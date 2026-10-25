# Laufzeit und Gerätemessung · 0.28.22-alpha.1

Auslöser: Nutzer-Screenshot auf SM-S721B mit 13 Betrieben / einem Haus,
6,2 FPS, P95 419,4 ms, Weltaufbau 14.259 ms und automatisch reduzierter
3D-Auflösung (76 %). Der Screenshot entstand während einer noch laufenden
Kamerarunde (22 s verbleibend). Er zeigt rollende Sitzungswerte, kein fertiges
30-Sekunden-Ergebnis; die installierte Versionsnummer ist darauf nicht sichtbar.

## Änderungen

- Routen behalten vorberechnete Positionen und kumulierte Streckenlängen;
  binäre Abschnittssuche statt wiederholter Vektorumwandlung und Vermessung
  jedes Kontrollpunkts pro Bild. Maximal 512 abgeleitete Routen, FIFO-Verdrängung,
  Vergleich der Originalpunkte zum Schutz vor Änderungen und Hashkollisionen.
  Gespeicherte Wege, Kurven, Ladungen und Fahrzeiten bleiben unverändert.
- Waldinstanzen schreiben Transformationen nur bei geänderter Wachstumsgröße,
  Baumzustand oder Platzierungsfreigabe. Wachstum, Fällung und Wiederherstellung
  nach einem Weltumbau bleiben sichtbar; keine Ausdünnung der Forste.
- Betriebshinweise berechnen Zustände auf ihrem bestehenden 0,5-s-Takt,
  prüfen Entfernung vorher und ersparen verdeckten Menüs die Zustandsermittlung.
  Die Bildschirmposition der Hinweise bleibt pro Bild beweglich.
- Die sichere Lack-Zusammenfassung aus .21 erreicht auch Landschaftsobjekte,
  Straßenumfeld und Haltestellen; Leuchten, Texturen und bewegliche Knoten
  behalten ihre eigenen Materialien und Anschlüsse.
- Die Kamerarunde zeigt die installierte Version, tatsächliche Zeichenaufrufe,
  Engine-Prozesszeit und CPU-Zeit für Welt, Wald, Transport, Stadtverkehr,
  Betriebshinweise, HUD und Spielverwaltung/Wirtschaftstakt. Die Aufzeichnung
  läuft nur während der Runde und speichert maximal 180 Samples je Bereich.
  Unterbereiche überschneiden sich; Zeiten dürfen nicht addiert werden.
  Es wird nichts automatisch übertragen. Die Stopptaste verdeckt keine Menüs.

## Nachweis und Grenzen

[CPU-Messung](alpha1-runtime/cpu-benchmark.json): echte .21-APK-Dateien gegen
Quellstand, erzeugte Testfirma, 780 simulierte Sekunden, dann stehende Wirtschaft,
240 direkte Aufrufe je Bereich. Desktop, kein Handy:

| Bereich | .21 | .22 Quellstand |
|---|---:|---:|
| Betriebshinweise | 0,597 ms | 0,096 ms |
| Walddarstellung | 0,175 ms | 0,136 ms |
| Transportdarstellung | 0,494 ms | 0,442 ms |
| Einzelne Abfrage einer langen 160-Punkte-Route | 0,735 ms | 0,0075 ms |

Die lange Route ist ein synthetischer Belastungsfall; ihr Faktor gilt nicht für
alle LKW oder die gesamte Bildrate. Der komplette Firmenzustand bleibt gleich.

[Gerenderter Vergleich](alpha1-runtime/frames-benchmark.json): dieselbe echte
Hauptwelt und Einstellungen wie zuvor, 540×960, OpenGL/Mesa llvmpipe.
Zeichenaufrufe in Fabrikansicht 1.336 → 1.317, Übersicht 1.443 → 1.402.
Die separat gerenderte Gebäudegalerie ist in diesem Lauf RGB-identisch.
Die Bildzeiten verbessern sich nicht überall. Der einmalige Weltaufbau beträgt
in diesem Quellvergleich 2,43 → 2,72 s; zusätzliche Zusammenfassung kostet Zeit.

**Die 6,2 FPS und die 14,3 s Ladezeit auf dem Handy sind damit noch nicht als
behoben nachgewiesen.** Das Update beseitigt belegte Wiederholungsarbeit und
liefert die fehlende Unterscheidung zwischen Skript- und Darstellungsaufwand.
Kein physischer Android-Lauf, keine GPU-Zeitmessung, keine Temperaturmessung.
Keine Änderungen an Lagergrenzen, Erträgen, Nachwachsdauer oder Spielständen.

Reproduktion mit isolierten Profilen:

```bash
bash scripts/test.sh
bash scripts/test_visual.sh VisualPerformance2822 VisualPerformance2821 VisualPerformance2811 VisualActiveForest2819
python3 scripts/benchmark_frames.py --baseline-apk releases/Timber-Loot-Tycoon-v0.28.21-alpha.1.apk --output /tmp/timber2822-frames/results.json
XDG_DATA_HOME=/tmp/timber2822-profile bash scripts/godot.sh --headless --script res://Tests/RuntimeProfile2822.gd
```

Nächster Gerätetest: .22 als Update installieren, Version im Leistungsmenü prüfen,
Kamerarunde im Standardmodus vollständig beenden. Danach Ergebnis und Messdetails
senden. Dieselbe Runde im Akkumodus hilft, Darstellungsdruck weiter einzugrenzen.
Ein früher Screenshot der laufenden Sitzungsanzeige ersetzt das Endergebnis nicht.

## Auslieferung

Die signierte APK und Quell-ZIP liegen im unveränderlichen Tag
`v0.28.22-alpha.1-android`. Der vorher angelegte Tag `v0.28.22-alpha.1`
enthält die Paketberichte, aber wegen der allgemeinen APK-Ausschlussregel noch
keine APK. Er wurde nicht überschrieben. Der Android-Tag ergänzt exakt die
geprüfte Datei; Versionsname 0.28.22-alpha.1 und Android-Code 3017 bleiben gleich.
[Prüfung der vollständigen HTTPS-Downloads](download-verification-alpha2822.json).
