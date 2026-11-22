-- Paste into the Studio command bar in EDIT mode (not while playing). Run AFTER BuildMap and DecorateMap.
-- Adds junkyard atmosphere in Workspace.Junk: trash mountains, wrecks, tire stacks, pallets, puddles,
-- steam vents, neon signs and dust. Only decoration, no game logic. Safe to run again (rebuilds Workspace.Junk).
local Workspace = game:GetService("Workspace")
local old = Workspace:FindFirstChild("Junk")
if old then
	old:Destroy()
end
local junk = Instance.new("Folder")
junk.Name = "Junk"
junk.Parent = Workspace
local rng = Random.new(21)
local function part(name, size, cframe, color, material, shape, collide)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Anchored = true
	p.Color = color
	p.Material = material or Enum.Material.Metal
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		p.Shape = shape
	end
	p.CanCollide = collide ~= false
	p.Parent = junk
	return p
end
local function polar(radius, degrees, y)
	local a = math.rad(degrees)
	return Vector3.new(radius * math.sin(a), y, radius * math.cos(a))
end
local upright = CFrame.Angles(0, 0, math.rad(90))
local function randomRotation()
	return CFrame.Angles(math.rad(rng:NextNumber(0, 360)), math.rad(rng:NextNumber(0, 360)), math.rad(rng:NextNumber(0, 360)))
end
local palette = {
	Color3.fromRGB(140, 85, 60),
	Color3.fromRGB(90, 95, 60),
	Color3.fromRGB(170, 155, 125),
	Color3.fromRGB(110, 112, 118),
	Color3.fromRGB(80, 100, 125),
	Color3.fromRGB(150, 70, 65),
	Color3.fromRGB(60, 45, 40),
}
local function pick()
	return palette[rng:NextInteger(1, #palette)]
end

local function wreck(origin)
	part("WreckBody", Vector3.new(9, 2.4, 4.2), origin * CFrame.new(0, 2.2, 0), Color3.fromRGB(130, 80, 60), Enum.Material.CorrodedMetal)
	part("WreckCabin", Vector3.new(4.6, 1.8, 3.8), origin * CFrame.new(-0.6, 4.2, 0), Color3.fromRGB(105, 70, 55), Enum.Material.CorrodedMetal)
	part("WreckWindow", Vector3.new(4.7, 1, 3.9), origin * CFrame.new(-0.6, 4.4, 0), Color3.fromRGB(60, 75, 90), Enum.Material.Glass).Transparency = 0.4
	for _, x in { -3, 3 } do
		for _, z in { -2.3, 2.3 } do
			part("WreckWheel", Vector3.new(0.9, 2.2, 2.2), origin * CFrame.new(x, 1.1, z) * CFrame.Angles(math.rad(90), 0, 0) * upright, Color3.fromRGB(28, 28, 30), Enum.Material.Rubber, Enum.PartType.Cylinder)
		end
	end
end

local function fridge(origin)
	part("Fridge", Vector3.new(3, 6, 3), origin * CFrame.new(0, 3, 0), Color3.fromRGB(205, 205, 200), Enum.Material.Metal)
	part("FridgeDoorLine", Vector3.new(3.05, 0.15, 3.05), origin * CFrame.new(0, 4.2, 0), Color3.fromRGB(90, 90, 90), Enum.Material.Metal, nil, false)
	part("FridgeHandle", Vector3.new(0.3, 1.4, 0.3), origin * CFrame.new(1.2, 3.4, -1.6), Color3.fromRGB(70, 70, 75), Enum.Material.Metal, nil, false)
end

local function mattress(origin)
	part("Mattress", Vector3.new(6, 0.9, 3.4), origin * CFrame.new(0, 0.45, 0), Color3.fromRGB(150, 140, 120), Enum.Material.Fabric)
	part("MattressStripe", Vector3.new(6.05, 0.95, 0.8), origin * CFrame.new(0, 0.46, 0), Color3.fromRGB(120, 80, 70), Enum.Material.Fabric, nil, false)
end

local function barrel(origin)
	part("Barrel", Vector3.new(3.2, 2.2, 2.2), origin * CFrame.new(0, 1.6, 0) * upright, Color3.fromRGB(70, 90, 70), Enum.Material.Metal, Enum.PartType.Cylinder)
	part("BarrelRing", Vector3.new(0.3, 2.3, 2.3), origin * CFrame.new(0, 1.6, 0) * upright, Color3.fromRGB(45, 55, 45), Enum.Material.Metal, Enum.PartType.Cylinder, false)
end

local function tireStack(origin, count)
	for t = 0, count - 1 do
		part("Tire", Vector3.new(1.3, 3.6, 3.6), origin * CFrame.new(rng:NextNumber(-0.2, 0.2), 0.65 + t * 1.3, rng:NextNumber(-0.2, 0.2)) * upright, Color3.fromRGB(28, 28, 30), Enum.Material.Rubber, Enum.PartType.Cylinder)
	end
end

local function mountain(center, spread)
	local radius = spread * 0.95
	local core = part("MountainCore", Vector3.new(radius * 2, radius * 2, radius * 2), CFrame.new(center + Vector3.new(0, -radius * 0.15, 0)), Color3.fromRGB(78, 64, 52), Enum.Material.Mud, Enum.PartType.Ball)
	part("MountainShoulder", Vector3.new(radius * 1.3, radius * 1.3, radius * 1.3), CFrame.new(center + Vector3.new(radius * 0.7, -radius * 0.2, radius * 0.4)), Color3.fromRGB(70, 58, 48), Enum.Material.Mud, Enum.PartType.Ball)
	local topY = core.Position.Y + radius
	for n = 1, 60 do
		local angle = rng:NextNumber(0, math.pi * 2)
		local dist = (rng:NextNumber() ^ 0.7) * radius * 0.92
		local surface = core.Position.Y + math.sqrt(math.max(radius * radius - dist * dist, 0))
		local size = rng:NextNumber(1.8, 4.2)
		local pos = Vector3.new(center.X + math.cos(angle) * dist, surface + size * 0.1, center.Z + math.sin(angle) * dist)
		local kind = rng:NextInteger(1, 4)
		if kind == 1 then
			part("Bag", Vector3.new(size, size * 0.9, size), CFrame.new(pos) * randomRotation(), Color3.fromRGB(26, 44, 32), Enum.Material.Plastic, Enum.PartType.Ball)
		elseif kind == 2 then
			part("Box", Vector3.new(size, size * 0.8, size * 1.2), CFrame.new(pos) * randomRotation(), Color3.fromRGB(175, 140, 95), Enum.Material.Cardboard)
		elseif kind == 3 then
			part("Scrap", Vector3.new(size * 1.6, 0.4, size), CFrame.new(pos) * randomRotation(), pick(), Enum.Material.CorrodedMetal)
		else
			part("Tire", Vector3.new(1.3, 3.2, 3.2), CFrame.new(pos) * randomRotation() * upright, Color3.fromRGB(28, 28, 30), Enum.Material.Rubber, Enum.PartType.Cylinder)
		end
	end
	fridge(CFrame.new(center.X + 1, topY - 0.5, center.Z) * CFrame.Angles(0, math.rad(rng:NextNumber(0, 360)), math.rad(rng:NextNumber(-12, 12))))
	mattress(CFrame.new(center.X - radius * 0.35, topY - radius * 0.35, center.Z + radius * 0.3) * CFrame.Angles(math.rad(rng:NextNumber(-25, 25)), math.rad(rng:NextNumber(0, 360)), math.rad(rng:NextNumber(-25, 25))))
	barrel(CFrame.new(center + Vector3.new(radius * 0.8, 0, -radius * 0.3)))
end

for k = 0, 5 do
	local deg = 30 + k * 60
	mountain(polar(103, deg, 0), 12)
	tireStack(CFrame.lookAt(polar(94, deg + 9, 0), Vector3.new(0, 0, 0)), rng:NextInteger(2, 4))
	for p = 0, 2 do
		part("Pallet", Vector3.new(4, 0.6, 4), CFrame.lookAt(polar(96, deg - 12 + p * 3, 0.3 + p * 0.6), Vector3.new(0, 0, 0)), Color3.fromRGB(150, 110, 70), Enum.Material.WoodPlanks)
	end
end

wreck(CFrame.lookAt(polar(112, 60, 0), Vector3.new(0, 0, 0)) * CFrame.Angles(0, math.rad(25), 0))
wreck(CFrame.lookAt(polar(112, 180, 0), Vector3.new(0, 0, 0)) * CFrame.Angles(0, math.rad(-15), math.rad(8)))
wreck(CFrame.lookAt(polar(112, 300, 0), Vector3.new(0, 0, 0)) * CFrame.Angles(0, math.rad(40), 0))
for k = 0, 5 do
	local deg = k * 60
	local sideDeg = deg + 22
	fridge(CFrame.new(polar(52, deg + 17, 1.2)) * CFrame.Angles(0, math.rad(rng:NextNumber(0, 360)), math.rad(rng:NextNumber(-85, -70))))
	for v = 1, 2 do
		local puddlePos = polar(rng:NextNumber(26, 46), deg + rng:NextNumber(18, 30) * (if v == 1 then 1 else -1), 0.06)
		local size = rng:NextNumber(4, 8)
		local puddle = part("Puddle", Vector3.new(0.1, size, size * rng:NextNumber(0.6, 1)), CFrame.new(puddlePos) * upright, Color3.fromRGB(62, 62, 66), Enum.Material.Glass, Enum.PartType.Cylinder, false)
		puddle.Transparency = 0.25
		puddle.Reflectance = 0.3
		puddle.CastShadow = false
	end
	local ventPos = polar(40, sideDeg, 0.15)
	part("Manhole", Vector3.new(0.3, 4, 4), CFrame.new(ventPos) * upright, Color3.fromRGB(55, 55, 60), Enum.Material.Metal, Enum.PartType.Cylinder, false)
	local anchor = part("VentAnchor", Vector3.new(1, 1, 1), CFrame.new(ventPos + Vector3.new(0, 1, 0)), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic, nil, false)
	anchor.Transparency = 1
	anchor.CanQuery = false
	local steam = Instance.new("ParticleEmitter")
	steam.Texture = "rbxasset://textures/particles/smoke_main.dds"
	steam.Rate = 5
	steam.Lifetime = NumberRange.new(2, 3.2)
	steam.Speed = NumberRange.new(3, 5)
	steam.SpreadAngle = Vector2.new(12, 12)
	steam.Color = ColorSequence.new(Color3.fromRGB(210, 210, 215))
	steam.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 4.5) })
	steam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 1) })
	steam.Parent = anchor
end

local signTexts = {
	{ "SCRAP", Color3.fromRGB(255, 70, 190) },
	{ "FREE STUFF", Color3.fromRGB(70, 230, 255) },
	{ "JUNK 24/7", Color3.fromRGB(255, 190, 60) },
	{ "NO THIEVES", Color3.fromRGB(255, 70, 70) },
}
for index, info in signTexts do
	local deg = 15 + (index - 1) * 90
	local origin = CFrame.lookAt(polar(118, deg, 0), Vector3.new(0, 0, 0))
	part("SignPostL", Vector3.new(0.6, 9, 0.6), origin * CFrame.new(-5, 4.5, 0.5), Color3.fromRGB(55, 57, 64), Enum.Material.Metal)
	part("SignPostR", Vector3.new(0.6, 9, 0.6), origin * CFrame.new(5, 4.5, 0.5), Color3.fromRGB(55, 57, 64), Enum.Material.Metal)
	local board = part("SignBoard", Vector3.new(12, 4, 0.5), origin * CFrame.new(0, 8, 0), Color3.fromRGB(20, 20, 24), Enum.Material.Metal)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.Parent = board
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = info[1]
	text.TextScaled = true
	text.Font = Enum.Font.FredokaOne
	text.TextColor3 = info[2]
	text.TextStrokeColor3 = info[2]
	text.TextStrokeTransparency = 0.6
	text.Parent = gui
	local glow = Instance.new("PointLight")
	glow.Color = info[2]
	glow.Range = 16
	glow.Brightness = 1.4
	glow.Parent = board
end

local dustAnchor = part("DustAnchor", Vector3.new(1, 1, 1), CFrame.new(0, 7, 0), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic, nil, false)
dustAnchor.Transparency = 1
dustAnchor.CanQuery = false
local dust = Instance.new("ParticleEmitter")
dust.Texture = "rbxasset://textures/particles/sparkles_main.dds"
dust.Rate = 6
dust.Lifetime = NumberRange.new(5, 8)
dust.Speed = NumberRange.new(0.5, 1.5)
dust.SpreadAngle = Vector2.new(180, 180)
dust.Color = ColorSequence.new(Color3.fromRGB(230, 200, 150))
dust.Size = NumberSequence.new(0.35)
dust.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.6), NumberSequenceKeypoint.new(1, 1) })
dust.Shape = Enum.ParticleEmitterShape.Box
dust.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
dust.Parent = dustAnchor
dustAnchor.Size = Vector3.new(40, 6, 40)

print("Junk built: " .. #junk:GetChildren() .. " parts")
