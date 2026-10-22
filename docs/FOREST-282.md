# 0.28.2-alpha.1 · Waldleben und Betriebsfluss

Weiter auf der wiederhergestellten 0.28-Basis. Keine Rückkehr zur verworfenen
0.29-Ampel-/Bauleitersteuerung. Eigene prozedurale Modelle und vorhandene Assets;
die Referenzbilder geben Farben, Silhouetten und Lesbarkeit vor.

| Abgeschlossene Aufgabe | Änderung und Grund | Mehrwert für Spieler | Geschätzter Qualitätseinfluss |
| --- | --- | --- | --- |
| LKW bleiben bei Produktionspause stehen | Bereits abgefahrene Lieferungen und Rückfahrten werden vor der Produktionspause abgearbeitet. Auftragsuhr und Verarbeitung bleiben pausiert. | Eine angehaltene Maschine strandet keine laufende Lieferung mehr. | Sehr hoch |
| Sich gegenseitig blockierende LKW | Zeitlich reservierte Abfahrten für Laden-, Baustellen-, Stein- und Exportfracht; Wartende bleiben im Depot. Getrennte Fahrspuren für Hin- und Rückweg. | Kreuzende und folgende LKW starten versetzt, statt auf der Kreuzung aufeinander zu warten. | Sehr hoch |
| Lange unsichtbare Startberechnung | Straßen-/Routen-Caches vermeiden wiederholte A*-Berechnung; wechselnde Miete invalidiert keine Route mehr. Eine getrennte Firmenkopie rechnet außerhalb der Darstellung. Sichtbares Logo und echter Fortschritt. | Frühes sichtbares Feedback, deutlich weniger Rechenarbeit; vollständiges Ergebnis wird erst am Ende gespeichert. | Sehr hoch |
| 1 · Engpässe direkt lösen | Produktionswarnungen, Gebäudekarte und neue Betriebsübersicht führen zum wirklich fehlenden Material oder angehaltenen Betrieb. | Weniger Suchen nach der Ursache; reale Bestände und Lieferwege bleiben nachvollziehbar. | Hoch |
| 2 · Materialtrends | Pfeile im Material-HUD und gemessene Änderung pro Minute in der Detailhilfe. Lager und zugehörige Fracht werden zusammen betrachtet. | Verbrauch wird früh sichtbar; bloßes Umladen erzeugt keinen falschen Rückgang. | Mittel bis hoch |
| 3 · Häuser bequem verschieben | Langer Druck öffnet die Vorschau; Bestätigung bleibt ausdrücklich nötig. Letztes Versetzen lässt sich auch nach Neuladen rückgängig machen, sofern der alte Platz noch frei ist. | Stadtgestaltung mit weniger Menüwegen; Stufe und erwirtschaftete Miete bleiben erhalten. | Hoch |
| 4 · Baukosten verständlich machen | Bauvorschau zeigt benötigt, frei und fehlend sowie bereits anderen Baustellen zugeteilte Fracht. Bestätigung und Abbruch bleiben außerhalb des Scrollbereichs. | Keine doppelt versprochenen Materialien; verständlichere Bauentscheidung auf kleinen Displays. | Hoch |
| 5 · Gestaffelte Depotabfahrt | Einheitliche endliche Fahrzeitreservierungen über alle vier Frachtarten, mit gespeicherter Wartezeit und sichtbaren Daten in der Betriebsübersicht. | Berechenbare Logistik ohne zusätzliche Ampelwartungsmechanik. | Hoch |
| 6 · Vergleichbare Leistungsmessung | Unter Mehr eine 30-Sekunden-Kamerarunde durch drei feste Ansichten, mit mittlerer Bildrate und 95. Perzentil der Framezeit. Stoppen/Minimieren beendet die Messung. | S26 Ultra und S24 FE können mit derselben Firma und demselben Profil verglichen werden. | Mittel |
| 7 · Ruhigere Weltbeschriftung | Namen und Frachttexte abhängig von Auswahl und Zoom; weit entfernte Frachtanzeigen auf drei begrenzt. Kontextmenüs verdecken keine zusätzliche Ereignisschaltfläche. | Mehr sichtbare Stadt, weniger überlagerte Schrift. | Hoch |
| 8 · Nützliche Rückkehrbilanz | Tatsächliche Verkäufe, fertiggestellte/verbesserte Gebäude und direkte Links zur Produktion, Fracht und zu den betreffenden Gebäuden. | Fortschritt nach Abwesenheit wird verständlich und führt direkt zurück ins Spiel. | Mittel bis hoch |
| Wärmere Grafikrichtung | Sandfarbene Höfe, blaue/kupferrote Giebeldächer, Holzzäune, helle Straßenränder, abgestimmte Bodenfarben und Beleuchtung bereits im ersten Weltframe. | Produktion und Straßen sind klarer unterscheidbar; die Welt wirkt freundlicher und zusammenhängend. | Hoch |

Die Einschätzungen sind Designurteile, keine gemessenen Bewertungen von Testern.
Die bestehenden Kernmechaniken bleiben Grundlage. Material, Miete, Fracht und
Fortschritt werden nicht durch Startboni oder erfundene Offline-Erträge ersetzt.

## Nachweise und Grenzen

- Vollständige Headless-Suite: 19.779 einzelne Prüfungen in 28 Suiten einschließlich
  zweier natürlicher Progressionsläufe; zusätzlich Hauptwelt-/Intro-Starttests.
- 648 Prüfungen in 14 unterschiedlichen OpenGL-Suiten. Die neue 28er-Suite wurde
  nach dem Umbruch der Ladeanzeige separat erneut ausgeführt.
- Neue Frachtsuite: 16 kreuzende, folgende und entgegenkommende Touren, zeitlich
  abgetastete Straßenpositionen, alle Hin-/Rückfahrten abgeschlossen, Fortsetzung
  nach JSON-Rundlauf identisch. Produktionspause lässt echte Fracht einmal ankommen.
- Cache-Vergleich: 30 simulierte Minuten mit denselben alten APK-Ressourcen und
  ausschließlich den Routen-Caches: **7.805 → 1.022 ms, rund 7,6×**, vollständiger
  Firmenzustand ohne Uhrstempel identisch. Dies misst die Cache-Optimierung, keinen
  vollständigen Vergleich zwischen zwei unterschiedlich disponierenden Versionen.
- Echter neuer Desktop-Prozess mit einer erzeugten gespeicherten Teststadt und
  acht Stunden Abwesenheit: erster Skript-Frame **436 ms**, vollständige Berechnung
  **13.971 ms**, 802 fortlaufende Frames. Kein Maß für Androids native Startzeit.
- Originaldatei und Live-Zustand bleiben während der Berechnung unberührt; Abbruch
  verbindet den Worker sicher und speichert keinen Teilstand. Minimieren stoppt
  nicht den Worker durch die Spielschleife. Android darf den ganzen Prozess trotzdem
  anhalten oder beenden; es wird kein Hintergrunddienst vorausgesetzt.
- Volle Ziellager können weiterhin berechtigt Fracht warten lassen. Bestehende
  alte Touren werden mit ihrer echten Ladung fortgesetzt; keine erzwungene Leerung.
- Bestehendes Android-Limit von 30 FPS, kleinere mobile Schatten und ausgeschaltete
  Hintergrunddarstellung bleiben aktiv. Kein Nachweis einer Temperaturverbesserung
  auf S26 Ultra oder S24 FE ohne Messung auf diesen Geräten.
- Alle Profile künstlich und isoliert unter `/tmp`; kein echter Spielstand gelesen.
  Einige ältere Grafiktests melden beim Beenden ObjectDB-Aufräumhinweise; dies ist
  kein bestandener Android-Langzeit-Speichertest.

[Automatische Prüfungen](alpha1-forest/automated-checks.json) ·
[Cache-Messung](alpha1-forest/route-benchmark.json) ·
[Testplan](alpha1-forest/TESTPLAN.txt) · [Vorschau](alpha1-forest/preview.png)
