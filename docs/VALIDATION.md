# Prüfung 0.8 — Living Industry

- 220 Regelprüfungen: zusätzlich volles Sägespäne-Lager, korrekte Überlaufmenge, optionaler Verkauf, Weiterverarbeitung und Wiederanlauf einer gespeicherten Firma mit 2.500 Holz/Sägespänen. Restore kopiert Daten unabhängig, ohne den geladenen Ausgangsstand zu verändern.
- 56 Platzierungs-/Einführungsprüfungen: Straßen/Wasser/Überlappung, kostenlose abgebrochene Vorschau, bezahlte Baustelle, gesperrte doppelte Platzierung, Rotation und gespeicherter Standort, kostenloses Verschieben samt Erhalt von Stufe/Geld, frei positionierte Häuser, altes Profil ohne Zwangstutorial, neue Einführung, Spänebox und Förderverbindungen mit Straßendurchfahrt.
- Weiterhin 4.135 Szenen-/Geometrieprüfungen, frischer Verlauf bis zum ersten Haus und abschließender Hauptszenenstart.
- OpenGL-Bilder von frischer Welt, Baukatalog, Platzierungsvorschau, Willkommen und ausgebautem Demonstrationsstand geprüft.
- Android-Updateprüfung: neue Versionsnummer 800, unveränderte Paketkennung und bisheriger Testsignaturschlüssel. Paket- und Downloadprüfung werden beim finalen Export erneut ausgeführt.
- Finaler APK-Export bestanden: 56.560.193 Bytes, SHA256 `25a7303854a39a72907f661d5fe026d9c4eeb90b65121d17264ee34986cb04f1`, Quell-Commit `7b091d0b96638f3921eb0962abff77964a5e3d4d`. Signatur stimmt mit der gespeicherten 0.7-APK überein; keine Android-Berechtigungen, ARM64/ARMv7, OpenGL, Hochformat und 16-KB-ZIP-Ausrichtung geprüft.
- Grenzen: echte Touch-/Installations-/Leistungsprüfung auf einem Telefon bleibt offen. Förderstrecken zeigen aktive Produktion und gemeinsame Materialpuffer; es gibt keine zusätzliche Fahrzeugkollision oder diskrete Simulation jedes einzelnen Bretts.

Der folgende Bericht dokumentiert den ursprünglichen 0.7-Meilenstein; seine Hashwerte beziehen sich auf diese ältere Fassung.

# Prüfbericht zum Wiederaufbau

Stand: 19. Oktober 2026. Godot 4.6.3, GDScript; Version 0.7.0-test.

## Automatisierte Prüfungen

- **207 Regelprüfungen, keine Fehler:** Rucksack und Lagergrenzen; echte Ein-/Ausgänge der Verarbeitung; atomare Bezahlung; laufender Bau und Upgrades; doppelte Aufträge; Miete; Forschung; 100 Loot-Ziehungen; Boosterablauf; einmalige Missions-/Auftragsprämien; identische Vordergrund-/Offline-Simulation; Prestige und steigende Kosten; Crafting; Ausrüsten; permanente Loot-Upgrades; Regionen; Materialreservierung und automatische Einzelbestellung; drei Projektstufen; faire Materialzuteilung unabhängig von Betriebsreihenfolge; Save/Load und beschädigtes Hauptsave mit Backup-Fallback.
- **Frischer Spielverlauf:** Das erste Haus wird ohne Geld-/Materialgeschenke nach 1.682 simulierten Sekunden fertig. Danach erwirtschaftet es Ertrag. Startbedingungen sind dieselben wie im Spiel. Die Teststeuerung verwendet normale Aktionen, Aufträge und Verkäufe.
- **4.135 Szenen-/Geometrieprüfungen, keine Fehler:** Zehn Waldgruppen mit zusammen 1.000 Bäumen; Bäume auf Land und abseits der Straßen/Zufahrten; mobile Menüs und Grundstücksauswahl; aktiver Materialplaner; sofort sichtbare bezahlte Baustelle und Entfernung des Gerüsts nach Abschluss; Baumabbau; Welt-/Heimkamera und kleines Fenster.
- **Hauptszene:** Abschließender Headless-Start ohne GDScript-/Laufzeitfehler.
- **Echte Bildausgabe:** OpenGL-Start unter Xvfb und Mesa llvmpipe; frische Welt, ausgebauter Demonstrationsstand und Industrie-Menü aufgenommen und visuell geprüft. Dabei gefundener Kopfbereich-Umbruch korrigiert. Desktop-Audio im Capture-Lauf auf Dummy gesetzt; die selbst erzeugten Audio-Wellen sind implementiert, Lautsprecher wurden hier nicht geprüft.

## Android

Signierter Debug-Export für ARM64/ARMv7. APK-Integrität, Signatur, 16-KB-ZIP-Ausrichtung, Android 7.0+, Hochformat, OpenGL und keine angeforderten Berechtigungen werden im Build-Skript geprüft. Der endgültige Hash steht bei der APK im Paketbericht. Kein echter Handy-/Emulator-Starttest.

## Sicherung

Git-Meilensteine werden zum Repository übertragen. Abschließend wird aus GitHub in ein neues Verzeichnis geklont, der gespeicherte Stand geprüft und die APK mit dem lokalen SHA256 verglichen. Quell-ZIP und vollständiges Git-Bundle mit SHA256-Manifest ergänzen die externe Git-Sicherung. Ein nicht bestätigter Push gilt nicht als Sicherung.

Ergebnis der Wiederherstellungsprüfung: GitHub-Commit `6d4d65f65cc9d35ff635ec25a42084b29c53449b` wurde erfolgreich nach `/workspace/timber-restore-check` geklont. Dort bestand die vollständige Testsuite erneut (207 Regeln, frischer Verlauf, 4.135 Szenen-/Geometrieprüfungen, abschließender Start). Die zurückgeladene APK stimmt mit SHA256 `893e4ec1ea95a18881d1abf9ee0ac8caf16797699fd1d3bbb908755a4788041e` überein.

Beide direkten HTTPS-Downloads von `raw.githubusercontent.com` wurden vollständig abgerufen: APK HTTP 200, 56.531.203 Bytes; Quell-ZIP HTTP 200, 763.308 Bytes. Beide SHA256-Werte entsprechen `releases/SHA256SUMS.txt`. Das Quellarchiv enthält 43 Dateien, einschließlich Hauptszene, Regeln, Tests und Build-Helfern, ohne Cache, APK oder privaten Schlüssel.

## Offene Nachweise

Kein 50-Stunden-Spieltest, kein Android-Leistungs-/Akkuprofil, keine abschließende Touch-/Safe-Area-/Hintergrundprüfung, keine iOS-/Store-Freigabe. Die erwähnten 28 Minuten sind simulierte Wirtschaft, kein gemessener menschlicher Spieldurchlauf. Screenshots des ausgebauten Gebiets belegen die Darstellung und keine erspielte Progression.
