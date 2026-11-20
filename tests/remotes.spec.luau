local t = require("./lib/t")
local load = require("./lib/load")

t.test("remote names are unique", function()
	local Remotes = load("Remotes")
	local seen = {}
	for _, name in Remotes.names do
		t.truthy(not seen[name])
		seen[name] = true
	end
end)

t.test("all remotes from the plan exist", function()
	local Remotes = load("Remotes")
	local have = {}
	for _, name in Remotes.names do
		have[name] = true
	end
	for _, name in {
		"HudUpdate",
		"Announce",
		"RequestPickup",
		"RequestPlace",
		"RequestStealStart",
		"RequestStealCommit",
		"RequestBuyBanana",
		"RequestPlaceBanana",
		"RequestUpgradeBase",
		"Slipped",
	} do
		t.truthy(have[name])
	end
end)
