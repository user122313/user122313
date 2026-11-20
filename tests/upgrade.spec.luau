local t = require("./lib/t")
local load = require("./lib/load")

t.test("canUpgrade false below cost", function()
	local Economy, Config = load("Economy"), load("Config")
	t.eq(Economy.canUpgrade(1, Config.UPGRADE_COST - 1), false)
end)

t.test("canUpgrade true at cost on level 1", function()
	local Economy, Config = load("Economy"), load("Config")
	t.eq(Economy.canUpgrade(1, Config.UPGRADE_COST), true)
end)

t.test("canUpgrade false on max level 2", function()
	local Economy = load("Economy")
	t.eq(Economy.canUpgrade(2, 999999), false)
end)
