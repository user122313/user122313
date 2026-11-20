# Prompt für Codex (UI-Aufgabe)

Du arbeitest an einem Roblox-Spiel (Luau, Rojo-Projekt). Lies zuerst `docs/ui/brief.md` und `src/shared/Theme.luau`. Das ist dein vollständiger Auftrag.

Regeln:
- Ändere NUR `src/client/Hud.luau`, `src/client/Effects.luau`, `src/client/StealController.luau`, `src/client/Main.client.luau`.
- Keine Änderungen in `src/server/` oder `src/shared/`. Fehlt dir etwas, schreib es am Ende als Liste „Wünsche an den Server“ auf, erfinde keine Events.
- UI wird komplett per Code gebaut, mit `Theme.luau` für alle Farben und Schrift.
- Alle sichtbaren Texte Englisch.
- Der Client entscheidet nichts (Geld, Besitz, Zeit). Er zeigt nur an und schickt Bitten.
- Kleine, gut kommentierte Commits. Keine neuen Abhängigkeiten.

Stand des Servers (so funktioniert es schon, baue dafür keine eigene UI):
- Schätze liegen als Models in `workspace.Treasures`. Jedes Model hat die Attribute `TreasureId` (string), `DefId`, `OwnerUserId` (number, 0 = niemand) und `CarriedBy` (number, 0 = niemand). Der Name über dem Schatz kommt vom Server.
- Aufheben am Abladeplatz und Ablegen im eigenen Bau laufen über Roblox-`ProximityPrompt`s (Server baut sie, Taste **F**, nicht E). Dafür brauchst du keinen Button. Taste **E** gehört allein dem Klauen: Roblox-Hinweise gewinnen immer gegen eine geteilte Taste, auch bei höherer Priorität (in Studio getestet).
- Klauen ist deine Aufgabe (`StealController.luau`): Ein klaubarer Schatz ist ein Model in `workspace.Treasures` mit `OwnerUserId ~= 0`, `OwnerUserId ~= LocalPlayer.UserId` und `CarriedBy == 0`, innerhalb von ca. 8 Studs. Beim Halten von E (oder Touch-Button) sendest du `RequestStealStart(treasureId)`, nach 1.5 s `RequestStealCommit(treasureId)`. Die Zeit zählt der Server selbst, du zeigst nur den Balken. Es gibt kein Abbrechen-Event: Lässt der Spieler vor 1.5 s los, sendest du trotzdem `RequestStealCommit(treasureId)`, der Server lehnt es als „zu kurz“ ab und gibt den Schatz wieder frei. Sendest du gar nichts, gibt der Server ihn nach 4 s selbst frei.
- Hinweise an einen einzelnen Spieler (z. B. „Your base is full!“) kommen als `Announce(text, "common")`. Zeig sie als kurzes Banner, auch wenn `rarity` = `common` ist.
- `HudUpdate(caps, incomePerSec)` kommt jede Sekunde.
- Bananenschalen (Element 8 im Brief): Zwei Buttons, „Buy banana (50)“ sendet `RequestBuyBanana()`, „Place banana“ sendet `RequestPlaceBanana()` (ohne Argumente, der Server stellt sie vor dem Spieler in seinen eigenen Bau). Wie viele Schalen der Spieler im Vorrat hat, steht im Spieler-Attribut `Bananas` (`LocalPlayer:GetAttribute("Bananas")`, Änderungen per `GetAttributeChangedSignal`). Fehlermeldungen („Not enough bottle caps!“ usw.) kommen als `Announce(text, "common")`.
- Bau ausbauen (Element 9 im Brief): Button „Upgrade base (500)“ sendet `RequestUpgradeBase()`. Die Ausbaustufe steht im Spieler-Attribut `BaseLevel` (1 oder 2); bei 2 versteckst du den Button. Der Server zieht die Kronkorken ab und schaltet die Plätze frei.
- `StealAlarm(thiefName)` kommt nur beim Besitzer an, sobald jemand bei ihm zu klauen beginnt: roter Rand blinkt, Text „SOMEONE IS STEALING!“ (du kannst den Namen des Diebs ergänzen).
- `Announce(text, rarity)` für seltene und legendäre Klaus kommt an ALLE Spieler. Der Text ist schon fertig formuliert („⚠ Alex stole the GOLDEN TOASTER!“), du färbst das Banner nach `rarity`.
- `Slipped(seconds)`: Der Server schleudert den Spieler selbst weg, der Client zeigt nur „SLIPPED!“ und das Kamera-Wackeln.
- Lies zuerst `STATUS.md` im Projektordner.

Gib am Ende eine kurze Liste: was gebaut wurde, was der Nutzer in Studio testen soll, und alle Wünsche an den Server.
