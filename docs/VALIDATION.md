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

## Offene Nachweise

Kein 50-Stunden-Spieltest, kein Android-Leistungs-/Akkuprofil, keine abschließende Touch-/Safe-Area-/Hintergrundprüfung, keine iOS-/Store-Freigabe. Die erwähnten 28 Minuten sind simulierte Wirtschaft, kein gemessener menschlicher Spieldurchlauf. Screenshots des ausgebauten Gebiets belegen die Darstellung und keine erspielte Progression.
