local Config = require(script.Parent.Config)
local Catalog = require(script.Parent.Catalog)
local Types = require(script.Parent.Types)

type Rarity = Types.Rarity

local Economy = {}

function Economy.incomePerSecond(ids: { string }): number
	local total = 0
	for _, id in ids do
		local def = Catalog.get(id)
		if def then
			total += Config.INCOME[def.rarity]
		end
	end
	return total
end

function Economy.capacity(baseLevel: number): number
	return Config.BASE_CAPACITY[baseLevel] or Config.BASE_CAPACITY[1]
end

function Economy.canUpgrade(baseLevel: number, caps: number): boolean
	if baseLevel >= #Config.BASE_CAPACITY then
		return false
	end
	return caps >= Config.UPGRADE_COST
end

-- r liegt in [0, 1). Schwellen kommen aus Config.DUMP_WEIGHTS.
function Economy.rollRarity(r: number): Rarity
	if r ~= r then
		return "common"
	end
	local w = Config.DUMP_WEIGHTS
	local sum = w.common + w.rare + w.legendary
	local x = r * sum
	if x < w.common then
		return "common"
	elseif x < w.common + w.rare then
		return "rare"
	end
	return "legendary"
end

return Economy
