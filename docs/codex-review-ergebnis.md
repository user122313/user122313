# Codex-Reviews (Auftrag 1 Server, Auftrag 2 Client), Stand 21.11.2026

Originaltexte von Codex, darunter die Einschätzung von Claude. Die Reviews wurden auf einem **älteren Stand** erstellt, einige Funde waren zu diesem Zeitpunkt schon behoben (siehe Spalte „Stand").

## Original Codex: Auftrag 1, Server-Review

**Vor Veröffentlichung zuerst beheben:** Die beiden Spielstände eines Schatztransfers können unterschiedlich weit gespeichert sein. Außerdem können zurückgebrachte Müllwagen-Schätze dauerhaft liegen bleiben.

1. **Sicher: Ein Schatztransfer ist über zwei Spielstände nicht atomar.** `src/server/TreasureService.luau:380–396`, `src/server/DataService.luau:43–45`. Beim Ablegen ändern sich beide Profile im Arbeitsspeicher, aber ProfileStore schreibt zwei DataStore-Schlüssel. Wird nur der neue Stand des Diebs vor einem Absturz gespeichert, haben ihn nach dem Neustart beide. Wird nur der Stand des Opfers gespeichert, fehlt er beiden. **Vorschlag:** Für dauerhafte Transfers stabile Schatz- und Transaktions-IDs und ein wiederholbares Wiederherstellungsverfahren vorsehen. Einen unterbrochenen Transfer in beiden Schreibreihenfolgen testen.
2. **Sicher: Der Abladeplatz kann dauerhaft Schätze ansammeln.** `src/server/TreasureService.luau:503–505`, `src/server/TreasureService.luau:523–531`. Die 60-Sekunden-Frist wird einmal geprüft. Wird ein Schatz zu diesem Zeitpunkt getragen und später etwa durch Respawn zum Abladeplatz zurückgebracht, gibt es keine neue Frist. **Vorschlag:** Bei jeder Rückkehr zum Abladeplatz eine neue, an diese konkrete Rückkehr gebundene Frist setzen. Eine alte Frist darf einen später zurückgebrachten Schatz nicht entfernen.
3. **Sicher: Klau-Starts lassen sich ohne erfolgreichen Klau wiederholen.** `src/server/StealService.luau:130–181`, `src/server/StealService.luau:236`. Die Abkühlzeit beginnt erst bei Erfolg. Wiederholte Starts am selben Schatz ersetzen die Sperre samt Frist und lösen weitere Besitzeralarme aus. Der jeweils alte Timer bleibt bis zum Ablauf eingeplant. **Vorschlag:** Startversuche pro Spieler begrenzen, denselben laufenden Start unverändert lassen und Alarm, Fehlerbanner und Logs bei Wiederholungen drosseln.
4. **Sicher: Der Klau prüft Nähe nur an beiden Enden der Haltezeit.** `src/server/StealService.luau:156–169`, `src/server/StealService.luau:215–222`. Ein Spieler kann während des Haltevorgangs den Radius verlassen und rechtzeitig zurückkommen. Bei gleicher Start- und Endposition ist die berechnete Bewegung null. **Vorschlag:** Während eines laufenden Holds serverseitig in festen Abständen Reichweite prüfen und bei Verlassen abbrechen. Bei Bedarf die gesamte Bewegung plausibilisieren.
5. **Sicher: Ein alter Ausrutsch-Timer kann den neuen Charakter verändern.** `src/server/TrapService.luau:89–120`. Nach einem Respawn innerhalb der zwei Sekunden sucht der Timer den dann aktuellen Humanoid und Root-Part. Er kann deren Bewegung auf null setzen und den neuen Charakter in `GettingUp` versetzen. **Vorschlag:** Timer an Charakter und Ausrutschvorgang binden. Beim Respawn das Attribut aufräumen und die Physik des neuen Charakters in Ruhe lassen.
6. **Sicher: Ohne freien Bau bleibt ein Spieler dauerhaft ohne Bau in dieser Sitzung.** `src/server/Main.server.luau:35–36`, `src/server/BaseService.luau:66–79`, `src/server/TreasureService.luau:678–681`. Wenn ein siebter Spieler zugelassen wird oder ein Bau in der Map fehlt, bleibt sein Besitz im gespeicherten Überlauf. Auch wenn später ein Bau frei wird, gibt es keinen erneuten Zuweisungsversuch. **Vorschlag:** Das Platzlimit auf sechs setzen und den Fall ohne Bau mit einer klaren Meldung und sauberer Profilfreigabe behandeln.
7. **Vermutung: Die Bananenschale kann an einer unplausiblen Berührung auslösen.** `src/server/TrapService.luau:124–148`. Der Handler prüft Spieler, Besitzer und Lebensstatus, aber keine Distanz zwischen Opfer und Schale. Ob Roblox hier bei clientseitig simulierter Charakterphysik tatsächlich ein unplausibles Ereignis durchreicht, braucht einen Studio-Test. **Vorschlag:** Vor Verbrauch serverseitig die Überlappung bzw. Nähe zur Schale prüfen.

Direktes Setzen von Kronkorken oder Besitz über Remote-Argumente habe ich im gelesenen Pfad nicht gefunden. `RequestPickup` und `RequestPlace` stehen in der Remote-Liste, haben hier aber keine Server-Handler. Die Spielertabellen werden beim Verlassen bereinigt. Die gefundenen Timer können Referenzen vorübergehend halten. Der anwachsende Bestand in Fund 2 ist der konkrete dauerhafte Speicherverbrauch.

Review per Quellcode, ohne Studio-Test und ohne Änderungen.

## Original Codex: Auftrag 2, Client-Review

Geprüft sind die vier Dateien aus dem aktualisierten ZIP. Grab und Drop verwenden serverseitig F, die Klau-Eingabe verwendet E. Der Touch-Button hat `TextScaled` mit einer Mindestgröße der Schrift von 22 px und die vorgesehenen 92–112 px. Der Commit nach einem abgelehnten Start löst im Server-Zeitfenster kein zweites Banner aus. Alle vier Dateien kompilieren.

1. **Sicher: Die vorgesehenen Rechtecke können sich im kleinen Querformat schneiden.** `src/client/Hud.luau:196–216`. Bei 568 px nutzbarer Breite endet der Footer bei etwa x=381. Der 92 px breite STEAL-Button beginnt bei etwa x=362. Beide liegen am unteren Rand. Damit passen Fortschrittsbalken bzw. Einführung und Button horizontal nicht nebeneinander. Wie viel Inhalt sichtbar verdeckt wird, hängt vom Rendering ab. **Vorschlag:** Auf iPhone SE und kleinem Android den Balken während eines Holds mit eingeblendetem Tipp prüfen und den Footer anhand der tatsächlichen Buttonbreite positionieren.
2. **Sicher: Die Banner-Warteschlange hat keine Obergrenze.** `src/client/Hud.luau:310–342`. Nur direkt wiederholte identische `common`-Texte werden zusammengefasst. Kommen unterschiedliche Meldungen schnell hintereinander, kann ein neues Banner deutlich verspätet erscheinen, während alte Einträge Speicher belegen. **Vorschlag:** Häufige persönliche Hinweise zeitlich bündeln und seltenen Ansagen einen festen Platz in der Anzeige geben. Das betrifft die Anzeigereihenfolge und braucht eine kleine Verhaltensentscheidung.
3. **Vermutung: Aktionsbuttons können auf einem sehr kleinen Handy in Touch-Steuerflächen ragen.** `src/client/Hud.luau:124–136`, `src/client/Hud.luau:204–216`. Die Aktionsliste beansprucht vor dem Upgrade etwa 200 px Höhe. Auf einem kurzen Display ist die tatsächliche Berührungsfläche des Joysticks entscheidend. Der bisherige XR-Test allein deckt das nicht ab. **Prüfung:** Während des Laufens Banane oder Upgrade drücken, anschließend mit eingeblendetem STEAL gleichzeitig springen. Den Test im Hoch- und Querformat durchführen.
4. **Vermutung: Aufräumen bei manueller Zerstörung des LocalScripts.** `src/client/Main.client.luau:46–53`. Alle Trennungen hängen an `script.Destroying`. Bei verzögerten Roblox-Signalen ist dieser Pfad bei Hot-Reload oder manueller Script-Zerstörung zu überprüfen. Beim gewöhnlichen Respawn bleibt das LocalScript bestehen. Der Controller setzt den Hold zurück und `Effects` entfernt den Kamera-Offset.

Im eigenen HUD ist keine Textgröße unter 22 px eingestellt. Einen beim normalen Respawn anwachsenden Bestand an Verbindungen habe ich im Code nicht gefunden.

**Bei Auftrag 2 wurde keine Client-Datei geändert.** Die Layout-Korrektur braucht einen Abgleich mit den echten Touch-Steuerflächen. Die Warteschlange braucht eine abgestimmte Anzeigereihenfolge. Studio-Tests stehen für die genannten Geräte aus.

---

## Einschätzung von Claude (21.11.2026), verglichen mit dem Opus-Review

Zwei Modelle haben unabhängig gelesen. Funde, die **beide** haben, sind am wahrscheinlichsten echt.

| Codex-Fund | Auch bei Opus? | Stand |
|---|---|---|
| Server 1, Transfer nicht atomar | von Claude als bekanntes Restrisiko geführt (Absturz genau zwischen zwei Speicherungen) | **offen, bewusst akzeptiert für den Prototyp.** Echte Lösung (Transaktions-IDs, Wiederherstellung) erst nach der Veröffentlichung bewerten |
| Server 2, Müll-Timer nach Rückkehr | ja | **behoben** (`scheduleDespawn`, in Studio geprüft) |
| Server 3, Klau-Starts wiederholen, Alarm spammen | ja | **behoben** (steigende Wartezeit, Alarm höchstens alle 4 s) |
| Server 4, Nähe nur am Anfang und Ende der Haltezeit | nein, nur Codex | **offen, echt, klein.** Während eines laufenden Holds die Entfernung prüfen und abbrechen, wenn der Dieb den Radius verlässt |
| Server 5, alter Ausrutsch-Timer betrifft neuen Charakter | nein, nur Codex | **offen, plausibel, klein.** Charakter beim Ausrutschen merken und nur dann eingreifen, wenn es derselbe ist |
| Server 6, ohne freien Bau | nein, nur Codex | **offen.** Max. Spieler = 6 beim Veröffentlichen setzen, bei fehlendem Bau klare Meldung und Kick mit sauberer Profilfreigabe |
| Server 7, Bananenschale ohne Distanzprüfung | ja, auch bei Opus als Vermutung | **offen, von beiden genannt:** vor dem Verbrauch der Schale die Nähe des Opfers prüfen (billig) |
| (nur Opus) Teleport mit geklauter Beute | Codex hat es nicht | **behoben** (`teleportSuspected`, Studio geprüft) |
| (nur Opus) zerstörter Schatz-Körper | Codex hat es nicht | **behoben** |
| (nur Opus) Bananen-Erstattung beim Verlassen | Codex hat es nicht | **behoben** |
| Client 1, Footer und STEAL-Button im kleinen Querformat | – | **offen:** Test im Emulator mit iPhone SE und kleinem Android (568 mal 320) |
| Client 2, Banner-Warteschlange ohne Obergrenze | – | **offen, klein:** Obergrenze einführen, häufige persönliche Hinweise bündeln |
| Client 3, Buttons nahe der Touch-Flächen | – | **offen, Prüfung nötig** (Hoch- und Querformat, gleichzeitig springen) |
| Client 4, Aufräumen bei manueller Zerstörung | – | **niedrig, ignorierbar** |
