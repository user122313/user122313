-- Lädt Module aus src/shared so, wie Roblox sie lädt: require(script.Parent.X).
-- Läuft mit Lune, aus dem Projektordner gestartet.
local fs = require("@lune/fs")
local luau = require("@lune/luau")

local cache: { [string]: any } = {}
local load

local siblings = setmetatable({}, {
	__index = function(_, name: string)
		return load(name)
	end,
})

local fakeScript = { Parent = siblings }

load = function(name: string): any
	if cache[name] ~= nil then
		return cache[name]
	end
	local source = fs.readFile(`src/shared/{name}.luau`)
	local chunk = luau.load(source, {
		debugName = name,
		environment = {
			script = fakeScript,
			require = function(m: any)
				return m
			end,
		},
	})
	local result = chunk()
	cache[name] = result
	return result
end

return load
