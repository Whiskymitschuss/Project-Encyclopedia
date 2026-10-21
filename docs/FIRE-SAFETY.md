# 0.24 — Rauchmelder und Hydranten

## Bedienung und Wirkung

Öffne **Mehr → Einsatzzentrale → Rauchmelder & Hydranten**. An jedem fertiggestellten
bewohnten Stadtgebäude können Rauchmelder und ein Hydrant installiert werden.
Die Hauskarte führt ebenfalls zum Brandschutz.

Ein Rauchmelder kostet anfangs 125 Münzen und erkennt neue automatische Brände
sofort. Ohne Melder dauert die Erkennung zwölf simulierte Sekunden. Wer Rauch
selbst bemerkt, kann in der Einsatzzentrale sofort alarmieren. Melder verhindern
keine Brandereignisse und verändern bereits bestehende Alarme nicht nachträglich.

Ein Hydrant kostet anfangs 350 Münzen. Sein sichtbarer Standort liegt am straßenseitigen Rand des
Grundstücks; er versorgt bewohnte Gebäude im horizontalen Umkreis von 44 m, wenn
auch eine Straßenverbindung existiert. Bei Disposition wird der nächste geeignete
Hydrant gespeichert. Die eigentliche Löscharbeit dauert dann 24 statt 36 Sekunden.
Kein laufender Münz- oder Warenverbrauch. Die Preise folgen der vorhandenen
Unternehmensära; der vollständige Preis wird vor dem Kauf angezeigt.

Neue Installationen ändern keine bereits laufenden Einsatzzeiten. Aktive Quellen
und die Straßen der gespeicherten Wasserleitung sind bis zur Rückkehr geschützt.
Die Schlauchdarstellung wird erst beim Löschen eingeblendet und beeinflusst die
Simulation nicht. Die Versorgung bleibt nach dem Löschen als gekaufte Einrichtung
bestehen. Kein Gebäudeschaden und keine Strafzahlung wurden hinzugefügt.

## Einsatzzentrale

Die Zentrale zeigt die tatsächliche Zahl freier/belegter Löschfahrzeuge, eigene
Wache oder Gemeindehilfe, Erkennung, fehlende Straßenanbindung, Warteschlange,
Ankunftszeit, Löschfortschritt und verbleibende Arbeitszeit samt Wasserquelle.
Routinefahrten und Rückfahrten belegen denselben vorhandenen Feuerwehrpool.

Alte Schema-1-Spielstände bleiben gültig: unbekaufte Häuser bekommen nichts
berechnet, bestehende Brandalarme bleiben gemeldet, laufende alte Einsätze behalten
ihre bisherigen Zeiten. Ausrüstung, Alarmzeit, Wasserquelle und Schlauchroute
überstehen JSON-Speicherung und die bestehende Offline-Simulation.

## Frühere Abschnitte

# 0.21 — Brandschutz

Ab dem ersten bewohnten Stadtgebäude können alle 420 simulierten Sekunden bis zu
zwei Gebäudebrände entstehen. Es gibt keine zerstörten Gebäude, verlorenen Vorräte
oder Strafzahlungen. Brände sind eine zusätzliche Rettungsaufgabe, keine Kaufpflicht.

Die Feuerwehr teilt sich die begrenzten Plätze der vorhandenen Gemeindedienste.
Sie fährt über gespeicherte Straßen zum tatsächlichen Brandort, löscht 36 Sekunden
vor Ort und fährt zurück. Eine eigene Wache ersetzt die Nachbarschaftshilfe;
ihre vorhandene Ausbaustufe erhöht die Fahrzeugkapazität. Ohne freien Wagen oder
Straßenverbindung bleibt der Einsatz ausdrücklich wartend. Brandorte und Fahrwege
sind gegen Versetzen beziehungsweise Straßenabriss geschützt.

Unter Welt/Gemeindedienste sind Einsätze, Löschfortschritt und Kamerasprung zum
Brandort erreichbar. Meldungen und Abschlüsse erscheinen in der Ereigniszentrale.
Neue Gemeindefahrten ausschalten stoppt neue Brandereignisse; bereits gemeldete
Brände werden weiter versorgt. Speichern und Offline-Simulation erhalten den
Fortschritt; die Stadtkasse bekommt den bisherigen Gemeindebonus genau einmal.
Alte Schema-1-Spielstände starten ohne nachträglich erfundene Brandereignisse.

Validierung: vollständige bestehende Headless-Suite plus 24 neue Brandprüfungen,
inklusive Flottenlimit, Ankunft vor Löschen, JSON-Wiederaufnahme, blockierte Route,
Ereignisbudget, Gebäudeschutz und ausbleibende Doppelvergütung. Gerätetests stehen aus.

## 0.22 — Einsatzstadt und neue Oberfläche

Die Welt zeigt Flammen am Gebäudedach, aufsteigende Rauchwolken, zwei Einsatzkräfte
und zwei segmentierte Wasserstrahlen. Wasser und Mannschaft erscheinen erst nach
Ankunft des zugewiesenen Feuerwehrfahrzeugs. Effekte schwinden mit dem tatsächlichen
Löschfortschritt und verschwinden nach Abschluss. Pro Brand gibt es sechs Flammen,
fünf Rauchkörper und 16 Wassersegmente. Akkumodus zeigt nur zwei Rauchkörper;
reduzierte Bewegung stoppt das Flackern und die Rauchbewegung. Es gibt keine teuren
zusätzlichen Echtzeit-Lichtquellen. Stilistisch bleibt es die vorhandene Low-Poly-Welt.

Das gemeinsame UI verwendet flache, abgerundete Flächen mit Waldgrün, warmem Gold
und hellen Inhaltskarten statt der bisherigen plastischen Knopfflächen. Alle Menüs
verwenden dieses Design. Die Verwaltung ist nach Sicherheit, Produktion, Wegen,
Entwicklung und Einstellungen gegliedert. Ein aktiver Brand bekommt einen direkten
HUD-Zugang zur Einsatzzentrale; deren Liste zeigt Anfahrt, Wartezustand und echten
Löschfortschritt. Breite Ansichten begrenzen Menüs und Hauptleisten auf 760 logische
Pixel. Texte in Schaltflächen umbrechen, lange Titel werden begrenzt. Icons behalten
ihr Seitenverhältnis; `canvas_items` mit `expand` skaliert die Ansicht gleichmäßig.

`Tests/VisualFireUI.gd` prüft die tatsächliche OpenGL-Szene und vier Fensterformate:
360×640, 540×960, 591×1280 und 1280×800. Die Bilder zeigen ein eigens aufgebautes
Testprofil, keinen Nutzerspielstand. Desktop-Software-Rendering liefert keinen
Nachweis für Android-Framerate, Temperatur, Akku oder physische Touchbedienung.

## Weitere Ideen, bewusst noch nicht als vorhanden angeboten

- Weitere Präventionsmaßnahmen mit offen angezeigtem Nutzen; Rauchmelder und Hydranten sind seit 0.24 umgesetzt.
- Drehleiter und abgestimmte Verstärkung bei Hochhäusern, später Verletztenrettung.
- Eigene priorisierte Leitstellenansicht mit nachvollziehbaren Alarmursachen.
- Kleine, reparierbare Gebäudeschäden nur mit klarer Spielerinformation und sicherer
  Wiederherstellung; aktuell werden weder Waren noch Gebäude beschädigt.
- Wetterabhängiger Rauch und zusammenhängende Waldbrandeinsätze erst mit geprüftem
  Leistungsbudget und sicheren Wegen für Einsatzfahrzeuge.

Diese zusätzlichen Systeme sind Folgeideen. Die Fassungen 0.21/0.22 enthalten den
oben beschriebenen vollständigen ersten Brand- und Oberflächenabschnitt.
