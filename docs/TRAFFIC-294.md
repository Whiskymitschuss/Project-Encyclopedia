# Alpha 2 · Ladehöfe und Rückstau · 0.29.4

Anlass: Nach dem Update 0.29.3 bleiben auf dem Handy weiterhin dieselben LKW
stehen. Die dort behobene Gegenverkehrssperre war nur eine Ursache. Zusätzliche
Nachstellungen mit mehreren Betrieben, Baustellen und städtischen Fahrzeugen
zeigen blockierte Hofzufahrten und überfüllte Kreuzungsausfahrten.

| Aufgabe | Was und warum geändert wurde | Mehrwert für Spieler | Geschätzte Qualitätswirkung |
| --- | --- | --- | --- |
| Hofzufahrt freihalten | Einfahrt und leere Rückfahrt nutzen getrennte Hofseiten; die Entladezeit enthält eine stetige Wende statt eines sofortigen Richtungswechsels im selben Tor. Fahrzeugumrisse grenzen die bisher zu grobe Abstandssperre am Hof ein. | Ankommende Ware und Rückfahrer sperren sich nicht gegenseitig ein. | Sehr hoch |
| Flotte disponieren | Ein Ladehof betreibt eine laufende Frachttour. Weitere echte, bereits reservierte Ladungen warten mit gespeicherter FIFO-Nummer im Depot. Die Ladenlinie bucht erst nach Rückkehr eine neue Tour und verschickt Holz/Bretter ab der kleinsten verarbeitbaren Zweiermenge. | Weniger Kleinsttransporte und keine volle Durchgangsstraße aus Depotwartenden. Zusätzliche Flotte kann andere Betriebe versorgen. | Hoch |
| Kreuzungen räumen | Vor Einfahrt auch den Platz auf der empfangenden Spur prüfen. | Abbiegende LKW stellen sich nicht quer vor die Gegenfahrspur, während die nächste Ampel noch wartet. | Sehr hoch |
| Bau und Laden fair versorgen | Pro Ladehof zwischen Bau und Ladenlinie wechseln; einzelne Bretter für die nächste verarbeitbare Ladenladung ansammeln. Eine Konstruktionsvergabe entscheidet anhand eines gemeinsamen Ausgangsstands, damit Teilmengen für verschiedene Baustellen erhalten bleiben. | Weder Laden noch Baustellen werden dauerhaft verdrängt. | Hoch |
| Vorhandene Staus übernehmen | Vor der normalen Migration einmal alte, noch nicht angelieferte Frachten vom bestehenden Depot neu disponieren. Ladungen und Wege bleiben erhalten; gelieferte Ware und leere Rückfahrten bleiben gutgeschrieben. Der Revisionsmarker verhindert wiederholte Neuansätze. | Die vorhandene Firma kann fortgesetzt werden. Es gibt weder Gratisware noch doppelte Anlieferung. | Sehr hoch |
| Wartegründe erklären | Depotwartende melden „Verladung belegt“; die Bauleitung benennt den belegten Ladehof. Verkehrsmenü erklärt Hof- und Ausfahrtregeln. | Wartende Ladung lässt sich von einem defekten oder blockierten Straßenfahrzeug unterscheiden. | Mittel |

## Nachweis

Die beiden neuen JSON-Dateien in `Tests/Fixtures/traffic294-*.json` sind erzeugte
Testfirmen aus den tatsächlich entpackten Assets der veröffentlichten 0.29.3-APK:
Quellstand `129dcbe0a6a59f8647c7c7d1cabcbc1f5f04a030`, APK-SHA256
`b8f6a3cbcd4be3efd2b21204c39d89d934e3dfb6f5e86434826a8a9071a7d9f4`.
Sie enthalten mehrere Betriebe, zwei Brände und parallele Upgrades. Spiegelung der
vollständigen Stadt und lange Anhänger decken andere Einfahrtrichtungen ab.
Es wurde kein privater Handyspielstand gelesen oder verändert.

`TrafficRecovery294` prüft zwei alte Blockaden für weitere 1.200 simulierte Sekunden:
2.420 Prüfungen einschließlich vollständiger Materialbilanz in jedem Takt,
unveränderter Ladungen bei einmaliger Neu-Disposition, tatsächlicher Ankunft und
Rückfahrt aller ursprünglichen Transporte, fertiggestellter Baustellen und
abgeschlossener Dienste. Derselbe Test scheitert mit **11 Prüfungen** an der
unveränderten veröffentlichten 0.29.3. Mit der Korrektur bestehen alle Prüfungen.
Die zwei Fälle verkaufen 39 beziehungsweise 48 zusätzliche Möbel und schließen
3 beziehungsweise 2 Baustellen ab. Das sind Desktop-Simulationen, keine Handytests.

`TrafficStress294` kombiniert acht oder 16 LKW, Fahrzeugstufen 2/3/4/6, zwei
Stadtausrichtungen, 14 Upgrades und zwei echte Brände. Ein bereits ausgefahrenes
Fahrzeug darf nicht 180 Sekunden ohne Fortschritt bleiben. Zusätzlich werden
Verkäufe, Baustellen, Brände und Flottenlimit geprüft. Der Standardlauf nutzt
vier Fälle; `--full` prüft alle 16 Kombinationen für je 1.200 simulierte Sekunden.

Die OpenGL-Szene `VisualTrafficRecovery294` lädt einen dieser alten Staus in die
wirkliche Hauptszene und prüft über 300 Simulationstakte die Sichtbarkeit der
Depotwartenden, getrennte Positionen der sichtbaren LKW und tatsächliche Verkäufe.
Weitere Grafiktests decken die frühere Schlange, Feuerwehranzeige und Stadtbedienung
ab. Die Textur- und Bildschirmproportionen werden nicht verändert.

Die Ganzzustandsreferenzen von 0.29.1 und 0.29.3 bleiben unverändert im Archiv.
Die absichtlich geänderte Disposition und einmalige Migration erhalten eine
separate `offline294-reference.json`. Der alte Kurztest für drei synthetische
Depotladungen wartet nun ihre drei kompletten Rundfahrten einschließlich Ampeln
ab; seine senkrecht kreuzenden Touren bezeichnen korrekt unterschiedliche Depots.
Der 0.29.3-Test trennt die einmalige Depot-Neu-Disposition von der anschließenden
fortlaufenden Versorgung; Ankunft, Rückkehr, Material und Flottenlimit bleiben
unabhängige Bedingungen.

Die eine laufende Frachttour pro Ladehof ist eine bewusste Vereinfachung für diese
Alpha. Sie erlaubt weiterhin parallele Touren verschiedener Betriebe und sämtliche
städtischen Dienste. Eine vollständig physikalische Verkehrssimulation oder ein
Gerätetest auf dem betroffenen Handy wird damit nicht behauptet.
