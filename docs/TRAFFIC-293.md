# Alpha 2 · Verkehrsfix · 0.29.3

Anlass: Im Handybild stehen LKW hintereinander, Betriebe warten auf Material und
Feuerwehreinsätze sind offen. Die kürzere Ladeberechnung aus 0.29.2 beseitigte
keine Fehler in den Verkehrsregeln.

| Aufgabe | Änderung und Grund | Mehrwert für Spieler | Geschätzte Qualitätswirkung |
| --- | --- | --- | --- |
| Gegenseitige Blockade lösen | Getrennte Spuren derselben Grünrichtung gelten nicht länger als Querverkehr. Versteckte Depotfahrzeuge und Fahrzeuge in Arbeitsbuchten blockieren die Kreuzungsfreigabe nicht. | Die nachgestellte Ladenlinie liefert und verkauft wieder, auch mit bereits gespeicherter Schlange. | Sehr hoch |
| Feuerwehr durchlassen | Eine anrückende, einem Brand zugeteilte Feuerwehr fordert für ihre Achse Grün im Umkreis von 32 Metern an. Bereits kreuzende Fahrzeuge räumen zuerst. Bei defekter Ampel bleibt der bisherige Wechselverkehr wirksam. | Vorausfahrende LKW können abfließen; die Feuerwehr bekommt Grün ohne abgeschaltete Abstandskontrolle. | Hoch |
| Tatsächlichen Status anzeigen | Nach einem freigegebenen Bewegungsschritt die alte Wartemeldung entfernen; ausfahrende Depotfahrzeuge wieder einblenden. Verkehrsmenü erläutert die neue Freigabe. | Ein wieder fahrender LKW meldet nicht länger seinen früheren Haltegrund. | Mittel |
| Vorhandene Firma erhalten | Dieselben gespeicherten Wege und Ladungen mit korrigierten Regeln weiterfahren lassen. Kein Zurücksetzen, keine geschenkten Waren und kein künstliches Fertigstellen. | Update setzt die Firma fort. | Hoch |

## Reproduktion und Grenzen

`Tests/Fixtures/traffic293-gridlock.json` ist ausschließlich erzeugtes Testmaterial:
Die veröffentlichte APK 0.29.2 (Quellstand
`84a700d8b9b3d1b696e760d3edd8689455a90fb1`, APK-SHA256
`f36640a234aa690387de47586de56d4adb6e5ab8482b393c5d1f9e34763f2317`)
simulierte die vorhandene Teststadt mit 20 Häusern und acht LKW für 120 Sekunden.
Acht Fahrzeuge blieben anschließend hängen; die Verkaufszahl blieb auf eins.
Es wurde kein privater Handyspielstand geöffnet oder verändert.

`TrafficFlow293` prüft diese unveränderte Schlange mit kleinen LKW und langen
Anhängern weitere 600 Sekunden: jede ursprüngliche Fahrt liefert und kehrt zurück,
Verkäufe gehen weiter, echte Aufträge werden abgeschlossen, Material bleibt in
jedem Schritt erhalten und die gekaufte Flottengröße wird eingehalten. Dazu kommen
Gegenverkehr, Feuerwehr-Grün, belegte Kreuzung, Ampelstörung sowie Gleichheit von
normaler Simulation und Wiederherstellung. Gegen die tatsächlich entpackten Assets
der alten APK scheitern 9 von 2.414 Prüfungen; mit der Korrektur bestehen sie.

Ein separater Stresslauf über je 1.800 simulierte Sekunden mit Fahrzeugstufen
2, 3, 4, 6 und 9 ergab jeweils 55 verkaufte Möbel, 12 pünktliche Aufträge und
zwei gelöschte Brände. Dies sind Desktop-Simulationen, keine Handy-Messungen.
Normale rote Ampeln und vorübergehender Rückstau bleiben Teil des Spiels.

Die alten Ganzzustands-Hashes `offline292-reference.json` bleiben unverändert als
historischer Nachweis. Die korrigierten Regeln verändern bewusst Lieferzeiten,
Brandeinsätze und Erträge. `OfflineReplay292` verwendet daher nun die ausdrücklich
als 0.29.3 gekennzeichnete `offline293-reference.json`; die unabhängigen Prüfungen
auf Materialerhaltung und kontinuierliche Lieferung stehen in `TrafficFlow293`.

Der OpenGL-Test lädt dieselbe gespeicherte Testschlange in die echte Hauptszene,
prüft die acht separaten Fahrzeugmodelle, steigende Verkäufe und die Übereinstimmung
von sichtbarer und berechneter Position im Hochformat 591 × 1280. Weitere bestehende
Grafiktests decken Ampeln, Brandanzeige und Stadtbedienung ab. Ein tatsächlicher
Android-Gerätetest bleibt erforderlich; der Screenshot allein ist kein Zugriff
auf die genaue Firma des Spielers.
