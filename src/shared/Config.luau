-- Alle Spielzahlen an einer Stelle. Hier darfst du Werte selbst ändern.
return {
	MAX_PLAYERS = 6,

	-- Müllwagen
	DUMP_INTERVAL = 20, -- Sekunden zwischen Lieferungen
	DUMP_DESPAWN = 60, -- Sekunden bis herumliegender Müll verschwindet
	DUMP_WEIGHTS = { common = 70, rare = 25, legendary = 5 },

	-- Klauen
	STEAL_HOLD = 1.5, -- Sekunden Taste halten
	STEAL_HOLD_TOLERANCE = 0.2, -- Netzwerk-Toleranz (Server misst die Zeit)
	STEAL_REACH = 8, -- Studs
	STEAL_COOLDOWN = 3, -- Sekunden zwischen zwei Klauen
	WALK_SPEED = 16,
	CARRY_SPEED = 12, -- knapp unter Laufgeschwindigkeit: knappe Verfolgungen
	MAX_MOVE_SPEED = 30, -- darüber: Verdacht auf Cheat
	DROP_RETURN = 10, -- Sekunden bis ein fallengelassener Schatz zurückkehrt
	STEAL_LOCK_TIMEOUT = 4, -- seconds until an unfinished steal frees the treasure again
	OWNER_TOUCH_RADIUS = 5, -- studs: owner this close to the thief makes the loot fall
	OWNER_TOUCH_CHECK = 0.1, -- seconds between owner-touch checks
	TELEPORT_SLACK = 10, -- studs a carrier may jump between two checks on top of MAX_MOVE_SPEED (falls, lag)
	STEAL_RETRY_DELAY = 1, -- seconds a thief must wait after a failed steal start, times the number of failures in a row
	STEAL_RETRY_MAX_STEPS = 5, -- the wait grows at most this many steps
	STEAL_FAIL_MEMORY = 30, -- seconds without a failed start until the failure count starts again
	ALARM_INTERVAL = 4, -- seconds between two steal alarms for the same owner

	-- Fallen
	BANANA_COST = 50,
	MAX_BANANAS = 3,
	SLIP_SECONDS = 2,

	-- Wirtschaft
	INCOME = { common = 1, rare = 4, legendary = 15 }, -- Kronkorken pro Sekunde
	BASE_CAPACITY = { 4, 8 }, -- Plätze je Ausbaustufe
	UPGRADE_COST = 500,

	-- Speichern
	AUTOSAVE_SECONDS = 120,
}
