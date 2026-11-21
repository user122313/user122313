-- Garbage truck, pickup, placing and income.
-- The server owns everything: treasure state lives in attributes on the treasure Model:
--   TreasureId (GUID), DefId (Catalog id), OwnerUserId (0 = nobody), CarriedBy (0 = nobody),
--   SlotName (slot of the owner's base; stays set while the treasure is stolen, so the slot stays reserved),
--   InSlot (true only while it really sits in that slot), LockedBy (0 = nobody, else a thief mid-steal).
-- Players grab/place with ProximityPrompts (works on PC and phone); the server re-checks everything.
-- A stolen treasure keeps the victim's OwnerUserId until the thief places it in his own base.
-- Saving: the runtime state here is the truth. TreasureService.syncSave(player) copies it into
-- DataService.get(player): caps, the DefIds of ALL treasures with OwnerUserId == player (also while a
-- thief carries one or it lies dropped), plus "overflow" ids that did not fit into the base on join,
-- and the base level. It is called after every change that matters and right before every save.
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local Catalog = require(Shared.Catalog)
local Config = require(Shared.Config)
local Economy = require(Shared.Economy)
local Remotes = require(Shared.Remotes)
local SaveSchema = require(Shared.SaveSchema)
local StealRules = require(Shared.StealRules)
local Theme = require(Shared.Theme)
local BaseService = require(script.Parent.BaseService)
local DataService = require(script.Parent.DataService)

local TreasureService = {}

-- overflow: saved treasure ids that had no free slot on join; they stay in the save, never dropped.
-- loadedLevel: base level from the save (used if the player has no base model).
-- live: true between addPlayer and removePlayer; only then syncSave writes into the save.
type State = { caps: number, carrying: Model?, overflow: { string }, loadedLevel: number, live: boolean }

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
	-- Key F: key E belongs to stealing (client StealController); Roblox prompts always win a shared key.
	prompt.KeyboardKeyCode = Enum.KeyCode.F
	prompt.Enabled = false
	prompt.Parent = body
	prompt.Triggered:Connect(function(player)
		TreasureService.tryPickup(player, model)
	end)

	model.Parent = treasureFolder
	return model
end

-- Last known position of a player who carries a STOLEN treasure (to catch teleports, see carrierJumped).
local carryTrack: { [Player]: { pos: Vector3, at: number } } = {}

-- Set by StealService: what happens to a thief who jumped (the loot falls and goes back to its owner).
TreasureService.onCarrierJumped = nil :: ((Player) -> ())?

-- True if a player who carries a stolen treasure moved further since the last sample than a walking
-- player can (teleport). Takes a new sample each time. Called every 0.1 s by StealService and by tryPlace.
function TreasureService.carrierJumped(player: Player): boolean
	local state = states[player]
	local treasure = state and state.carrying
	if not treasure or not isStolenBy(treasure, player) then
		carryTrack[player] = nil
		return false
	end
	local root = rootOf(player)
	if not root then
		return false
	end
	local now = os.clock()
	local last = carryTrack[player]
	carryTrack[player] = { pos = root.Position, at = now }
	if not last then
		return false
	end
	return StealRules.teleportSuspected((root.Position - last.pos).Magnitude, now - last.at)
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
	local carrierRoot = rootOf(player)
	carryTrack[player] = if carrierRoot then { pos = carrierRoot.Position, at = os.clock() } else nil
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
	if player:GetAttribute("Slipping") == true then
		return false, "slipping"
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
	-- The body of the carried treasure is gone: give the owner his treasure back, nothing is placed.
	if not treasure.PrimaryPart then
		TreasureService.returnToOwner(treasure)
		return false, "lost"
	end
	-- A thief who teleported with stolen loot does not get to keep it (spec 6.2: speed check while carrying).
	if TreasureService.carrierJumped(player) then
		warn(`[TreasureService] {player.Name} jumped while carrying, loot returned`)
		hint(player, "Too fast! The treasure slipped away.")
		local onJumped = TreasureService.onCarrierJumped
		if onJumped then
			onJumped(player)
		end
		return false, "too_fast"
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
	-- Both saves are updated in the same step (no yield between).
	local victimId: number? = nil
	if isStolenBy(treasure, player) then
		victimId = treasure:GetAttribute("OwnerUserId")
		local oldSlot = homeSlotOf(treasure)
		if oldSlot then
			oldSlot:SetAttribute("TreasureId", nil)
		end
	end
	state.carrying = nil
	setSpeed(player, Config.WALK_SPEED)
	setMarker(player, false)
	placeInSlot(treasure, player, slot)
	TreasureService.syncSave(player)
	local victim = if victimId then Players:GetPlayerByUserId(victimId) else nil
	if victim then
		TreasureService.syncSave(victim)
	end
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

-- Unowned dump treasure disappears DUMP_DESPAWN seconds after it lay down on the dump.
-- A token makes sure only the newest timer counts (the treasure may be picked up and returned again).
local function scheduleDespawn(treasure: Model)
	local previous = treasure:GetAttribute("DespawnToken")
	local token = (if typeof(previous) == "number" then previous else 0) + 1
	treasure:SetAttribute("DespawnToken", token)
	task.delay(Config.DUMP_DESPAWN, function()
		if
			treasure.Parent
			and treasure:GetAttribute("DespawnToken") == token
			and treasure:GetAttribute("OwnerUserId") == 0
			and treasure:GetAttribute("CarriedBy") == 0
		then
			destroyTreasure(treasure)
		end
	end)
end

-- The treasure's Body is gone (for example it fell into the void while carried), the model is useless.
-- The owner must not lose his treasure: free his reserved slot and rebuild it from its DefId.
local function recoverLost(treasure: Model)
	local ownerId = treasure:GetAttribute("OwnerUserId")
	local defId = treasure:GetAttribute("DefId")
	local owner = if typeof(ownerId) == "number" and ownerId ~= 0 then Players:GetPlayerByUserId(ownerId) else nil
	local state = owner and states[owner]
	local base = owner and BaseService.baseOf(owner)
	local slotName = treasure:GetAttribute("SlotName")
	if base and typeof(slotName) == "string" then
		local slot = base:FindFirstChild(slotName)
		if slot and slot:GetAttribute("TreasureId") == treasure:GetAttribute("TreasureId") then
			slot:SetAttribute("TreasureId", nil)
		end
	end
	destroyTreasure(treasure)
	if owner and state and state.live and typeof(defId) == "string" then
		warn(`[TreasureService] treasure {defId} lost its body, rebuilt for {owner.Name}`)
		table.insert(state.overflow, defId)
		TreasureService.refill(owner)
		TreasureService.syncSave(owner)
	end
end

-- Treasure goes back to where it belongs: the owner's slot, or the dump if it has no owner.
function TreasureService.returnToOwner(treasure: Instance)
	if not treasure:IsA("Model") then
		return
	end
	clearCarrier(treasure)
	if not treasure.PrimaryPart then
		recoverLost(treasure)
		return
	end
	detach(treasure)

	local ownerId = treasure:GetAttribute("OwnerUserId")
	if typeof(ownerId) == "number" and ownerId ~= 0 then
		local owner = Players:GetPlayerByUserId(ownerId)
		local base = owner and BaseService.baseOf(owner)
		local slotName = treasure:GetAttribute("SlotName")
		local slot = base and typeof(slotName) == "string" and base:FindFirstChild(slotName)
		if owner and slot and slot:IsA("BasePart") then
			placeInSlot(treasure, owner, slot)
			TreasureService.syncSave(owner)
			return
		end
		-- Owner still playing but his slot is gone (should not happen): keep the treasure in his
		-- save as overflow instead of losing it. A leaving owner was already saved with it.
		local ownerState = owner and states[owner]
		local defId = treasure:GetAttribute("DefId")
		if owner and ownerState and ownerState.live and typeof(defId) == "string" then
			warn(`[TreasureService] no slot for returning {defId}, kept in {owner.Name}'s save as overflow`)
			table.insert(ownerState.overflow, defId)
		end
		destroyTreasure(treasure)
		if owner then
			TreasureService.syncSave(owner)
		end
		return
	end
	placeAtDump(treasure)
	setPromptEnabled(treasure, true)
	scheduleDespawn(treasure)
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
	scheduleDespawn(treasure)
	return treasure
end

function TreasureService.getCaps(player: Player): number
	local state = states[player]
	return if state then state.caps else 0
end

local function slotNumber(treasure: Model): number
	local slotName = treasure:GetAttribute("SlotName")
	local n = if typeof(slotName) == "string" then tonumber(string.match(slotName, "^Slot(%d+)$")) else nil
	return n or math.huge
end

local function levelOf(player: Player, state: State): number
	local base = BaseService.baseOf(player)
	local level = base and base:GetAttribute("BaseLevel")
	if typeof(level) == "number" then
		return level
	end
	return state.loadedLevel
end

-- Copies the live state of this player into his save data (DataService.get). Never yields.
-- Saved treasures = every treasure he owns (in a slot, carried by a thief, or dropped), ordered
-- by slot so a reload puts them back in the same places, then the overflow ids.
function TreasureService.syncSave(player: Player)
	local state = states[player]
	if not state or not state.live then
		return
	end
	local data = DataService.get(player)
	if not data then
		return
	end
	local owned: { Model } = {}
	for _, treasure in treasures do
		if treasure:GetAttribute("OwnerUserId") == player.UserId then
			table.insert(owned, treasure)
		end
	end
	table.sort(owned, function(a, b)
		local sa, sb = slotNumber(a), slotNumber(b)
		if sa ~= sb then
			return sa < sb
		end
		return tostring(a:GetAttribute("TreasureId")) < tostring(b:GetAttribute("TreasureId"))
	end)
	local ids = {}
	for _, treasure in owned do
		table.insert(ids, treasure:GetAttribute("DefId"))
	end
	for _, id in state.overflow do
		table.insert(ids, id)
	end
	local clean = SaveSchema.fromRuntime(state.caps, ids, levelOf(player, state))
	if #clean.treasures < #ids then
		warn(`[TreasureService] {player.Name}: {#ids - #clean.treasures} treasure id(s) could not be saved`)
	end
	data.version = clean.version
	data.caps = clean.caps
	data.treasures = clean.treasures
	data.baseLevel = clean.baseLevel
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

-- Takes bottle caps from the player if he has enough. Returns true on success.
function TreasureService.trySpendCaps(player: Player, amount: number): boolean
	local state = states[player]
	if not state or amount < 0 or state.caps < amount then
		return false
	end
	state.caps -= amount
	sendHud(player)
	TreasureService.syncSave(player)
	return true
end

-- After the base got bigger: saved treasures that had no slot (overflow) move into the new slots.
local function fillFromOverflow(player: Player, state: State)
	local remaining = {}
	for _, defId in state.overflow do
		local slot = BaseService.freeSlot(player)
		local treasure = if slot then createTreasure(defId) else nil
		if slot and treasure then
			placeInSlot(treasure, player, slot)
		else
			table.insert(remaining, defId)
		end
	end
	state.overflow = remaining
end

-- Puts saved treasures without a slot (overflow) into free slots, if there are any.
function TreasureService.refill(player: Player)
	local state = states[player]
	if state then
		fillFromOverflow(player, state)
	end
end

-- Upgrade the base one level: costs Config.UPGRADE_COST bottle caps, unlocks more slots.
-- Check, payment, level change and overflow refill happen in one step without yielding.
function TreasureService.tryUpgrade(player: Player): (boolean, string?)
	local state = states[player]
	local base = BaseService.baseOf(player)
	if not state or not state.live or not base then
		return false, "no_state"
	end
	local level = base:GetAttribute("BaseLevel")
	level = if typeof(level) == "number" then level else 1
	if not Economy.canUpgrade(level, state.caps) then
		hint(player, if level >= #Config.BASE_CAPACITY then "Your base is already maxed out!" else "Not enough bottle caps!")
		return false, if level >= #Config.BASE_CAPACITY then "max_level" else "no_caps"
	end
	if not TreasureService.trySpendCaps(player, Config.UPGRADE_COST) then
		return false, "no_caps"
	end
	BaseService.setLevel(player, level + 1)
	fillFromOverflow(player, state)
	TreasureService.syncSave(player)
	sendHud(player)
	Remotes.get("Announce"):FireClient(player, "Base upgraded! More room for trash!", "rare")
	return true, nil
end

-- Gives bottle caps to a player (for example the refund of banana peels he bought but did not place).
function TreasureService.addCaps(player: Player, amount: number): boolean
	local state = states[player]
	if not state or type(amount) ~= "number" or amount ~= amount or amount <= 0 then
		return false
	end
	state.caps += amount
	sendHud(player)
	TreasureService.syncSave(player)
	return true
end

-- Builds the player's runtime state from his loaded save. Call after DataService.load succeeded
-- and after BaseService.assign. Never yields. New players get their start treasure from
-- SaveSchema.default(), not from here.
function TreasureService.addPlayer(player: Player, data: SaveSchema.SaveData)
	if states[player] then
		return
	end
	local base = BaseService.baseOf(player)
	if base then
		BaseService.setLevel(player, data.baseLevel)
	end
	-- No base (server had none free): every treasure waits as overflow, nothing is lost.
	local capacity = if base then BaseService.capacityOf(player) else 0
	local placed, overflow = SaveSchema.splitByCapacity(data.treasures, capacity)
	local state: State = { caps = data.caps, carrying = nil, overflow = overflow, loadedLevel = data.baseLevel, live = false }
	states[player] = state
	for _, defId in placed do
		local slot = BaseService.freeSlot(player)
		local treasure = if slot then createTreasure(defId) else nil
		if slot and treasure then
			placeInSlot(treasure, player, slot)
		else
			warn(`[TreasureService] could not place {defId} for {player.Name}, kept as overflow`)
			table.insert(state.overflow, defId)
		end
	end
	if #state.overflow > 0 then
		print(`[TreasureService] {player.Name}: {#state.overflow} treasure(s) did not fit and stay in the save`)
	end
	-- Death or respawn while carrying: the treasure goes back (stolen -> victim's slot, dump -> dump).
	local function returnCarried()
		local current = states[player]
		if current and current.carrying then
			TreasureService.returnToOwner(current.carrying)
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
	state.live = true
	-- Writes the save once in the runtime order (placed by slot, then overflow).
	TreasureService.syncSave(player)
	sendHud(player)
end

-- Removes the player's runtime state. Call AFTER the final TreasureService.syncSave(player):
-- from here on his save is not touched any more (his treasures leave the map but stay in his save,
-- also one a thief is carrying right now: the owner never lost it).
function TreasureService.removePlayer(player: Player)
	local state = states[player]
	carryTrack[player] = nil
	if state then
		state.live = false
	end
	-- Leaving thief: StealRules decides (carrying -> back to the owner's slot).
	if state and state.carrying then
		if StealRules.resolveLeave("thief", true) == "return_to_owner" then
			TreasureService.returnToOwner(state.carrying)
		end
	end
	-- Leaving owner: his base disappears with its contents. For a treasure a thief is carrying,
	-- StealRules says "return_to_owner" = back into the owner's save data: it still has his
	-- OwnerUserId, so the final syncSave (Main, before this) kept it in his save. It leaves the map
	-- with the base; the same goes for one lying dropped on the ground.
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
			prompt.KeyboardKeyCode = Enum.KeyCode.F -- E is for stealing
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
	Remotes.get("RequestUpgradeBase").OnServerEvent:Connect(function(player)
		TreasureService.tryUpgrade(player)
	end)
	-- Players join/leave through Main (addPlayer / removePlayer), because the save must be loaded first.

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
				TreasureService.syncSave(player)
			end
		end
	end)
end

return TreasureService
