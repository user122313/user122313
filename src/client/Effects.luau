-- Shows the owner-only steal alarm and the slip reaction on the HUD.
-- Adds a short local camera shake to the server-driven slip animation.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Theme = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Theme"))
local danger = Color3.fromRGB(table.unpack(Theme.colors.danger))
local text = Color3.fromRGB(table.unpack(Theme.colors.text))
local background = Color3.fromRGB(table.unpack(Theme.colors.background))
local hasThemeFont, themeFont = pcall(function()
	return Enum.Font[Theme.font]
end)
local font = hasThemeFont and themeFont or Enum.Font.GothamBold

local PRE_CAMERA = "MuellbanditenSlipRestore"
local POST_CAMERA = "MuellbanditenSlipShake"
local CAMERA_PRIORITY = Enum.RenderPriority.Camera.Value

local Effects = {}
Effects.__index = Effects

local function restoreCamera(self)
	local frame = self.cameraFrame
	if frame and frame.camera.CFrame == frame.shaken then
		frame.camera.CFrame = frame.original
	end
	self.cameraFrame = nil
end

local function stopShake(self)
	if self.shaking then
		RunService:UnbindFromRenderStep(PRE_CAMERA)
		RunService:UnbindFromRenderStep(POST_CAMERA)
		self.shaking = false
	end
	restoreCamera(self)
end

local function clearSlip(self)
	local tween = self.slipTween
	self.slipTween = nil
	if tween then
		tween:Cancel()
	end
	self.slipLabel.Visible = false
	stopShake(self)
end

function Effects.new(gui: ScreenGui)
	local border = Instance.new("Frame")
	border.Name = "AlarmBorder"
	border.AnchorPoint = Vector2.new(0.5, 0.5)
	border.Position = UDim2.fromScale(0.5, 0.5)
	local inset = Theme.strokeThickness * 2
	border.Size = UDim2.new(1, -2 * inset, 1, -2 * inset)
	border.BackgroundTransparency = 1
	border.BorderSizePixel = 0
	border.Visible = false
	border.ZIndex = 10
	border.Parent = gui

	local borderCorner = Instance.new("UICorner")
	borderCorner.CornerRadius = UDim.new(0, Theme.cornerRadius)
	borderCorner.Parent = border

	local borderStroke = Instance.new("UIStroke")
	borderStroke.Color = danger
	borderStroke.Thickness = 2 * Theme.strokeThickness
	borderStroke.Parent = border

	local alarmLabel = Instance.new("TextLabel")
	alarmLabel.Name = "StealAlarm"
	alarmLabel.AutomaticSize = Enum.AutomaticSize.Y
	alarmLabel.BackgroundColor3 = background
	alarmLabel.BorderSizePixel = 0
	alarmLabel.Font = font
	alarmLabel.Text = "SOMEONE IS STEALING!"
	alarmLabel.TextColor3 = text
	alarmLabel.TextSize = Theme.textSize.banner
	alarmLabel.TextWrapped = true
	alarmLabel.Visible = false
	alarmLabel.ZIndex = 11
	alarmLabel.Parent = gui

	local alarmSize = Instance.new("UISizeConstraint")
	alarmSize.MaxSize = Vector2.new(14 * Theme.textSize.banner, math.huge)
	alarmSize.Parent = alarmLabel

	local alarmCorner = Instance.new("UICorner")
	alarmCorner.CornerRadius = UDim.new(0, Theme.cornerRadius)
	alarmCorner.Parent = alarmLabel

	local alarmPadding = Instance.new("UIPadding")
	local padding = UDim.new(0, Theme.cornerRadius / 2)
	alarmPadding.PaddingLeft = padding
	alarmPadding.PaddingRight = padding
	alarmPadding.PaddingTop = padding
	alarmPadding.PaddingBottom = padding
	alarmPadding.Parent = alarmLabel

	local function placeAlarm()
		local view = gui.AbsoluteSize
		if view.Y < 440 and view.X >= view.Y * 1.55 then
			-- On short screens, use the side opposite the action buttons and leave the header clear.
			local right = UserInputService.TouchEnabled
			alarmLabel.AnchorPoint = Vector2.new(if right then 1 else 0, 0)
			alarmLabel.Position = UDim2.fromScale(if right then 0.99 else 0.01, 0.04)
			alarmLabel.Size = UDim2.fromScale(0.29, 0)
		else
			alarmLabel.AnchorPoint = Vector2.new(0.5, 0)
			alarmLabel.Position = UDim2.fromScale(0.5, 0.31)
			alarmLabel.Size = UDim2.fromScale(0.84, 0)
		end
	end
	placeAlarm()

	local slipLabel = Instance.new("TextLabel")
	slipLabel.Name = "SlipReaction"
	slipLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	slipLabel.Position = UDim2.fromScale(0.5, 0.5)
	slipLabel.Size = UDim2.fromScale(0.8, 0.25)
	slipLabel.BackgroundTransparency = 1
	slipLabel.Font = font
	slipLabel.Text = "SLIPPED!"
	slipLabel.TextColor3 = text
	slipLabel.TextStrokeColor3 = background
	slipLabel.TextScaled = true
	slipLabel.Visible = false
	slipLabel.ZIndex = 12
	slipLabel.Parent = gui

	local slipTextSize = Instance.new("UITextSizeConstraint")
	slipTextSize.MinTextSize = Theme.textSize.banner
	slipTextSize.MaxTextSize = math.round(1.5 * Theme.textSize.banner)
	slipTextSize.Parent = slipLabel

	local self = setmetatable({
		border = border,
		borderStroke = borderStroke,
		alarmLabel = alarmLabel,
		slipLabel = slipLabel,
		viewportChanged = gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(placeAlarm),
	}, Effects)
	self.characterRemoving = Players.LocalPlayer.CharacterRemoving:Connect(function()
		clearSlip(self)
	end)
	return self
end

function Effects:showStealAlarm(_thiefName: string)
	if self.alarmTween then
		self.alarmTween:Cancel()
	end
	self.borderStroke.Transparency = 0.08
	self.border.Visible = true
	self.alarmLabel.Visible = true

	local blink = TweenService:Create(self.borderStroke, TweenInfo.new(0.28, Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut, 2, true), { Transparency = 0.9 })
	self.alarmTween = blink
	blink.Completed:Once(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed and self.alarmTween == blink then
			self.alarmTween = nil
			self.border.Visible = false
			self.alarmLabel.Visible = false
		end
	end)
	blink:Play()
end

function Effects:showSlip(seconds: number)
	clearSlip(self)
	if seconds <= 0 then
		return
	end

	self.slipLabel.TextTransparency = 0
	self.slipLabel.TextStrokeTransparency = 0.05
	self.slipLabel.Visible = true
	local fadeTime = math.min(0.2, seconds)
	local fade = TweenService:Create(self.slipLabel, TweenInfo.new(fadeTime, Enum.EasingStyle.Quad,
		Enum.EasingDirection.In, 0, false, seconds - fadeTime), { TextTransparency = 1, TextStrokeTransparency = 1 })
	self.slipTween = fade
	fade.Completed:Once(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed and self.slipTween == fade then
			self.slipTween = nil
			clearSlip(self)
		end
	end)
	fade:Play()

	local shakeTime = math.min(0.45, seconds)
	local start = os.clock()
	self.shaking = true
	-- Remove our offset before Roblox calculates its next camera frame so the shake cannot accumulate.
	RunService:BindToRenderStep(PRE_CAMERA, CAMERA_PRIORITY - 1, function()
		restoreCamera(self)
	end)
	RunService:BindToRenderStep(POST_CAMERA, CAMERA_PRIORITY + 1, function()
		local elapsed = os.clock() - start
		if elapsed >= shakeTime then
			stopShake(self)
			return
		end

		local camera = workspace.CurrentCamera
		if camera then
			local strength = (1 - elapsed / shakeTime) ^ 2
			local original = camera.CFrame
			local offset = CFrame.new(math.sin(elapsed * 46) * 0.25 * strength,
				math.sin(elapsed * 69) * 0.16 * strength, 0)
			camera.CFrame = original * offset * CFrame.Angles(0, 0, math.sin(elapsed * 51) * 0.025 * strength)
			self.cameraFrame = { camera = camera, original = original, shaken = camera.CFrame }
		end
	end)
end

function Effects:destroy()
	self.characterRemoving:Disconnect()
	self.viewportChanged:Disconnect()
	clearSlip(self)
	if self.alarmTween then
		self.alarmTween:Cancel()
		self.alarmTween = nil
	end
	self.border:Destroy()
	self.alarmLabel:Destroy()
	self.slipLabel:Destroy()
end

return Effects
