-- Pure rules for server-wide announcements (no Roblox needed, tested with Lune).
local AnnounceRules = {}

-- Only exciting steals are shouted to everybody (common steals stay quiet).
function AnnounceRules.shouldAnnounce(rarity: string): boolean
	return rarity == "rare" or rarity == "legendary"
end

-- "⚠ Alex stole the GOLDEN TOASTER!"
function AnnounceRules.stolenText(thiefName: string, treasureName: string): string
	return `⚠ {thiefName} stole the {string.upper(treasureName)}!`
end

return AnnounceRules
