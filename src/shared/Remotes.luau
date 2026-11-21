-- Names of all RemoteEvents. The server creates them, the client looks them up.
-- Every message from the client is a REQUEST, never a fact (see spec 6.1).
local Remotes = {}

Remotes.names = {
	"HudUpdate", -- server -> client: caps, income
	"Announce", -- server -> all clients: banner text, rarity
	-- Pickup and place are NOT remotes: they run through ProximityPrompts on the server.
	"RequestStealStart",
	"RequestStealCommit",
	"RequestBuyBanana",
	"RequestPlaceBanana",
	"RequestUpgradeBase",
	"Slipped", -- server -> client: slip duration
	"StealAlarm", -- server -> owner: thiefName (someone started stealing from you)
}

local FOLDER_NAME = "Remotes"

local function isKnown(name: string): boolean
	return table.find(Remotes.names, name) ~= nil
end

-- Server only: creates ReplicatedStorage.Remotes with one RemoteEvent per name.
function Remotes.create(): Folder
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local existing = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
	if existing then
		existing:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = FOLDER_NAME
	for _, name in Remotes.names do
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	folder.Parent = ReplicatedStorage
	return folder
end

-- Server and client: returns the RemoteEvent (client waits until it exists).
function Remotes.get(name: string): RemoteEvent
	if not isKnown(name) then
		error(`Unknown remote: {name}`)
	end
	local folder = game:GetService("ReplicatedStorage"):WaitForChild(FOLDER_NAME)
	return folder:WaitForChild(name) :: RemoteEvent
end

return Remotes
