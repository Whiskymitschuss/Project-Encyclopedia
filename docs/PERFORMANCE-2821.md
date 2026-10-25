# Kamera und Darstellung · 0.28.21-alpha.1

Ziel dieses Updates sind Ruckler während des Spielens und beim Kameraschwenk.
Es verändert weder Wirtschaft noch Lagergrenzen, Fahrzeugkapazitäten, Personal,
Waldwachstum oder Spielgeschwindigkeit.

## Gemessene Engpässe

Die Landschaft sortierte bei jedem Wechsel des 16-m-Kameraabschnitts alle
Dekorationseinträge und berechnete ihre Geländehöhe und Instanztransformationen
neu. Außerdem zeichneten viele statische Bauteile jede Lackfarbe separat.

Die neue Landschaft behält vorberechnete Transformationen. Sie partitioniert
nur die sichtbaren Instanzplätze und ändert dabei ausschließlich vertauschte
Plätze. Stillstehende Kameras und unveränderte Abschnitte lösen keine Arbeit
aus. Alle 2.500 Dekorationseinträge und die sechs bisherigen MultiMeshes
bleiben erhalten. Der Akkumodus behält seine Auswahl der nächsten 45 Prozent.
Diese Änderung belegt weniger Setter-Aufrufe und CPU-Arbeit; die tatsächlich
übertragenen GPU-Bytes wurden nicht mit einem Grafikdebugger gemessen.

Statische, untexturierte Lackflächen mit passenden Materialeigenschaften werden
pro vorhandenem Bewegungsknoten zusammengefasst. Ihre Farben stehen in den
Vertexdaten. Rauheit und Metall bleiben getrennt. Texturen, Glas, Leuchten,
benannte bewegliche Teile, Fahrer, Fördertechnik und Lageranschlüsse behalten
ihre eigenen Knoten. Fahrzeuge nutzen die neue Zusammenfassung beim Erstellen
und danach weiterhin ihren vorhandenen Pool. Es entstehen keine weltweiten
Riesenmeshes, die die räumliche Sichtbarkeitsprüfung verhindern würden.

## Wiederholbarer Vergleich

[Messbericht](alpha1-performance/frames-benchmark.json), erzeugtes Profil mit
18 Betrieben und zwölf Stadtgebäuden, tatsächliche Hauptwelt bei 540 × 960,
Standardqualität, automatische Detailreduktion ausgeschaltet. Vergleich mit
unveränderten Dateien der 0.28.20-APK. Wirtschaft nach 180 simulierten Sekunden
angehalten; Darstellung und Kamera laufen weiter. Desktop, OpenGL/Mesa llvmpipe.

| Messung | 0.28.20 | Optimierter Quellstand |
|---|---:|---:|
| Kameraaktualisierung bei Abschnittswechsel, Median aus 3 × 120 Aufrufen | 18,44 ms | 1,33 ms |
| Zeichenaufrufe, Fabrikansicht | 1.990 | 1.338 |
| Zeichenaufrufe, Stadtansicht | 1.482 | 932 |
| Zeichenaufrufe, Übersicht | 2.166 | 1.443 |
| Mesh-Knoten der Testwelt | 2.619 | 1.761 |
| Gesamte Knoten der Testwelt | 4.364 | 3.506 |

Das sind rund 93 % weniger CPU-Zeit für die Kameraaktualisierung und etwa ein
Drittel weniger Zeichenaufrufe in der Fabrikansicht. Der gesamte Firmenzustand
ist zwischen beiden Läufen identisch. Ein separat gerendertes Gebäudebild
unterscheidet sich im Mittel um höchstens 0,0022 von 255 RGB-Stufen; Materialien
und Silhouetten bleiben erhalten.

**Keine Behauptung über Handy-FPS:** Der Software-Renderer ist weiterhin stark
begrenzt; seine Bildzeiten verbessern sich nicht in jeder Ansicht und jedem
Perzentil. Die einmalige Weltkonstruktion steigt im Quellvergleich von ungefähr
2,43 auf 2,76 Sekunden durch das Zusammenfassen der Flächen. Dieser Pass ist
kein Ladezeit-Update. Ein echter Android-Geräte- und Wärmetest bleibt offen.
Der spätere APK-Vergleich steht zusätzlich im Paketprüfbericht.

Reproduktion nach Import des Projekts:

```bash
python3 scripts/benchmark_frames.py
# Optional: statt des Quellstands die tatsächlich gebaute APK vergleichen:
python3 scripts/benchmark_frames.py --candidate-apk exports/Timber-Loot-Tycoon-v0.28.21-alpha.1.apk --output /tmp/timber-performance-apk.json
```

Das Skript verwendet temporäre Projekte und Profile. Es liest keine privaten
Spielstände. Die beiden manuell ausführbaren Messszenen sind keine Ersatzwelt;
die Optimierung ist in der vorhandenen Hauptwelt integriert.

## Qualität und verbleibende Arbeit

`Performance2821` prüft tatsächliche farbige Dreiecke, unveränderte Materialien,
bewegliche Anschlüsse, sichere Ausnahmen, Instanzmitgliedschaft, Geländehöhen,
begrenzte Änderungen und den vollständigen Firmenzustand.
`VisualPerformance2821` vergleicht echte gerenderte Farben und prüft die
MultiMesh-Positionen, Größen und Farben mit dem OpenGL-Renderer. Die
Headless-Dummy-Grafik liefert keine tatsächlichen Instanztransformationen;
deshalb liegen diese Prüfungen ausdrücklich im Grafiktest.

Die bestehenden Lager-, Logistik-, Forst-, Straßen- und Bedienungsprüfungen
werden zusätzlich ausgeführt. [Quellprüfbericht](alpha1-performance/automated-checks.json).
Weitere Arbeit hängt von Messungen auf dem betroffenen Handy ab, insbesondere
GPU-Auslastung, tatsächliche Bildzeiten, Wärme und Speicher. Die vollständige
frühere Masterliste ist weiterhin nicht abgeschlossen.
