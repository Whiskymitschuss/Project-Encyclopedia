# Stottern und adaptive Darstellung · 0.28.23-alpha.1

Nutzermessung auf SM-S721B, Version .22: 4,8 FPS, P95 384,9 ms,
13 Betriebe / ein Haus, Weltaufbau 3.389 ms, 3D-Auflösung 76 %.
Die Sitzungsmessung zeigt weiterhin schwere Laufzeitprobleme. Der Screenshot
enthält kein abgeschlossenes Kamerarunden-Ergebnis und keine CPU-Bereiche.

## Änderung

Die bisherige Automatik hatte nur eine Entlastungsstufe: nach drei Sekunden
schlechter Bildzeiten 85 % des normalen linearen Rendermaßstabs. Selbst bei
anhaltend 4–5 FPS blieb sie dort. Der neue Regler reagiert nach sechs weiteren
Sekunden schwerer Last mit 65 %, nach weiteren sechs Sekunden mit 50 %.
Alle Werte beziehen sich auf den bisherigen mobilen Zwei-Megapixel-Grundrahmen.
Auf 1080×2340 ergibt schwere Last so etwa **44,5 % statt 75,6 %** der nativen
Kantenlänge; das sind etwa **65 % weniger angeforderte 3D-Pixel** als zuvor.
Die 3D-Welt wird entsprechend weicher; Menüs und Touchflächen bleiben nativ.

Kurze einzelne Ausreißer schalten nicht sofort alle Stufen durch. Erholung
fordert 20 stabile Sekunden und mindestens 45 Sekunden seit dem letzten Wechsel,
bevor genau eine Stufe zurückkehrt. Vollständige Erholung kann bei Stufe 3
mehrere Minuten dauern. Akkumodus wird bei schwerer Last ebenfalls entlastet.
Wer die Automatik abschaltet, behält die bisherige native Darstellungsoption.

Bei Entlastung verwenden Forste und Landschaft ihre vorhandenen groben Meshes.
Auch eine stehende Kamera aktualisiert den Detailgrad. Kein Baum wird gelöscht,
keine Mitarbeiterzahl verändert, keine Produktion verlangsamt und kein Waren-
oder Spielstand geändert. Fotomodus stellt volle Auflösung und die ursprüngliche
Detailgeometrie wieder her; beim Verlassen kehrt die aktuelle Entlastung zurück.

Beim Antippen stoppt eine laufende Kamerafahrt an der aktuellen Ansicht. Dadurch
rutschen kleine Fahrzeuge zwischen Drücken und Loslassen nicht aus dem Ziel.
Die echte Touch-/LKW-Prüfung wird zusätzlich mit ausgeführt.

## Automatische Diagnose

Auf Android laufen CPU-Messungen jetzt auch ohne Kamerarunde. Maximal 180
Aufrufe je festem Bereich bleiben im Speicher. Speichern erhält einen eigenen
Messbereich; zusätzlich erscheinen Anzahl langsamer Bilder über 100 ms,
längste gemessene Verzögerung, Zeichenaufrufe und tatsächliche Grafik-API.
Lange Hänger über zwei Sekunden werden nach der Aufwärmphase mitgezählt;
App-Hintergrund und Rückkehr werden herausgefiltert.

Die Leistungsseite zeigt Gerät/Version, aktuelle Leistung und automatische
Messdetails zuerst. Die optionale Kamerarunde folgt darunter. Der manuell
kopierbare Testbericht enthält die automatischen Werte ebenfalls. Keine
Übertragung, keine neue Berechtigung, keine Temperatur- oder GPU-Zeitmessung.
CPU-Zeiten sind pro Aufruf; verschachtelte Bereiche dürfen nicht addiert werden.

## Prüfung und Grenzen

Ein CPU-Nachspiel mit einer erzeugten Firma über 180 simulierte Sekunden
identifizierte erste Modellerzeugungen als einzelne Spitzen. Periodische
Speicherung lag auf dem Desktop ungefähr bei 3,5–5,9 ms. Das beweist keinen
Speicherengpass auf dem Handy; die sichere atomare Speicherung bleibt unverändert.

`Performance2823` prüft Eskalation, einzelne Ausreißer, langsame Erholung,
Rendermaßstab, Akku-/Foto-/Opt-out-Verhalten, begrenzte Messfenster und vollständig
unveränderten Firmenzustand. `VisualPerformance2823` prüft tatsächliche
GPU-Meshauswahl, native HUD-Geometrie, Fotomodus und die echte Leistungsseite.

Ein Desktop-Grafikvergleich ist unter `alpha1-adaptive/` dokumentiert. Er verwendet
die echte Hauptwelt, 1080×2340 und dieselbe synthetisch angelegte 16-Sekunden-Last.
Das ist ein Nachweis der Reaktion auf Last, keine unabhängige Erkennung eines
Handy-GPU-Engpasses. **Keine zugesicherten 30 FPS auf dem SM-S721B.**
Weitere Eingrenzung nutzt die jetzt automatisch erhobenen CPU- und Renderwerte.
Das Problem gilt erst nach erneuter Gerätemessung als behoben.

Im isolierten Desktop-Vergleich sank die Median-Bildzeit von 95,55 auf 69,91 ms,
P95 von 120,32 auf 97,02 ms. Gerenderte Dreiecke 232.504 → 192.152,
Zeichenaufrufe unverändert 258. Beide vollständigen Firmenzustände sind gleich.
Die Werte beschreiben diese Testansicht und synthetische Last, keine Handy-FPS.
