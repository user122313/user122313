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
