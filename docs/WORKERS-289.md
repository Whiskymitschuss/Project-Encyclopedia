# Holzfäller und echte automatische Ernte · 0.28.9-alpha.1

Der Nutzer hat den gezeigten Holzbestand durch manuelles Fällen und Abliefern
gefüllt. Diese Bestandszunahme belegt keine funktionierenden Helfer. Deshalb
prüft diese Fassung die automatische Ernte unabhängig von manuellen Aktionen.

## Nachgestellte Ursachen

Eine generierte fortgeschrittene Firma mit 31 Helfern, Holzharvester Stufe 11,
104 Holz am Sammelplatz und 802 Holz in der Zentrale wurde 30 Minuten ohne
`chop()` oder `deposit()` simuliert. Vor der Änderung entstanden nur 72 Holz,
verteilt auf vier Simulationssekunden mit Ernte. Die längste Erntepause betrug
586 Sekunden. Der zentral gelagerte, zuvor manuell erworbene Vorrat verhinderte
die dringende Waldabholung. Andere Waren belegten die gemeinsamen LKW.
Die alte Holzladung von 18 war kleiner als der manuelle Baum-Ertrag von 37.

Zusätzlich ersetzte ein gekauftes Großgerät sämtliche sichtbaren Biber-Holzfäller
durch höchstens vier Maschinen. Die übrigen Arbeiterdarstellungen entfielen.
Der alte Entfernungsschnitt blendete Arbeiter beim isometrischen Herauszoomen
aus. Tiefe Waldpositionen verdeckten sie hinter Baumkronen; eine Fokusfahrt zur
Waldmitte konnte sie unter die untere Materialanzeige setzen. Das Ende einer
Baustellenfahrt erzeugte außerdem die gesamte Helfergruppe neu.

## Umgesetzte Änderungen

- Ein voller beziehungsweise abholbereiter Wald bekommt eine echte Abholtour,
  auch wenn schon Holz im Zentrallager liegt. Vorhandene Holztouren und ihre
  leere Rückfahrt zählen weiterhin zur begrenzten gemeinsamen Flotte.
- Holztransporter holen vier Bündel statt einer Kistenladung ab; im Prüffall
  sind das 72 statt 18 Holz. Andere Waren behalten ihre Kapazität. Die begrenzte
  Warenannahme nimmt auch bereits gebuchte größere Ladungen verlustfrei auf.
- Biber und Maschinen arbeiten gemeinsam innerhalb des bisherigen mobilen
  Figurenlimits. Eine ausdrücklich pausierte Station erhält keine aktive Crew,
  solange eine andere Sammelstation arbeitet. Baustellenfahrten setzen den
  Waldtrupp nicht mehr zurück.
- Holzfäller stehen am vorderen Rand der Baumreihen und bleiben beim Zoom
  darstellbar. **Team → Holzfäller ansehen** fokussiert diesen Arbeitsbereich.
- Tatsächlich gebuchte Holzladungen lösen Trage- und Ladebewegungen aus, auch
  wenn der Sammelplatz bis zur Abholung voll ist. Ohne Ernte und Ladeauftrag
  wird kein Fällen vorgetäuscht. Animationen erzeugen keine zusätzlichen Waren.
- **Team** zeigt einen getrennten Zähler **Automatisch gewonnen seit Update**,
  die aktuelle Ernte und den Status jeder Sammelstation. Manuelles Fällen und
  Abliefern verändern diesen Zähler nicht. Reduzierte Bewegung wird angezeigt.

## Ergebnis und Prüfgrenzen

Mit denselben Ausgangswerten entstehen nach der Änderung **1.544 automatisch
gewonnene Holz in 30 Minuten**, ohne manuelles Fällen oder Abliefern. Die längste
Erntepause sinkt im Prüffall auf **125 Sekunden**. Mit anfänglich 1.015 zentral
gelagerten Holz entsteht dasselbe Ergebnis. Die Werte sind reproduzierbare
Simulationen, keine zugesicherte Produktionsrate für jeden Spielstand.
[Kontrollskript](alpha1-workers/controlled-probe.gd.txt),
[vorher](alpha1-workers/controlled-before.json) und
[nachher](alpha1-workers/controlled-after.json) sind dokumentiert.

Geprüft werden echte Vorratsbewegungen, gemeinsame Flottengrenzen, fortlaufende
Werkproduktion/Verkäufe/Baustellenfahrten und eine identische Fortsetzung nach
vollpräziser JSON-Speicherung. Grafikprüfungen verwenden die Hauptwelt mit
Bibern, Maschine, fallenden Bäumen, unverändertem Inventar während Animationen,
echten reservierten Ladungen und dem tatsächlichen Team-Menü. Kleine Bildschirme,
große Schrift und beide Grafikstufen sind eingeschlossen.

Ein wirklich volles Lager, eine Pause oder eine fehlende Straße begrenzen die
Ernte weiterhin. Nicht alle 31 Helfer werden gleichzeitig als 31 Figuren
gerendert. Das vorhandene Figurenlimit bleibt erhalten. Die sichtbaren
Arbeitsschleifen lesen verbuchte Produktion und Transporte; individuelle
Baum-/Werkzeugaufträge für jeden einzelnen Biber sind noch kein vollständiges
eigenes Inventarsystem.

Der private Spielstand und ein physisches Android-Gerät liegen hier nicht vor.
Die Hauptwelt und die unveränderten Dateien der tatsächlichen APK werden mit
Desktop-Godot geprüft. Ladezeit, Temperatur und mobile Dauerleistung sind damit
nicht auf dem Handy nachgewiesen. Die Startoptimierung aus 0.28.8 bleibt enthalten;
diese Fassung behauptet keine weitere Ladezeitverbesserung.

Der vollständige Masterumbau bleibt offen; siehe
[Reststand](WORLD-REWORK-286.md). Gleiche Paketkennung und dasselbe Testzertifikat,
Android-Code **3004**. Als Update installieren, nicht deinstallieren und keine
App-Daten löschen.
