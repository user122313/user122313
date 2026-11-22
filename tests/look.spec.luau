local t = require("./lib/t")
local load = require("./lib/load")

local HALF = 1.5 -- Body is 3x3x3; every visible part must stay inside (small tolerance)
local TOLERANCE = 0.05

local function extents(part)
	-- Sizes are given in WORLD axes (x, y, z) for every kind.
	return part.size[1] / 2, part.size[2] / 2, part.size[3] / 2
end

t.test("every catalog treasure has a look with at least 2 parts", function()
	local Catalog, Look = load("Catalog"), load("TreasureLook")
	for _, def in Catalog.all do
		local parts = Look.get(def.id)
		t.eq(type(parts), "table")
		t.eq(#parts >= 2, true)
	end
end)

t.test("unknown treasure id has no look", function()
	t.eq(load("TreasureLook").get("nope"), nil)
end)

t.test("all parts stay inside the 3x3x3 body and above the floor", function()
	local Catalog, Look = load("Catalog"), load("TreasureLook")
	for _, def in Catalog.all do
		for _, part in Look.get(def.id) do
			local hx, hy, hz = extents(part)
			t.eq(math.abs(part.offset[1]) + hx <= HALF + TOLERANCE, true)
			t.eq(math.abs(part.offset[3]) + hz <= HALF + TOLERANCE, true)
			t.eq(part.offset[2] + hy <= HALF + TOLERANCE, true)
			t.eq(part.offset[2] - hy >= -HALF - TOLERANCE, true)
		end
	end
end)

t.test("every part has a known kind, valid colors and a material name", function()
	local Catalog, Look = load("Catalog"), load("TreasureLook")
	local kinds = { block = true, ball = true, can = true }
	for _, def in Catalog.all do
		for _, part in Look.get(def.id) do
			t.eq(kinds[part.kind], true)
			t.eq(#part.color, 3)
			for _, c in part.color do
				t.eq(c >= 0 and c <= 255, true)
			end
			t.eq(type(part.material), "string")
			t.eq(#part.size, 3)
			t.eq(#part.offset, 3)
			for _, s in part.size do
				t.eq(s > 0, true)
			end
		end
	end
end)

t.test("treasures look different from each other", function()
	local Catalog, Look = load("Catalog"), load("TreasureLook")
	local seen = {}
	for _, def in Catalog.all do
		local first = Look.get(def.id)[1]
		local key = `{first.kind}/{table.concat(first.size, ",")}/{table.concat(first.color, ",")}`
		t.eq(seen[key], nil)
		seen[key] = true
	end
end)
