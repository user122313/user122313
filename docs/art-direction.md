# Art Direction: Trash Bandits (Entwurf, 22.11.2026)

Ziel: Ein klarer, einheitlicher Look, der mit einfachen Mitteln gut wirkt und auf Handys läuft. Roblox empfiehlt selbst, eine "visuelle Sprache" (Form, Farbe, Stil) festzulegen und in einem Style Guide zu notieren ([Choose an art style](https://create.roblox.com/docs/tutorials/curriculums/user-interface-design/choose-an-art-style)). Das hier ist unser Style Guide. **Nichts davon ist verbindlich, bis der Nutzer zustimmt.** Recherche und Quellen: Obsidian-Notiz `Roblox Wissen`.

## 1. Grundidee
"Verdreckter Schrottplatz im goldenen Abendlicht, aber lustig, nicht eklig." Dicke, leicht schiefe, abgerundete Formen. Die Umgebung ist gedämpft und schmutzig, **Wertvolles ist knallig**. So fallen Schätze, Fallen und UI sofort auf.

Regel: **Sättigung = Wert.** Nur Schätze, Fallen, Kronkorken und UI dürfen kräftige Farben haben. Alles andere bleibt gedämpft.

## 2. Farben
| Rolle | Farbe | Hinweis |
|---|---|---|
| Boden, Asphalt | 62, 65, 72 | schon drin |
| Umgebung (Rost, Oliv, Beige) | gedämpft, Sättigung niedrig | Container, Zaun, Kisten |
| Kronkorken und Hauptakzent | Orange 255, 153, 0 | aus `Theme.luau` |
| Selten | Blau 80, 170, 255 | `Theme.colors.rare` |
| Legendär | Gold 255, 205, 40 | `Theme.colors.legendary` |
| Gefahr, Alarm, Dieb | Rot 235, 70, 60 | `Theme.colors.danger` |
| Bau-Identität | 6 Farben der Baue | Tore, Randstreifen |
| Fallen | Bananengelb + Schwarz (Warnstreifen) | einheitlich für alle Fallen |

## 3. Formen
- **Umgebung:** Blöcke, Stapel, schiefe Türme. Viel Horizontales und Gestapeltes.
- **Schätze:** runder oder auffälliger als die Umgebung, jeder mit eigener Silhouette (Test: Schwarz-Weiß-Bild, erkennt man den Schatz?).
- **UI:** abgerundet, wie in `Theme.luau` (nicht die Formen der 3D-Welt kopieren, aber verwandt wirken).

## 4. Schätze (9 Stück, Stand 22.11.2026 erledigt)
Eigene Formen in `src/shared/TreasureLook.luau`. Seltene stehen auf einer Leuchtplatte, legendäre leuchten. **Als Nächstes:** leichtes Schweben und Drehen beim Abladeplatz, Funkeln bei legendären, kleiner Aufprall-Effekt beim Ablegen.

## 5. Fallen
- **Bananenschale (jetzt):** ein gelber flacher Block. **Besser:** gebogene Schale aus 3 bis 4 Teilen, gelb mit braunem Fleck, Warnglanz für den Besitzer.
- **Ausrutschen:** kleiner Sternenring um den Kopf, Drehung, "Boing"-Ton, Kamera-Wackeln (ist da, `Effects.luau`).
- **Entscheidung für den Nutzer:** Sollen Diebe Fallen sehen (fair, Spannung beim Vorbeischleichen) oder sollen sie versteckt sein (mehr Überraschung)? Empfehlung: sichtbar, aber unauffällig (gedämpftes Gelb), Besitzer sieht sie mit Leuchtrand.
- Spätere Fallen (Mausefalle, Leim, Klebeband): erst nach dem Playtest (`IDEEN.md`).

## 6. Figuren
- **Stufe 1 (günstig, Woche 2 bis 3):** normale Roblox-Avatare, dazu **Waschbär-Accessoires** (Ohren, Schwanz, Banditenmaske) automatisch angehängt. Funktioniert mit jedem Avatar, braucht nur ein paar Teile.
- **Stufe 2 (später):** eigene Waschbär-Figur. Technisch geht das über ein eigenes Modell mit R15-Knochennamen, Humanoid, HumanoidRootPart und passender HipHeight, Autoscaling aus ([Custom characters guide](https://devforum.roblox.com/t/custom-characters-guide/2825528), [Custom rigs ohne R15](https://devforum.roblox.com/t/custom-characters-without-humanoid-features/901531)). Das Modell muss in Blender oder per Assistant entstehen. Aufwand hoch, erst nach dem Playtest.
- Waschbär im Icon, Roblox-Figur im Spiel: ehrlich im Video erklären, bis Stufe 1 oder 2 da ist.

## 7. Effekte (VFX)
Bausteine: `ParticleEmitter`, `Beam`, `Trail`, Kamera-Wackeln. Achtung vor viel Überlappung transparenter Flächen, das kostet Leistung ([Roblox VFX Referenz](https://nonlooped.github.io/roblox-suite/skills/roblox-vfx), Community-Quelle). Liste:
- Kronkorken-Funkeln beim Verdienen, Dampf aus Kanaldeckeln, Staub bei Schritten auf dem Abladeplatz.
- Klau: Fortschrittsring (da), roter Alarm (da), Staubwolke beim Schnappen.
- Müllwagen: Auspuff-Rauch, Hupe, kippt Müll aus.
- Legendär: Lichtsäule und Banner (Banner da).

## 8. Sound (fehlt komplett)
Bedarf: Aufheben, Ablegen, Klau-Start (Schleife), Klau-Erfolg, Alarm, Ausrutschen (Quietschen + Boing), Kronkorken-Klimpern, Ausbau, Legendär-Fanfare, Müllwagen-Hupe, Ambiente (Wind, fernes Scheppern).
Quellen und Regeln (Quelle: [Roblox Audio-Doku](https://create.roblox.com/docs/audio/assets)): Eigene Audio nur mit Rechten, Roblox prüft automatisch auf Urheberrecht, und Sperren sind nicht anfechtbar. Kurze Effekte unter 10 Sekunden gibt es frei im Creator Store. **Zu klären:** ob KI-erzeugte Effekte (z. B. mit dem ElevenLabs-Skill) bei Roblox durch die Prüfung kommen und ob die Lizenz passt.

## 9. Müll-Atmosphäre (Props)
Müllberg als große Landmarke (Mitte hinter dem Abladeplatz oder Ecken), Reifenstapel, kaputter Kühlschrank, Matratze, Einkaufswagen, Eimer, Kisten, Paletten, Schlauch, Kanaldeckel mit Dampf, Pfützen, Graffiti-Tafeln, flackernde Neonschilder, Kabel, Fahnen aus Stoffresten, kaputte Autos am Zaunrand. Erzeugung: einfache Formen per Code (Skript `tools/DecorateMap.luau`), aufwendige Props mit `/generate` im Studio-Assistant.

## 10. Leistung (Handy zuerst)
Offiziell gibt es keine feste Teile-Grenze, nur Community-Richtwerte: spielbare Handy-Spiele haben 13.000 bis 25.000 Teile, Lichter mit Schatten sparsam (Richtwert 10 bis 20 pro Bereich), `CastShadows` bei kleinen Details aus, MeshParts statt Unions ([DevForum Performance](https://devforum.roblox.com/t/real-world-building-and-scripting-optimization-for-roblox/3127146)). Wir liegen bei 215 Dekoteilen und 18 Lichtern, das ist niedrig. **Prüfen:** im Emulator mit fester Grafikstufe und später auf einem echten Handy.

## 11. Arbeitspakete (in dieser Reihenfolge)
1. **Müll-Atmosphäre 2** (Claude, Code): Müllberge, Reifenstapel, Kühlschränke, Pfützen, Dampf, Neonschilder. Klein anfangen.
2. **`/generate` testen** (Nutzer tippt, Claude bewertet): 5 Props, nur die guten behalten, Dreiecke begrenzen.
3. **Bananenschale und Ausrutsch-Effekt** (Claude, Server/Effekte, kleiner Teil Codex für Client).
4. **Waschbär-Accessoires** (Claude).
5. **Sounds** (Nutzer entscheidet Quelle, Claude baut ein).
6. **Icon und Thumbnail neu** (nach 1 bis 3).
7. **Eigene Waschbär-Figur** (später, Blender oder Assistant).

Zuerst Playtest mit Bilal, bevor mehr als Paket 1 bis 3 gebaut wird.
