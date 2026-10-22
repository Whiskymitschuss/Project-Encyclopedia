# 0.28.3-alpha.1 · Offener Werkshof und animierte Abläufe

Die neuen Referenzen zeigen vor allem einen anderen Aufbau: Waldparzellen,
breite Holztransportwege, ein zusammenhängender offener Produktionshof und
ein kurzer Dialog direkt in der Welt. Diese Gliederung ist jetzt umgesetzt.
Modelle, Figuren und Texte stammen aus dem eigenen Projekt.

| Aufgabe | Was wurde geändert? | Warum / Mehrwert für Spieler | Geschätzter Qualitätseinfluss |
| --- | --- | --- | --- |
| Zusammenhängender Werkshof | Gemeinsame Betonfläche, interne weiß markierte Fahrgassen, niedrige weiß-rote Randmauern mit freien Zugängen. Werkstätten ohne einzelne hohe Rückwand und Dach. | Holzlager, Verarbeitung und Erweiterungsfläche wirken wie ein gemeinsamer Betrieb; Maschinen bleiben sichtbar. | Sehr hoch |
| Klar gegliederter Wald | Je Biom zehn leicht versetzte Baumreihen, breite sandfarbene Ränder und Zäune außerhalb von Straßen und belegten Grundstücken. Nördliche Transportwege erhalten eine breitere sandfarbene Oberfläche. | Der Spieler erkennt bewirtschaftete Waldflächen und den Weg zur Produktion. Die vorhandenen hundert fällbaren Bäume je Biom bleiben erhalten. | Hoch |
| Kompakteres HUD | Schmale orange-braune Währungsleiste, Profilzugang zum Team, kompaktere Navigation, sechs Materialzähler in einer Zeile auf normalen Handys; kleine Displays/große Schrift nutzen zwei Zeilen. | Mehr Platz für die Welt; Materialbestände und wichtigste Aktionen bleiben direkt erreichbar. | Hoch |
| Einführung in der Welt | Drei eigene Benno-Dialoge mit Textaufbau und animiertem Porträt; Touch führt zum wirklichen Lager und Sägewerk. Kurze Anleitung oder freies Spiel bleiben direkt wählbar. | Der Betrieb wird am echten Schauplatz erklärt. Kein Zwang, eine lange Bildfolge abzuwarten. | Hoch |
| Werkstatttransporte animieren | Gabelstapler fahren bei tatsächlicher Produktion am Warenausgang, mit drehenden Rädern, Hubgabel, Ladung und leicht bewegtem Fahrer. Sichtbarer Output passt zum Betrieb. | Maschinen erscheinen als Teil eines Arbeitsablaufs. Die Animation erzeugt keine zusätzlichen Waren oder Gewinne. | Hoch |
| Verladen animieren | Laufkatze und Haken des Lagerkrans folgen der realen Lade-/Entladephase eines zugehörigen LKWs. | Warenumschlag wird am richtigen Gebäude und zur richtigen Zeit sichtbar. | Mittel bis hoch |
| Holzfäller animieren | Axtbewegung im Wald, beladener Weg zum Lager, Entladen und leere Rückkehr. | Arbeitsrichtung ist verständlicher; der vorige beladene Rückweg in den Wald ist korrigiert. | Hoch |
| Hinweise sauber anordnen | Produktionswarnungen und Frachtanzeigen berücksichtigen Tutorial, Porträt und Begleiterblase bei der Kollisionsvermeidung. | Keine schwebende Warnung über dem Einführungsknopf oder Dialog. | Mittel |
| Team und Einstieg anpassen | Teamübersicht mit eigenem Porträt und verständlicher Rollenbeschreibung; warmer Titelhintergrund. Bestehende Einstell- und Werkzeugaktionen bleiben echt. | Einheitliche visuelle Sprache vom Start über die Einführung bis zur Verwaltung. | Mittel |
| Mobile Last begrenzen | Höchstens sechs nahe Werkstattstapler, zwei im Akkumodus. Ferne Animationen ruhen; reduzierte Bewegung stoppt Arbeiter, Stapler, Kräne und Porträtbewegung. Statische Hof-/Walddetails werden gebündelt. | Lebendigkeit mit begrenzter zusätzlicher Darstellungslast. | Hoch |

Die Schätzungen sind Designurteile, keine gemessenen Testerbewertungen.
Bestehende Flammen, Rauch, Löschwasser, Säge, Fördergut, Dampf, Bauarbeiter,
Fahrzeuge, Wind und Verkaufs-/Fortschrittseffekte bleiben Teil der animierten Welt.
Es werden keine fremden Spielfiguren oder Bilder in die App übernommen.

## Bestehende Firmen und Grenzen

Gespeicherte Gebäude, individuelle Standorte, Straßenverbindungen, Fracht,
Ressourcen und Produktionsregeln werden nicht neu angeordnet oder zurückgesetzt.
Der gemeinsame Werkshof gestaltet die bisherige zentrale Startfläche um; frei
versetzte und neue Betriebe behalten ihre Standorte. Die sichtbaren Fahrgassen
verwenden das bestehende reale Straßennetz. Die Ausbaustadt bleibt erhalten.

Die 0.28-Basis sowie Start- und Verkehrsfixes aus 0.28.2 bleiben aktiv. Kein
neues Ampel-/Bauleiterpflichtsystem. Animationen sind eine Darstellung der
vorhandenen Arbeit; sie buchen keine einzelnen sichtbaren Holzstücke zusätzlich.
Standard- und Akkumodus behalten auf Android maximal 30 FPS.

Alle automatischen Tests verwenden künstliche temporäre Firmen. OpenGL-Tests
und die Prüfung entpackter APK-Ressourcen sind Desktop-Prüfungen. Ein tatsächlicher
Android-Gerätelauf sowie Wärme-/Akkumessungen auf S26 Ultra und S24 FE stehen aus.
Einige ältere Grafiktests melden weiterhin ObjectDB-Aufräumhinweise beim Beenden.

[Automatische Prüfungen](alpha1-campus/automated-checks.json) ·
[Testplan](alpha1-campus/TESTPLAN.txt) · [Hofansicht](alpha1-campus/yard.png) ·
[Einführung](alpha1-campus/story.png)
