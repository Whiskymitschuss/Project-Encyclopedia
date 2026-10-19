# Timber Loot Tycoon — Benno im Wald 0.11

Spielbarer Godot-4.6-Wiederaufbau mit eigener Low-Poly-Grafik, prozeduralen Texturen und erzeugten Soundeffekten. Die Holzindustrie wächst zu einer Stadt mit Immobilien und Großprojekten. Der frühere Quellstand ist nicht verfügbar; dieses Projekt setzt die Anforderungen aus dem Chat neu um. Entwicklungsfassung, keine nachgewiesen marktreife App.

## Auf dem Handy testen

Die signierte Android-Test-APK liegt nach dem Build unter **[releases/Timber-Loot-Tycoon-v0.11-test.apk](releases/Timber-Loot-Tycoon-v0.11-test.apk)**. Auf GitHub die Datei öffnen und **Download raw file** wählen. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0; rund 58 MB. Die APK verlangt keine Android-Berechtigungen. Details: [Android-Test](docs/ANDROID.md).

## Spielen und entwickeln

`project.godot` mit Godot **4.6.3** importieren und **F5** drücken. Im vorbereiteten Linux-Checkout:

```bash
bash scripts/godot.sh --editor
bash scripts/test.sh
python3 scripts/build_android.py
python3 scripts/backup.py
```

Der Android-Helfer lädt offizielle, fest versionierte und per Prüfsumme verifizierte Exportvorlagen und SDK-Pakete. Java mit `keytool` und Godot müssen bereits vorhanden sein. Cache, Editor-Konfiguration und Testsignaturschlüssel liegen außerhalb des Quellprojekts unter `/workspace/.timber-runtime`. Alternative Laufzeitpfade können über die im Skript dokumentierten Umgebungsvariablen gesetzt werden. Keine Gradle-Abhängigkeiten oder Benutzer-Zugangsdaten erforderlich.

## Neu in 0.11

- Benno, ein eigener animierter 3D-Biber mit Helm, rotem Hemd, großen Zähnen, Blinzeln und Winken. Deine bereitgestellte Biber-Grafik erscheint unverändert im Willkommensbildschirm; der kleine Begleiter ist ein separates, vereinfachtes 3D-Modell.
- Einmalige Begrüßung beim Start und nach längerer Rückkehr, mehrere freundliche Texte sowie die tatsächlich berechneten Offline-Einnahmen. Ein alter Offline-Bericht wird nicht bei jeder erneuten Begrüßung wiederholt.
- Benno freut sich über fertiggestellte Betriebe, Häuser, Upgrades, neue Regionen, Prestige und besonderen Loot. Ein Bauauftrag allein gilt nicht als fertiges Gebäude. Eine einzelne vorgemerkte Reaktion und Zeitabstände verhindern eine Flut alter Meldungen.
- Antippen zum Plaudern; Hinweise berücksichtigen Rucksack, Spänebox, Trocknung und Stadt. Wo passend führt ein Link direkt ins zugehörige Menü. Automatische Tipps werden pro Hinweis und Sitzung nur einmal gezeigt, Sprechblasen lassen sich sofort schließen.
- Begleiter und Sprechblasen bleiben in Menüs und im Baumodus verborgen. Benno lässt sich unter Mehr → Einstellungen abschalten; die Einstellung bleibt beim Speichern und Prestige erhalten. Das kleine Portrait rendert mit begrenzter Bildrate und pausiert in verdeckten Ansichten.
- Unveränderte Wirtschaft und Schema-1-Speicherdatei, Paket und Testsignatur. Android-Versionscode 1100; als Update installieren.

![Benno winkt im Spiel; ausdrücklich aufgebauter Demonstrationsstand](docs/preview-benno.png)

## Weiterhin aus 0.10

- Plastische Oberfläche mit gewölbten Farbflächen, Lichtkante, schmaler Seitenkante und verändertem Druckzustand. Alle Menüs, Baukarten und Aktionsflächen verwenden die neue gemeinsame Oberfläche.
- Echte eigene 3D-Modelle für die fünf Hauptmenüs sowie Münzen und Diamanten. Ein isolierter 896×128-Viewport rendert alle sieben Symbole gemeinsam einmal; die Oberfläche verwendet Ausschnitte dieses Bildes. Nach Rückkehr aus dem Hintergrund wird neu gerendert, ohne ständige zusätzliche 3D-Pässe im laufenden Spiel.
- Räumliche Schatten für Gebäude, Maschinen, Arbeiter und Förderbänder im Standardmodus. Akkumodus deaktiviert sie. Neutralere Beleuchtung sowie unterschiedliche Rauheit von Holz, Lack und Metall geben den Anlagen mehr Tiefe.
- Bestehende 0.7/0.8/0.9-Spielstände, Paketkennung und Testsignatur bleiben erhalten. Android-Versionscode 1000. Es gibt keine Zielgröße von 55 MB und keine künstliche Vergrößerung: Die Ressourcen werden nach sichtbarem Nutzen ausgewählt.

## Weiterhin aus 0.9

- Offene Fabrikflächen mit eigenen Maschinenmodellen: Säge mit Blatt und Stammzufuhr, Trocknungsanlage, Möbel-/Bauelement-Arbeitsplätze, Papier- und Pelletanlagen. Große Holzstapel mit sichtbaren Stirnflächen, Bretterpaletten, Möbel, Lagerregale, Steuerpulte und Arbeitsmarkierungen ersetzen die geschlossenen Fabrikhäuser.
- Werkstücke fahren über Rollenbahnen; Säge und Werkzeugköpfe laufen abhängig vom tatsächlichen Produktionsfluss ihres Betriebs. Pause und Materialmangel stoppen die Bewegung. Bestände neben der Verarbeitung reagieren auf die gemeinsamen Ressourcenvorräte. Diese Anzeige ergänzt die Wirtschaft, sie simuliert keine einzelnen physischen Werkstücke oder getrennten Betriebslager.
- Helm, Warnweste, bewegte Arme und Beine: Ein Teil des eingestellten Teams bedient sichtbar die Maschinen, der Rest transportiert im Wald. Die bestehenden Leistungswerte bleiben erhalten; die Rollenverteilung ist eine begrenzte visuelle Darstellung.
- Kompakter Kopfbereich, kleinere Aktionsleiste und eigene orange Symbole auf hellen Navigationstasten. Näherer Einstieg auf die Industrie; Weltübersicht und freie Kamera bleiben erreichbar.
- Android-Versionscode 900. Paket, Testsignatur und Schema-1-Spielstand bleiben wie bei 0.7/0.8. Als Update installieren, ohne vorher die App oder ihre Daten zu löschen.

![Offener Arbeitsplatz mit Säge, Bediener und Holzstapeln; Demonstrationsstand](docs/preview-workshop.png)

## Weiterhin aus 0.8

- Kräftigere Farben, unterscheidbare Betriebsdetails, helle Menükarten, direkter Baukatalog mit Produktion/Wohnen/Versorgung und mehr Platz auf hohen Handybildschirmen.
- Neue Gebäude in der Welt platzieren und in 90°-Schritten drehen. Grüne/rote Vorschau, Prüfung gegen Straßen und andere Gebäude, keine Bezahlung vor Bestätigung. Bestehende Betriebe und Häuser kostenlos verschieben; Positionen und Bauaufträge bleiben gespeichert. Der Baumodus nutzt das zentrale Baugebiet innerhalb der Hauptstraßen.
- Sichtbare automatisch geroutete Förderstrecken umgehen Gebäude und überbrücken Straßen. Güter bewegen sich bei aktiver Produktion. Die Wirtschaft verwendet weiterhin gemeinsame Materialpuffer; Förderstrecken sind keine zusätzliche Waren- oder Stausimulation.
- Spänebox mit Füllstand am Sägewerk und direktem Zugriff unten. Bestand manuell leeren und verkaufen oder für Pellets/Papier halten. Bei voller Box bleibt der gespeicherte Vorrat erhalten; nur neu anfallender Überlauf wird kompostiert. Optional lässt sich dieser Überlauf stattdessen verkaufen. Die Bretterproduktion stoppt deswegen nicht mehr.
- Willkommen und vier praktische Einführungsschritte für neue Profile. Bestehende 0.7-Spielstände behalten ihren Fortschritt und bekommen keine verpflichtende Einführung. Hilfe ist unter Mehr erreichbar.
- Betrieb antippen: Produktionszustand, Ausbau und Verschieben direkt erreichbar. Nebel schwächer, korrigierte Ganzzahlanzeigen, Schutz vor doppelten emulierten Mausklicks auf Touchgeräten.

## Spielumfang

- Zusammenhängende Landschaft von 400 × 390 Einheiten, zehn Biome, 1.000 instanzierte Bäume, zehn sichtbare Bossbäume. Straßen und Projektzufahrten bleiben auf Land. Bäume wachsen nach; Holzfäller sind in begrenzter Anzahl sichtbar.
- Bis zu 24 frei platzierbare Industriebetriebe, mehrere Betriebe desselben Typs und unabhängige Upgrades. Sammelstation, Lager, Hütten, Sägewerke, Trocknung, Möbelfabrik, Garage, Forschung, Fertighauswerk, Tischlerei, Pellet-, Papier- und Designmöbel-Produktion.
- Echte Ressourcenbilanzen, faire gemeinsame Materialzuteilung, sichtbare laufende Fördergüter und Sägen, Bauzeit, Gerüste und Kräne. Bestehende Betriebe produzieren während Upgrades weiter.
- Zwölf Stadtgrundstücke in drei erschließbaren Regionen. Zehn Gebäudetypen: Häuser, Laden, Wohnhaus, Villa, Hotel, Büros, Park, Schule, Klinik, Feuerwehr. Bis Stufe zehn, Miete, Bewohner und öffentliche Boni.
- Materialplaner für ein Stadthaus: Bestände und Kosten, Schutz vor automatischem Verbrauch, optional genau ein automatischer Bauauftrag. Manuelle Verkäufe bleiben möglich.
- Fünf Großprojekte mit je drei bezahlten Bauabschnitten und anschließendem laufenden Ertrag. Standortmodelle und Zufahrten sind sichtbar.
- 15 Werkzeug- und zehn Fahrzeugstufen; Mitarbeiter, automatische Möbel-Exporte, wiederholbare Lieferaufträge, sieben Meilensteine, fünf Forschungsrichtungen.
- Sechs Loot-Seltenheiten mit offen angezeigten Wahrscheinlichkeiten. Werkzeug- und Fahrzeugteile sind zum Herstellen verwendbar; freigeschaltete Skins lassen sich anlegen. Münzen, Diamanten, Tickets, Geldscheine und Mythic Tokens werden gespeichert; Tokens verbessern dauerhaft die Loot-Chance. Geldscheine dienen derzeit als Auftragszähler/Vorratswährung.
- Zeitlich begrenzte Booster, steigende Prestige-Kosten und dauerhafte Geld-, Produktions- und Loot-Boni. Permanente Währungen, Inventar und Skins überstehen den Neustart; der Prestige-Hain benötigt eine vorherige Ära.
- Tageszeit, Regen, Nebel, Holzsplitter-Pool und Originalsounds. Akkumodus reduziert dargestellte Arbeiter, LKWs und Wettereffekte; Wälder verwenden MultiMeshes und statische Modelle zusammengefasste Geometrie.
- Versionierter Spielstand, atomare Übernahme, Backup-Fallback, Hintergrund-Speicherung und bis zu acht Stunden deterministischer Offline-Fortschritt.

## Erste Schritte

1. **Fällen** zeigt den aktiven Wald und füllt den Rucksack. **Abliefern** bringt Holz ins Lager und zeigt die Industrie. Antippen im Wald funktioniert ebenfalls; Ziehen und Zwei-Finger-Zoom bewegen die Kamera.
2. Holz und Bretter unter **Verkaufen** handeln, Missionen abholen und eine Trockenkammer sowie Möbelfabrik unter **Bauen → Produktion** beauftragen.
3. Mitarbeiter und Lager ausbauen. Möbel werden durch LKWs automatisch exportiert. Fördergüter bewegen sich nur bei aktiver Produktion des jeweiligen Betriebs.
4. Fertighauswerk bauen. Unter **Stadt → Grundstück** ein Holzhaus als Bauziel vormerken. Nach Lieferung und Fertigstellung bringt es Miete und Wohnraum. Weitere Fabrikzweige, Regionen und Projekte öffnen den nächsten Ausbau.

Die automatisierte Progressionsprüfung erreicht das erste Haus aus einem frischen Profil ohne geschenkte Ressourcen nach 1.682 simulierten Sekunden. Dies ist ein einzelner geprüfter Spielpfad, keine Langzeit-Balance-Zusage.

## Prüfung und Grenzen

`bash scripts/test.sh` verwendet temporäre Spielstände: 220 Regelprüfungen, ein frischer Verlauf bis zum ersten Haus, 4.135 Szenen-/Geometrieprüfungen, 56 Platzierungs-/Tutorialprüfungen und 42 Prüfungen der offenen Produktion, Schattenumschaltung und Bildschirmaufteilung sowie 23 Begleiterprüfungen sowie ein abschließender Headless-Start. Eine zusätzliche OpenGL-Prüfung testet die sieben wirklich gerenderten 3D-Symbole, Transparenz, Beleuchtung, getrennte Szenen, Druckzustand und erneutes Zeichnen nach Rückkehr aus dem Hintergrund (23 Prüfungen einschließlich 3D-Biber und sichtbarer Winkeanimation). [Prüfbericht](docs/VALIDATION.md). Die Bilder unter `docs/` stammen aus dem Spiel; die Stadtansicht verwendet ausdrücklich einen nur für das Bild aufgebauten Demonstrationsstand.

Noch offen: reale Android-Gerätetests für Touch, Safe Area, Hintergrund, Temperatur und Akku; 50-Stunden-Balancing, Barrierefreiheit, Release-Signierung, iOS und Store-Abnahme. Freies Straßenzeichnen, Immobilienverkauf/Umbau, vollständig simulierte Bahn-/Schifffahrt und eigene Musik pro Biom sind noch nicht enthalten. Fahrzeuge verwenden derzeit ein gemeinsames LKW-Modell; höhere Stufen verändern Geschwindigkeit und Kapazität. Geldscheine und einige seltene Baupläne haben noch keinen eigenen Ausgabepfad. Großprojekte verwenden Standortmodelle; es gibt noch keinen echten Hafenverkehr. Keine Werbung, In-App-Käufe oder Cloud-Spielstandsynchronisierung.

## Sicherung

Jeder geprüfte Meilenstein erhält einen Git-Commit und wird nach `origin/main` übertragen. Ein lokaler Commit alleine ist keine externe Sicherung. `scripts/backup.py` erstellt zusätzlich ein Quellarchiv und ein vollständiges Git-Bundle außerhalb des Checkouts. Die ZIP enthält Quellcode ohne APK; das Bundle enthält die ganze Git-Historie einschließlich der separat gespeicherten Test-APK. Der externe Sicherungsstand wird durch erneutes Abrufen und Vergleich des Commit-Hashes geprüft.

Keine Zugangsdaten, privaten Signaturschlüssel, Spielstände oder Build-Caches gehören in Git.
