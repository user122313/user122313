local t = require("./lib/t")
local load = require("./lib/load")

local function schema()
	return load("SaveSchema")
end

-- splitByCapacity: which saved treasures go into slots, which wait as overflow

t.test("split: everything fits", function()
	local S = schema()
	local placed, overflow = S.splitByCapacity({ "pizza_box", "old_sock" }, 4)
	t.eq(placed, { "pizza_box", "old_sock" })
	t.eq(overflow, {})
end)

t.test("split: extra treasures go to overflow, order stays", function()
	local S = schema()
	local ids = { "pizza_box", "old_sock", "gum_blob", "fish_bone", "disco_can", "golden_toaster" }
	local placed, overflow = S.splitByCapacity(ids, 4)
	t.eq(placed, { "pizza_box", "old_sock", "gum_blob", "fish_bone" })
	t.eq(overflow, { "disco_can", "golden_toaster" })
end)

t.test("split: nothing is lost or duplicated", function()
	local S = schema()
	local ids = { "pizza_box", "pizza_box", "golden_toaster", "old_sock", "pizza_box" }
	local placed, overflow = S.splitByCapacity(ids, 2)
	t.eq(#placed + #overflow, 5)
	t.eq(placed, { "pizza_box", "pizza_box" })
	t.eq(overflow, { "golden_toaster", "old_sock", "pizza_box" })
end)

t.test("split: unknown and non-string ids are skipped", function()
	local S = schema()
	local placed, overflow = S.splitByCapacity({ "gibt_es_nicht", 5, "pizza_box", "old_sock" } :: any, 1)
	t.eq(placed, { "pizza_box" })
	t.eq(overflow, { "old_sock" })
end)

t.test("split: capacity 0, negative or NaN puts everything into overflow", function()
	local S = schema()
	for _, cap in { 0, -3, 0 / 0 } do
		local placed, overflow = S.splitByCapacity({ "pizza_box", "old_sock" }, cap)
		t.eq(placed, {})
		t.eq(overflow, { "pizza_box", "old_sock" })
	end
end)

t.test("split: broken list gives two empty lists", function()
	local S = schema()
	local placed, overflow = S.splitByCapacity(nil :: any, 4)
	t.eq(placed, {})
	t.eq(overflow, {})
end)

t.test("split: does not change the input list", function()
	local S = schema()
	local ids = { "pizza_box", "old_sock", "gum_blob" }
	S.splitByCapacity(ids, 1)
	t.eq(ids, { "pizza_box", "old_sock", "gum_blob" })
end)

-- fromRuntime: clean SaveData built from the live game numbers

t.test("fromRuntime: normal values pass through", function()
	local S = schema()
	t.eq(S.fromRuntime(120, { "pizza_box", "golden_toaster" }, 2), {
		version = S.CURRENT_VERSION,
		caps = 120,
		treasures = { "pizza_box", "golden_toaster" },
		baseLevel = 2,
	})
end)

t.test("fromRuntime: empty treasure list stays empty (no start treasure added)", function()
	local S = schema()
	t.eq(S.fromRuntime(5, {}, 1).treasures, {})
	t.eq(S.fromRuntime(5, nil :: any, 1).treasures, {})
end)

t.test("fromRuntime: negative, NaN and infinite caps become 0", function()
	local S = schema()
	t.eq(S.fromRuntime(-10, {}, 1).caps, 0)
	t.eq(S.fromRuntime(0 / 0, {}, 1).caps, 0)
	t.eq(S.fromRuntime(math.huge, {}, 1).caps, 0)
	t.eq(S.fromRuntime("x" :: any, {}, 1).caps, 0)
end)

t.test("fromRuntime: caps rounded down", function()
	local S = schema()
	t.eq(S.fromRuntime(12.9, {}, 1).caps, 12)
end)

t.test("fromRuntime: level clamped to 1..2", function()
	local S = schema()
	t.eq(S.fromRuntime(0, {}, 0).baseLevel, 1)
	t.eq(S.fromRuntime(0, {}, 7).baseLevel, 2)
	t.eq(S.fromRuntime(0, {}, nil :: any).baseLevel, 1)
end)

t.test("fromRuntime: unknown ids dropped, order and duplicates kept", function()
	local S = schema()
	local out = S.fromRuntime(0, { "old_sock", "nope", "pizza_box", "old_sock" }, 1)
	t.eq(out.treasures, { "old_sock", "pizza_box", "old_sock" })
end)

t.test("fromRuntime: result survives migrate unchanged", function()
	local S = schema()
	local out = S.fromRuntime(77, { "disco_can", "pizza_box" }, 2)
	t.eq(S.migrate(out), out)
end)

t.test("fromRuntime: does not share the input list", function()
	local S = schema()
	local ids = { "pizza_box" }
	local out = S.fromRuntime(0, ids, 1)
	table.insert(ids, "old_sock")
	t.eq(out.treasures, { "pizza_box" })
end)
