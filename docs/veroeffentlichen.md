# Trash Bandits auf Roblox veröffentlichen

> Von Codex geschrieben (Auftrag 3, 21.11.2026). **Claude hat die Angaben zu Roblox-Menüs und -Regeln nicht selbst gegen die Live-Oberfläche geprüft.** Beim ersten Durchgehen jeden Klickpfad mit dem echten Bildschirm abgleichen und Abweichungen hier notieren.

Offizielle Roblox-Dokumentation abgerufen am **21. November 2026**. Die Klickpfade verwenden die englischen Menünamen. Studio und Creator Dashboard können je nach Sprache, Konto und Rollout leicht anders aussehen.

## 1. Das Spiel privat hochladen

1. Öffne in Roblox Studio die lokale `Muellbanditen.rbxl`. Verbinde Rojo und prüfe einmal im Explorer, ob Map und aktuelle Skripte im Place sind.
2. Gehe zu **File → Publish**. Die Schaltfläche kann auch **Publish to Roblox** bzw. **Auf Roblox veröffentlichen** heißen. Wähle beim ersten Hochladen die Erstellung eines neuen Spiels. Gib **Trash Bandits**, den richtigen Besitzer und eine kurze Beschreibung ein. Bestätige mit **Save** bzw. **Create**.
3. Neue Spiele starten mit eingeschränktem Zugriff. Prüfe im Creator Dashboard unter **Creations → Trash Bandits → Publish settings → Manage Audience**, dass der Zugriff beim Playtest bleibt. Für einen Freund kannst du dort **Early testers** verwenden. Wähle den öffentlichen Zugriff erst in Schritt 7. [Publizieren und Zugriff](https://create.roblox.com/docs/production/publishing/publish-games-and-places)

## 2. Echtes Speichern in Studio testen

1. Öffne im privat publizierten Testspiel **File → Experience Settings → Security**. Aktiviere **Enable Studio Access to API Services** und speichere.
2. Starte **Play** und öffne **Output**. Der Server muss `Using the REAL DataStore "PlayerData"` melden. Eine Meldung mit **MOCK** bedeutet, dass der Teststand beim Stoppen verloren geht.
3. Verdiene Kronkorken und lege einen Schatz im eigenen Bau ab. Notiere Kronkorken, Schätze und Ausbaustufe. Drücke **Stop**, warte auf das Ende der Sitzung und starte nochmal **Play**. Vergleiche den geladenen Stand. Nutze dabei dasselbe Roblox-Konto und dieselbe Experience.
4. Studio und Roblox-Server derselben Experience greifen auf denselben DataStore zu. Lass den Zugriff bei einer separaten privaten Test-Experience an und schalte ihn für **Trash Bandits** beim öffentlichen Start aus. Teste die Veröffentlichung danach auch in der Roblox-App. [DataStores in Studio](https://create.roblox.com/docs/cloud-services/data-stores#enable-studio-access)

## 3. Sechs Spieler pro Server einstellen

Öffne im Creator Dashboard **Trash Bandits → Configurations → Places**. Klicke den mit einem Stern markierten Start-Place an. Gehe zu **Access**, setze **Maximum Visitor Count** auf **6** und klicke **Save Changes**. Prüfe das Limit auf einem neu gestarteten Server. Die sechs Baue in der Map legen das Plattformlimit nicht fest. [Spielerlimit im Creator Dashboard](https://create.roblox.com/docs/chat/voice-chat#set-maximum-players)

## 4. Altersfreigabe ausfüllen

1. Öffne **Publish settings → Content ratings → Get a rating**. Die Seite kann noch **Maturity & Compliance** heißen. Prüfe bei fehlendem Button unter **Game details**, ob Name, Beschreibung und Genre gesetzt sind.
2. Der Fragebogen fragt, welche Inhalte auftreten, wie deutlich sie sind und wie häufig sie vorkommen. Je nach Version erscheinen Fragen zu Gewalt, Blut, Schreckmomenten, vulgärem Humor und weiteren Themen. Zähle auch seltene Szenen, wenn Spieler sie erleben können. Prüfe bei **Trash Bandits** besonders, wie die Bananenstürze, der Diebstahl und eventuelle spätere Effekte tatsächlich dargestellt werden. Nutze für Grenzfälle die Beispiele im Fragebogen. Die Einstufung ergibt sich aus deinen Antworten.
3. Kontrolliere die Vorschau und klicke **Send**. Unter 18 kann die Ermittlung der Einstufung laut Roblox einige Tage dauern. Reiche den Fragebogen erneut ein, wenn ein Update eine Antwort ändert. [Fragebogen und Einstufung](https://create.roblox.com/docs/production/promotion/content-ratings)

## 5. Icon und Thumbnail hochladen

- **Icon.** Exportiere ein quadratisches Bild mit mindestens **512 × 512 px**. Prüfe, ob das Motiv auch klein erkennbar ist. Öffne **Configurations → Places → Start-Place → Icon → Image → Change**. Wähle die Datei und speichere. Das Icon erscheint für andere nach der Moderation. [Roblox-Icons](https://create.roblox.com/docs/production/publishing/experience-icons)
- **Thumbnail.** Exportiere einen echten Spielausschnitt in **16:9**, idealerweise **1920 × 1080 px** als PNG oder JPG. Lass wichtige Schrift und Motive vom unteren Rand weg. Öffne **Configurations → Places → Start-Place → Thumbnails** und lade das Bild für die **Experience Detail Page** hoch. Die **Home Page** hat eigene Platzierungen. Nutze für beide Bilder eigene oder freigegebene Inhalte und zeige nur Spielinhalte, die Spieler erwarten können. [Roblox-Thumbnails](https://create.roblox.com/docs/production/publishing/thumbnails)

## 6. Titel und Beschreibung festlegen

Unter **Publish settings → Game details** kannst du Titel und Beschreibung korrigieren. Nutze **Trash Bandits** und beschreibe die Funktionen, die in der hochgeladenen Version spielbar sind. Vermeide Versprechen über Belohnungen, Updates oder Spielmodi, die diese Version noch nicht bietet. [Namen und Beschreibungen](https://create.roblox.com/docs/production/publishing/publish-games-and-places#name-and-description)

> Hunt for trash treasures, steal loot from rival bases, and carry it home to earn bottle caps. Buy banana peels to trip thieves and upgrade your base for more room.

## 7. Öffentlichen Zugriff freigeben

1. Speichere in Studio die geprüfte Version über **File → Publish**. Bei der ersten öffentlichen Freigabe kann Studio die Frage zu altersbeschränkten Inhalten anzeigen. Antworte anhand der tatsächlichen Inhalte.
2. Gehe im **Creator Dashboard → Trash Bandits → Publish settings → Manage Audience → Manage access** zum Reiter **Public**. Lass **Friends** aus, wenn auch Personen außerhalb deiner Freundesliste spielen sollen. Speichere mit **Save Changes**. Kontrolliere danach von einem zugelassenen Roblox-Konto ohne Editierrechte, ob die Spielseite den Start erlaubt.
3. Für die dokumentierte 16+-Freigabe nennt Roblox ein Konto in gutem Zustand, mindestens zwei Tage Kontolaufzeit, eine Altersprüfung und Angaben zum Inhalt. Für **Kids und Select** gelten zusätzliche Anforderungen, darunter Altersverifizierung (unter 18 per Gesichtsaltersschätzung), Zwei-Faktor-Authentifizierung, der vollständige Fragebogen, eine geeignete Einstufung und die Roblox-Prüfung. Die Dokumentation nennt außerdem ein zweimonatiges berechtigtes Abo oder eine einmalige erstattbare Veröffentlichungsgebühr als Optionen für diese zusätzliche Reichweite. Prüfe, welches Publikum dein Dashboard tatsächlich freigibt, bevor du einen Termin ankündigst. [Öffentliche Freigabe und Voraussetzungen](https://create.roblox.com/docs/production/publishing/publish-games-and-places#release-requirements)

## 8. Besuche, Spielzeit und Wiederkehr ansehen

- **Besuche.** Schau auf der Roblox-Spielseite bei **Visits**, wenn du die Gesamtzahl sehen willst. Im Creator Dashboard unter **Analytics → Acquisition** kannst du sehen, aus welchen Quellen Nutzer kamen und gespielt haben. Die dort gezeigten eindeutigen Nutzer sind eine andere Kennzahl als die Gesamtbesuche. Der genaue Name einer Besuchs- oder Sitzungskennzahl im Dashboard kann sich ändern. [Acquisition](https://create.roblox.com/docs/production/analytics/acquisition)
- **Spielzeit.** Öffne **Analytics → Engagement** und suche **Average Session Time**. Das ist die durchschnittliche Dauer eines Spielbesuchs. Wähle oben den Zeitraum für deinen Playtest. [Engagement](https://create.roblox.com/docs/production/analytics/engagement)
- **Wiederkehr.** Öffne **Analytics → Retention**. **D1**, **D7** und **D30** zeigen, welcher Anteil neuer Spieler nach einem, sieben oder dreißig Tagen wiederkommt. Nach einem kurzen Playtest können spätere Werte noch fehlen. [Retention](https://create.roblox.com/docs/production/analytics/retention)
