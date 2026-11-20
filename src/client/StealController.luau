-- Finds nearby treasures and tracks a hold from E or the touch button.
-- Shows local progress and sends requests while the server resolves the steal.
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local STEAL_ACTION = "MuellbanditenSteal"
local CONTROL_REFRESH_INTERVAL = 0.1

local StealController = {}

type Hold = {
	input: InputObject,
	treasure: Model,
	treasureId: string,
	startedAt: number,
}

local function getRoot(player: Player): BasePart?
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function findTarget(player: Player): (Model?, string?)
	local root = getRoot(player)
	local treasures = Workspace:FindFirstChild("Treasures")
	if not root or not treasures then
		return nil, nil
	end

	local closest, closestId
	local closestDistance = Config.STEAL_REACH
	for _, treasure in treasures:GetChildren() do
		if not treasure:IsA("Model") then
			continue
		end
		local owner = treasure:GetAttribute("OwnerUserId")
		local treasureId = treasure:GetAttribute("TreasureId")
		local body = treasure.PrimaryPart
		if typeof(owner) ~= "number" or owner == 0 or owner == player.UserId
			or typeof(treasureId) ~= "string" or treasureId == ""
			or treasure:GetAttribute("CarriedBy") ~= 0 or treasure:GetAttribute("InSlot") == false
			or not body
		then
			continue
		end

		local distance = (root.Position - body.Position).Magnitude
		if distance <= closestDistance then
			closest, closestId, closestDistance = treasure, treasureId, distance
		end
	end
	return closest, closestId
end

function StealController.start(
	stealButton: GuiButton,
	showProgress: (boolean) -> (),
	requestStart: (string) -> (),
	requestCommit: (string) -> (),
	setKeyboardHint: ((boolean) -> ())?
): () -> ()
	local player = Players.LocalPlayer
	local hold: Hold? = nil
	local keyboardCaptured = false
	local keyboardHintVisible = false
	local nextControlRefresh = 0
	stealButton.Visible = false
	showProgress(false)
	if setKeyboardHint then
		setKeyboardHint(false)
	end

	local function updateKeyboardHint(visible: boolean)
		if setKeyboardHint and keyboardHintVisible ~= visible then
			keyboardHintVisible = visible
			setKeyboardHint(visible)
		end
	end

	local function finishHold(sendCommit: boolean)
		local attempt = hold
		if not attempt then
			return
		end
		hold = nil
		showProgress(false)
		if sendCommit then
			requestCommit(attempt.treasureId)
		end
	end

	local function beginHold(input: InputObject): boolean
		if hold or UserInputService:GetFocusedTextBox() or GuiService.MenuIsOpen then
			return false
		end
		local treasure, treasureId = findTarget(player)
		if not treasure or not treasureId then
			return false
		end

		-- Keep the same target throughout the hold even if another treasure becomes closer.
		hold = { input = input, treasure = treasure, treasureId = treasureId, startedAt = os.clock() }
		requestStart(treasureId)
		updateKeyboardHint(false)
		showProgress(true)
		return true
	end

	local function onStealKey(_name: string, state: Enum.UserInputState, input: InputObject)
		if state == Enum.UserInputState.Begin and not keyboardCaptured then
			keyboardCaptured = beginHold(input)
		end
		if not keyboardCaptured then
			return Enum.ContextActionResult.Pass
		end
		if state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
			keyboardCaptured = false
			if hold and hold.input.UserInputType == Enum.UserInputType.Keyboard then
				finishHold(true)
			end
		end
		return Enum.ContextActionResult.Sink
	end

	local function onInputInterrupted()
		keyboardCaptured = false
		finishHold(true)
	end

	local function update()
		local now = os.clock()
		local attempt = hold
		if attempt then
			if not getRoot(player) or not attempt.treasure.Parent then
				finishHold(false)
			elseif attempt.input.UserInputState == Enum.UserInputState.Cancel
				or attempt.input.UserInputState == Enum.UserInputState.End
				or now - attempt.startedAt >= Config.STEAL_HOLD
			then
				finishHold(true)
			end
		end

		if now >= nextControlRefresh then
			nextControlRefresh = now + CONTROL_REFRESH_INTERVAL
			local hasTarget = hold == nil and findTarget(player) ~= nil
			stealButton.Visible = UserInputService.TouchEnabled and (hold ~= nil or hasTarget)
			updateKeyboardHint(hasTarget and not keyboardCaptured
				and UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
				and not UserInputService:GetFocusedTextBox() and not GuiService.MenuIsOpen)
		end
	end

	-- E is only for stealing. The server's Grab and Drop prompts use key F: Roblox prompts always win
	-- a shared key, whatever priority we bind with (tested in Studio, see STATUS.md).
	ContextActionService:BindActionAtPriority(
		STEAL_ACTION, onStealKey, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.E
	)
	local connections = {
		stealButton.InputBegan:Connect(function(input)
			if stealButton.Visible and (input.UserInputType == Enum.UserInputType.Touch
				or input.UserInputType == Enum.UserInputType.MouseButton1)
			then
				beginHold(input)
			end
		end),
		UserInputService.InputEnded:Connect(function(input)
			-- Global release also fires if the finger has moved off the touch button.
			if hold and hold.input == input then
				finishHold(true)
			end
		end),
		UserInputService.WindowFocusReleased:Connect(onInputInterrupted),
		UserInputService.TextBoxFocused:Connect(onInputInterrupted),
		GuiService.MenuOpened:Connect(onInputInterrupted),
		player.CharacterRemoving:Connect(function()
			finishHold(false)
		end),
		RunService.RenderStepped:Connect(update),
	}

	return function()
		keyboardCaptured = false
		ContextActionService:UnbindAction(STEAL_ACTION)
		for _, connection in connections do
			connection:Disconnect()
		end
		finishHold(false)
		stealButton.Visible = false
		updateKeyboardHint(false)
	end
end

return StealController
