# Rückkehr zur 0.28 · 0.28.1-alpha.1

## Wiederhergestellte Spielbasis

**Geändert:** Der aktive Spielcode und die Tests stammen wieder aus dem tatsächlich
verteilten Alpha-1-Quellstand `d14b53774d5505a93ee1e7b845b2b4753fd9b804`.
Die Ampel-, Bauleiter- und Ladeablaufänderungen ab 0.29 sind zurückgenommen.
Historie, alte Veröffentlichungen und die isolierte Test-/Build-Infrastruktur bleiben.

**Grund:** Auf dem Handy bleiben seit 0.29 dieselben LKW stehen. Weitere Korrekturen
an dieser Verkehrssteuerung haben den gemeldeten Fehler nicht verlässlich beseitigt.
**Spielernutzen:** Wieder die vertraute 0.28 als Grundlage, statt weiterer 0.29-Regeln.
**Geschätzte Qualitätswirkung:** Hoch für Zuverlässigkeit; keine Gerätegarantie.

Die sichtbare Versionsnummer ist 0.28.1-alpha.1. Android-Code 2951 liegt absichtlich
über 2942, damit diese Rückkehr als Update über 0.29.4 installiert werden kann.
Paket, Speicherverzeichnis und bestehendes Testzertifikat bleiben gleich.
Nicht deinstallieren und keine App-Daten löschen.

Die unveränderte Spielbasis besteht in isolierten Profilen alle 19630 Prüfungen
in 26 Headless-Suiten sowie Main-/Boot-Smokes. Gerätetests stehen aus.
Die späteren, ausdrücklich gewünschten Änderungen an Häusern, Materialanzeige und
mobiler Lastbegrenzung werden gesondert dokumentiert und geprüft.

## Häuser versetzen

**Geändert:** Direkter Verschieben-Knopf in der Gebäudekarte, mit Vorschau,
Drehung und Bestätigung. Der globale Sperrriegel bei irgendeiner laufenden
Baustellenlieferung entfällt. Geschützt bleiben der tatsächlich verwendete
Ladehof sowie der eigene Ausbau und Einsätze/Stadtfahrten am Gebäude. Die
Vorschau erklärt diese Sperre, bevor bestätigt werden kann.
**Grund:** Die Aktion war bei Häusern versteckt; laufender Stadtbau machte
Versetzen zusätzlich oft unmöglich.
**Spielernutzen:** Die Stadt lässt sich umgestalten, ohne Miete, Ausbaustufen
oder Münzen zu verlieren. Abbrechen verändert nichts.
**Geschätzte Qualitätswirkung:** Hoch für Bedienbarkeit und Gestaltungsfreiheit.

## Materialbestände im Hauptbildschirm

**Geändert:** Sechs feste Materialfelder (Holz, Bretter, Trockenholz, Möbel,
Wände, Dächer), unabhängig vom Ladenauftrag. Angezeigt werden Lager und
lokale Betriebsbestände; Ladungen im Transit sind separat in der Detailansicht.
„Alle Waren“ erschließt sämtliche Materialien einschließlich Stein und Hardware.
Beim Bauen sowie auf kurzen Bildschirmen bei geöffneten Details weicht das große Materialfeld
einer kompakten Bestandszeile; die Hauptansicht zeigt wieder alle sechs Felder.
**Grund:** Der bisherige Ladenstatus verdrängte die tatsächlichen Bestände.
**Spielernutzen:** Engpässe erkennen und Quellen öffnen, ohne durch Menüs zu suchen.
**Geschätzte Qualitätswirkung:** Hoch für Übersicht und Produktionsverständnis.

## Mobile Lastbegrenzung

**Geändert:** Android erhält unabhängig von 60/90/120-Hz-Display maximal 30 FPS,
Desktop 60 FPS, Akkumodus ebenfalls 30 FPS. Mobile Richtungsschatten verwenden
1024 statt der bisherigen Standardgröße; Desktop 2048. Beim Minimieren werden
Szenenverarbeitung und Renderloop ausgesetzt. Rückkehr setzt sie fort und
berechnet fehlende Zeit einmal über die wiederhergestellte 0.28-Simulation.
UI und Welt behalten ihr Seitenverhältnis.
**Grund:** S26 Ultra wird laut Handytest nach 4–5 Minuten heiß, S24 FE nicht.
Die bisherige Fassung begrenzte die Bildrate selbst nicht. Mehr Last auf einem
hochauflösenden Gerät ist plausibel; eine eindeutige Temperaturursache ist damit
noch nicht gemessen.
**Spielernutzen:** Begrenzte Bildarbeit und geringere Schattenlast, keine
unnötige Darstellung im Hintergrund.
**Geschätzte Qualitätswirkung:** Mittel bis hoch; tatsächliche Temperatur und
Bildruhe müssen auf S26 Ultra und S24 FE verglichen werden. Kein Gerätelauf
oder Temperaturmessergebnis wird aus Cloud-Tests abgeleitet.

## Kompatibilität und Rückfallebene

Beim ersten Speichern nach 0.29 bewahrt Store die ursprünglichen gültigen
Dateibytes zusätzlich unter `user://recovery/before-028-rollback.json`. Spätere
Autosaves überschreiben diese Kopie nicht. Bei einem Kopierfehler bleibt die
Originaldatei unangetastet. Technikerfahrten ohne Wirtschaftsladung werden
beim Laden entfernt; die 0.28 besitzt keine Ampelwartung. Ordentliche Stadtfahrten,
Brände, Bestände und echte Frachten bleiben.

Der Kompatibilitätstest verwendet ausschließlich die künstlich erzeugte
Teststadt aus 0.29.3, keinen privaten Handyspielstand. Er prüft unveränderte
Bestände beim Laden, persistente Sicherung und das Beenden der alten Frachten
unter 0.28. Touch-/OpenGL-Tests prüfen die echten Bedienelemente, einschließlich
kleinem logischem 360×640-Viewport, großer Schrift und unverzerrter Darstellung.

[Installationsanleitung](alpha1-rollback/START-HIER.txt) ·
[Testplan für Geräte](alpha1-rollback/TESTPLAN.txt).

## Einstieg bleibt bedienbar

**Geändert:** Bennos Einführungskarte und Bau-/Umzugsvorschau besitzen feste
Bildschirmgrenzen und einen Bereich zum Scrollen. Kurzzeitige Mindesthöhen beim
Textumbruch können sie nicht mehr über die Aktionsleiste wachsen lassen.
**Grund:** Der echte Touch-Test fand eine übergroße Einführungskarte, die den
ersten Fällen-Tipp abfing; große Schrift konnte auch die Bauvorschau verschieben.
**Spielernutzen:** Anleitung lesen und sofort tatsächlich spielen; alle Aktionen
bleiben erreichbar, auch auf kurzen Displays.
**Geschätzte Qualitätswirkung:** Hoch für den ersten Spieleindruck.

## Geprüfter Stand

19,673 numerische Headless-Prüfungen in 25 Suiten, zusätzlich
beide realen Progressionsläufe (insgesamt 27 Suiten) sowie Main-/Boot-Smokes.
612 OpenGL-Prüfungen in zwölf Suiten. Nach den Layoutkorrekturen
sind Umzug, Autobahnzeichnung und das gesamte Tutorial erneut per Touch geprüft.
Die Save-Prüfungen bestehen auch nach der atomaren Sicherungskorrektur.
[Prüfbericht](alpha1-rollback/automated-checks.json). Einige Desktop-Suiten melden
beim Prozessende ObjectDB-Aufräumwarnungen; der X11-Softwaretreiber unterstützt
keinen Wechsel des VSync-Modus. Kein Ersatz für einen Handy-/Temperaturtest.
