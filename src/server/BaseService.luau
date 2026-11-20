-- Assigns one of the six bases (Workspace.Bases.Base1..Base6) to each player.
-- The base owner is stored as attribute OwnerUserId on the Base model.
-- Slots (Slot1..Slot8) hold treasures; a taken slot carries attribute TreasureId.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Economy = require(ReplicatedStorage.Shared.Economy)

local BaseService = {}

local baseOfPlayer: { [Player]: Model } = {}
local characterConnections: { [Player]: RBXScriptConnection } = {}

local function basesFolder(): Instance?
	return Workspace:FindFirstChild("Bases")
end

local function spawnOf(base: Model): BasePart?
	local spawn = base:FindFirstChild("Spawn")
	if spawn and spawn:IsA("BasePart") then
		return spawn
	end
	return nil
end

local function moveToSpawn(character: Model, spawn: BasePart)
	character:PivotTo(spawn.CFrame + Vector3.new(0, 4, 0))
end

-- Returns the player's base, or nil if the server has no free base.
-- No yield between "find free base" and "set owner", so two players
-- joining at the same moment can never get the same base.
function BaseService.assign(player: Player): Model?
	local existing = baseOfPlayer[player]
	if existing then
		return existing
	end

	local folder = basesFolder()
	if not folder then
		warn("[BaseService] Workspace.Bases is missing")
		return nil
	end

	local chosen: Model? = nil
	for i = 1, Config.MAX_PLAYERS do
		local base = folder:FindFirstChild(`Base{i}`)
		if base and base:IsA("Model") then
			local owner = base:GetAttribute("OwnerUserId")
			if owner == nil or owner == 0 then
				chosen = base
				break
			end
		end
	end
	if not chosen then
		warn(`[BaseService] no free base for {player.Name}`)
		return nil
	end

	chosen:SetAttribute("OwnerUserId", player.UserId)
	chosen:SetAttribute("BaseLevel", 1)
	baseOfPlayer[player] = chosen

	local spawn = spawnOf(chosen)
	if spawn then
		player.RespawnLocation = spawn :: SpawnLocation
		characterConnections[player] = player.CharacterAdded:Connect(function(character)
			moveToSpawn(character, spawn)
		end)
		if player.Character then
			moveToSpawn(player.Character, spawn)
		end
	else
		warn(`[BaseService] {chosen.Name} has no Spawn part`)
	end

	print(`[BaseService] {chosen.Name} -> {player.Name}`)
	return chosen
end

-- Frees the base. Treasures inside are handled by TreasureService (Task 4+)
-- before this is called.
function BaseService.release(player: Player)
	local base = baseOfPlayer[player]
	baseOfPlayer[player] = nil

	local connection = characterConnections[player]
	if connection then
		connection:Disconnect()
		characterConnections[player] = nil
	end

	if base then
		base:SetAttribute("OwnerUserId", nil)
		base:SetAttribute("BaseLevel", 1)
		for _, child in base:GetChildren() do
			if string.match(child.Name, "^Slot%d+$") then
				child:SetAttribute("TreasureId", nil)
			end
		end
		print(`[BaseService] {base.Name} is free again ({player.Name} left)`)
	end
end

function BaseService.ownerOf(base: Model): Player?
	local userId = base:GetAttribute("OwnerUserId")
	if typeof(userId) ~= "number" or userId == 0 then
		return nil
	end
	return Players:GetPlayerByUserId(userId)
end

function BaseService.baseOf(player: Player): Model?
	return baseOfPlayer[player]
end

-- First empty slot within the capacity of the base level, or nil if the base is full.
function BaseService.freeSlot(player: Player): BasePart?
	local base = baseOfPlayer[player]
	if not base then
		return nil
	end
	local level = base:GetAttribute("BaseLevel")
	local capacity = Economy.capacity(if typeof(level) == "number" then level else 1)
	for i = 1, capacity do
		local slot = base:FindFirstChild(`Slot{i}`)
		if slot and slot:IsA("BasePart") then
			local id = slot:GetAttribute("TreasureId")
			if id == nil or id == "" then
				return slot
			end
		end
	end
	return nil
end

-- True if the player stands on the floor of his own base (not above it, not outside).
function BaseService.isInsideOwnBase(player: Player): boolean
	local base = baseOfPlayer[player]
	local floor = base and base:FindFirstChild("Floor")
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not floor or not floor:IsA("BasePart") or not root or not root:IsA("BasePart") then
		return false
	end
	local rel = floor.CFrame:PointToObjectSpace(root.Position)
	return math.abs(rel.X) <= floor.Size.X / 2 and math.abs(rel.Z) <= floor.Size.Z / 2 and rel.Y <= 15
end

function BaseService.start()
	Players.PlayerAdded:Connect(BaseService.assign)
	Players.PlayerRemoving:Connect(BaseService.release)
	-- Players that joined before this script ran
	for _, player in Players:GetPlayers() do
		BaseService.assign(player)
	end
end

return BaseService
