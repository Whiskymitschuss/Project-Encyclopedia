# Timber Loot Tycoon — Stadtverkehr 0.16

Spielbarer Godot-4.6-Wiederaufbau mit eigener Low-Poly-Grafik, prozeduralen Texturen und erzeugten Soundeffekten. Die Holzindustrie wächst zu einer Stadt mit Immobilien und Großprojekten. Der frühere Quellstand ist nicht verfügbar; dieses Projekt setzt die Anforderungen aus dem Chat neu um. Entwicklungsfassung, keine nachgewiesen marktreife App.

## Auf dem Handy testen

Die signierte Android-Test-APK liegt nach dem Build unter **[releases/Timber-Loot-Tycoon-v0.16-test.apk](releases/Timber-Loot-Tycoon-v0.16-test.apk)**. Auf GitHub die Datei öffnen und **Download raw file** wählen. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0; rund 58 MB. Die APK verlangt keine Android-Berechtigungen. Details: [Android-Test](docs/ANDROID.md).

## Spielen und entwickeln

`project.godot` mit Godot **4.6.3** importieren und **F5** drücken. Im vorbereiteten Linux-Checkout:

```bash
bash scripts/godot.sh --editor
bash scripts/test.sh
python3 scripts/build_android.py
python3 scripts/backup.py
```

Der Android-Helfer lädt offizielle, fest versionierte und per Prüfsumme verifizierte Exportvorlagen und SDK-Pakete. Java mit `keytool` und Godot müssen bereits vorhanden sein. Cache, Editor-Konfiguration und Testsignaturschlüssel liegen außerhalb des Quellprojekts unter `/workspace/.timber-runtime`. Alternative Laufzeitpfade können über die im Skript dokumentierten Umgebungsvariablen gesetzt werden. Keine Gradle-Abhängigkeiten oder Benutzer-Zugangsdaten erforderlich.

## Neu in 0.16 — LKWs und Stadtleben

- Die Förderstrecken zwischen den Gebäuden sind entfernt. **Holz → Bretter → Möbel → Laden** verwendet auf allen drei Teilstrecken tatsächliche Straßenfahrten. Die gesamte gekaufte Fahrzeugflotte wird gemeinsam mit Baustellen vergeben, einschließlich Beladen, Entladen und leerer Rückfahrt. Nachgelagerte Lieferungen haben Vorrang, damit bereits ein einzelner Start-LKW die ganze Kette bedienen kann.
- Pickup und LKW, ab Transportstufe 5 ein Gelenk-Auflieger, ab Stufe 7 ein Tiefbett mit Rampen. Holz, Bretter, Möbel und Materialkisten sitzen auf dem tatsächlichen Ladebereich; leere Rückfahrten zeigen keine Ladung. Ein Upgrade ersetzt auch schon aktive Fahrzeugmodelle. Kleine maschineninterne Rollentische bleiben Teil der Verarbeitung.
- Polizei, Feuerwehr, Rettungswagen und Taxis fahren echte Aufträge über das Straßennetz. Rettung und Gemeindehilfe haben einen Arbeitsaufenthalt am Ziel; Taxifahrgäste warten, steigen ein und werden an einem tatsächlichen Stadtziel abgesetzt. Abgeschlossene Fahrten sammeln Spielmünzen in der abholbaren Stadtkasse. Ohne eigene Wache kommt Hilfe von der bestehenden westlichen Zufahrt.
- Neue frei platzierbare **Polizeiwache und Taxizentrale**, jeweils mit eigener Gebäudeform. Eigene Feuerwehr und Klinik dienen den passenden Fahrzeugen als Ausgangspunkt; bessere Dienstgebäude erlauben mehr gleichzeitig verfügbare Fahrzeuge. Bis zu zwölf gespeicherte Bewohnerwege zwischen tatsächlichen Häusern und Zielen ergänzen die bisherigen Vorgartenszenen. Begrenzte wiederverwendbare Figuren-/Fahrzeugpools und der Akkumodus begrenzen die Darstellung.
- Direkter Zugang über **Stadt → Stadtleben & Fahrzeuge** oder **Mehr**. Dort Fahrten anfordern, Stadtkasse abholen, neue Fahrten ein-/ausschalten, Standorte bauen und Fahrzeuge ansehen. Erledigte Aufträge und laufende Wege überstehen Laden und Offlinezeit. Aktive Wege schützen ihre Straßen und Standorte bis zum Abschluss.
- Im Baukatalog und allen anderen Listen **direkt über Karten und Schaltflächen mit dem Finger wischen**. Eine Wischbewegung löst keinen Kauf aus; kurze Berührungen bedienen weiterhin die richtige Schaltfläche. Nachlauf, abgebrochene Touchgesten und kleine Hochformatfenster sind berücksichtigt. Die schmale Scrollleiste ist entfernt, die Kamera bleibt hinter dem Menü stehen.
- Alte gespeicherte Bandladungen werden verlustfrei zu ausstehenden Straßenlieferungen am Ausgang zurückgeführt, auch wenn der dortige Puffer voll ist. Bereits angekommenes Material wird nicht doppelt gebucht. Neue Auftragsfristen berücksichtigen die längeren Straßenfahrten. Gleiches Paket, gleicher Testschlüssel, Schema 1 und Android-Versionscode 1600: als Update installieren.
- Die fortgeschrittenen bisherigen Fabriken verwenden weiterhin ihre gemeinsamen Lager. Individuelle Transporte für deren gesamte Wirtschaft, Kollisionsverkehr, Kreuzungsampeln und die späteren Stein-/Stahl-/Betonketten bleiben weitere Schritte; diese Version behauptet keine vollständige Verkehrssimulation.

![Stadtverkehr mit echten Dienstfahrten; ausdrücklich aufgebautes Demonstrationsprofil](docs/preview-traffic-city.png)

![Holz, Bretter und Möbel auf Tiefbett-Aufliegern; ausdrücklich aufgebautes Demonstrationsprofil](docs/preview-traffic-freight.png)

## Weiterhin aus 0.15 — Material wird wirklich geliefert

Die damaligen Bandfahrten sind seit 0.16 durch den oben beschriebenen Straßenverkehr ersetzt.

- Kleine spielbare Linie **Holz → Bretter → Möbel → Laden** unter **Aufträge → Lieferkette** eröffnen. Sie verwendet vorhandene Gebäude, eigene Puffer und die gekauften Transportfahrzeuge. Antippbare Materialzähler zeigen Leerstand, Teilmengen und volle Ausgänge direkt über den Gebäuden.
- Ladenaufträge mit Frist und Bonus. Verspätete Möbel verdienen 70 % des Verkaufspreises; der Auftrag bleibt erfüllbar. Kein echtes Geld und kein Game Over.
- Unternehmenslevel: einfache Geld-Upgrades auf Level 1–3; ab Level 4 Materialbaustellen mit sieben Bauphasen. Holz, Bretter, Muttern und Schrauben müssen tatsächlich am Bauplatz ankommen. Hardware gibt es gegen Spielmünzen im Materialdepot.
- Liefer-LKWs nehmen Ware am Lager auf, fahren über Straßen zur Baustelle, entladen und kehren leer zurück. Baustellen und Laden teilen sich den gekauften Fuhrpark. Pause, Priorität, Materialkauf, Baukamera, sichere Bauabbrüche und ein begrenztes zuweisbares Bauteam sind spielbar. Ab Level 10 kann die globale Baustellen-Automatik übernehmen.
- Sichtbare Baustellenschilder, Lieferflächen, wachsende Baugeometrie, arbeitende beziehungsweise wartende Bauarbeiter, Kran und Eröffnungsfeier. Ladungen und Bauphasen sind gespeichert und laufen unabhängig von der Darstellung weiter.
- Alte Spielstände und schon bezahlte Baustellen bleiben erhalten. Zusätzliche Fabriken behalten die bisherige fortgeschrittene Holz-/Stadtwirtschaft. Das ist der erste spielbare Abschnitt des großen Master-Plans; Stein-, Stahl- und Betonketten sowie die neuen Bergbaumaschinen stehen noch aus. Der genaue Stand und die weiteren Phasen stehen in [Industrie-Masterplan](docs/INDUSTRY-ROADMAP.md).

![Echte Holzlieferkette mit lokalen Materialanzeigen; aufgebauter Demonstrationsstand](docs/preview-delivery-world.png)

![Materialbaustelle mit zugewiesenem Bauteam; aufgebauter Demonstrationsstand](docs/preview-delivery-construction.png)

## Neu in 0.14 — Ein lebendiges Waldtal

- Das flache rechteckige Landschaftsbrett und die harten Biomplatten sind durch zusammenhängendes Gelände mit weichen Farbwechseln, unregelmäßigem Waldrand, Hügeln und flachen Ufern ersetzt. Ein geschwungener Bach, ein kleiner See, eine Holz-Fußgängerbrücke, ein Picknickplatz und ein Aussichtsturm geben dem Tal eigene Orte. Die weiterhin bebaubaren Flächen bleiben eben; gespeicherte Häuser und Straßen werden nicht versetzt.
- Zusätzlich bis zu 2.500 rein dekorative Bäume, Büsche, Steine und Blumengruppen. Sechs gemeinsame instanzierte Geometrien halten die Zahl der Zeichenaufrufe klein; Stämme haben ihre eigene Holzfarbe. Die 1.000 wirtschaftlich nutzbaren, nachwachsenden Bäume bleiben erhalten und bekommen unregelmäßige Waldformen und unterschiedliche Baumkronen.
- Vegetation verschwindet automatisch aus Gebäuden, Baustellen, Straßen, Haltestellen und Förderstrecken. Ein Haus in einer Wiese zu platzieren kostet dafür nichts zusätzlich. Deko erhöht weder Holzvorräte noch Arbeiterleistung und verändert keine Baukosten.
- Straßenränder erhalten kleine Pflanzungen. Wenig genutzte feste Zufahrten erscheinen als Schotterwege, belebte Straßen als Asphalt; Linien- und Lieferstrecken bleiben befahrbar. Die bestehenden Straßengraphen und eigenen Strecken sind unverändert. Leere Grundstücke tragen keine großen dauerhaften Farbplatten mehr.
- Kamerafehler beim starken Herauszoomen behoben: Die Kamera bewegt sich mit dem Zoom ausreichend zurück, sodass sie den Vordergrund nicht abschneidet. Die Übersicht bleibt näher am Ort; volle Welt und freie Zoomstufen bleiben erreichbar. Dünnere Nebelschicht, lesbareres Abendlicht und ruhigere Bodenfarben.
- Akkumodus zeichnet nur 45 % der zusätzlichen Landschaftsdekoration. Platzierung, Wirtschaft, alte Spielstände und Schema 1 bleiben erhalten. Android-Versionscode 1400 und derselbe Testschlüssel wie zuvor.

![Überarbeitete Landschaft; aufgebauter Demonstrationsstand](docs/preview-valley-overview.png)

![Bach und Fußgängerbrücke im Tal; aufgebauter Demonstrationsstand](docs/preview-valley-river.png)

## Weiterhin aus 0.13 — Vom Holzlager zur Kleinstadt

- Zusammenhängendes Land von 640 × 560 Einheiten. Nach den drei bisherigen Regionen und 20 Bewohnern erschließt du Ost- und Westviertel: jeweils zwölf zusätzliche Hausgrundstücke, acht weitere Industriebetriebe und eine Zufahrt. Insgesamt bis zu 36 Stadtgrundstücke und 40 Betriebe; bisherige Positionen bleiben erhalten.
- Eigene Asphaltstraßen und Fußwege: Start und Ziel auf der Karte wählen, rechtwinklige Kurve wechseln, Kosten prüfen und bestätigen. Straßen schließen am vorhandenen Netz an; Gebäude, Baustellen, nicht erschlossene Viertel und Wasser werden geprüft. Abbrechen ist kostenlos. Strecken bleiben im Spielstand und lassen sich ohne Erstattung entfernen; aktive Busverbindungen sind geschützt.
- Eigene Formen für zwölf Stadtgebäude, darunter Feuerwehr mit Fahrzeughalle und Löschwagen, Wohnhaus mit Balkonen, Landhaus mit Veranda, Villa mit Pool, Laden mit Auslage, Schule, Gesundheitszentrum, Hotel, Bürohaus, Park und neuer Nachtclub. Größere Ausbaustufen erhalten mehr Etagen beziehungsweise zusätzliche Ausstattung. Vorgartenspaziergänge meiden den Villenpool.
- Goldene Mietanzeigen über Häusern zum Antippen, Abholung am Haus oder für die ganze Stadt. Neue Profile sammeln Miete im Hauskonto, auch während der maximal acht Offline-Stunden. Für 2.500 Münzen, angepasst an Prestige, übernimmt ein Hausverwalter die automatische Auszahlung. Alte Spielstände behalten ihre bisherige automatische Miete kostenlos.
- Bis zu acht frei gesetzte Haltestellen und drei Buslinien mit selbst gewählter Stationsreihenfolge. Sichtbare Busse fahren auf dem tatsächlichen Straßengraphen, halten vier Sekunden und öffnen die Türen; Bewohner warten am Unterstand. Abgeschlossene Rundfahrten verdienen einen nach Einwohnerzahl begrenzten Fahrpreis abzüglich Betriebskosten. Route, Fahrstand und Ertrag werden gespeichert und offline weitergerechnet. Unterbrochene Strecken bringen keine Fahrgelder.
- Werkzeugstufen 11–15 zeigen jetzt Mini-Forstmaschinen, Harvester und schwere Bagger mit bewegtem Arm, Säge und Holzladung. Arbeitsstreifen halten die Modelle sichtbar. Transportstufen zeigen Handwagen, Schubkarre, Pickup, LKW und schwere Forsttransporter. Bereits gekaufte Stufen erscheinen nach Laden ohne erneuten Kauf. Die bestehenden Leistungswerte bleiben erhalten; die Maschinen sind eine begrenzte szenische Darstellung des Gesamtteams.
- Direkter Zugang zu Straßen und Busverkehr im Baukatalog und in der Stadt; neue Meilensteine für Wege, Mietabholung, Busfahrten und Viertel. Förderstrecken verbinden auch Betriebe in den neuen Gebieten und überbrücken eigene Straßen.
- Android-Versionscode 1300, gleiches Paket, gleicher Testschlüssel und Schema-1-Spielstand. Als Update installieren, ohne vorher zu deinstallieren.

![Kleinstadt mit eigenen Gebäudemodellen und Mietanzeigen; aufgebauter Demonstrationsstand](docs/preview-town.png)

## Weiterhin aus 0.12

- Hütten erhalten Bank, Tisch mit Tasse und Brotdose, Sonnenschirm, Blumen und eine leuchtende Laterne. Parks haben richtige Bänke und zusätzliche Pflanzkübel. Die Dekoration bleibt innerhalb der bestehenden Grundstücke und dreht sich mit dem Gebäude.
- Ab vier dargestellten Mitarbeitern besucht ein Mitglied des sichtbaren Teams den Hütten-Pausenplatz. Es geht über den freien Vorplatz zur Bank, sitzt mit einer Tasse und kehrt wieder zurück. Der Mitarbeiter wird aus der bestehenden begrenzten Teamdarstellung genommen, es entsteht kein zusätzliches Personal.
- Arbeiter und Bewohner winken einander bei Begegnungen zu. Abstandsprüfung und Abklingzeit begrenzen die Gesten. Bewohner gehen im Vorgarten ihres tatsächlich gespeicherten Hauses spazieren und folgen auch dessen Rotation.
- Echte Bauabschlüsse lösen einen kurzen Eröffnungs-/Ausbaujubel mit Konfetti, Beschriftung und leiser Dreitonfolge aus. Eine begrenzte nahe Gruppe hebt die Arme. Reine Bauaufträge oder geladene Bestandsgebäude lösen keine Feier aus; mehrere Effekte verwenden einen festen Pool.
- Akkumodus reduziert Partikel und Zuschauer. Unter Mehr → Einstellungen lassen sich die neuen Alltagsszenen abschalten; diese Wahl bleibt beim Speichern und Prestige erhalten. Benno bleibt unabhängig einstellbar.
- Alltagsszenen sind eine szenische Darstellung; Pausen und Jubel verändern Produktion, Kosten, Lager oder Bauzeiten nicht. Es gibt weiterhin keine vollständige Fußgänger-/Fahrzeug-Kollisionssimulation.
- Update mit Versionscode 1200, gleichem Paket, Testschlüssel und Schema-1-Speicherdatei. Nicht vorher deinstallieren. Die vorherige Version 0.11 wurde vom Nutzer als auf seinem Handy funktionierend bestätigt; dies ersetzt keinen Gerätetest der neuen 0.12.

![Pausenplatz an der Hütte; ausdrücklich aufgebauter Demonstrationsstand](docs/preview-pause.png)

## Weiterhin aus 0.11

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

- Zusammenhängendes natürliches Gelände um die unveränderten Bauflächen von 640 × 560 Einheiten, zehn Biome, 1.000 instanzierte Bäume, zehn sichtbare Bossbäume. Straßen und Projektzufahrten bleiben auf Land. Bäume wachsen nach; Holzfäller sind in begrenzter Anzahl sichtbar.
- Bis zu 40 frei platzierbare Industriebetriebe, mehrere Betriebe desselben Typs und unabhängige Upgrades. Sammelstation, Lager, Hütten, Sägewerke, Trocknung, Möbelfabrik, Garage, Forschung, Fertighauswerk, Tischlerei, Pellet-, Papier- und Designmöbel-Produktion.
- Echte Ressourcenbilanzen, faire gemeinsame Materialzuteilung, sichtbare Straßenladungen und arbeitende Sägen, Bauzeit, Gerüste und Kräne. Bestehende Betriebe produzieren während Upgrades weiter.
- Bis zu 36 Stadtgrundstücke in drei Regionen und zwei zusätzlichen Vierteln. Vierzehn Gebäudetypen einschließlich Polizeiwache und Taxizentrale: Holzhaus, Landhaus, Laden, Wohnhaus, Villa, Hotel, Büros, Nachtclub, Park, Schule, Klinik, Feuerwehr. Bis Stufe zehn, Miete, Bewohner und öffentliche Boni.
- Materialplaner für ein Stadthaus: Bestände und Kosten, Schutz vor automatischem Verbrauch, optional genau ein automatischer Bauauftrag. Manuelle Verkäufe bleiben möglich.
- Fünf Großprojekte mit je drei bezahlten Bauabschnitten und anschließendem laufenden Ertrag. Standortmodelle und Zufahrten sind sichtbar.
- 15 Werkzeug- und zehn Fahrzeugstufen; Mitarbeiter, automatische Möbel-Exporte, wiederholbare Lieferaufträge, elf Meilensteine, fünf Forschungsrichtungen.
- Sechs Loot-Seltenheiten mit offen angezeigten Wahrscheinlichkeiten. Werkzeug- und Fahrzeugteile sind zum Herstellen verwendbar; freigeschaltete Skins lassen sich anlegen. Münzen, Diamanten, Tickets, Geldscheine und Mythic Tokens werden gespeichert; Tokens verbessern dauerhaft die Loot-Chance. Geldscheine dienen derzeit als Auftragszähler/Vorratswährung.
- Zeitlich begrenzte Booster, steigende Prestige-Kosten und dauerhafte Geld-, Produktions- und Loot-Boni. Permanente Währungen, Inventar und Skins überstehen den Neustart; der Prestige-Hain benötigt eine vorherige Ära.
- Tageszeit, Regen, Nebel, Holzsplitter-Pool und Originalsounds. Akkumodus reduziert dargestellte Arbeiter, LKWs und Wettereffekte; Wälder verwenden MultiMeshes und statische Modelle zusammengefasste Geometrie.
- Versionierter Spielstand, atomare Übernahme, Backup-Fallback, Hintergrund-Speicherung und bis zu acht Stunden deterministischer Offline-Fortschritt.

## Erste Schritte

1. **Fällen** zeigt den aktiven Wald und füllt den Rucksack. **Abliefern** bringt Holz ins Lager und zeigt die Industrie. Antippen im Wald funktioniert ebenfalls; Ziehen und Zwei-Finger-Zoom bewegen die Kamera.
2. Holz und Bretter unter **Verkaufen** handeln, Missionen abholen und eine Trockenkammer sowie Möbelfabrik unter **Bauen → Produktion** beauftragen.
3. Mitarbeiter und Lager ausbauen. Möbel werden durch LKWs automatisch exportiert. Fördergüter bewegen sich nur bei aktiver Produktion des jeweiligen Betriebs.
4. Fertighauswerk bauen. Unter **Stadt → Grundstück** ein Holzhaus als Bauziel vormerken. Nach Lieferung und Fertigstellung bringt es Miete und Wohnraum. Die goldene Anzeige über dem Haus oder Stadt → Mieten holt Erträge ab; der Hausverwalter automatisiert das. Weitere Fabrikzweige, Regionen und Projekte öffnen den nächsten Ausbau.

5. Unter **Bauen → Straßen & Wege** eigene Strecken anlegen. Im Busmenü zwei Haltestellen an Straßen bauen, in Fahrreihenfolge auswählen und den ersten Bus kaufen. **Stadt → Regionen & Projekte** erschließt später weitere Viertel.

Die automatisierte Progressionsprüfung erreicht das erste Haus aus einem frischen Profil ohne geschenkte Ressourcen nach 1.682 simulierten Sekunden. Dies ist ein einzelner geprüfter Spielpfad, keine Langzeit-Balance-Zusage.

## Prüfung und Grenzen

`bash scripts/test.sh` verwendet temporäre Spielstände: 220 Regelprüfungen, ein frischer Verlauf bis zum ersten Haus, 4.092 Szenen-/Geometrieprüfungen, 56 Platzierungs-/Tutorialprüfungen und 42 Prüfungen der offenen Produktion, Schattenumschaltung und Bildschirmaufteilung sowie 23 Begleiter- und 30 Alltagsszenenprüfungen sowie 216 Stadt-/Straßen-/Busprüfungen, 177 Landschaftsprüfungen und ein abschließender Headless-Start. Eine zusätzliche OpenGL-Prüfung testet die sieben wirklich gerenderten 3D-Symbole, Transparenz, Beleuchtung, getrennte Szenen, Druckzustand und erneutes Zeichnen nach Rückkehr aus dem Hintergrund (23 Prüfungen einschließlich 3D-Biber und sichtbarer Winkeanimation). Neun zusätzliche OpenGL-Prüfungen prüfen tatsächliche Landschaftsfarben, sichtbares Wasser, den gerenderten Pflanzenpuffer nach Verschieben eines Gebäudes und den Vordergrund bei weitem Zoom. [Prüfbericht](docs/VALIDATION.md). Die Bilder unter `docs/` stammen aus dem Spiel; die Stadtansicht verwendet ausdrücklich einen nur für das Bild aufgebauten Demonstrationsstand.

Noch offen: reale Android-Gerätetests für Touch, Safe Area, Hintergrund, Temperatur und Akku; 50-Stunden-Balancing, Barrierefreiheit, Release-Signierung, iOS und Store-Abnahme. Immobilienverkauf/Umbau, frei vom Spieler formbares Wasser/Gelände, Autobahnen, vollständige Bahn-/Schifffahrt und eigene Musik pro Biom sind noch nicht enthalten. Busse fahren berechnete Routen mit vereinfachter Einwohnernachfrage, ohne vollständige Kollisions-/Stausimulation. Die sichtbaren Transportstufen fahren den bisherigen gemeinsamen Export-Rundkurs; sie routen noch keine individuellen Warenaufträge. Förderbänder nutzen weiterhin gemeinsame Ressourcenpuffer. Geldscheine und einige seltene Baupläne haben noch keinen eigenen Ausgabepfad. Großprojekte verwenden Standortmodelle; es gibt noch keinen echten Hafenverkehr. Keine Werbung, In-App-Käufe oder Cloud-Spielstandsynchronisierung.

## Sicherung

Jeder geprüfte Meilenstein erhält einen Git-Commit und wird nach `origin/main` übertragen. Ein lokaler Commit alleine ist keine externe Sicherung. `scripts/backup.py` erstellt zusätzlich ein Quellarchiv und ein vollständiges Git-Bundle außerhalb des Checkouts. Die ZIP enthält Quellcode ohne APK; das Bundle enthält die ganze Git-Historie einschließlich der separat gespeicherten Test-APK. Der externe Sicherungsstand wird durch erneutes Abrufen und Vergleich des Commit-Hashes geprüft.

Keine Zugangsdaten, privaten Signaturschlüssel, Spielstände oder Build-Caches gehören in Git.
