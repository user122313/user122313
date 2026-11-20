local Catalog = require(script.Parent.Catalog)
local Config = require(script.Parent.Config)

export type SaveData = {
	version: number,
	caps: number,
	treasures: { string },
	baseLevel: number,
}

local SaveSchema = {}

SaveSchema.CURRENT_VERSION = 1
SaveSchema.MAX_CAPS = 1e12
SaveSchema.MAX_TREASURES = 200

function SaveSchema.default(): SaveData
	return {
		version = SaveSchema.CURRENT_VERSION,
		caps = 0,
		treasures = { Catalog.startTreasureId },
		baseLevel = 1,
	}
end

local function cleanCaps(v: any): number
	if type(v) ~= "number" or v ~= v or v == math.huge or v == -math.huge then
		return 0
	end
	return math.min(SaveSchema.MAX_CAPS, math.max(0, math.floor(v)))
end

local function cleanLevel(v: any): number
	if type(v) ~= "number" or v ~= v then
		return 1
	end
	return math.clamp(math.floor(v), 1, #Config.BASE_CAPACITY)
end

-- Only known Catalog ids, in the same order, duplicates kept. Never adds the start treasure.
local function knownIds(v: any): { string }
	local out = {}
	if type(v) ~= "table" then
		return out
	end
	for _, id in ipairs(v) do
		if #out >= SaveSchema.MAX_TREASURES then
			break
		end
		if type(id) == "string" and Catalog.get(id) then
			table.insert(out, id)
		end
	end
	return out
end

local function cleanTreasures(v: any): { string }
	if type(v) ~= "table" then
		return SaveSchema.default().treasures
	end
	return knownIds(v)
end

-- Splits saved treasure ids into the ones that get a slot (the first `capacity` ones)
-- and the overflow that does not fit right now. Overflow must be kept in the save, never dropped.
-- Unknown ids are skipped; the input list is not changed.
function SaveSchema.splitByCapacity(ids: { string }, capacity: number): ({ string }, { string })
	local placed, overflow = {}, {}
	local limit = if type(capacity) == "number" and capacity == capacity then math.max(0, math.floor(capacity)) else 0
	for _, id in knownIds(ids) do
		if #placed < limit then
			table.insert(placed, id)
		else
			table.insert(overflow, id)
		end
	end
	return placed, overflow
end

-- Builds clean save data from the live game values (used every time the save is updated).
function SaveSchema.fromRuntime(caps: number, ids: { string }, baseLevel: number): SaveData
	return {
		version = SaveSchema.CURRENT_VERSION,
		caps = cleanCaps(caps),
		treasures = knownIds(ids),
		baseLevel = cleanLevel(baseLevel),
	}
end

-- true, wenn der Spielstand von einer neueren Spielversion stammt. Dann darf ein
-- älterer Server ihn nicht überschreiben (DataService muss Speichern verweigern).
function SaveSchema.isFromFuture(raw: any): boolean
	return type(raw) == "table" and type(raw.version) == "number" and raw.version > SaveSchema.CURRENT_VERSION
end

-- Nimmt beliebige (auch kaputte oder alte) Daten und liefert immer gültige Daten.
function SaveSchema.migrate(raw: any): SaveData
	if type(raw) ~= "table" then
		return SaveSchema.default()
	end
	return {
		version = SaveSchema.CURRENT_VERSION,
		caps = cleanCaps(raw.caps),
		treasures = cleanTreasures(raw.treasures),
		baseLevel = cleanLevel(raw.baseLevel),
	}
end

return SaveSchema
