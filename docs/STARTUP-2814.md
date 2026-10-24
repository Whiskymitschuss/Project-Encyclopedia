# Bibercover und direkter Spielstart · 0.28.14-alpha.1

Der bisherige kleine Schaukasten und die zeitgesteuerte Introfolge entfallen.
Ein eigenes bildschirmfüllendes Biber-Waldmotiv mit getrenntem scharfem
Timber-Loot-Schriftzug orientiert sich am Aufbau der gewünschten Referenz.
Das Motiv ist ebenfalls der native Engine-Splash statt des kleinen App-Icons.

Die Ladeanzeige liegt unten. Die Hauptwelt wird per Godot-Threaded-Resource-
Loading vorbereitet. Nach abgeschlossener Offline-Berechnung wird die echte
Hauptszene direkt geöffnet. Es gibt keine zusätzliche viersekündige Introfrist
und keinen erforderlichen Weiterspielen-Tipp beim normalen App-Start.

Eine ausdrückliche Rückkehr aus dem Spielmenü hält den Startbildschirm mit
„Weiterspielen“ an. Der zugehörige Sitzungszustand ist nicht im Spielstand.
Fehler zeigen „Erneut versuchen“. Bei beschädigten Speicherdateien bleibt der
Start bis zur ausdrücklichen Wiederherstellung gesperrt. Die bisherigen
Archivierungs- und Speicherfunktionen bleiben maßgeblich.

Die Offline-Nachrechnung verwendet denselben Hintergrund. Die Anzeige stammt
weiter direkt vom tatsächlichen Worker. Teilberechnungen dürfen weiterhin
keinen vorhandenen Spielstand überschreiben. Das neue Bild verändert weder
Produktion noch Nachrechnung und ist kein Nachweis einer kürzeren Ladezeit
auf einem echten Handy. Es wird kein zusätzlicher 3D-Schaukasten instanziiert.

[Gestaltungsbuch und Gebäudekonzepte](DESIGN-DIRECTION-2814.md) ·
[Quellprüfungen](alpha1-loading/automated-checks.json) ·
[Prüfungen der tatsächlichen APK-Dateien](alpha1-loading/packaged-checks.json).

Die neue Gebäudetafel zeigt drei Sägewerkformen, Möbelwerk, Zentrallager und
Rathaus als künftige Modelliergrundlage. Die vorhandenen 3D-Gebäude und der
zuletzt vorgeschlagene Ausbau der Produktionsautomatik sind mit diesem
Startupdate noch nicht ersetzt beziehungsweise umgesetzt.

Android-Code 3009. Gleiches Paket und bisheriges Testzertifikat.
Als Update installieren; nicht deinstallieren und keine App-Daten löschen.
Kein physischer Android-/Hitzetest und keine Prüfung privater Handyspielstände.
