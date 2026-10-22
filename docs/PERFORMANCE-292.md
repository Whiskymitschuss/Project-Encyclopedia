# Alpha 2 · schneller laden und App-Wechsel · 0.29.2

Anlass: Die Ladeanzeige funktioniert, aber sieben Stunden Abwesenheit benötigen
zu lange. Beim Minimieren blieb die Berechnung stehen, weil sie an den pausierten
Android-Renderloop gebunden war.

| Aufgabe | Änderung und Grund | Mehrwert für Spieler | Geschätzte Qualitätswirkung |
| --- | --- | --- | --- |
| Rechenzeit senken | Nahe Kreuzungen räumlich vorsortieren, Fahrzeugpositionen und Richtungen wiederverwenden. Statische Ziel-IDs einmal vorbereiten und Rathausstufe einmal pro Aktualisierung lesen. | Weniger Wartezeit nach längerer Pause und weniger Rechenarbeit im laufenden Spiel. | Sehr hoch |
| App-Wechsel ermöglichen | Eigener Thread mit abgetrennter Simulationskopie; Start sofort beim Laden, Fortschrittsübergabe über Mutex. | Berechnung benötigt keinen sichtbaren Spielframe mehr. | Sehr hoch |
| Firma schützen | Aktuelle Firma bleibt unverändert. Erst fertigen Worker verbinden, Ergebnis übernehmen und speichern. Abbruch wartet auf den Worker und verwirft seinen Teilstand. | Keine halbfertigen Stände, späten Fremdergebnisse oder doppelten Erträge. | Hoch |
| Übergänge absichern | Auch vor dem ersten Ladeframe starten; zusätzliche Hintergrundzeit separat nachrechnen. Aufgeschobenes Öffnen der Welt wartet auf das vollständige Ergebnis. | Frühes Minimieren und Wechsel während des Starts bleiben beherrschbar. | Hoch |
| Schließen verständlich machen | Ladebutton heißt „Spiel schließen“; Erklärung unterscheidet App-Wechsel und Beenden. | Der Spieler beendet den Rechenlauf nicht versehentlich über „Später weiterspielen“. | Mittel |

Der Worker benutzt die bestehenden Simulationsregeln. Kein Pauschalbonus, kein
Entfernen von Staus und kein Überspringen von Material-, Brand- oder Bauzuständen.
Die Hauptszene verarbeitet währenddessen keine Eingaben oder Wirtschaftsschritte.
Der Worker fasst weder Szenenknoten noch Spielerdateien an. Seine Simulationsnode
hängt außerhalb des Szenenbaums; Signale sind gesperrt. Erst nach Thread-Join greift
die Hauptszene wieder auf die geteilten Routencaches zu. Wenn kein Thread gestartet
werden kann, bleibt die bisherige Berechnung in kurzen Abschnitten verfügbar.

Android behält die Kontrolle über den gesamten Prozess. Ein eigener Thread ist
kein unbegrenzt laufender Android-Hintergrunddienst. Das System darf die App
anhalten oder beenden. Es werden keine neuen Berechtigungen, dauerhaften Dienste
oder Benachrichtigungen benötigt. Bei Beenden bleibt der letzte vollständige
Spielstand erhalten; beim erneuten Start wird von dort neu gerechnet.

## Nachweis

- Rechenprofil: Rund 80 % der ursprünglichen Teststadt-Zeit entfielen auf Verkehr.
- Reine Simulation: 3.600 Sekunden im Stadtfall von 5,110 auf 2,398 Sekunden,
  **2,13× schneller**; zehn vollständige Zwischenstände in zwei Fällen identisch.
  [CPU-Vergleich](alpha2-performance/cpu-benchmark.json).
- Vollständiger Ladevorgang: 20 Häuser, acht LKW, acht Stunden Offline-Zeit,
  Desktop-Godot 4.6.3, auf denselben CPU-Kern begrenzt, 60 FPS, headless.
  **83,887 auf 21,675 Sekunden**, **3,87× schneller**; abschließender Firmenstand
  besitzt denselben SHA256. [Ladevergleich](alpha2-performance/loading-benchmark.json).
- Referenzszenarien stammen aus der unveränderten 0.29.1-Simulation und werden als
  Regression mit fünf Zeitpunkten je Fall gegen die ganze Firma geprüft. Dazu
  kommen räumliche Kreuzungsprüfungen nach Straßenänderung und Wiederherstellung.
- Hintergrundtest blockiert absichtlich nur den Hauptloop und sendet die echte
  Pause-Benachrichtigung: Worker-Fortschritt läuft weiter, Originaldatei bleibt
  unverändert. Zusätzlich Grafiktest mit tatsächlicher 3D-Welt und Touch nach
  Abschluss. [Automatisierte Ergebnisse](alpha2-performance/automated-checks.json).

Die Zeitmessungen gelten für den beschriebenen Desktop-Test. Sie sind weder eine
Ladezeitgarantie noch ein bestätigter Android-Gerätetest. Paket, Testsignatur,
Speicherverzeichnis und Acht-Stunden-Limit bleiben erhalten. Als Update installieren.
