# Müllbanditen Prototyp – Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ein öffentlich spielbarer Roblox-Prototyp (6 Spieler pro Server) in 4 Wochen: Müll-Schätze klauen, mit Bananenschalen verteidigen, Fortschritt speichern.

**Architecture:** Der Server entscheidet alles (Besitz, Kronkorken, Klau-Regeln). Der Client zeigt an und schickt nur Bitten per RemoteEvent. Alle Regeln sind reine Luau-Module ohne Roblox-Bezug (`src/shared/*`), damit sie außerhalb von Studio mit Lune getestet werden können. Roblox-spezifischer Code (Services, UI) ist dünn und wird per Checkliste in Studio geprüft.

**Tech Stack:** Roblox Studio, Luau, Rojo (Dateien → Studio), Lune (Tests ohne Studio), Rokit (Toolchain), Git, ProfileStore (Speichern).

**Spec:** `docs/superpowers/specs/2026-11-20-roblox-chaos-spiel-design.md`

## Global Constraints

- Hauptgerät ist der Windows-Gaming-Laptop; Roblox Studio nur dort. Alles andere kostenlos, keine bezahlten Tools in den ersten 4 Wochen.
- Max. **6 Spieler** pro Server, 1 Map, 6 Baue, Abladeplatz in der Mitte.
- Server ist Schiedsrichter: Geld, Besitz und Ergebnisse werden **nie** vom Client übernommen. Haltezeit misst der Server.
- Währung heißt **Kronkorken**. Seltenheiten: `common`, `rare`, `legendary`. 8–10 Schätze.
- Klau-Haltezeit **1.5 s**, Trage-Geschwindigkeit leicht unter Lauf-Geschwindigkeit; Ausrutschen **2 s**; max. **3** Bananenschalen im Bau.
- Spielstand hat von Anfang an `version`-Feld. Keine Roblox-Pay-to-win-Mechanik, keine Käufe in diesen 4 Wochen.
- Alle Zahlen stehen zentral in `src/shared/Config.luau`, nirgends sonst.
- Nur Gratis-Assets ohne Skripte (Skripte vor Einbau löschen).
- Nicht im Prototyp: zweite Map, Game Passes, Handel, weitere Fallen, Quests, Ranglisten, NPCs, eigene Modelle/Animationen (Spec 5.4).
- Kürzungsreihenfolge bei Zeitnot: Ausbaustufe → Ansagen → Anzahl Schätze. Nie kürzen: Klauen, Bananenschale, Speichern, öffentlich machen, Video.
- Code erklärt Claude pro neuem System in 3–5 einfachen Sätzen; der Nutzer macht pro Woche mindestens eine kleine Änderung selbst (z. B. Wert in `Config.luau`).

## Review Focus

1. **Zwei Diebe klauen gleichzeitig denselben Schatz:** nur der erste bekommt ihn, der zweite bekommt `locked`. (Task 5, 6)
2. **Dieb oder Besitzer verlässt mitten im Klau den Server:** Schatz geht zurück an den Besitzer, nichts verdoppelt sich, nichts geht verloren. (Task 5, 6)
3. **Voller Bau:** man kann nichts aufheben oder klauen, die Aktion wird mit klarem Grund abgelehnt. (Task 4, 5)
4. **Kaputter, leerer oder alter Spielstand (`nil`, falsche Version, negative Kronkorken, unbekannte Schatz-IDs):** Spieler startet mit sinnvollen Werten, kein Absturz, kein Verlust gültiger Teile. (Task 9)
5. **Handy-Bedienung:** Taste-halten-zum-Klauen muss auch per Touch funktionieren. (Task 12)

---

## Gameplay-Regeln pro Ereignis (verbindlich für alle Tasks)

| Ereignis | Server tut | Spieler sieht/hört |
|---|---|---|
| Spieler betritt Server | freien Bau zuweisen, Spielstand laden, Start-Schatz `common` in Bau legen | Kamera/Spawn am eigenen Bau, HUD mit Kronkorken und Einkommen |
| Müllwagen-Intervall (20 s) | 1 Schatz am Abladeplatz erzeugen (Seltenheit gewichtet), nach 60 s ohne Besitzer entfernen | Wagen-Sound, Schatz fällt, Name über dem Schatz |
| Schatz vom Abladeplatz aufheben | prüfen: Nähe, Hände frei, Bau nicht voll → Spieler trägt ihn | Schatz über dem Kopf, Spieler etwas langsamer |
| Im eigenen Bau ablegen | Schatz gehört dem Spieler, wird gespeichert, Einkommen steigt | „Ding!“-Ton, Zähler tickt schneller |
| Klau beginnen (Taste 1.5 s halten) | Start-Zeit merken, Schatz `lockedBy = Dieb` | Fortschrittsbalken beim Dieb, Warnsignal beim Besitzer |
| Klau abschließen | Dauer, Nähe, Hände frei, Platz, Cooldown prüfen → Schatz wechselt Besitz **dauerhaft**, Dieb trägt ihn | serverweite Ansage bei `rare`/`legendary`, Dieb leuchtet |
| Besitzer berührt Dieb | Schatz fällt, nach 10 s zurück zum Besitzer | Wackel-Effekt, Sound |
| Dieb erreicht eigenen Bau | Schatz bleibt beim Dieb (gespeichert), beim Besitzer entfernt | Jubel-Sound, Zähler |
| Bananenschale betreten | Spieler 2 s hilflos, trägt er etwas: fällt zurück zum Besitzer, Schale verbraucht | Spieler fliegt durch die Luft, Text „AUSGERUTSCHT!“ |
| Spieler verlässt Server | Speichern; Bau samt Inhalt von der Map entfernen; trug er etwas: Schatz zurück zum Besitzer | Bau verschwindet |

## File Structure

```
rokit.toml                      Toolchain (rojo, lune)
default.project.json            Rojo-Zuordnung
src/shared/Config.luau          alle Zahlen (Zeiten, Preise, Einkommen)
src/shared/Types.luau           geteilte Typen
src/shared/Catalog.luau         Schatz-Definitionen
src/shared/Economy.luau         Einkommens-/Preislogik (rein)
src/shared/StealRules.luau      Klau-Prüfungen (rein)
src/shared/TrapRules.luau       Fallen-Prüfungen (rein)
src/shared/SaveSchema.luau      Spielstand-Format + Migration (rein)
src/shared/Remotes.luau         Namen aller RemoteEvents
src/shared/Packages/ProfileStore.luau   fertige Speicher-Bibliothek (eingecheckt)
src/server/Main.server.luau     Start, verdrahtet die Services
src/server/BaseService.luau     Bau-Zuweisung, Schatz-Plätze, Ausbau
src/server/TreasureService.luau Müllwagen, Aufheben, Ablegen, Rückkehr
src/server/StealService.luau    Klau-Ablauf, Tragen, Besitzer-Berührung
src/server/TrapService.luau     Bananenschalen
src/server/DataService.luau     Laden/Speichern über ProfileStore
src/server/Announcer.luau       serverweite Ansagen
src/client/Main.client.luau     Start
src/client/Hud.luau             Kronkorken, Einkommen, Hinweise
src/client/StealController.luau Taste halten, Balken, Eingabe (Maus/Touch)
src/client/Effects.luau         Wackeln, Ausrutschen, Sounds
tests/run.luau, tests/lib/t.luau Test-Runner; tests/*.spec.luau
place/Muellbanditen.rbxl        Map + Modelle (täglich committen)
STATUS.md, IDEEN.md             Stand und Ideen-Parkplatz
docs/videos/video-workflow.md   Videoablauf
```

---

# Woche 1: Fundament

### Task 1: Repo, Toolchain, Test-Runner

**Files:**
- Create: `rokit.toml`, `default.project.json`, `.gitignore`, `STATUS.md`, `IDEEN.md`, `tests/run.luau`, `tests/lib/t.luau`, `src/shared/Config.luau`, `src/shared/Types.luau`, `src/server/Main.server.luau`, `src/client/Main.client.luau`

**Interfaces:**
- Produces: `t.test(name: string, fn: () -> ())`, `t.eq(actual: any, expected: any)`, `t.truthy(v: any)`; Runner führt alle `tests/*.spec.luau` aus, Exit-Code ≠ 0 bei Fehlern.
- Produces: `Config` mit Feldern aus „Task 2“ (zunächst leere Tabelle).

- [ ] **Step 1:** Rokit installieren, `rokit add rojo-rbx/rojo` und `rokit add lune-org/lune` ausführen. Prüfen: `rojo --version` und `lune --version` geben Versionen aus. (Falls ein Paketname abweicht: aktuelle Namen in der Rojo/Lune-Doku nachsehen und hier korrigieren.)
- [ ] **Step 2:** `default.project.json`: `ReplicatedStorage.Shared` → `src/shared`, `ServerScriptService.Server` → `src/server`, `StarterPlayer.StarterPlayerScripts.Client` → `src/client`; `$ignoreUnknownInstances: true`, damit die Map in der `.rbxl` nicht überschrieben wird.
- [ ] **Step 3:** Test-Runner schreiben: `tests/run.luau` lädt jede `*.spec.luau` per `lune`-fs, ruft sie auf, zählt Erfolge/Fehler, Exit 1 bei Fehlern.
- [ ] **Step 4:** Leeren Test `tests/smoke.spec.luau` (`t.eq(1+1, 2)`) anlegen. Run: `lune run tests/run`. Expected: `1 passed, 0 failed`.
- [ ] **Step 5:** `STATUS.md` (3 Zeilen: Was geht / Was als Nächstes / Blockiert) und `IDEEN.md` anlegen.
- [ ] **Step 6:** Manuell: Roblox Studio neues Baseplate-Place → als `place/Muellbanditen.rbxl` speichern, `rojo serve`, Rojo-Plugin in Studio verbinden, in `Main.server.luau` `print("Müllbanditen läuft")`. Expected: Ausgabe im Studio-Output beim Play.
- [ ] **Step 7: Commit** `git add -A && git commit -m "chore: project skeleton, rojo, lune test runner"`

### Task 2: Config, Katalog, Wirtschaft (rein, getestet)

**Files:**
- Modify: `src/shared/Config.luau`, `src/shared/Types.luau`
- Create: `src/shared/Catalog.luau`, `src/shared/Economy.luau`, `tests/economy.spec.luau`

**Interfaces:**
- Produces `Config`: `MAX_PLAYERS=6`, `DUMP_INTERVAL=20`, `DUMP_DESPAWN=60`, `STEAL_HOLD=1.5`, `STEAL_HOLD_TOLERANCE=0.2`, `STEAL_REACH=8` (Studs), `STEAL_COOLDOWN=3`, `CARRY_SPEED=12`, `WALK_SPEED=16`, `DROP_RETURN=10`, `SLIP_SECONDS=2`, `BANANA_COST=50`, `MAX_BANANAS=3`, `BASE_CAPACITY={4, 8}`, `UPGRADE_COST=500`, `INCOME={common=1, rare=4, legendary=15}`, `DUMP_WEIGHTS={common=70, rare=25, legendary=5}`, `MAX_MOVE_SPEED=30` (für den Tempo-Check), `AUTOSAVE_SECONDS=120`.
- Produces `Types`: `Rarity = "common"|"rare"|"legendary"`, `TreasureDef = {id: string, name: string, rarity: Rarity}`.
- Produces `Catalog`: `Catalog.all: {TreasureDef}`, `Catalog.get(id: string): TreasureDef?`, `Catalog.startTreasureId: string`.
- Produces `Economy.incomePerSecond(ids: {string}): number`, `Economy.capacity(baseLevel: number): number`, `Economy.rollRarity(r: number): Rarity` (r in [0,1)).

- [ ] **Step 1: Failing tests** in `tests/economy.spec.luau`: `income of empty base is 0`; `income sums rarities (common+rare+legendary = 20)`; `unknown id adds 0`; `capacity level1 = 4, level2 = 8`; `rollRarity(0)=common, rollRarity(0.69)=common, rollRarity(0.70)=rare, rollRarity(0.95)=legendary`; `catalog has 8 to 10 treasures, all three rarities, unique ids`.
- [ ] **Step 2:** Run `lune run tests/run`. Expected: FAIL (Module fehlt).
- [ ] **Step 3:** `Catalog.luau` mit 8–10 Einträgen, z. B. common: Pizzakarton, Alte Socke, Kaugummi-Klumpen, Fischgräte; rare: Disco-Dose, Zahnbürsten-Bündel, Goldener Kronkorken-Haufen; legendary: Goldener Toaster, Kaputte Krone. Start-Schatz = ein `common`.
- [ ] **Step 4:** `Economy.luau` implementieren (Gewichte aus `Config.DUMP_WEIGHTS`, kumulativ).
- [ ] **Step 5:** Run: Expected all PASS.
- [ ] **Step 6: Commit** `feat: config, treasure catalog, economy rules`

### Task 3: Baue und Spieler-Beitritt (Studio)

**Files:**
- Create: `src/server/BaseService.luau`, `src/shared/Remotes.luau`
- Modify: `src/server/Main.server.luau`; Studio-Map: Ordner `Workspace.Bases` mit `Base1..Base6` (je Modell mit `Spawn`-Part und `Slot1..Slot8`-Parts), `Workspace.DumpSite`.

**Interfaces:**
- Produces `BaseService.assign(player: Player): Model?` (nil wenn Server voll), `BaseService.release(player: Player)`, `BaseService.ownerOf(base: Model): Player?`, `BaseService.baseOf(player: Player): Model?`, `BaseService.freeSlot(player: Player): BasePart?`.
- Produces `Remotes.names`-Liste: `HudUpdate`, `Announce`, `RequestPickup`, `RequestPlace`, `RequestStealStart`, `RequestStealCommit`, `RequestBuyBanana`, `RequestPlaceBanana`, `RequestUpgradeBase`, `Slipped`; Server legt sie als RemoteEvents in `ReplicatedStorage.Remotes` an.

- [ ] **Step 1:** Map in Studio aus einfachen grauen Parts bauen: 6 Baue im Kreis, Abladeplatz in der Mitte. Namen wie oben. `Players.MaxPlayers = 6` in den Spiel-Einstellungen.
- [ ] **Step 2:** `BaseService` implementieren: `Players.PlayerAdded` → `assign`, Spawn-Position setzen; `PlayerRemoving` → `release`. Besitzer als Attribut `OwnerUserId` am Base-Modell.
- [ ] **Step 3: Manuell prüfen** (Studio → Test → 3 Spieler lokal): jeder Spieler spawnt im eigenen Bau, kein Bau doppelt belegt; nach Verlassen ist der Bau wieder frei. Ergebnis in `STATUS.md` notieren.
- [ ] **Step 4: Commit** `feat: base assignment`

### Task 4: Müllwagen, Aufheben, Ablegen, Einkommen, HUD

**Files:**
- Create: `src/server/TreasureService.luau`, `src/client/Hud.luau`
- Modify: `src/server/Main.server.luau`, `src/client/Main.client.luau`

**Interfaces:**
- Consumes: `Economy`, `Catalog`, `BaseService`, `Remotes`.
- Produces `TreasureService.spawnAtDump(): Instance` (Modell mit Attributen `TreasureId` (GUID-String), `DefId`, `OwnerUserId` (leer am Abladeplatz)); `TreasureService.giveTo(player: Player, treasure: Instance): boolean`; `TreasureService.ownedBy(player: Player): {Instance}`; `TreasureService.returnToOwner(treasure: Instance)`.
- Produces Client-Event `HudUpdate(caps: number, incomePerSec: number)`.

- [ ] **Step 1:** Schatz-Modelle: je Katalog-Eintrag ein einfaches Modell (Part + Name als `BillboardGui`) unter `ServerStorage.Treasures`, Name = `DefId`.
- [ ] **Step 2:** Müllwagen-Schleife: alle `Config.DUMP_INTERVAL` s `spawnAtDump()` (Seltenheit via `Economy.rollRarity(math.random())`), nach `Config.DUMP_DESPAWN` s ohne Besitzer entfernen.
- [ ] **Step 3:** `RequestPickup(treasureId)`: Server prüft Nähe (`STEAL_REACH`), Hände frei, Bau nicht voll (`Economy.capacity`) → Schatz wird getragen. `RequestPlace()`: nur im eigenen Bau → freier Slot, `OwnerUserId` setzen.
- [ ] **Step 4:** Einkommen: pro Sekunde `Economy.incomePerSecond` der Besitz-Schätze auf `caps` addieren, `HudUpdate` an den Spieler. Start-Schatz beim ersten Beitritt.
- [ ] **Step 5:** `Hud.luau`: zwei Textfelder (Kronkorken, „+X/s“), reagiert auf `HudUpdate`.
- [ ] **Step 6: Manuell prüfen:** Schatz erscheint alle 20 s, kann aufgehoben und im Bau abgelegt werden, Zähler steigt mit Seltenheit; voller Bau lehnt Aufheben ab (Hinweis erscheint); nicht abgeholter Schatz verschwindet nach 60 s.
- [ ] **Step 7: Commit** `feat: dump spawner, pickup, place, income, hud`
- [ ] **Step 8 (Video):** Woche-1-Video nach `docs/videos/video-workflow.md`.

---

# Woche 2: Klauen

### Task 5: Klau-Regeln (rein, getestet)

**Files:**
- Create: `src/shared/StealRules.luau`, `tests/steal.spec.luau`

**Interfaces:**
- Produces:
  - `type StealRequest = { distance: number, heldSeconds: number, now: number, thiefCarrying: boolean, thiefBaseFull: boolean, thiefLastStealAt: number, thiefSpeed: number, treasureOwnerId: number?, thiefId: number, treasureLockedBy: number? }`
  - `StealRules.validate(req: StealRequest): (boolean, string?)` – Ablehnungsgründe als Strings: `"too_far"`, `"too_short"`, `"carrying"`, `"base_full"`, `"cooldown"`, `"locked"`, `"own_treasure"`, `"too_fast"`.
  - `StealRules.resolveLeave(role: "thief" | "owner", carrying: boolean): "return_to_owner" | "none"`

- [ ] **Step 1: Failing tests:** `valid steal passes`; `rejects distance > STEAL_REACH`; `rejects heldSeconds < STEAL_HOLD - STEAL_HOLD_TOLERANCE (1.29 rejected, 1.31 accepted)`; `rejects when carrying`; `rejects when base full`; `rejects within STEAL_COOLDOWN of last steal`; `second thief rejected when lockedBy another id (review focus 1)`; `lockedBy same thief passes`; `rejects own treasure`; `rejects speed > MAX_MOVE_SPEED`; `thief leaves while carrying -> return_to_owner`; `owner leaves while thief carries -> return_to_owner`; `leave without carrying -> none`.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** `StealRules` implementieren, Prüfreihenfolge: own_treasure, locked, carrying, base_full, cooldown, too_far, too_fast, too_short (feste Reihenfolge, getestet über einen Fall mit zwei Verstößen: `locked` gewinnt vor `too_far`).
- [ ] **Step 4:** Run → PASS.
- [ ] **Step 5: Commit** `feat: steal validation rules`

### Task 6: Klau-Ablauf (Server + Client)

**Files:**
- Create: `src/server/StealService.luau`, `src/client/StealController.luau`
- Modify: `src/server/TreasureService.luau`, `src/server/Main.server.luau`, `src/client/Main.client.luau`

**Interfaces:**
- Consumes: `StealRules.validate`, `TreasureService.returnToOwner`, `BaseService`, `Config`.
- Produces: Server-Zustand pro Dieb `{ treasureId: string, startedAt: number }`; Events `RequestStealStart(treasureId: string)`, `RequestStealCommit(treasureId: string)`; Server → Client `HudUpdate` bleibt.
- Produces `StealService.dropCarried(player: Player)` (Schatz fällt, `DROP_RETURN` s später `returnToOwner`).

- [ ] **Step 1:** `StealStart`: Server merkt `startedAt = os.clock()`, setzt `lockedBy`. Mit `StealCommit`: Server berechnet `heldSeconds = now - startedAt` (nie vom Client), ruft `StealRules.validate`; bei Erfolg `OwnerUserId` auf Dieb, Dieb trägt, `WalkSpeed = CARRY_SPEED`, Marker (`Highlight`) am Dieb. Bei Ablehnung: `lockedBy` löschen, Grund als Hinweis an den Client.
- [ ] **Step 2:** `StealController`: Taste `E` (PC) bzw. Touch-Button gedrückt halten, Fortschrittsbalken 1.5 s, Loslassen = Abbruch; Start/Commit-Events senden.
- [ ] **Step 3:** Berührung: Besitzer (Spieler, dem der Schatz vor dem Klau gehörte) berührt den Dieb → `dropCarried`. Nach `DROP_RETURN` s: Schatz zurück zum Besitzer.
- [ ] **Step 4:** Dieb erreicht eigenen Bau: Schatz bleibt (Task 4 `RequestPlace`), Marker weg, `WalkSpeed` normal.
- [ ] **Step 5:** Spieler verlässt Server: `StealRules.resolveLeave` anwenden (Dieb trägt → zurück zum Besitzer; Besitzer geht → Schatz zurück an dessen Spielstand). Prüfen: nichts doppelt, nichts verloren.
- [ ] **Step 6: Manuell prüfen** (Studio, 3 Test-Spieler): Klau gelingt nach 1.5 s; zu früh loslassen bricht ab; zwei Spieler gleichzeitig → nur einer bekommt ihn; Dieb verlässt Server → Schatz kehrt zurück; kein Exploit: im Studio über die Konsole `RequestStealCommit` ohne Start senden → Ablehnung, Server-Log zeigt Grund.
- [ ] **Step 7: Commit** `feat: steal flow with server validation`
- [ ] **Step 8 (Playtest + Video):** Erster Playtest mit Zwillingsbruder (OBS-Replay-Puffer an), Bugs in `STATUS.md`, Video nach Workflow.

---

# Woche 3: Fallen, Gefühl, Speichern

### Task 7: Bananenschale (Regeln rein + Server)

**Files:**
- Create: `src/shared/TrapRules.luau`, `tests/trap.spec.luau`, `src/server/TrapService.luau`

**Interfaces:**
- Produces: `TrapRules.canBuy(caps: number): boolean`, `TrapRules.canPlace(placed: number, inOwnBase: boolean): (boolean, string?)` (Gründe `"max_traps"`, `"not_in_base"`), `TrapRules.slipOutcome(carrying: boolean): { helplessSeconds: number, dropsLoot: boolean }`.
- Produces Event `Slipped` (Server → Client) mit Dauer.

- [ ] **Step 1: Failing tests:** `canBuy false below BANANA_COST, true at cost`; `canPlace rejects 4th banana`; `canPlace rejects outside own base`; `slipOutcome carrying drops loot, helpless 2s`; `slipOutcome empty-handed does not drop`.
- [ ] **Step 2:** Run → FAIL. **Step 3:** `TrapRules` implementieren. **Step 4:** Run → PASS.
- [ ] **Step 5:** `TrapService`: Kauf (`RequestBuyBanana`), Platzieren (`RequestPlaceBanana`, Position = vor dem Spieler im eigenen Bau), `Touched` auf Schale: nur Fremde lösen aus; Spieler wird weggeschleudert (`ApplyImpulse`), 2 s `PlatformStand`, Loot fällt → `StealService.dropCarried`; Schale entfernen.
- [ ] **Step 6: Manuell:** Schale kaufen (Kronkorken sinken um 50), 3 platzieren, 4. abgelehnt; Fremder rutscht aus und verliert Beute; Besitzer selbst löst sie nicht aus.
- [ ] **Step 7: Commit** `feat: banana trap`

### Task 8: Gefühl – Effekte und Ansagen

**Files:**
- Create: `src/server/Announcer.luau`, `src/client/Effects.luau`
- Modify: `src/server/StealService.luau`, `src/client/Hud.luau`

**Interfaces:**
- Produces `Announcer.treasureStolen(thiefName: string, def: TreasureDef)` – sendet `Announce(text, rarity)` an alle, nur bei `rare`/`legendary`.
- Produces `Effects.slip(seconds: number)`, `Effects.carryGlow(character: Model, on: boolean)`.

- [ ] **Step 1:** Ansagen: „⚠ {Name} hat den GOLDENEN TOASTER geklaut!“ als Banner (3 s), Klau-Warnsignal beim Besitzer (Bildschirmrand rot blinkt + Ton).
- [ ] **Step 2:** Effekte: „AUSGERUTSCHT!“-Text, kurzes Kamera-Wackeln, Sounds (Klau, Ablegen, Ausrutschen, Müllwagen) aus Roblox-Gratis-Audio, Lautstärke moderat.
- [ ] **Step 3: Manuell:** Alle Effekte aus 5.5 der Spec sind sichtbar; ein 5-Sekunden-Clip ohne Ton ist verständlich (Test: Aufnahme Zwillingsbruder zeigen).
- [ ] **Step 4: Commit** `feat: announcements and effects`

### Task 9: Spielstand-Schema (rein, getestet)

**Files:**
- Create: `src/shared/SaveSchema.luau`, `tests/save.spec.luau`

**Interfaces:**
- Produces: `type SaveData = { version: number, caps: number, treasures: {string}, baseLevel: number }`; `SaveSchema.CURRENT_VERSION = 1`; `SaveSchema.default(): SaveData` (0 Kronkorken, Start-Schatz, Level 1); `SaveSchema.migrate(raw: any): SaveData`.

- [ ] **Step 1: Failing tests (Review Focus 4):** `migrate(nil) = default`; `migrate({}) = default`; `valid v1 data unchanged`; `negative caps -> 0`; `non-number caps -> 0`; `unknown treasure ids dropped, valid ids kept`; `treasures beyond capacity of baseLevel are kept (nicht verloren)`; `baseLevel clamped to 1..2`; `missing version treated as v0 and upgraded to current`; `output always has all four fields`.
- [ ] **Step 2:** Run → FAIL. **Step 3:** Implementieren. **Step 4:** Run → PASS.
- [ ] **Step 5: Commit** `feat: save schema with migration`

### Task 10: Speichern mit ProfileStore

**Files:**
- Create: `src/server/DataService.luau`, `src/shared/Packages/ProfileStore.luau`
- Modify: `src/server/Main.server.luau`, `TreasureService`, `BaseService`

**Interfaces:**
- Consumes: `SaveSchema`.
- Produces: `DataService.load(player: Player): SaveData?` (nil → Spieler wird mit Hinweis gekickt, **nie** mit leerem Stand weiterspielen lassen), `DataService.get(player: Player): SaveData?`, `DataService.release(player: Player)`.

- [ ] **Step 1:** ProfileStore (aktuelle Version aus dem offiziellen Repo, Lizenz prüfen) als Datei einchecken; Version und Quelle in Kommentar am Dateikopf vermerken.
- [ ] **Step 2:** `DataService`: Profil laden mit Session-Lock, `SaveSchema.migrate` auf die Daten, Auto-Save alle `AUTOSAVE_SECONDS`, bei `PlayerRemoving` und `game:BindToClose` speichern/freigeben. DataStore-Studio-Zugriff in den Spiel-Einstellungen aktivieren (Spiel einmal privat veröffentlichen).
- [ ] **Step 3:** Verdrahten: `caps`, besessene Schätze und `baseLevel` werden beim Betreten aus `SaveData` aufgebaut und bei Änderungen in `get(player)` nachgeführt.
- [ ] **Step 4: Manuell prüfen:** Spielen, Schatz klauen, Server beenden, neu starten → Kronkorken, Schätze, Level sind da. Zweites Fenster mit demselben Konto (Session-Lock) überschreibt nichts. Studio-Beenden mitten im Spiel verliert höchstens den letzten Auto-Save-Zeitraum.
- [ ] **Step 5: Commit** `feat: persistent saves via ProfileStore`
- [ ] **Step 6 (Playtest + Video):** Zweiter Playtest (3–5 Leute), Clips für das Woche-3-Video, Bug-Liste in `STATUS.md`.

---

# Woche 4: Öffentlich machen

### Task 11: Ausbaustufe und Einführung

**Files:**
- Modify: `src/server/BaseService.luau`, `src/client/Hud.luau`; Create: `tests/upgrade.spec.luau` (nutzt `Economy`)

**Interfaces:**
- Produces: `Economy.canUpgrade(baseLevel: number, caps: number): boolean` (Level 1 → 2 kostet `UPGRADE_COST`, Level 2 ist Maximum); Event `RequestUpgradeBase()`.

- [ ] **Step 1: Failing tests:** `canUpgrade false below cost`, `true at cost on level 1`, `false on level 2 (max)`. **Step 2:** Run → FAIL. **Step 3:** In `Economy` implementieren, `BaseService` zieht Kronkorken ab, schaltet Slots 5–8 frei. **Step 4:** Run → PASS.
- [ ] **Step 5:** 3 Hinweise im Spiel (erste Sekunden): „Hol dir Müll in der Mitte“, „Halte E bei fremdem Müll zum Klauen“, „Kauf Bananenschalen gegen Diebe“ – kurze Einblendungen, überspringbar.
- [ ] **Step 6: Commit** `feat: base upgrade and onboarding hints`

### Task 12: Handy-Test, Veröffentlichung, Zahlen

**Files:**
- Modify: `STATUS.md`

- [ ] **Step 1:** Studio-Geräte-Emulator (Handy): Klau-Taste per Touch halten funktioniert, Fortschrittsbalken lesbar, HUD verdeckt nichts. Fehler beheben (Review Focus 5).
- [ ] **Step 2:** Icon und Thumbnail (Thumbnail aus Spiel-Screenshot, Text nachträglich einfügen; Bild lokal sichern, nicht nur im ChatGPT-Verlauf).
- [ ] **Step 3:** Roblox-Altersfreigabe-Fragebogen ausfüllen, Titel/Beschreibung ohne falsche Versprechen, Spiel auf **öffentlich** stellen, Max. Spieler 6.
- [ ] **Step 4:** Mindestens 5 Personen außerhalb des engsten Kreises einladen; Analyse-Seite öffnen und Zahlen (Besuche, Spieldauer, Wiederkehr) in `STATUS.md` notieren.
- [ ] **Step 5:** Prüfpunkt nach 4 Wochen gegen Spec Abschnitt 8 abhaken (alle fünf Kriterien) und die Entscheidung über Kanal 2 in `STATUS.md` festhalten.
- [ ] **Step 6: Commit** `chore: publish prototype, record week-4 checkpoint`
- [ ] **Step 7 (Video):** Woche-4-Video mit ehrlichen Zahlen.

---

## Self-Review

- **Spec-Abdeckung:** Map/6 Baue (T3), Währung/Einkommen (T2, T4), 8–10 Schätze + 3 Seltenheiten (T2), Klauen mit Server-Prüfungen (T5, T6), Bananenschale (T7), Ansagen/Effekte (T8), Speichern mit Versionsnummer und Bibliothek (T9, T10), Ausbaustufe, Einführung, Handy-Test, Veröffentlichung, Prüfpunkt (T11, T12), Besitzregeln inkl. Verlassen (T5, T6), Toolbox-Skripte (Global Constraints), Rhythmus/Videos (Wochen-Schritte + `video-workflow.md`).
- **Typ-Konsistenz:** `Config`-Namen, `Rarity`, `StealRequest`-Felder und Remote-Namen sind in Task 2/3/5 definiert und in den späteren Tasks gleich benannt.
- **Bewusste Grenze:** Roblox-spezifischer Code (Services, UI, Physik) ist nicht automatisiert testbar, daher Checklisten statt Unit-Tests. Regeln, die Cheaten oder Datenverlust verhindern, sind dagegen rein und getestet.
- **Offene Annahme:** Toolnamen/Versionen (Rokit, Lune, Rojo, ProfileStore) vor Nutzung in Task 1/10 gegen die aktuelle Doku prüfen.
