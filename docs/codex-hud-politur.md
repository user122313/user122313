# Auftrag für Codex: HUD-Politur (klein und sicher)

**Ziel:** Das HUD soll besser aussehen und sich besser anfühlen, ohne dass etwas kaputtgeht. Es funktioniert schon (in Studio mit echter Eingabe und im Handy-Emulator geprüft). Du darfst es also nur verbessern, nicht neu bauen.

**Vorher lesen:** `STATUS.md` (Abschnitte „Codex-UI eingebaut" und „Handy-Test"), `docs/ui/brief.md`, `src/shared/Theme.luau`, deine vier Dateien in `src/client/`.

## Regeln
- Ändere nur `src/client/Hud.luau`, `Effects.luau`, `StealController.luau`, `Main.client.luau`. Nichts in `src/server`, `src/shared`, `tests`, `place`.
- Alle sichtbaren Texte **Englisch**. Farben, Schrift, Radius nur aus `Theme.luau`. Fehlt dir ein Wert, schreib ihn als Wunsch auf, erfinde keinen.
- Der Client entscheidet nichts. Keine neuen RemoteEvents.
- **Taste E ist nur für das Klauen, Grab und Drop sind auf F.** Das darfst du nicht ändern (Roblox-Hinweise gewinnen immer gegen eine geteilte Taste).
- Diese Handy-Fixes **nicht rückgängig machen:** STEAL-Button mit `TextScaled`, Größe 92 bis 112 px, Text auf einer Zeile; kein Text unter `Theme.textSize.hint` (22); Joystick und Sprungknopf bleiben frei; nichts Wichtiges in der Bildschirmmitte.
- Du kannst Studio nicht starten. Darum: kleine Schritte, jede Änderung kurz erklären, nichts „nebenbei" umbauen.

## Was du verbessern darfst (in dieser Reihenfolge, nimm nur, was du sicher kannst)
1. **Kronkorken-Zähler:** kurzes „Pop" (leichtes Skalieren) beim Steigen, bei Ausgaben anderer Effekt oder Farbe. Der Zähler zählt schon animiert hoch.
2. **Banner:** klarere Unterschiede je Seltenheit (`common`, `rare`, `legendary`), zum Beispiel Rahmen oder Streifen in der Seltenheitsfarbe. Lesbarkeit geht vor Deko.
3. **Buttons:** Druck-Feedback (kurz kleiner und wieder zurück), deaktiviert aussehen, wenn die Aktion nicht geht (zum Beispiel Kauf ohne genug Kronkorken nur optisch, der Server entscheidet weiter allein).
4. **Klau-Balken:** weicher füllen, bei Abbruch kurz zurückfahren statt springen.
5. **Alarm und SLIPPED:** kleine Feinheiten, solange sie nichts verdecken.
6. **Einführungshinweise:** schöner einblenden, weiter überspringbar, höchstens 3, nur die erste Minute.

## Nicht jetzt
Keine neuen Funktionen, keine neuen Menüs, keine Sounds (die Dateien fehlen), kein Shop, keine Waschbär-Grafiken, keine Änderungen an der Spielregel.

## Abgabe
- Die geänderten Dateien **vollständig** zurück (als Dateien oder je ein Codeblock mit Dateinamen).
- Eine kurze Liste: was geändert wurde und warum, und eine **Studio-Prüfliste** (was Claude in Studio und im Handy-Emulator prüfen soll).
- Wünsche an den Server oder an `Theme.luau` getrennt aufführen.
