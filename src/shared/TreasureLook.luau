-- Visual parts of each treasure. Pure data, built into Parts by TreasureService.createTreasure.
-- Every part is given in WORLD axes relative to the treasure's 3x3x3 body (center = 0, floor = y -1.5):
--   size   = { x, y, z } studs, offset = { x, y, z } studs, color = { r, g, b } (0-255), material = Enum.Material name.
--   kind   = "block", "ball" (size = diameter in all axes) or "can" (upright cylinder: size = { diameter, height, diameter }).
-- Keep every part inside the body box (tests/look.spec.luau checks it), so placing and carrying keep working.
export type LookPart = {
	kind: string,
	size: { number },
	offset: { number },
	color: { number },
	material: string,
}

local function part(kind: string, size: { number }, offset: { number }, color: { number }, material: string?): LookPart
	return { kind = kind, size = size, offset = offset, color = color, material = material or "SmoothPlastic" }
end

local CARDBOARD = { 205, 160, 100 }
local GOLD = { 240, 190, 40 }
local WHITE = { 240, 240, 228 }

local looks: { [string]: { LookPart } } = {
	pizza_box = {
		part("block", { 3, 0.5, 3 }, { 0, -1.25, 0 }, CARDBOARD, "Cardboard"),
		part("block", { 2.6, 0.1, 2.6 }, { 0, -0.95, 0 }, { 245, 205, 90 }),
		part("can", { 0.8, 0.12, 0.8 }, { -0.6, -0.85, -0.5 }, { 200, 50, 40 }),
		part("can", { 0.8, 0.12, 0.8 }, { 0.6, -0.85, 0.2 }, { 200, 50, 40 }),
		part("can", { 0.8, 0.12, 0.8 }, { -0.3, -0.85, 0.8 }, { 200, 50, 40 }),
	},
	old_sock = {
		part("block", { 1, 2, 1 }, { 0, -0.5, 0 }, { 150, 170, 205 }, "Fabric"),
		part("block", { 1, 0.8, 1.6 }, { 0, -1.1, 0.6 }, { 150, 170, 205 }, "Fabric"),
		part("block", { 1.06, 0.3, 1.06 }, { 0, 0.25, 0 }, { 210, 60, 60 }, "Fabric"),
	},
	gum_blob = {
		part("ball", { 2.6, 2.6, 2.6 }, { 0, -0.2, 0 }, { 255, 120, 190 }),
		part("ball", { 1, 1, 1 }, { 0.9, -1, 0.7 }, { 255, 150, 205 }),
		part("ball", { 0.5, 0.5, 0.5 }, { -0.7, 0.9, 0.3 }, { 255, 190, 225 }),
	},
	fish_bone = {
		part("block", { 0.25, 0.25, 3 }, { 0, -1.35, 0 }, WHITE),
		part("block", { 1.8, 0.2, 0.2 }, { 0, -1.35, -0.5 }, WHITE),
		part("block", { 1.8, 0.2, 0.2 }, { 0, -1.35, 0.1 }, WHITE),
		part("block", { 1.4, 0.2, 0.2 }, { 0, -1.35, 0.7 }, WHITE),
		part("ball", { 0.8, 0.8, 0.8 }, { 0, -1.1, -1.05 }, WHITE),
	},
	disco_can = {
		part("can", { 1.8, 2.4, 1.8 }, { 0, -0.3, 0 }, { 200, 205, 215 }, "Metal"),
		part("can", { 1.9, 0.4, 1.9 }, { 0, -0.3, 0 }, { 255, 70, 220 }, "Neon"),
		part("can", { 1.9, 0.2, 1.9 }, { 0, 0.95, 0 }, { 150, 155, 165 }, "Metal"),
	},
	toothbrush_bundle = {
		part("block", { 0.35, 0.3, 3 }, { -0.5, -1.35, 0 }, { 70, 140, 255 }),
		part("block", { 0.35, 0.3, 3 }, { 0, -1.05, 0 }, { 90, 210, 120 }),
		part("block", { 0.35, 0.3, 3 }, { 0.5, -1.35, 0 }, { 255, 130, 190 }),
		part("block", { 0.5, 0.45, 0.7 }, { -0.5, -1.3, -1.1 }, WHITE),
		part("block", { 0.5, 0.45, 0.7 }, { 0, -1, -1.1 }, WHITE),
		part("block", { 0.5, 0.45, 0.7 }, { 0.5, -1.3, -1.1 }, WHITE),
	},
	cap_pile = {
		part("can", { 1.5, 0.25, 1.5 }, { -0.6, -1.35, 0.3 }, GOLD, "Metal"),
		part("can", { 1.5, 0.25, 1.5 }, { 0.6, -1.35, -0.2 }, GOLD, "Metal"),
		part("can", { 1.5, 0.25, 1.5 }, { 0.1, -1.1, 0.1 }, { 255, 215, 80 }, "Metal"),
		part("can", { 1.5, 0.25, 1.5 }, { -0.2, -0.85, -0.1 }, GOLD, "Metal"),
	},
	golden_toaster = {
		part("block", { 2.6, 1.6, 1.6 }, { 0, -0.7, 0 }, GOLD, "Metal"),
		part("block", { 0.7, 0.1, 1.2 }, { -0.5, 0.12, 0 }, { 60, 40, 10 }),
		part("block", { 0.7, 0.1, 1.2 }, { 0.5, 0.12, 0 }, { 60, 40, 10 }),
		part("block", { 0.2, 0.5, 0.3 }, { 1.2, -0.3, 0 }, { 120, 120, 130 }, "Metal"),
		part("block", { 2.2, 0.3, 1.4 }, { 0, -1.35, 0 }, { 180, 130, 20 }, "Metal"),
	},
	broken_crown = {
		part("can", { 2.4, 0.8, 2.4 }, { 0, -1.1, 0 }, GOLD, "Metal"),
		part("block", { 0.4, 0.9, 0.4 }, { 1, -0.25, 0 }, GOLD, "Metal"),
		part("block", { 0.4, 0.9, 0.4 }, { 0.31, -0.25, 0.95 }, GOLD, "Metal"),
		part("block", { 0.4, 0.9, 0.4 }, { -0.81, -0.25, 0.59 }, GOLD, "Metal"),
		part("block", { 0.4, 0.35, 0.4 }, { -0.81, -0.52, -0.59 }, GOLD, "Metal"),
		part("block", { 0.4, 0.9, 0.4 }, { 0.31, -0.25, -0.95 }, GOLD, "Metal"),
		part("ball", { 0.4, 0.4, 0.4 }, { 0, -1.1, 1.15 }, { 220, 40, 60 }, "Neon"),
	},
}

local TreasureLook = {}

-- The parts of this treasure, or nil for an unknown id.
function TreasureLook.get(defId: string): { LookPart }?
	return looks[defId]
end

return TreasureLook
