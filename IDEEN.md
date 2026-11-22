# IDEEN-PARKPLATZ

Neue Ideen kommen hierher, nicht ins Spiel. Höchstens eine pro Woche wird übernommen, frühestens nach dem Prüfpunkt in Woche 4 (Spec 5.4).

1. Mutationen (Farb-Varianten mit Einkommens-Bonus)
2. Schutzschild für den Bau (Mülltonnen-Deckel)
3. Events (Müllwagen-Streik), danach Rebirth
4. Lärm-Falle (klappernde Tonne)
5. Kein Pay-to-win, wenn Robux dann nur kosmetisch

## Map (Wunsch vom 20.11.2026, Samet)
- Größere Abstände zwischen den Häusern (Bauen). Technisch nur eine Zahl: `RADIUS` in `tools/BuildMap.luau` von 70 auf z. B. 90 erhöhen und das Skript in Studio neu laufen lassen (Bauten und Abladeplatz werden neu erzeugt; vorher handgemachte Änderungen an der Map gehen verloren). Dann Gegencheck: Tragetempo 12 gegen Lauftempo 16 muss immer noch knappe Verfolgungen ergeben. Entscheidung nach dem ersten Playtest mit Bilal in Woche 2.

## Weitere Fallen (Idee vom 20.11.2026, Samet: „mehrere kreative Fallen")
Gemeinsame Regeln: gleicher Ablauf wie die Bananenschale (kaufen, im eigenen Bau platzieren, Fremder löst aus), eigene Kosten, Maximalzahl, Ausnahme für den Besitzer. Reihenfolge nach Aufwand, einfachste zuerst.
- Kaugummi-Fleck: Fremder wird für ein paar Sekunden stark verlangsamt (nur WalkSpeed, sehr einfach)
- Mausefalle: hält den Dieb kurz fest (ca. 1.5 s), Beute bleibt in der Hand
- Mülltonnen-Deckel: schließt den Dieb für 3 s in einer Tonne ein, lustiger Clip
- Stinkbombe: grüne Wolke, alle Fremden im Radius sind verlangsamt und sehen schlechter
- Spring-Pilz / Katapult: schleudert den Dieb zurück aus dem Bau
- Fake-Schatz (Mimic): sieht aus wie ein seltener Schatz, beißt zu, wenn jemand klaut (braucht Anzeige und Balance)
- Klappernde Tonne (siehe 4): meldet dem Besitzer leise, wenn ein Fremder nahe kommt

## Upgrades im Stil von „Steal a Brainrot" (Idee vom 20.11.2026)
Kein Geld nötig, alles mit Kronkorken kaufbar. Ausbaustufe des Baus gibt es schon (Plan Task 11).
- Mehr Plätze im Bau (Stufe 3, 4 …) statt nur 2 Stufen
- Schnellere Beine (WalkSpeed +Prozent) und Tragetempo
- Zwei Schätze gleichzeitig tragen
- Kürzere Haltezeit beim Klauen (Gegenstück: Besitzer kann sie verlängern)
- Einkommen-Multiplikator für den Bau
- Bau-Schloss: Schutz für kurze Zeit mit langer Abklingzeit (siehe 2)
- Fallen-Upgrades: mehr Schalen, stärkerer Wurf, kürzere Abklingzeit
- Rebirth (siehe 3), erst wenn Spieler wiederkommen

Achtung: Jede dieser Ideen braucht UI (Codex), Server (Claude), Balance und Tests. Das ist Feature-Sammlung (Anti-Ziel in Spec Abschnitt 2), solange der Kernloop nicht im Playtest bewiesen ist.

## Shop-Tab und echte Käufe (Idee vom 22.11.2026)
- Shop-Tab im HUD mit 2 bis 3 Angeboten: Extra-Plätze (Game Pass), Kronkorken-Paket (Developer Product). Keine Zufalls-Käufe.
- Vorher: Altersfreigabe-Fragebogen neu ausfüllen, Regeln für minderjährige Creator klären. Recherche: `docs/recherche-map-und-shop.md`.
- Erst nach dem Playtest, nicht vor Woche 4.
