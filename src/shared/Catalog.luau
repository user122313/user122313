local Types = require(script.Parent.Types)

type TreasureDef = Types.TreasureDef

local all: { TreasureDef } = {
	{ id = "pizza_box", name = "Pizza Box", rarity = "common" },
	{ id = "old_sock", name = "Old Sock", rarity = "common" },
	{ id = "gum_blob", name = "Gum Blob", rarity = "common" },
	{ id = "fish_bone", name = "Fish Bone", rarity = "common" },
	{ id = "disco_can", name = "Disco Can", rarity = "rare" },
	{ id = "toothbrush_bundle", name = "Toothbrush Bundle", rarity = "rare" },
	{ id = "cap_pile", name = "Golden Bottle Cap Pile", rarity = "rare" },
	{ id = "golden_toaster", name = "Golden Toaster", rarity = "legendary" },
	{ id = "broken_crown", name = "Broken Crown", rarity = "legendary" },
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
