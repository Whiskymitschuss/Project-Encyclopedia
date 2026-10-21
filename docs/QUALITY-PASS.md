# Qualitätsüberarbeitung 0.25

Die Auswirkungen sind Designeinschätzungen, keine gemessenen Spielerbewertungen.
Bestehende Wirtschaft, Bauzeiten, Spielstände und Produktionsketten bleiben maßgeblich.

## Aufgabe 1 – HUD und Mitteilungen

- **Änderung:** Abgesetzte Währungskarten mit größerem Münzwert, kompakte Zielzeile mit
  animiertem echtem Fortschritt, einheitliche Abstände und Rundungen. Mitteilungseingang
  bündelt Hinweise und Ereignisse; bis zu vier deduplizierte Kurzmeldungen werden
  nacheinander gezeigt. Die letzten zwölf Sitzungsmeldungen bleiben im Eingang lesbar.
- **Warum:** Werte, nächste Aufgabe und Handlungen sollen schneller erfassbar sein.
- **Spielernutzen:** Mehr Orientierung, weniger gleichzeitig konkurrierende Texte;
  Verkaufserlöse und Zielbelohnungen erscheinen direkt am Konto. Mehr Platz auf kleinen
  Displays durch kurze Beschriftungen; Bilder behalten ihr Seitenverhältnis.
- **Geschätzter Qualitätseffekt:** hoch, da bei jeder Aktion sichtbar.

## Aufgabe 2 – Lebendige Welt

- **Änderung:** Dezenter, versetzter Wind auf den gebündelten Baumkronen; vier
  wiederverwendete Fallbäume übernehmen Form und Farbe ihres echten Waldbaums.
  Kamine an Wohnhäusern und Hütte geben kleine Rauchwolken ab. Vorhandene Arbeiter,
  Transporte und soziale Gesten bleiben erhalten.
- **Warum:** Auch zwischen Eingaben soll der Betrieb bewohnt wirken.
- **Spielernutzen:** Baumfällen hat Richtung und Gewicht; Rauch und Wind verbinden
  die Einzelobjekte zu einer zusammenhängenden Welt.
- **Geschätzter Qualitätseffekt:** mittel bis hoch, besonders in der normalen Nahansicht.

## Aufgabe 3 – Feuerwehrpräsentation

- **Änderung:** Funken, pulsierendes warmes Licht ohne zusätzliche Schattenkarte,
  Wasserzerstäubung und bewegte Wasserstrahlen. Zwei Balken zeigen verbleibenden Brand
  und echten Löschfortschritt. Der Eingang zeigt dieselben Werte lesbar im Einsatzmenü.
  Gebäudenamen und Mietbeschriftungen treten während eines Brands zurück.
  Nach tatsächlichem Abschluss: Dunst, grüner Bodenring, Erfolgsschrift und kurzer Klang.
- **Warum:** Anfahrt, aktive Löscharbeit und Abschluss müssen sofort unterscheidbar sein.
- **Spielernutzen:** Eingriffe und Wasserversorgung lassen sich visuell nachvollziehen.
  Gebäudeschaden wird ehrlich als **0** angezeigt: Die bestehende Simulation beschädigt
  und zerstört keine Häuser. „Brandstärke“ bezeichnet hier den verbleibenden Anteil
  `1 − Löschfortschritt`, keine neue physikalische Ausbreitungsberechnung.
- **Geschätzter Qualitätseffekt:** hoch bei Einsätzen.

## Aufgabe 4 – Sichtbare Gebäudestufen

- **Änderung:** Gemeinsame fünfteilige Holz-/Messing-Ausbauplakette für Stadt, Betriebe
  und Steinindustrie. Stufe 2 ergänzt Blumen, Stufe 3 Lageranbauten, Stufe 4 einen großen
  rückwärtigen Betriebsunterstand, Stufe 5 Solardächer und Messingakzente. Stadthäuser
  behalten zusätzlich ihre bereits vorhandenen stufenabhängigen Flügel und Etagen.
  Höhere Wirtschaftsstufen bleiben erhalten; die Premium-Sprache gilt ab Stufe 5.
- **Warum:** Industriestufen teilten bisher zu oft dieselbe Silhouette.
- **Spielernutzen:** Ausbau lohnt sich sichtbar, ohne neue Bauflächen zu benötigen.
- **Geschätzter Qualitätseffekt:** mittel bis hoch beim Ausbau und Stadtüberblick.

## Aufgabe 5 – Atmosphäre und Oberflächen

- **Änderung:** Zusätzliche Blumenfarben, gestaltete Grundstückskanten und günstige
  Kontaktabdunklung; Baumkronen erhalten dunklere Unterseiten und hellere Spitzen.
  Vorhandene Büsche, Holzstapel, Zäune, Wege und Straßenmöblierung werden weitergenutzt.
- **Warum:** Farbvariation und Kontakt zum Boden geben der Low-Poly-Welt mehr Tiefe.
- **Spielernutzen:** Gebäude wirken gesetzt und gepflegt, der Wald weniger gleichförmig.
  Kein teurer SSAO-Nachbearbeitungspass im mobilen GL-Renderer.
- **Geschätzter Qualitätseffekt:** mittel, dauerhaft in der Welt sichtbar.

## Aufgabe 6 – Produktionsfeedback

- **Änderung:** Sägespäne an arbeitenden Werkzeugen, Dampf am aktiven Trockner und
  Staub an tatsächlich arbeitenden Materialbaustellen. Reale Verkäufe und Ladenumsatz
  erzeugen Münzen und Erlösbeschriftung; keine Partikel bei leeren Verkäufen.
  Vorhandene Sägen, Werkzeuge, Werkstücke und Lieferwagen bleiben die zentrale Animation.
- **Warum:** Materialverarbeitung und Einnahmen brauchen lesbare Ursache und Wirkung.
- **Spielernutzen:** Funktionierende, pausierte und stockende Produktion lassen sich
  leichter unterscheiden; Verkäufe fühlen sich unmittelbarer an.
- **Geschätzter Qualitätseffekt:** hoch im aktiven Spiel.

## Aufgabe 7 – Belohnender Fortschritt

- **Änderung:** Sanft animierter echter Zielfortschritt, farblich markierte abholbereite
  Ziele, Münzfeedback für Meilensteine, Kapitel und Kurzaufträge. Unternehmenslevel
  erhalten eine sichtbare Freischaltmeldung; bestehende Baufeiern bleiben erhalten.
- **Warum:** Erreichte Ziele sollen als Erfolg ankommen und den nächsten Schritt zeigen.
- **Spielernutzen:** Klare Rückmeldung ohne neue Währungen, tägliche Pflicht oder neue
  Aufgabenmechanik. Belohnungen stammen ausschließlich aus erfolgreichen Transaktionen.
- **Geschätzter Qualitätseffekt:** mittel bis hoch bei Zielabschlüssen.

## Effektbudget und Zugänglichkeit

Vier Erfolgseffektplätze, vier Fallbäume, sechs vorhandene Späneeffekte; Feuer weiterhin
maximal zwei. Partikelmengen sinken im Akkumodus, Entfernung begrenzt die Darstellung.
Wind und Brandlicht entfallen im Akkumodus. Reduzierte Bewegung stoppt neue dekorative
Partikel, Wind und Fallanimationen; Status, Wirtschaft und Bedienung laufen weiter.
Keine Änderung an gespeicherten Ressourcen, Produktionsgeschwindigkeit oder Branddauer
für die Darstellung. Kleine Architekturdetails werden wie bisher entfernungsabhängig
abgeschaltet und pro Material zu Netzen gebündelt.

## Prüfung und Abgrenzung

19.456 Headless-Prüfungen und 324 gerenderte Prüfungen über die sieben Aufgaben und
bestehenden Spielfunktionen. Erlöse, Löscherfolge und Partikelzustände werden gegen
reale Spieltransaktionen geprüft. Layoutprobleme aus den Grafiktests wurden behoben.
[Prüfbericht und inszenierte Vorschaubilder](VALIDATION.md) enthalten die Einzelheiten.
Die geschätzte Qualitätswirkung ist noch nicht durch einen Nutzertest gemessen.
Android-Gerätetest, echte Mobil-Framerate und Akkuverhalten bleiben offen.
