local Config = require(script.Parent.Config)

local TrapRules = {}

function TrapRules.canBuy(caps: number): boolean
	return caps >= Config.BANANA_COST
end

function TrapRules.canPlace(placed: number, inOwnBase: boolean): (boolean, string?)
	if not inOwnBase then
		return false, "not_in_base"
	end
	if placed >= Config.MAX_BANANAS then
		return false, "max_traps"
	end
	return true, nil
end

-- Is the victim really close to the peel (distance root to peel center)? Broken numbers: no.
function TrapRules.bananaTouchValid(distance: number): boolean
	if type(distance) ~= "number" or distance ~= distance or distance < 0 then
		return false
	end
	return distance <= Config.BANANA_TRIGGER_RADIUS
end

function TrapRules.slipOutcome(carrying: boolean): { helplessSeconds: number, dropsLoot: boolean }
	return { helplessSeconds = Config.SLIP_SECONDS, dropsLoot = carrying }
end

return TrapRules
