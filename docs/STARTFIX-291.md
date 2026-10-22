# Alpha 2 · Startfix 0.29.1

Anlass: Auf dem Handy bleibt nach dem Öffnen nur die dunkelgrüne Fläche sichtbar.
Im bisherigen Startablauf wird vor dem ersten Intro-Frame synchron bis zu acht
Stunden Offline-Fortschritt berechnet. Seit den umfangreicheren Verkehrsschritten
ist dies besonders teuer. Der konkrete Handyfehler lässt sich ohne Gerätelog
nicht abschließend zuordnen; die nachgewiesene Blockade im Startcode wird behoben.

| Aufgabe | Änderung und Grund | Mehrwert für Spieler | Geschätzte Qualitätswirkung |
| --- | --- | --- | --- |
| Start sichtbar machen | Natives Logo und rein zweidimensionale Ladeanzeige erscheinen vor der Offline-Berechnung. | Erkennbarer Start, Versionsnummer und laufender Fortschritt. | Hoch |
| Blockade beseitigen | Offline-Simulation in Abschnitten mit 8-ms-Zeitbudget und höchstens 120 Simulationsschritten pro Frame; zwei Frames Vorlauf. Ein einzelner Simulationsschritt kann das Zeitbudget überschreiten. | Die Anzeige bleibt bedienbar. „Später weiterspielen“ beendet sicher. | Sehr hoch |
| Hintergrundwechsel absichern | Android-Fortsetzung nutzt denselben Ablauf. Bereits berechnete Hintergrundzeit wird abgezogen; acht Stunden bleiben das Maximum. | Erträge werden genau einmal berücksichtigt. | Hoch |
| Firma erhalten | Während der Berechnung keine Teilstände speichern. Erst nach vollständiger Simulation speichern und die Welt einmal aktualisieren. | Abbruch, Schließen oder Suspendieren überschreiben die bisherige Speicherdatei nicht. | Sehr hoch |
| Testfehler vermeiden | Jede unabhängige Testsuite erhält ein eigenes temporäres Profil. | Tests berücksichtigen echte Offline-Starts, ohne fremde Teststände oder Spielerdateien anzufassen. | Mittel, indirekt |

Die vorhandene Firma wird durch das Update übernommen: gleiches Android-Paket,
gleiches Speicherverzeichnis und dasselbe Testzertifikat. Versioncode 2912 ist
höher als Alpha 2 (2902). Als Update installieren, vorher nicht deinstallieren.

Automatisierte Prüfung: [Ergebnisse](alpha2-startfix/automated-checks.json),
[Prüfprotokoll](VALIDATION.md), [Handy-Testplan](alpha2-startfix/TESTPLAN.txt).
Ein erfolgreicher Desktop-/OpenGL-Lauf ersetzt keinen Test auf dem betroffenen
Android-Handy. Es wird keine maximale Ladezeit auf Geräten versprochen.
