-- Garbage truck, pickup, placing and income.
-- The server owns everything: treasure state lives in attributes on the treasure Model:
--   TreasureId (GUID), DefId (Catalog id), OwnerUserId (0 = nobody), CarriedBy (0 = nobody),
--   SlotName (slot of the owner's base; stays set while the treasure is stolen, so the slot stays reserved),
--   InSlot (true only while it really sits in that slot), LockedBy (0 = nobody, else a thief mid-steal).
-- Players grab/place with ProximityPrompts (works on PC and phone); the server re-checks everything.
-- A stolen treasure keeps the victim's OwnerUserId until the thief places it in his own base.
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local Catalog = require(Shared.Catalog)
local Config = require(Shared.Config)
local Economy = require(Shared.Economy)
local Remotes = require(Shared.Remotes)
local StealRules = require(Shared.StealRules)
local Theme = require(Shared.Theme)
local BaseService = require(script.Parent.BaseService)

local TreasureService = {}

type State = { caps: number, carrying: Model? }

local states: { [Player]: State } = {}
local treasures: { [string]: Model } = {}
local treasureFolder: Folder? = nil

-- Extra studs on top of STEAL_REACH so a laggy but honest player is not rejected.
local REACH_TOLERANCE = 2
-- Glow on a thief who carries someone else's treasure (visible to everyone).
local MARKER_NAME = "ThiefMarker"

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

local function setMarker(player: Player, on: boolean)
	local character = player.Character
	if not character then
		return
	end
	local existing = character:FindFirstChild(MARKER_NAME)
	if on and not existing then
		local highlight = Instance.new("Highlight")
		highlight.Name = MARKER_NAME
		highlight.FillColor = rgb(Theme.colors.danger)
		highlight.FillTransparency = 0.5
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.Parent = character
	elseif not on and existing then
		existing:Destroy()
	end
end

-- Stolen = owned by somebody other than the given player.
local function isStolenBy(treasure: Model, player: Player): boolean
	local ownerId = treasure:GetAttribute("OwnerUserId")
	return typeof(ownerId) == "number" and ownerId ~= 0 and ownerId ~= player.UserId
end

-- The owner's slot this treasure belongs to (nil if owner or base is gone).
local function homeSlotOf(treasure: Model): BasePart?
	local ownerId = treasure:GetAttribute("OwnerUserId")
	if typeof(ownerId) ~= "number" or ownerId == 0 then
		return nil
	end
	local owner = Players:GetPlayerByUserId(ownerId)
	local base = owner and BaseService.baseOf(owner)
	local slotName = treasure:GetAttribute("SlotName")
	if not base or typeof(slotName) ~= "string" then
		return nil
	end
	local slot = base:FindFirstChild(slotName)
	if slot and slot:IsA("BasePart") and slot:GetAttribute("TreasureId") == treasure:GetAttribute("TreasureId") then
		return slot
	end
	return nil
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
	treasure:SetAttribute("LockedBy", 0)
	treasure:SetAttribute("InSlot", true)
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
		setMarker(carrier, false)
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
	model:SetAttribute("LockedBy", 0)
	model:SetAttribute("InSlot", false)
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
	treasure:SetAttribute("LockedBy", 0)
	-- SlotName stays: a stolen treasure keeps its slot in the victim's base reserved.
	treasure:SetAttribute("InSlot", false)
	setPromptEnabled(treasure, false)
	setSpeed(player, Config.CARRY_SPEED)
	if isStolenBy(treasure, player) then
		setMarker(player, true)
	end
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
	if
		treasure:GetAttribute("OwnerUserId") ~= 0
		or treasure:GetAttribute("CarriedBy") ~= 0
		or treasure:GetAttribute("LockedBy") ~= 0
	then
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
	-- Ownership changes here, in one step without yielding: the victim's reserved slot
	-- is freed and the thief's slot is filled, so nothing can be duplicated or lost.
	if isStolenBy(treasure, player) then
		local oldSlot = homeSlotOf(treasure)
		if oldSlot then
			oldSlot:SetAttribute("TreasureId", nil)
		end
	end
	state.carrying = nil
	setSpeed(player, Config.WALK_SPEED)
	setMarker(player, false)
	placeInSlot(treasure, player, slot)
	return true, nil
end

-- The treasure with this TreasureId, or nil.
function TreasureService.find(treasureId: string): Model?
	return treasures[treasureId]
end

-- What the player carries right now, or nil.
function TreasureService.carriedBy(player: Player): Model?
	local state = states[player]
	if state then
		return state.carrying
	end
	return nil
end

-- True only if the treasure really sits in its owner's slot (not carried, not dropped, owner present).
function TreasureService.isHome(treasure: Model): boolean
	return treasure:GetAttribute("InSlot") == true
		and treasure:GetAttribute("CarriedBy") == 0
		and homeSlotOf(treasure) ~= nil
end

-- The carried treasure falls on the ground behind the player. Nobody can pick it up there;
-- the caller decides when it returns (TreasureService.returnToOwner). Returns the treasure.
function TreasureService.dropAtFeet(player: Player): Model?
	local state = states[player]
	local treasure = state and state.carrying
	if not state or not treasure then
		return nil
	end
	state.carrying = nil
	setSpeed(player, Config.WALK_SPEED)
	setMarker(player, false)
	treasure:SetAttribute("CarriedBy", 0)
	treasure:SetAttribute("LockedBy", 0)
	treasure:SetAttribute("InSlot", false)
	detach(treasure)
	setPromptEnabled(treasure, false)

	local root, body = rootOf(player), treasure.PrimaryPart
	if root and body then
		local ignore: { Instance } = {}
		if treasureFolder then
			table.insert(ignore, treasureFolder)
		end
		for _, other in Players:GetPlayers() do
			if other.Character then
				table.insert(ignore, other.Character)
			end
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignore
		local origin = (root.CFrame * CFrame.new(0, 0, 3)).Position
		local hit = Workspace:Raycast(origin, Vector3.new(0, -50, 0), params)
		local groundY = if hit then hit.Position.Y else root.Position.Y - 3
		treasure:PivotTo(CFrame.new(origin.X, groundY + body.Size.Y / 2, origin.Z))
	end
	return treasure
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
	-- Only treasures really sitting in their owner's slot pay (not carried, stolen or dropped).
	for _, treasure in TreasureService.ownedBy(player) do
		if TreasureService.isHome(treasure :: Model) then
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
	-- Death or respawn while carrying: the treasure goes back (stolen -> victim's slot, dump -> dump).
	local function returnCarried()
		local state = states[player]
		if state and state.carrying then
			TreasureService.returnToOwner(state.carrying)
		end
	end
	local function hookCharacter(character: Model)
		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
		if humanoid and humanoid:IsA("Humanoid") then
			humanoid.Died:Connect(function()
				if player.Character == character then
					returnCarried()
				end
			end)
		end
	end
	player.CharacterAdded:Connect(hookCharacter)
	if player.Character then
		task.spawn(hookCharacter, player.Character)
	end
	player.CharacterRemoving:Connect(returnCarried)
	sendHud(player)
end

local function onPlayerRemoving(player: Player)
	local state = states[player]
	-- Leaving thief: StealRules decides (carrying -> back to the owner's slot).
	if state and state.carrying then
		if StealRules.resolveLeave("thief", true) == "return_to_owner" then
			TreasureService.returnToOwner(state.carrying)
		end
	end
	-- Leaving owner: his base disappears with its contents. For a treasure a thief is carrying,
	-- StealRules says "return_to_owner" = back into the owner's save data (Task 10), so it leaves
	-- with the base too; the same goes for one lying dropped on the ground.
	-- destroyTreasure also clears the thief's carry state, speed and glow.
	-- ownedBy returns a new list, so destroying while looping is safe.
	for _, treasure in TreasureService.ownedBy(player) do
		local carried = treasure:GetAttribute("CarriedBy") ~= 0
		if carried and StealRules.resolveLeave("owner", carried) ~= "return_to_owner" then
			warn(`[TreasureService] unexpected leave rule for {treasure.Name}`)
		end
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
