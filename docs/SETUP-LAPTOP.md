# Setup auf dem Gaming-Laptop (Windows), einmalig, max. 1–2 Stunden

Ziel: Studio, Rojo und Claude Code laufen auf einem Gerät. Nichts Weiteres installieren.

## 1. Programme (alle kostenlos)
1. **Roblox Studio** (mit deinem Konto anmelden) – roblox.com/create
2. **Git** – git-scm.com
3. **VS Code** – code.visualstudio.com
4. **OBS Studio** – obsproject.com
5. **Claude Code** – Installationsanleitung auf docs.claude.com (Abschnitt „Claude Code“). Dort steht der aktuelle Weg für Windows.

## 2. Projekt holen
```bash
git clone https://github.com/user122313/user122313.git muellbanditen
cd muellbanditen
git checkout claude/charming-euler-3z2iul
```

## 3. Werkzeuge für Rojo und Tests
Plan Task 1, Step 1: **Rokit** installieren (Anleitung im Rokit-Repository: `rojo-rbx/rokit`), dann im Projektordner:
```bash
rokit add rojo-rbx/rojo
rokit add lune-org/lune
```
Prüfen:
```bash
rojo --version
lune --version
lune run tests/run
```
Erwartet: `68 passed, 0 failed`. Wenn ein Paketname abweicht, steht der aktuelle Name in der Rojo/Lune-Doku. Sag Claude Bescheid, er korrigiert den Plan.

## 4. Studio verbinden
1. Studio öffnen → neues Baseplate → als `place/Muellbanditen.rbxl` im Projektordner speichern.
2. Im Projektordner `rojo serve` starten (Fenster offen lassen).
3. In Studio das **Rojo-Plugin** installieren (Plugin-Leiste → Marketplace → „Rojo“) und **Connect** klicken.
4. Play drücken. Im Output soll „Müllbanditen läuft“ stehen. Dann steht das Setup.

## 5. Claude Code starten
Im Projektordner `claude` starten und sagen: „Lies docs/superpowers/plans/2026-11-20-muellbanditen-prototyp.md und STATUS.md und mach mit Task 3 weiter.“

## Regeln
- Jeden Arbeitstag am Ende: `.rbxl` speichern und committen, `STATUS.md` aktualisieren lassen.
- Neue Ideen nur in `IDEEN.md`.
- OBS-Replay-Puffer (30–60 s) einschalten, bevor du anfängst.
