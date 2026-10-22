# 0.28.4-alpha.1 · Fabrik und Zentrallogistik

Weiter auf der 0.28-Spielbasis. Eigenständige Grafik; Lumber Inc. dient als Referenz
für klare Arbeitsbereiche, offene Fabriken, kräftige Farben und lesbare Bedienung.
Keine fremden Figuren, Bilder oder Markenassets übernommen.

## Aufgaben und Nutzen

| Abgeschlossene Aufgabe | Änderung und Grund | Nutzen | Geschätzter Qualitätseinfluss |
| --- | --- | --- | --- |
| Grafikfehler im Werkshof | Größerer zusammenhängender Hof; eine sichtbare Bodenfläche; erhöhte Markierungen, flache interne Fahrgassen, freigehaltene Kreuzungen; entfernte gestreckte Flächentexturen und Pflanzen im Beton | Weniger Flimmern und Überschneidungen; Arbeitsbereiche verständlicher | Hoch |
| Hausproportionen | Fenster, Eingang und Dachüberstand folgen der tatsächlichen Größe des Hauses auf jeder Stufe, statt festen Fremdmaßen | Keine schwebenden Fassadenteile; saubere Anschlüsse ohne verzerrte Skalierung | Mittel–hoch |
| Maßstab und Transport | Straßen-LKW unter 2,5 m breit und 6,6 m lang, kleinere Forstmaschinen und Bagger; Gebäude behalten ihre maßhaltigen Grundstücke; neuer großer Logistikhof | Fahrzeuge passen zu Fahrgassen und Werkstätten | Hoch |
| Laden und Frachttexte | Keine bildschirmfüllenden 3D-Liefertexte; Fahrzeugauswahl zeigt Ladung, Ziel und Phase. Ladung bleibt auf der Ladefläche, statt seitlich durch Maschinen zu gleiten | Sicht bleibt frei und Verladung wirkt schlüssiger | Hoch |
| Zentrallager | Neues Gebäude mit 31 × 23 m statt 19 × 23 m; größere Kapazität, Regale, zwei Stapler mit Fahrern, eigener Abholflotte | Fertigwaren sammeln sich nachvollziehbar an einem Ort | Hoch |
| Warenfluss | Nach Bau der Zentrale bleiben Holzernte und Fertigwaren zunächst am Produzenten; echte Abholung und Entladung schreiben sie dem Zentrallager gut. Bestehende lokale Lieferlinien beziehen Nachschub aus der Zentrale | Ein klarer Materialweg und weniger direkte Konkurrenz um Fertigwaren | Hoch |
| Baustellenflotte | Eigene schwarz-weiße Fahrzeuge; weiß-blaue Abhol- und Lagerfahrzeuge. Im Zentralbetrieb teilen sich Baustellen keine Fahrzeuge mit Produktion und Export | Eine Produktionsfahrt kann nicht die komplette Baustellenflotte belegen | Hoch |
| Abhol-Express | Neues regionales Depot; entfernte Baustellen wählen den nächsten geeigneten, straßenseitig verbundenen Stützpunkt. Zentrale liefert tatsächlichen Phasenbedarf, Baustellenfahrer übernehmen die letzte Strecke | Kürzere letzte Lieferstrecke ohne freie oder doppelte Ware | Hoch |
| Staplerarbeit | Arbeitszyklus aus Stellplatz, Aufnahme, Transport, Absetzen, leerer Rückfahrt und Parken; Ein- und Auslagerung mit unterschiedlichen Richtungen und Ladungsformen | Der Hof zeigt verständliche Arbeitsabläufe | Hoch |
| Lagerdarstellung | Sichtbare Stapel lesen tatsächliche Lagerbestände; Produktion zeigt ihren lokalen Ausgang | Gefüllte Paletten entsprechen vorhandenen Waren | Mittel–hoch |
| Verkehr | Endliche Abfahrtsreservierung auch für Ladebuchten und vorbeifahrende LKW; neue Touren halten straßenparallel außerhalb der Maschinen | Weniger Überschneidungen, keine neue gegenseitige Ampel-Wartelogik | Hoch |
| Materialanzeige | Sechs Werte in zwei lesbaren Reihen, exakte vierstellige Zahlen, helle Währungskarten, nummerierte Quellen mit Zustand | Material und Engpässe schneller erfassbar | Hoch |
| Feuer und Rauch | Bewegte, gekrümmte Flammenkörper mit Farbverlauf ersetzen starre Kegel; windabhängiger Rauch, Wasser, Licht und Fortschritt bleiben erhalten | Klar bessere Lesbarkeit als Brand statt Verkehrskegel | Mittel–hoch |

Die Einflussangaben sind Designschätzungen, keine gemessenen Spielerbewertungen.

## Benutzung

**Bauen → Versorgung → Zentrallager platzieren.** Erst nach Fertigstellung wird die
neue zentrale Warenlogistik aktiv. Der Hof benötigt eine größere freie Baufläche
und einen Anschluss an das Straßennetz. Es gibt eine Zentrale; sie kann ausgebaut
werden. Ein bestehendes Lagerhaus wird nicht ungefragt vergrößert oder versetzt.

Danach kann **Abhol-Express** unter Versorgung gebaut werden. Ab mehr als 80 m
Straßenroute prüft eine Baustelle erreichbare Express-Depots und wählt das nächste,
wenn seine letzte Strecke mindestens 20 % kürzer als die direkte Zentralroute ist.
Ohne geeigneten Express kommt die Lieferung direkt aus der Zentrale. Im Express
zurückgebliebene Ware kann über dessen Gebäudekarte physisch zur Zentrale
zurückgefahren werden.

Zentrale: drei Lager- und drei Baustellenfahrzeuge auf Stufe 1; Ausbau erhöht die
jeweilige Flotte bis höchstens sechs. Auch leere Rückfahrten belegen ihr Fahrzeug.
Eine Fertigware wird bei Abholung abgezogen, unterwegs separat gezählt und erst
nach Entladung gutgeschrieben. Fehlende Straßen oder voller Zielbestand erzeugen
keine Ware. Produktionsrezepte behalten ihre bestehenden Eingänge; generische
Werkstätten beziehen diese weiterhin aus dem gemeinsamen Zentralbestand.

Der große Bauumriss, Rotationen, Straßenprüfung, Vegetationsfreihaltung und
Gebäudeauswahl berücksichtigen die neue Fläche. Straßen und Gehwege behalten
ihren tatsächlichen begehbaren Graphen. Alte Standorte, Vorräte, Jobs und laufende
Fahrten werden erhalten. Alte Touren behalten ihre Zeiten; kurze private Zufahrten
werden außerhalb der Maschinen dargestellt. Kein Spielstand-Reset.

## Darstellung und Leistung

Stapler folgen realer Produktion beziehungsweise echten Ladephasen. Eine begonnene
Fahrt kehrt nach Arbeitsende leer zum Stellplatz zurück. Die Animation bucht selbst
keine Ware. Bis zu sechs nahe Stapler im Standardmodus, zwei im Akkumodus; reduzierte
Bewegung und Produktionspause werden beachtet. Die Simulation läuft unabhängig
von der sichtbaren Animation. Android bleibt bei maximal 30 FPS.

Zentrallogistik benötigt zusätzliche echte Routen und Fahrten. Eine konstante
Lieferung setzt freie Kapazität, hergestellte Materialien, Baustellenarbeiter und
Straßenanschlüsse voraus. Es wird kein unbegrenzter Warenfluss versprochen.

## Prüfung und offene Geräteprüfung

Automatisierte Prüfberichte: [Quellstand](alpha1-factory/automated-checks.json),
[exportierte APK-Ressourcen](alpha1-factory/packaged-checks.json),
[Testerplan](alpha1-factory/TESTPLAN.txt). Bilder zeigen tatsächlich gerenderte Szenen.
Nur künstliche Firmen und temporäre Profile wurden verwendet.

Desktop-/OpenGL-Prüfungen und Tests entpackter Ressourcen ersetzen keinen
Android-Gerätelauf. Reale Wärmeentwicklung, Akkuverbrauch und Startzeit auf
S26 Ultra/S24 FE sind weiterhin am Gerät zu prüfen. Der Debug-Testschlüssel und
das Paket bleiben identisch; Update ohne Deinstallation, Android-Code 2981.
