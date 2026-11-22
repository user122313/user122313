-- Base shield: every base has a pad. The owner walks onto it and for Config.SHIELD_SECONDS nobody can steal
-- from this base. After that the pad needs Config.SHIELD_COOLDOWN seconds before it works again.
-- The shield state lives on the base Model as attribute "ShieldUntil" (server time, Workspace:GetServerTimeNow()),
-- so StealService can check it and a client HUD can show a countdown later.
-- Times and checks come from ShieldRules (tested). This file only builds the pad and the visual field.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local Config = require(Shared.Config)
local Remotes = require(Shared.Remotes)
local ShieldRules = require(Shared.ShieldRules)
local BaseService = require(script.Parent.BaseService)

local ShieldService = {}

type PadState = { pad: BasePart, label: TextLabel, field: BasePart?, readyAt: number, token: number }

local pads: { [Model]: PadState } = {}
local fieldFolder: Folder? = nil

local READY = Color3.fromRGB(70, 220, 255)
local ACTIVE = Color3.fromRGB(120, 255, 160)
local WAITING = Color3.fromRGB(90, 90, 100)

local function serverNow(): number
	return Workspace:GetServerTimeNow()
end

local function announce(player: Player, text: string)
	Remotes.get("Announce"):FireClient(player, text, "common")
end

local function fx(kind: string, position: Vector3)
	Remotes.get("Fx"):FireAllClients(kind, position, "")
end

local function setPad(state: PadState, mode: string)
	if mode == "ready" then
		state.pad.Color = READY
		state.pad.Material = Enum.Material.Neon
		state.label.Text = "SHIELD"
		state.label.TextColor3 = READY
	elseif mode == "active" then
		state.pad.Color = ACTIVE
		state.pad.Material = Enum.Material.Neon
		state.label.Text = "SHIELD ON"
		state.label.TextColor3 = ACTIVE
	else
		state.pad.Color = WAITING
		state.pad.Material = Enum.Material.SmoothPlastic
		state.label.Text = "RECHARGING"
		state.label.TextColor3 = Color3.fromRGB(190, 190, 200)
	end
end

-- Is this player's base shielded right now?
function ShieldService.isShielded(player: Player): boolean
	local base = BaseService.baseOf(player)
	if not base then
		return false
	end
	local untilTime = base:GetAttribute("ShieldUntil")
	return ShieldRules.isActive(serverNow(), if typeof(untilTime) == "number" then untilTime else nil)
end

local function endShield(base: Model, state: PadState)
	base:SetAttribute("ShieldUntil", 0)
	if state.field then
		state.field:Destroy()
		state.field = nil
	end
end

local function activate(base: Model, owner: Player, state: PadState)
	local floor = base:FindFirstChild("Floor")
	if not floor or not floor:IsA("BasePart") then
		return
	end
	local times = ShieldRules.activate(serverNow())
	base:SetAttribute("ShieldUntil", times.shieldUntil)
	state.readyAt = times.readyAt
	state.token += 1
	local token = state.token

	if state.field then
		state.field:Destroy()
	end
	local field = Instance.new("Part")
	field.Name = "ShieldField"
	field.Size = Vector3.new(floor.Size.X, 10, floor.Size.Z)
	field.CFrame = floor.CFrame * CFrame.new(0, floor.Size.Y / 2 + 5, 0)
	field.Anchored = true
	field.CanCollide = false
	field.CanQuery = false
	field.CanTouch = false
	field.CastShadow = false
	field.Material = Enum.Material.ForceField
	field.Color = READY
	field.Parent = fieldFolder
	state.field = field

	setPad(state, "active")
	announce(owner, `Shield on for {Config.SHIELD_SECONDS} seconds!`)
	fx("shield_on", floor.Position)

	task.delay(Config.SHIELD_SECONDS, function()
		if state.token ~= token then
			return
		end
		endShield(base, state)
		setPad(state, "waiting")
		if owner.Parent == Players then
			announce(owner, "Shield is down!")
		end
		fx("shield_off", floor.Position)
		task.delay(Config.SHIELD_COOLDOWN, function()
			if state.token == token then
				setPad(state, "ready")
			end
		end)
	end)
end

local function buildPad(base: Model)
	local floor = base:FindFirstChild("Floor")
	if not floor or not floor:IsA("BasePart") then
		return
	end
	local pad = Instance.new("Part")
	pad.Name = "ShieldPad"
	pad.Size = Vector3.new(5, 0.4, 5)
	-- Front right corner of the base floor: out of the way of spawn and slots.
	pad.CFrame = floor.CFrame * CFrame.new(floor.Size.X / 2 - 4, floor.Size.Y / 2 + 0.2, -(floor.Size.Z / 2 - 4))
	pad.Anchored = true
	pad.CanCollide = false
	pad.CanQuery = false
	pad.Parent = base

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(150, 30)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.MaxDistance = 35
	gui.AlwaysOnTop = false
	gui.Parent = pad
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.TextStrokeTransparency = 0
	label.Parent = gui

	local state: PadState = { pad = pad, label = label, field = nil, readyAt = 0, token = 0 }
	setPad(state, "ready")
	pads[base] = state
end

-- Per 0.1 s: an owner standing on his pad switches the shield on (if the pad is ready).
local function check()
	for base, state in pads do
		local ownerId = base:GetAttribute("OwnerUserId")
		local owner = if typeof(ownerId) == "number" and ownerId ~= 0 then Players:GetPlayerByUserId(ownerId) else nil
		if not owner then
			-- Base is free again (owner left): reset everything for the next player.
			if state.field or state.readyAt ~= 0 then
				state.token += 1
				state.readyAt = 0
				endShield(base, state)
				setPad(state, "ready")
			end
			continue
		end
		local character = owner.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if root and root:IsA("BasePart") and humanoid and humanoid.Health > 0 then
			local offset = root.Position - state.pad.Position
			if ShieldRules.onPad(offset.X, offset.Y, offset.Z) and ShieldRules.canActivate(serverNow(), state.readyAt) then
				activate(base, owner, state)
			end
		end
	end
end

function ShieldService.start()
	local folder = Instance.new("Folder")
	folder.Name = "Shields"
	folder.Parent = Workspace
	fieldFolder = folder

	local bases = Workspace:FindFirstChild("Bases")
	if not bases then
		warn("[ShieldService] Workspace.Bases is missing")
		return
	end
	for _, base in bases:GetChildren() do
		if base:IsA("Model") then
			buildPad(base)
		end
	end
	task.spawn(function()
		while true do
			task.wait(0.1)
			check()
		end
	end)
end

return ShieldService
