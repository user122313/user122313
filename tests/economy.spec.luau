local t = require("./lib/t")
local load = require("./lib/load")

t.test("income of empty base is 0", function()
	local Economy = load("Economy")
	t.eq(Economy.incomePerSecond({}), 0)
end)

t.test("income sums rarities (common+rare+legendary = 20)", function()
	local Economy, Catalog = load("Economy"), load("Catalog")
	local ids = {}
	for _, def in Catalog.all do
		if def.rarity == "common" and not ids[1] then
			ids[1] = def.id
		elseif def.rarity == "rare" and not ids[2] then
			ids[2] = def.id
		elseif def.rarity == "legendary" and not ids[3] then
			ids[3] = def.id
		end
	end
	t.eq(Economy.incomePerSecond(ids), 20)
end)

t.test("unknown id adds 0 income", function()
	local Economy = load("Economy")
	t.eq(Economy.incomePerSecond({ "does_not_exist" }), 0)
end)

t.test("capacity level 1 = 4, level 2 = 8", function()
	local Economy = load("Economy")
	t.eq(Economy.capacity(1), 4)
	t.eq(Economy.capacity(2), 8)
end)

t.test("rollRarity thresholds follow DUMP_WEIGHTS (70/25/5)", function()
	local Economy = load("Economy")
	t.eq(Economy.rollRarity(0), "common")
	t.eq(Economy.rollRarity(0.69), "common")
	t.eq(Economy.rollRarity(0.70), "rare")
	t.eq(Economy.rollRarity(0.94), "rare")
	t.eq(Economy.rollRarity(0.95), "legendary")
	t.eq(Economy.rollRarity(0.999), "legendary")
end)

t.test("catalog has 8 to 10 treasures, all rarities, unique ids", function()
	local Catalog = load("Catalog")
	t.truthy(#Catalog.all >= 8 and #Catalog.all <= 10)
	local seen, rarities = {}, {}
	for _, def in Catalog.all do
		t.truthy(not seen[def.id])
		seen[def.id] = true
		rarities[def.rarity] = true
	end
	t.truthy(rarities.common and rarities.rare and rarities.legendary)
end)

t.test("catalog start treasure exists and is common", function()
	local Catalog = load("Catalog")
	local def = Catalog.get(Catalog.startTreasureId)
	t.truthy(def)
	t.eq(def.rarity, "common")
end)

t.test("catalog get returns nil for unknown id", function()
	local Catalog = load("Catalog")
	t.eq(Catalog.get("nope"), nil)
end)
