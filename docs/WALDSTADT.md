# Waldstadt 0.20 — erster Abschnitt der 3D-Erneuerung

Der Einstieg bleibt eine Holzfirma. Vorhandene Häuser, Fabriken und Grundstücke
verwenden die überarbeiteten gemeinsamen Modelle auch in bestehenden Spielständen.
Das Startviertel ist die gestalterische Grundlage für weitere Weltabschnitte.

## Im Spiel umgesetzt

- Gemeinsame gerundete 3D-Geometrien für Baukörper, Maschinen und Fassaden sowie
  separat abgerundete Grundstücksplatten und Straßenabschlüsse. Die ursprünglichen
  19×23-Grundstücke und gespeicherten Gebäudeausrichtungen bleiben maßgeblich.
- Eingerahmte Front- und Seitenfenster, Fensterbänke, gegliederte Flachdächer mit
  Dachrand und Lüftung sowie begrünte Eingänge, Zäune und Briefkästen für passende
  Haustypen. Alle vorhandenen zehn Stadt-Ausbaustufen verwenden diese Gestaltung.
- Getrennte Oberflächen für Putz, lackierte Teile, Holz, Dach und Pflaster.
  Fenster erhalten ihren warmen Nachteindruck durch den tatsächlichen Tag-/Nachtstand;
  neu gebaute Fenster übernehmen ihn sofort. Gemeinsame Materialien benötigen
  keine eigene Leuchte pro Fenster.
- Sägewerk und andere offene Holzfabriken bekommen eine gestaltete Rückwand,
  Werkstattfenster, kleine Büroeinheiten und Markierungen am Ladebereich.
  Vorhandene Maschinen, Ladungen, Holzvorräte und Spänefüllstände bleiben echte
  Darstellungen der bestehenden Produktion.
- Gehwegmodule mit erhöhten Bordsteinen, lesbare Kreuzungen, Querungen und
  gerundete Gehwegecken. Tatsächliche Grundstücke, Neubauflächen und Haltestellen
  werden bei der Ausschmückung berücksichtigt.
- LKWs, Einsatzfahrzeuge, Taxis und Busse fahren sichtbar durch abgeleitete
  Kurven innerhalb des Straßenbereichs. Gespeicherte Wegpunkte, geschützte
  Straßenzellen und Transportuhren behalten ihre bisherigen Werte. Die kurze
  Rundung bedeutet eine etwas langsamere Fahrt durch die Kreuzung; sie schafft
  weder eine neue Abkürzung im Straßengraphen noch zusätzliche Lieferungen.
- Geschwungene Nadelbaumkronen, feinere Laubbäume und zusätzliche niedrige
  Wiesenpflanzen auf freien Bauflächen. Sie teilen die vorhandenen sechs
  Dekorations-Batches und das unveränderte Limit von 2.500 Dekorationseinträgen.
  Es bleiben genau 1.000 nutzbare Bäume. Bauen räumt die Pflanzen automatisch weg.
- Begrenzte Mesh- und Fahrkurven-Caches, nach Material zusammengefasste Modelle,
  kleine Grundstücksdetails mit Sichtweitengrenze, nach Kameranähe begrenzte
  Dekorationsinstanzen, einfachere entfernte Bäume und der bestehende Akkumodus.
  Produktionsfortschritt hängt weiterhin von der Simulation ab.

## Bedienung

Ein vorhandenes Spiel als Android-Update fortsetzen oder normal neu beginnen.
Nahe heranzoomen, ein Haus antippen und **Stufen 1–10** ansehen. Neue Architektur
entsteht weiterhin durch bezahlte Bauaufträge und echte Materiallieferungen.
Straßen und Häuser werden mit den vorhandenen Werkzeugen gebaut und versetzt.
Die begrenzte, mit dem Finger scrollbar bedienbare Gebäudekarte aus 0.19.2 bleibt erhalten.

## Abgrenzung

Diese Version ist der erste gestalterische Abschnitt. Der vorhandene Straßengraph
und die Zeichenwerkzeuge bleiben rechtwinklig; frei gezeichnete Straßenbögen,
ein neuer Kreisverkehr-Editor, Terrassenbau und eine vollständige Überarbeitung
aller Biome sind weitere Aufgaben. Es gibt keine neue Kollisions-/Ampelsimulation
oder neu erfundene Wirtschaft für rein dekorative Gebäude.

Die Vorschaubilder des Starts verwenden einen isolierten neuen Spielstand. Die
Stadt-, Haus- und Nachtbilder verwenden ausdrücklich ein aufgebautes Testprofil.
Sie werden in Godot gerendert und sind keine Konzeptbilder. Desktop-Grafikprüfungen
ersetzen keine Messung auf einem echten Android-Gerät.
