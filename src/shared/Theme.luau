-- Gemeinsamer Look für alle UI-Teile. Farben als {R, G, B} (0-255),
-- im Client mit Color3.fromRGB(unpack(farbe)) verwenden.
return {
	colors = {
		background = { 34, 40, 38 }, -- dunkles Graugrün (Mülltonne)
		panel = { 52, 61, 58 },
		text = { 255, 248, 230 }, -- warmes Weiß
		accent = { 255, 153, 0 }, -- Orange: Kronkorken, Hauptakzent
		good = { 120, 220, 110 }, -- Erfolg
		danger = { 235, 70, 60 }, -- Warnung, Klau-Alarm
		rare = { 80, 170, 255 },
		legendary = { 255, 205, 40 },
	},
	font = "FredokaOne", -- Enum.Font.FredokaOne; Fallback: GothamBold
	cornerRadius = 12, -- Pixel für UICorner
	strokeThickness = 3,
	-- Mindestgrößen für Handy-Lesbarkeit
	textSize = { hud = 28, banner = 34, hint = 22 },
}
