# Leistung und Holzproduktionsstraße · 0.28.11-alpha.1

Diese Fassung baut auf der funktionierenden Logistik von 0.28.10 auf. Produktion,
Lager, Transportbuchungen und bestehende Straßen bleiben erhalten. Die neue
Arbeit betrifft Darstellung, Diagnose und verständlichere Bedienung.

## Leistung, die sich prüfen lässt

Android war bereits auf 30 FPS begrenzt. Neu werden sichtbare Details räumlich
begrenzt: Maschinen außerhalb des Bildes beziehungsweise in weiter Übersicht
animieren weder Säge noch Material auf Förderbändern und emittieren keine
Produktionspartikel. Ihre echten Lagerwerte werden weiter in größeren Abständen
aktualisiert. Sichtbare Maschinen erhalten höchstens 30 Animationsupdates pro
Sekunde, im Akkumodus beziehungsweise bei Entlastung zehn. Ein unsichtbarer
Stapler durchsucht nicht mehr in jedem Bild sämtliche Warentransporte. Er
verwirft seine rein visuelle Handhabung und übernimmt beim Zurückschwenken den
tatsächlichen gebuchten Transport. Keine dieser Änderungen bewegt Waren.

Auf hochauflösenden Android-Displays begrenzt die aktivierte automatische
Entlastung die Welt zunächst auf ungefähr zwei Millionen 3D-Pixel. Kleinere
Displays behalten ihre native Auflösung. Die verwendete Skalierung ist sichtbar;
das Abschalten der Option erlaubt volle native 3D-Auflösung.

Die adaptive Darstellung reagiert nach rund drei Sekunden dauerhaft schlechter
Bildzeiten. Nur die 3D-Auflösung sinkt auf 85 Prozent der gewählten Basis je Dimension; Schatten
entfallen vorübergehend. Stabile Bildzeiten stellen die Details mit einer
Wartefrist wieder her. Die Option ist abschaltbar. Akkumodus verwendet explizit
75 Prozent der Basis je Dimension. Menü und Schrift behalten ihre native Auflösung;
Fotomodus verwendet volle 3D-Auflösung. Die Schattenreichweite bleibt begrenzt,
weite Übersicht verzichtet auf Schatten. Eine zurückkehrende Firma rendert das
Intro-Diorama statisch statt während der Offline-Nachrechnung weiter zu animieren.

Das ist keine temperaturgesteuerte Regelung. Android-Geräte, insbesondere S26
Ultra und S24 FE, müssen hinsichtlich Wärme, Akku und Dauerleistung weiterhin
physisch verglichen werden. Die Offline-Wirtschaft wird nicht verlangsamt oder
durch einen pauschalen Ertrag ersetzt. Eine neue Beschleunigung der eigentlichen
Offline-Simulation gegenüber 0.28.10 wird nicht behauptet.

Ein kontrollierter Vergleich mit unveränderten Ressourcen der veröffentlichten
0.28.10-APK verwendet je 20.000 manuelle Aufrufe eines unsichtbaren Sägewerks und
Staplers. Drei Durchläufe je Stand ergeben einen Median von **196,2 → 73,5 ms**.
Der Firmenstand bleibt jeweils unverändert. Dies ist ein kleiner Desktop-CPU-Test
für diese beiden Controller, keine FPS-, Temperatur- oder Android-Messung.
[Messdaten](alpha1-timberline/presentation-probe.json) und
[Probe](alpha1-timberline/presentation-probe.gd.txt).

## Messung im Spiel

Mehr → Hilfe → Startzeit, FPS & Kamerarunde sowie Einstellungen → Startzeit & FPS
zeigen die aktuellen Sitzungswerte. Ein begrenztes Fenster aus 180 tatsächlichen
Bildabständen liefert FPS und P95. Offline-Berechnung, Hintergrundzeit und die
ersten zwei Sekunden nach dem Szenenwechsel zählen nicht als normale Welt-FPS.

Die Werte unterscheiden den ersten Script-Frame seit Engine-Start, das erste
gezeichnete Weltbild nach „Weiterspielen“ und die letzte Offline-Nachrechnung mit
ihrer simulierten Dauer. Der erste Wert misst ausdrücklich nicht den gesamten
Android-App-Start seit Berühren des App-Symbols. Messdaten liegen außerhalb des
Firmenzustands und werden im neuen Feedbacktext ergänzt. Bestehende Textentwürfe
bleiben unverändert. Die Kamerarunde steht weiterhin zum Gerätevergleich bereit.

## Lesbare Holzproduktion in der Hauptwelt

Sammelstation, Sägewerk, Holzwerkstätten und Lager erhalten zusammenpassende,
maßhaltige Hofmarkierungen. Türkis kennzeichnet Eingänge, Gold Ausgänge. Paletten-
Anschläge und Holzständer bleiben innerhalb des vorhandenen Grundstücks und
außerhalb der Stapler-Randwege. Das Sägewerk bekommt eine zusätzliche offene
Sägeabdeckung. Wiederholte Hofgeometrie teilt Meshes und Materialien.

Ein kleines Produktionslicht nutzt den wirklichen Werksstatus: Grün bedeutet
Material vorhanden, Gold vollen Ausgang, Rot fehlende Eingänge. Pause zeigt ein
dunkles Licht. Ein angehaltener Produktionsprozess lässt kein erfundenes Produkt
auf dem Band weiterfahren. Mengen, Rohstoffe und verbuchte Transporte bleiben
autoritativ. Die schon vorhandenen Biber, fallenden Bäume, Holztransporter und
Stapler gehören weiterhin zur echten Hauptwelt.

Logistik → Holzkette erklärt den tatsächlichen Ablauf über ein Rohstofflager,
zeigt bestehende Stationen, Lager und Sägewerke mit ihren aktuellen Werten und
führt zur jeweiligen Anlage. Die Anzeige erfindet keine direkte Wald-Sägewerk-
Verbindung, wenn die aktuelle Firma über Zentrale oder Express transportiert.

## Gebäudeversetzen

Die Vorschau nennt Grundfläche und Anschluss an das tatsächliche Straßennetz.
Eine gestrichelte Markierung führt vom Grundstücksrand zum gewählten Straßenpunkt.
Grün kennzeichnet freie, angebundene Fläche. Freie Fläche mit noch fehlender
LKW-Verbindung ist goldfarben; bestehende Platzierungsfehler bleiben rot und
zeigen ihren bisherigen konkreten Grund. Eine Straße muss mit dem Betriebsnetz
verbunden sein, bevor die Vorschau sie als erreichbare LKW-Zufahrt beschreibt.

Das Bauen vor der späteren Straßenerschließung bleibt möglich. Der Hinweis
ändert keine Baukosten, Straßen oder alten Grundstücke. Abbrechen entfernt die
Vorschau vollständig. Belegte Fahrzeuge und laufende Ausbauten schützen ihre
Standorte weiterhin. Die Waren-Schaltfläche bricht auch bei großer Schrift nicht
mehr mitten im Wort um.

## Grenzen und Prüfung

Automatisierte Firmen, Hauptweltszenen und unveränderte APK-Dateien werden am
Desktop geprüft. Kein privater Spielstand und kein physischer Android-Lauf.
Die ganze Masterliste mit sämtlichen Gebäuden, zehn vollständig neuen Stufen
und umfassend neuen Weltgrafiken ist weiterhin offen. Dieses Update liefert
den beschriebenen Feinschliff an den vorhandenen Anlagen, keinen vollständigen
Asset-Austausch.

Android-Code 3006, gleiche Paketkennung und dasselbe Testzertifikat.
Als Update installieren; nicht deinstallieren und keine App-Daten löschen.
