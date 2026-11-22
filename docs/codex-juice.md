# Auftrag für Codex: Spielgefühl ("Juice"), Effekte, Sounds, HUD

**Warum:** Der erste Spieltest sagt: Die Logik funktioniert, aber das Spiel ist langweilig. Es fehlen kräftige Drop-Animationen, Sounds und ein HUD mit Wumms. Das ist jetzt dein Bereich. Der Server liefert die Ereignisse, du machst daraus ein Erlebnis.

**Vorher lesen:** `STATUS.md` (Abschnitte "Optik-Durchgang" und "Auto-Ablegen und Schild"), `docs/art-direction.md` (Stil: gedämpfte Umgebung, **knallige Schätze, Fallen, UI**, Sättigung = Wert), `docs/codex-hud-politur.md` (Regeln und Handy-Fixes, die du nicht rückgängig machen darfst), `src/shared/Theme.luau`, deine Dateien in `src/client`.

## Regeln (wie bisher)
- Nur `src/client` (neue Dateien darin sind erlaubt). Nichts in `src/server`, `src/shared`, `tests`, `place`, `tools`. Wünsche an den Server oder an `Theme.luau` getrennt aufschreiben.
- Alle sichtbaren Texte Englisch. Farben, Schrift, Radius aus `Theme.luau`.
- Der Client entscheidet nichts. Keine neuen RemoteEvents, nur die vorhandenen lesen.
- Taste E ist nur für Klauen, F nur für Aufheben im Müllhaufen. **Es gibt keine Taste mehr fürs Ablegen** (siehe unten).
- Handy zuerst: Aktionsbuttons bleiben frei von Joystick und Sprungknopf, kein Text unter 22 px, STEAL-Button wie bisher.
- Leistung: Partikel sparsam (wenige Emitter, kurze Lebensdauer), keine Dauer-Effekte auf jedem Schatz. Auf dem Handy muss es flüssig bleiben.
- Du kannst Studio nicht starten. Kleine Schritte, jede Änderung kurz erklären, Studio-Prüfliste mitliefern.

## Neu auf dem Server (22.11.2026)
1. **Auto-Ablegen:** Wer einen Schatz trägt und seinen Bau betritt, legt ihn automatisch in einen freien Platz. Der Hinweis "Drop here" (F) ist weg. Dein Hinweistext "Grab trash in the middle" bleibt richtig, der Text zum Ablegen darf aus den Einführungshinweisen verschwinden oder zu "Carry it into your base" werden.
2. **Schild:** In jedem Bau liegt vorne rechts ein Schild-Knopf (Pad, `ShieldPad`). Wer als Besitzer darauf läuft, schaltet **10 Sekunden** Schild ein, in denen niemand aus diesem Bau klauen kann. Danach lädt der Knopf **45 Sekunden** auf. Das Schild ist ein halbtransparentes Feld über dem Bau (macht der Server). Spielerfeedback kommt als `Announce`: "Shield on for 10 seconds!", "Shield is down!", und beim Dieb "That base is shielded!".
3. **Neues Ereignis `Fx`** (`RemoteEvent` in `ReplicatedStorage.Remotes`, vom Server an alle Clients): `OnClientEvent(kind: string, position: Vector3, rarity: string)`.

| `kind` | wann | Hinweis |
|---|---|---|
| `"pickup"` | Spieler hebt Müll am Haufen auf | `position` = Schatz, `rarity` = `"common"`, `"rare"`, `"legendary"` |
| `"steal"` | Dieb hat geklaut | wie pickup, aber Klau |
| `"place"` | Schatz liegt im Bau (auch automatisch) | `position` = Platz im Bau |
| `"shield_on"` | Schild geht an | `position` = Mitte des Baus, `rarity` leer |
| `"shield_off"` | Schild ist aus | wie oben |

Zusätzlich vorhanden: `Slipped`, `StealAlarm`, `HudUpdate`, `Announce`. Attribut am Bau-Model `ShieldUntil` (Serverzeit, `workspace:GetServerTimeNow()`), solange `ShieldUntil > jetzt` ist das Schild aktiv. Damit kannst du einen Countdown im HUD zeigen (Bau des Spielers: `workspace.Bases` Kind mit `OwnerUserId == LocalPlayer.UserId`).

## Was gebaut werden soll (in dieser Reihenfolge, nimm nur, was du sicher kannst)
1. **Drop-Animation beim Ablegen (`place`):** Der Schatz soll sichtbar in den Platz fallen (z. B. aus 6 Studs, mit Aufprall/Bounce in ca. 0,4 s), dazu Stoßwelle (Neonring, der sich ausdehnt), Funken oder Kronkorken-Partikel. **Stärker je Seltenheit:** `common` klein, `rare` blauer Blitz und Ring, `legendary` goldene Lichtsäule, kurzer Bildschirm-Blitz und Kamerawackeln. Wichtig: das echte Schatz-Model nicht dauerhaft verschieben (der Server besitzt es). Zeig besser einen **rein visuellen Klon** oder einen Effekt über dem Platz.
2. **Aufheben und Klauen (`pickup`, `steal`):** kleiner Hüpfer und Glanz, bei `steal` zusätzlich roter Blitz und Alarmton. Die Dieb-Markierung und der Alarm für den Besitzer existieren schon, nur schöner machen.
3. **Kronkorken-Zähler:** größere Pop-Animation, bei Ablegen eines Schatzes "+X" aufsteigen lassen.
4. **Schild:** `shield_on`: Welle über dem Bau, kurzer Ton, im HUD ein Schildsymbol mit Countdown (Sekunden), bei `shield_off` abklingen. Für den Dieb: Wenn er an einem geschützten Bau steht, ein klarer Hinweis (kommt schon als `Announce`).
5. **Sounds:** Lege eine Datei `src/client/Sounds.luau` an: eine Tabelle mit Namen zu `SoundId`-Werten (zunächst leer, `""`) und eine Funktion `play(name)`, die bei leerer ID still bleibt. Die echten IDs trägt der Nutzer später ein (Quelle noch offen, Roblox prüft Uploads auf Urheberrecht). Benötigte Namen: `pickup`, `place_common`, `place_rare`, `place_legendary`, `steal`, `alarm`, `slip`, `caps`, `upgrade`, `shield_on`, `shield_off`, `truck`.
6. **HUD-Redesign (klein halten):** Der Kronkorken-Zähler soll wie das Hauptstück wirken (größer, Glanz, Rahmen). Einheitliche Form: abgerundet, klare Kontraste. Die Einführungshinweise anpassen (kein Ablegen per Taste mehr, Schild-Knopf erwähnen).

## Nicht jetzt
Keine neuen Menüs, kein Shop, keine Waschbär-Grafiken, keine neuen Remotes, keine Änderungen an Server oder Spielregeln.

## Abgabe
- Die geänderten und neuen Dateien **vollständig** zurück (Datei oder Codeblock mit Dateinamen).
- Kurze Liste: was geändert wurde und warum, dazu eine **Studio-Prüfliste** (was Claude im Studio und im Handy-Emulator prüfen soll).
- Wünsche an Server oder `Theme.luau` getrennt aufführen.
