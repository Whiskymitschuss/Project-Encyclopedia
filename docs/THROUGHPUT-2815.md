# Mehr Durchsatz für Werke und Lager · 0.28.15-alpha.1

## Ursache und Wirkung

„Wartet auf freien LKW“ war eine tatsächliche Kapazitätsgrenze: Eine frühe
Zentrale hatte drei Fahrzeuge für Abholung, Werksversorgung und regionale
Umlagerungen. Ein Sägewerk der ausgewählten Lieferlinie auf Stufe 2 fasste nur
acht Holz. Die Ware im Zentrallager war dadurch kein ausreichend großer Vorrat
am Werk. Viele kleine Fahrten belegten außerdem dieselben Ladeplätze.

Die Produktion prüft weiterhin ihre tatsächlich vorliegenden Zutaten. Ein
belegter Fuhrpark ist kein eigener Produktionsschalter. Solange am Werk Material
liegt, wird es verarbeitet; die Statuszeile unterscheidet den wartenden Nachschub.

## Änderungen in der bestehenden Hauptwelt

- Fertiges Zentrallager Stufe 1: **fünf statt drei Lager-LKW** im einheitlichen
  Logistiknetz. Lagerausbau und Abhol-Express vergrößern die Grundflotte weiter.
- **Zusätzliche Lager-LKW kaufen** unter Logistik und Garage. Zwei Kaufplätze
  stehen zunächst zur Verfügung; jede Garagenstufe öffnet zwei weitere.
  Preis des ersten zusätzlichen Lager-LKW: 800 Münzen, danach Faktor 1,6.
  Die aktive Lagerflotte ist insgesamt auf 16 begrenzt. Bereits erworbene Zähler
  bleiben gespeichert; ein später voller aktiver Fuhrpark nimmt keine weiteren
  Käufe an. Allgemeine Fernhandels-LKW bleiben eine getrennte Kaufentscheidung.
- Die Baustellenflotte bleibt getrennt. Ein gekaufter Lager-LKW wird nicht
  zusätzlich als zweites gekauftes Fahrzeug der Baustellenflotte erzeugt.
- Werkspuffer und Ausgänge im einheitlichen Netz: **96 + 16 × Gebäudestufe**,
  begrenzt auf 384 je Material. Stufe 1 fasst 112, Stufe 2 128 statt bisher
  8 in der ausgewählten Linie beziehungsweise 16 im gewöhnlichen Werk.
  Das betrifft Holzwerke und die vorhandenen Mineralbetriebe. Bestehende
  Inventare werden weder aufgefüllt noch auf die neue Kapazität gekürzt.
- Größere Ladungen: `(12 + 2 × Fahrzeugstufe) × 6` Holz oder `× 4` sonstige
  Fracht. Beispielsweise Fahrzeugstufe 1: **84 Holz / 56 Palettenware** statt
  56 / 28 im bisherigen einheitlichen Netz. Tatsächliche Ladung bleibt durch
  Quellbestand, freien Zielpuffer und Baureserve begrenzt.
- **Transportausbau je Werk, Stufe 0–4**: +32 Pufferplätze je Stufe sowie
  +25 Prozent maximales Ladevolumen je Stufe. Erster Ausbau 500 Münzen,
  weitere Kosten Faktor 1,8. Prestige verwendet den vorhandenen Kostenfaktor.
  Die Verbesserung ist ein Betriebs-/Transportausbau, keine zusätzliche
  Produktionslinie oder vorgetäuschte neue Gebäudeform.
- Umschlag im einheitlichen Netz: vier Sekunden zum Laden und vier zum
  Entladen; je Transportausbaustufe eine halbe Sekunde weniger, bis zwei Sekunden.
  Die tatsächlichen Fahrstrecken, sichere Abfahrtsreservierungen und leeren
  Rückfahrten bleiben erhalten. Laufende Fahrten behalten Ladung und Zeitplan.
- Pro Werk und Material fährt zunächst eine angeforderte Lieferung. Deren
  Ladung und Zielraum sind reserviert; ein weiterer LKW wird nicht mit einer
  winzigen Nachfüllung hinter dieselbe noch unentladene Ladung gestellt.
- Werksstatus zeigt bei gebuchter Lieferung die Ankunft einschließlich bereits
  eingeplanter Straßenwartezeit. Ohne verfügbaren LKW heißt es ausdrücklich,
  dass **der Nachschub** wartet. Werksvorrat und laufende Produktion bleiben
  dabei unabhängig lesbar.

Die alten direkten Liefer-/Transportmodi ohne einheitliches Lagernetz behalten
bestehende Kapazitätsregeln. Das neue Netz nutzt weiterhin Lager → Werk und
Fabrik → Lager; es gibt keine Waren-Teleportation oder direkte Bauplatzabkürzung.

## Gemessener Vergleich

Eine generierte kleine Firma mit sechs Arbeitern, Fahrzeugstufe 1, Sägewerk
Stufe 2, Zentrallager Stufe 1, Möbelwerk, Trocknung und reichlich Lagerholz wurde
1.200 Sekunden ohne manuelle Bestellungen, Fällen oder Abliefern simuliert.
Der Vergleichsstand ist der unmittelbar vorherige Quellstand von 0.28.14.
Die Firma startet in beiden Fällen mit identischen Waren und Gebäuden.

| Messung | Vorher | 0.28.15 |
|---|---:|---:|
| Lager-LKW, ohne zusätzliche Käufe | 3 | 5 |
| Holzpuffer des ausgewählten Sägewerks | 8 | 128 |
| Sägewerk aktiv, von 1.200 Sekunden | 90 | 1.020 |
| Wegen fehlendem Eingangsvorrat untätig | 1.110 | 180 |
| Längste zusammenhängende Eingangspause | 146 s | 30 s |
| Fertige Bretter | 36 | 647,33 |
| Tatsächlich im Laden verkaufte Möbel | 22 | 74 |

Das ist eine kontrollierte Simulation, keine Leistungs- oder Ertragsgarantie
für jeden Spielstand. Volle Lager, Pausen, fehlende Rohstoffe, Baustellenreserven
oder nicht angeschlossene Betriebe bleiben reale mögliche Stopps. Auch eine
verbesserte endliche Flotte kann zeitweise warten.

## Prüfung und Grenzen

[Quellprüfungen](alpha1-throughput/automated-checks.json) ·
[Prüfung der tatsächlichen APK-Dateien](alpha1-throughput/packaged-checks.json).
Neue Prüfungen kontrollieren vollständige Verarbeitung bis Trockenholz, Möbel,
Wänden und Dächern, unveränderte Materialbilanz, keine doppelten Lieferungen,
gekaufte Fahrzeuge/Ausbauten, exakte Speicherfortsetzung und sichere Reservierungen
aller 16 Fahrzeuge. Die vorherige Holzabholung und Materialbaustellen werden
weiter mitgeprüft. Neue UI-Aktionen werden per echten Touch-Ereignissen bedient.

Android-Code 3010, gleiche Paketkennung und bisheriges Testzertifikat.
**Als Update installieren; nicht deinstallieren und keine App-Daten löschen.**
Kein echter Android-/Hitzetest und kein privater Handyspielstand.
Die frühere vollständige Design-/World-Masterliste bleibt darüber hinaus offen.
