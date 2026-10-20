# Zehn Kapitel und Rathaus — 0.19.1

Die Kapitel ergänzen die bestehende Stadt und Holzindustrie. Nichts wird beim Update zurückgesetzt. Die Zielanzeige oben führt nach dem kurzen Tutorial zur Kapitelreise; **Mehr → Kapitel 1–10 & Rathaus** bleibt jederzeit erreichbar.

Jedes Kapitel enthält drei Ziele und einen abschließenden **tatsächlich fertig gebauten Rathausausbau**. Erst danach wird der Abschluss abgeholt und das nächste Kapitel geöffnet. Bereits während früherer Kapitel erreichte Ziele werden vermerkt. Ein Bauauftrag zählt noch nicht als fertiges Gebäude. Forschungs-, Werkzeug-, Firmen- und Gebäudestufen behalten ihre bisherigen Freischaltungen; die Kapitel ersetzen diese nicht.

| Kapitel | Aufgaben | Rathaus danach |
| --- | --- | --- |
| 1 · Ein guter Anfang | 5 Bäume fällen; 20 Holz aus dem Rucksack abliefern; erste Ware verkaufen | Waldbüro · 1 |
| 2 · Die Säge singt | 20 Bretter produzieren; ein Sägewerk auf Stufe 2; 3 Holzarbeiter beschäftigen | Gemeindebüro · 2 |
| 3 · Mehr als nur Holz | Trockenkammer und Möbelfabrik fertigstellen; 12 Möbel verkaufen | Gemeindehaus · 3 |
| 4 · Alles kommt an | Kleine Holzlieferkette aktivieren; 6 echte Materiallieferungen; einen Ladenauftrag erfüllen | Kleines Rathaus · 4 |
| 5 · Aus Plänen wird Heimat | Fertighauswerk; erstes Stadtgebäude außer Rathaus; 100 Münzen Miete erhalten | Rathaus · 5 |
| 6 · Ein festes Fundament | Steinbruch; Steinwerk; 50 eigene Bausteine/Kies ins Lager liefern | Stadtrathaus · 6 |
| 7 · Eine Stadt für alle | Eigene Straße/Weg; 20 Bewohner; 3 abgeschlossene Stadtfahrten | Großes Rathaus · 7 |
| 8 · Neue Horizonte | 3 Waldregionen; ein Stadtgebäude außer Rathaus auf Stufe 5; neues Stadtviertel | Stadtverwaltung · 8 |
| 9 · Deine eigene Skyline | Ein Stadtgebäude außer Rathaus auf Stufe 10; 5 Waldregionen; 500 Möbel verkaufen | Metropol-Rathaus · 9 |
| 10 · Dein Industrieimperium | 3 fertige Sägewerke; 100 Bewohner; insgesamt 2.000 Möbel verkaufen | Timber-Stadtpalais · 10 |

## Ein Rathaus mit echtem Bau und Nutzen

Das Rathaus wird frei auf erschlossenem, gültigem Gelände platziert. Es hat einen eigenen Verwaltungsplatz (gespeicherte Plot-ID 100) und verbraucht keine Wohnbauplätze. Dadurch werden alte Städte mit bereits belegten Wohnparzellen nicht ausgesperrt. Ein zweites Rathaus wird auch während eines laufenden Erstbaus verhindert.

Bereits Stufe 1 wird mit realen Holz-/Bretterlieferungen, sieben Bauphasen und dem bestehenden Bauteam errichtet. Es benötigt deshalb kein noch gesperrtes Fertighauswerk. Spätere Materialien erscheinen erst nach passenden Branchenkapiteln: Möbel ab Stufe 3, Wand-/Dachmodule ab 5, Bausteine/Kies ab 6, Bauelemente ab 8. Holz und Bretter bleiben bis Stufe 10 nötig. Alle Lieferungen teilen sich die gekaufte Flotte. Das fertige Modell ändert sich erst nach Abschluss. Materialien, Münzpreis und Quelle lassen sich vor dem Auftrag ansehen.

Die Münzpreise lauten 200 / 450 / 900 / 1.800 / 4.000 / 8.000 / 16.000 / 32.000 / 64.000 / 120.000, multipliziert mit der bisherigen Prestige-Schwierigkeit. Materialien und Ziele sind zentral in `Economy/Journey.gd` konfiguriert. Einzel-, Kontext- und Viertel-Ausbau verwenden dieselbe Rechnung; gesperrte Rathausstufen lassen sich auch über einen Viertelauftrag nicht umgehen.

Jede fertige Rathausstufe erhöht die Grundmiete aller Häuser um zwei Prozentpunkte. Gemeinsam mit Park-/Klinikboni gilt die bestehende Obergrenze von +100 %. Der Kapitelabschluss gibt zusätzlich zu den einzelnen Münzprämien drei Diamanten, ein Loot-Ticket und eine bleibende Auszeichnung. Die Auszeichnung besitzt eine tatsächliche 3D-Vorschau und einen wählbaren Titel im HUD.

## Freiwillige Kurzaufträge

**Aufträge → Freiwillige Kurzaufträge** bietet drei zum vorhandenen Betrieb passende Vorhaben. Ein Auftrag ist gleichzeitig aktiv. Es zählen ausschließlich neue Ereignisse seit Annahme: gewonnenes Holz, fertig produzierte Bretter/Möbel, tatsächlich angekommene beladene LKWs, fertige Bauprojekte oder eigene ins Lager gelieferte Baustoffe. Bereits vorhandene oder gekaufte Vorräte sind keine Produktion. Volle Ausgänge, fehlende Inputs und pausierte Betriebe erzeugen keinen künstlichen Fortschritt. Eine leere Rückfahrt ist keine weitere Lieferung.

Es gibt kein Ablaufdatum, keinen Tageswechsel, keine Streak, keinen kostenpflichtigen Neustart und keine Echtgeldkäufe. Ein Auftrag kann kostenlos zurückgelegt werden; bereits verdiente Münzen entstehen dabei nicht. Abgeholte Aufträge zahlen ihren vorher sichtbaren Münzbetrag; jeder dritte gibt zusätzlich ein Ticket. Zähler und Annahme-Baseline werden gespeichert. Produktionsziele konsumieren keine Waren zusätzlich — sie zählen die tatsächliche Fertigung, während die Ware ganz normal weiterfließt.

## Rückkehr und Speichern

Nach mehr als einer Minute Abwesenheit führt **Willkommen zurück · Bilanz** zur tatsächlichen Entwicklung: Münzen, produzierte Bretter/Möbel, angekommene Materiallieferungen, fertiggestellte Projekte und neu angesammelte Miete. Diese Werte sind bereits in der Wirtschaft verbucht. Die Übersicht besitzt keinen zweiten Auszahlungsbutton. Mietabholung entnimmt weiterhin nur das wirkliche Hauskonto.

Beim Fortsetzen derselben laufenden Anwendung werden schon im Hintergrund simulierte Sekunden von der nachzuholenden Zeit abgezogen. Wiederholte Resume-Meldungen rechnen dieselbe Abwesenheit nicht erneut. Die vorhandene Offline-Grenze bleibt acht Stunden. Kapitelzähler und neue Statistikdaten liegen im bisherigen Schema-1-Spielstand. Alte Profile übernehmen ausschließlich bekannte historische Zähler; unbekannte vergangene Produktion wird nicht erfunden. Abholbare Ziele gewähren beim Laden keine heimlichen Prämien.

Prestige erhält erreichte/abgeholte Kapitel, Auszeichnungen, Titel und historische Erfolgszähler. Ein angefangener Kurzauftrag wird ohne Kosten zurückgelegt. Die physische Stadt und das Rathaus werden entsprechend dem bisherigen Prestige-Neustart neu aufgebaut; bereits abgeschlossene Kapitel werden nicht noch einmal bezahlt.

## Prüfgrenzen

Automatisierte Startprogression und Testprofile prüfen technische Erreichbarkeit, tatsächliche Transporte und die zehn Bau-/Freischaltungsschritte. Aufbauprofile für späte Kapitel sind ausdrücklich vorbereitete Teststände. Sie belegen keine reale Spieldauer, Spielerbindung oder langfristige Balance. Diese müssen mit freiwilligen Testspielern auf echten Geräten beobachtet werden; es werden keine Analyse- oder Werbedienste hinzugefügt.
