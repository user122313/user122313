# Aufträge für Codex, während Claude pausiert (21.11.2026)

**Regel für alle Aufträge:** Codex kann Roblox Studio nicht starten. Alles, was er ändert, ist ungetestet. Darum zuerst Prüfen und Aufschreiben, nur kleine, gut erklärte Änderungen. Claude testet alles in Studio, sobald das Limit wieder frei ist.

**Vorher:** ZIP `Muellbanditen-fuer-Codex.zip` entpacken, `STATUS.md` lesen. Codex darf **nicht** ändern: `src/server/*`, `src/shared/*`, `tests/*`, `place/*`. Er darf ändern: `src/client/*` (nur die 4 Dateien Hud, Effects, StealController, Main.client) und neue Dateien unter `docs/`.

**Zurück zu Claude:** Alles, was Codex liefert, als Dateien oder Codeblöcke mit Dateinamen. Geänderte Client-Dateien nach `src/client/` kopieren, neue Dokumente nach `docs/`. Dann Claude sagen: „Codex hat X geliefert, bitte prüfen und in Studio testen."

---

## Auftrag 1 (wichtigster): Gegenlesen des Server-Codes, nur lesen
> Lies `STATUS.md`, `docs/superpowers/specs/2026-11-20-roblox-chaos-spiel-design.md` und `docs/superpowers/plans/2026-11-20-muellbanditen-prototyp.md`. Prüfe danach `src/server/StealService.luau`, `TreasureService.luau`, `TrapService.luau`, `DataService.luau`, `BaseService.luau`, `Announcer.luau` und `src/shared/*.luau` als Reviewer. **Ändere nichts.** Suche gezielt: (1) Wege, auf denen ein Spieler (Exploiter) per RemoteEvent betrügen kann, (2) Stellen, wo Schätze oder Kronkorken doppelt entstehen oder verloren gehen, (3) Speicher-Fehler (Datenverlust, Doppelspeichern), (4) Fehler bei mehreren Spielern gleichzeitig (Race Conditions), (5) Speicherlecks, die nach Verlassen von Spielern bleiben. Gib eine nummerierte Liste mit Datei:Zeile, was schiefgehen kann, einem konkreten Szenario und einem Vorschlag. Markiere nur Dinge, bei denen du dir sicher bist, als „sicher", den Rest als „Vermutung".

## Auftrag 2: Gegenlesen des Client-Codes, nur lesen
> Prüfe deine eigenen vier Client-Dateien noch einmal gegen `docs/ui/brief.md` und `docs/ui/codex-ui-prompt.md`. Beachte neu: Grab/Drop-Hinweise nutzen Taste **F**, E ist nur fürs Klauen; der STEAL-Button hat jetzt `TextScaled` und 92 bis 112 px; bei abgelehntem Klau-Start ignoriert der Server das folgende Commit still. Suche: Layout-Probleme auf kleinen Handys (iPhone SE, kleine Androids, Querformat), Text unter 22 px, Dinge, die den Joystick oder Sprungknopf verdecken, Speicherlecks (nicht getrennte Verbindungen), und Dinge, die beim Respawn kaputtgehen. Liste die Funde auf. Ändere Code nur, wenn der Fund sicher ist und die Änderung höchstens ein paar Zeilen groß ist. Beschreibe jede Änderung.

## Auftrag 3: Veröffentlichungs-Anleitung aus der offiziellen Doku
> Schreibe `docs/veroeffentlichen.md` (auf Deutsch, für einen 17-jährigen Anfänger, mit Klickpfaden). Quelle ist die **aktuelle offizielle Roblox-Dokumentation und der Creator Hub**, nenne die Links und das Abrufdatum. Inhalt: (1) Spiel als **privat** veröffentlichen (Studio: Datei, Auf Roblox veröffentlichen), (2) **API-Zugriff für DataStores in Studio** einschalten, (3) Einstellungen für 6 Spieler pro Server (Max. Spieler), (4) Altersfreigabe-Fragebogen, was gefragt wird und worauf man achten muss, (5) Icon- und Thumbnail-Größen und -Regeln, (6) Titel und Beschreibung ohne falsche Versprechen, (7) wie man das Spiel auf **öffentlich** stellt, (8) wo man Besuche, Spielzeit und Wiederkehr in den Analysen findet. Der Spieltitel ist **Trash Bandits**. Schreibe ausdrücklich dazu, wenn du dir bei einem Schritt nicht sicher bist oder die Oberfläche anders aussehen könnte.

## Auftrag 4 (optional): Video-Skript gegenlesen
> Lies `docs/videos/woche1-skript.md` und `docs/videos/video-workflow.md`. Mach Verbesserungsvorschläge für Hook, Tempo und Verständlichkeit für Zuschauer, die Roblox kennen, aber nichts von dem Projekt wissen. Schreib keine Gedankenstriche und keine KI-Floskeln, nutze einfache Sätze. Gib 3 alternative Hooks (je 2 Sätze) und 3 Thumbnail-Texte (2 bis 4 Wörter).
