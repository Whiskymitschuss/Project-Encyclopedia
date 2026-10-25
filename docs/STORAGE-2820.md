# Lagergrenzen · 0.28.20-alpha.1

Die bisherigen Lagergrenzen waren überwiegend bereits vorhanden, aber die
Hauptanzeige addierte Zentrale und Werkspuffer ohne eine Obergrenze. Einige
zusätzliche Eingänge konnten außerdem für LKW gebuchte Plätze belegen.
Diese Änderung macht die vorhandenen Grenzen sichtbar und vereinheitlicht ihre
Durchsetzung. Sie setzt vorhandene Waren nicht zurück und erzeugt keine neuen.

## Plätze je Warenart

- Zentrale: 500 Grundplätze + 500 je gebauter Lagerhaus-Stufe + 1.500 je gebauter
  Zentrallager-Stufe. Neue Firma: 1.000; mit erstem Zentrallager: 2.500.
- Lagerhäuser zählen höchstens bis Katalogstufe 50, Zentrallager bis Stufe 20.
  Mehrere gebaute Lager tragen zur gemeinsamen Zentrale bei; sie besitzen keine
  mehrfach gezählten Kopien des zentralen Inventars.
- Abhol-Express: 96 auf Stufe 1, +24 je weiterer Stufe bis 312 auf Stufe 10.
- Im vereinheitlichten Netz: Werkseingänge und -ausgänge normalerweise
  96 + 16 × Gebäudestufe + 32 × Transportausbau, höchstens 384 je Ware.
  Bei der einfachen Holzlinie und Steinwerken ist der lokale Puffer ein
  gemeinsamer Eigentümer je Ware, kein doppelt gezählter Ein-/Ausgang.
- Frühe Firmen ohne Zentrallager behalten ihre bestehenden kleineren lokalen
  Linien- und Steinpuffer. Ein Ausbau vergrößert Plätze, füllt sie aber nicht.

Die Fächer sind je Material getrennt. Ein volles Trockenholzfach blockiert keine
Holzplätze. Geld, Diamanten und Tickets sind keine Lagerwaren. Es gibt kein
neues globales Ressourcenlimit unabhängig von gebauten Lagergebäuden.

## Echter Warenfluss

Anfahrende zentrale Abholungen, ältere Steinlieferungen und zurückkehrende
verwaiste Baustellenladungen reservieren das jeweilige zentrale Fach.
Warenannahmebestände buchen dieselben Plätze. Käufe, manuelle Ablieferung,
Produktionsgutschriften, Linienauflösung und Bauabbruch berücksichtigen diese
Buchungen. Ein übergroßer Abholauftrag wird vor dem Abzug der Quelle abgelehnt.
Mehrere zentrale Höfe können nicht dieselben Plätze doppelt reservieren.

Alte Linienfahrzeuge entladen erst, wenn ihr tatsächlicher Zielpuffer Platz hat.
Obsolete Werksanlieferungen dürfen den Ausgang nicht mehr künstlich vergrößern.
Voller Ausgang pausiert die Verarbeitung ohne weiteren Rohstoffverbrauch.
Entnahme/Verkauf und verfügbare Straßen/LKW lassen Abholung und Produktion
wieder automatisch anlaufen. Die Wiederaufforstung bleibt davon unabhängig.

Vorhandene Überbestände bleiben vollständig erhalten. Sie werden als
Überbestand angezeigt und nehmen keine neuen Gutschriften an. Alte geladene
zentrale Frachten dürfen in die bisherige begrenzte Warenannahme entladen;
diese Ausnahme wird nicht für neue spekulative Abholungen verwendet.
Sägespäne behalten die bisherige gesonderte Überlaufbehandlung (Verkauf oder
Kompost); ein voller Nebenproduktbehälter stoppt das Sägen weiterhin nicht.

## Anzeige

Die große Zahl bleibt der genaue Vorrat aller Lager und Betriebe. Die zweite
Zeile `L …/…` zeigt zentrale Belegung und Grenze. Im Detail steht zusätzlich die
Summe der zentralen, regionalen und geeigneten lokalen Lagerplätze je Ware.
LKW-Inhalt ist weiterhin separat. `!` am Warennamen meldet ein volles oder
voll gebuchtes Zentralfach. Abgekürzte Zahlen werden im Vorratsdetail erklärt.
Das Detail zeigt zentrale Belegung/Kapazität, freie und gebuchte Plätze sowie
Verknüpfungen zum Lagerausbau. Logistik und Express-Auswahl nennen ihre Grenzen.

## Nachweis und Grenzen

`Storage2820` prüft Grenzen aller 16 Waren, geteilte Buchungen mehrerer Höfe,
Kaufablehnung ohne Geldabzug, Erhalt alter Überbestände, blockierte Entladung
und tatsächliches automatisches Wiederanlaufen mit `Game.step`.
`VisualStorage2820` prüft die wirkliche Hauptwelt und Menüs in 360 × 640 und
591 × 1280, jeweils mit normaler und großer Schrift; Textbreiten werden gemessen.
Die gesamten Quellprüfungen stehen im [Prüfbericht](alpha1-storage/automated-checks.json).
Diese generierten Firmen ersetzen keinen Test des privaten Spielstands oder
auf einem echten Android-Gerät. Das gesamte frühere Master-Rework bleibt offen.
