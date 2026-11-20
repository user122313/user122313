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

function TrapRules.slipOutcome(carrying: boolean): { helplessSeconds: number, dropsLoot: boolean }
	return { helplessSeconds = Config.SLIP_SECONDS, dropsLoot = carrying }
end

return TrapRules
