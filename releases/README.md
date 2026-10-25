# Aktuell: Laufzeit und Messdetails · 0.28.22-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.22-alpha.1/releases/Timber-Loot-Tycoon-v0.28.22-alpha.1.apk)** · [Passender Quellcode](Timber-Loot-Tycoon-v0.28.22-source.zip) ·
[Messungen und Grenzen](../docs/PERFORMANCE-2822.md)

Vorbereitete Fahrzeugwege, weniger unveränderte Wald-Updates und feste
Zustandsprüfungen für Betriebshinweise. Die Kamerarunde nennt zusätzlich die
Version, Zeichenaufrufe und CPU-Zeiten. Keine Änderung an Waren, Lagergrenzen,
Personal, Wachstum oder Spielgeschwindigkeit.

Android-Code **3017**; bisheriges Paket und Testzertifikat.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0, Debug-Testfassung.
Quellprüfungen: 21.552 Headless / 398 OpenGL. Tatsächliche APK-Dateien:
10,959 Headless / 274 OpenGL.
Kein echter Android-Geräte-/Wärmetest. Die gemeldeten 6,2 Handy-FPS und
14,3 Sekunden Weltaufbau sind noch nicht als behoben nachgewiesen.
Bitte die 30-Sekunden-Runde vollständig beenden und Ergebnis plus Messdetails senden.
Quellstand `e6a71e237c2440ae9213e309b0cbef7b0137a867`; 894 Dateien der Quell-ZIP gegen Git geprüft.

## Vorher: Kamera und Darstellung · 0.28.21-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.21-alpha.1/releases/Timber-Loot-Tycoon-v0.28.21-alpha.1.apk)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.21-source.zip) · [Änderungen und Messgrenzen](../docs/PERFORMANCE-2821.md)

Vorbereitete Landschaftstransformationen und weniger Änderungen der sichtbaren
Instanzplätze bei Kamerabewegung. Passende statische Lackflächen teilen sich
Zeichenaufrufe. Keine ausgedünnten Wälder und keine Änderungen an Wirtschaft,
Waren, Lagergrenzen, Personal oder Spielgeschwindigkeit.

Quellvergleich: etwa 93 % weniger CPU-Zeit für Kameraaktualisierungen beim
Abschnittswechsel; etwa ein Drittel weniger Zeichenaufrufe in der Fabrikansicht.
Zusätzlicher [Vergleich der tatsächlichen APKs](../docs/alpha1-performance/apk-frames-benchmark.json).
Identischer kompletter Firmenzustand, praktisch gleiche gerenderte Farben.
Desktop/Software-Renderer, keine zugesicherten Handy-FPS. Weltkonstruktion kann
durch einmaliges Zusammenfassen etwas länger dauern; kein Ladezeit-Update.

Android-Code **3016**, bisheriges Paket und Testzertifikat.
**Als Update installieren; nicht vorher deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0, Debug-Testfassung.
21.532 Headless- und 367 relevante OpenGL-Quellprüfungen bestanden;
zusätzlich 10.939 Headless- und 243 OpenGL-Prüfungen mit unveränderten APK-Dateien.
Kein physischer Android-Geräte-/Wärmetest; frühere vollständige Masterliste offen.
APK-Quellstand `fd13f75a2bf3a32c888de01e3d9558b324c97991`. Quell-ZIP: 880 Dateien gegen Git geprüft.

## Vorher: Lagergrenzen · 0.28.20-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.20-alpha.1/releases/Timber-Loot-Tycoon-v0.28.20-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.20-alpha.1/releases/Timber-Loot-Tycoon-v0.28.20-Lager-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.20-source.zip) · [Lagerregeln und Prüfungen](../docs/STORAGE-2820.md)

Feste ausbaufähige Fächer je Warenart: Start 1.000, mit erstem Zentrallager 2.500.
Abhol-Express 96 bis 312, ausgebaute Werkspuffer bis 384 je Ware. Keine neuen
Gratisbestände. Gebuchte LKW-Ladungen sind auch vor Käufen und Ablieferung
reserviert; mehrere zentrale Höfe teilen dieselbe begrenzte Zentrale. Volle
Ausgänge stoppen den Rohstoffverbrauch. Nach Entnahme/Verkauf geht der Warenfluss
automatisch weiter. Alte Überbestände bleiben erhalten, nehmen keine neuen
Gutschriften an und können verbraucht werden.

Hauptanzeige: genauer gesamter Vorrat; darunter L = Zentrale / Kapazität.
! meldet das volle/gebuchte Zentralfach, ↻ die wartende Holzabholung.
Warendetail und Logistik erklären Plätze und verknüpfen den Lagerausbau.

Android-Code **3015**, gleiches Paket und Testzertifikat.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0, Debug-Testfassung.
21510 Headless- und 487 relevante OpenGL-Quellprüfungen;
zusätzlich 11647 Headless- und 167 OpenGL-Prüfungen mit
unveränderten Dateien aus der tatsächlichen APK. Kein echter Android-Gerätetest.
APK-Quellstand `0ed25d73bb897735021d8c575ba314a5cc87e2ba`. Quell-ZIP: 858 Dateien gegen Git geprüft.
Die frühere vollständige Masterliste bleibt offen.

## Vorher: Nachwuchs im aktiven Wald · 0.28.19-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.19-alpha.1/releases/Timber-Loot-Tycoon-v0.28.19-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.19-alpha.1/releases/Timber-Loot-Tycoon-v0.28.19-Nachwuchs-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.19-source.zip) · [Ursache, Simulation und Bilder](../docs/ACTIVE-FOREST-2819.md)

Pflanzer umgehen versperrte Zugänge und Maschinenflächen über freie Seitenwege.
Neue Missionen speichern ihren echten Weg; Darstellung und Bauplatzreservierung
benutzen ihn ebenfalls. Forstforschung beschleunigt auch Pflanzen und Wachstum,
Turbo neue Pflanzreisen und Arbeit. Die Automatik kann bei stark abgeerntetem
Wald mehr der vorhandenen Helfer zum Pflanzen einsetzen. Starterversorgung und
manuelle Zuweisungen bleiben erhalten. Belegte/geschlossene Flächen bleiben gesperrt.
Alte Missionen und Jungbäume behalten ihre bisherigen Zeiten. Keine Gratiswaren.

Acht echte 900-Sekunden-Simulationen mit 8/31 Helfern, Forschung 0/10/12 und Turbo
behalten nach der Einlaufphase mindestens zehn erntereife aktive Bäume. Auch bei
vollem Abholvorrat wachsen alle 93 physisch freien Eichenwaldstellen wieder nach.
Generierte Versuche, keine Garantie für jeden Spielstand und kein echter Handytest.

Android-Code **3014**, gleiches Paket und Testzertifikat; 0.28-Basis.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Debug-signierte Testfassung.
Kein echter Android-Gerätelauf und keine Temperaturmessung.

21431 Headless- und 276 relevante OpenGL-Prüfungen des Quellstands;
zusätzlich 6890 Headless- und 276 OpenGL-Prüfungen mit
unveränderten Spieldateien aus der wirklichen APK.
[Prüfbericht](../docs/alpha1-active-forest/automated-checks.json).
APK-Quellstand `22cb737b237e5dcb046d052581be0a45b2b7d4bd`. Quell-ZIP: 843 Dateien gegen Git geprüft.

## Vorher: Starterfeld und Waldwechsel · 0.28.18-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.18-alpha.1/releases/Timber-Loot-Tycoon-v0.28.18-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.18-alpha.1/releases/Timber-Loot-Tycoon-v0.28.18-Starter-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.18-source.zip) · [Ursache, Messung und Bilder](../docs/STARTER-2818.md)

Freie Pflanzmissionen wechseln zwischen allen bereits abgeernteten Wäldern.
Das alte Starterfeld bekommt auch bei laufender Ernte im Eichenwald seine
Pflanzaufträge. Ein gespeicherter Verteilerzeiger funktioniert auch mit einem
Pflanzer und nach Neustarts. Bestehende Missionen behalten Wege und Zeiten.
Teamübersicht mit allen betroffenen Wäldern und direkter Starter-Kameraaktion.
Keine Gratiswaren und keine zusätzlichen Arbeiter; manuelle Zuweisungen bleiben.

Weiterhin 45 Sekunden Wachstum nach echtem Pflanzen. Bereits laufende Altmissionen
kehren zuerst zurück. Bewusst auf null gesetztes Pflanzteam muss unter Team
wieder zugewiesen werden. Gestaltung, Logistik, Inventare und Spielstände bleiben.

Android-Code **3013**, gleiches Paket und Testzertifikat; 0.28-Basis.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Debug-signierte Testfassung.
Kein echter Android-Gerätelauf und keine Temperaturmessung.

21299 Headless- und 259 relevante OpenGL-Prüfungen des Quellstands;
zusätzlich 6758 Headless- und 259 OpenGL-Prüfungen mit
unveränderten Spieldateien aus der wirklichen APK.
[Prüfbericht](../docs/alpha1-starter/automated-checks.json).
APK-Quellstand `bd95f341ccb4acfc839c8eea27ac31bcea13c068`. Quell-ZIP: 829 Dateien gegen Git geprüft.

## Vorher: Wiederaufforstung · 0.28.17-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.17-alpha.1/releases/Timber-Loot-Tycoon-v0.28.17-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.17-alpha.1/releases/Timber-Loot-Tycoon-v0.28.17-Wald-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.17-source.zip) · [Änderungen und Waldmessung](../docs/REGROWTH-2817.md)

Jungbäume werden 45 statt 90 Sekunden nach tatsächlichem Pflanzen erntereif.
Bei kahlem Wald teilt die Automatik mehr der vorhandenen Helfer zum Aufforsten ein.
Neue Pflanzmissionen laufen zügiger, alte Jungbäume behalten bereits gewachsene Zeit.
Pflanzer bleiben auch ohne verbliebene Holzfällerfiguren sichtbar. Team und Welt
zeigen Nachwuchs und den nächsten Erntezeitpunkt. Ernte und Pflanzen verwenden
dieselben erreichbaren Waldgänge. Keine Gratiswaren und keine zusätzlichen Arbeiter.

Unter Team → Baumpflanzer bei bewusst deaktiviertem Pflanzen „Automatisch“ wählen.
Manuelle Zuweisungen werden erhalten. Blockierte Pflanzzufahrten müssen frei bleiben.
Vorhandene Gestaltung, Waren, Transportausbauten und Spielstände bleiben bestehen.

Android-Code **3012**, gleiches Paket und Testzertifikat; 0.28-Basis.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Debug-signierte Testfassung.
Kein echter Android-Gerätelauf und keine Temperaturmessung.

21272 Headless- und 327 relevante OpenGL-Prüfungen des Quellstands;
zusätzlich 6731 Headless- und 327 OpenGL-Prüfungen mit
unveränderten Spieldateien aus der wirklichen APK.
[Prüfbericht](../docs/alpha1-regrowth/automated-checks.json).
APK-Quellstand `259b3c114f4e112e011757d98eb39cc04b22e35f`. Quell-ZIP: 815 Dateien gegen Git geprüft.

## Vorher: Einheitlicher Weltstil · 0.28.16-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.16-alpha.1/releases/Timber-Loot-Tycoon-v0.28.16-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.16-alpha.1/releases/Timber-Loot-Tycoon-v0.28.16-Design-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.16-source.zip) · [Designbuch und Hauptweltbilder](../docs/DESIGN-2816.md)

Die vorhandene Hauptwelt erhält gemeinsame Farben und Materialien. Neue offene
Holzrahmenhallen und Berufsschilder ergänzen die Werke, blaue/goldene Ladefassaden
die beiden Lagerarten. Zehn Rathauszustände sind neu aufgebaut. Fahrzeuge haben
abgeschrägte Karosserien, Biber abgestimmte Berufsfarben, Menüs ruhigere Oberflächen.
Dachfarben bleiben nach erneutem Batching erhalten. Das eigene Vollbild-Bibercover
bleibt der Spielstart. Wirtschaft, Inventare, Transportausbauten und Spielstände
werden nicht zurückgesetzt. Andere Stadtbaukörper behalten ihre Architektur;
die vollständige frühere Masterliste bleibt offen.

Android-Code **3011**, gleiches Paket und Testzertifikat; 0.28-Basis.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Debug-signierte Testfassung.
Kein echter Android-Gerätelauf und keine Temperaturmessung.

21251 Headless- und 1181 OpenGL-Prüfungen des Quellstands;
zusätzlich 6710 Headless- und 625 OpenGL-Prüfungen mit
unveränderten Spieldateien aus der wirklichen APK.
[Prüfbericht](../docs/alpha1-style/automated-checks.json).
APK-Quellstand `14fdfd5931c1d53d1ff74315b81d36b9e2aaf15e`. Quell-ZIP: 801 Dateien gegen Git geprüft.

## Vorher: Mehr Durchsatz für Lager und Werke · 0.28.15-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.15-alpha.1/releases/Timber-Loot-Tycoon-v0.28.15-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.15-alpha.1/releases/Timber-Loot-Tycoon-v0.28.15-Transport-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.15-source.zip) · [Änderungen und Messung](../docs/THROUGHPUT-2815.md)

Fünf statt drei Lager-LKW ab fertiggestellter Zentrale Stufe 1. Größere
Werkspuffer, größere echte Ladungen und verbesserter Umschlag. Zusätzliche
Lager-LKW unter Logistik/Garage kaufen; Transportausbau direkt im Werk.
Maximal 16 Lager-LKW aktiv. Angeforderte Fracht wird bei Ankunftsplanung und
Zielraum berücksichtigt. Vorhandener Werkvorrat wird auch bei belegter Flotte
weiterverarbeitet. Kein Gratisauffüllen oder vorzeitige Warengutschrift.

Generierte Vergleichsfirma, 1.200 simulierte Sekunden ohne manuelle Hilfe:
647,33 statt 36 Bretter und 74 statt 22 tatsächlich verkaufte Möbel. Das
Sägewerk arbeitet 1.020 statt 90 Sekunden. Keine Garantie für jeden Spielstand.

Android-Code **3010**, gleiches Paket und Testzertifikat; 0.28-Basis.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Debug-signierte Testfassung.
Kein echter Android-Gerätelauf und keine Temperaturmessung.

21064 Headless- und 318 relevante OpenGL-Prüfungen des Quellstands;
zusätzlich 6523 Headless- und 318 OpenGL-Prüfungen mit
unveränderten Spieldateien aus der wirklichen APK.
[Prüfbericht](../docs/alpha1-throughput/automated-checks.json).
APK-Quellstand `a584051a9fa01e8a8c27c15e1a81ee87b4ad20f5`. Quell-ZIP: 777 Dateien gegen Git geprüft.

## Vorher: Bibercover und direkter Spielstart · 0.28.14-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.14-alpha.1/releases/Timber-Loot-Tycoon-v0.28.14-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.14-alpha.1/releases/Timber-Loot-Tycoon-v0.28.14-Spielstart-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.14-source.zip) · [Änderungen](../docs/STARTUP-2814.md) ·
[Neue Gestaltungsrichtung und Gebäudeentwürfe](../docs/DESIGN-DIRECTION-2814.md)

Eigenes bildschirmfüllendes Bibercover, scharfer Schriftzug und Ladeanzeige unten.
Nach dem tatsächlichen Laden und der Offline-Nachrechnung öffnet sich die Welt
automatisch. Der Titel hat keinen separaten 3D-Schaukasten und keine Introfrist.
Menürückkehr und Speicherwiederherstellung bleiben bedienbar.
Die Gebäudetafel ist eine Modelliergrundlage, noch kein Ersatz der 3D-Gebäude.
Produktionsautomatik und vollständiger Masterumbau sind damit nicht neu umgesetzt.

Android-Code **3009**, gleiches Paket und Testzertifikat; 0.28-Basis.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Debug-signierte Testfassung.
Kein echter Android-Gerätelauf und keine Temperaturmessung.

21032 Headless- und 170 relevante OpenGL-Prüfungen des Quellstands;
zusätzlich 6420 Headless- und 170 OpenGL-Prüfungen mit
unveränderten Spieldateien aus der wirklichen APK.
[Prüfbericht](../docs/alpha1-loading/automated-checks.json).
APK-Quellstand `d0154d1d9ca993c5e2fb98f354809ed3a8c07ed6`. Quell-ZIP: 759 Dateien gegen Git geprüft.

## Vorher: Waldzugang und Holzfäller · 0.28.13-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.13-alpha.1/releases/Timber-Loot-Tycoon-v0.28.13-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.13-alpha.1/releases/Timber-Loot-Tycoon-v0.28.13-Waldzugang-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.13-source.zip) · [Änderungen und Grenzen](../docs/FOREST-ACCESS-2813.md)

Die vordere Waldabsperrung ist entfernt. Holzfäller arbeiten vor erreichbaren
Bäumen innerhalb des Waldes und tragen über geprüfte Gassen zum Sammelplatz.
Abgeerntete Arbeitsplätze werden per Fußweg gewechselt. Ein kleiner Hinweis
zeigt ausstehende Holzabholung oder volle Holzlager. Der tatsächliche Ertrag und
die vorhandenen Lager-/Transportbestände bleiben maßgeblich.

Android-Code **3008**, gleiches Paket und Testzertifikat; 0.28-Basis.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Debug-signierte Testfassung.
Kein echter Android-Gerätelauf und keine Temperaturmessung.

21033 Headless- und 1163 OpenGL-Prüfungen des Quellstands;
zusätzlich 8008 Headless- und 607 OpenGL-Prüfungen mit
unveränderten Spieldateien aus der wirklichen APK.
[Prüfbericht](../docs/alpha1-forest-access/automated-checks.json).

APK-Quellstand `dae1617c20cfe230316edc037ce9a04562452970`. Quell-ZIP: 738 Dateien gegen Git geprüft;
Testerpaket: 7 geprüfte Einträge. Signaturschlüssel außerhalb von Git.

## Vorher: Holzwerkshof und Wiederaufforstung · 0.28.12-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.12-alpha.1/releases/Timber-Loot-Tycoon-v0.28.12-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.12-alpha.1/releases/Timber-Loot-Tycoon-v0.28.12-Werkshof-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.12-source.zip) · [Änderungen und Grenzen](../docs/CAMPUS-2812.md)

Ein verbundener Holzwerkshof, zehn baulich unterschiedliche Sägewerkformen,
Entrinden → Sägen → Hobeln, bis zu drei tatsächlich eingerichtete Linien und
Biber-Baumpflanzer mit echten Wegen und gespeicherten Jungbäumen sind in der
Hauptwelt integriert. Neue Werkshöfe und zusätzliche Linien verwenden bezahlte
Baustellen mit realen Materiallieferungen und angekommenen Bauteams. Die bestehende
Stadt und ihre Lager-/Express-Logistik bleiben erhalten.

Android-Code **3007**, gleiches Paket und Testzertifikat; 0.28-Basis.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Debug-signierte Testfassung.
Kein echter Android-Gerätelauf und keine Temperaturmessung.

21015 Headless- und 1126 OpenGL-Prüfungen des Quellstands;
zusätzlich 7990 Headless- und 570 OpenGL-Prüfungen mit
unveränderten Spieldateien aus der wirklichen APK.
[Prüfbericht](../docs/alpha1-werkshof/automated-checks.json).

APK-Quellstand `b40d306008d855a97289d92462a71180a0dc4582`. Quell-ZIP: 725 Dateien gegen Git geprüft;
Testerpaket: 7 geprüfte Einträge. Signaturschlüssel außerhalb von Git.

## Vorher: Leistung und Holzproduktionsstraße · 0.28.11-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.11-alpha.1/releases/Timber-Loot-Tycoon-v0.28.11-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.11-alpha.1/releases/Timber-Loot-Tycoon-Alpha-1-Holzlinie-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.11-source.zip) · [Änderungen und Grenzen](../docs/TIMBERLINE-2811.md)

Unsichtbare Maschinen und Stapler sparen Detailarbeit. Adaptive Darstellung und
Akkumodus reduzieren nur die Weltauflösung; Menü und Schrift bleiben scharf.
Start-, Offline- und FPS-Messungen sind im Spiel sichtbar. Hofmarkierungen,
Sägeabdeckung und Produktionsleuchten machen die vorhandene Holzlinie lesbarer.
Die Holzkette zeigt echte Betriebe; Gebäudevorschauen markieren den LKW-Anschluss.
Die Logistik und die Wirtschaft aus 0.28.10 bleiben erhalten.

Android-Code **3006**, gleiches Paket und Testzertifikat; 0.28-Basis.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Debug-signierte Testfassung.
Kein echter Android-Gerätelauf und keine Temperaturmessung.

20976 Headless- und 1090 OpenGL-Prüfungen des Quellstands;
zusätzlich 1491 Headless- und 418 OpenGL-Prüfungen mit
unveränderten Spieldateien aus der wirklichen APK.
[Prüfbericht](../docs/alpha1-timberline/automated-checks.json).

APK-Quellstand `3f45d0c616e1225724144021a002e128edaaefb0`. Quell-ZIP: 684 Dateien gegen Git geprüft;
Testerpaket: 7 geprüfte Einträge. Signaturschlüssel außerhalb von Git.

## Vorher: Automatische Werkslogistik und Bauteams · 0.28.10-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.10-alpha.1/releases/Timber-Loot-Tycoon-v0.28.10-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.10-alpha.1/releases/Timber-Loot-Tycoon-Alpha-1-Logistik-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.10-source.zip) · [Änderungen und Grenzen](../docs/LOGISTICS-2810.md)

Alle vorhandenen Produktionsarten werden automatisch zum geeigneten Zentrallager
oder Abhol-Express abgeholt. Eigene Werkseingänge erhalten echten Nachschub;
regionale Überschüsse kommen zur Zentrale zurück. Gemeinsame, begrenzte Flotten
verteilen Fahrten fair und bringen Material bis auf die Baustelle.

Bauteams reisen im Sprinter aus der Arbeiterhütte an. Erst angekommene Biber
arbeiten mit geliefertem Material, Werkzeug und Leitern. Neue Logistikansichten,
Menüsuche, Kategorien und Zurück-Navigation zeigen Bestände und Wartegründe.
Voraussetzung für das neue Netz ist ein fertiggestelltes Zentrallager.

Android-Code **3005**, gleiches Paket und Testzertifikat; 0.28-Basis.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Debug-signierte Testfassung.
Kein echter Android-Gerätelauf und keine Temperaturmessung.

20957 Headless- und 1064 OpenGL-Prüfungen des Quellstands;
zusätzlich 1472 Headless- und 392 OpenGL-Prüfungen mit
unveränderten Spieldateien aus der wirklichen APK.
[Prüfbericht](../docs/alpha1-logistics/automated-checks.json).

APK-Quellstand `2ce5ccaaccdd9c7e6a326d737af3c9baf2bda9b3`. Quell-ZIP: 656 Dateien gegen Git geprüft;
Testerpaket: 7 geprüfte Einträge. Signaturschlüssel außerhalb von Git.

## Vorher: Holzfäller und automatische Ernte · 0.28.9-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.9-alpha.1/releases/Timber-Loot-Tycoon-v0.28.9-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.9-alpha.1/releases/Timber-Loot-Tycoon-Alpha-1-Waldarbeit-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.9-source.zip) · [Änderungen und Grenzen](../docs/WORKERS-289.md)

Ein manuell gefüllter Holzbestand ist kein Nachweis für automatische Ernte.
Team zeigt deshalb einen eigenen automatischen Holzzähler und den Stationsstatus.
Volle Sammelplätze erhalten auch mit Holz im Zentrallager eine reale Abholung;
größere Bündelladungen nutzen die bestehende begrenzte Flotte. Biber bleiben neben
gekauften Forstmaschinen sichtbar. Team → Holzfäller ansehen führt zur Arbeitskante.

Generierter Kontrollfall mit 31 Helfern und Werkzeugstufe 11, jeweils 30 Minuten
ohne manuelle Aktionen: **72 → 1.544 automatisch gewonnene Holz**, längste Pause
**586 → 125 Sekunden**. Kein Test des privaten Spielstands und keine zugesicherte
allgemeine Produktionsrate. Die Startoptimierung aus 0.28.8 bleibt enthalten;
keine neue Zusicherung zu Handy-Startzeit und Wärme. Masterumbau weiter offen.

Android-Code **3004**, gleiches Paket und Testzertifikat; 0.28-Basis.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Debug-signierte Testfassung.
Kein echter Android-Gerätelauf und keine Temperaturmessung.

20889 Headless- und 1024 OpenGL-Prüfungen des Quellstands;
zusätzlich 1348 Headless- und 304 OpenGL-Prüfungen mit
unveränderten Spieldateien aus der wirklichen APK.
[Prüfbericht](../docs/alpha1-workers/automated-checks.json).

APK-Quellstand `ce0f6106816c1a3b4431fc0f120590c06d9db3fb`. Quell-ZIP: 622 Dateien gegen Git geprüft;
Testerpaket: 7 geprüfte Einträge. Signaturschlüssel außerhalb von Git.

## Vorher: Waldabholung und Startzeit · 0.28.8-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.8-alpha.1/releases/Timber-Loot-Tycoon-v0.28.8-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.8-alpha.1/releases/Timber-Loot-Tycoon-Alpha-1-Waldstart-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.8-source.zip) · [Änderungen und Grenzen](../docs/RECOVERY-288.md)

Volle Sammelstation bei leerem zentralem Holzlager: Die automatische Werksversorgung
lässt einen realen Truck für den dringenden Holztransport frei. Faire Abholrunden
und numerisch stabile Quellen erhalten die Disposition beim Speichern. Express-
Zufuhren berücksichtigen ihre echte gebuchte Kapazität. Die Holzkarte zeigt Abholung.
Start, Einstellungen und Feedback zeigen die tatsächliche installierte Version
statt der fest eingetragenen 0.28.3.

Offline-Optimierung auf dem Desktop für acht Stunden: **17,2 → 12,1 s** und
**24,3 → 14,3 s**, im isolierten Optimierungsvergleich vollständig identischer
Firmenstand. Neue Dispositionsentscheidungen sind separat geprüft.
Keine zugesicherte Handy-Ladezeit. Der gesamte Masterumbau bleibt offen.

Android-Code **3003**, gleiches Paket und Testzertifikat; 0.28-Basis.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Debug-signierte Testfassung.
Kein echter Android-Gerätelauf und keine Temperaturmessung.

20872 Headless- und 999 OpenGL-Prüfungen des Quellstands;
zusätzlich 1322 Headless- und 279 OpenGL-Prüfungen mit
unveränderten Spieldateien aus der wirklichen APK.
[Prüfbericht](../docs/alpha1-recovery/automated-checks.json).

APK-Quellstand `eaeea297ba3eb102c4dd82478abb50230db4d337`. Quell-ZIP: 606 Dateien gegen Git geprüft;
Testerpaket: 7 geprüfte Einträge. Signaturschlüssel außerhalb von Git.

## Vorher: Holzfäller und Abholung · 0.28.7-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.7-alpha.1/releases/Timber-Loot-Tycoon-v0.28.7-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.7-alpha.1/releases/Timber-Loot-Tycoon-Alpha-1-Holzfaeller-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.7-source.zip) · [Ursachen und Grenzen](../docs/FORESTRY-287.md)

Volle Lager hielten sämtliche Abhol-LKW beim Entladen fest. Eine begrenzte
Warenannahme erhält die Ladungen und lässt die Flotte regulär zurückkehren.
Werke werden wieder beliefert und die tatsächliche Holzernte läuft wieder an.
Alle aktiven Sammelstationen mit Platz werden genutzt; Reservierungen verhindern
neue Überbuchungen. Vorhandene Überbestände werden nicht still gekürzt.

Biber und Forstmaschinen stellen angenommene Ernte dar, beenden begonnene Zyklen
und fällen Bäume nahe ihrem Arbeitsbereich. Kleinere Maschinenplätze lassen Bäume
in Arbeitsnähe stehen. Der Stationsstatus nennt volle Lager, fehlende Arbeiter,
Pausen, fehlende Straßen und die aktuelle Abholung.

Android-Code **3002**, gleiches Paket und Testzertifikat; weiterhin 0.28-Basis.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Debug-signierte Testfassung.
Der vollständige Masterumbau bleibt offen. Handy-/Hitzetests stehen aus.

20847 Headless- und 975 OpenGL-Prüfungen des Quellstands;
zusätzlich 1262 Headless- und 506 OpenGL-Prüfungen mit
unveränderten Spieldateien aus der wirklichen APK.
[Prüfbericht](../docs/alpha1-logging/automated-checks.json).

APK-Quellstand `88c0bc0bae3b548eaf878327df9f5817e9218ed3`. Quell-ZIP: 588 Dateien gegen Git geprüft;
Testerpaket: 7 geprüfte Einträge. Signaturschlüssel außerhalb von Git.

## Vorher: Versorgung und Biberwelt · 0.28.6-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.6-alpha.1/releases/Timber-Loot-Tycoon-v0.28.6-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.6-alpha.1/releases/Timber-Loot-Tycoon-Alpha-1-Versorgung-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.6-source.zip) · [Änderungen und Reststand](../docs/WORLD-REWORK-286.md)

Baurechnungen blockieren nicht mehr die Herstellung fehlender Baumaterialien.
**Ware anfordern** im Werk startet tatsächliche Lager-LKW mit lokalem
Eingangspuffer und automatischem Nachschub. Eigene Lagerflotte für Abholung
und Fabrikversorgung, faire Warenzuteilung,
unabhängige Betriebspausen, automatische Bauteam-Übergabe und genaue Lieferstatus.
Die Materialleiste trennt Gesamtbestand und Lageranteil. Zehn Architektur-
Erweiterungen jetzt auch für Zentrale, Express, Steinbruch und Steinwerk.
**Der gesamte Masterumbau bleibt offen.**

Android-Code **3001**, gleiches Paket und Testzertifikat, weiterhin 0.28-Basis.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Debug-signierte Testfassung.

20824 Headless- und 958 OpenGL-Prüfungen
mit dem Quellstand. Zusätzlich 1239 Headless- und
489 OpenGL-Prüfungen unveränderter Ressourcen aus der
wirklichen APK. Kein echter Android-Lauf und keine Temperaturmessung.
[Prüfbericht](../docs/alpha1-supply/automated-checks.json).

APK-Quellstand `59accccbcd80f09b0887115d53b281f403269f53`. Quell-ZIP: 574 Dateien gegen Git geprüft;
Testerpaket: 7 geprüfte Einträge. Paketdaten und Hashes stehen in
der APK-JSON und `SHA256SUMS.txt`. Der Signaturschlüssel bleibt außerhalb von Git.

## Vorher: Biberwelt · 0.28.5-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.5-alpha.1/releases/Timber-Loot-Tycoon-v0.28.5-alpha.1.apk)** · **[Testerpaket](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.5-alpha.1/releases/Timber-Loot-Tycoon-Alpha-1-Biberwelt-Testerpaket.zip)** ·
[Passender Quellcode](Timber-Loot-Tycoon-v0.28.5-source.zip) · [Genauer Entwicklungsstand](../docs/WORLD-REWORK-285.md)

Erster integrierter Meilenstein des großen Weltumbaus: getrennte Straßen und
Grundstücke, zehn Biberformen und drei Berufsausstattungen, sichtbare Biberfahrer,
zehn Architekturmodule für 14 bestehende Betriebsarten, Staplerphasen anhand
wirklicher Lieferungen. **Der Gesamtumbau ist noch nicht fertig.** Zusätzliche
Industriezweige, sämtliche neuen Gebäudefamilien und Berufsabläufe stehen aus.

Android-Code **2991**, gleiches Paket und Testzertifikat. **Als Update installieren;
nicht deinstallieren und keine App-Daten löschen.** Android 7.0+, ARM64/ARMv7,
OpenGL ES 3.0. Debug-signierte Testfassung.

20722 Headless- und 934 OpenGL-Prüfungen
bestanden. Zusätzlich 1014 Headless- und
465 OpenGL-Prüfungen mit unveränderten Ressourcen aus der
wirklichen APK. Keine echte Android-Ausführung und keine Temperaturmessung.
[Prüfbericht](../docs/alpha1-beavers/automated-checks.json).

APK-Quellstand `845adf4cfd7f8e93f13c878e4a164c443d373633`. Quell-ZIP: 550 Dateien gegen Git geprüft.
Testerpaket: 7 Einträge. Paketdaten und SHA256 stehen in der APK-JSON
und `SHA256SUMS.txt`. Der Signaturschlüssel bleibt außerhalb des Repositorys.
Der Download ist öffentlich.

## Vorher: Zentrallogistik · 0.28.4-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.4-alpha.1/releases/Timber-Loot-Tycoon-v0.28.4-alpha.1.apk)** · **[Testerpaket mit Anleitung](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.4-alpha.1/releases/Timber-Loot-Tycoon-Alpha-1-Zentrallogistik-Testerpaket.zip)**

[Passender Quellcode](Timber-Loot-Tycoon-v0.28.4-source.zip) · [Änderungen](../docs/FACTORY-284.md) · [Testplan](../docs/alpha1-factory/TESTPLAN.txt)

Version **0.28.4-alpha.1**, Android-Code **2981**, weiterhin auf 0.28-Basis.
Direkt als Update über die vorhandene Alpha installieren. **Nicht deinstallieren
und keine App-Daten löschen.** Gleiches Paket, Speicherverzeichnis und Testzertifikat
wie seit 0.23. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0.

Überarbeiteter Fabrikhof, kompakte Fahrzeuge und lesbare Materialwerte. Neues
31 × 23 m Zentrallager mit tatsächlicher Warenabholung, eigener weiß-blauer Lagerflotte
und schwarz-weißer Baustellenflotte. Regionale Abhol-Express-Depots für entfernte
Baustellen. Vollständige Staplerzyklen und Regale mit wirklichen Beständen.
Bewegte Flammenkörper und Rauch; alte Standorte und laufende Frachten bleiben erhalten.
Unter Bauen → Versorgung die Zentrale bewusst neu platzieren und fertigstellen.

19,815 Headless-Prüfungen und 795 OpenGL-Prüfungen
bestanden; zusätzlich 107 Headless- und 274
OpenGL-Prüfungen mit den tatsächlich entpackten APK-Assets. Keine dieser Prüfungen
ist ein echter Android-Gerätetest. Dieser steht aus, ebenso die Temperaturmessung
auf S26 Ultra/S24 FE. Paket, Signatur, Version und ZIP-Ausrichtung geprüft.

APK-Quellstand `8ccb88798b42d22ab8c679d085606eb812c14e2a`. Quell-ZIP: 522 Dateien gegen Git geprüft.
Testerpaket: 6 Einträge mit identischer APK und Prüfsummen.
Der private Schlüssel wird nicht mitgeliefert. Ein öffentlicher Download ist
kein Zugang nur für eingeladene Tester.

## Frühere Veröffentlichungen

# Empfohlen: Werkshof · 0.28.3-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.3-alpha.1/releases/Timber-Loot-Tycoon-v0.28.3-alpha.1.apk)** · **[Testerpaket mit Anleitung](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.3-alpha.1/releases/Timber-Loot-Tycoon-Alpha-1-Werkshof-Testerpaket.zip)**

[Passender Quellcode](Timber-Loot-Tycoon-v0.28.3-source.zip) · [Änderungen](../docs/CAMPUS-283.md) · [Testplan](../docs/alpha1-campus/TESTPLAN.txt)

Version **0.28.3-alpha.1**, Android-Code **2971**, weiterhin auf 0.28-Basis.
Direkt als Update über die vorhandene Alpha installieren. **Nicht deinstallieren
und keine App-Daten löschen.** Gleiches Paket, Speicherverzeichnis und Testzertifikat
wie seit 0.23. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0.

Zusammenhängender offener Werkshof, geordnete Waldparzellen und breite sandfarbene
Transportwege. Kompaktes warmes HUD und Benno-Dialoge direkt in der Welt. Neue
Stapler-, Kran- und Holzfälleranimationen folgen der wirklichen Arbeit; reduzierte
Bewegung und Akkumodus begrenzen die zusätzliche Darstellung. Die Start-, Verkehrs-
und Bedienverbesserungen aus 0.28.2 bleiben enthalten.

19,767 Headless-Prüfungen und 695 OpenGL-Prüfungen
bestanden; zusätzlich 65 Headless- und 229
OpenGL-Prüfungen mit den tatsächlich entpackten APK-Assets. Keine dieser Prüfungen
ist ein echter Android-Gerätetest. Dieser steht aus, ebenso die Temperaturmessung
auf S26 Ultra/S24 FE. Paket, Signatur, Version und ZIP-Ausrichtung geprüft.

APK-Quellstand `dff975822d50b3feee22772269fbe01db625881e`. Quell-ZIP: 500 Dateien gegen Git geprüft.
Testerpaket: 6 Einträge mit identischer APK und Prüfsummen.
Der private Schlüssel wird nicht mitgeliefert. Ein öffentlicher Download ist
kein Zugang nur für eingeladene Tester.

## Frühere Veröffentlichungen

# Empfohlen: Waldleben · 0.28.2-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.2-alpha.1/releases/Timber-Loot-Tycoon-v0.28.2-alpha.1.apk)** · **[Testerpaket mit Anleitung](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.2-alpha.1/releases/Timber-Loot-Tycoon-Alpha-1-Waldleben-Testerpaket.zip)**

[Passender Quellcode](Timber-Loot-Tycoon-v0.28.2-source.zip) · [Änderungen](../docs/FOREST-282.md) · [Testplan](../docs/alpha1-forest/TESTPLAN.txt)

Version **0.28.2-alpha.1**, Android-Code **2961**, weiterhin auf 0.28-Basis.
Direkt als Update über die vorhandene Alpha installieren. **Nicht deinstallieren
und keine App-Daten löschen.** Gleiches Paket, Speicherverzeichnis und Testzertifikat
wie seit 0.23. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0.

Wärmere Low-Poly-Höfe mit neuen Dächern und Zäunen; gestaffelte Abfahrten über
alle Frachtarten und kein Strandungseffekt durch Produktionspause. Routen-Caches
und Berechnung einer getrennten Firmenkopie mit sichtbarem Fortschritt.
Dazu acht Bedienhilfen einschließlich Engpässen, Materialtrends, Langdruck-Verschieben
mit Rückgängig, Baukosten und vergleichbarer Kamerarunde.

19,779 Headless-Prüfungen und 648 OpenGL-Prüfungen
bestanden; zusätzlich 65 Headless- und 182
OpenGL-Prüfungen mit den tatsächlich entpackten APK-Assets. Keine dieser Prüfungen
ist ein echter Android-Gerätetest. Dieser steht aus, ebenso die Temperaturmessung
auf S26 Ultra/S24 FE. Paket, Signatur, Version und ZIP-Ausrichtung geprüft.

APK-Quellstand `0215505adc1f92566f53577f4700666608706ea6`. Quell-ZIP: 482 Dateien gegen Git geprüft.
Testerpaket: 6 Einträge mit identischer APK und Prüfsummen.
Der private Schlüssel wird nicht mitgeliefert. Ein öffentlicher Download ist
kein Zugang nur für eingeladene Tester.

## Frühere Veröffentlichungen

# Empfohlen: Rückkehr zur 0.28 · 0.28.1-alpha.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.1-alpha.1/releases/Timber-Loot-Tycoon-v0.28.1-alpha.1.apk)** · **[Testerpaket mit Anleitung](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.1-alpha.1/releases/Timber-Loot-Tycoon-Alpha-1-Rueckkehr-028-Testerpaket.zip)**

[Passender Quellcode](Timber-Loot-Tycoon-v0.28.1-source.zip) · [Änderungen](../docs/ROLLBACK-028.md) · [Testplan](../docs/alpha1-rollback/TESTPLAN.txt)

Version **0.28.1-alpha.1**, Android-Code **2951**. Die Spielbasis ist wieder die
verteilte 0.28; Ampel- und Bauleitersteuerung ab 0.29 sind zurückgenommen.
Die höhere interne Nummer erlaubt ein Update über 0.29.4. **Nicht deinstallieren
und keine App-Daten löschen.** Gleiches Paket, Speicherverzeichnis und Testzertifikat
wie seit 0.23. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0.

Zusätzlich auf der 0.28-Basis: Häuser direkt versetzen, dauerhafte Materialbestände
im Hauptbildschirm, begrenzte Tutorial-/Bauvorschau und mobile Lastbegrenzung.
Android maximal 30 FPS, kleinere Schatten, keine Darstellung im Hintergrund.
Die Temperaturwirkung auf S26 Ultra und S24 FE muss auf den Geräten geprüft werden.

19,673 Headless-Prüfungen und 612 OpenGL-Prüfungen
bestanden; zusätzlich 43 Headless- und 146
OpenGL-Prüfungen mit den tatsächlich entpackten APK-Assets. Keine dieser Prüfungen
ist ein echter Android-Gerätetest. Dieser steht aus. Paket, Signatur, Version
und ZIP-Ausrichtung geprüft. Der private Schlüssel wird nicht mitgeliefert.

APK-Quellstand `e1f70e76a30522f8456762c50f57ac580dfd311f`. Quell-ZIP: 455 Dateien gegen Git geprüft.
Testerpaket: 6 Einträge mit identischer APK und Prüfsummen.
Ein öffentlicher Download ist kein Zugang nur für eingeladene Tester.

## Frühere Veröffentlichungen (0.29 zurückgenommen)

# Alpha 2 · Ladehof-Update 0.29.4

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.29.4-alpha.2/releases/Timber-Loot-Tycoon-v0.29.4-alpha.2.apk)** · **[Testerpaket mit Anleitung](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.29.4-alpha.2/releases/Timber-Loot-Tycoon-Alpha-2-Ladehof-Update-Testerpaket.zip)**

[Passender Quellcode](Timber-Loot-Tycoon-v0.29.4-source.zip) · [Änderungen](../docs/TRAFFIC-294.md) · [Testplan](../docs/alpha2-yard/TESTPLAN.txt)

Version **0.29.4-alpha.2**, Code **2942**, Launchername **Timber Loot Alpha**.
Direkt über die vorhandene Alpha installieren; vorher nicht deinstallieren und
keine App-Daten löschen. Gleiches Paket, Speicherverzeichnis und Testzertifikat
wie seit 0.23. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0.

Behebt blockierte Hofzufahrten und volle Kreuzungsausfahrten. Weitere Ladungen
warten im Depot, bis die laufende Tour zurück ist. Baustellen und Ladenlinie
wechseln sich am Ladehof ab. Alte noch nicht angelieferte Frachten werden einmal
vom vorhandenen Depot neu disponiert; ihre Mengen und bereits gutgeschriebene
Lieferungen bleiben erhalten. Anrückende Feuerwehr fordert weiterhin Grün an.

25.466 Headless-Prüfungen und 228 gezielte OpenGL-Prüfungen bestanden. Zusätzlich
2.420 Verkehrs- und 15 Hintergrundprüfungen auf den tatsächlich entpackten APK-Assets.
Diese Desktop-Prüfungen sind kein echter Android-Gerätetest; dieser steht aus.
APK-Signatur, Paket, Version und ZIP-Ausrichtung geprüft. Der private Schlüssel
und Spielerprofile werden nicht mitgeliefert.

APK-Quellstand `1b503a1692ee994840a6b2330d0e3fcabd76644b`. Quell-ZIP: 491 Dateien gegen Git-Blobs geprüft.
Testerpaket: 6 Einträge mit identischer APK und Prüfsummen.
Ein öffentlicher Download ist kein Zugang nur für eingeladene Tester.

## Vorherige Veröffentlichungen

# Alpha 2 · Verkehrsfix 0.29.3

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.29.3-alpha.2/releases/Timber-Loot-Tycoon-v0.29.3-alpha.2.apk)** · **[Testerpaket mit Anleitung](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.29.3-alpha.2/releases/Timber-Loot-Tycoon-Alpha-2-Verkehrsfix-Testerpaket.zip)**

[Passender Quellcode](Timber-Loot-Tycoon-v0.29.3-source.zip) · [Änderungen](../docs/TRAFFIC-293.md) · [Testplan](../docs/alpha2-traffic/TESTPLAN.txt)

Version **0.29.3-alpha.2**, Code **2932**, Launchername **Timber Loot Alpha**.
Direkt über die vorhandene Alpha installieren; vorher nicht deinstallieren und
keine App-Daten löschen. Gleiches Paket, Speicherverzeichnis und Testzertifikat
wie seit 0.23. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0.

Behebt die nachgestellte gegenseitige Blockade von LKW auf getrennten Spuren;
bereits gespeicherte Testschlangen kommen wieder in Bewegung. Anrückende
Löschfahrzeuge fordern Grün an und lassen belegte Kreuzungen zuerst räumen.
Waren und Fahrzeugbestand werden weder zurückgesetzt noch künstlich ergänzt.

22.928 Headless-Prüfungen und 130 gezielte OpenGL-Prüfungen bestanden. Zusätzlich
2.414 Verkehrs- und 15 Hintergrundprüfungen auf den tatsächlich entpackten APK-Assets.
Diese Desktop-Prüfungen sind kein echter Android-Gerätetest; dieser steht aus.
APK-Signatur, Paket, Version und ZIP-Ausrichtung geprüft. Der private Schlüssel
und Spielerprofile werden nicht mitgeliefert.

APK-Quellstand `129dcbe0a6a59f8647c7c7d1cabcbc1f5f04a030`. Quell-ZIP: 472 Dateien gegen Git-Blobs geprüft.
Testerpaket: 6 Einträge mit identischer APK und Prüfsummen.
Ein öffentlicher Download ist kein Zugang nur für eingeladene Tester.

## Vorherige Veröffentlichungen

# Alpha 2 · Schnellstart 0.29.2

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.29.2-alpha.2/releases/Timber-Loot-Tycoon-v0.29.2-alpha.2.apk)** · **[Testerpaket mit Anleitung](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.29.2-alpha.2/releases/Timber-Loot-Tycoon-Alpha-2-Schnellstart-Testerpaket.zip)**

[Passender Quellcode](Timber-Loot-Tycoon-v0.29.2-source.zip) · [Änderungen](../docs/PERFORMANCE-292.md) · [Testplan](../docs/alpha2-performance/TESTPLAN.txt)

Version **0.29.2-alpha.2**, Code **2922**, Launchername **Timber Loot Alpha**.
Direkt über die vorhandene Alpha installieren; vorher nicht deinstallieren und
keine App-Daten löschen. Gleiches Paket `com.whiskymitschuss.timberloot.reborn`,
gleiches Testzertifikat und Speicherverzeichnis. Android 7.0+, ARM64/ARMv7,
OpenGL ES 3.0, nur optionale Vibration.

Der Rechenlauf ist unabhängig vom sichtbaren Spielfenster. Minimieren pausiert ihn
nicht mehr durch die Spielschleife; Android darf weiterhin den ganzen Prozess
anhalten oder beenden. Der Desktop-Ladevergleich mit identischer Teststadt ist
3,87× schneller (83,887 → 21,675 Sekunden), mit identischem Firmenstand.
Das ist keine Messung auf einem Handy. Ein Abbruch bewahrt den bisherigen Stand.

20,514 Headless- und 526 OpenGL-Prüfungen bestanden.
Debug-signierte Alpha; ein Test dieser Fassung auf dem betroffenen Android-Handy
steht noch aus. Es gibt keine zugesicherte maximale Ladezeit auf jedem Gerät.

APK-Quellstand `84a700d8b9b3d1b696e760d3edd8689455a90fb1`. Quell-ZIP: 457 Dateien einzeln gegen Git-Blobs
geprüft. Testerpaket: 6 Einträge mit identischer APK und Prüfsummen.
Ein öffentlicher Download ist kein Zugang nur für eingeladene Tester.
Private Schlüssel, Spielerprofile und Testberichte sind nicht enthalten.

## Vorherige Veröffentlichungen

# Alpha 2 · Startfix 0.29.1

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.29.1-alpha.2/releases/Timber-Loot-Tycoon-v0.29.1-alpha.2.apk)** · **[Testerpaket mit Anleitung](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.29.1-alpha.2/releases/Timber-Loot-Tycoon-Alpha-2-Startfix-Testerpaket.zip)**

[Passender Quellcode](Timber-Loot-Tycoon-v0.29.1-source.zip) · [Änderungen](../docs/STARTFIX-291.md) · [Testplan](../docs/alpha2-startfix/TESTPLAN.txt)

Version **0.29.1-alpha.2**, Code **2912**, Launchername **Timber Loot Alpha**.
Direkt über die vorhandene Alpha installieren; vorher nicht deinstallieren und
keine App-Daten löschen. Gleiches Paket `com.whiskymitschuss.timberloot.reborn`,
gleiches Testzertifikat und Speicherverzeichnis. Android 7.0+, ARM64/ARMv7,
OpenGL ES 3.0, nur optionale Vibration.

Beim Start erscheinen ein Logo und eine Ladeanzeige. Offline-Fortschritt wird in
kurzen Abschnitten verarbeitet. Ein Abbruch überschreibt den bisherigen Stand
nicht. Auch die Rückkehr aus dem Hintergrund läuft über diesen Ablauf.

20,160 Headless- und 517 OpenGL-Prüfungen bestanden.
Debug-signierte Alpha; ein Test dieser Fassung auf dem betroffenen Android-Handy
steht noch aus. Es gibt keine zugesicherte maximale Ladezeit auf jedem Gerät.

APK-Quellstand `8ecab481388911558235eab22a6e670705a47849`. Quell-ZIP: 436 Dateien einzeln gegen Git-Blobs
geprüft. Testerpaket: 6 Einträge mit identischer APK und Prüfsummen.
Ein öffentlicher Download ist kein Zugang nur für eingeladene Tester.
Private Schlüssel, Spielerprofile und Testberichte sind nicht enthalten.

## Vorherige Veröffentlichungen

# Alpha 2 — Feuer, Bauleitung und Verkehr

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.29.0-alpha.2/releases/Timber-Loot-Tycoon-v0.29-alpha.2.apk)** · **[Testerpaket mit Anleitung](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.29.0-alpha.2/releases/Timber-Loot-Tycoon-Alpha-2-Testerpaket.zip)**

[Passender Quellcode](Timber-Loot-Tycoon-v0.29-source.zip) · [Änderungen](../docs/ALPHA2.md) · [Testplan](../docs/alpha2/TESTPLAN.txt)

Version **0.29-alpha.2**, Code **2902**, Launchername **Timber Loot Alpha**.
Als Update über Alpha 1 oder „Timber Loot Neu“ ab 0.23 installieren; vorher nicht deinstallieren.
Gleiches Paket `com.whiskymitschuss.timberloot.reborn`, gleiches Testzertifikat und
Speicherverzeichnis. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0, nur optionale Vibration.

Animierte Flammen und weicher Rauch, kompakte Brandanzeige, geräumte Bauflächen,
versetzte Forstmaschinen, wechselnde Bauteams, Ampeln mit Techniker-Reparaturen,
passende Fahrzeuggrößen und echte Wartezeit für Lieferungen. Bauleiterin Mara
koordiniert vorhandene Teams und erklärt Material- und Transportengpässe.

20,125 Headless- und 490 OpenGL-Prüfungen bestanden.
Debug-signierte Alpha. Für Alpha 2 stehen echte Android-Leistungstests noch aus.
Deine Firma bleibt bei einer Update-Installation erhalten; Daten nicht löschen.

APK-Quellstand `04d4f4210301848fd14041bcfb5ab940a52e978f`. Quell-ZIP: 420 Dateien einzeln gegen Git-Blobs geprüft.
Testerpaket: 6 Einträge, identische APK und überprüfte Texte/Prüfsummen.
Ein öffentlicher Download ist kein Zugang nur für eingeladene Tester.
Private Schlüssel, Spielerprofile und Testberichte sind nicht enthalten.

## Vorherige Veröffentlichung

# Alpha 1 — erste Fassung für Spieltests

**[APK herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.0-alpha.1/releases/Timber-Loot-Tycoon-v0.28-alpha.1.apk)** · **[Testerpaket mit Anleitung](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.28.0-alpha.1/releases/Timber-Loot-Tycoon-Alpha-1-Testerpaket.zip)**

**[Passender Quellcode](Timber-Loot-Tycoon-v0.28-source.zip)**

Version **0.28-alpha.1**, Code **2801**, Launchername **Timber Loot Alpha**.
Als Update über „Timber Loot Neu“ ab 0.23 installieren; vorher nicht deinstallieren.
Gleiches Paket `com.whiskymitschuss.timberloot.reborn`, gleiches Testzertifikat und
Speicherverzeichnis. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0, nur optionale Vibration.

Neues 3D-Intro, kurze fortsetzbare Anleitung durch Benno, echte erste Produktion
und eigene Hütte, gesicherte Speicherdateien, korrigierte Touch-/Zurück-Bedienung
und lesbarere kleine Displays. **Mehr → Alpha 1 · Testen & Feedback** enthält einen
bearbeitbaren Bericht mit Kopieren und lokaler Sicherung. Es wird nichts automatisch
versendet. [Änderungen](../docs/ALPHA1.md), [Testplan](../docs/alpha1/TESTPLAN.txt).

Das Tester-ZIP enthält exakt diese APK, Installation, Testplan, Feedbackvorlage,
Builddaten und Prüfsummen. Der Eigentümer kann es an ausgewählte Tester weitergeben.
Der öffentliche GitHub-Link ist kein Zugang nur für eingeladene Personen.

19.630 Headless- und 465 OpenGL-Prüfungen bestanden. Debug-signierte Alpha;
echter Android-Gerätetest und mobile Leistungsprüfung stehen aus. Hafen und
Flughafen bleiben geplant. Kein Cloud-Save; lokale Daten nicht löschen.

APK-Quellstand `d14b53774d5505a93ee1e7b845b2b4753fd9b804`. Quell-ZIP: 397 Dateien einzeln gegen ihre
Git-Blobs geprüft. Testerpaket: 6 Einträge, APK-Bytes und Texte geprüft.
Hashes und Zertifikat im APK-Bericht und in `SHA256SUMS.txt`.
Private Schlüssel, Spielerprofile und lokale Testberichte sind nicht enthalten.

## Historische Veröffentlichung 0.27

# Freie Welt & Handel 0.27

**[APK 0.27 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.27.0-welthandel/releases/Timber-Loot-Tycoon-v0.27-test.apk)**

**[Passender Quellcode](Timber-Loot-Tycoon-v0.27-source.zip)**

Als Update über **Timber Loot Neu ab 0.23** installieren; vorher nicht deinstallieren.
Paket `com.whiskymitschuss.timberloot.reborn`, Version `0.27-test`, Code 2700.
Testsignatur und Speicherbereich bleiben erhalten.

Freies Bauen auf dem ebenen Festland ohne feste Haus-/Industrieplatzgrenzen.
Sichtbar geschützte Biome müssen erschlossen werden. **Mehr → Autobahn &
Exporthandel**: Markt mit Anschluss **300 / 176** über eigene Straßen verbinden.
Echte Warenladungen, gemeinsame LKW-Flotte, Auszahlung bei Ankunft und reservierte
Rückfahrt. Lokaler Verkauf bleibt verfügbar. Hafen und Flughafen sind nächste,
noch inaktive Frachtwege. [Änderungen und Bedienung](../docs/WORLD-TRADE27.md).

19.595 Headless- und 406 Grafikprüfungen bestanden. V2-Signatur,
16-KB-Ausrichtung, API 24+, ARM64/ARMv7, OpenGL und Hochformat geprüft.
Nur optionale Vibration. Echter Handytest und mobile Leistungsmessung stehen aus.

Quellstand `d915a41aac101b7870a35005c29c9ca26e6cc13f`; Quell-ZIP: 372 Dateien gegen ihre Git-Blobs geprüft.
Hashdaten und Zertifikat im APK-Bericht und in `SHA256SUMS.txt`.
Private Schlüssel, Spielstände und Fotos sind nicht enthalten.

## Historische Veröffentlichung 0.26

# Detailwelt 0.26 — zehn Ideen umgesetzt

**[APK 0.26 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.26.0-detailwelt/releases/Timber-Loot-Tycoon-v0.26-test.apk)**

**[Passender Quellcode](Timber-Loot-Tycoon-v0.26-source.zip)**

Als Update über **Timber Loot Neu ab 0.23** installieren; vorher nicht deinstallieren.
Paket `com.whiskymitschuss.timberloot.reborn`, Version `0.26-test`, Code 2600.
Testsignatur und Speicherbereich bleiben erhalten.

Gemeinsamer Wind, räumliche Feuerwehrgeräusche, Fällklang und Baumstümpfe, nasse
Straßen/Dächer, Vögel und Hasen, sichtbare Ladeübergaben, Bau-Enthüllung,
Produktionshinweise, weichere Kamera sowie **Mehr → Fotomodus & Galerie**.
Fotos werden auf diesem Gerät in der Spielgalerie gespeichert; kein automatischer
Export in die Android-Systemgalerie. [Alle zehn Aufgaben](../docs/DETAIL-PASS26.md).

19.502 Headless- und 361 gerenderte Prüfungen bestanden. Signatur v2,
16-KB-Ausrichtung, API 24+, ARM64/ARMv7, OpenGL und Hochformat geprüft.
Weiterhin nur optionale Vibration. Handytest, Hörprobe und mobile Leistungsmessung
von 0.26 stehen aus.

Quellstand `5897b95a116de9b1385e85e7b4a9573376c8a415`; Quell-ZIP: 356 Dateien einzeln mit Git abgeglichen.
Hashdaten und Zertifikat im APK-Bericht und in `SHA256SUMS.txt`.
Private Schlüssel, Spielstände und Fotos sind nicht enthalten.

## Historische Veröffentlichung 0.25

# Waldleben 0.25 — Qualitätsüberarbeitung

**[APK 0.25 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.25.0-waldleben/releases/Timber-Loot-Tycoon-v0.25-test.apk)**

**[Passender Quellcode](Timber-Loot-Tycoon-v0.25-source.zip)**

Als Update über **Timber Loot Neu 0.23/0.24** installieren; nicht deinstallieren.
Paket `com.whiskymitschuss.timberloot.reborn`, Version `0.25-test`, Code 2500.
Bestehende Testsignatur und Speicherbereich bleiben erhalten.

Neues HUD mit Währungskarten, Zielbalken und Mitteilungseingang; Wind und Baumfällen,
Kaminrauch und echte Produktionspartikel; Funken, Wasser und Löschfortschritt;
erkennbare Ausbaustufen und Belohnungsfeedback. Alle sieben Aufgaben samt
Spielernutzen: [Qualitätsdokumentation](../docs/QUALITY-PASS.md).

19.456 Headless- und 324 gerenderte Prüfungen bestanden. Signatur v2, 16-KB-Ausrichtung,
API 24+, ARM64/ARMv7, OpenGL und Hochformat geprüft. Nur optionale Vibration.
Ein echter Handytest von 0.25 und mobile Leistungs-/Akkumessungen stehen aus.

Quellstand `f5de63c1166300e6083e6a4834c660929968ce52`; Quell-ZIP: 329 Dateien einzeln mit Git abgeglichen.
Hashdaten und Zertifikat im APK-Bericht und in `SHA256SUMS.txt`.
Private Schlüssel und Spielstände sind nicht enthalten.

## Historische Veröffentlichung 0.24

# Brandschutz 0.24 — Update für Timber Loot Neu

**[APK 0.24 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.24.0-brandschutz/releases/Timber-Loot-Tycoon-v0.24-test.apk)**

**[Passender Quellcode](Timber-Loot-Tycoon-v0.24-source.zip)**

**Als Update über Timber Loot Neu 0.23 installieren; nicht vorher deinstallieren.**
Paket `com.whiskymitschuss.timberloot.reborn`, Version `0.24-test`, Code 2400.
Signatur identisch mit der vom Nutzer getesteten 0.23. Bestehende neue Spielstände
bleiben im selben Speicherordner; die ursprüngliche App bis 0.20 ist ein anderes Paket.

Neu: kaufbare Rauchmelder und Hydranten, echte Erkennungs-/Löschzeitvorteile,
Straßenversorgung und sichtbare Schläuche, getrennte Einsatz-/Wartezustände sowie
freie/belegte Feuerwehrkapazität. Keine laufenden Münzkosten und keine Gebäudeverluste.

APK-Signatur v2, API 24+, ARM64/ARMv7, OpenGL, Hochformat und 16-KB-Ausrichtung
geprüft. Nur optionale Vibration. Ein echter Handytest von 0.24 steht aus.

APK-Quellstand `34b5ee44807c827f022b95c805e8ba6690fe30e2`. Quell-ZIP: 312 Dateien, einzeln gegen ihre
Git-Blobs geprüft. Signatur- und Hashdaten in `.apk.json` und `SHA256SUMS.txt`.
Der private Schlüssel bleibt außerhalb des Repositories und aller Quellarchive.

## Historische Veröffentlichungen

# Neubeginn 0.23 — neue Test-App

**[APK 0.23 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.23.0-neubeginn/releases/Timber-Loot-Tycoon-v0.23-test.apk)**

**[Passender Quellcode](Timber-Loot-Tycoon-v0.23-source.zip)**

Im Launcher **Timber Loot Neu**, Paket `com.whiskymitschuss.timberloot.reborn`,
Version `0.23-test`, Code 2300. Neues Biber-Logo, überspringbares Startintro und
sämtliche Brand-/UI-Erweiterungen von 0.21/0.22. Separate Installation neben der
bisherigen App. Neuer Testschlüssel auf ausdrücklichen Wunsch; keine Übernahme
alter Daten und kein Update über das alte Paket.

Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0; rund 63 MB. Nur optionale Vibration.
Signatur v2, 16-KB-Ausrichtung, Paket/Version und verpackte Startszene geprüft.
Keine echte Handy-Installation oder Leistungsmessung behauptet.

APK-Quellstand: `6906cc4f52ecac6d6149031545dfa36c226ce6b0`. Das passende ZIP enthält 303 Dateien,
jeweils gegen den Git-Blob dieses Quellstands geprüft. SHA256 und Zertifikatsdaten
stehen in `Timber-Loot-Tycoon-v0.23-test.apk.json` und `SHA256SUMS.txt`.
Der private Schlüssel ist weder im ZIP noch im Repository enthalten.

## Historische Veröffentlichungen

# Timber Loot Tycoon 0.20 — Waldstadt

**[Android-Update 0.20 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.20.0-waldstadt/releases/Timber-Loot-Tycoon-v0.20-test.apk)**

**[Passendes Godot-Quellprojekt herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.20.0-waldstadt/releases/Timber-Loot-Tycoon-v0.20-source.zip)**

Erster Abschnitt der 3D-Erneuerung: gerundete Baukörper und Grundstücke, eingerahmte Fenster, gestaltete Dächer, Eingänge und Vorgärten. Offene Holzfabriken erhalten ausgearbeitete Werkstatt-Rückseiten und Ladebereiche. Gehwege besitzen Bordsteine und gerundete Kreuzungsecken; LKWs und Busse nehmen sichtbare Kurven auf Grundlage ihrer echten Liefer-/Fahrwege. Wärmere Nachtfenster, weichere Baumkronen und bewachsene freie Bauflächen. Nahe Pflanzen werden gezielt instanziert und entfernte Bäume vereinfacht. [Umfang und weitere Schritte](../docs/WALDSTADT.md).

**Als Update installieren, vorher nicht deinstallieren und keine App-Daten löschen.** Gleiches Paket, gleicher Testschlüssel und Speicherformat 1; Versionscode 2000. Bestehende Firmen und zehn Kapitel bleiben spielbar. Android 7.0+, ARM64/ARMv7 und OpenGL ES 3.0. Die einzige Berechtigung bleibt die optionale Vibration. Keine Werbung oder echten Käufe. Ein Android-Geräte- und Leistungstest dieser Version steht aus.

19.350 Headless-Prüfungen, danach 4.397 gezielte Headless-Prüfungen der Sichtweitenoptimierung und 155 gezielte Desktop-OpenGL-/Touch-Prüfungen bestanden. Eine frische GitHub-Kopie bestätigt 4.397 relevante Headless- und 14 neue grafische Prüfungen. Gemeldete Renderer-Last am Start gegenüber dem ersten unoptimierten neuen Modellstand um rund 55 % reduziert; keine gemessene Smartphone-Framerate. [Prüfbericht](../docs/VALIDATION.md).

APK-Quellstand `f19ab74fe973d7586a5506749dd85f8f8d42865c`. Quell-ZIP: 282 Dateien, jede gegen ihren Git-Blob geprüft. APK: 58,422,147 Bytes, SHA256 `0b1928681b8d58b9720eedd97094d6b1d895a62702d8adb1d3d2d44c81cdaa86`. Quell-ZIP: 15,270,924 Bytes, SHA256 `bd5d6961c54522d8d2388294609ae4ac816c62198e065c3af834255e0f4d0231`. Signatur und Paketdaten in `.apk.json`, Hashes in `SHA256SUMS.txt`.

APK, passende Quell-ZIP und alle fünf neuen Vorschauen wurden vom festen Tag `v0.20.0-waldstadt` vollständig per HTTPS mit HTTP 200 zurückgeladen. Größen und SHA256 stimmen mit gebautem Original und unabhängiger GitHub-Wiederherstellung überein. [Download-Prüfbericht](../docs/download-verification-20.json).

## Historischer Stand 0.19.2

# Timber Loot Tycoon 0.19.2 — Gebäudekarte korrigiert

**[Android-Update 0.19.2 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.19.2-cardfix/releases/Timber-Loot-Tycoon-v0.19.2-test.apk)**

**[Passendes Godot-Quellprojekt herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.19.2-cardfix/releases/Timber-Loot-Tycoon-v0.19.2-source.zip)**

Die Gebäudekarte bleibt auch bei wechselnden Textgrößen auf den verfügbaren Bereich begrenzt. Titel und Schließen bleiben sichtbar; längere Inhalte scrollen mit dem Finger. Aktualisierungen erhalten die Leseposition und das gedrückte Touch-Ziel. Welt-Materialanzeigen überdecken weder Gebäudekarte noch Baupalette.

**Als Update installieren, vorher nicht deinstallieren und keine App-Daten löschen.** Gleiches Paket, gleicher Testschlüssel und Speicherformat 1; Android-Code 1920. Zehn Kapitel und alle bisherigen Produktions-/Bausysteme bleiben erhalten. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Die einzige Berechtigung bleibt die optionale Vibration. Kein echter Android-Gerätetest dieser Korrektur.

19.222 Headless-Prüfungen und 569 gezielte Desktop-OpenGL-Prüfungen bestanden, einschließlich wiederholter Touch-Auswahl, vorübergehend überhohem Inhalt, großer Schrift, geringer logischer Bildschirmhöhe, Finger-Scrollen und sichtbarem Schließen. Die frische GitHub-Wiederherstellung bestätigt zusätzlich 437 Layout- und 87 Touch-Prüfungen. Die normale Wiederholung allein stellte den Handyfehler in der Cloud nicht nach; der gezielte Höhen-Stress schlug vor der Korrektur fehl und besteht danach. [Prüfbericht](../docs/VALIDATION.md).

APK-Quellstand `226519915f46e3f8e883190f6670422b8cbab86f`. Quell-ZIP: 263 Dateien, jede gegen ihren Git-Blob geprüft. APK: 58,396,802 Bytes, SHA256 `ad54a55a0b35d5370603c6e13f41f1eafedeb0639659c6800d52c150935198e3`. Quell-ZIP: 13,333,293 Bytes, SHA256 `a82d0385b2aa4bc943abd13fa582a2014cfecfee8ce9515083fb3a956f57c4da`. Signatur/Paketdaten in `.apk.json`, Prüfsummen in `SHA256SUMS.txt`.

APK, passende Quell-ZIP und Karten-Vorschau wurden vom festen Tag `v0.19.2-cardfix` vollständig per HTTPS mit HTTP 200 zurückgeladen. Größen und SHA256 stimmen mit gebautem Original und unabhängiger GitHub-Wiederherstellung überein. [Download-Prüfbericht](../docs/download-verification-192.json).

## Historischer Stand 0.19.1

# Timber Loot Tycoon 0.19.1 — Zehn Kapitel & Rathaus

**[Android-Update 0.19.1 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.19.1-journey/releases/Timber-Loot-Tycoon-v0.19.1-test.apk)**

**[Passendes Godot-Quellprojekt herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.19.1-journey/releases/Timber-Loot-Tycoon-v0.19.1-source.zip)**

Zehn Kapitel mit 30 konkreten Aufgaben und zehn wirklichen Rathaus-Bauabschlüssen. Das Rathaus wächst vom Waldbüro zum Stadtpalais, wird mit tatsächlichen LKW-Lieferungen gebaut und verbessert die Grundmiete. Eigenes Verwaltungsgrundstück ohne Verlust von Wohnbauplätzen. Kapitelpokale und Titel bleiben über Prestige hinaus erhalten. Freiwillige Kurzaufträge zählen neue Produktion und echte Ankünfte; die Rückkehrbilanz zahlt vorhandene Erträge nicht erneut aus. [Alle Kapitel und Voraussetzungen](../docs/CHAPTERS.md).

**Als Update installieren, vorher nicht deinstallieren.** Gleiches Paket, gleiche Testsignatur und Schema 1; Android-Code 1910. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Ausschließlich optionale Vibration als Berechtigung. Kein echter Android-Gerätetest dieser Version; mobile Leistung und reale Spielerbindung bleiben zu prüfen.

18.785 Headless-Prüfungen und 223 Desktop-OpenGL-/Eingabeprüfungen im gesamten Prüfumfang. Erste zwei Kapitel ohne Münz-/Materialgeschenke: Rathaus 1 nach 393 simulierten Sekunden, Rathaus 2 bei 855 Sekunden. Späte Kapitel und alle zehn Bauausbauten mit ausdrücklich vorbereitetem Testprofil geprüft, keine nachgewiesene reale Gesamtspieldauer.

APK-Quellstand `cae1e85f08e2346ae490179dd2161fce587a8855`. Quell-ZIP: 256 Dateien, jede gegen ihren Git-Blob geprüft. APK: 58,396,701 Bytes, SHA256 `bd9fd6e2f1f9597f52eb965fbdeb24799eac8117dc3dfde56d867418ae98773a`. Quell-ZIP: 12,981,993 Bytes, SHA256 `5d58bf9f18af538d6fd488d183a9ff9decb134f0ea6abb9e2343558d3d4446a2`. Paket-/Signaturdaten in `.apk.json`, Hashes in `SHA256SUMS.txt`.

Ein optionales Einnahmemodell über hochwertige Kosmetik und ein einmaliges Unterstützerpaket ist als [Vorschlag](../docs/MONETIZATION.md) dokumentiert. Die APK enthält keine echten Käufe oder Werbung.

Auch eine unabhängige Wiederherstellung besteht alle 18.785 Headless-Prüfungen und die 40 neuen OpenGL-Prüfungen. Alle sieben Download-Dateien wurden vollständig vom festen Tag geladen und mit beiden Projektkopien verglichen. [Download-Prüfbericht](../docs/download-verification-191.json).

## Historischer Stand 0.19

# Timber Loot Tycoon 0.19 — Stadtgefühl

**[Android-Update 0.19 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.19.0-cityux/releases/Timber-Loot-Tycoon-v0.19-test.apk)**

**[Passendes Godot-Quellprojekt 0.19 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.19.0-cityux/releases/Timber-Loot-Tycoon-v0.19-source.zip)**

Alle zwölf beschriebenen UX-Bereiche sind verbunden: Gebäudekarten mit Wischgeste, Materialhilfe und Liefermengen, auswählbare LKWs mit echten Straßenwegen, horizontale Baupalette, Straßenzeichnen und geschützte Rücknahme, benannte Viertel mit gemeinsamen Ausbauplänen, antippbare Übersicht und Regionsinformationen, ruhige Ereignisse, Benno-Hinweise sowie Rückmeldungen und Zugänglichkeit. [Bedienung und Prüfliste](../docs/UX-CHECKLIST.md).

Vierzehn Stadtgebäudetypen erhalten jeweils zehn tatsächliche Architekturstadien: 140 Modelle. Wohnhaus → Hochhaus, Hotel → Resort, Feuerwache → zentrale Hauptfeuerwache, Rettungsstation → Krankenhaus/Klinikum. Auch alle anderen Stadtgebäude wachsen sichtbar. Erst fertig gebaute Ausbaustufen ändern das gespeicherte Haus. Die tatsächlichen Modelle lassen sich beim Haus unter **Stufen 1–10** ansehen.

Unten **Bauen** öffnet die neue Wischpalette, **Welt** die Übersicht. Gebäude und Liefer-LKWs direkt antippen. Für Viertel **Bauen → Wege → Viertel markieren** wählen. Der bestätigte Ausbauplan bezahlt normale Aufträge; ein frei werdendes begrenztes Bauteam übernimmt automatisch die nächste Baustelle. Bestände, Anlieferung, Bauarbeit und manuelle Eingriffe bleiben wirkungsvoll.

**Als Update installieren, vorher nicht deinstallieren und keine App-Daten löschen.** Paket, Testsignatur, Speicherpfad und Schema 1 bleiben gleich; Versionscode 1900. Oben rechts steht **STADTGEFÜHL / 19**. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Einzige Android-Berechtigung ist `android.permission.VIBRATE` für optionale, anfangs ausgeschaltete Vibration. Reale Geräteinstallation, Touch, Vibration und Leistung der neuen Version wurden hier nicht auf Hardware geprüft.

18.518 Headless- und 183 Desktop-OpenGL-Prüfungen bestanden. APK-Quellstand `81e784afb4c28fda17a315ad3287a7d061225930`. Die passende Quell-ZIP enthält 239 einzeln gegen Git geprüfte Dateien. APK: 58,363,391 Bytes, SHA256 `6ae401c2656db11618360565d25661983aa19947393d30954319ee7bb2372c68`. Quell-ZIP: 12,099,048 Bytes, SHA256 `9cbda93ae25d2073babc5640ef73c4363081eb4a9d55ad37252dee1ffc4674b8`. Signatur und Paketdaten in `.apk.json`, Prüfsummen in `SHA256SUMS.txt`.

Auch in einer unabhängigen frischen GitHub-Kopie bestehen alle 18.518 Headless- und 183 Desktop-OpenGL-Prüfungen. APK, Quellarchiv und alle sieben Vorschauen wurden vom festen Versionstag vollständig per HTTPS zurückgeladen und mit beiden Kopien verglichen. [Download-Prüfbericht](../docs/download-verification-19.json).

## Historischer Stand 0.18

# Timber Loot Tycoon 0.18 — Baulogistik

**[Android-Update 0.18 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.18.0-logistics/releases/Timber-Loot-Tycoon-v0.18-test.apk)**

**[Passendes Godot-Quellprojekt 0.18 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.18.0-logistics/releases/Timber-Loot-Tycoon-v0.18-source.zip)**

Behebt wartende Baustellen bei aktiver Holzlinie: LKWs laden benötigte Bretter direkt am Sägewerk, fertige Möbel am Möbelwerk und Bausteine/Kies am Steinwerk. Neue und schon angefangene alte Materialbaustellen bestellen automatisch ab Unternehmenslevel 4. Keine manuelle Entnahme aus der Holzlinie und keine zusätzliche Level-10-Freischaltung nötig. Bestände werden beim Beladen entnommen und erst beim tatsächlichen Entladen an der Baustelle verbucht.

Ein Ladefehler mit als Fließkommazahlen gespeicherten Gebäudereferenzen konnte die alte Produktion zusätzlich zur Holzlinie laufen lassen. Diese doppelte Zuordnung ist korrigiert. Eingangs- und Ausgangsware besitzen feste getrennte Materialanzeigen; leere Rückfahrten sind ausdrücklich markiert. Das Baustellenmenü zeigt tatsächlich ankommende Mengen und Lieferursprünge. Unterschiedliche Lieferbereiche teilen sich auch bei gleicher numerischer ID kein Fahrzeugmodell.

**Als Update installieren. Vorher nicht deinstallieren und keine App-Daten löschen.** Paket, Testsignatur und Speicherformat 1 bleiben gleich; Versionscode 1800. Oben rechts steht **BAULOGISTIK / 18**. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0, keine Berechtigungen. Geräteinstallation und Leistung der neuen Version wurden hier nicht auf Hardware geprüft.

17.771 Headless- und 138 Desktop-OpenGL-Prüfungen bestanden. APK-Quellstand `7ea1dfd7643fe95228d0d696d14ff3cb3c149fd7`. Die passende Quell-ZIP enthält 210 einzeln gegen Git geprüfte Dateien; Release-Dateien sind aus ihr ausgeschlossen. APK: 58,300,624 Bytes, SHA256 `279d5dcadd02f56b53c9b93ac2304fd743765fa3f348aa70444eed9b86c859a8`. Quell-ZIP: 10,537,974 Bytes, SHA256 `3313f02c382d64e3a853b0c8333ac6d2017d773e0d54555280039e5939fa57fd`. Signatur und Paketdaten in `.apk.json`, Prüfsummen in `SHA256SUMS.txt`.

Auch in einer unabhängigen frischen GitHub-Kopie bestehen alle 17.771 Headless- und 138 Desktop-OpenGL-Prüfungen. APK, Quellarchiv und beide Vorschauen wurden vom festen Versionstag vollständig per HTTPS zurückgeladen und mit beiden Kopien verglichen. [Download-Prüfbericht](../docs/download-verification-18.json).

## Historischer Stand 0.17

# Timber Loot Tycoon 0.17 — Stein & Holz

**[Android-Update 0.17 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.17.0-stone/releases/Timber-Loot-Tycoon-v0.17-test.apk)**

**[Passendes Godot-Quellprojekt 0.17 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.17.0-stone/releases/Timber-Loot-Tycoon-v0.17-source.zip)**

Ab Unternehmenslevel 5: **Steinbruch → Muldenkipper → Steinwerk → Bausteine oder Kies → LKW-Lieferung ins Lager → Fundament und Betriebsausbau**. Bau zuerst Steinbruch und Steinwerk; ihre ersten Baustellen benötigen noch keine eigenen Steinprodukte. Die gesamte Branche bleibt neben deinem bisherigen Holzgeschäft erhalten.

Bagger lösen tatsächliches Gestein aus begrenzten Vorkommen, bewegen die geladene Schaufel und entladen in eine Abholmulde. Steinwerke besitzen auswählbare Rezepte und eigene Vorräte. Volle Lager und fehlende Rohstoffe stoppen die passenden Vorgänge. Fahrer bringen Material über echte Straßen; Ware gehört erst nach Entladung zum Ziel. Holz, Stein und Baustellen teilen die gekaufte Flotte. Selbst ein einzelner LKW kann beide Branchen abwechselnd bedienen.

Unter **Bauen → Steinbruch & Baustoffe** oder **Mehr → Steinbruch & Baustoffe**: Standorte errichten, Produkt auswählen, Vorkommen erschließen und Betriebe bis Stufe 10 ausbauen. Bausteine und Kies werden für größere Ausbauten verwendet; ein Notmaterialhändler verhindert Sackgassen. Die Bauvorschau zeigt die konkrete spätere Materialrechnung vor dem Bezahlen. Stadtbaustellen ab Level 4 lassen sich auch starten, bevor ihr Material per LKW ankommt.

**Als Update installieren, vorher nicht deinstallieren und keine App-Daten löschen.** Gleiches Paket und gleicher Testschlüssel wie 0.16, Schema 1, Versionscode 1700. Oben rechts steht **STEIN & HOLZ / 17**. Android 7.0+, ARM64/ARMv7 und OpenGL ES 3.0; rund 58 MB, keine Berechtigungen. Der neue Android-Geräte- und Leistungstest steht noch aus.

17.337 Headless- und 108 Desktop-OpenGL-Prüfungen bestanden. Auch eine frische GitHub-Kopie besteht die gesamte Headless-Suite. APK-Quellstand `662573b23cb9b3781b2f07085a314161070c4cb8`; das passende Archiv enthält 203 einzeln gegen Git geprüfte Dateien. Die Rezept-/Material-JSON ist im APK ausdrücklich enthalten und geprüft. Paketdaten in `.apk.json`, Prüfsummen in `SHA256SUMS.txt`.

Die weiteren Sand-, Metall- und Betonketten sowie vollständige Fahrzeugidentitäten und Kollisionsverkehr bleiben offen. Der [Industrie-Masterplan](../docs/INDUSTRY-ROADMAP.md) beschreibt den tatsächlichen Stand.

Auch alle 108 OpenGL-Prüfungen wurden in der frischen GitHub-Kopie bestanden. Die APK, das Quellarchiv und alle vier neuen Vorschauen wurden über die feste Version vollständig per HTTPS heruntergeladen und mit beiden Projektkopien verglichen. [Download-Prüfbericht](../docs/download-verification-17.json).

## Historischer Stand 0.16

# Timber Loot Tycoon 0.16 — Stadtverkehr

**[Android-Update 0.16 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.16.0-traffic/releases/Timber-Loot-Tycoon-v0.16-test.apk)**

**[Passendes Quellprojekt 0.16 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.16.0-traffic/releases/Timber-Loot-Tycoon-v0.16-source.zip)**

Förderstrecken zwischen den Gebäuden sind entfernt. Holz, Bretter, Möbel und Baumaterial werden über Straßen gefahren; alle drei Kettenstrecken und Baustellen teilen die gekaufte Flotte. Höhere Fahrzeugstufen zeigen Gelenk-Auflieger beziehungsweise Tiefbett mit tatsächlicher Ladung und leerer Rückfahrt. Alte Bandladungen werden ohne Materialverlust übernommen.

Polizei, Feuerwehr, Krankenwagen, Taxis mit Fahrgästen und gespeicherte Bewohnerwege beleben die Stadt. Neue Polizeiwache und Taxizentrale sind frei platzierbar. Unter **Mehr → Stadtleben & Fahrzeuge** Fahrten anfordern, eigene Standorte bauen und die Stadtkasse abholen. Einnahmen entstehen erst bei erfülltem Auftrag. Dienstfahrzeuge kommen bis zum Bau eigener Standorte von der westlichen Zufahrt.

Im Baukatalog und anderen Listen direkt über Karten und Schaltflächen mit dem Finger wischen. Wischen löst keinen Kauf aus; kurze Tipps funktionieren weiterhin. Nachlauf, abgebrochene Gesten und kleine Hochformatbildschirme wurden geprüft.

**Als Update installieren, nicht vorher deinstallieren und keine App-Daten löschen.** Gleiches Paket, gleicher Testschlüssel, Schema-1-Spielstand; Versionscode 1600. Oben rechts steht **STADTVERKEHR / 16**. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0; rund 58 MB, keine Berechtigungen.

12.461 automatisierte Headless- und 81 Desktop-OpenGL-Prüfungen bestanden. APK-Quellstand `c8c9e032f643d965e432773af4b6d334c62d3ed1`; das passende Quellarchiv enthält 177 einzeln gegen Git geprüfte Dateien. Paketdaten in `.apk.json`, Prüfsummen in `SHA256SUMS.txt`. Die neue Version wurde noch nicht auf echter Android-Hardware geprüft. Die offenen größeren Industriephasen stehen im [Industrie-Masterplan](../docs/INDUSTRY-ROADMAP.md).

Auch die unabhängige frische GitHub-Kopie hat alle 12.461 Headless- und 81 OpenGL-Prüfungen bestanden. APK, Quellarchiv und vier Vorschauen wurden über die oben verlinkte feste Version vollständig per HTTPS heruntergeladen und mit beiden Projektkopien verglichen. [Download-Prüfbericht](../docs/download-verification-16.json).

## Historischer Stand 0.15

# Timber Loot Tycoon 0.15 — Lieferwerk

**[Android-Update 0.15 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.15.0-delivery/releases/Timber-Loot-Tycoon-v0.15-test.apk)**

**[Passendes Quellprojekt 0.15 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.15.0-delivery/releases/Timber-Loot-Tycoon-v0.15-source.zip)**

Erster spielbarer Abschnitt des Industrie-Masterplans: echte lokale Lieferkette Holz → Bretter → Möbel → Laden, Materialzähler über Gebäuden, Ladenfristen mit Bonus und reduzierter Auszahlung bei Verspätung. Unter **Aufträge → Lieferkette** mit vorhandener Möbelfabrik eröffnen.

Neue Betriebe und Upgrades kosten anfangs nur Münzen. Ab Unternehmenslevel 4 benötigen Baustellen tatsächlich angelieferte Materialien, sieben Bauphasen und zugewiesene Bauarbeiter. Muttern und Schrauben gibt es im Materialdepot für Spielmünzen. Lieferfahrzeuge nehmen echte Ladung auf, fahren auf Straßen zur Baustelle, entladen und kehren leer zurück. Pause, Priorität, Personal, Baukamera und sichere Abbrüche sind verbunden. Ab Level 10 lässt sich die globale Baustellen-Automatik aktivieren.

Neue Stein-, Metall- und Betonketten sowie Bergbaumaschinen sind noch offen; der vollständige tatsächliche Stand steht im [Industrie-Masterplan](../docs/INDUSTRY-ROADMAP.md). Weitere vorhandene Holz-/Stadtbetriebe behalten ihre bisherige Wirtschaft.

**Als Update installieren, nicht vorher deinstallieren und keine App-Daten löschen.** Gleiches Paket, gleicher Testschlüssel, Schema-1-Spielstand; Versionscode 1500. Danach steht oben rechts **LIEFERWERK / 15**. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0; rund 58 MB, keine Berechtigungen. Handy-Installation, Touch und reale Leistung dieser Version bleiben zu prüfen.

8.374 Headless-Prüfungen und erster-Haus-Verlauf bestanden, ebenso 54 lokale OpenGL-Prüfungen. Auch die unabhängige frische GitHub-Kopie hat alle 8.374 Headless- und 54 OpenGL-Prüfungen bestanden. Quellstand `7ca882361dc542394440f2b911725d8e4e78128f`, passendes Archiv mit 160 einzeln gegen Git geprüften Dateien. APK-Paketdaten in `.apk.json`, Prüfsummen in `SHA256SUMS.txt`.

## Historischer Stand 0.14

# Timber Loot Tycoon 0.14 — Ein lebendiges Waldtal

**[Android-Update 0.14 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.14.0-valley/releases/Timber-Loot-Tycoon-v0.14-test.apk)**

**[Passendes Quellprojekt 0.14 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.14.0-valley/releases/Timber-Loot-Tycoon-v0.14-source.zip)**

Neu: zusammenhängendes Gelände mit weichen Biomfarben, unregelmäßigen Waldgruppen, zusätzlichen Bäumen und Wiesen, Hügeln, einem Bach, See, Holzbrücke, Picknickplatz und Aussichtsturm. Straßenränder sind bepflanzt; unbebaute Flächen tragen keine großen Farbplatten mehr. Ein Kamerafehler, der beim Herauszoomen den Vordergrund abschnitt, ist behoben. Abendlicht und Nebel lassen den Ort besser erkennen.

Gebäude, Spielstand, eigene Straßen, Buslinien und Wirtschaft bleiben erhalten. Dekoration weicht automatisch vor Bauplätzen, Straßen und Förderstrecken zurück. Akkumodus reduziert die neue Vegetation. Naturkulisse und Fußgängerbrücke sind keine zusätzlichen Produktions- oder Verkehrssysteme.

Als Update installieren: **nicht vorher deinstallieren und keine App-Daten löschen.** Paket, Testschlüssel und Schema-1-Speicherdatei bleiben gleich; Versionscode 1400. Oben rechts steht danach **WALDTAL / 14**. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0, rund 58 MB, keine Berechtigungen.

4.856 Headless-Prüfungen und erster-Haus-Verlauf bestanden, auch in einer frischen GitHub-Kopie. Auch die 32 OpenGL-Prüfungen für UI und Landschaft bestehen in der frischen Kopie. Die 0.13 wurde vom Nutzer als Screenshot der laufenden App gezeigt; echte Installation, Touch und Leistung der neuen 0.14 bleiben zu testen.

APK-Quellstand: `8fdd1a6bd54cbfffe312b018c1785aa12293ddda`. Passendes Archiv mit 126 einzeln gegen Git geprüften Quelldateien. Mit Godot 4.6.3 öffnen. Prüfsummen in `SHA256SUMS.txt`, Paketdaten in `.apk.json`.

## Historischer Stand 0.13

# Timber Loot Tycoon 0.13 — Die erste Kleinstadt

**[Android-Update 0.13 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.13.0-town/releases/Timber-Loot-Tycoon-v0.13-test.apk)**

**[Passendes Quellprojekt 0.13 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.13.0-town/releases/Timber-Loot-Tycoon-v0.13-source.zip)**

Neu: größere zusammenhängende Landschaft, Ost-/Westviertel mit bis zu 36 Hausgrundstücken und 40 Betrieben, frei gezeichnete Asphaltstraßen und Fußwege, zwölf eigene Stadtgebäude inklusive Landhaus und Nachtclub, Mietkonten zum Antippen und optionaler Hausverwalter, Haltestellen und konfigurierbare Buslinien mit sichtbaren Fahrzeugen, Fahrplan und Offline-Einnahmen. Gekaufte Forstmaschinen und Transportstufen sind jetzt sichtbar. Neue Meilensteine begleiten den Aufbau.

Unter Bauen → Straßen & Wege Strecken zeichnen. Im Busmenü mindestens zwei Haltestellen an Straßen setzen, in Fahrreihenfolge wählen und einen Bus kaufen. Ab vier Bewohnern fährt die Linie. Stadt → Regionen & Projekte erschließt nach drei Regionen und 20 Bewohnern weitere Viertel.

Als Update über die vorhandene App installieren. **Nicht deinstallieren und keine App-Daten löschen.** Gleiches Paket, Testschlüssel und Schema-1-Spielstand; Versionscode 1300. Oben rechts steht danach **KLEINSTADT / 13**. Alte Profile behalten automatische Miete kostenlos. Bei neuen Profilen Miete am Haus oder gesammelt in der Stadt abholen; die Hausverwaltung automatisiert das später.

Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0, rund 58 MB, keine Android-Berechtigungen. 4.726 Headless-Prüfungen, erster-Haus-Verlauf und 23 OpenGL-Prüfungen bestanden, auch in einer frischen GitHub-Wiederherstellung. Echte Handy-Installation, Touch und Leistung der neuen 0.13 bleiben zu testen. Busse verwenden ein berechnetes Straßennetz mit vereinfachter Nachfrage, keine vollständige Kollisionssimulation.

APK-Quellstand: `7bc708e2e5d2e37865570c3d6007bf8c883831a4`. Passendes Archiv mit 112 einzeln gegen Git geprüften Quelldateien. Mit Godot 4.6.3 öffnen. Prüfsummen stehen in `SHA256SUMS.txt`, Paketdaten in `.apk.json`.

## Historischer Stand 0.12

# Timber Loot Tycoon 0.12 — Waldleben

**[Android-Update 0.12 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.12.0-cozy/releases/Timber-Loot-Tycoon-v0.12-test.apk)**

**[Passendes Quellprojekt 0.12 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.12.0-cozy/releases/Timber-Loot-Tycoon-v0.12-source.zip)**

Neu: Hütten mit Pausenplatz, Bank, Tisch, Blumen, Laterne und Sonnenschirm; Mitarbeiter mit Kaffeepause; gegenseitiges Winken; Bewohner im eigenen Vorgarten. Echte Fertigstellungen bekommen einen kurzen Eröffnungsjubel mit Konfetti und sanftem Klang. Alle Szenen bleiben rein optisch und verändern Produktion oder Preise nicht.

Neue Alltagsszenen lassen sich unter Mehr → Einstellungen abschalten. Akkumodus reduziert die Effekte. Benno bleibt unabhängig einstellbar. Keine Pflichtdialoge und keine zusätzlichen Aufgaben für die Pausenplätze.

Als Update über die vorhandene App installieren. Nicht deinstallieren und keine App-Daten löschen. Unverändertes Paket, Testschlüssel und Speicherformat; Versionscode 1200. Danach steht oben rechts **WALDLEBEN / 12**. Android 7.0+, ARM64/ARMv7 und OpenGL ES 3.0, rund 58 MB; keine Android-Berechtigungen.

4.506 Headless-Prüfungen plus erster-Haus-Verlauf und 23 OpenGL-Prüfungen bestanden, auch nach Wiederherstellung aus GitHub. Die vorherige Version 0.11 läuft laut Nutzer auf seinem Handy; ein echter Gerätetest der neuen 0.12 steht aus.

APK-Quellstand: `6f083f473916141bcd5ae917641e463284a62c43`. 91 Quelldateien im passenden Archiv einzeln gegen Git geprüft. Prüfsummen: `SHA256SUMS.txt`, Paketdaten: `.apk.json`. Entpacken und mit Godot 4.6.3 öffnen.

## Historischer Stand 0.11

# Timber Loot Tycoon 0.11 — Benno im Wald

**[Android-Update 0.11 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.11.0-benno/releases/Timber-Loot-Tycoon-v0.11-test.apk)**

**[Passendes Quellprojekt 0.11 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.11.0-benno/releases/Timber-Loot-Tycoon-v0.11-source.zip)**

Benno ist da: ein eigener kleiner 3D-Biber mit Winken, Blinzeln und freundlichen Begrüßungen. Er freut sich über fertige Gebäude, Häuser, Upgrades, neue Regionen und besonderen Loot. Hinweise beziehen sich auf deinen wirklichen Spielstand. Die neue Willkommensgrafik verwendet die vom Nutzer bereitgestellte Biber-Vorlage.

Sprechblasen schließen oder Benno antippen zum Plaudern. In Menüs und beim Platzieren macht er Platz. Abschalten unter Mehr → Einstellungen; die Einstellung bleibt auch beim Prestige erhalten. Keine tägliche Verluststrafe, kein Pflichtdialog und keine gekauften Begrüßungen.

Als Update über die vorhandene App installieren; nicht vorher deinstallieren oder App-Daten löschen. Gleicher Testschlüssel, Paket und Speicherdatei, Versionscode 1100. Danach steht oben rechts **BENNO / 11**. Android 7.0+, ARM64/ARMv7 und OpenGL ES 3.0, etwa 58 MB, keine Android-Berechtigungen.

4.476 Headless-Prüfungen plus frischer Verlauf bis zum ersten Haus sowie 23 OpenGL-Prüfungen bestanden. Echter Handy-/Resume-/Leistungstest der APK bleibt offen. APK-Quellstand: `66aab5d885a18d5446b4450fa6c9fc05724a7c5e`. Das passende Quellarchiv enthält 82 gegen Git geprüfte Dateien. Prüfsummen in `SHA256SUMS.txt`, Paketbericht im `.apk.json`.

## Historischer Stand 0.10

# Timber Loot Tycoon 0.10 — Sculpted World

**[Android-Update 0.10 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.10.0-sculpt/releases/Timber-Loot-Tycoon-v0.10-test.apk)**

**[Passendes Quellprojekt 0.10 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.10.0-sculpt/releases/Timber-Loot-Tycoon-v0.10-source.zip)**

Als Update über die vorhandene App installieren. Nicht deinstallieren und keine App-Daten löschen. Gleiches Paket, gleicher Testsignaturschlüssel und gleicher Spielstand; Versionscode 1000. Oben rechts steht nach dem Update **SCULPT / 10**.

Neu: plastische Tasten und Baukarten mit Lichtkanten und Druckzustand, sieben echte 3D-Symbole, räumliche Weltschatten im Standardmodus, lackierte Maschinen und Metall-/Holzoberflächen. Der Akkumodus schaltet Weltschatten ab. Es gibt kein künstliches APK-Größenlimit.

4.453 Headless-Prüfungen plus erster-Haus-Spielverlauf und 19 OpenGL-Prüfungen. Android-Paket, Signaturgleichheit mit 0.9 und 16-KB-ZIP-Ausrichtung geprüft. Reale Android-Leistung und Update-Installation stehen weiterhin aus.

APK-Quellstand: `54a6e86abaea53ac6a829e7a6c6598129320bc71`. Das Quellarchiv wurde dateiweise gegen diesen Git-Stand geprüft. Öffnen mit Godot 4.6.3. Prüfsummen in `SHA256SUMS.txt`, Paketbericht neben der APK. Android 7.0+, ARM64/ARMv7 und OpenGL ES 3.0 erforderlich. Keine Android-Berechtigungen.

## Historischer Stand 0.9

# Timber Loot Tycoon 0.9 — Open Workshop

**[Android-Update 0.9 direkt herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.9.0-workshop/releases/Timber-Loot-Tycoon-v0.9-test.apk)**

**[Passendes Quellprojekt 0.9 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/v0.9.0-workshop/releases/Timber-Loot-Tycoon-v0.9-source.zip)**

Als Update über die vorhandene 0.7/0.8-App installieren; nicht vorher deinstallieren und keine App-Daten löschen. Paket, Testsignatur und Schema-1-Speicherdatei bleiben gleich, Versionscode steigt auf 900. Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0, etwa 54 MiB, keine Berechtigungen.

Neu: offene Produktionsplätze, sichtbare Stammzufuhr und Werkstücke, Sägeblatt und Werkzeugköpfe mit echtem Produktionsstatus, Helm-/Warnwesten-Arbeiter an Maschinen, Holz- und Bretterstapel sowie kompakte mobile Navigation mit eigenen Symbolen. Alle Wirtschaftssysteme und freies Platzieren aus 0.8 bleiben enthalten.

4.451 automatisierte Prüfungen und der frische Verlauf bis zum ersten Haus bestanden, auch nach erneutem Klonen von GitHub. Signaturgleichheit mit der bisherigen APK sowie 16-KB-ZIP-Ausrichtung und Android-Paket geprüft. Ein echter Handy-Start und Leistungstest dieser Version steht aus.

APK-Quellstand: `8a9f0eb7f1486d1d5b1f24616f057d718c3e62be`. Prüfsummen stehen in `SHA256SUMS.txt`, Paketdaten im `.apk.json`.

## Historischer Stand 0.8

# Timber Loot Tycoon 0.8 — Living Industry

**[Android-Update 0.8 direkt herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/main/releases/Timber-Loot-Tycoon-v0.8-test.apk)**

**[Passendes Quellprojekt 0.8 herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/main/releases/Timber-Loot-Tycoon-v0.8-source.zip)**

Als Update über die bestehende 0.7-App installieren, nicht deinstallieren und keine App-Daten löschen. Gleiche Paketkennung, gleicher Testsignaturschlüssel, höhere Versionsnummer (800), gleiche Speicherdatei. Bestehende Spielstände behalten ihren Fortschritt.

Neu: platzieren/drehen/verschieben, farbiger Baukatalog, helle Gebäudekarten, geroutete Förderbrücken, Spänebox mit manuellem Verkauf, Willkommen und Einführung. Die Blockade der Sägewerke durch volle Sägespäne-Behälter ist behoben. Standardmäßig wird nur neuer Überlauf kompostiert; gespeicherte Sägespäne bleiben zum Verkaufen und Weiterverarbeiten erhalten. Überlauf-Autoverkauf ist optional.

220 Regel-, 4.135 Szenen-/Geometrie- und 56 Platzierungs-/Einführungsprüfungen bestanden; frischer Spielverlauf bis zum ersten Haus geprüft. Installation/Touch auf echter Hardware bleibt für diese neue APK offen. Signaturvergleich mit 0.7 ist bestanden.

## Älterer gesicherter Stand 0.7

**[Android-APK direkt herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/main/releases/Timber-Loot-Tycoon-v0.7-test.apk)**

**[Quellprojekt-ZIP herunterladen](https://raw.githubusercontent.com/Whiskymitschuss/Project-Encyclopedia/main/releases/Timber-Loot-Tycoon-v0.7-source.zip)**

Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. APK herunterladen, im Downloadordner öffnen, bei Bedarf „Installation aus dieser Quelle“ erlauben und installieren. App: **Timber Loot**. Keine Berechtigungen, keine Echtgeldkäufe. Der Code ist eine neue Entwicklungsfassung, kein wiederhergestelltes Original und noch keine Store-Version.

Die APK ist mit dem lokalen Testschlüssel signiert. Signatur und Paket wurden geprüft; Installation auf echter Android-Hardware bleibt ungetestet. Der zugehörige Quell-Commit steht im `.apk.json`-Bericht. `SHA256SUMS.txt` enthält die Prüfsummen beider Downloads.

Die Quell-ZIP enthält das Godot-Projekt ohne Build-Caches, private Schlüssel oder APK. Entpacken und `project.godot` in Godot 4.6.3 öffnen. Die vollständige Commit-Historie liegt im Git-Repository; weitere Quellarchive und Git-Bundles entstehen mit `scripts/backup.py`.
