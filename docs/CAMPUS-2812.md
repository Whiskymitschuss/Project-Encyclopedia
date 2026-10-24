# Holzwerkshof, Sägewerke und Wiederaufforstung · 0.28.12-alpha.1

Die ausgewählten Punkte 1–5 sind in die bestehende Hauptwelt integriert.
Die Orientierung an Lumber Inc. betrifft einen lesbaren Industriebetrieb;
Modelle, Biber, Farben und Gebäudestruktur sind eigene prozedurale Geometrie.
Bestehende Gebäude, Straßen, Waren, Transporte und wirtschaftliche Gebäudestufen
bleiben erhalten. Es gibt keinen automatischen Abriss der bisherigen Stadt.

## 1. Zusammenhängender Holzwerkshof

Logistik → Holzkette → Holzwerkshof verbindet die vorhandenen Anlagen mit dem
neuen Planer. Sammelstation, Sägewerk, Trocknung und Lager bilden einen regulär
bezahlten Vierer-Bauauftrag auf einer gemeinsam geprüften Industriezeile.
Erst wenn alle Grundstücke frei, angeschlossen und die Münzen vorhanden sind,
werden die normalen Baustellen angelegt. Materiallieferungen und Bauteams
benutzen die bestehende Logistik. Bestehende Anlagen werden nicht versetzt.

Benachbarte Holzgrundstücke erhalten kurze private Fußverbindungen mit
zusammenpassenden Hofdetails. Öffentliche Straßen, Gehwege, Grundstücksgrenzen
und Stapler-Randgassen bleiben frei. Eingänge sind türkis, Ausgänge goldfarben.
Bei fehlendem Platz nennt der Planer den Grund und erzeugt keine Teilbestellung.
Die tatsächlichen Transporte laufen weiter über Zentrale oder Abhol-Express;
ein Hofverbinder ist keine versteckte Waren-Teleportverbindung.

## 2. Zehn baulich verschiedene Sägewerkformen

Jedes vorhandene Sägewerk verwendet jetzt dieselbe neue Gebäudefamilie in der
Hauptwelt. Stufen 1–10 ergänzen Unterstand, Technikraum, Bretterregal, Stahlrahmen,
Hallentor, Technikflügel, dritte Maschinenbucht, Doppeldach, Versorgungsleitungen
und hohen Leitstand. Geometrie und Silhouette ändern sich innerhalb des bisherigen
Grundstücks, nicht nur Farbe und Skalierung. Offene Hallenseiten lassen Maschinen
und Biber erkennen. Der Bretterausgang hat eine gemeinsame Übergabeförderstrecke.
Alte wirtschaftliche Stufen über 10 behalten ihre bisherige Wirkung und die
zehnte Bauform; kein bestehender Fortschritt wird auf Stufe 10 zurückgesetzt.

## 3. Echte Verarbeitung in drei Stufen

Rohholz durchläuft Entrinden → Sägen → Hobeln. Jede Linie besitzt getrennte,
gespeicherte Zwischenpuffer. Zwei Holz bleiben bis zum Abschluss als Material
in Verarbeitung gebunden; erst danach entstehen ein Brett und eine Sägespäne.
Diese Mengen sind bilanziert und können währenddessen weder verkauft noch ein
zweites Mal verladen werden. Im Warenmenü und Tooltip steht der gebundene Anteil
separat. Die Hauptkarte zeigt weiterhin nutzbare Bestände und Lageranteil.

Die Trocknung bleibt eine eigene nachgelagerte Fabrik. Pause, voller Ausgang und
fehlender Nachschub unterbrechen den passenden echten Vorgang. Angehaltene
Maschinen erzeugen keine zusätzlichen Waren. Die gleichen Schritte gelten für
die bisherige Lieferlinie und reguläre Werke mit lokalen Lagereingängen.
Animationen lesen die tatsächlichen Puffer und Arbeitsschritte; sie schreiben
keine Bestände. Gespeicherte Zwischenprodukte werden nach dem Laden fortgesetzt.
Der erste fertige Artikel braucht jetzt die drei Maschinenstufen; die stationäre
Grundrate der bisherigen einzelnen Linie bleibt erhalten.

## 4. Tatsächlich parallele Linien

Sägewerkstufe 4 erlaubt den Kauf einer zweiten, Stufe 7 einer dritten Linie.
Die Einrichtung kostet Münzen und Baumaterial. Ein normaler Ausbauauftrag
fordert Lieferungen und ein angekommenes Bauteam an. Erst nach Fertigstellung
arbeitet die zusätzliche Linie. Keine automatische kostenlose Verdopplung alter
Werke. Jede Linie besitzt eigene Maschinen, Puffer und einen sichtbaren
Biber-Maschinenführer; diese Bediener gehören zur gekauften Anlagenausstattung.
Die eingestellten Waldhelfer teilen sich weiterhin Fällen und Pflanzen.

Ein kontrollierter Test bei Stufe 7 und ausreichendem Ein-/Ausgang misst über
zehn Sekunden im stationären Betrieb 63, 126 und 189 Bretter für eine, zwei und
drei Linien. Das ist Verarbeitungskapazität, keine Zusage für eine unversorgte
Fabrik. Reale Lagerplätze, Nachschub, LKW und Abholung begrenzen den Durchsatz.

## 5. Biber pflanzen tatsächlich nach

Die bestehenden deterministischen Baumpositionen erhalten einen gespeicherten
Zustand. Ein reifer Baum besitzt einen endlichen Holzvorrat; nur akzeptierte
Ernte verbraucht ihn und löst den sichtbaren Fall aus. Ein Stumpf wächst nicht
mehr nach einer rein grafischen Wartezeit automatisch wieder zum Baum.

Die automatische Zuteilung entsendet bis zur aufgerundeten Hälfte der vorhandenen Waldhelfer,
sofern tatsächlich erreichbare Pflanzstellen vorhanden sind. Nur laufende
Missionen binden Personal. Team → Wiederaufforstung erlaubt auch eine manuelle
Zuteilung oder Pause. Die Biber gehen mit Spaten und Setzlingen über geprüfte
Forstwege zum Stumpf, pflanzen vier Sekunden und kehren zurück. Fahrzeit richtet
sich nach der echten Weglänge. Der Jungbaum wächst anschließend über 90
Simulationssekunden zum erntereifen Baum. Kein Holz wird beim Pflanzen erzeugt.

Gebäude, Baustellen, Straßen und Forstmaschinenstände werden freigehalten.
Aktive Pflanzwege sind gegen neu darübergelegte Gebäude und Straßen geschützt.
Pflanzaufträge, Stümpfe und Wachstumsfristen überstehen Speichern und Offline-Zeit.
Die Darstellung verwendet vorhandene Bauminstanzen und wenige wiederverwendete
Biber. Grafikeinstellung und Kamera verändern den Ertrag nicht.

## Prüfung und Grenzen

[Automatisierte Quellprüfungen](alpha1-werkshof/automated-checks.json) und
[Prüfung der tatsächlichen APK-Dateien](alpha1-werkshof/packaged-checks.json)
dokumentieren die endgültigen Ergebnisse separat. Die Bilder in diesem Ordner
stammen aus der tatsächlichen Hauptwelt mit generierten Testfirmen.

Geprüft werden Warenbilanz einschließlich Zwischenpuffern, alle zehn Bauformen,
parallele Kapazität, bezahlter Linienausbau, angekommene Bautrupps, Pflanzwege,
Jungbäume, Pausen, voller Ausgang, alte Spielstände und kleine Menüs. Die
vorhandenen Logistik-, Baustellen-, Verkehrs-, Wald- und Fortschrittstests
bleiben Bestandteil der Gesamtprüfung. Ein natürlicher Start muss weiterhin
Hütte und Rathaus ohne Materialgeschenke erreichen; acht Stunden Offline-Zeit
werden mit der schrittweisen Fortsetzung nach dem Laden verglichen.

Keine physische Android-, Wärme-, Akku- oder Dauer-FPS-Messung dieser Fassung.
Kein Zugriff auf den privaten Handyspielstand. Die komplette frühere Masterliste
mit sämtlichen Fabriken, neuen Industriezweigen und allen Fahrzeugen ist damit
nicht abgeschlossen. Diese Fassung betrifft die fünf ausgewählten Ausbauten.
Die 90 Sekunden Wachstum sind ein Spielwert, keine reale Forstsimulation.

Android-Code 3007, gleiches Paket und dasselbe bisherige Testzertifikat.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
