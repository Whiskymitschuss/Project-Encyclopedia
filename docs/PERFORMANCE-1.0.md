# Timber Loot Tycoon – Performance Update 1.0

Spielversion **0.28.26-alpha.1**, Android-Code **3021**. Das vorhandene Projekt
wurde überarbeitet. Eine stabile Bildrate von 30 FPS auf dem SM-S721B ist noch
nicht nachgewiesen. Wetter bleibt vollständig aus. Die Spielversion bleibt Alpha.

## 1. Ausgangsstand und gefundene Probleme

Verbindlicher Ausgangsstand: `ed7ca551c4d7dd429409e9d3f33775076be008b9`.
Git-Sicherung und zuvor wiederhergestelltes vollständiges Bundle vorhanden.
Die vom Nutzer gemeldeten 4,7 FPS / P95 395 ms / 21.861 ms Weltaufbau sind eine
reale Samsung-Messung unter Mobile/Vulkan; die untenstehenden Rechnerdaten sind
keine neuen Handywerte. [Ausgangsprotokoll](performance-1/baseline.json).

Nachgewiesen in einer festen, erzeugten Stadt mit 18 Betrieben und 12 Häusern:

- Vollständiges Neubauen der Welt bei unveränderten Bau-/Mitarbeiterdaten:
  zwei Aufrufe kosteten 291,9 und 329,7 ms CPU. Dabei wurden auch aktive
  Transportdarstellungen verworfen.
- Erste Arbeiterdarstellung: 190,6 ms CPU. Terrain und Modelle wurden während
  des Spielstarts prozedural erzeugt; Landschaftsphase rund 692 ms.
- Fahrzeuge und bisher unbenutzte Biber-Geometrie entstanden während laufender
  Transporte. Unvorbereitete erste Aufrufe erreichten im CPU-Test 15–26 ms.
- Bisherige Fahrzeugpools waren nur pro Ladungsstil begrenzt; alte
  Fahrzeugstufen konnten in vielen separaten Pools weiterleben.
- Überwiegend gut begrenzte laufende Skriptarbeit: alle Skripte einschließlich
  NPCs separat geprüft. Diese Zeiten erklären die Handy-Bildzeit nicht allein.
- Im Renderer-Vergleich kostet die sichtbare 3D-Welt wesentlich mehr als die
  reine Oberfläche. Weniger Dreiecke führen unter Software-Vulkan nicht in
  jedem Durchlauf zu entsprechend kürzeren Bildzeiten.

## 2. Umgesetzte technische Lösungen

**Ressourcen und Start:** 690 vorbereitete Ressourcen aus der bestehenden
Geometrie. Alle vorhandenen Gebäudefamilien erhalten vorbereitete Stufen 1–10,
beide Stile, unveränderte Anschluss-/Kollisions-/Maschinenknoten. Identische
Industrievarianten teilen dieselben Dateien. 120 kompatible Biber-Rigs,
LKW/Kipper für Stufen 2–9, Mannschaftssprinter und Landschaft werden vorbereitet.
ImporterMesh erzeugt zusätzliche automatische LODs; nahe Originalgeometrie
bleibt erhalten. Keine neuen Platzhalter.

Godots Thread-Loader lädt benötigte Ressourcen mit bis zu vier offenen Aufträgen;
Szenenbaum und Instanzen bleiben auf dem Hauptthread. Der reale Spielstart
verteilt Arbeiten über mehrere Frames. Die Ladeabdeckung zeigt echten
Arbeitsfortschritt; Kameraeingaben bleiben gesperrt. Währenddessen wird keine
unfertige 3D-Welt teuer gezeichnet. Vor Freigabe wird das erste Weltbild gerendert.
Zusätzliche Ladezeit wird wirtschaftlich einmal berücksichtigt, bereits durch
Resume berechnete Zeit abgezogen. Separate Startphasen stehen im Leistungsmenü.

**Welt und Rendering:** inkrementeller Abgleich anhand stabiler IDs und Revisionen.
Unveränderte Gebäude, Straßen und Fahrzeuge bleiben bestehen. Ein Upgrade ersetzt
seinen Gebäudeteil. Ein Spielstandswechsel aktualisiert gebundene Daten erneut.
Virtuelle 64-Einheiten-Zellen erhalten öffentliche Node-Pfade und Spielstands-IDs.
Konservative Bildschirmgrenzen berücksichtigen große Gebäude und Ladehöfe.
Entfernte Gebäude behalten ihre Daten und Kollisionen; Rendern und Animationen
werden ausgesetzt. Die zentrale Simulation läuft unabhängig davon weiter.
Bestehende Wald-/Landschafts-MultiMeshes und Sichtbarkeitsoptimierungen bleiben.

**NPCs und Transporte:** nahe Animationen je Profil 30/60 Hz, Spar-/Entlastungsmodus
10 Hz, entfernte 4 Hz, unsichtbare bis 2 Hz. Zeit wird gesammelt, nicht verworfen.
Biber, Fahrer, Werkzeuge, Ladung und Maschinen bleiben vorhanden. Vorbereitete
LKWs binden echte Räder und Ladungsvarianten; Fahrtrouten und CargoTransfer bleiben
maßgeblich. Aktive Fahrzeuge überleben Weltaktualisierungen. Der wiederverwendbare
LKW-Pool enthält insgesamt maximal zwölf Modelle und vier je Stil; alte Stufen
werden freigegeben. Geparkte Poolmodelle verarbeiten keine Animationen. Prototype-
Caches für Gebäude und Fahrzeuge sind ebenfalls begrenzt. Straßenrouten werden
weiter mit den vorhandenen vorberechneten Strecken abgetastet.

**Wirtschaft und Speichern:** bestehender Sekundentakt und atomarer Speicherweg
bleiben erhalten. Eine Testfirma produziert bei 5, 25 und 50 Darstellungs-FPS
denselben vollständigen 60-Sekunden-Zustand. Ein zweiter vollständiger Vergleich
prüft 120 Sekunden Simulation bei schlafenden Sichtbereichen. Bestehende
Reservierungen, Lagergrenzen, Bau-/Transportphasen, Drive-Thru und Offline-Replay
werden weiter von denselben Systemen verwaltet. Keine vereinfachte Fernwirtschaft,
keine zweifachen Erlöse und keine neue Spielstandkonvertierung.

**Grafikprofile:** Sparmodus und Standard zielen auf 30 FPS, Hoch/Ultra auf 60.
Hoch aktiviert 2×, Ultra 4× MSAA und höhere Detail-/Auflösungsgrenzen. Menüs bleiben
nativ. Automatische Entlastung nutzt anhaltend gemessene Bildzeiten; manuelle Wahl
und Abschaltung bleiben möglich. Empfehlungen erscheinen erst nach genügend
Messbildern, höheres Profil nur bei passenden gemessenen Renderzeiten empfohlen.
Das sind Zielbudgets, keine FPS-Garantie. Es gibt keinen Temperatursensor.

## 3. Messwerte vorher/nachher

Gleiche erzeugte Firma, Linux/Godot 4.6.3. Vollständige Firmenzustände in jedem
Vergleich identisch. Headless-Zeiten sind CPU-Aufrufzeiten. OpenGL/Vulkan laufen
hier auf llvmpipe/Lavapipe-Softwaregrafik, nicht auf Xclipse oder Windows-Hardware.

| Messung | Vorher | Nachher |
| --- | ---: | ---: |
| CPU-Weltaufbau, direkter Headless-Aufruf | 2.471 ms | 1.736 ms |
| Erste Arbeiterdarstellung, direkter Aufruf | 190,6 ms | 100,3 ms |
| Unveränderter Weltabgleich, zwei Aufrufe | 291,9 / 329,7 ms | 0,263 / 0,161 ms |
| Gerenderte Dreiecke, feste Industrieansicht | 196.114 | 142.312 |
| OpenGL Bildzeit Median, Abschlussdurchlauf | 63,0 ms | 57,6 ms |
| OpenGL Bildzeit P95, Abschlussdurchlauf | 70,0 ms | 67,4 ms |
| OpenGL Zeichenaufrufe, dieselbe Ansicht | 576 | 578 |
| Vulkan Bildzeit Median, Abschlussdurchlauf | 118,3 ms | 102,5 ms |
| Vulkan Bildzeit P95, Abschlussdurchlauf | 131,0 ms | 114,3 ms |
| Vulkan Zeichenaufrufe, dieselbe Ansicht | 572 | 574 |

Die Zeichenaufrufe sind nicht gesunken. Eine frühere Vulkan-Runde ergab sogar
98,4 → 102,6 ms; die Abschlussrunde allein beweist deshalb keinen verlässlichen
Vulkan-FPS-Gewinn. Die OpenGL-Messungen verbessern sich in beiden Durchläufen,
aber auch dort sind die Werte keine Handyprognose. Die hohen Softwarezeiten
liefern keinen 30-FPS-Nachweis. Die Startzeit verbessert sich in beiden Backends.

Renderer-Test: native 1080×2340 Oberfläche, 44,48 % 3D-Skalierung, synthetisch
vorgegebene Entlastungsstufe 3, feste Kamera, eingefrorene Simulation/Darstellung,
12 Aufwärm- und 30 Messbilder je Ansicht. Zusätzlich 3D-aus, HUD-aus und Übersicht.
Root-Viewport-Render-CPU/GPU per echten Engine-Timestamps erfasst.

Im Vulkan-Abschlusstest steigt der Engine-Speicher etwa von 110,9 auf 120,8 MB,
der gemeldete GPU-Speicher von 111,4 auf 112,2 MB. Vorbereitete Ressourcen und
zusätzliche unsichtbare Ladungsvarianten haben Kosten; es wird keine pauschale
Speicherersparnis behauptet. Headless-Speicher nach unmittelbar aufeinanderfolgenden
Neubauten ist wegen noch ausstehender Freigaben nicht als Dauerverbrauch vergleichbar.

[CPU-Ausgang](performance-1/baseline-cpu.json) ·
[CPU-Abschluss](performance-1/cpu-final.json) ·
[Alle Skripte](performance-1/scripts-after.json) ·
[OpenGL Abschluss](performance-1/render-opengl-final.json) ·
[Vulkan Abschluss](performance-1/render-vulkan-final.json) ·
[Frühere Vulkan-Runde](performance-1/render-vulkan.json).

## 4. Qualitätssicherung

21.657 Headless-Prüfungen in 51 berichteten Modulen, vollständiger Lauf und danach
gezielte finale Lade-/Eingabe-/Wirtschaftsprüfungen. 485 OpenGL-Prüfungen in 14
Modulen und 125 Vulkan-Prüfungen in sechs Modulen bestanden. Enthalten:
Produktion, Fracht, Reservierungen, Bau/Upgrades, alle vorhandenen Modellfamilien,
Biber, tatsächliche vier Grafikprofile, Fotoqualität, alte Speicherstände,
Hauptwelt, Wetterabschaltung und tatsächlicher Kaltstart mit acht Offline-Stunden.

Ein beim ersten Ressourcenversuch entdecktes Problem verschachtelter Szenen wurde
behoben: gespeicherte Fahrzeug-/Gebäudeinstanzen werden vor dem Packen sauber
aufgelöst, Node-Pfade der Räder/Ladung erhalten stabile Namen. Wiederholte
Instanziierung und Freigabe hinterlassen in den geprüften Szenarien keine
verwaisten Nodes. Der Kaltstart-Smoke-Test wartet auf die fertige Welt, statt den
Prozess mitten im asynchronen Laden nach einer festen Framezahl abzubrechen.

Die Galerie behält Architektur und Farben: mittlerer RGB-Unterschied unter
0,8/255 je Kanal, geringe Kanten-/LOD-Abweichungen, echte Bilder visuell geprüft.
[Galerie vorher](performance-1/gallery-before.png) · [Galerie nachher](performance-1/gallery-after.png).
[Maschinenlesbares Prüfprotokoll](performance-1/source-checks.json).
Tests verwenden erzeugte Firmen und isolierte Profile, niemals private Spielstände.
Paketprüfung der APK-Dateien wird separat dokumentiert.

## 5. Geänderte Dateien

- `Buildings/Models.gd`, `Components/SceneryBlueprint.gd`, `Assets/Baked/*`,
  `scripts/bake_runtime.{py,gd}`, `scripts/MeshLodBake.gd`: vorbereitete Original-
  ressourcen, Manifestprüfung und LOD-Erzeugung.
- `Components/World.gd`, `WorldVisualCache.gd`, `WorldChunks.gd`,
  `WorldPreloader.gd`, `ValleyLandscape.gd`, `TradeWorld.gd`: Wiederverwendung,
  Sichtbereiche, Laden und unveränderte Grenzen.
- `DeliveryWorld.gd`, `CrewWorld.gd`, `VehicleBlueprints.gd`,
  `Vehicles/{Truck,DumpTruck,CrewVan}.gd`, `YardHandling.gd`, `ProductionMachine.gd`:
  vorbereitete Szenen, korrekte Konfiguration/Referenzen und begrenzte Pools.
- `NPCs/{Worker,ConstructionWorker}.gd`, `characters/beavers/{BeaverModels,BeaverRig}.gd`,
  `PresentationBudget.gd`: Biber-Reuse und entfernungsabhängige Darstellung.
- `Managers/{Game,RuntimeStats}.gd`, `GraphicsProfiles.gd`,
  `UI/{Startup,HUD,OperationsDesk}.gd`: Lastprofile, Startphasen und reale Diagnose.
- Neue Profil-/Prüfskripte `Tests/*2826.gd`, angepasste Start-/Profiltests,
  `scripts/{test.sh,test_visual.sh,benchmark_rendering.py,build_android.py}`,
  Versionsdateien, README und Prüfberichte. Vollständige erzeugte Dateiliste im
  [Ressourcenmanifest](../Assets/Baked/manifest.json).

## 6. Einschränkungen und nächste notwendige Schritte

- Kein physisches Samsung- oder Windows-Gerät verfügbar. 30 stabile FPS,
  optionale 60 FPS, Dauerlast/Wärme und 5–10 Sekunden Handy-Weltaufbau bleiben
  zu messen. Renderer-spezifische Ergebnisse dürfen nicht verallgemeinert werden.
- Acht Offline-Stunden der großen Testfirma benötigen im echten Kaltstart hier
  rund 30,6 Sekunden, die kleinere Firma rund 24,3 Sekunden einschließlich Start.
  Die Oberfläche bleibt dabei bedienbar. Der vorhandene Replay-Worker bleibt
  korrekt; weitere ereignisbasierte Beschleunigung braucht separate Nachweise.
- Virtuelle Sichtbereiche entfernen keine Simulationsdaten und entladen nicht
  sämtliche Meshes aus dem Speicher. Für deutlich größere Welten wären echtes
  Asset-Streaming und zusätzliche Speicherbudgets gesondert zu entwickeln.
- Erste unvorbereitete direkte Transport-/Pflanzaufrufe bleiben im CPU-Profil
  mit etwa 18–23 ms sichtbar. Der tatsächliche Start lädt benötigte Prototypen vor;
  bislang nie benutzte Varianten, neue Baustellen und sehr große Straßenänderungen
  können weiterhin Aufwand auslösen. Keine behauptete Beseitigung aller Hänger.
- Zusätzliche Draw-Call-/Schatten-/Treiberoptimierung nach echten Xclipse-Render-
  CPU/GPU-Werten. Der installierte Leistungsvergleich bietet den 10-Sekunden-Test.
- Android-Testdateien werden zusätzlich als ARM64-APKs gebaut, passend zum
  SM-S721B. Der universelle ARM64/ARMv7-Export bleibt im Preset verfügbar.
  Windows nutzt dieselben optimierten Systeme, wurde aber nicht nativ gestartet.
- Keine Store-Reife und kein Release-Schlüssel. Bestehendes Testpaket/Zertifikat,
  Speicherpfad und Schema bleiben erhalten; Aktualisierung ohne Deinstallation.
