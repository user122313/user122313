-- Paste into the Studio command bar in EDIT mode (not while playing).
-- Rebuilds Workspace.Bases (Base1..Base6) and Workspace.DumpSite from scratch.
-- Lines starting with "--" are removed before pasting; do not add comments inside the code.
local Workspace = game:GetService("Workspace")
local COUNT = 6
local RADIUS = 70
for _, name in { "Bases", "DumpSite" } do
	local old = Workspace:FindFirstChild(name)
	if old then
		old:Destroy()
	end
end
local function makePart(parent, name, size, cframe, color)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Anchored = true
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local colors = {
	Color3.fromRGB(231, 76, 60),
	Color3.fromRGB(52, 152, 219),
	Color3.fromRGB(46, 204, 113),
	Color3.fromRGB(241, 196, 15),
	Color3.fromRGB(155, 89, 182),
	Color3.fromRGB(230, 126, 34),
}
local wallColor = Color3.fromRGB(120, 120, 125)
local folder = Instance.new("Folder")
folder.Name = "Bases"
folder.Parent = Workspace
for i = 1, COUNT do
	local angle = math.rad((i - 1) * (360 / COUNT))
	local pos = Vector3.new(RADIUS * math.sin(angle), 0.5, RADIUS * math.cos(angle))
	local origin = CFrame.lookAt(pos, Vector3.new(0, 0.5, 0))
	local base = Instance.new("Model")
	base.Name = "Base" .. i
	base:SetAttribute("BaseLevel", 1)
	local floor = makePart(base, "Floor", Vector3.new(30, 1, 30), origin, colors[i])
	makePart(base, "WallLeft", Vector3.new(1, 6, 30), origin * CFrame.new(-14.5, 3.5, 0), wallColor)
	makePart(base, "WallRight", Vector3.new(1, 6, 30), origin * CFrame.new(14.5, 3.5, 0), wallColor)
	makePart(base, "WallBack", Vector3.new(28, 6, 1), origin * CFrame.new(0, 3.5, 14.5), wallColor)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.CFrame = origin * CFrame.new(0, 1, -9)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Transparency = 0.5
	spawn.Color = Color3.fromRGB(255, 255, 255)
	spawn.Parent = base
	for s = 1, 8 do
		local row = if s <= 4 then 8 else 1
		local col = ((s - 1) % 4) * 6 - 9
		local slot = makePart(
			base,
			"Slot" .. s,
			Vector3.new(5, 0.2, 5),
			origin * CFrame.new(col, 0.6, row),
			if s <= 4 then Color3.fromRGB(240, 220, 120) else Color3.fromRGB(150, 135, 70)
		)
		slot:SetAttribute("MinLevel", if s <= 4 then 1 else 2)
	end
	base.PrimaryPart = floor
	base.Parent = folder
end
local dump = Instance.new("Model")
dump.Name = "DumpSite"
local disc = makePart(
	dump,
	"Floor",
	Vector3.new(1, 30, 30),
	CFrame.new(0, 0.5, 0) * CFrame.Angles(0, 0, math.rad(90)),
	Color3.fromRGB(90, 90, 95)
)
disc.Shape = Enum.PartType.Cylinder
local drop = makePart(dump, "DropPoint", Vector3.new(2, 2, 2), CFrame.new(0, 4, 0), Color3.fromRGB(255, 255, 255))
drop.Transparency = 1
drop.CanCollide = false
dump.PrimaryPart = disc
dump.Parent = Workspace
print("Map built: 6 bases + DumpSite")
