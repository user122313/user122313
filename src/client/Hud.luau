-- Builds the responsive HUD and the touch controls from the shared theme.
-- Animates server-provided values and banners, and forwards button presses.
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")

local Config = require(Shared.Config)
local Theme = require(Shared.Theme)

local Hud = {}
local hasThemeFont, themeFont = pcall(function()
	return Enum.Font[Theme.font]
end)
local FONT = hasThemeFont and themeFont or Enum.Font.GothamBold
local COLORS: { [string]: Color3 } = {}
for name, rgb in Theme.colors do
	COLORS[name] = Color3.fromRGB(table.unpack(rgb))
end

local function roundCorners(gui: GuiObject)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Theme.cornerRadius)
	corner.Parent = gui
end

local function pad(gui: GuiObject, horizontal: number, vertical: number)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, horizontal)
	padding.PaddingRight = padding.PaddingLeft
	padding.PaddingTop = UDim.new(0, vertical)
	padding.PaddingBottom = padding.PaddingTop
	padding.Parent = gui
end

local function stack(parent: GuiObject, gap: number)
	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, gap)
	layout.Parent = parent
end

local function limitSize(gui: GuiObject, maxWidth: number, maxHeight: number?)
	local constraint = Instance.new("UISizeConstraint")
	constraint.MaxSize = Vector2.new(maxWidth, maxHeight or math.huge)
	constraint.Parent = gui
end

local function frame(parent: Instance, name: string, order: number, color: Color3?): Frame
	local gui = Instance.new("Frame")
	gui.Name = name
	gui.BackgroundTransparency = if color then 0 else 1
	if color then
		gui.BackgroundColor3 = color
	end
	gui.BorderSizePixel = 0
	gui.LayoutOrder = order
	gui.Size = UDim2.fromScale(1, 0)
	gui.AutomaticSize = Enum.AutomaticSize.Y
	gui.Parent = parent
	return gui
end

local function label(parent: Instance, name: string, order: number, value: string, size: number, color: Color3): TextLabel
	local gui = Instance.new("TextLabel")
	gui.Name = name
	gui.LayoutOrder = order
	gui.BackgroundTransparency = 1
	gui.Size = UDim2.fromScale(1, 0)
	gui.AutomaticSize = Enum.AutomaticSize.Y
	gui.Font = FONT
	gui.Text = value
	gui.TextColor3 = color
	gui.TextSize = size
	gui.TextWrapped = true
	gui.Parent = parent
	return gui
end

local function button(parent: GuiObject, name: string, order: number, value: string): TextButton
	local gui = Instance.new("TextButton")
	gui.Name = name
	gui.LayoutOrder = order
	gui.Size = UDim2.new(1, 0, 0, 54)
	gui.BackgroundColor3 = COLORS.panel
	gui.BorderSizePixel = 0
	gui.Font = FONT
	gui.Text = value
	gui.TextColor3 = COLORS.text
	gui.TextSize = Theme.textSize.hint
	gui.TextWrapped = true
	roundCorners(gui)
	pad(gui, 7, 0)
	gui.Parent = parent
	return gui
end

type Announcement = { text: string, rarity: string }

function Hud.new(player: Player, playerGui: PlayerGui, buyBanana: () -> (), placeBanana: () -> (), upgradeBase: () -> ())
	local gui = Instance.new("ScreenGui")
	gui.Name = "MuellbanditenHud"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 10
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets

	local viewport = frame(gui, "Viewport", 0)
	viewport.AutomaticSize = Enum.AutomaticSize.None
	viewport.Size = UDim2.fromScale(1, 1)

	local header = frame(viewport, "Header", 1)
	header.AnchorPoint = Vector2.new(0.5, 0)
	header.Position = UDim2.fromScale(0.5, 0.02)
	header.ZIndex = 4
	limitSize(header, 660)
	stack(header, 6)

	local counter = frame(header, "BottleCaps", 1, COLORS.background)
	limitSize(counter, 230)
	roundCorners(counter)
	pad(counter, 8, 4)
	stack(counter, 0)
	label(counter, "Caption", 1, "BOTTLE CAPS", Theme.textSize.hint, COLORS.text)
	local capsLabel = label(counter, "Amount", 2, "—", Theme.textSize.hud + 8, COLORS.accent)
	local incomeLabel = label(counter, "Income", 3, "+—/s", Theme.textSize.hint, COLORS.good)

	local banner = frame(header, "Announcement", 2, COLORS.panel)
	banner.Visible = false
	roundCorners(banner)
	pad(banner, 10, 4)
	local bannerText = label(banner, "Message", 1, "", Theme.textSize.banner, COLORS.text)

	local actions = frame(viewport, "BaseActions", 2)
	limitSize(actions, 218)
	stack(actions, 5)
	local stockPanel = frame(actions, "BananaStock", 1, COLORS.background)
	roundCorners(stockPanel)
	pad(stockPanel, 6, 4)
	local stock = label(stockPanel, "Stock", 1, "Bananas: —", Theme.textSize.hint, COLORS.text)
	local buy = button(actions, "BuyBanana", 2, string.format("Buy banana (%d)", Config.BANANA_COST))
	local place = button(actions, "PlaceBanana", 3, "Place banana")
	local upgrade = button(actions, "UpgradeBase", 4, string.format("Upgrade base (%d)", Config.UPGRADE_COST))

	local footer = frame(viewport, "Footer", 3)
	footer.AnchorPoint = Vector2.new(0.5, 1)
	footer.ZIndex = 2
	limitSize(footer, 480)
	stack(footer, 5)

	local hint = frame(footer, "Introduction", 1, COLORS.background)
	roundCorners(hint)
	pad(hint, 7, 5)
	stack(hint, 3)
	local hintText = label(hint, "Tip", 1, "", Theme.textSize.hint, COLORS.text)
	local skip = button(hint, "SkipTips", 2, "Skip")
	skip.Size = UDim2.new(0.65, 0, 0, 44)
	limitSize(skip, 104)

	local keyboardHint = label(footer, "KeyboardSteal", 2, "Hold E to steal", Theme.textSize.hint, COLORS.text)
	keyboardHint.BackgroundColor3 = COLORS.background
	keyboardHint.BackgroundTransparency = 0
	keyboardHint.Visible = false
	roundCorners(keyboardHint)
	pad(keyboardHint, 5, 4)

	local progress = frame(footer, "StealProgress", 3, COLORS.background)
	progress.Visible = false
	roundCorners(progress)
	pad(progress, 8, 6)
	stack(progress, 4)
	label(progress, "Caption", 1, "STEALING…", Theme.textSize.hint, COLORS.text)
	local track = frame(progress, "Track", 2, COLORS.panel)
	track.AutomaticSize = Enum.AutomaticSize.None
	track.Size = UDim2.new(1, 0, 0, 13)
	roundCorners(track)
	local fill = frame(track, "Fill", 1, COLORS.accent)
	fill.AutomaticSize = Enum.AutomaticSize.None
	fill.Size = UDim2.fromScale(0, 1)
	roundCorners(fill)

	local stealButton = button(viewport, "StealTouch", 4, "STEAL")
	stealButton.AnchorPoint = Vector2.new(1, 1)
	stealButton.Size = UDim2.fromScale(0.23, 0.24)
	stealButton.BackgroundColor3 = COLORS.accent
	stealButton.TextColor3 = COLORS.background
	stealButton.TextSize = Theme.textSize.hud
	stealButton.Visible = false
	stealButton.ZIndex = 3
	local buttonSize = Instance.new("UISizeConstraint")
	buttonSize.MinSize = Vector2.new(72, 72)
	buttonSize.MaxSize = Vector2.new(100, 100)
	buttonSize.Parent = stealButton
	local buttonRatio = Instance.new("UIAspectRatioConstraint")
	buttonRatio.AspectRatio = 1
	buttonRatio.Parent = stealButton

	-- The touch layout keeps the actions clear of the jump button and thumbstick.
	local function layout()
		local view = viewport.AbsoluteSize
		local shortWide = view.Y < 440 and view.X >= view.Y * 1.55
		local portrait = view.X < view.Y
		local touch = UserInputService.TouchEnabled
		header.Size = UDim2.fromScale(if shortWide then 0.38 else 0.94, 0)
		counter.Size = UDim2.fromScale(if shortWide then 0.9 elseif portrait then 0.62 else 0.52, 0)
		actions.AnchorPoint = Vector2.new(if touch then 0 else 1, 0)
		actions.Position = UDim2.fromScale(if touch then 0.02 else 0.98, if shortWide then 0.03 elseif portrait then 0.30 else 0.2)
		actions.Size = UDim2.fromScale(if shortWide then 0.27 elseif portrait then 0.46 else 0.32, 0)
		footer.Position = UDim2.fromScale(0.5, 0.97)
		footer.Size = UDim2.fromScale(if shortWide then 0.34 else 0.62, 0)
		stealButton.Position = if shortWide then UDim2.fromScale(0.8, 0.95) else UDim2.fromScale(0.98, 0.77)
	end

	local displayedCaps = Instance.new("NumberValue")
	displayedCaps.Parent = counter
	local capsTween: Tween?
	local progressTween = TweenService:Create(fill, TweenInfo.new(Config.STEAL_HOLD, Enum.EasingStyle.Linear), {
		Size = UDim2.fromScale(1, 1),
	})
	local previousCaps: number?
	local pending: { Announcement } = {}
	local active: Announcement?
	local bannerTask: thread?
	local hintTask: thread?
	local hintIndex = 1
	local hintMessages = {
		"Grab trash in the middle",
		"Hold E at another base to steal",
		"Buy banana peels to stop thieves",
	}

	local function updateBananas()
		local count = player:GetAttribute("Bananas")
		stock.Text = if typeof(count) == "number" then string.format("Bananas: %d", count) else "Bananas: —"
	end

	local function updateBase()
		local level = player:GetAttribute("BaseLevel")
		upgrade.Visible = typeof(level) == "number" and level < 2
	end

	local function updateTip()
		hintText.Text = if hintIndex == 2 and UserInputService.PreferredInput == Enum.PreferredInput.Touch
			then "Hold STEAL at another base to steal"
			else hintMessages[hintIndex]
	end

	local function hideTips()
		hint.Visible = false
		if hintTask then
			task.cancel(hintTask)
			hintTask = nil
		end
	end

	local connections = {
		viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout),
		player:GetAttributeChangedSignal("Bananas"):Connect(updateBananas),
		player:GetAttributeChangedSignal("BaseLevel"):Connect(updateBase),
		UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateTip),
		buy.Activated:Connect(buyBanana),
		place.Activated:Connect(placeBanana),
		upgrade.Activated:Connect(upgradeBase),
		skip.Activated:Connect(hideTips),
		displayedCaps.Changed:Connect(function(value)
			capsLabel.Text = tostring(math.round(value))
		end),
	}

	local hud = { gui = gui, stealButton = stealButton }

	function hud.setMoney(caps: number, incomePerSec: number)
		incomeLabel.Text = "+" .. tostring(incomePerSec) .. "/s"
		if previousCaps == caps then
			return
		end
		if capsTween then
			capsTween:Cancel()
			capsTween = nil
		end
		if previousCaps and caps > previousCaps then
			local tween = TweenService:Create(displayedCaps, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { Value = caps })
			capsTween = tween
			tween:Play()
		else
			displayedCaps.Value = caps
			capsLabel.Text = tostring(caps)
		end
		previousCaps = caps
	end

	function hud.setStealProgress(visible: boolean)
		progressTween:Cancel()
		progress.Visible = visible
		fill.Size = UDim2.fromScale(0, 1)
		if visible then
			progressTween:Play()
		end
	end

	function hud.setKeyboardHint(visible: boolean)
		keyboardHint.Visible = visible
	end

	function hud.announce(message: string, rarity: string)
		local last = pending[#pending] or active
		if rarity == "common" and last and last.rarity == rarity and last.text == message then
			return
		end
		table.insert(pending, { text = message, rarity = rarity })
		if bannerTask then
			return
		end

		-- Keep simultaneous messages legible by giving each its own display time.
		bannerTask = task.defer(function()
			while #pending > 0 do
				local item = table.remove(pending, 1)
				active = item
				local special = item.rarity == "rare" or item.rarity == "legendary"
				banner.BackgroundColor3 = if special then COLORS[item.rarity] else COLORS.panel
				bannerText.TextColor3 = if special then COLORS.background else COLORS.text
				bannerText.Text = item.text
				banner.BackgroundTransparency = 1
				bannerText.TextTransparency = 1
				banner.Visible = true

				local fade = TweenInfo.new(0.15)
				TweenService:Create(banner, fade, { BackgroundTransparency = 0 }):Play()
				TweenService:Create(bannerText, fade, { TextTransparency = 0 }):Play()
				task.wait(if special then 2.85 else 1.85)
				TweenService:Create(banner, fade, { BackgroundTransparency = 1 }):Play()
				TweenService:Create(bannerText, fade, { TextTransparency = 1 }):Play()
				task.wait(fade.Time)
			end
			active = nil
			banner.Visible = false
			bannerTask = nil
		end)
	end

	function hud.destroy()
		hideTips()
		progressTween:Destroy()
		if bannerTask then
			task.cancel(bannerTask)
		end
		if capsTween then
			capsTween:Cancel()
		end
		for _, connection in connections do
			connection:Disconnect()
		end
		gui:Destroy()
	end

	updateBananas()
	updateBase()
	updateTip()
	hintTask = task.spawn(function()
		for index = 2, #hintMessages do
			task.wait(8)
			hintIndex = index
			updateTip()
		end
		task.wait(8)
		hint.Visible = false
		hintTask = nil
	end)

	gui.Parent = playerGui
	layout()
	return hud
end

return Hud
