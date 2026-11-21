# Auftrag für Codex: Client-Funde aus deinem eigenen Review (`Hud.luau`)

**Ziel:** Zwei kleine Funde aus deinem Client-Review beheben. Nur das, nichts daneben. Wenn du auch den Auftrag `docs/codex-hud-politur.md` bekommst: **zuerst diesen hier**, danach die Politur auf dem Ergebnis aufbauen.

**Vorher lesen:** `STATUS.md`, `docs/codex-review-ergebnis.md` (Abschnitt Client), `src/client/Hud.luau`.

## Regeln
Wie in `docs/codex-hud-politur.md`: nur `src/client`, Texte Englisch, Werte aus `Theme.luau`, keine neuen RemoteEvents, E nur fürs Klauen, F für Grab/Drop, kein Text unter 22 px, STEAL-Button (`TextScaled`, 92 bis 112 px, eine Zeile) bleibt. Du kannst Studio nicht starten: kleine Schritte, jede Änderung kurz erklären.

## Fund 1: Banner-Warteschlange ohne Obergrenze (`Hud.announce`, ca. Zeile 310 bis 342)
Kommen viele verschiedene Meldungen schnell hintereinander, wächst `pending` ohne Grenze und neue Banner erscheinen sehr spät.
Gewünscht (kleine Verhaltensentscheidung, ich schlage vor):
- `pending` höchstens **4** Einträge. Ist sie voll, wird zuerst der **älteste `common`-Eintrag** entfernt, damit der neue Platz findet. `rare`/`legendary` (Ansagen für alle) werden **nie** für `common` verdrängt, sie sind wichtiger.
- Sind nur `rare`/`legendary` in der Schlange und sie ist voll, wird der älteste verworfen.
- Die bestehende Regel (gleicher `common`-Text direkt nacheinander wird zusammengefasst) bleibt.
- Die Anzeigezeiten (1,85 s / 2,85 s) bleiben.

## Fund 2: Footer gegen STEAL-Button im kleinen Querformat (`layout`, ca. Zeile 196 bis 216)
Bei 568 mal 320 (iPhone SE quer) endet der Footer (Balken/Einführung) bei etwa x = 381, der STEAL-Button beginnt bei etwa x = 362, beide unten. Sie können sich überschneiden.
Gewünscht: Im `shortWide`-Fall den Footer so schmaler oder weiter links setzen, dass er **links vom STEAL-Button** endet (Footer-Rechtskante kleiner als Button-Linkskante, mit etwa 8 px Abstand), ohne dass der Footer-Text unter 22 px rutscht. Rechne mit der echten Buttonbreite (`stealButton.AbsoluteSize.X`), nicht mit einer festen Zahl, und rufe `layout` bei Größenänderung wie bisher auf.
Nicht ändern: Position und Größe des STEAL-Buttons selbst, Joystick- und Sprungknopf-Freiraum.

## Abgabe
- `Hud.luau` **vollständig** zurück (Datei oder ein Codeblock mit Dateinamen).
- Kurze Liste: was geändert, warum, plus **Studio-Prüfliste** (Claude prüft im Emulator 568 mal 320 quer, iPhone XR quer und hoch, und feuert 10 Meldungen schnell hintereinander).
- Wünsche an Server oder `Theme.luau` getrennt aufführen.
