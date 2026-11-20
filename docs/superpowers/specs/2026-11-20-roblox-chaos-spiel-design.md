# Design: Roblox-Chaos-Spiel (Arbeitstitel „Müllbanditen“)

- **Datum:** 2026-11-20
- **Status:** Vom Nutzer freigegeben am 2026-11-20 (Antworten siehe Ende von Abschnitt 9)
- **Für wen:** den Nutzer (Entscheidungen) und den Builder (Claude Code auf dem Windows-Laptop, der daraus einen Umsetzungsplan macht)
- **Wichtig:** Alles, was mit **[VORSCHLAG]** markiert ist, hat der Nutzer noch nicht entschieden. Der Builder darf damit planen, aber Woche 1 startet erst, wenn der Nutzer den Themen-Twist bestätigt oder ausgetauscht hat.

---

## 1. Intent: Worum geht es, und warum?

Der Nutzer pausiert alle anderen Projekte und baut ein Roblox-Spiel. Er ist Anfänger in Roblox und Lua, nach eigener Aussage sehr zerstreut und hat bisher kein Projekt bis zum Ende durchgezogen.

Die eigentlichen Ziele, ehrlich sortiert:

1. **Durchziehen.** Zum ersten Mal ein Projekt so weit bringen, dass fremde Menschen es benutzen. Das ist das wichtigste Ziel. Ein mittelmäßiges, aber veröffentlichtes Spiel ist ein Erfolg. Ein geniales Spiel, das bei 70 % liegen bleibt, ist ein Misserfolg.
2. **Reichweite über den Devlog.** Die Entwicklung wird gefilmt (ohne Gesicht) und auf Kanal 1 veröffentlicht. Der Devlog ist ein eigenes Produkt und kein Nebenprodukt. Er funktioniert auch dann, wenn das Spiel floppt („Ich habe versucht, ein Roblox-Spiel zu bauen, und das ist passiert“).
3. **Ein Spiel mit echten Spielern.** Nicht nur Freunde, sondern Fremde, die freiwillig wiederkommen.

Das Warum hinter dem Genre: Das Umfeld des Nutzers spielt viel Roblox und kennt „Steal a Brainrot“. Klau- und Chaos-Spiele erzeugen von selbst lustige Momente (jemand klaut dir in letzter Sekunde etwas, jemand rutscht auf deiner Falle aus). Solche Momente lassen sich als Clips verwenden, und Spieler laden Freunde ein, um sich gegenseitig zu ärgern. Das passt zu beiden Kanälen.

## 2. Ziele, Nicht-Ziele, Anti-Ziele

### Ziele (in Reihenfolge)

- In 4 Wochen: ein **öffentlich spielbarer Prototyp** auf Roblox, den mindestens 5 Personen außerhalb des engsten Freundeskreises gespielt haben.
- In 4 Wochen: **4 veröffentlichte Devlog-Videos** auf Kanal 1 (eins pro Woche).
- In 90 Tagen: kein neues Projekt anfangen. Am Ende von Woche 12 eine ehrliche Weiter-oder-Stopp-Entscheidung anhand der Kriterien in Abschnitt 8.
- Nebenbei: Lua/Luau und Roblox Studio so weit lernen, dass der Nutzer den Code, den Claude schreibt, grob versteht und kleine Änderungen selbst machen kann.

### Nicht-Ziele (bewusst nicht jetzt)

- Geld verdienen. Game Passes oder Shops kommen frühestens nach Woche 4 und nur, wenn Spieler wiederkommen.
- Ein großes, schönes Spiel mit vielen Maps, Events und Skins.
- Kanal 2 (Spiel-Kanal) vor dem ersten spielbaren öffentlichen Stand.
- Eigene 3D-Modelle oder Animationen in den ersten 4 Wochen. Einfache Formen und geprüfte Gratis-Assets reichen.
- Bezahlte Tools, Werbung oder Sponsoring in den ersten 4 Wochen.
- Agenten-Setups, Plugins, Automatisierung rund um Claude Code am Anfang.

### Anti-Ziele (Misserfolg, auch wenn technisch alles läuft)

- **Ein Brainrot-Klon mit anderem Anstrich.** Wenn jemand das Spiel in 10 Sekunden als „Steal a Brainrot, nur mit X“ beschreibt und nichts Eigenes merkt, ist das Thema gescheitert.
- **Ein Spiel, das nur Spaß macht, wenn der Nutzer selbst mitspielt** oder seine Freunde vorher eingewiesen werden.
- **Feature-Sammlung statt Spiel.** 15 halbfertige Systeme, aber der Kernloop (klauen, zurückbringen, verteidigen) fühlt sich nicht gut an.
- **Dark Patterns gegenüber Kindern.** Die Roblox-Zielgruppe ist zum großen Teil jung. Kein Druck zum Kaufen, kein Pay-to-win, keine künstlichen Wartezeiten, die nur mit Robux verschwinden.
- **Video-Hamsterrad.** Wenn Videos so viel Zeit fressen, dass am Spiel nichts mehr passiert, oder umgekehrt Videos ausfallen, weil „das Spiel noch nicht so weit ist“.
- **Das Projekt stirbt still.** Kein öffentliches Ende, keine Entscheidung, nur weniger Commits. Auch ein Stopp nach 12 Wochen soll ein bewusster Schritt sein (mit Abschlussvideo).

## 3. Constraints (Rahmenbedingungen)

| Bereich | Rahmen | Folge für das Design |
|---|---|---|
| Können | Anfänger in Roblox Studio und Lua | Wenige, einfache Systeme. Jede Woche nur ein neues technisches Konzept. |
| Fokus | Sehr zerstreut, bisher nie durchgezogen | Kleiner Umfang, feste Wochen-Deadline (Video), Ideen-Parkplatz statt sofort umsetzen, 90-Tage-Commitment. |
| Geld | Kein Startkapital, keine Ausgaben in den ersten 4 Wochen | Nur kostenlose Tools. Keine Werbung auf Roblox, d. h. Spieler kommen nur über Freunde, Videos und organische Empfehlung. |
| Hardware | Windows-Gaming-Laptop als Hauptgerät | Roblox Studio läuft nur dort. Alles (Studio, Claude Code, OBS, Schnitt) läuft auf diesem einen Gerät. |
| Werkzeuge | Roblox Studio, VS Code + Rojo, Git/GitHub, OBS, DaVinci Resolve oder CapCut | Code liegt als Dateien in Git, Rojo überträgt ihn nach Studio. Map und Modelle liegen in der Studio-Datei. |
| KI | Opus für Design, Architektur, harte Bugs. Sonnet für Routine-Lua. ChatGPT Plus (bis Januar) für Thumbnails und Bilder. | **Nichts darf von einem Abo abhängen:** Code ist normales Luau in Git, Bilder werden lokal gespeichert, keine Pipeline braucht ein bestimmtes KI-Abo. |
| Zeit | Viel Zeit vorhanden | Gefahr: viel Zeit verleitet zu großem Umfang. Der Umfang bleibt trotzdem klein. |

## 4. Approaches: Welche Wege wurden betrachtet?

### A: Tycoon/Simulator (verworfen als Hauptspiel)

Klicken oder sammeln, Geld verdienen, Basis ausbauen.
- **Vorteil:** technisch am leichtesten, kaum Multiplayer-Logik, viele Tutorials.
- **Kosten:** sehr gesättigter Markt, wenig spontane Clip-Momente, Spieler brauchen sich gegenseitig nicht. Für den Devlog langweilig („heute habe ich einen weiteren Knopf gebaut“).
- **Was davon übernommen wird:** Währung, passives Einkommen und Basis-Ausbau als **Bindungsschicht** (Grund, morgen wiederzukommen). Dieser Teil ist technisch einfach und bewährt.

### B: Kurzes Chaos-/Klau-Spiel mit eigenem Thema (gewählt)

Spieler haben eine Basis mit wertvollen Dingen, klauen sich gegenseitig Dinge und verteidigen sich mit Fallen.
- **Vorteil:** Spieler-gegen-Spieler-Momente entstehen von selbst. Gut für Clips, gut für „hol deine Freunde dazu“. Das Genre ist bei der Zielgruppe gerade bekannt.
- **Kosten:** mehr Multiplayer-Logik als A, das Klauen muss gegen Cheater abgesichert werden (Abschnitt 6), das Spiel braucht genug Spieler pro Server, um zu funktionieren. Außerdem Klon-Gefahr, wenn das Thema zu dünn ist.
- **Warum trotzdem B:** Es ist der einzige Weg, bei dem Spiel und Devlog sich gegenseitig helfen. Der Mehraufwand gegenüber A ist überschaubar, wenn der Prototyp klein bleibt.

### C: Obby (Hindernis-Parcours) (verworfen)

- **Vorteil:** sehr einfach zu bauen, kein Speichern nötig.
- **Kosten:** extrem gesättigt, kaum Wiederspielwert, Freunde einladen bringt wenig. Clips gibt es, aber die sind austauschbar.

**Entscheidung:** B, mit A-Elementen (Währung, Einkommen, Ausbau) als Bindungsschicht.

## 5. Spielkonzept

### 5.1 Themen-Twist [VORSCHLAG, muss vom Nutzer bestätigt werden]

Das Thema muss drei Dinge leisten: sofort verständlich für Kinder und Teenager, von sich aus lustig (ohne dass man es erklären muss) und es muss eine Mechanik mitbringen, die es bei Brainrot nicht gibt.

**Twist 1: Müllbanditen (Waschbären-Bande) – Empfehlung**
Jeder Spieler ist ein Waschbär mit eigenem Bau. In der Mitte kommt regelmäßig ein Müllwagen und kippt „Schätze“ ab: Pizzakartons, alte Socken, ein goldener Toaster. Jeder Schatz hat eine Seltenheit und bringt im Bau Kronkorken pro Sekunde. Man klaut sich gegenseitig den Müll und legt Bananenschalen als Falle aus.
- *Warum gut:* Tiere und Müll sind sofort lustig und kinderfreundlich. Die Sammel-Lust (seltene Dinge) bleibt, aber die Gegenstände sind eigene Witze statt Memes, die in 3 Monaten tot sind. Ausrutschen, Stinkbomben, Mülltonnen-Deckel sind von sich aus Slapstick und damit Clip-Material. Es braucht keine Gegner-KI, nur Spieler. Technisch der einfachste der drei Twists.
- *Schwäche:* Der Grundaufbau (Basis, Gegenstände mit Seltenheit, passives Einkommen, klauen) ist Brainrot sehr ähnlich. Das Eigene muss über Humor (Gegenstände, Sounds, Waschbär-Animationen) und die Fallen kommen. Das ist eine echte Klon-Gefahr, die beim Playtest geprüft werden muss (Abschnitt 8).

**Twist 2: Mitternachts-Snackraub**
Spieler sind Kinder in einem riesigen dunklen Haus und klauen sich gegenseitig Snacks aus den Kinderzimmern. Lärm (quietschende Dielen, Spielzeug auf dem Boden) weckt „Mama“, einen Nicht-Spieler-Charakter, der den lautesten Spieler zurück ins Bett schickt, wobei der seine Beute verliert.
- *Warum gut:* Die Lärm-Mechanik ist wirklich eigen und erzeugt Spannung (Schleichen) plus Schadenfreude (erwischt werden). Sehr starkes Video-Thema.
- *Schwäche:* braucht eine Gegner-KI (Wegfindung, Lärm-Erkennung) und gute Beleuchtung. Für einen Anfänger in 4 Wochen zu viel. Gute Idee für später oder als Event.

**Twist 3: Gartenzwerg-Krieg**
Nachbarn klauen sich gegenseitig Gartenzwerge aus den Vorgärten. Geklaute Zwerge schreien und verraten den Dieb; Rasensprenger und Gartenschläuche als Verteidigung.
- *Warum gut:* absurd, gut lesbar, „schreiender Zwerg“ ist ein guter Gag.
- *Schwäche:* Das Thema trägt weniger lange (Zwerge sind ein Witz, kein Sammelsystem), und die Seltenheiten wirken beliebiger als beim Müll.

**Empfehlung:** Twist 1 (Müllbanditen), weil er in 4 Wochen machbar ist und trotzdem eigenen Humor hat. Die Lärm-Idee aus Twist 2 wird auf den Ideen-Parkplatz gelegt; eine abgespeckte Version („klappernde Mülltonne verrät dich“) kann später als Falle dazukommen.

> Der Rest dieses Dokuments verwendet Twist 1. Wählt der Nutzer einen anderen Twist, bleiben Kernloop, Architektur und Wochenplan gleich; nur Namen, Gegenstände und die Falle ändern sich.

### 5.2 Kernloop in 60 Sekunden

1. **0–10 s:** Spieler spawnt in seinem Bau, sieht seine 2–3 Müll-Schätze, die Kronkorken produzieren. Oben läuft der Zähler.
2. **10–25 s:** Der Müllwagen kippt in der Mitte neuen Müll ab. Alle rennen hin. Wer zuerst da ist, schnappt sich etwas und trägt es nach Hause.
3. **25–45 s:** Auf dem Rückweg oder danach: In einem fremden Bau liegt ein seltener Schatz. Der Spieler schleicht hin, hält die Taste gedrückt, klaut ihn und rennt (verlangsamt, gut sichtbar für alle) zurück.
4. **45–55 s:** Der Besitzer merkt es (Warnsignal), jagt hinterher. Berührt er den Dieb, fällt der Schatz runter. Oder der Dieb rutscht auf einer Bananenschale aus, die der Besitzer gelegt hat.
5. **55–60 s:** Schatz ist sicher im eigenen Bau, Einkommen steigt. Mit Kronkorken kauft man Fallen oder baut den Bau aus. Wiederholen.

Der Loop braucht **mindestens 3–4 Spieler pro Server**, sonst gibt es niemanden zum Beklauen. Das ist ein bekanntes Risiko (Abschnitt 8).

### 5.3 Minimaler Prototyp (Ziel bis Ende Woche 4)

| Baustein | Genau eins | Inhalt |
|---|---|---|
| Map | 1 Map | Ein Hinterhof oder eine Gasse, 6 Baue im Kreis um einen Abladeplatz in der Mitte. Einfache Formen, wenig Deko. |
| Währung | Kronkorken | Kommen nur aus Schätzen im eigenen Bau (pro Sekunde). Werden gespeichert. |
| Gegenstände | ca. 8–10 Müll-Schätze in 3 Seltenheiten | gewöhnlich, selten, legendär. Einfache Modelle mit lustigem Namen. |
| Klau-Mechanik | Schnappen und Tragen | In fremdem Bau Taste ca. 1,5 s halten → Schatz wird getragen → Träger ist langsamer und sichtbar markiert → Berührung durch den Besitzer lässt den Schatz fallen → gefallene Schätze gehen nach kurzer Zeit zurück. |
| Verteidigung | Bananenschale | Mit Kronkorken kaufen, bis zu 3 im eigenen Bau platzieren. Wer drauftritt, rutscht weg (ca. 2 s hilflos), verliert seine Beute, die Schale ist verbraucht. |
| Bindung (A-Schicht) | 1 Ausbaustufe | Bau vergrößern: mehr Plätze für Schätze. |
| Speichern | ja | Kronkorken, Schätze im Bau, Ausbaustufe. |

**Besitzregeln (damit der Builder nicht raten muss):**
- Müll auf dem Abladeplatz gehört niemandem, bis ihn jemand im eigenen Bau ablegt. Liegt er zu lange herum, verschwindet er.
- Ein erfolgreich geklauter Schatz gehört dauerhaft dem Dieb (wird bei ihm gespeichert, beim Opfer entfernt). Das ist der Kern des Spiels und erzeugt die Emotion.
- Damit niemand komplett leer ausgeht: Jeder Spieler bekommt beim ersten Betreten einen gewöhnlichen Start-Schatz, und der Müllwagen liefert regelmäßig Nachschub.
- Ist der eigene Bau voll, kann man nichts aufheben oder klauen (Anreiz zum Ausbau).
- Verlässt ein Spieler den Server, verschwindet sein Bau samt Schätzen von der Map; die Schätze bleiben in seinem Spielstand und sind beim nächsten Betreten wieder da. Offline kann also niemand beklaut werden.
- Verlässt ein Dieb den Server, während er trägt, geht der Schatz an den Besitzer zurück.

### 5.4 Ausdrücklich NICHT im ersten Prototyp

- Zweite Map, zweite Währung, Robux-Käufe, Game Passes, Handel zwischen Spielern
- Weitere Fallen (Stinkbombe, Mülltonnen-Deckel als Schloss, klappernde Tonne) → Ideen-Parkplatz
- Rebirth/Prestige, Ranglisten, tägliche Belohnungen, Quests, Events
- Eigene Animationen, eigene 3D-Modelle, Charakter-Skins
- Gegner-KI / Nicht-Spieler-Charaktere
- Optimierung für Konsole/VR (Handy-Steuerung nur so weit, wie Roblox sie von selbst liefert; kurz testen, weil viele Roblox-Spieler am Handy sind)
- Schloss/Schutzschild für den Bau (z. B. Mülltonnen-Deckel); im Prototyp schützen nur Bananenschalen und Hinterherrennen

### 5.5 Clipbare Momente gezielt designen

Clips entstehen nicht zufällig, man kann sie planen. Regeln für jede Mechanik:

1. **Sichtbarkeit:** Ein Dieb mit Beute muss für alle erkennbar sein (Schatz über dem Kopf, Leuchten, Ton). Wer etwas klaut, soll gesehen werden, sonst gibt es keine Verfolgungsjagd.
2. **Knappes Ende:** Einstellungen so wählen, dass viele Diebstähle knapp ausgehen (Tragegeschwindigkeit leicht unter Laufgeschwindigkeit). „Fast geschafft“ ist der beste Clip.
3. **Übertriebene Reaktion:** Ausrutschen ist nicht nur ein kurzes Stolpern, sondern der Waschbär fliegt durch die Luft, mit Geräusch und kurzer Textanzeige („AUSGERUTSCHT!“). Übertreibung ist billig und wirkt stark.
4. **Umkehrung:** Wer gerade klaut, ist selbst verwundbar (sein Bau ist leer, er ist langsam). Das erzeugt „Rache“-Momente.
5. **Ansage für alle:** Seltene Ereignisse werden serverweit angesagt („Jemand hat den GOLDENEN TOASTER geklaut!“). Damit wissen alle, wo es spannend wird, und der Moment ist im Video ohne Erklärung verständlich.
6. **Lesbar ohne Ton und Kontext:** Ein Clip muss in 5 Sekunden verständlich sein, auch stumm auf dem Handy.
7. **Für den Devlog:** Bei jedem Playtest OBS mitlaufen lassen (Replay-Puffer), damit gute Momente nicht verloren gehen.

## 6. Technische Grobarchitektur (in einfachen Worten)

### 6.1 Server und Client

- **Server** = der Roblox-Rechner, auf dem das Spiel für alle läuft. **Er ist der Schiedsrichter.** Er weiß, wem welcher Schatz gehört, wie viele Kronkorken jemand hat, wer gerade was trägt.
- **Client** = das Gerät des Spielers. Er zeigt an, nimmt Tastendrücke an und **bittet** den Server um Aktionen („ich möchte diesen Schatz nehmen“). Er entscheidet nichts Wichtiges selbst.
- Die Kommunikation läuft über Roblox-Nachrichten zwischen Client und Server (RemoteEvents). Jede Nachricht vom Client ist eine Bitte, keine Tatsache.

### 6.2 Exploit-Risiken beim Klauen

Cheater können auf ihrem Gerät beliebige Nachrichten an den Server schicken und sich teleportieren oder schneller laufen. Ein Klau-Spiel ist dafür besonders anfällig. Daher prüft der Server bei jeder Klau-Bitte selbst:

- Steht der Spieler wirklich nah genug am Schatz?
- Gehört der Schatz jemand anderem, und trägt der Spieler gerade nichts?
- Hat er die Taste lange genug gehalten (Server misst die Zeit, nicht der Client)?
- Ist er nicht zu schnell unterwegs (grober Geschwindigkeits-Check beim Tragen)?
- Wartezeiten zwischen Aktionen werden auf dem Server gezählt.

Grundregel: **Geld, Besitz und Ergebnisse werden nie vom Client übernommen.** Der Client schickt nie „ich habe jetzt 5000 Kronkorken“.

Zweites Risiko: **Gratis-Modelle aus der Roblox-Toolbox** können versteckte Skripte (Hintertüren) enthalten. Nur Modelle ohne Skripte verwenden oder Skripte vor dem Einbau löschen.

Ehrlich: Ein Anfänger-Spiel wird nie völlig cheat-sicher. Ziel ist, dass die offensichtlichen Tricks nicht funktionieren.

### 6.3 Datenspeicherung

- Gespeichert wird pro Spieler: Kronkorken, welche Schätze im Bau liegen, Ausbaustufe. Mehr nicht.
- Speichern beim Verlassen des Spiels und zusätzlich automatisch alle paar Minuten (falls der Server abstürzt).
- Roblox bietet dafür eine eingebaute Speicherfunktion (DataStores). Sie funktioniert in Studio nur, wenn das Spiel veröffentlicht ist (privat reicht) und der API-Zugriff in den Spiel-Einstellungen eingeschaltet ist.
- Größtes Risiko: **Datenverlust** (z. B. wenn ein Spieler schnell den Server wechselt und alte Daten neue überschreiben). Dafür gibt es bewährte kostenlose Bibliotheken; der Builder entscheidet, ob er eine nutzt (Empfehlung: ja, statt selbst zu bauen).
- Speicher-Format von Anfang an mit einer Versionsnummer versehen, damit spätere Änderungen alte Spielstände nicht kaputtmachen.

### 6.4 Arbeitsweise mit den Werkzeugen

- Code liegt als Dateien in einem Git-Repository (GitHub), wird in VS Code bzw. von Claude Code geschrieben und per Rojo live in Roblox Studio übertragen.
- Map, Modelle und Sounds liegen in der Studio-Datei (.rbxl). Diese Datei regelmäßig sichern (mindestens nach jedem Arbeitstag, z. B. ebenfalls in Git oder als datierte Kopie).
- Kleine Commits mit verständlichen Nachrichten. Commits sind auch Devlog-Material („was habe ich diese Woche gemacht“).
- Testen in Studio mit mehreren simulierten Spielern (Studio kann mehrere Test-Spieler lokal starten). Echter Multiplayer-Test mit Freunden über ein privat veröffentlichtes Spiel.

## 7. 4-Wochen-Plan

Grundregeln für jede Woche:
- **Video-Deadline ist fest** (Wochentag vom Nutzer festzulegen). Das Video zeigt, was da ist, auch wenn es kaputt ist. „Es hat nicht funktioniert“ ist ein gutes Video.
- **Zeitbudget:** grob 70 % Spiel, 30 % Video. Wenn das Video mehr frisst, wird es einfacher, nicht später.
- **Ab Tag 1 aufnehmen:** OBS läuft bei jeder Arbeitssitzung (oder zumindest der Replay-Puffer).
- **Ideen-Parkplatz:** Neue Ideen werden in eine Liste geschrieben, nicht umgesetzt. Am Ende jeder Woche wird höchstens eine Idee in die nächste Woche übernommen, wenn der Wochenplan sonst erfüllt ist.
- **Jede Woche endet mit etwas Spielbarem**, das man jemand anderem zeigen kann.

### Woche 1: Fundament

- **Spielbar am Ende:** Eine graue Map mit 6 Bauen und Abladeplatz. Jeder Spieler bekommt beim Betreten einen Bau. Der Müllwagen (oder zunächst einfach ein Spawn-Punkt) wirft alle X Sekunden einen Schatz ab. Man kann ihn aufheben und im eigenen Bau ablegen. Schätze erzeugen Kronkorken, der Zähler ist sichtbar. (Noch kein Klauen, kein Speichern.)
- **Technisch neu:** Setup (Studio, VS Code, Rojo, Git), Server/Client-Grundprinzip.
- **Video-Thema:** „Ich habe noch nie ein Projekt beendet. Jetzt baue ich ein Roblox-Spiel, 90 Tage.“ Warum, das Konzept, das Setup, der erste graue Prototyp. Das Versprechen an die Zuschauer ist gleichzeitig die eigene Verpflichtung.

### Woche 2: Klauen

- **Spielbar am Ende:** Schätze aus fremden Bauen klauen (Taste halten, tragen, verlangsamt, sichtbar), Besitzer kann den Dieb durch Berührung stoppen, Schatz fällt und kehrt zurück. Server-Prüfungen aus 6.2 sind drin. **Erster Playtest mit 3–5 Leuten aus dem Umfeld.**
- **Technisch neu:** Kommunikation Client → Server, Server-Prüfungen.
- **Video-Thema:** „Ich habe meine Freunde mein (kaputtes) Spiel testen lassen.“ Echte Reaktionen, echte Bugs, was gelernt wurde.

### Woche 3: Fallen, Gefühl und Speichern

- **Spielbar am Ende:** Bananenschale kaufen und platzieren, Ausrutschen mit übertriebener Reaktion, Sounds und serverweite Ansagen (Abschnitt 5.5), Speichern von Kronkorken, Schätzen und Ausbaustufe. Seltenheiten (3 Stufen) und 8–10 Schätze mit Namen.
- **Technisch neu:** Speichern (DataStore), einfache Physik-Effekte.
- **Video-Thema:** „Ich habe eine Falle gebaut, die mein Spiel kaputt gemacht hat“ (oder was immer beim Bauen schiefgeht). Gute Clips aus dem zweiten Playtest.

### Woche 4: Öffentlich machen

- **Spielbar am Ende:** 1 Ausbaustufe für den Bau, kurze Einführung im Spiel (3 Hinweise, keine Textwand), Icon und Thumbnail, Spiel ist **öffentlich**. Mindestens 5 Personen außerhalb des engsten Kreises haben es gespielt. Altersfreigabe-Fragebogen von Roblox ausgefüllt. Kurzer Handy-Test.
- **Technisch neu:** Veröffentlichung, Roblox-Analyse-Seite (Spielerzahlen, Spielzeit, Wiederkehr) lesen lernen.
- **Video-Thema:** „Mein erstes Roblox-Spiel ist online. Hier sind die (ehrlichen) Zahlen.“ Danach Entscheidung über den Start von Kanal 2 (Abschnitt 8).

**Puffer:** Wenn eine Woche nicht fertig wird, wird der Umfang der nächsten Woche gekürzt, nicht der Plan verschoben. Kürzungs-Reihenfolge, falls nötig: Ausbaustufe → Ansagen → Anzahl der Schätze. Nie gekürzt werden: Klauen, Bananenschale, Speichern, öffentlich machen, Video.

## 8. Risiken und ehrliche Einschätzung

### Die Wahrheit über Roblox

- Die allermeisten Roblox-Spiele haben nach dem Start fast keine Spieler. Das ist der Normalfall, nicht Pech. Ohne Werbebudget kommen Spieler nur über Freunde, Videos und den Roblox-Empfehlungsalgorithmus, und der reagiert vor allem auf Spieldauer und Wiederkehr, die ein neues Spiel erst beweisen muss.
- Klau-Spiele haben ein Henne-Ei-Problem: Ein leerer Server ist langweilig, also gehen Spieler wieder, also bleibt er leer. Gegenmaßnahmen: wenige Plätze pro Server (z. B. 6), damit sich Spieler sammeln; feste Playtest-Termine; das Spiel muss auch zu zweit wenigstens ein bisschen funktionieren (Müllwagen-Rennen).
- Geld: Selbst erfolgreiche kleine Spiele verdienen anfangs wenig, und die Auszahlung von Robux in echtes Geld hat hohe Mindestgrenzen. Geld ist in diesem Projekt kein realistisches 12-Wochen-Ziel.
- Trend-Risiko: Das Klau-Genre kann in wenigen Monaten abflauen. Deshalb ein eigenes Thema und deshalb der Devlog als zweites Standbein.

### Persönliche Risiken (größer als die technischen)

| Risiko | Warum wahrscheinlich | Gegenmaßnahme |
|---|---|---|
| Aufgeben in Woche 2–3 („das Tal“) | Neuheit ist weg, Bugs nerven, wenig Fortschritt sichtbar | Video-Deadline, öffentliches Versprechen im ersten Video, kleine Wochenziele |
| Neue Projekt-Idee lockt | Zerstreutheit, Muster aus der Vergangenheit | 90-Tage-Regel, Ideen-Parkplatz, neue Idee höchstens als Notiz |
| Umfang wächst | Viel Zeit, viele Ideen, KI schreibt schnell Code | Liste „NICHT im Prototyp“ (5.4) gilt bis Woche 4 strikt |
| Code verstehen ist zu schwer | Claude schreibt, Nutzer versteht nicht mehr, was passiert | Kleine Schritte, Claude erklärt jedes neue System kurz in einfachen Worten; Nutzer macht pro Woche mindestens eine kleine Änderung selbst |
| Videos fressen alle Zeit | Schnitt ist zeitaufwendig | 30-%-Budget, einfaches Format, lieber kürzer |
| Tool-Bastelei statt Spiel | Setup-Optimierung fühlt sich produktiv an | Kein Agenten/Plugin-Overhead; Setup ist in Woche 1 auf 1–2 Tage begrenzt |
| Abo endet (ChatGPT im Januar) | festes Datum | Alle Bilder lokal speichern; Thumbnails notfalls aus Spiel-Screenshots + kostenlosem Bildprogramm |

### Was Erfolg realistisch bedeutet

- **Realistischer Erfolg nach 12 Wochen:** Ein öffentliches Spiel, das ein paar Dutzend bis wenige hundert Fremde gespielt haben, eine kleine Gruppe kommt wieder, 12 Devlog-Videos, ein Kanal mit erstem Publikum, und der Nutzer hat zum ersten Mal etwas durchgezogen.
- **Großer Erfolg** (tausende gleichzeitige Spieler) ist möglich, aber unwahrscheinlich, und darf nicht der Maßstab sein.

### Prüfpunkt nach 4 Wochen

Weiter, wenn **alle** zutreffen:
- 4 Videos sind online.
- Das Spiel ist öffentlich und mindestens 5 Fremde haben es gespielt.
- Mindestens 2 Playtester wollen ungefragt nochmal spielen oder haben jemanden eingeladen.
- Kein Playtester beschreibt es ausschließlich als „wie Brainrot“.
- Der Nutzer will selbst weitermachen.

Wenn das Spiel-Kriterium scheitert, aber die Videos laufen: Thema oder Mechanik anpassen, nicht das Projekt wechseln (die 90 Tage gelten). Wenn die Videos fehlen: das ist das ernstere Warnsignal, weil es den Durchhalte-Mechanismus betrifft.

**Kanal 2** startet frühestens nach dem Prüfpunkt nach 4 Wochen und nur, wenn mindestens ein paar Fremde das Spiel wiederholt spielen. Vorher gibt es dort nichts, was Zuschauer halten würde.

### Prüfpunkt nach 12 Wochen (Weiter-oder-Stopp)

Anhaltspunkte (Richtwerte, keine harten Grenzen; der Builder/Nutzer liest die echten Zahlen auf der Roblox-Analyse-Seite):
- Kommen Spieler am nächsten Tag wieder? Ein merklicher Teil (grob jeder Zehnte oder mehr) ist ein gutes Zeichen für ein kleines Spiel.
- Spielen Leute im Schnitt länger als ein paar Minuten (grob 8–10 Minuten oder mehr)?
- Wächst die Zahl der Besuche ohne dass der Nutzer jeden Spieler persönlich einlädt?
- Wächst der Devlog-Kanal (Abos, Aufrufe pro Video steigend)?

Mögliche Ergebnisse: **weitermachen** (Spiel ausbauen, Kanal 2 hochfahren), **Spiel einfrieren, Devlog weiter** (nächstes Spiel mit dem Gelernten, als Fortsetzung des Kanals) oder **bewusst beenden** mit Abschlussvideo. Alle drei sind legitim. Nicht legitim ist stilles Einschlafen.

## 9. Was der Builder entscheidet, und offene Fragen an den Nutzer

### Dem Builder überlassen

- Ordnerstruktur, Rojo-Projektaufbau, Aufteilung in Module
- Ob eine fertige Speicher-Bibliothek genutzt wird (Empfehlung: ja) und welche
- Genaue Zahlen: Einkommen pro Schatz, Haltezeit beim Klauen, Geschwindigkeiten, Preise, Abwurf-Intervall (Startwerte setzen, im Playtest anpassen)
- Umsetzung des Ausrutschens (echte Physik oder einfacher Wegschleuder-Effekt)
- Aussehen der Anzeige (Zähler, Hinweise), Auswahl der Gratis-Assets (mit Skript-Prüfung)
- Wie die .rbxl-Datei gesichert wird
- Aufteilung der Aufgaben auf Opus/Sonnet nach der Regel in Abschnitt 3
- Zerlegung jeder Woche in Tagesaufgaben

### Offene Fragen an den Nutzer (nur er kann sie beantworten)

1. **Themen-Twist:** Bestätigst du „Müllbanditen“ (Twist 1), oder lieber Twist 2/3 oder eine eigene Idee? (Blockiert Woche 1.)
2. **Zeit pro Woche:** Wie viele Stunden kannst du realistisch pro Woche arbeiten? (Bestimmt, ob der 4-Wochen-Umfang passt.)
3. **Starttag und Video-Tag:** An welchem Datum beginnen die 90 Tage, und an welchem Wochentag erscheint das Video?
4. **Playtester:** Wer genau testet in Woche 2 (Namen oder Anzahl, ungefähres Alter), und wann können sie?
5. **Videos:** Auf Deutsch oder Englisch? Mit deiner Stimme, Text-Einblendungen oder KI-Stimme? (Beeinflusst Aufwand und Reichweite stark.)
6. **Roblox-Konto:** Hast du ein Konto, mit dem du Spiele veröffentlichen kannst (Alter, Verifizierung), oder muss das noch eingerichtet werden?

### Antworten des Nutzers (2026-11-20) und Entscheidungen daraus

1. **Twist:** „Müllbanditen“ bestätigt.
2. **Zeit:** bis zu 14 h/Woche bei wenig Schulstress. **Planungswert: 8–10 h/Woche** (Claudes Call, damit Schulwochen den Rhythmus nicht brechen; alles darüber ist Bonus).
3. **Starttag/Video-Tag:** Nutzer hat keine Präferenz genannt. **Claudes Vorschlag:** Start Montag, Video-Tag Sonntag. Nutzer kann ändern.
4. **Playtester:** Zwillingsbruder für Woche 2. Fremde ab Woche 4.
5. **Videos:** Nutzer will nicht selbst schneiden, Sprechen ist okay. Erste 4 Wochen: eigene Stimme als Voice-over, Schnitt weitgehend automatisiert (siehe `docs/videos/video-workflow.md`).
6. **Roblox-Konto:** vorhanden.

### Entscheidung zur Sprache (2026-11-20, nach Rückfrage)

Nutzer entscheidet: **alles auf Englisch** (Spiel-Texte, Schatz-Namen, Ansagen, Videos mit Voice-over, Titel, Kanalnamen). Ersetzt die frühere Annahme „Devlog Deutsch + englische Untertitel“. Die Dokumente im Repo bleiben auf Deutsch (nur für den Nutzer), alles, was Spieler oder Zuschauer sehen, ist Englisch. Der Nutzer will UI-Texte und Sprecher-Skripte von Claude gegenlesen lassen.
