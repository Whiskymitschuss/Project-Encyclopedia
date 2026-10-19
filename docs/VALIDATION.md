# Prüfung 0.9 — Open Workshop

- Bestehende 220 Regel-, 4.135 Szenen-/Geometrie- und 56 Platzierungs-/Einführungsprüfungen unverändert im Umfang bestanden. Der frische Verlauf erreicht das erste Haus weiter nach 1.682 simulierten Sekunden ohne Zusatzressourcen.
- 40 zusätzliche Werkstattprüfungen: tatsächlich leere Maschine steht; echte Umwandlung treibt das Sägeblatt an; sofortige Pause friert Werkzeug und Werkstück ein; Materialmangel stoppt; ein Bediener arbeitet passend zur Maschine; alle acht Produktionsarten werden auf Stufen 1/10/100 instanziiert, ohne Ressourcen zu ändern; HUD bleibt bei drei Bildschirmgrößen innerhalb der Zeichenfläche.
- OpenGL-Bildausgabe unter Mesa/Xvfb: neuer Einstieg, offene Säge, Stadtansicht, Baukatalog, Platzierung und Willkommen aufgenommen. Die ausgebaute Welt und Materialvorräte sind ausschließlich ein Demonstrationsprofil des Capture-Skripts; kein bestehender Nutzerspielstand wird dafür geändert.
- Schema 1, Speicherdatei und Paketkennung unverändert. Paket/Versionscode 900, v2-Signatur und 16-KB-ZIP-Ausrichtung geprüft; Zertifikat stimmt mit 0.8 überein. Aus GitHub neu nach `/workspace/timber-restore-09` geklont; alle 4.451 Prüfungen, der frische Verlauf und der Hauptszenenstart erneut bestanden. Reale Geräteinstallation, Touch und mobile Leistung dieser Version sind noch nicht geprüft.
- Die Referenzbilder dienen als Richtung für offene Produktionsflächen und übersichtliche Bedienung. Modelle und Symbole sind eigene Geometrie/Vektoren. Es werden keine Screenshots oder Spielressourcen fremder Spiele in die App eingebunden.

## Auslieferungsstand 0.9

- Quell-Commit: `8a9f0eb7f1486d1d5b1f24616f057d718c3e62be`.
- APK: 56.577.150 Bytes, SHA256 `9ec4fe4252eb8914b908a50f0fa935b181a1e693f0def026e8f9420e379a15c1`.
- Quell-ZIP: 62 Dateien, 1.569.317 Bytes, SHA256 `6bc0400009cd0a514d63d338275179f5ccebc7cf52701264482c0b3bfec5fc4f`. Jede Datei gegen Git-Blob des APK-Quellstands geprüft.
- Zertifikat SHA256: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005` (unverändert).
- Beide externen HTTPS-Downloads vom unveränderlichen Tag `v0.9.0-workshop` vollständig mit HTTP 200 zurückgeladen und SHA256 mit den Originaldateien verglichen. Auch die APK und ZIP aus der unabhängigen GitHub-Kopie stimmen überein. Bericht: `download-verification-09.json`.

## Historischer Prüfbericht 0.8

# Prüfung 0.8 — Living Industry

- 220 Regelprüfungen: zusätzlich volles Sägespäne-Lager, korrekte Überlaufmenge, optionaler Verkauf, Weiterverarbeitung und Wiederanlauf einer gespeicherten Firma mit 2.500 Holz/Sägespänen. Restore kopiert Daten unabhängig, ohne den geladenen Ausgangsstand zu verändern.
- 56 Platzierungs-/Einführungsprüfungen: Straßen/Wasser/Überlappung, kostenlose abgebrochene Vorschau, bezahlte Baustelle, gesperrte doppelte Platzierung, Rotation und gespeicherter Standort, kostenloses Verschieben samt Erhalt von Stufe/Geld, frei positionierte Häuser, altes Profil ohne Zwangstutorial, neue Einführung, Spänebox und Förderverbindungen mit Straßendurchfahrt.
- Weiterhin 4.135 Szenen-/Geometrieprüfungen, frischer Verlauf bis zum ersten Haus und abschließender Hauptszenenstart.
- OpenGL-Bilder von frischer Welt, Baukatalog, Platzierungsvorschau, Willkommen und ausgebautem Demonstrationsstand geprüft.
- Android-Updateprüfung: neue Versionsnummer 800, unveränderte Paketkennung und bisheriger Testsignaturschlüssel. Paket- und Downloadprüfung werden beim finalen Export erneut ausgeführt.
- Finaler APK-Export bestanden: 56.560.291 Bytes, SHA256 `37c679d49c73a17f3d4672b9e4328060e47034bc9a9e86f58db01bdb967fffb1`, Quell-Commit `dfcaff6d05191fdd12b949b8eeec792eb6b24cc1`. Signatur stimmt mit der gespeicherten 0.7-APK überein; keine Android-Berechtigungen, ARM64/ARMv7, OpenGL, Hochformat und 16-KB-ZIP-Ausrichtung geprüft.
- Grenzen: echte Touch-/Installations-/Leistungsprüfung auf einem Telefon bleibt offen. Förderstrecken zeigen aktive Produktion und gemeinsame Materialpuffer; es gibt keine zusätzliche Fahrzeugkollision oder diskrete Simulation jedes einzelnen Bretts.

Wiederherstellung 0.8: Der frische GitHub-Klon `/workspace/timber-restore-08` wurde bis zum Quell-Commit `dfcaff6d05191fdd12b949b8eeec792eb6b24cc1` aktualisiert. Darin bestanden alle 220 Regel-, 4.135 Szenen-/Geometrie- und 56 Platzierungs-/Einführungsprüfungen, der frische Spielpfad und der Hauptszenenstart erneut.

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
