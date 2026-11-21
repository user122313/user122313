-- Steal flow: hold to steal from another player's base, carry the loot home, the owner can take it back.
-- The client only sends REQUESTS (RequestStealStart / RequestStealCommit with a treasureId).
-- The server measures hold time and movement itself and asks StealRules.validate.
-- One hold per thief: { treasure, startedAt, startPos, token }. The treasure is locked
-- (attribute LockedBy) for that thief until commit, rejection, timeout, death or leave.
-- The client releases a hold early by sending RequestStealCommit (rejected as too_short).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local Catalog = require(Shared.Catalog)
local Config = require(Shared.Config)
local Remotes = require(Shared.Remotes)
local StealRules = require(Shared.StealRules)
local Announcer = require(script.Parent.Announcer)
local BaseService = require(script.Parent.BaseService)
local TreasureService = require(script.Parent.TreasureService)

local StealService = {}

type Hold = { treasure: Model, treasureId: string, startedAt: number, startPos: Vector3, token: number }

local holds: { [Player]: Hold } = {}
local lastStealAt: { [Player]: number } = {}
-- When a player's steal request was last rejected (a Commit that follows right after is expected, no second hint).
local lastRejectAt: { [Player]: number } = {}
local REJECT_QUIET_SECONDS = 6
-- Failed starts in a row per thief and the time until he may start again (anti lock abuse).
local failStreak: { [Player]: { count: number, at: number } } = {}
local blockedUntil: { [Player]: number } = {}
-- When an owner got his last steal alarm (UserId -> time), so nobody can spam his screen.
local lastAlarmAt: { [number]: number } = {}
local dropTokens: { [Model]: number } = {}
local nextToken = 0

-- TreasureIds are GUIDs (36 chars); anything much longer is junk.
local MAX_ID_LENGTH = 64

local HINTS = {
	too_far = "Get closer to steal it!",
	too_short = "Hold longer to steal it!",
	carrying = "Your hands are full!",
	base_full = "Your base is full!",
	cooldown = "Wait a moment before stealing again!",
	locked = "Someone else is already stealing that!",
	own_treasure = "That's already yours!",
	too_fast = "Stand still while stealing!",
	no_start = "Hold the button to steal!",
	slipping = "You're slipping!",
	timeout = "Too slow, the steal was cancelled!",
}

local function hint(player: Player, reason: string)
	Remotes.get("Announce"):FireClient(player, HINTS[reason] or "You can't steal that.", "common")
end

local function rootOf(player: Player): BasePart?
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function nextTokenValue(): number
	nextToken += 1
	return nextToken
end

-- Frees the lock of this player's hold (only if he still holds it).
local function clearHold(player: Player)
	local hold = holds[player]
	if not hold then
		return
	end
	holds[player] = nil
	if hold.treasure:GetAttribute("LockedBy") == player.UserId then
		hold.treasure:SetAttribute("LockedBy", 0)
	end
end

local function reject(player: Player, reason: string, treasureId: string?)
	local now = os.clock()
	lastRejectAt[player] = now
	-- Every failed steal makes the next start wait a little longer (1 s, 2 s, ... up to 5 s).
	local streak = failStreak[player]
	local count = if streak and now - streak.at <= Config.STEAL_FAIL_MEMORY then streak.count + 1 else 1
	failStreak[player] = { count = count, at = now }
	blockedUntil[player] = now + StealRules.retryDelay(count)
	clearHold(player)
	warn(`[StealService] {player.Name} rejected: {reason} ({treasureId or "?"})`)
	hint(player, reason)
end

local function validId(treasureId: any): boolean
	return type(treasureId) == "string" and #treasureId > 0 and #treasureId <= MAX_ID_LENGTH
end

-- Treasure that may be stolen at all: exists, owned by another player who is still here,
-- really sits in his slot, nobody carries it. Returns the treasure and owner id, or nil + reason.
local function stealable(player: Player, treasureId: string): (Model?, number?, string?)
	local treasure = TreasureService.find(treasureId)
	if not treasure or not treasure.Parent then
		return nil, nil, "invalid"
	end
	local ownerId = treasure:GetAttribute("OwnerUserId")
	if typeof(ownerId) ~= "number" or ownerId == 0 then
		return nil, nil, "no_owner"
	end
	if ownerId == player.UserId then
		return nil, nil, "own_treasure"
	end
	-- isHome checks: owner still on the server, has his base, treasure sits in that slot, not carried.
	if not TreasureService.isHome(treasure) then
		return nil, nil, "not_in_slot"
	end
	return treasure, ownerId, nil
end

local function buildRequest(player: Player, treasure: Model, ownerId: number, heldSeconds: number, speed: number, distance: number)
	local lockedBy = treasure:GetAttribute("LockedBy")
	return {
		distance = distance,
		heldSeconds = heldSeconds,
		now = os.clock(),
		thiefCarrying = TreasureService.carriedBy(player) ~= nil,
		thiefBaseFull = BaseService.freeSlot(player) == nil,
		thiefLastStealAt = lastStealAt[player],
		thiefSpeed = speed,
		treasureOwnerId = ownerId,
		thiefId = player.UserId,
		treasureLockedBy = if typeof(lockedBy) == "number" and lockedBy ~= 0 then lockedBy else nil,
	}
end

-- No yield anywhere in here: check and lock happen in the same step, so of two
-- thieves the first request wins and the second one sees "locked".
local function onStealStart(player: Player, treasureId: any)
	if not validId(treasureId) then
		warn(`[StealService] {player.Name} sent a bad StealStart argument`)
		return
	end
	-- After a failed steal the thief has to wait (a griefer cannot keep a treasure locked by spamming starts).
	if os.clock() < (blockedUntil[player] or 0) then
		hint(player, "cooldown")
		return
	end
	-- A new start always ends the old hold first.
	clearHold(player)
	-- Nobody steals while sliding on a banana peel.
	if player:GetAttribute("Slipping") == true then
		reject(player, "slipping", treasureId)
		return
	end

	local treasure, ownerId, why = stealable(player, treasureId)
	if not treasure or not ownerId then
		reject(player, why or "invalid", treasureId)
		return
	end
	local root, body = rootOf(player), treasure.PrimaryPart
	if not root or not body then
		reject(player, "no_character", treasureId)
		return
	end

	-- Early check with the full hold time assumed: catches locked, carrying, base_full,
	-- cooldown and too_far before the player waits 1.5 s for nothing.
	local distance = (root.Position - body.Position).Magnitude
	local ok, reason = StealRules.validate(buildRequest(player, treasure, ownerId, Config.STEAL_HOLD, 0, distance))
	if not ok then
		reject(player, reason or "invalid", treasureId)
		return
	end

	local token = nextTokenValue()
	treasure:SetAttribute("LockedBy", player.UserId)
	holds[player] = {
		treasure = treasure,
		treasureId = treasureId,
		startedAt = os.clock(),
		startPos = root.Position,
		token = token,
	}
	-- Warning signal for the victim while the hold is running (at most one per ALARM_INTERVAL).
	local alarmNow = os.clock()
	if alarmNow - (lastAlarmAt[ownerId] or -1000) >= Config.ALARM_INTERVAL then
		lastAlarmAt[ownerId] = alarmNow
		Announcer.stealAlarm(ownerId, player.Name)
	end

	-- The thief never commits: free the treasure again.
	task.delay(Config.STEAL_LOCK_TIMEOUT, function()
		local hold = holds[player]
		if hold and hold.token == token then
			reject(player, "timeout", treasureId)
		end
	end)
end

local function onStealCommit(player: Player, treasureId: any)
	if not validId(treasureId) then
		warn(`[StealService] {player.Name} sent a bad StealCommit argument`)
		return
	end
	local hold = holds[player]
	if not hold or hold.treasureId ~= treasureId then
		-- The client keeps holding after a rejected Start and sends Commit on release: stay quiet then.
		if os.clock() - (lastRejectAt[player] or -1000) < REJECT_QUIET_SECONDS then
			warn(`[StealService] {player.Name} commit after a rejected start ignored`)
			return
		end
		reject(player, "no_start", treasureId)
		return
	end
	if player:GetAttribute("Slipping") == true then
		reject(player, "slipping", treasureId)
		return
	end

	local treasure, ownerId, why = stealable(player, treasureId)
	if not treasure or not ownerId or treasure ~= hold.treasure then
		reject(player, why or "invalid", treasureId)
		return
	end
	local root, body = rootOf(player), treasure.PrimaryPart
	if not root or not body then
		reject(player, "no_character", treasureId)
		return
	end

	-- Everything measured on the server, never taken from the client.
	local now = os.clock()
	local heldSeconds = now - hold.startedAt
	local moved = (root.Position - hold.startPos).Magnitude
	local speed = moved / math.max(heldSeconds, 1 / 60)
	local distance = (root.Position - body.Position).Magnitude

	local ok, reason = StealRules.validate(buildRequest(player, treasure, ownerId, heldSeconds, speed, distance))
	if not ok then
		reject(player, reason or "invalid", treasureId)
		return
	end

	-- Success: the hold ends, the thief carries the treasure (OwnerUserId stays with the victim
	-- until the thief places it in his own base, see TreasureService.tryPlace).
	holds[player] = nil
	if not TreasureService.giveTo(player, treasure) then
		treasure:SetAttribute("LockedBy", 0)
		reject(player, "failed", treasureId)
		return
	end
	lastStealAt[player] = now
	failStreak[player] = nil
	blockedUntil[player] = nil
	print(`[StealService] {player.Name} stole {treasure.Name} from user {ownerId}`)
	local def = Catalog.get(treasure:GetAttribute("DefId"))
	if def then
		Announcer.treasureStolen(player.Name, def)
	end
end

-- The carried treasure falls to the ground; DROP_RETURN seconds later it goes back to its owner.
-- Nobody can pick it up while it lies there and it earns nothing.
function StealService.dropCarried(player: Player)
	local treasure = TreasureService.dropAtFeet(player)
	if not treasure then
		return
	end
	local token = nextTokenValue()
	dropTokens[treasure] = token
	task.delay(Config.DROP_RETURN, function()
		if dropTokens[treasure] ~= token then
			return
		end
		dropTokens[treasure] = nil
		-- Gone (owner left) or already back: nothing to do.
		if treasure.Parent and treasure:GetAttribute("CarriedBy") == 0 and treasure:GetAttribute("InSlot") ~= true then
			TreasureService.returnToOwner(treasure)
		end
	end)
end

-- Owner close to the thief -> the loot falls. Plain distance check on the server, no Touched events.
local function checkOwnerTouches()
	local toDrop = {}
	for _, thief in Players:GetPlayers() do
		-- A thief who teleported with the loot (more than a walking player can) drops it.
		if TreasureService.carrierJumped(thief) then
			warn(`[StealService] {thief.Name} jumped while carrying stolen loot, it falls`)
			table.insert(toDrop, thief)
			continue
		end
		local treasure = TreasureService.carriedBy(thief)
		local ownerId = treasure and treasure:GetAttribute("OwnerUserId")
		if typeof(ownerId) == "number" and ownerId ~= 0 and ownerId ~= thief.UserId then
			local owner = Players:GetPlayerByUserId(ownerId)
			local thiefRoot = rootOf(thief)
			local ownerRoot = owner and rootOf(owner)
			if thiefRoot and ownerRoot and (thiefRoot.Position - ownerRoot.Position).Magnitude <= Config.OWNER_TOUCH_RADIUS then
				table.insert(toDrop, thief)
			end
		end
	end
	for _, thief in toDrop do
		StealService.dropCarried(thief)
	end
end

-- While a hold runs the thief must stay near the treasure, otherwise he could step away and
-- come back right before the commit (start and end positions alone would look fine).
local function checkHolds()
	local broken = {}
	for thief, hold in holds do
		local root, body = rootOf(thief), hold.treasure.PrimaryPart
		if not root or not body or StealRules.holdBroken((root.Position - body.Position).Magnitude) then
			table.insert(broken, thief)
		end
	end
	for _, thief in broken do
		local hold = holds[thief]
		if hold then
			reject(thief, "too_far", hold.treasureId)
		end
	end
end

local function onPlayerRemoving(player: Player)
	-- Thief leaves mid-hold: free the lock.
	clearHold(player)
	lastStealAt[player] = nil
	lastRejectAt[player] = nil
	failStreak[player] = nil
	blockedUntil[player] = nil
	lastAlarmAt[player.UserId] = nil
	-- Owner leaves: cancel every hold on his treasures (they leave with his base).
	-- Collect first, then clear, so the table is not changed while looping over it.
	local cancelled = {}
	for thief, hold in holds do
		if hold.treasure:GetAttribute("OwnerUserId") == player.UserId then
			table.insert(cancelled, thief)
		end
	end
	for _, thief in cancelled do
		clearHold(thief)
	end
end

local function onPlayerAdded(player: Player)
	-- Death or respawn mid-hold cancels the steal.
	player.CharacterRemoving:Connect(function()
		clearHold(player)
	end)
end

-- The remote handlers, also callable from server code (used by Studio checks).
StealService.handleStart = onStealStart
StealService.handleCommit = onStealCommit

function StealService.start()
	-- A thief who tries to place loot after a teleport loses it (see TreasureService.tryPlace).
	TreasureService.onCarrierJumped = StealService.dropCarried
	Remotes.get("RequestStealStart").OnServerEvent:Connect(StealService.handleStart)
	Remotes.get("RequestStealCommit").OnServerEvent:Connect(StealService.handleCommit)

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end

	local holdElapsed = 0
	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		holdElapsed += dt
		if holdElapsed >= Config.STEAL_HOLD_CHECK then
			holdElapsed = 0
			checkHolds()
		end
		elapsed += dt
		if elapsed >= Config.OWNER_TOUCH_CHECK then
			elapsed = 0
			checkOwnerTouches()
		end
	end)
end

return StealService
