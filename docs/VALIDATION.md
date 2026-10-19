# Prüfung 0.12 — Waldleben

- 220 Regel-, 4.135 Szenen-, 56 Platzierungs-, 42 Werkstatt-, 23 Begleiter- und 30 neue Alltagsszenenprüfungen: 4.506 Headless-Prüfungen plus frischer erster-Haus-Verlauf und abschließender Start. Die unveränderte Wirtschaft erreicht das erste Haus weiterhin nach 1.682 simulierten Sekunden.
- Neue Prüfungen: kompatible alte Profile; keine Feier für Bestandsgebäude oder bloße Bauaufträge; Pausengast ohne zusätzliches Personal; Sitzpose/Tasse und Rückkehr; vollständiger Laufweg innerhalb des ursprünglichen und verschobenen/gedrehten Grundstücks; gegenseitige Begrüßung mit Abklingzeit; Schalter/Restore/Prestige; echte bezahlte Fertigstellung am gewählten Standort; begrenzte Zuschauer und fester Partikelpool; unveränderte Ressourcenrechnung; Akkumodus; Vorgartenspaziergang am tatsächlichen gedrehten Haus.
- Die bisherigen 23 echten OpenGL-Prüfungen für UI und Benno bestehen weiterhin. Bildausgabe von Hüttenvorplatz mit Pausengast und einer tatsächlich im Capture-Profil fertig gebauten Hütte geprüft. Beschriftung höher gesetzt, um Gebäudenamen nicht zu überdecken.
- Alle Capture-Bilder verwenden einen ausdrücklich aufgebauten Demonstrationsstand. Das Einfrieren des Pausengasts für das Foto verändert keine Nutzerdaten. Die Eröffnungsaufnahme verwendet einen bezahlten Bauauftrag und dessen echte Fertigstellung im Demonstrationsprofil.
- Der Nutzer hat Version 0.11 als auf seinem Handy funktionierend bestätigt. Für 0.12 sind reale Geräte-, Sound-, Temperatur- und längere Häufigkeitstests noch offen. Klang wird im Grafiktest mit Dummy-Audiotreiber erzeugt; hier wurden keine Lautsprecher geprüft.
- Straßennetze, Baukosten und Wirtschaft bleiben unverändert. Alltagsszenen sind kosmetisch, keine neue Schicht für Arbeitszeiten oder Fußgänger-Kollisionen. Park-/Hüttenausstattung ist Teil ihrer bestehenden Grundstücksfläche.

## Historischer Prüfbericht 0.11

# Prüfung 0.11 — Benno im Wald

- 220 Regel-, 4.135 Szenen-, 56 Platzierungs-, 42 Werkstatt- und 23 neue Begleiterprüfungen: zusammen 4.476 Headless-Prüfungen. Weiterhin frischer erster-Haus-Verlauf nach 1.682 simulierten Sekunden sowie abschließender Szenenstart.
- Begleiterprüfungen: kompatibles altes Profil, Begrüßung ohne Währungsänderung, Winkeauslöser, wegklickbare Blase, keine angebliche Fertigstellung bei bloßem Bauauftrag, Reaktion auf Fertigstellung, Menüs und Platzierung frei, Hinweise aus echtem Vorrat, Abschalten ohne Ereignisstau, Einstellung nach Restore/Prestige, erneutes Einschalten, nur einmaliger gleicher Tipp, tatsächlicher Offline-Bericht nur einmal und Rückkehrbegrüßung und korrekter Baum-Missionsschwelle nach Prestige.
- 23 OpenGL-Prüfungen: bisherige 3D-Menüs plus getrennte Portraitbeleuchtung, wirklich gerenderter transparenter Biber, sichtbare Silhouette und Änderung der gerenderten Pixel beim Winken.
- Begrüßung und Biber, Werkstatt, Baukatalog, Platzierung und neue Willkommen-Grafik unter OpenGL geprüft. Die fortgeschrittenen Capture-Bilder verwenden einen ausdrücklich aufgebauten Demonstrationsstand und eine inszenierte Feierblase; ihre Ressourcen sind kein Nutzerspielstand.
- APK-Gerätetest, Benachrichtigungen/Resume unter Android und langfristige Begleiterhäufigkeit bleiben auf Hardware zu prüfen. Kein Sprachsynthese-/Voiceover-System, keine Loginpflicht, keine täglichen Verluststrafen oder erzwungenen Belohnungsdialoge.

## Auslieferung 0.11

- APK-Quellstand: `66aab5d885a18d5446b4450fa6c9fc05724a7c5e`.
- APK: 58.102.026 Bytes, SHA256 `3588bc86c9f0364438e171aaed11e3dd8b9223bfe90c8d1add7a954c11b2997a`.
- Quell-ZIP: 82 Dateien, 2.580.510 Bytes, SHA256 `6f6e72f015b2900f377f049195421f1ac2a615530569beab3f786112a9039d0d`. Dateiinhalte einzeln gegen ihre Git-Blobs des APK-Quellstands geprüft.
- Zertifikat SHA256: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`, identisch zur bisherigen APK. Versionscode 1100, Schema 1, unveränderte Paketkennung und Speicherdatei, v2-Signatur und 16-KB-ZIP-Ausrichtung geprüft.
- Neue unabhängige GitHub-Kopie unter `/workspace/timber-restore-11`. Erstimport, vollständige Headless-Suite und anschließend separate OpenGL-Prüfung. Alle 4.476 Headless-Prüfungen, der erste-Haus-Verlauf, Hauptszenenstart und die 23 OpenGL-Prüfungen bestehen auch dort. APK, Quell-ZIP und Benno-Vorschau vom unveränderlichen Tag `v0.11.0-benno` vollständig per HTTPS mit HTTP 200 zurückgeladen; alle SHA256 stimmen mit den Originaldateien sowie den Dateien aus der GitHub-Wiederherstellung überein. Bericht: `download-verification-11.json`.

## Historischer Prüfbericht 0.10

# Prüfung 0.10 — Sculpted World

- 220 Regel-, 4.135 Szenen-/Geometrie- und 56 Platzierungsprüfungen. Der frische Spielverlauf erreicht das erste Haus weiterhin nach 1.682 simulierten Sekunden ohne zusätzliche Ressourcen.
- 42 Werkstattprüfungen einschließlich Schatten an/aus durch Standard-/Akkumodus. Zusammen 4.453 Headless-Prüfungen plus Progressionslauf und abschließender Hauptszenenstart.
- Separate echte OpenGL-Prüfung: sieben gerenderte 3D-Symbole jeweils auf sichtbare Silhouette, transparente Ränder und farbige beleuchtete Details geprüft. Die 3D-Szene der Symbole ist von der Welt getrennt. Druckzustand ändert das Flächenbild und Inhaltsabstand. Nach Anwendungsfortsetzung wird neu gerendert. 19 Prüfungen.
- OpenGL-Aufnahmen von Einstieg, offener Werkstatt, Baukatalog, Bauvorschau, Einführung und aufgebauter Stadt. Der fortgeschrittene Stand ist eine explizite Capture-Demonstration; kein Benutzerspielstand wird dafür verändert.
- Kein Größenlimit von 55 MB: Symbole, Oberflächen und Modelle werden ressourcenschonend aus eigener Geometrie und Vektoren erzeugt. Die Paketgröße allein ist kein Maß für Grafikqualität.
- Schattenleistung, Temperatur, Safe Area und Wiederaufnahme auf realen Android-Geräten sind weiterhin separat zu prüfen. Der Akkumodus stellt einen Ausweichmodus ohne neue Weltschatten bereit. Die Prüfungen hier sind keine Messung auf einem Telefon.

## Auslieferung 0.10

- APK-Quellstand: `54a6e86abaea53ac6a829e7a6c6598129320bc71`.
- APK: 56.585.744 Bytes, SHA256 `b44b4a8bfbd83339407d06e3a2c4b9cf246f069bf6fea96a678a6adb91150e2d`.
- Quell-ZIP: 69 Dateien, 1.947.082 Bytes, SHA256 `305f51e32f7f83226989e1c3d8466752a9c2b87b53f5d0aa99fb764d94aec796`. Jede enthaltene Datei stimmt mit ihrem Git-Blob am APK-Quellstand überein.
- Zertifikat SHA256: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`, unverändert zu 0.9. Versionscode 1000, Spielstandschema 1, GL Compatibility, keine Berechtigungen.
- Wiederherstellung: neue unabhängige Kopie von GitHub unter `/workspace/timber-restore-10`. Zuerst Import mit `bash scripts/godot.sh --headless --editor --import --quit`, dann `bash scripts/test.sh`. Die gesonderte OpenGL-Prüfung ist `Tests/VisualUI.gd` und benötigt einen verfügbaren X11-/OpenGL-Bildschirm. Grafikprüfung nach dem Import ausführen; ein direkter Skriptstart vor dem Erstimport hat noch keinen globalen GDScript-Klassenindex.
- APK, passende Quell-ZIP und Vorschau vom festen Tag `v0.10.0-sculpt` vollständig per HTTPS zurückgeladen, jeweils HTTP 200 und identischer SHA256. Bericht: `download-verification-10.json`. In der neu geklonten Kopie bestehen nach dem Erstimport sämtliche 4.453 Headless-Prüfungen, der erste-Haus-Verlauf, Hauptszenenstart sowie die 19 OpenGL-Prüfungen erneut.

## Historischer Prüfbericht 0.9

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
