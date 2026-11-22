local Config = require(script.Parent.Config)

local ShieldRules = {}

local function isNumber(v: any): boolean
	return type(v) == "number" and v == v
end

-- Is the shield on? shieldUntil = time it ends (0 or nil = never switched on).
function ShieldRules.isActive(now: number, shieldUntil: number?): boolean
	if not isNumber(now) or not isNumber(shieldUntil) then
		return false
	end
	return now < (shieldUntil :: number)
end

-- May the pad be used? readyAt = time it works again (nil = never used).
function ShieldRules.canActivate(now: number, readyAt: number?): boolean
	if not isNumber(now) then
		return false
	end
	if not isNumber(readyAt) then
		return true
	end
	return now >= (readyAt :: number)
end

-- Times after switching the shield on at `now`: when it ends, and when the pad can be used again.
function ShieldRules.activate(now: number): { shieldUntil: number, readyAt: number }
	return {
		shieldUntil = now + Config.SHIELD_SECONDS,
		readyAt = now + Config.SHIELD_SECONDS + Config.SHIELD_COOLDOWN,
	}
end

-- Is a player standing on the pad? Offsets are player root minus pad center (studs).
function ShieldRules.onPad(dx: number, dy: number, dz: number): boolean
	if not isNumber(dx) or not isNumber(dy) or not isNumber(dz) then
		return false
	end
	return math.sqrt(dx * dx + dz * dz) <= Config.SHIELD_PAD_RADIUS and math.abs(dy) <= 6
end

return ShieldRules
