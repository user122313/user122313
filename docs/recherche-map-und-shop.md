# Recherche: Map-Design, Shop und Käufe (22.11.2026)

Gesucht im Web am 22.11.2026. Offizielle Roblox-Doku zählt mehr als Foren und Blogs. Vieles zu Steal-Spielen kommt aus Meinungsartikeln, nicht aus Messdaten. **Nichts davon ist umgesetzt.** Umfang laut Spec 5.4 gilt bis Woche 4, neue Ideen stehen auch in `IDEEN.md`.

## Map und Optik
- **Graybox zuerst, dann Kunst** (Roblox-Doku, [Grayboxing](https://create.roblox.com/docs)): Layout und Spielgefühl testen, erst danach die Platzhalter ersetzen. Unser Stand ist genau diese Graybox. Die Logik testen war also richtig, jetzt kommt der Kunst-Durchgang.
- **Layout steuert, wohin Spieler laufen:** Rampen, Engstellen, Höhenunterschiede (Artikel zu Steal a Brainrot, Meinung). Offene Fläche führt zu Gedränge. Für uns: der Abladeplatz in der Mitte, Wege zu den 6 Bauen.
- **Landmarken:** Spieler sollen immer etwas Auffälliges sehen, keine leeren Flächen ([DevForum-Level-Guide](https://devforum.roblox.com/t/first-person-shooter-map-design-in-roblox-picture-heavy/25475)). Jeder Bau hat schon eine eigene Farbe, das ist ein Anfang.
- **Fair und symmetrisch:** Alle Baue gleich gut (haben wir, 6 im Kreis).
- **Erkennbare Schätze:** eigene Silhouette, klare Farbpalette, aus der Ferne lesbar. Unsere Schätze sind aktuell weiße Würfel. Das ist der größte Schwachpunkt.
- **Wenig Teile, dafür klar:** vorgefertigte Umgebungen mit wenigen Teilen statt Dekor ohne Zweck ([Fehler von Neulingen](https://payhip.com/SupremeTech/blog/news/5-mistakes-new-roblox-developers-make-when-creating-maps)).
- **Lücke:** Zu Licht, Farbe und Low-Poly-Kunst in Roblox habe ich keine brauchbare Quelle gefunden.

## Shop und Käufe
- **Zwei Arten** ([Roblox Monetarisierung](https://create.roblox.com/docs/production/monetization)): Game Pass = einmal kaufen, dauerhaft (z. B. Extra-Platz, doppelte Kronkorken). Developer Product = mehrfach kaufbar (z. B. Kronkorken-Pakete, Bananen).
- **Einnahmen:** Von jedem Verkauf im eigenen Spiel bekommt der Creator 70 % der ausgegebenen Robux (Roblox-Doku).
- **Ehrlich präsentieren:** keine erfundenen Rabatte oder falsche Verknappung. Schlechte Taktiken führen zu Daumen runter (Roblox-Doku, [Monetization foundations](https://create.roblox.com/docs/production/game-design/monetization-foundations)).
- **Shop-Grundsatz laut Doku:** Items sollen integriert, passend zur Situation und einladend wirken. Genaue UI-Vorgaben habe ich nicht gefunden.
- **Zufalls-Items (Loot-Boxen):** Wer sie für Robux anbietet, muss die Wahrscheinlichkeiten zeigen und `PolicyService` beachten, sonst ist das Spiel in manchen Ländern für unter 18 gesperrt ([Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items)). Empfehlung: keine Zufalls-Käufe einbauen.
- **Altersfreigabe ändern:** Im Fragebogen haben wir „Digitale Käufe: Nein“ angegeben. **Sobald echte Käufe im Spiel sind, muss der Fragebogen neu ausgefüllt werden.**
- **Nicht geprüft:** Was ein Minderjähriger als Creator beachten muss (Auszahlung, Steuern, Alter). Das vor dem ersten Verkauf klären.

## Vorschlag für die Reihenfolge (zur Entscheidung des Nutzers)
1. Optik-Durchgang in kleinen Schritten: Schätze mit Form und Farbe, Boden und Wände mit Material statt Grau, Beschriftung repariert (doppelte „Pizza Box“).
2. Erst nach dem Playtest in Woche 2 bis 4: Shop-Tab mit 2 bis 3 Angeboten (z. B. Extra-Plätze als Game Pass, Kronkorken-Paket als Developer Product). Vorher klären, ob Käufe zum Umfang gehören.
