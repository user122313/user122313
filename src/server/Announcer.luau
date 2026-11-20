-- Server-wide announcements and the steal alarm for the victim.
-- The client (Hud.luau / Effects.luau) only displays what arrives here.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local AnnounceRules = require(Shared.AnnounceRules)
local Remotes = require(Shared.Remotes)

local Announcer = {}

-- A rare/legendary treasure was stolen: banner for everybody ("⚠ Alex stole the GOLDEN TOASTER!").
function Announcer.treasureStolen(thiefName: string, def: { name: string, rarity: string })
	if not AnnounceRules.shouldAnnounce(def.rarity) then
		return
	end
	Remotes.get("Announce"):FireAllClients(AnnounceRules.stolenText(thiefName, def.name), def.rarity)
end

-- Someone started stealing from this player: warning signal for the victim only.
function Announcer.stealAlarm(ownerId: number, thiefName: string)
	local owner = Players:GetPlayerByUserId(ownerId)
	if owner then
		Remotes.get("StealAlarm"):FireClient(owner, thiefName)
	end
end

return Announcer
