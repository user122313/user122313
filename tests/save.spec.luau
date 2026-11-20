local t = require("./lib/t")
local load = require("./lib/load")

local function schema()
	return load("SaveSchema")
end

t.test("default: version, 0 caps, start treasure, level 1", function()
	local S, Catalog = schema(), load("Catalog")
	t.eq(S.default(), { version = S.CURRENT_VERSION, caps = 0, treasures = { Catalog.startTreasureId }, baseLevel = 1 })
end)

t.test("migrate(nil) = default", function()
	local S = schema()
	t.eq(S.migrate(nil), S.default())
end)

t.test("migrate of non-table = default", function()
	local S = schema()
	t.eq(S.migrate("kaputt"), S.default())
	t.eq(S.migrate(42), S.default())
end)

t.test("migrate({}) = default", function()
	local S = schema()
	t.eq(S.migrate({}), S.default())
end)

t.test("valid v1 data unchanged", function()
	local S = schema()
	local data = { version = 1, caps = 250, treasures = { "pizza_box", "golden_toaster" }, baseLevel = 2 }
	t.eq(S.migrate(data), data)
end)

t.test("explicitly empty treasure list stays empty", function()
	local S = schema()
	local data = { version = 1, caps = 5, treasures = {}, baseLevel = 1 }
	t.eq(S.migrate(data), data)
end)

t.test("negative caps become 0", function()
	local S = schema()
	t.eq(S.migrate({ version = 1, caps = -50, treasures = { "pizza_box" }, baseLevel = 1 }).caps, 0)
end)

t.test("non-number caps become 0", function()
	local S = schema()
	t.eq(S.migrate({ version = 1, caps = "viel", treasures = { "pizza_box" }, baseLevel = 1 }).caps, 0)
end)

t.test("NaN and infinite caps become 0", function()
	local S = schema()
	t.eq(S.migrate({ version = 1, caps = 0 / 0, treasures = {}, baseLevel = 1 }).caps, 0)
	t.eq(S.migrate({ version = 1, caps = math.huge, treasures = {}, baseLevel = 1 }).caps, 0)
end)

t.test("unknown treasure ids dropped, valid kept", function()
	local S = schema()
	local out = S.migrate({ version = 1, caps = 1, treasures = { "pizza_box", "gibt_es_nicht", 5, "old_sock" }, baseLevel = 1 })
	t.eq(out.treasures, { "pizza_box", "old_sock" })
end)

t.test("treasures beyond capacity of baseLevel are kept", function()
	local S = schema()
	local ids = { "pizza_box", "old_sock", "gum_blob", "fish_bone", "disco_can", "cap_pile" }
	t.eq(#S.migrate({ version = 1, caps = 1, treasures = ids, baseLevel = 1 }).treasures, 6)
end)

t.test("baseLevel clamped to 1..2", function()
	local S = schema()
	t.eq(S.migrate({ version = 1, caps = 1, treasures = {}, baseLevel = 0 }).baseLevel, 1)
	t.eq(S.migrate({ version = 1, caps = 1, treasures = {}, baseLevel = 9 }).baseLevel, 2)
	t.eq(S.migrate({ version = 1, caps = 1, treasures = {}, baseLevel = "x" }).baseLevel, 1)
end)

t.test("missing version is upgraded to current", function()
	local S = schema()
	t.eq(S.migrate({ caps = 10, treasures = { "pizza_box" }, baseLevel = 1 }).version, S.CURRENT_VERSION)
end)

t.test("output always has all four fields", function()
	local S = schema()
	for _, raw in { {}, { caps = 3 }, { treasures = "x" }, { baseLevel = 2 } } do
		local out = S.migrate(raw)
		t.eq(type(out.version), "number")
		t.eq(type(out.caps), "number")
		t.eq(type(out.treasures), "table")
		t.eq(type(out.baseLevel), "number")
	end
end)

t.test("caps are whole numbers", function()
	local S = schema()
	t.eq(S.migrate({ version = 1, caps = 12.7, treasures = {}, baseLevel = 1 }).caps, 12)
end)

t.test("isFromFuture: version above CURRENT_VERSION is detected", function()
	local S = schema()
	t.eq(S.isFromFuture({ version = S.CURRENT_VERSION + 1 }), true)
	t.eq(S.isFromFuture({ version = S.CURRENT_VERSION }), false)
	t.eq(S.isFromFuture(nil), false)
	t.eq(S.isFromFuture({}), false)
end)

t.test("treasure list ignores non-array keys", function()
	local S = schema()
	local out = S.migrate({ version = 1, caps = 1, treasures = { "pizza_box", x = "golden_toaster" }, baseLevel = 1 })
	t.eq(out.treasures, { "pizza_box" })
end)

t.test("treasure list is capped at 200 entries", function()
	local S = schema()
	local ids = {}
	for i = 1, 500 do
		ids[i] = "pizza_box"
	end
	t.eq(#S.migrate({ version = 1, caps = 1, treasures = ids, baseLevel = 1 }).treasures, 200)
end)

t.test("caps are capped at 1e12", function()
	local S = schema()
	t.eq(S.migrate({ version = 1, caps = 1e300, treasures = {}, baseLevel = 1 }).caps, 1e12)
end)

t.test("fields have the right types", function()
	local S = schema()
	for _, raw in { {}, { caps = "x", treasures = 5, baseLevel = {} } } do
		local out = S.migrate(raw)
		t.eq(type(out.version), "number")
		t.eq(type(out.caps), "number")
		t.eq(type(out.treasures), "table")
		t.eq(type(out.baseLevel), "number")
	end
end)
