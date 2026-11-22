local Config = require(script.Parent.Config)

export type DepositInfo = {
	carrying: boolean,
	insideBase: boolean,
	slipping: boolean,
	secondsSinceTry: number,
}

local DepositRules = {}

-- Should the server try to put the carried treasure into the player's base right now?
-- True while carrying inside the own base, not slipping, and the last try is at least DEPOSIT_RETRY old.
-- Broken input never deposits.
function DepositRules.shouldDeposit(info: DepositInfo): boolean
	if type(info) ~= "table" then
		return false
	end
	local since = info.secondsSinceTry
	if type(since) ~= "number" or since ~= since then
		return false
	end
	if not info.carrying or not info.insideBase or info.slipping then
		return false
	end
	return since >= Config.DEPOSIT_RETRY
end

return DepositRules
