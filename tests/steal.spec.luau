local t = require("./lib/t")
local load = require("./lib/load")

local function valid(overrides: { [string]: any }?)
	local req = {
		distance = 5,
		heldSeconds = 1.5,
		now = 100,
		thiefCarrying = false,
		thiefBaseFull = false,
		thiefLastStealAt = 0,
		thiefSpeed = 16,
		treasureOwnerId = 2,
		thiefId = 1,
		treasureLockedBy = nil,
	}
	for k, v in overrides or {} do
		req[k] = v
	end
	return req
end

local function check(overrides: { [string]: any }?)
	local StealRules = load("StealRules")
	return StealRules.validate(valid(overrides))
end

t.test("valid steal passes", function()
	local ok, reason = check()
	t.eq(ok, true)
	t.eq(reason, nil)
end)

t.test("rejects distance beyond STEAL_REACH", function()
	local Config = load("Config")
	local ok, reason = check({ distance = Config.STEAL_REACH + 0.1 })
	t.eq(ok, false)
	t.eq(reason, "too_far")
	t.eq((check({ distance = Config.STEAL_REACH })), true)
end)

t.test("hold time: 1.29s rejected, 1.31s accepted (STEAL_HOLD - tolerance)", function()
	local ok, reason = check({ heldSeconds = 1.29 })
	t.eq(ok, false)
	t.eq(reason, "too_short")
	t.eq((check({ heldSeconds = 1.31 })), true)
end)

t.test("rejects when already carrying", function()
	local ok, reason = check({ thiefCarrying = true })
	t.eq(ok, false)
	t.eq(reason, "carrying")
end)

t.test("rejects when thief base is full", function()
	local ok, reason = check({ thiefBaseFull = true })
	t.eq(ok, false)
	t.eq(reason, "base_full")
end)

t.test("rejects within STEAL_COOLDOWN of last steal, accepts at exactly the cooldown", function()
	local Config = load("Config")
	local ok, reason = check({ now = 100, thiefLastStealAt = 100 - Config.STEAL_COOLDOWN + 0.5 })
	t.eq(ok, false)
	t.eq(reason, "cooldown")
	t.eq((check({ now = 100, thiefLastStealAt = 100 - Config.STEAL_COOLDOWN })), true)
end)

t.test("second thief rejected when treasure locked by another player", function()
	local ok, reason = check({ treasureLockedBy = 3 })
	t.eq(ok, false)
	t.eq(reason, "locked")
end)

t.test("treasure locked by the same thief passes", function()
	t.eq((check({ treasureLockedBy = 1 })), true)
end)

t.test("rejects own treasure", function()
	local ok, reason = check({ treasureOwnerId = 1 })
	t.eq(ok, false)
	t.eq(reason, "own_treasure")
end)

t.test("rejects unowned dump treasure as steal (use pickup instead)", function()
	local req = valid()
	req.treasureOwnerId = nil
	local ok, reason = load("StealRules").validate(req)
	t.eq(ok, false)
	t.eq(reason, "no_owner")
end)

t.test("rejects speed above MAX_MOVE_SPEED", function()
	local Config = load("Config")
	local ok, reason = check({ thiefSpeed = Config.MAX_MOVE_SPEED + 1 })
	t.eq(ok, false)
	t.eq(reason, "too_fast")
end)

t.test("check order: locked wins over too_far", function()
	local ok, reason = check({ treasureLockedBy = 3, distance = 999 })
	t.eq(ok, false)
	t.eq(reason, "locked")
end)

t.test("thief leaves while carrying -> return_to_owner", function()
	local StealRules = load("StealRules")
	t.eq(StealRules.resolveLeave("thief", true), "return_to_owner")
end)

t.test("owner leaves while thief carries -> return_to_owner", function()
	local StealRules = load("StealRules")
	t.eq(StealRules.resolveLeave("owner", true), "return_to_owner")
end)

t.test("leave without carrying -> none", function()
	local StealRules = load("StealRules")
	t.eq(StealRules.resolveLeave("thief", false), "none")
	t.eq(StealRules.resolveLeave("owner", false), "none")
end)

-- Review-Funde: kaputte Zahlen müssen abgelehnt werden, nie durchgehen oder abstürzen.
for _, field in { "distance", "heldSeconds", "now", "thiefSpeed" } do
	t.test(`bad_input: NaN in {field} is rejected`, function()
		local ok, reason = check({ [field] = 0 / 0 })
		t.eq(ok, false)
		t.eq(reason, "bad_input")
	end)
	t.test(`bad_input: negative {field} is rejected`, function()
		local ok, reason = check({ [field] = -1 })
		t.eq(ok, false)
		t.eq(reason, "bad_input")
	end)
	t.test(`bad_input: missing {field} is rejected without crashing`, function()
		local req = valid()
		req[field] = nil
		local ok, reason = load("StealRules").validate(req)
		t.eq(ok, false)
		t.eq(reason, "bad_input")
	end)
end

t.test("bad_input: missing thiefId is rejected", function()
	local req = valid()
	req.thiefId = nil
	local ok, reason = load("StealRules").validate(req)
	t.eq(ok, false)
	t.eq(reason, "bad_input")
end)

t.test("first steal ever: thiefLastStealAt nil means no cooldown", function()
	local req = valid()
	req.thiefLastStealAt = nil
	t.eq((load("StealRules").validate(req)), true)
end)

t.test("boundaries: speed == MAX_MOVE_SPEED accepted, hold == 1.3 accepted", function()
	local Config = load("Config")
	t.eq((check({ thiefSpeed = Config.MAX_MOVE_SPEED })), true)
	t.eq((check({ heldSeconds = Config.STEAL_HOLD - Config.STEAL_HOLD_TOLERANCE })), true)
end)
