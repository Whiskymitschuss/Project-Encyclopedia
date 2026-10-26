# Lange Einzelhänger · 0.28.27-alpha.1

Android-Code 3022. Ausgangsstand: `a8981cf83be77118fb7bdacaadc2395b312be75e`
(0.28.26). Anlass: weiterhin gelegentliche Hänger von fünf bis zehn Sekunden.
Auf einem physischen Android-Gerät wurde die Ursache noch nicht nachgewiesen.

## Befund und Änderung

Automatisches Speichern alle 20 Sekunden und zahlreiche Bau-/Menüaktionen
liefen synchron auf dem Hauptthread: JSON erzeugen, schreiben, flushen, erneut
lesen und prüfen, vorherigen gültigen Stand sichern und temporäre Datei ersetzen.
Ein langsamer Dateizugriff konnte damit das ganze Bild blockieren. Die bestehenden
Skriptmessungen beweisen nicht, dass dieser Pfad die gemeldeten Handy-Hänger
verursacht. Die bislang unbekannte Wartezeit kann auch außerhalb gemessener
Skripte liegen.

Routine-Speicherungen laufen jetzt mit einer eigenen unveränderlichen Kopie der
Firma in einem Dateiarbeiter. Dieser verwendet nur RefCounted-Objekte und
Datei-/JSON-APIs, keine Szenenknoten, Signale oder veränderlichen Wirtschaftsdaten.
Ein aktiver Auftrag und höchstens der neueste wartende Auftrag begrenzen die
Warteschlange. Ergebnisse kommen nach Thread-Ende auf den Hauptthread zurück;
die Oberfläche meldet Erfolg erst nach einem tatsächlich geprüften Dateiaustausch.

Dateipfad, Schema, Vollpräzision, Validierung, rotierende Sicherung und dauerhafte
0.29-Rollback-Sicherung bleiben erhalten. Derselbe bestehende Spielstand wird
weiterverwendet. Der bisherige gültige Stand wird nur einmal pro Transaktion
geparst. Fehler überschreiben keine gültige Datei. Ein explizites dauerhaftes
Speichern wartet auf den aktiven Schreiber und verwirft ältere wartende Kopien.
Hintergrundwechsel, Beenden und Rückkehr zum Titel bleiben dauerhaft gesichert;
hier kann langsamer Speicher weiterhin Wartezeit verursachen. Der Hintergrund-
auftrag selbst ersetzt keine Betriebssystemgarantie bei erzwungenem Prozessabbruch.

Das Kopieren/Validieren einer Momentaufnahme bleibt auf dem Hauptthread und
wird separat als „Speicherauftrag“ gemessen. Die Dateioperationen laufen im
Hintergrund. Bei vielen Änderungen entstehen höchstens zwei zu speichernde Momentaufnahmen in der
Auftragsfolge. Bestehende deterministische Headless-Spieltests behalten ihre
dauerhafte Speichersemantik; eigene Threadtests und Grafiktests prüfen die neue
asynchrone Strecke tatsächlich.

## Messung und Nachweis

Kontrollierte Fehler-/Verzögerungstests auf Linux/Godot 4.6.3, isolierte Profile:

- Ein absichtlich um 350 ms verzögerter Dateischreiber blockiert den aufrufenden
  Thread nicht. Mehrere Aufträge werden zusammengefasst, spätere Änderungen an
  der Originalfirma gelangen nicht in die bereits übergebene Momentaufnahme.
- Hauptwelt mit vorhandener Fabrikfirma, beweglicher Kamera und einer künstlich
  um eine Sekunde verzögerten Speicherung. Frames werden währenddessen wirklich
  gezeichnet. Manueller Menüknopf und reguläres 20-Sekunden-Autosave verwenden
  denselben Hintergrundpfad. Konkrete Zeiten und Prüfzahlen stehen im
  [maschinellen Bericht](hitches-2827/source-checks.json).
- Neueste Datei, vorherige Sicherung, injizierter Schreibfehler, anschließende
  Wiederaufnahme, ungültige Werte, Wiederherstellungssperre und dauerhafter
  Abschluss gegen ältere wartende Kopien geprüft.

Das sind kontrollierte Nachweise gegen eine bekannte Hauptthread-Blockierung,
keine neuen Samsung-FPS-Messungen und kein Beweis, dass alle Handy-Hänger
behoben sind. Rendering wurde dabei unter Linux mit Softwaregrafik ausgeführt.
Wirtschaft, Bestände, Waldwachstum, Transporte, Bauabläufe und vorhandene
vorbereitete 3D-Modelle werden nicht umgestaltet. Tageslicht bleibt dauerhaft an.

## Zuordnung des nächsten Hängers

Das Leistungsmenü zeigt „Letzte lange Hänger“ und den echten Status der
Hintergrundspeicherung. Eine rein lokale, begrenzte Liste hält die letzten zwölf
Bildlücken ab einer Sekunde fest. Dazu wird der längste erfasste Skriptabschnitt
des betreffenden Intervalls mit eigener Dauer angezeigt. Beispielsweise erklärt
60 ms Skriptzeit eine fünfsekündige Bildlücke nicht vollständig. Ohne passenden
Abschnitt bleibt die Ursache ausdrücklich nicht zugeordnet; der Bericht behauptet
keinen GPU-, Treiber- oder Speicherfehler. Kein Dateiprotokoll pro Frame, kein
Versand, keine Änderung des Spielstands durch diese Diagnose.

## Dateien und offene Arbeit

- `SaveSystem/SaveFiles.gd`, `SaveTask.gd`, `Store.gd`: isolierter Dateiarbeiter,
  begrenzte Auftragsfolge, gültiger Dateiaustausch und Ergebniszustellung.
- `Managers/Game.gd`, `UI/HUD.gd`, `CityUX.gd`, `JourneyUI.gd`: Routine-Aufträge;
  ausdrücklich dauerhafte Lebenszyklus-Speicherungen bleiben erhalten.
- `Managers/RuntimeStats.gd`, `UI/OperationsDesk.gd`: lokale Hängerzuordnung.
- `Tests/Hitches2827.gd`, `VisualHitches2827.gd` und Testrunner: echte konkurrierende
  Speicher-/Kameraabläufe, Reihenfolge und Fehlerpfade.
- Versionsdateien, Dokumentation und passende Android-Testpakete.

Weiter erforderlich: dieselbe Stadt auf dem SM-S721B spielen, bei erneutem
Hänger den neuen Abschnitt im Leistungsmenü prüfen. Native Android-/Windows-
Profilerläufe, Treiberwartezeiten und stabile 30 FPS bleiben offene Nachweise.
