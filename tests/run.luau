local fs = require("@lune/fs")
local process = require("@lune/process")
local t = require("./lib/t")

local specs = {}
for _, entry in fs.readDir("tests") do
	if string.match(entry, "%.spec%.luau$") then
		table.insert(specs, entry)
	end
end
table.sort(specs)

for _, file in specs do
	local name = string.gsub(file, "%.luau$", "")
	require(`./{name}`)
end

local failed = t.report()
if failed > 0 then
	process.exit(1)
end
