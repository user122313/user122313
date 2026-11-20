local Types = require(script.Parent.Types)

type TreasureDef = Types.TreasureDef

local all: { TreasureDef } = {
	{ id = "pizza_box", name = "Pizzakarton", rarity = "common" },
	{ id = "old_sock", name = "Alte Socke", rarity = "common" },
	{ id = "gum_blob", name = "Kaugummi-Klumpen", rarity = "common" },
	{ id = "fish_bone", name = "Fischgräte", rarity = "common" },
	{ id = "disco_can", name = "Disco-Dose", rarity = "rare" },
	{ id = "toothbrush_bundle", name = "Zahnbürsten-Bündel", rarity = "rare" },
	{ id = "cap_pile", name = "Goldener Kronkorken-Haufen", rarity = "rare" },
	{ id = "golden_toaster", name = "Goldener Toaster", rarity = "legendary" },
	{ id = "broken_crown", name = "Kaputte Krone", rarity = "legendary" },
}

local byId: { [string]: TreasureDef } = {}
for _, def in all do
	byId[def.id] = def
end

local Catalog = {
	all = all,
	startTreasureId = "pizza_box",
}

function Catalog.get(id: string): TreasureDef?
	return byId[id]
end

return Catalog
