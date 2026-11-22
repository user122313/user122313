-- Paste into the Studio command bar in EDIT mode (not while playing). Run AFTER BuildMap.
-- Only ADDS decoration (Workspace.Decor) and changes Material/Color of floors and walls and the lighting.
-- It never changes names, sizes, slots or attributes of bases, so all game logic keeps working. Safe to run again.
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local old = Workspace:FindFirstChild("Decor")
if old then
	old:Destroy()
end
local decor = Instance.new("Folder")
decor.Name = "Decor"
decor.Parent = Workspace
local rng = Random.new(7)
local baseColors = {
	Color3.fromRGB(231, 76, 60),
	Color3.fromRGB(52, 152, 219),
	Color3.fromRGB(46, 204, 113),
	Color3.fromRGB(241, 196, 15),
	Color3.fromRGB(155, 89, 182),
	Color3.fromRGB(230, 126, 34),
}
local function part(name, size, cframe, color, material, shape, collide)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Anchored = true
	p.Color = color
	p.Material = material or Enum.Material.Concrete
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		p.Shape = shape
	end
	p.CanCollide = collide ~= false
	p.Parent = decor
	return p
end
local function polar(radius, degrees, y)
	local a = math.rad(degrees)
	return Vector3.new(radius * math.sin(a), y, radius * math.cos(a))
end
local upright = CFrame.Angles(0, 0, math.rad(90))

local ground = Workspace:FindFirstChild("Baseplate")
if ground and ground:IsA("BasePart") then
	for _, child in ground:GetChildren() do
		if child:IsA("Texture") or child:IsA("Decal") then
			child:Destroy()
		end
	end
	ground.Material = Enum.Material.Asphalt
	ground.Color = Color3.fromRGB(62, 65, 72)
else
	part("Ground", Vector3.new(600, 1, 600), CFrame.new(0, -0.5, 0), Color3.fromRGB(62, 65, 72), Enum.Material.Asphalt)
end

for i = 1, 6 do
	local deg = (i - 1) * 60
	local color = baseColors[i]
	local pathPos = polar(35, deg, 0.25)
	part("Path" .. i, Vector3.new(10, 0.5, 42), CFrame.lookAt(pathPos, Vector3.new(0, 0.25, 0)), Color3.fromRGB(128, 126, 120), Enum.Material.Slate)
	local gateOrigin = CFrame.lookAt(polar(19, deg, 0), Vector3.new(0, 0, 0))
	part("GatePostL" .. i, Vector3.new(1.2, 9, 1.2), gateOrigin * CFrame.new(-6, 4.5, 0), Color3.fromRGB(70, 72, 80), Enum.Material.Metal)
	part("GatePostR" .. i, Vector3.new(1.2, 9, 1.2), gateOrigin * CFrame.new(6, 4.5, 0), Color3.fromRGB(70, 72, 80), Enum.Material.Metal)
	part("GateBar" .. i, Vector3.new(14, 1.4, 1.4), gateOrigin * CFrame.new(0, 9.2, 0), color, Enum.Material.Neon)

	local base = Workspace:FindFirstChild("Bases") and Workspace.Bases:FindFirstChild("Base" .. i)
	if base then
		local floor = base:FindFirstChild("Floor")
		if floor then
			floor.Material = Enum.Material.Concrete
		end
		for _, wallName in { "WallLeft", "WallRight", "WallBack" } do
			local wall = base:FindFirstChild(wallName)
			if wall and wall:IsA("BasePart") then
				wall.Material = Enum.Material.Brick
				wall.Color = Color3.fromRGB(138, 100, 88)
				part(
					"Trim",
					wall.Size + Vector3.new(0.4, 0, 0.4) - Vector3.new(0, wall.Size.Y - 0.6, 0),
					wall.CFrame * CFrame.new(0, wall.Size.Y / 2 + 0.3, 0),
					color,
					Enum.Material.SmoothPlastic,
					nil,
					false
				)
			end
		end
	end

	local lampSide = if i % 2 == 0 then 7 else -7
	for _, radius in { 30, 46 } do
		local lampOrigin = CFrame.lookAt(polar(radius, deg, 0), Vector3.new(0, 0, 0))
		local pole = part("LampPole", Vector3.new(0.6, 9, 0.6), lampOrigin * CFrame.new(lampSide, 4.5, 0), Color3.fromRGB(55, 57, 64), Enum.Material.Metal)
		local head = part("LampHead", Vector3.new(1.8, 1.8, 1.8), pole.CFrame * CFrame.new(0, 5, 0), Color3.fromRGB(255, 220, 150), Enum.Material.Neon, Enum.PartType.Ball, false)
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 215, 150)
		light.Range = 22
		light.Brightness = 1.3
		light.Parent = head
	end

	local dumpDeg = deg + 30
	local dumpOrigin = CFrame.lookAt(polar(23, dumpDeg, 0), Vector3.new(0, 0, 0))
	part("Dumpster", Vector3.new(7, 4, 4), dumpOrigin * CFrame.new(0, 2.5, 0), Color3.fromRGB(48, 110, 72), Enum.Material.Metal)
	part("DumpsterLid", Vector3.new(7.3, 0.5, 4.3), dumpOrigin * CFrame.new(0, 4.75, 0) * CFrame.Angles(math.rad(-8), 0, 0), Color3.fromRGB(30, 70, 48), Enum.Material.Metal)
	for t = 0, 1 do
		part("Tire", Vector3.new(1.3, 3.6, 3.6), dumpOrigin * CFrame.new(5.5, 0.65 + t * 1.3, 0.5) * upright, Color3.fromRGB(28, 28, 30), Enum.Material.Rubber, Enum.PartType.Cylinder)
	end
	for b = 1, 3 do
		part(
			"TrashBag",
			Vector3.new(2.4, 2.4, 2.4),
			dumpOrigin * CFrame.new(-5 + b * 0.9 - 2, 1.2, 3 + rng:NextNumber(-0.6, 0.6)),
			Color3.fromRGB(26, 44, 32),
			Enum.Material.Plastic,
			Enum.PartType.Ball
		)
	end
end

local FENCE_COUNT = 36
for k = 0, FENCE_COUNT - 1 do
	local deg = k * (360 / FENCE_COUNT)
	local height = rng:NextNumber(13, 19)
	local shade = rng:NextInteger(95, 135)
	local rust = rng:NextInteger(0, 1) == 1
	part(
		"Fence",
		Vector3.new(23, height, 2),
		CFrame.lookAt(polar(125, deg, height / 2), Vector3.new(0, height / 2, 0)),
		if rust then Color3.fromRGB(shade + 20, shade - 20, shade - 45) else Color3.fromRGB(shade, shade, shade + 6),
		Enum.Material.CorrodedMetal
	)
end
for n = 1, 70 do
	local deg = rng:NextNumber(0, 360)
	local radius = rng:NextNumber(100, 118)
	local size = rng:NextNumber(1.5, 3.2)
	if rng:NextInteger(0, 2) == 0 then
		part("Crate", Vector3.new(size, size, size), CFrame.new(polar(radius, deg, size / 2)) * CFrame.Angles(0, math.rad(rng:NextNumber(0, 90)), 0), Color3.fromRGB(150, 110, 70), Enum.Material.WoodPlanks)
	else
		part("Bag", Vector3.new(size, size, size), CFrame.new(polar(radius, deg, size / 2)), Color3.fromRGB(26, 44, 32), Enum.Material.Plastic, Enum.PartType.Ball)
	end
end

local signAnchor = part("SignAnchor", Vector3.new(1, 1, 1), CFrame.new(0, 34, 0), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic, nil, false)
signAnchor.Transparency = 1
signAnchor.CanQuery = false
local sign = Instance.new("BillboardGui")
sign.Size = UDim2.fromOffset(520, 110)
sign.AlwaysOnTop = false
sign.MaxDistance = 400
sign.Parent = signAnchor
local signText = Instance.new("TextLabel")
signText.Size = UDim2.fromScale(1, 1)
signText.BackgroundTransparency = 1
signText.Text = "TRASH BANDITS"
signText.TextScaled = true
signText.Font = Enum.Font.FredokaOne
signText.TextColor3 = Color3.fromRGB(255, 153, 0)
signText.TextStrokeTransparency = 0
signText.Parent = sign

Lighting.ClockTime = 17.2
Lighting.Brightness = 2.4
Lighting.Ambient = Color3.fromRGB(95, 95, 115)
Lighting.OutdoorAmbient = Color3.fromRGB(110, 105, 125)
Lighting.ColorShift_Top = Color3.fromRGB(255, 205, 160)
for _, className in { "Atmosphere", "BloomEffect", "ColorCorrectionEffect" } do
	local existing = Lighting:FindFirstChildOfClass(className)
	if existing then
		existing:Destroy()
	end
end
local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.28
atmosphere.Offset = 0.2
atmosphere.Color = Color3.fromRGB(255, 205, 170)
atmosphere.Decay = Color3.fromRGB(190, 140, 120)
atmosphere.Haze = 1.2
atmosphere.Parent = Lighting
local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.35
bloom.Size = 22
bloom.Threshold = 1.6
bloom.Parent = Lighting
local grade = Instance.new("ColorCorrectionEffect")
grade.Saturation = 0.18
grade.Contrast = 0.08
grade.Parent = Lighting
print("Decor built: " .. #decor:GetChildren() .. " parts")
