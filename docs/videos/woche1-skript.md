# Woche 1 Video: Skript-Entwurf (Englisch, zum Sprechen)

**Thema laut Spec:** „Ich habe noch nie ein Projekt beendet. Jetzt baue ich ein Roblox-Spiel.“
**Länge:** ca. 3 bis 4 Minuten. **Sprache im Video: Englisch.** Dieses Dokument ist die Stütze, gesprochen wird in deinen eigenen Worten und in deinem Tempo. Streich alles, was sich falsch anfühlt.
**Video-Tag:** Sonntag (Vorschlag der Spec, du kannst ihn ändern). Ein rohes, kurzes Video ist besser als keins.

> Ehrlicher Hinweis zum Stil: Dein Schreibstil-Profil kennt bisher nur formelle E-Mails. Das hier ist kein Text „in deiner Stimme“, sondern ein einfacher Entwurf. Lies ihn einmal laut und ändere jeden Satz, bei dem du dich verstellst.

## Entscheidung für dich, bevor du aufnimmst
Das Video sagt, dass der Code von einer KI geschrieben wird. Das stimmt, und es ist der ehrlichste Weg (Zuschauer merken es sowieso). Wenn du das nicht sagen willst, streich den Abschnitt „How I build it“. Meine Empfehlung: drin lassen. Du entscheidest das Spiel, die KI tippt.

## Skript

### 1. Hook (0 bis 10 s)
*Bild: ein Clip, in dem ein grauer Waschbär jemandem einen Schatz klaut und dann auf einer Bananenschale ausrutscht.*

> I have never finished a project. Not one. This time I'm building a whole Roblox game, and I'll show you every week how it goes.

### 2. Das Spiel (10 bis 40 s)
*Bild: Flug über die graue Map, die 6 Baue, der Müllwagen-Platz in der Mitte.*

> The game is called Müllbanditen. You play a raccoon. Every few seconds a garbage truck dumps treasure in the middle: old socks, pizza boxes, sometimes a golden toaster.
>
> You carry it home and it earns you bottle caps. But the other raccoons can steal it from your base. And you can put banana peels in their way.

### 3. Warum ich das mache (40 bis 70 s)
*Bild: Studio, Rojo, der Code im Hintergrund, ruhig.*

> I start a lot of things and finish almost none. So this time I made a deal with myself. Ninety days. One game. One video every week, even if it's rough.
>
> If it fails, you will see that too.

### 4. How I build it (70 bis 110 s) *(optional, siehe Entscheidung oben)*
*Bild: Claude Code im Terminal, daneben Studio.*

> I'm new to Roblox and Lua, so I don't write the code myself. An AI writes it, and I decide what the game should be. I also check that it really works, because the AI can be wrong.
>
> The first rule: the server decides everything. Money, who owns what, who stole what. Your computer only asks.

### 5. Was diese Woche passiert ist (110 bis 190 s)
*Bild: drei graue Test-Spieler in Studio. Hier die Clips aus dem Mehrspieler-Test zeigen.*

> This week I got the whole base game running, without any good graphics yet.
>
> Every player gets their own base. Treasure falls in the middle, you pick it up and carry it home. Stealing takes one and a half seconds of holding a button. If the owner runs into you, you drop it.
>
> Then I tested the hard cases. What if two players steal the same thing at the same moment? Only the first one gets it. What if the thief leaves the game while carrying it? It goes back to the owner. Nothing gets lost.

*Optional, ein lustiger Moment (nimm den, der wirklich passiert ist):*

> And then the banana peel. It threw my test player way too high, and he landed on the other side of the base. I'm keeping it. It's funny.

### 6. Was noch fehlt, ehrlich (190 bis 215 s)
> Right now it looks like a grey box. There is no real menu yet, no sound, and I haven't played it with a real person. That's next.

### 7. Ausblick (215 bis 230 s)
> Next week my brother and I play it for the first time. I expect it to break. See you then.

## Titel-Vorschläge (3 Varianten)
1. `I've never finished a project. So I'm making a Roblox game.`
2. `Day 1 of 90: raccoons, garbage and banana peels (Roblox devlog)`
3. `Making a Roblox game where you steal trash from your friends`

Tipp: Titel 3 sagt in einer Zeile, was das Spiel ist. Titel 1 ist stärker für den Kanal. Teste beide im Kopf: Würdest du darauf klicken?

## Kapitel
- 0:00 The hook
- 0:10 The game
- 0:40 Why I'm doing this
- 1:10 How I build it
- 1:50 What I built this week
- 3:10 What's missing
- 3:35 Next week

## Clips, die du noch aufnehmen musst (ca. 30 Minuten, OBS, Replay-Puffer an)
Nichts davon ist bisher aufgenommen. Das geht alles in Studio, ohne Freunde:
1. **Map-Flug:** Studio-Kamera über die 6 Baue und den Abladeplatz (10 s).
2. **Müllwagen:** Schätze erscheinen am Abladeplatz (10 s).
3. **Aufheben und Heimtragen:** ein Spieler trägt einen Schatz, über dem Kopf schwebt er (10 s).
4. **Klau:** Mehrspieler-Test (Server und Clients, 3 Spieler), ein Spieler klaut einem anderen den Schatz (15 s).
5. **Bananenschale:** ein Spieler rutscht aus und fliegt durch die Luft (10 s). Das ist dein bester Clip.
6. **Studio-Test-Ansicht:** drei Fenster nebeneinander (5 s), sieht nach „echtes Entwickeln“ aus.

Hinweis: Das Spiel hat noch keine UI. Auf den Clips sieht man Namensschilder über den Schätzen und die Roblox-Hinweise „Grab“ und „Drop here“, aber keine Kronkorken-Anzeige. Das ist ok und wird im Video offen gesagt. Mit Codex-UI werden die Clips schöner. Nimm sie lieber danach auf, wenn die UI bis Sonntag fertig ist, sonst jetzt und im nächsten Video die UI zeigen.
