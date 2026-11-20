local Config = require(script.Parent.Config)

export type StealRequest = {
	distance: number,
	heldSeconds: number,
	now: number,
	thiefCarrying: boolean,
	thiefBaseFull: boolean,
	thiefLastStealAt: number,
	thiefSpeed: number,
	treasureOwnerId: number?,
	thiefId: number,
	treasureLockedBy: number?,
}

local StealRules = {}

-- Feste Prüfreihenfolge; der erste Verstoß bestimmt den Grund.
function StealRules.validate(req: StealRequest): (boolean, string?)
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
	if req.now - req.thiefLastStealAt < Config.STEAL_COOLDOWN then
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

-- carrying: wird der Schatz gerade von einem Dieb getragen?
function StealRules.resolveLeave(role: "thief" | "owner", carrying: boolean): "return_to_owner" | "none"
	if carrying then
		return "return_to_owner"
	end
	return "none"
end

return StealRules
