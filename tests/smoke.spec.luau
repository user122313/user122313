local t = require("./lib/t")
t.test("smoke: 1 + 1 = 2", function()
	t.eq(1 + 1, 2)
end)
