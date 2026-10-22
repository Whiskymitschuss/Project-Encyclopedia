# Weltumbau · 0.28.5-alpha.1

Erster integrierter Meilenstein des Biber-Masterauftrags vom 22.10.2026.
**Der Gesamtauftrag ist noch nicht abgeschlossen.** Diese Fassung erweitert das
vorhandene Spiel; sie ist keine getrennte Demonstrationswelt. Die wirtschaftliche
Spielbasis bleibt 0.28. Neue Modelle und Animationen schreiben keinen Firmenstand um.

## Bestandsaufnahme vor dem Umbau

Godot 4.6.3, GL Compatibility, prozedurale Modelle über `Buildings/Models.gd`,
18 Industrie-/Versorgungsarten, 15 Wohn-/Servicearten, zehn bewirtschaftete Biome.
`Game` verwaltet Wirtschaft und Speicherung. `LogisticsRoutes` verwendet den
Straßengraphen. `CentralLogistics`, `DeliveryChain`, `StoneIndustry` und
`ConstructionRules` besitzen echte getrennte Warenbestände und laufende Frachten.
Die Hauptwelt verwendet diese Systeme bereits. Arbeiter liefen bisher mit
Menschenmodellen; der Biber war vor allem Begleiter. Straßen wurden mehrfach aus
überlappenden Streifen gezeichnet, zusätzlich zu einem durchgehenden grauen Hof.

## Abgeschlossene Baugruppen

| Baugruppe | Änderung und Grund | Mehrwert | Geschätzter Qualitätseinfluss |
|---|---|---|---|
| Straßenflächen | Eine geometrische Vereinigung des echten Straßengraphen ersetzt doppelte Streifen und Kreuzungskappen. Asphalt, Gehweg, Bordsteine, Zebrastreifen und Forstpfade haben getrennte Höhen. | Keine beige Überdeckung; Kreuzungen und Bauflächen wieder lesbar. | Hoch |
| Grundstücke | Graue Gesamtplatte entfernt. Fabriken behalten eigene begrenzte Böden; freie Grundstücke zeigen wieder Gelände. Kameratiefenbereich reduziert, Waldparzellen erhalten größere Höhenabstände. | Übersichtlicher Aufbau und weniger gefährdete Tiefenflächen auf mobilen GPUs. | Hoch; echte Handyprüfung ausstehend |
| Biber-Familie | Zehn unterschiedliche Körper-/Kopf-/Ohren-/Schwanzformen mit gemeinsamen Gelenken, sichtbaren Zähnen, Schnauzen, Augen und Alters-/Gesichtsdetails. Drei unabhängig wählbare Berufskleidungen plus Zivil- und Feuerwehrausstattung. | Eigenständige Identität statt Menschen zwischen Bibern; 30 Varianten/Beruf-Kombinationen. | Hoch |
| Personal und Fahrer | Arbeiter, Bauarbeiter, Bewohner, Passanten, Feuerwehrbesatzung, Staplerfahrer, Frachtfahrer, Taxi-/Servicepersonal, Busfahrer, Forstmaschinen, Steinbruchbagger und Baukräne benutzen die neue Familie. Geöffnete Kabinen lassen Fahrer erkennen. | Arbeit und Transport gehören sichtbar zur Biberwelt. Vorhandene Tätigkeitscontroller bleiben erhalten. | Hoch |
| Maßstab | Erwachsene Biber etwa 1,9 Einheiten hoch; kompakte Busse, Einsatzfahrzeuge und Stapler passen zur Frachtflotte. | Weniger übergroße Figuren und kleinere Fahrzeuge in den Fahrspuren. | Hoch |
| Animation und Darstellungskosten | Gemeinsame prozedurale Gelenkstruktur; Arbeitsarme, Gang, Sitzen, Lenken, Kopf-/Schwanzbewegung und Blinzeln. Gepackte Szenen teilen fertige Meshes; Vertexfarben bündeln Fell und Kleidung je Körperteil. Fernsicht und reduzierte Bewegung begrenzen Zusatzanimationen. | Lebendige Figuren mit begrenzten Zusatzkosten. | Mittel bis hoch; keine gemessene Android-FPS-/Temperaturverbesserung |
| Einstieg | Dialogtext wird vor der Buchstabenanimation vollständig umbrochen. | Die Anleitungstaste bleibt während des Tippens an ihrer Position. | Mittel |
| Vorhandene Fabrikarchitektur | 14 vorhandene Industrie-/Versorgungsarten erhalten zehn aufeinander aufbauende Architekturmodule: Unterstand, Werkstatt, Regal, Förderbrücke, Stahlrahmen, Technikflügel, Portal, Dachverbund, Versorgungsbrücke und Leitstand. Bauflächen bleiben unverändert. | Fertige Upgrades verändern die Silhouette und Außenanlagen statt nur Farbe oder Skalierung. Bestehende Leistungssteigerungen bleiben wirksam. | Mittel bis hoch |
| Stapler und Warenübergabe | Werkshof- und Depotstapler folgen tatsächlichen Lade-/Entladephasen. Ware bleibt bis zur bestätigten Übergabe sichtbar. Zwei Zentralstapler teilen Aufträge nach ID auf. Werkstattfahrten umgehen die zentrale Maschinenlinie über Randgassen. | Keine erfundenen beladenen Produktionsrunden; nachvollziehbarer Übergabepunkt und leere Rückfahrt. | Hoch |

Die Bewertungen sind Designeinschätzungen, keine Ergebnisse einer Spielerbefragung.

## Tatsächlicher Stand nach Masterphasen

| Phase | Stand | Noch offen |
|---|---|---|
| 1 Analyse | Abgeschlossen für den vorhandenen Quellstand. | Neue Funktionen erneut gegen die vorhandene Wirtschaft prüfen. |
| 2 Einheitlicher Stil | Gemeinsame Biberfamilie, warme Oberflächen und Fabrikmodule integriert. | Vollständige Neuformung sämtlicher alter Gebäude und Umgebungsobjekte. |
| 3 Straßen/Welt | Kanonische Straßenflächen, Bordsteine, Markierungen und getrennte Grundstücke integriert. | Eigenständiger durchgehender Fußgängergraph; umfassende Hindernisnavigation für sämtliche Arbeitswege; individuelle Terrain-Neugestaltung. Die bisherige Verkehrsplanung bleibt Grundlage. |
| 4 Biber | Zehn Formen und drei Berufsausstattungen in der Hauptwelt integriert; frühere Menschenmodelle ersetzt. | Vollständige Aufnahme-/Einsteige-/Aussteige-/Werkzeugwechsel-Clips und neue berufsspezifische KI. Die besondere Variante hat noch keine Seltenheitsökonomie. |
| 5 Gebäude 1–10 | Zehn bauliche Ergänzungsstufen für 14 bestehende Arten; Wohn-/Serviceentwicklung bleibt vorhanden. | Keine Behauptung von 30 vollständig neu modellierten Gebäudefamilien. Zentrale/Express und Steinbruch/Steinwerk behalten ihre bisherige Entwicklung. Eigene editierbare Szenendateien und zehn individuell ausgearbeitete Maschinen-/Hallenlayouts je neuer Familie fehlen. |
| 6 Fahrzeuge/Logistik | Biberfahrer, sitzende Gelenke, reale Staplerphasen, Randgassen und vorhandene getrennte Flotten integriert. | Vollständige Fahrzeug-Ein-/Ausstiege, materialspezifische Regalplätze und umfassende Kollisions-/Manöverprüfung aller Grundstücksvarianten. |
| 7 Produktionsketten | Bestehende Holz-, Möbel-, Modul- und Steinketten erhalten ihre echten Inventare und Fahrten. | Neue Paletten-, Ziegel-, Beton-, Erz-/Stahl-/Träger-/Schraubenproduktion. Nicht jede dekorative Maschinenbewegung entspricht bereits einer einzelnen gebuchten Einheit. Holzernte und Figuren müssen noch pro Einzelauftrag synchronisiert werden. |
| 8 Bau/Upgrades | Bestehende Vorschau, Materialanforderung, echte Lieferungen und sieben materialabhängige Bauphasen erhalten; Biber-Bauteams integriert. | Zehn einzeln materialisierte Bauphasen und zusätzliche Baustoffrezepte ab Stufe 4. |
| 9 Integration | Sämtliche Änderungen dieses Meilensteins laufen in der vorhandenen Hauptwelt. | Weitere Baugruppen nach ihrer Umsetzung integrieren. |
| 10 Tests/Optimierung | Automatisierte Prüfberichte und Bildschirmaufnahmen dieser Fassung neben dieser Datei. | Physische Android-Ausführung, S26-Ultra-/S24-FE-Vergleich, Temperatur, Akku, Touch und Langzeit-Balancing. |

### Architektur und Maßstab

Ein Weltmaß entspricht einer stilisierten Einheit. Bestehende normale Grundstücke
bleiben 19 × 23, die Zentrale 31 × 23. Ein Erwachsener ist einschließlich Helm
etwa 1,9 Einheiten hoch. Sichtbare Fahrer werden für die kompakten Kabinen mit derselben Anatomie
auf Sitzmaß gebracht. Frachtfahrzeuge bleiben unter 2,5 Einheiten breit. Dies ist
ein bewusst stilisierter Maßstab, keine technische Nachbildung realer Metermaße.

`characters/beavers/BeaverModels.gd` trennt Form, Berufskleidung und Sitzpose;
`BeaverRig.gd` ergänzt die vorhandenen Tätigkeitscontroller. Die 30 Kombinationen
sind keine 30 getrennten KIs. `StreetSurface.gd` ist Darstellung des tatsächlichen
Graphen. `IndustryEvolution.gd` erzeugt die neuen Architekturmodule und benannte
Anschlusspositionen; die bisherige Wirtschaft bestimmt weiterhin die Kapazität.
`logistics/YardRoutes.gd` führt Werkstattstapler um die Maschinenlinie herum.

Die Warenbuchung gehört weiterhin dem Simulationssystem und funktioniert auch
bei ausgeschalteter Animation, unsichtbaren Objekten und Offline-Fortschritt.
Eine sichtbare Staplerpalette ist die Darstellung einer bereits reservierten
Fracht, kein zusätzliches Inventar. Ausblendung oder App-Minimierung darf deshalb
weder Waren erzeugen noch eine Lieferung von einem gerenderten Frame abhängig machen.

### Nächste fachliche Baugruppe

Zuerst die verbleibenden vorhandenen Gebäudefamilien und begehbare Arbeitswege
vervollständigen. Danach die zusätzlich gewünschten Fabriken und Materialketten
mit eindeutigem Eigentümer für Rohstoff, reservierte Fracht, Transport und Zielbestand
integrieren. Die fehlenden Industriezweige werden nicht als funktionslose Menüpunkte
oder dekorative Fabriken vorgetäuscht.
