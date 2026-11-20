# UI-Auftrag für Codex (Client-Dateien)

**Du besitzt nur:** `src/client/Hud.luau`, `src/client/Effects.luau`, `src/client/StealController.luau`, `src/client/Main.client.luau`.
**Nicht anfassen:** `src/server/*`, `src/shared/*` (außer lesen). Brauchst du etwas Neues (Datenfeld, Event), schreib es als Wunsch an den Nutzer, erfinde nichts.

## Stil
Spielname: Müllbanditen (englischer Titel folgt). Waschbären, Müll, Slapstick. Alle sichtbaren Texte **Englisch**, kurz, laut, übertrieben. Farben, Schrift, Radius: `src/shared/Theme.luau` verwenden, keine eigenen Farbwerte im UI-Code. Dicke Schrift, große Zahlen, starker Kontrast. Muss am **Handy** gut lesbar sein (kleiner Bildschirm, Daumen).

## UI wird per Code gebaut
`Hud.luau` erzeugt das ScreenGui und alle Elemente selbst (kein Studio-Klicken). Animationen über `TweenService`. Layout mit `UIListLayout`/`UIAspectRatioConstraint`, nicht mit festen Pixelpositionen. Auf Handy und PC testbar (Studio-Geräteemulator).

## Elemente
1. **Bottle caps counter** (oben mittig): Zahl der Kronkorken, Zahl zählt animiert hoch. Darunter klein „+X/s“.
2. **Steal bar** (unten mittig): Fortschrittsbalken beim Halten der Klau-Taste (1.5 s). Beim Abbruch zurücksetzen.
3. **Steal button (Touch)**: großer Button unten rechts, nur auf Touch-Geräten sichtbar; gedrückt halten = klauen. PC: Taste E.
4. **Alarm** beim Besitzer: roter Rand blinkt kurz + Text „SOMEONE IS STEALING!“.
5. **Announce banner** (oben, 3 s): z. B. „⚠ Alex stole the GOLDEN TOASTER!“, Farbe nach Seltenheit (`rare`, `legendary`).
6. **Slip text**: „SLIPPED!“ groß in der Mitte, kurzes Kamera-Wackeln.
7. **Hints** (nur erste Minute, überspringbar, max. 3): „Grab trash in the middle“, „Hold E at another base to steal“, „Buy banana peels to stop thieves“.
8. **Banana buttons** (klein, am Rand, Daumen-tauglich): „Buy banana (50)“ und „Place banana“ mit Anzeige, wie viele Schalen im Vorrat sind (Attribut `Bananas` am Spieler). Gedacht für PC und Handy.
9. **Upgrade button** (klein, am Rand): „Upgrade base (500)“ sendet `RequestUpgradeBase()` (ohne Argumente). Nur sichtbar, solange `LocalPlayer:GetAttribute("BaseLevel")` kleiner als 2 ist (Attribut am Spieler, Änderungen per `GetAttributeChangedSignal`). Kosten stehen in `Config.UPGRADE_COST`. Erfolg und Fehler kommen als `Announce` (z. B. „Base upgraded! More room for trash!“, `rare`).

## Daten, die der Server schickt (RemoteEvents in `ReplicatedStorage.Remotes`)
- `HudUpdate(caps: number, incomePerSec: number)`
- `Announce(text: string, rarity: "common" | "rare" | "legendary")`
- `StealAlarm(thiefName: string)` (nur an den Besitzer, sobald jemand bei ihm zu klauen beginnt; Element 4)
- `Slipped(seconds: number)`
- Der Client schickt nur Bitten: `RequestStealStart(treasureId: string)`, `RequestStealCommit(treasureId: string)`. Zeit und Ergebnis entscheidet der Server, der Client zeigt nur an.

## Fertig, wenn
- Alle 7 Elemente funktionieren in Studio-Play, auf PC **und** Handy-Emulator.
- Kein Text kleiner als `Theme.textSize`, nichts verdeckt die Spielfläche in der Mitte.
- Jede Datei hat oben einen 2-Zeilen-Kommentar, was sie tut (der Nutzer liest nicht Code, aber ich muss ihn prüfen können).
