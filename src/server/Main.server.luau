local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DataService = require(script.Parent.DataService)
local BaseService = require(script.Parent.BaseService)
local TreasureService = require(script.Parent.TreasureService)
local StealService = require(script.Parent.StealService)
local TrapService = require(script.Parent.TrapService)
local ShieldService = require(script.Parent.ShieldService)

Remotes.create()
DataService.start()
-- Right before every save (autosave, leave, shutdown) the live game state is copied into the save.
DataService.setBeforeSave(TreasureService.syncSave)
TreasureService.start()
StealService.start()
TrapService.start()
ShieldService.start()

local MSG_NO_BASE = "This server is full. Please try another server."

-- Players whose leave was already handled (weak keys: no memory kept after they are gone).
local hasLeft: { [Player]: boolean } = setmetatable({}, { __mode = "k" }) :: any

-- Join: load the save FIRST (yields), only then hand out a base and build its content.
-- If loading fails DataService has kicked the player: he gets no base and no treasures.
local function onJoin(player: Player)
	local data = DataService.load(player)
	if not data then
		BaseService.release(player)
		return
	end
	if hasLeft[player] or player.Parent ~= Players then
		-- Left while loading: nothing was built, just give the save back unchanged.
		DataService.release(player)
		return
	end
	if not BaseService.assign(player) then
		-- No free base (e.g. a 7th player): never let him play without one. Give the save back
		-- unchanged, then kick him with a clear message. Nothing was built for him.
		warn(`[Main] no free base for {player.Name}, kicking`)
		DataService.release(player)
		player:Kick(MSG_NO_BASE)
		return
	end
	TreasureService.addPlayer(player, data)
end

-- Leave, in this order: final save update while everything is still in place, then tear down,
-- then free the base, then the final save + unlock. Nothing here yields.
local function onLeave(player: Player)
	hasLeft[player] = true
	TrapService.refundStock(player) -- unplaced banana peels come back as bottle caps
	TreasureService.syncSave(player)
	TreasureService.removePlayer(player)
	BaseService.release(player)
	DataService.release(player)
end

Players.PlayerAdded:Connect(onJoin)
Players.PlayerRemoving:Connect(onLeave)
-- Players that joined before this script ran
for _, player in Players:GetPlayers() do
	task.spawn(onJoin, player)
end

print("Muellbanditen server running")
