# STATUS

- **Was geht:** Repo-Gerüst, Rojo-Projektdatei, Test-Runner (Lune), alle reinen Regeln mit 68 grünen Tests: Wirtschaft/Katalog, Klau-Prüfungen, Fallen, Spielstand-Format, Ausbau.
- **Toolchain (20.11.2026, Laptop):** Rokit 1.2.0, Rojo 7.7.1, Lune 0.11.1 installiert, `rokit.toml` im Repo, Rojo-Plugin in Studio installiert. Projektordner: `C:\Users\samet\Muellbanditen`.
- **Task 1 fertig (20.11.2026):** Baseplate als `place/Muellbanditen.rbxl` gespeichert, Rojo verbunden, Play zeigt Server- und Client-Print.
- **Task 3 fertig (20.11.2026):** Map (6 Baue im Kreis, Abladeplatz) per `tools/BuildMap.luau` erzeugt, `BaseService` + `Remotes` laufen. Studio-Test mit 3 Spielern: jeder bekam einen eigenen Bau (Base1/2/3), nach dem Verlassen waren sie wieder frei (Server-Log bestätigt). Noch offen: `MaxPlayers = 6` kann erst beim Veröffentlichen gesetzt werden (Task 12).
- **Task 4 Server-Teil fertig (20.11.2026):** `TreasureService` (Müllwagen alle 20 s, Aufheben/Ablegen per ProximityPrompt statt eigener Client-Taste, Einkommen, Start-Schatz, Rückkehr). Server-Check in Studio grün: Aufheben, Tempo 12/16, Ablegen nur im eigenen Bau, voller Bau lehnt ab, Kronkorken steigen, Respawn mit Schatz legt ihn zurück, unabgeholter Schatz verschwindet nach 60 s. Schatz-Modelle werden aus dem Katalog im Code gebaut (kein ServerStorage-Ordner, keine Studio-Assets).
- **Offen für Task 4:** `Hud.luau` (Codex, liest `HudUpdate(caps, incomePerSec)`; Hinweise kommen als `Announce(text, "common")` an den einzelnen Spieler). Client-Empfang von `HudUpdate` noch nicht sichtbar getestet, weil das HUD fehlt.
- **Task 6 Server-Teil fertig (20.11.2026):** `StealService` (Opus-Agent geschrieben, von Claude geprüft). Studio-Check mit 3 Spielern, alle Punkte grün: Commit ohne Start abgelehnt, kaputte Eingaben ohne Fehler, Klau nach 1.5 s, Besitz bleibt beim Opfer bis zum Ablegen, danach Besitzwechsel in einem Schritt, zu kurz/zu weit/Timeout, zwei Diebe gleichzeitig (nur der erste bekommt den Schatz), Besitzer in der Nähe lässt Beute fallen und sie kehrt nach 10 s zurück, Tod/Verlassen des Diebs bringt den Schatz zurück, Besitzer geht = Schatz weg und Dieb frei, Abkühlzeit, voller Bau.
- **Nicht getestet:** Tempo-Check (`too_fast`) einzeln (nur über Teleport ohne `too_far` nicht isolierbar), Handy-Bedienung, echtes Halten der Taste E (kommt mit Codex `StealController`). Abbruch geht über zu frühes `RequestStealCommit` (kein eigenes Cancel-Event): Codex muss beim Loslassen Commit senden.
- **Als Nächstes:** HUD und `StealController` durch Codex, dann Task 7 (Bananenschale).
- **Blockiert:** Alles mit Roblox Studio braucht deinen Laptop.

- **Creator-Name (entschieden):** `SamyDev` (überall gleich: Roblox, YouTube, TikTok, Instagram). Verfügbarkeit noch prüfen; wenn belegt, überall dieselbe Variante.
- **Sprache:** alles Englisch (Spiel, Videos, Kanäle).
