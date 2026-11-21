-- Banana peel trap: buy with bottle caps, place in your own base, strangers slip on it.
-- Remotes (requests only, the server decides everything):
--   RequestBuyBanana()   -> costs Config.BANANA_COST, adds one peel to the player's stock
--   RequestPlaceBanana() -> puts one peel from the stock on the floor in front of the player (own base only)
-- The stock is shown to the client through the player attribute "Bananas".
-- A slipping player has the attribute "Slipping" = true (steal and pickup are blocked meanwhile).
-- Slip: flung through the air, helpless for Config.SLIP_SECONDS, drops what he carries, the peel is used up.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local Config = require(Shared.Config)
local Remotes = require(Shared.Remotes)
local TrapRules = require(Shared.TrapRules)
local BaseService = require(script.Parent.BaseService)
local StealService = require(script.Parent.StealService)
local TreasureService = require(script.Parent.TreasureService)

local TrapService = {}

-- How hard a slipping player is thrown (studs per second); the impulse is scaled by his mass.
local FLING_UP = 60
local FLING_AWAY = 28

local stock: { [Player]: number } = {}
local placed: { [Player]: { BasePart } } = {}
local slipping: { [Player]: boolean } = {}
local trapFolder: Folder? = nil

local function hint(player: Player, text: string)
	Remotes.get("Announce"):FireClient(player, text, "common")
end

local function setStock(player: Player, amount: number)
	stock[player] = amount
	player:SetAttribute("Bananas", amount)
end

local function aliveRoot(player: Player): (Humanoid?, BasePart?)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
		return humanoid, root
	end
	return nil, nil
end

local function removePlaced(player: Player, banana: BasePart)
	local list = placed[player]
	local index = list and table.find(list, banana)
	if list and index then
		table.remove(list, index)
	end
end

-- Buying: caps -> one peel in the stock.
function TrapService.handleBuy(player: Player): (boolean, string?)
	if stock[player] == nil then
		return false, "no_state"
	end
	if not TrapRules.canBuy(TreasureService.getCaps(player)) then
		hint(player, "Not enough bottle caps!")
		return false, "no_caps"
	end
	if not TreasureService.trySpendCaps(player, Config.BANANA_COST) then
		hint(player, "Not enough bottle caps!")
		return false, "no_caps"
	end
	setStock(player, stock[player] + 1)
	return true, nil
end

local function slip(player: Player, bananaPosition: Vector3)
	local humanoid, root = aliveRoot(player)
	if slipping[player] or not humanoid or not root then
		return
	end
	slipping[player] = true
	player:SetAttribute("Slipping", true)

	local outcome = TrapRules.slipOutcome(TreasureService.carriedBy(player) ~= nil)
	if outcome.dropsLoot then
		-- Stolen loot goes back to its owner after DROP_RETURN, dump loot goes back to the dump.
		StealService.dropCarried(player)
	end

	humanoid.PlatformStand = true
	-- The server takes over the physics of the character for the flight, so the throw is not lost.
	pcall(function()
		root:SetNetworkOwner(nil)
	end)
	local away = Vector3.new(root.Position.X - bananaPosition.X, 0, root.Position.Z - bananaPosition.Z)
	if away.Magnitude < 0.1 then
		away = -root.CFrame.LookVector
	end
	away = away.Unit
	root:ApplyImpulse(Vector3.new(away.X * FLING_AWAY, FLING_UP, away.Z * FLING_AWAY) * root.AssemblyMass)

	Remotes.get("Slipped"):FireClient(player, outcome.helplessSeconds)

	task.delay(outcome.helplessSeconds, function()
		slipping[player] = nil
		if player.Parent == nil then
			return
		end
		player:SetAttribute("Slipping", nil)
		local h, r = aliveRoot(player)
		if h and r then
			-- Stop all motion before the player gets his character back, otherwise
			-- the client replays an old throw and the character jumps once more.
			r.AssemblyLinearVelocity = Vector3.zero
			r.AssemblyAngularVelocity = Vector3.zero
			h.PlatformStand = false
			h:ChangeState(Enum.HumanoidStateType.GettingUp)
			pcall(function()
				r:SetNetworkOwner(player)
			end)
		end
	end)
end

local function onBananaTouched(banana: BasePart, hit: BasePart)
	if banana:GetAttribute("Used") == true then
		return
	end
	local character = hit:FindFirstAncestorOfClass("Model")
	local victim = character and Players:GetPlayerFromCharacter(character)
	if not victim then
		return
	end
	-- The owner never slips on his own peels; a player who is already sliding does not use one up.
	if victim.UserId == banana:GetAttribute("OwnerUserId") or slipping[victim] then
		return
	end
	if not aliveRoot(victim) then
		return
	end
	banana:SetAttribute("Used", true)
	local ownerId = banana:GetAttribute("OwnerUserId")
	local owner = if typeof(ownerId) == "number" then Players:GetPlayerByUserId(ownerId) else nil
	if owner then
		removePlaced(owner, banana)
	end
	local position = banana.Position
	banana:Destroy()
	slip(victim, position)
end

local function createBanana(owner: Player, position: Vector3): BasePart
	local banana = Instance.new("Part")
	banana.Name = "BananaPeel"
	banana.Size = Vector3.new(2.4, 0.5, 3.2)
	banana.Color = Color3.fromRGB(255, 225, 53)
	banana.Material = Enum.Material.SmoothPlastic
	banana.Anchored = true
	banana.CanCollide = false
	banana.CFrame = CFrame.new(position) * CFrame.Angles(0, math.random() * math.pi * 2, 0)
	banana:SetAttribute("OwnerUserId", owner.UserId)
	banana.Touched:Connect(function(hit)
		onBananaTouched(banana, hit)
	end)
	banana.Parent = trapFolder
	return banana
end

-- Placing: one peel from the stock on the floor in front of the player, inside his own base.
function TrapService.handlePlace(player: Player): (boolean, string?)
	local count = stock[player]
	if count == nil then
		return false, "no_state"
	end
	if count <= 0 then
		hint(player, "Buy a banana peel first!")
		return false, "no_stock"
	end
	local _, root = aliveRoot(player)
	local base = BaseService.baseOf(player)
	local floor = base and base:FindFirstChild("Floor")
	if not root or not floor or not floor:IsA("BasePart") then
		return false, "no_base"
	end
	local list = placed[player]
	local ok, reason = TrapRules.canPlace(#list, BaseService.isInsideOwnBase(player))
	if not ok then
		hint(player, if reason == "max_traps" then `Max {Config.MAX_BANANAS} banana peels in your base!` else "Place it in YOUR base!")
		return false, reason
	end

	-- Four studs in front of the player, kept inside the floor.
	local rel = floor.CFrame:PointToObjectSpace((root.CFrame * CFrame.new(0, 0, -4)).Position)
	local limit = floor.Size.X / 2 - 2
	local clamped = Vector3.new(math.clamp(rel.X, -limit, limit), floor.Size.Y / 2 + 0.25, math.clamp(rel.Z, -limit, limit))
	local banana = createBanana(player, floor.CFrame:PointToWorldSpace(clamped))
	table.insert(list, banana)
	setStock(player, count - 1)
	return true, nil
end

-- Peels a player bought but did not place are not saved. When he leaves, he gets the bottle caps back,
-- so nothing he paid for is lost. Call BEFORE the final save (see Main). Returns the refunded caps.
function TrapService.refundStock(player: Player): number
	local count = stock[player] or 0
	if count <= 0 then
		return 0
	end
	local amount = count * Config.BANANA_COST
	stock[player] = 0
	if TreasureService.addCaps(player, amount) then
		return amount
	end
	return 0
end

local function onPlayerAdded(player: Player)
	placed[player] = {}
	setStock(player, 0)
end

local function onPlayerRemoving(player: Player)
	-- His peels disappear with his base.
	for _, banana in placed[player] or {} do
		banana:Destroy()
	end
	placed[player] = nil
	stock[player] = nil
	slipping[player] = nil
end

function TrapService.start()
	local folder = Instance.new("Folder")
	folder.Name = "Traps"
	folder.Parent = Workspace
	trapFolder = folder

	Remotes.get("RequestBuyBanana").OnServerEvent:Connect(TrapService.handleBuy)
	Remotes.get("RequestPlaceBanana").OnServerEvent:Connect(TrapService.handlePlace)

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end
end

return TrapService
