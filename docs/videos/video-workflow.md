# Video-Workflow Devlog (Kanal 1)

**Ziel:** Jede Woche ein Video, ohne dass du selbst stundenlang schneidest. Du **filmst und sprichst**, der Rest ist so weit wie möglich automatisiert.

**Ehrlich vorweg:**
- Ich (Claude) kann keine Videos schneiden. Ich kann dir Skripte schreiben, die den langweiligen Teil erledigen (Stille und Fehlversuche rausschneiden, Untertitel erzeugen), und ich schreibe dir Skript, Titel und Kapitelstruktur.
- Eine vollautomatische Pipeline liefert brauchbares, aber kein perfektes Video. Rechne mit **30–45 Minuten manueller Feinschliff** pro Video. Das ist Absicht: ein Mensch muss mindestens einmal drüberschauen, sonst landen peinliche Stellen online.
- Preise und Gratis-Grenzen der Tools ändern sich oft. Vor dem Kauf aktuell nachsehen. In den ersten 4 Wochen: nur Gratis-Tools.

## Zeitbudget pro Woche (bei 8–10 h)

| Schritt | Zeit |
|---|---|
| Aufnehmen (läuft nebenbei beim Arbeiten, OBS) | 0 extra |
| Voice-over sprechen | 20–30 min |
| Automatischer Rohschnitt | 10 min (Rechner arbeitet) |
| Feinschliff, Thumbnail, Upload | 60–90 min |
| **Gesamt** | **ca. 2 h = ~25 %** |

Wenn es mehr wird: Video kürzer machen, nicht Spiel-Zeit opfern (Spec: max. 30 % für Video).

## Ablauf

1. **Aufnehmen (OBS, Windows):**
   - Aufnahme-Qualität: MP4/MKV, 1080p, 30 fps. Gameplay und Studio als getrennte Szenen.
   - **Replay-Puffer (30–60 s) aktivieren:** Bei jedem lustigen Moment Taste drücken, dann ist der Clip schon gespeichert. Das ist dein Clip-Material für Shorts.
   - Ordner `D:\Devlog\Woche-N\rohmaterial\` (oder ähnlich) pro Woche.
2. **Skript (Claude, 10 min):** Du schickst mir deine Stichpunkte der Woche („was habe ich gebaut, was ging schief, was war lustig“). Ich schreibe daraus ein kurzes Sprecher-Skript (ca. 3–5 Minuten), einen Titel-Vorschlag mit 3 Varianten und eine Kapitelliste. **Gesprochen wird in deinen eigenen Worten**, das Skript ist nur die Stütze.
3. **Voice-over aufnehmen:** Skript vorlesen oder frei sprechen, zum Gameplay-Video (nicht live beim Spielen, sonst Chaos). Ein ruhiger Raum und ein Headset-Mikro reichen. Lieber zweimal sprechen als später reparieren.
4. **Automatischer Rohschnitt (Skript, das ich dir später in `tools/video/` baue, nur auf Wunsch):**
   - Stille und lange Pausen entfernen (Open-Source-Werkzeuge wie `auto-editor` bzw. `ffmpeg`).
   - Untertitel mit lokalem Spracherkennungsmodell (z. B. Whisper) erzeugen, damit nichts im Internet hochgeladen werden muss.
5. **Feinschliff (DaVinci Resolve oder CapCut, beides gratis):**
   - Gameplay-Clips auf die Sprecherstimme legen, Untertitel prüfen und Namen/Spielbegriffe korrigieren.
   - Hartes Qualitätstor: erste 10 Sekunden müssen ein Versprechen oder einen Gag enthalten (kein „Hallo Leute, heute…“).
6. **Thumbnail:** Spiel-Screenshot (gutes Standbild aus dem Clip) + 2–4 große Wörter. Bild in ChatGPT erzeugen oder bearbeiten ist ok, **Datei lokal speichern**.
7. **Upload:** Titel, Beschreibung, Kapitel, Link zum Spiel (ab Woche 4).

## Wochenstruktur des Videos (3–5 Minuten)

1. **Hook (0–10 s):** der lustigste Moment der Woche oder die Frage „Hat es funktioniert?“
2. **Ziel der Woche (10–30 s):** Was wollte ich bauen?
3. **Bauen und Scheitern (Hauptteil):** 2–3 echte Probleme, jeweils: Problem → Versuch → Ergebnis. Fehler sind erwünscht.
4. **Ergebnis (30 s):** spielbarer Stand, ein Clip.
5. **Ausblick (10 s):** Was kommt nächste Woche? Keine „liked und abonniert“-Litanei, ein Satz.

Themen pro Woche: siehe Spec Abschnitt 7 (W1: „noch nie ein Projekt beendet“, W2: Freunde testen, W3: kaputte Falle, W4: online + ehrliche Zahlen).

## Shorts (optional, ab Woche 2)

Pro Woche 1–2 Shorts aus den Replay-Puffer-Clips (max. 20 s, Text-Einblendung, stumm verständlich). Nur wenn das Hauptvideo schon fertig ist, nie davor.

## Wenn es zu viel wird

Reihenfolge der Kürzung: Shorts → Thumbnail-Feinarbeit → Untertitel → Video kürzer. **Nie ausfallen lassen:** das wöchentliche Hauptvideo (auch roh und kurz). Das ist dein Durchhalte-Mechanismus.

## Später (nicht jetzt)

- Schnitt bezahlen (Freelancer-Plattform), erst wenn der Kanal Einnahmen oder klaren Zuwachs hat.
- Kanal 2 für das Spiel erst nach dem Prüfpunkt nach 4 Wochen (Spec Abschnitt 8).
