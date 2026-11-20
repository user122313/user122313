local t = require("./lib/t")
local load = require("./lib/load")

t.test("only rare and legendary steals are announced to everybody", function()
	local AnnounceRules = load("AnnounceRules")
	t.eq(AnnounceRules.shouldAnnounce("common"), false)
	t.eq(AnnounceRules.shouldAnnounce("rare"), true)
	t.eq(AnnounceRules.shouldAnnounce("legendary"), true)
	t.eq(AnnounceRules.shouldAnnounce("nonsense"), false)
end)

t.test("stolen text names the thief and shouts the treasure", function()
	local AnnounceRules = load("AnnounceRules")
	t.eq(AnnounceRules.stolenText("Alex", "Golden Toaster"), "⚠ Alex stole the GOLDEN TOASTER!")
end)

t.test("every catalog treasure produces a text", function()
	local AnnounceRules, Catalog = load("AnnounceRules"), load("Catalog")
	for _, def in Catalog.all do
		t.truthy(#AnnounceRules.stolenText("X", def.name) > 10)
	end
end)

t.test("StealAlarm remote exists", function()
	local Remotes = load("Remotes")
	t.truthy(table.find(Remotes.names, "StealAlarm") ~= nil)
end)
