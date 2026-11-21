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

t.test("remotes nobody listens to are not offered (pickup and place use prompts)", function()
	local Remotes = load("Remotes")
	t.eq(table.find(Remotes.names, "RequestPickup"), nil)
	t.eq(table.find(Remotes.names, "RequestPlace"), nil)
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
