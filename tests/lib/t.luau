-- Minimaler Test-Helfer (kein Roblox nötig).
local t = {}

local passed, failed = 0, 0
local failures = {}

local function deepEqual(a: any, b: any): boolean
	if type(a) ~= type(b) then
		return false
	end
	if type(a) ~= "table" then
		return a == b
	end
	for k, v in a do
		if not deepEqual(v, b[k]) then
			return false
		end
	end
	for k in b do
		if a[k] == nil then
			return false
		end
	end
	return true
end

function t.test(name: string, fn: () -> ())
	local ok, err = pcall(fn)
	if ok then
		passed += 1
	else
		failed += 1
		table.insert(failures, `FAIL {name}\n     {tostring(err)}`)
	end
end

function t.eq(actual: any, expected: any)
	if not deepEqual(actual, expected) then
		error(`expected {tostring(expected)}, got {tostring(actual)}`, 2)
	end
end

function t.truthy(v: any)
	if not v then
		error("expected truthy value", 2)
	end
end

function t.report(): number
	for _, f in failures do
		print(f)
	end
	print(`{passed} passed, {failed} failed`)
	return failed
end

return t
