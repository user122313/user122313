# Playtest-Checkliste (Woche 2, mit Bilal und wenn möglich 2 bis 4 weiteren)

**Ziel:** herausfinden, ob der Kern „klauen, tragen, verteidigen“ Spaß macht und ob Fremde ihn in 30 Sekunden ohne Erklärung verstehen. Nicht: Fehler suchen im Code (das kommt nebenbei).
**Voraussetzung:** Codex-UI ist drin, das Spiel ist privat veröffentlicht, API-Zugriff ist an (sonst wird nichts gespeichert). Mindestens 3 Spieler, besser 4 bis 6. Mit zwei Spielern funktioniert der Loop kaum.

## Vorbereitung konkret (Stand 22.11.2026)
Reihenfolge, damit nichts schiefgeht. Die Klickpfade sind nur teilweise gegen die echte Oberfläche geprüft, Abweichungen bitte hier notieren.
1. **Aktuelle Version veröffentlichen (du):** In Studio **Datei, Auf Roblox veröffentlichen** (Spiel „Trash Bandits“ auswählen, überschreiben). Strg+S speichert nur einen Entwurf, Tester sehen sonst eventuell die alte Version. Das Spiel bleibt privat.
2. **Selbsttest in der Roblox-App (du, 10 Minuten, allein):** Mit deinem Konto das Spiel starten. Prüfen: lädt ohne Fehler, eigener Bau, Müll aufheben (Taste F) und ablegen, Kronkorken steigen. Dann **Spiel verlassen und neu betreten**: sind die Kronkorken noch da? Das ist der erste Test des echten Speicherns auf einem echten Server.
3. **Tester einladen (du):** Creator Dashboard, Trash Bandits, **Veröffentlichungseinstellungen, Zielgruppe verwalten, Vorabtester einladen**. Ob Tester auf deiner Freundesliste sein müssen, ist ungeprüft. Wer keinen Zugriff hat, schreibt dir das.
4. **Mindestens 3 Spieler** (Bilal plus 2). Server fasst höchstens 6 (Limit ist gesetzt).
5. **Ein Tester am Handy**, wenn möglich. Handy-Leistung ist bisher nicht auf einem echten Gerät geprüft.
6. **Vorher sagen:** Prototyp, normale Roblox-Figuren (keine Waschbären), keine Sounds, Fehler sind erwartet. Sonst bewerten sie das Falsche.
7. **Aufnahme:** OBS mit Replay-Puffer, Hotkey vorher testen.

## Vorbereitung (15 Minuten)
- [ ] Spiel privat veröffentlicht, Bilal und die anderen als Tester eingeladen
- [ ] OBS läuft, Replay-Puffer (30 bis 60 s) an, Hotkey getestet
- [ ] Du selbst spielst mit, aber hältst dich mit Erklärungen zurück
- [ ] Zettel oder Handy-Notizen für Beobachtungen
- [ ] Mindestens ein Tester am Handy (falls möglich)
- [ ] `STATUS.md` offen, damit du Bugs direkt notieren kannst

## Ablauf (ca. 30 Minuten)
1. **Erste 30 Sekunden ohne Erklärung.** Sag nur: „Spiel einfach.“ Beobachte schweigend:
   - Wer findet den Müllwagen-Platz? Wer hebt etwas auf?
   - Wer legt den Schatz in den eigenen Bau? Wie lange dauert das?
   - Versteht jemand das Klauen ohne Hinweis?
2. **10 Minuten freies Spielen.** Nichts erklären. Markiere dir Momente mit Lachen, Fluchen, Frust.
3. **5 Minuten gezielt:** Sag allen: „Versucht jetzt, einen seltenen Schatz zu klauen und legt eine Bananenschale aus.“ So testest du beide Kernsysteme sicher.
4. **Pause, dann 10 Minuten weiter.** Jetzt zeigt sich, ob die Lust bleibt.
5. **Fragen am Ende** (jeden einzeln, nicht in der Gruppe, sonst antworten alle gleich):
   1. Was war der lustigste Moment?
   2. Was war nervig oder unklar?
   3. Beschreib das Spiel einem Freund in einem Satz. (Wenn die Antwort „wie Steal a Brainrot, nur mit Müll“ ist, notiere es wörtlich. Das ist das Klon-Risiko aus der Spec.)
   4. Würdest du es nochmal spielen? Würdest du einen Freund einladen?
   5. Wo ist es zu schwer, zu leicht, zu langsam?

## Was du beobachten sollst (ohne zu fragen)
| Frage | Gutes Zeichen | Schlechtes Zeichen |
|---|---|---|
| Verständlich in 30 s? | klaut oder legt aus, ohne Hilfe | steht herum, fragt „was soll ich tun?“ |
| Wird geklaut? | jemand klaut in den ersten 5 Minuten | niemand traut sich oder merkt es nicht |
| Gibt es knappe Jagden? | Dieb fast zu Hause, Besitzer fast dran | Dieb entkommt immer oder wird immer sofort gefangen |
| Bananenschale lustig? | Lachen, Wiederholung | wird ignoriert oder ist unfair |
| Leerlauf? | immer etwas los | lange Wartezeit auf Müll |
| Handy? | Klau-Taste leicht zu halten | Taste verdeckt etwas oder reagiert nicht |
| Clip-tauglich? | ein 5-Sekunden-Clip ohne Ton ist verständlich | man versteht den Clip nur mit Erklärung |

## Prüfpunkte aus der Spec (Abschnitt 8), die dieser Test schon liefert
- [ ] Niemand beschreibt es ausschließlich als „Brainrot“
- [ ] Mindestens 2 Tester wollen ungefragt nochmal spielen oder laden jemanden ein
- [ ] Du willst selbst weitermachen

## Bug-Liste (laufend ausfüllen, danach in `STATUS.md` übernehmen)
| Was passierte | Wer, wann | Wiederholbar? |
|---|---|---|
| | | |

## Stellschrauben nach dem Test
Nur ändern, was du beobachtet hast. Eine Zahl pro Runde, dann neu testen.

| Beobachtung | Zahl drehen | Wo steht sie |
|---|---|---|
| Dieb wird immer gefangen / entkommt immer | Tragetempo `CARRY_SPEED` (12) gegen `WALK_SPEED` (16) | `src/shared/Config.luau` |
| Klauen fühlt sich zu leicht/schwer an | Haltezeit `STEAL_HOLD` (1.5 s), Reichweite `STEAL_REACH` (8) | `Config.luau` |
| Besitzer fängt Dieb zu leicht | `OWNER_TOUCH_RADIUS` (5) | `Config.luau` |
| Dieb gleich wieder klauen zu schnell | `STEAL_COOLDOWN` (3 s) | `Config.luau` |
| Geklauter Schatz kommt zu schnell/spät zurück | `DROP_RETURN` (10 s) | `Config.luau` |
| Zu wenig/zu viel Müll | `DUMP_INTERVAL` (20 s), `DUMP_DESPAWN` (60 s), Seltenheit `DUMP_WEIGHTS` | `Config.luau` |
| Zu wenig/zu viel Geld | `INCOME` je Seltenheit, `BANANA_COST` (50), `UPGRADE_COST` (500) | `Config.luau` |
| Bananenschale zu hart/zu schwach | `SLIP_SECONDS` (2 s), `MAX_BANANAS` (3), Wurf `FLING_UP`/`FLING_AWAY` | `Config.luau`, `src/server/TrapService.luau` |
| Wege zu kurz/zu lang | `RADIUS` (70) | `tools/BuildMap.luau` (Skript neu laufen lassen) |

Sag mir einfach „Test hat gezeigt: …“, dann drehe ich die passende Zahl und teste sie.

## Danach
- [ ] Ergebnisse in `STATUS.md`
- [ ] Beste 3 Clips aus dem Replay-Puffer sichern (für das Woche-2-Video)
- [ ] Entscheidung: Map-Abstände ändern? (siehe `IDEEN.md`)
- [ ] Eine Idee aus `IDEEN.md` übernehmen, höchstens eine, und nur wenn der Wochenplan erfüllt ist
