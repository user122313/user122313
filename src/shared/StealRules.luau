local Config = require(script.Parent.Config)

export type StealRequest = {
	distance: number,
	heldSeconds: number,
	now: number,
	thiefCarrying: boolean,
	thiefBaseFull: boolean,
	thiefLastStealAt: number?,
	thiefSpeed: number,
	treasureOwnerId: number?,
	thiefId: number,
	treasureLockedBy: number?,
}

local StealRules = {}

local function isGoodNumber(v: any): boolean
	return type(v) == "number" and v == v and v >= 0 and v ~= math.huge
end

-- Feste Prüfreihenfolge; der erste Verstoß bestimmt den Grund.
-- Kaputte Eingaben (NaN, negativ, fehlend) werden abgelehnt, nie durchgelassen.
-- thiefLastStealAt = nil heißt: noch nie geklaut, kein Cooldown.
function StealRules.validate(req: StealRequest): (boolean, string?)
	if
		type(req.thiefId) ~= "number"
		or not isGoodNumber(req.distance)
		or not isGoodNumber(req.heldSeconds)
		or not isGoodNumber(req.now)
		or not isGoodNumber(req.thiefSpeed)
		or (req.thiefLastStealAt ~= nil and (type(req.thiefLastStealAt) ~= "number" or req.thiefLastStealAt ~= req.thiefLastStealAt))
	then
		return false, "bad_input"
	end
	if req.treasureOwnerId == nil then
		return false, "no_owner"
	end
	if req.treasureOwnerId == req.thiefId then
		return false, "own_treasure"
	end
	if req.treasureLockedBy ~= nil and req.treasureLockedBy ~= req.thiefId then
		return false, "locked"
	end
	if req.thiefCarrying then
		return false, "carrying"
	end
	if req.thiefBaseFull then
		return false, "base_full"
	end
	if req.thiefLastStealAt ~= nil and req.now - req.thiefLastStealAt < Config.STEAL_COOLDOWN then
		return false, "cooldown"
	end
	if req.distance > Config.STEAL_REACH then
		return false, "too_far"
	end
	if req.thiefSpeed > Config.MAX_MOVE_SPEED then
		return false, "too_fast"
	end
	if req.heldSeconds < Config.STEAL_HOLD - Config.STEAL_HOLD_TOLERANCE then
		return false, "too_short"
	end
	return true, nil
end

-- Did the thief leave the treasure's reach during a running hold? Broken numbers cancel the hold.
function StealRules.holdBroken(distance: number): boolean
	if not isGoodNumber(distance) then
		return true
	end
	return distance > Config.STEAL_REACH + Config.STEAL_HOLD_REACH_TOLERANCE
end

-- Did a carrier jump (teleport) between two position samples?
-- Allowed: MAX_MOVE_SPEED over the elapsed time plus TELEPORT_SLACK. Broken numbers count as a jump.
function StealRules.teleportSuspected(distance: number, seconds: number): boolean
	if not isGoodNumber(distance) or not isGoodNumber(seconds) then
		return true
	end
	return distance > Config.MAX_MOVE_SPEED * seconds + Config.TELEPORT_SLACK
end

-- How long a thief must wait before he may start a steal again, after `failures` failed starts in a row.
function StealRules.retryDelay(failures: number): number
	if type(failures) ~= "number" or failures ~= failures or failures <= 0 then
		return 0
	end
	return Config.STEAL_RETRY_DELAY * math.min(math.floor(failures), Config.STEAL_RETRY_MAX_STEPS)
end

-- carrying: wird der Schatz gerade von einem Dieb getragen?
function StealRules.resolveLeave(role: "thief" | "owner", carrying: boolean): "return_to_owner" | "none"
	if carrying then
		return "return_to_owner"
	end
	return "none"
end

return StealRules
