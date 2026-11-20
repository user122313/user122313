-- Loading and saving player data with ProfileStore (session lock, autosave, save on leave and shutdown).
-- One profile per player, key "Player_<UserId>" in the DataStore STORE_NAME.
-- DataService.get(player) returns the live SaveData table; game code updates it (TreasureService.syncSave)
-- and ProfileStore writes it to the DataStore: autosave every Config.AUTOSAVE_SECONDS, on
-- DataService.release, and on server shutdown (ProfileStore binds game:BindToClose itself).
-- Before every save the "beforeSave" callback (set by Main) copies the live game state into the data.
-- Safety rules:
--   * A failed load returns nil and kicks the player. He never plays with an empty profile.
--   * Data from a newer game version (SaveSchema.isFromFuture) is never changed: the session is ended
--     with Profile.Data untouched (it writes back exactly what was loaded) and the player is kicked.
--   * In Studio without API access ProfileStore uses its own in-memory mock store automatically
--     (nothing survives the end of the play session). The log says which store is used.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local SaveSchema = require(ReplicatedStorage.Shared.SaveSchema)
local ProfileStore = require(script.Parent.Packages.ProfileStore)

type SaveData = SaveSchema.SaveData

local DataService = {}

-- NEVER rename this once the game is public: a new name means an empty DataStore for everyone.
local STORE_NAME = "PlayerData"
-- true: Studio always uses the mock store (never touches real saves, but nothing survives a restart).
-- false: Studio uses the real DataStore when API access is on, otherwise the automatic mock.
local USE_MOCK_IN_STUDIO = false
-- Give up loading after this many seconds (ProfileStore may wait ~40 s for another server's lock).
local LOAD_TIMEOUT = 90

local MSG_LOAD_FAILED = "We couldn't load your data. Please rejoin."
local MSG_FUTURE = "This server runs an older version of the game. Please rejoin to get a newer server."
local MSG_SESSION_ENDED = "Your data was opened on another server. Please rejoin."

type Record = { profile: any, data: SaveData }

local records: { [Player]: Record } = {}
local beforeSave: ((Player) -> ())? = nil
local store: any = nil

local function keyOf(player: Player): string
	return `Player_{player.UserId}`
end

local function isInGame(player: Player): boolean
	return player.Parent == Players
end

-- Called right before ProfileStore saves (autosave, final save, shutdown). Must not yield.
function DataService.setBeforeSave(callback: (Player) -> ())
	beforeSave = callback
end

-- Loads (yields!). Returns the player's SaveData, or nil if loading failed (player is kicked then).
-- A brand-new player gets SaveSchema.default() (ProfileStore copies the template).
function DataService.load(player: Player): SaveData?
	if records[player] then
		return records[player].data
	end
	if not store then
		warn("[DataService] load() called before start()")
		return nil
	end

	local started = os.clock()
	-- pcall: StartSessionAsync can also throw (e.g. the same key is still open on this server).
	local ok, result = pcall(function()
		return store:StartSessionAsync(keyOf(player), {
			Cancel = function()
				return not isInGame(player) or os.clock() - started > LOAD_TIMEOUT
			end,
		})
	end)
	local profile = if ok then result else nil

	if profile == nil then
		warn(`[DataService] could not load data for {player.Name} ({player.UserId}): {if ok then "no profile" else tostring(result)}`)
		if isInGame(player) then
			player:Kick(MSG_LOAD_FAILED)
		end
		return nil
	end

	-- Left while loading: give the profile back without touching it.
	if not isInGame(player) then
		profile:EndSession()
		return nil
	end

	local raw = profile.Data
	if SaveSchema.isFromFuture(raw) then
		-- Do NOT touch profile.Data: EndSession then writes back exactly what was loaded
		-- and frees the session lock, so a newer server can load it later.
		warn(`[DataService] {player.Name} has data version {raw.version}, this server knows {SaveSchema.CURRENT_VERSION}; saving disabled, kicking`)
		profile:EndSession()
		player:Kick(MSG_FUTURE)
		return nil
	end

	profile:AddUserId(player.UserId) -- GDPR: links the key to the user
	local data = SaveSchema.migrate(raw)
	profile.Data = data -- allowed by ProfileStore docs ("you may set Profile.Data to a new table reference")

	local record: Record = { profile = profile, data = data }
	records[player] = record

	profile.OnSave:Connect(function()
		if records[player] == record and beforeSave then
			beforeSave(player)
		end
	end)
	-- Session taken over by another server (or ended by us): stop using it, kick if still here.
	profile.OnSessionEnd:Connect(function()
		if records[player] == record then
			records[player] = nil
			if isInGame(player) then
				warn(`[DataService] session for {player.Name} ended elsewhere, kicking`)
				player:Kick(MSG_SESSION_ENDED)
			end
		end
	end)

	print(`[DataService] loaded {player.Name}: caps={data.caps}, treasures={#data.treasures}, level={data.baseLevel}`)
	return data
end

-- The live SaveData of a loaded player, or nil (not loaded, failed, or already released).
function DataService.get(player: Player): SaveData?
	local record = records[player]
	if record and record.profile:IsActive() then
		return record.data
	end
	return nil
end

-- Final save and session unlock. Call AFTER the last update of DataService.get(player).
function DataService.release(player: Player)
	local record = records[player]
	records[player] = nil
	if record and record.profile:IsActive() then
		record.profile:EndSession()
		print(`[DataService] released {player.Name}`)
	end
end

-- "NotReady", "NoInternet", "NoAccess" or "Access" (ProfileStore's view of the DataStore).
function DataService.storeState(): string
	return ProfileStore.DataStoreState
end

function DataService.start()
	-- Autosave interval from Config (ProfileStore default would be 300 s).
	ProfileStore.SetConstant("AUTO_SAVE_PERIOD", Config.AUTOSAVE_SECONDS)

	local liveStore = ProfileStore.New(STORE_NAME, SaveSchema.default())
	local useMock = USE_MOCK_IN_STUDIO and RunService:IsStudio()
	store = if useMock then liveStore.Mock else liveStore

	ProfileStore.OnError:Connect(function(message, storeName, key)
		warn(`[DataService] DataStore error ({storeName}/{key}): {message}`)
	end)
	ProfileStore.OnCriticalToggle:Connect(function(isCritical)
		warn(`[DataService] DataStore critical state: {isCritical}`)
	end)

	-- Say clearly in the log which store is used.
	task.spawn(function()
		while ProfileStore.DataStoreState == "NotReady" do
			task.wait()
		end
		if useMock then
			warn("[DataService] Using the MOCK store (USE_MOCK_IN_STUDIO): data is NOT saved after this session")
		elseif ProfileStore.DataStoreState == "Access" then
			print(`[DataService] Using the REAL DataStore "{STORE_NAME}": data is saved`)
		else
			warn(`[DataService] No DataStore access ({ProfileStore.DataStoreState}): using ProfileStore's in-memory mock, data is NOT saved after this session`)
		end
	end)
end

return DataService
