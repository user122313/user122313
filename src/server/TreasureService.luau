-- Garbage truck, pickup, placing and income.
-- The server owns everything: treasure state lives in attributes on the treasure Model:
--   TreasureId (GUID), DefId (Catalog id), OwnerUserId (0 = nobody), CarriedBy (0 = nobody),
--   SlotName ("Slot3" while placed in a base).
-- Players grab/place with ProximityPrompts (works on PC and phone); the server re-checks everything.
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local Catalog = require(Shared.Catalog)
local Config = require(Shared.Config)
local Economy = require(Shared.Economy)
local Remotes = require(Shared.Remotes)
local Theme = require(Shared.Theme)
local BaseService = require(script.Parent.BaseService)

local TreasureService = {}

type State = { caps: number, carrying: Model? }

local states: { [Player]: State } = {}
local treasures: { [string]: Model } = {}
local treasureFolder: Folder? = nil

-- Extra studs on top of STEAL_REACH so a laggy but honest player is not rejected.
local REACH_TOLERANCE = 2

local function rgb(c: { number }): Color3
	return Color3.fromRGB(c[1], c[2], c[3])
end

local function rarityColor(rarity: string): Color3
	if rarity == "rare" then
		return rgb(Theme.colors.rare)
	elseif rarity == "legendary" then
		return rgb(Theme.colors.legendary)
	end
	return Color3.fromRGB(190, 190, 190)
end

local function hint(player: Player, text: string)
	Remotes.get("Announce"):FireClient(player, text, "common")
end

local function humanoidOf(player: Player): Humanoid?
	local character = player.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function rootOf(player: Player): BasePart?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function setSpeed(player: Player, speed: number)
	local humanoid = humanoidOf(player)
	if humanoid then
		humanoid.WalkSpeed = speed
	end
end

local function setPromptEnabled(treasure: Model, enabled: boolean)
	local body = treasure.PrimaryPart
	local prompt = body and body:FindFirstChild("GrabPrompt")
	if prompt and prompt:IsA("ProximityPrompt") then
		prompt.Enabled = enabled
	end
end

local function detach(treasure: Model)
	local body = treasure.PrimaryPart
	if not body then
		return
	end
	local weld = body:FindFirstChild("CarryWeld")
	if weld then
		weld:Destroy()
	end
	for _, d in treasure:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
			d.Massless = false
		end
	end
end

local function attachToCharacter(treasure: Model, player: Player): boolean
	local root = rootOf(player)
	local body = treasure.PrimaryPart
	if not root or not body then
		return false
	end
	treasure:PivotTo(root.CFrame * CFrame.new(0, 4.5, 0))
	for _, d in treasure:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = false
			d.CanCollide = false
			d.Massless = true
		end
	end
	local weld = Instance.new("WeldConstraint")
	weld.Name = "CarryWeld"
	weld.Part0 = root
	weld.Part1 = body
	weld.Parent = body
	return true
end

local function placeAtDump(treasure: Model)
	local dump = Workspace:FindFirstChild("DumpSite")
	local drop = dump and dump:FindFirstChild("DropPoint")
	if not drop or not drop:IsA("BasePart") then
		warn("[TreasureService] Workspace.DumpSite.DropPoint is missing")
		return
	end
	local angle = math.random() * math.pi * 2
	local radius = math.random() * 10
	local body = treasure.PrimaryPart :: BasePart
	-- Dump floor top is at y = 1
	local y = 1 + body.Size.Y / 2
	treasure:PivotTo(CFrame.new(drop.Position.X + math.cos(angle) * radius, y, drop.Position.Z + math.sin(angle) * radius))
end

local function placeInSlot(treasure: Model, owner: Player, slot: BasePart)
	detach(treasure)
	local body = treasure.PrimaryPart :: BasePart
	treasure:PivotTo(slot.CFrame * CFrame.new(0, slot.Size.Y / 2 + body.Size.Y / 2, 0))
	slot:SetAttribute("TreasureId", treasure:GetAttribute("TreasureId"))
	treasure:SetAttribute("SlotName", slot.Name)
	treasure:SetAttribute("OwnerUserId", owner.UserId)
	treasure:SetAttribute("CarriedBy", 0)
	setPromptEnabled(treasure, false)
end

local function clearCarrier(treasure: Model)
	local carrierId = treasure:GetAttribute("CarriedBy")
	if typeof(carrierId) ~= "number" or carrierId == 0 then
		return
	end
	local carrier = Players:GetPlayerByUserId(carrierId)
	local state = carrier and states[carrier]
	if carrier and state and state.carrying == treasure then
		state.carrying = nil
		setSpeed(carrier, Config.WALK_SPEED)
	end
	treasure:SetAttribute("CarriedBy", 0)
end

local function destroyTreasure(treasure: Model)
	clearCarrier(treasure)
	local id = treasure:GetAttribute("TreasureId")
	if typeof(id) == "string" then
		treasures[id] = nil
	end
	treasure:Destroy()
end

local function createTreasure(defId: string): Model?
	local def = Catalog.get(defId)
	if not def then
		return nil
	end
	local color = rarityColor(def.rarity)

	local model = Instance.new("Model")
	model.Name = def.id
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(3, 3, 3)
	body.Color = color
	body.Material = if def.rarity == "common" then Enum.Material.SmoothPlastic else Enum.Material.Neon
	body.TopSurface = Enum.SurfaceType.Smooth
	body.BottomSurface = Enum.SurfaceType.Smooth
	body.Anchored = true
	body.CanCollide = false
	body.Parent = model
	model.PrimaryPart = body

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(220, 44)
	billboard.StudsOffset = Vector3.new(0, 3.2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = body
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = def.name
	label.TextScaled = true
	label.TextColor3 = color
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.FredokaOne
	label.Parent = billboard

	local id = HttpService:GenerateGUID(false)
	model:SetAttribute("TreasureId", id)
	model:SetAttribute("DefId", def.id)
	model:SetAttribute("OwnerUserId", 0)
	model:SetAttribute("CarriedBy", 0)
	treasures[id] = model

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "GrabPrompt"
	prompt.ActionText = "Grab"
	prompt.ObjectText = def.name
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = Config.STEAL_REACH
	prompt.RequiresLineOfSight = false
	prompt.Enabled = false
	prompt.Parent = body
	prompt.Triggered:Connect(function(player)
		TreasureService.tryPickup(player, model)
	end)

	model.Parent = treasureFolder
	return model
end

-- The player now carries the treasure (slower, treasure floats above the head).
function TreasureService.giveTo(player: Player, treasure: Instance): boolean
	local state = states[player]
	if not state or state.carrying or not treasure:IsA("Model") then
		return false
	end
	if not attachToCharacter(treasure, player) then
		return false
	end
	state.carrying = treasure
	treasure:SetAttribute("CarriedBy", player.UserId)
	setPromptEnabled(treasure, false)
	setSpeed(player, Config.CARRY_SPEED)
	return true
end

-- Server-side pickup check. Called by the ProximityPrompt and re-validated here.
function TreasureService.tryPickup(player: Player, treasure: Instance): (boolean, string?)
	local state = states[player]
	if not state then
		return false, "no_state"
	end
	if typeof(treasure) ~= "Instance" or not treasure:IsA("Model") then
		return false, "invalid"
	end
	local id = treasure:GetAttribute("TreasureId")
	if typeof(id) ~= "string" or treasures[id] ~= treasure then
		return false, "invalid"
	end
	if state.carrying then
		hint(player, "Your hands are full!")
		return false, "carrying"
	end
	if treasure:GetAttribute("OwnerUserId") ~= 0 or treasure:GetAttribute("CarriedBy") ~= 0 then
		return false, "taken"
	end
	local humanoid, root, body = humanoidOf(player), rootOf(player), treasure.PrimaryPart
	if not humanoid or humanoid.Health <= 0 or not root or not body then
		return false, "no_character"
	end
	if (root.Position - body.Position).Magnitude > Config.STEAL_REACH + REACH_TOLERANCE then
		return false, "too_far"
	end
	if not BaseService.freeSlot(player) then
		hint(player, "Your base is full!")
		return false, "base_full"
	end
	if not TreasureService.giveTo(player, treasure) then
		return false, "failed"
	end
	return true, nil
end

-- Puts the carried treasure into a free slot of the player's own base.
function TreasureService.tryPlace(player: Player): (boolean, string?)
	local state = states[player]
	local treasure = state and state.carrying
	if not state or not treasure then
		return false, "not_carrying"
	end
	local base, root = BaseService.baseOf(player), rootOf(player)
	local floor = base and base:FindFirstChild("Floor")
	if not base or not root or not floor or not floor:IsA("BasePart") then
		return false, "no_base"
	end
	local rel = floor.CFrame:PointToObjectSpace(root.Position)
	if math.abs(rel.X) > floor.Size.X / 2 or math.abs(rel.Z) > floor.Size.Z / 2 or rel.Y > 15 then
		hint(player, "Bring it to YOUR base!")
		return false, "not_in_base"
	end
	local slot = BaseService.freeSlot(player)
	if not slot then
		hint(player, "Your base is full!")
		return false, "base_full"
	end
	state.carrying = nil
	setSpeed(player, Config.WALK_SPEED)
	placeInSlot(treasure, player, slot)
	return true, nil
end

function TreasureService.ownedBy(player: Player): { Instance }
	local result = {}
	for _, treasure in treasures do
		if treasure:GetAttribute("OwnerUserId") == player.UserId then
			table.insert(result, treasure)
		end
	end
	return result
end

-- Treasure goes back to where it belongs: the owner's slot, or the dump if it has no owner.
function TreasureService.returnToOwner(treasure: Instance)
	if not treasure:IsA("Model") or not treasure.PrimaryPart then
		return
	end
	clearCarrier(treasure)
	detach(treasure)

	local ownerId = treasure:GetAttribute("OwnerUserId")
	if typeof(ownerId) == "number" and ownerId ~= 0 then
		local owner = Players:GetPlayerByUserId(ownerId)
		local base = owner and BaseService.baseOf(owner)
		local slotName = treasure:GetAttribute("SlotName")
		local slot = base and typeof(slotName) == "string" and base:FindFirstChild(slotName)
		if owner and slot and slot:IsA("BasePart") then
			placeInSlot(treasure, owner, slot)
			return
		end
		destroyTreasure(treasure)
		return
	end
	placeAtDump(treasure)
	setPromptEnabled(treasure, true)
end

-- One new treasure on the dump site (rarity by weight). Removed again if nobody takes it.
function TreasureService.spawnAtDump(): Instance?
	local rarity = Economy.rollRarity(math.random())
	local candidates = {}
	for _, def in Catalog.all do
		if def.rarity == rarity then
			table.insert(candidates, def)
		end
	end
	local def = candidates[math.random(1, #candidates)]
	local treasure = createTreasure(def.id)
	if not treasure then
		return nil
	end
	placeAtDump(treasure)
	setPromptEnabled(treasure, true)
	task.delay(Config.DUMP_DESPAWN, function()
		if
			treasure.Parent
			and treasure:GetAttribute("OwnerUserId") == 0
			and treasure:GetAttribute("CarriedBy") == 0
		then
			destroyTreasure(treasure)
		end
	end)
	return treasure
end

function TreasureService.getCaps(player: Player): number
	local state = states[player]
	return if state then state.caps else 0
end

local function incomeOf(player: Player): number
	local ids = {}
	for _, treasure in TreasureService.ownedBy(player) do
		if treasure:GetAttribute("CarriedBy") == 0 then
			table.insert(ids, treasure:GetAttribute("DefId"))
		end
	end
	return Economy.incomePerSecond(ids)
end

local function sendHud(player: Player)
	local state = states[player]
	if state then
		Remotes.get("HudUpdate"):FireClient(player, state.caps, incomeOf(player))
	end
end

local function onPlayerAdded(player: Player)
	states[player] = { caps = 0, carrying = nil }
	local base = BaseService.assign(player)
	if base then
		local slot = BaseService.freeSlot(player)
		local start = createTreasure(Catalog.startTreasureId)
		if start and slot then
			placeInSlot(start, player, slot)
		end
	end
	player.CharacterRemoving:Connect(function()
		local state = states[player]
		if state and state.carrying then
			TreasureService.returnToOwner(state.carrying)
		end
	end)
	sendHud(player)
end

local function onPlayerRemoving(player: Player)
	local state = states[player]
	if state and state.carrying then
		TreasureService.returnToOwner(state.carrying)
	end
	-- The base disappears with its contents; saving comes with DataService (Task 10).
	for _, treasure in TreasureService.ownedBy(player) do
		destroyTreasure(treasure :: Model)
	end
	states[player] = nil
end

local function attachPlacePrompts()
	local bases = Workspace:FindFirstChild("Bases")
	if not bases then
		warn("[TreasureService] Workspace.Bases is missing")
		return
	end
	for _, base in bases:GetChildren() do
		local floor = base:FindFirstChild("Floor")
		if floor and floor:IsA("BasePart") then
			local prompt = Instance.new("ProximityPrompt")
			prompt.Name = "PlacePrompt"
			prompt.ActionText = "Drop here"
			prompt.ObjectText = "Your base"
			prompt.HoldDuration = 0.2
			prompt.MaxActivationDistance = 22
			prompt.RequiresLineOfSight = false
			prompt.Parent = floor
			prompt.Triggered:Connect(function(player)
				TreasureService.tryPlace(player)
			end)
		end
	end
end

function TreasureService.start()
	local folder = Instance.new("Folder")
	folder.Name = "Treasures"
	folder.Parent = Workspace
	treasureFolder = folder

	attachPlacePrompts()

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end

	-- Garbage truck
	task.spawn(function()
		while true do
			task.wait(Config.DUMP_INTERVAL)
			TreasureService.spawnAtDump()
		end
	end)

	-- Income, once per second
	task.spawn(function()
		while true do
			task.wait(1)
			for player, state in states do
				state.caps += incomeOf(player)
				sendHud(player)
			end
		end
	end)
end

return TreasureService
