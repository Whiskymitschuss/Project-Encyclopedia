# Automatische Werkslogistik und anreisende Bauteams · 0.28.10-alpha.1

Fertige Fabrikwaren bleiben am Werk liegen, während andere Transporte die
Fahrzeuge belegen. Eine Holzpriorität und mehrere getrennte Dispositionsschleifen
garantierten bisher keine gleichmäßige Versorgung. Der Abhol-Express diente
hauptsächlich dem Nachschub aus der Zentrale. Viele Werke nutzten zusätzlich
noch entfernte Lagervorräte direkt statt eines tatsächlich belieferten Eingangs.

Diese Fassung verbindet die vorhandenen Produktionen, Lager und Baustellen in
der Hauptwelt. Bestehende Gebäude, Straßen, Fortschritte und Waren bleiben erhalten.
Die erweiterte Simulation beginnt mit einem fertiggestellten Zentrallager;
der Einsteigerbetrieb ohne Zentrale behält seine bisherigen Abläufe.

## Ein zusammenhängender Warenfluss

1. Alle vorhandenen produzierenden Werksarten werden automatisch bedient:
   Sägewerk, Trockenkammer, Möbelwerk, Fertighauswerk, Tischlerei, Pelletwerk,
   Papierfabrik, Design-Manufaktur, Steinbruch und Steinwerk.
2. Fertige Waren warten am tatsächlichen Ausgang. Ein weiß-blauer LKW holt sie
   zum nächsten geeigneten Zentrallager oder Abhol-Express. Auch ein pausiertes
   Werk kann seinen bereits vorhandenen Ausgangsbestand abholen lassen.
3. Werke erhalten Zutaten automatisch in ihren eigenen Eingang. Bestellungen
   und unterwegs befindliche Ladungen reservieren denselben begrenzten Platz.
   Erst nach dem Entladen steht die Ware für die Verarbeitung bereit.
4. Entfernte Baustellen nutzen den nächstgelegenen geeigneten Abhol-Express.
   Fehlender Regionalbestand wird tatsächlich nachgeliefert. Schwarz-weiße
   Baustellen-LKW übernehmen die letzte Strecke; die Fabrik wird nicht umgangen.
5. Ein Abhol-Express behält Material für seine versorgten Baustellen und einen
   Arbeitsvorrat naher Werke. Überschüsse gelangen mit echten Rücktransporten
   zur Zentrale, damit Endprodukte dort für weitere Aufträge und Verkauf nutzbar sind.

Eine gemeinsame Disposition wechselt Abholung, Werksversorgung und regionale
Transporte ab. Wartezeit und Ausgangsfüllung bestimmen die Reihenfolge innerhalb
der Aufgaben. Höchstens ein bevorzugter Holz-Shuttle hält den Wald in Betrieb;
die übrigen Fahrzeuge bedienen die allgemeine Warteschlange. Kleine Restmengen
werden kurz gebündelt. Die Fahrzeuge bleiben auch bei der leeren Rückfahrt belegt.

Die eigene Baustellenflotte verteilt ihre Fahrten ebenfalls fair. Ein großer
Auftrag kann nicht alle freien Fahrzeuge vor der ersten Lieferung an einen
kleinen Nachbarn belegen. Priorisierte Baustellen erhalten zwei Vergaberunden,
andere Baustellen weiterhin eine. Bereits gebuchte Fahrten bleiben erhalten.
Bezahlte aktive Altbaustellen werden auch dann automatisch aufgenommen, wenn ihr
alter manueller Anforderungsmarker noch ausgeschaltet war. Eine ausdrückliche
Baustellenpause oder eine manuelle Zuweisung von null Bauarbeitern bleibt wirksam.

## Mitarbeiter kommen tatsächlich zur Baustelle

Das Bauteam fährt von einer erreichbaren aktiven Arbeiterhütte im Sprinter los.
Es gibt höchstens zwei Sprinter mit jeweils vier Mitarbeiterplätzen, zusätzlich
zum Biberfahrer. Die Fahrzeuge tragen Leitern und Werkzeugkästen und besitzen
animierte Räder, Lenkbewegungen und eine Schiebetür.

Zugewiesene Mitarbeiter stehen erst nach ihrer tatsächlichen Ankunft auf der
Baustelle zur Verfügung. Ohne Ankunft und ohne Material der aktuellen Bauphase
entsteht kein Baufortschritt. Biber tragen Werkzeug beziehungsweise angelieferte
Bretter, bauen, hämmern und arbeiten in höheren Bauphasen auf Leitern. Reduzierte
Bewegung ergibt eine feste Arbeitspose.

Nach Abschluss, Pause oder Abzug eines Teams werden die Mitarbeiter abgeholt.
Biber, die noch vor Ort oder auf der Rückfahrt sind, können nicht gleichzeitig
auf einer anderen Baustelle eingesetzt werden. Auch am fertiggestellten Gebäude
bleibt eine wartende Bibergruppe bis zur Abholung sichtbar. Die Darstellung bleibt
begrenzt; Personalzahlen, Ankunft und Fahrten werden unabhängig davon simuliert.

Sprinter lassen sich direkt auf der Karte auswählen. Ihr Fahrzeugfenster zeigt
Mitarbeiter und Fahrtzweck statt einer erfundenen Warenladung. Ihre Routen sind
gegenüber laufenden Materialfahrten reserviert. Eine benutzte Straße und die
befahrene Arbeiterhütte lassen sich bis zur Rückkehr nicht entfernen/versetzen.

## Übersichtliche Bedienung

- **Logistik** ist direkt in der Hauptnavigation erreichbar. Vier Ansichten
  trennen Übersicht, Betriebe, Baustellen und Fahrten.
- Werke zeigen lokalen Eingang, tatsächliche Ladungen unterwegs und den Status
  ihrer Abholung. Engpässe verweisen zum betroffenen Betrieb.
- Baustellen unterscheiden zugewiesene und angekommene Mitarbeiter sowie
  fehlendes, fahrendes und geliefertes Material. Kleinteile können mit der
  angezeigten Münzsumme gezielt beschafft werden.
- Die Garage erklärt getrennt Lagerflotte, Baustellenfahrer und allgemeine LKW.
  Zusätzliche Lagerfahrzeuge erhält man durch Zentralausbau und Express-Standorte,
  Transportverbesserungen erhöhen Kapazität und Tempo.
- **Mehr** bietet vier Kategorien und eine Suchfunktion. Die Suche behält den
  Tastaturfokus. Alle bisherigen Funktionen bleiben erreichbar.
- Eine Zurück-Schaltfläche und die Android-Zurück-Taste führen durch die
  geöffneten Menüs zurück; Scrollposition und Logistikansicht bleiben erhalten.
- Gebäudedetails zeigen ihren eigenen Ausbau statt sämtlicher fremder Baustellen.
  Ein Baustellenlink öffnet den betreffenden Auftrag.
- Materialwerte unterscheiden Zentrale, Abhol-Express, Werk und unterwegs.
  Dieselbe regionale Ware erscheint nicht doppelt in der Quellenhilfe.
- Große allgemeine Liefertexte sind entfernt. Kleine Rückmeldungen erscheinen
  nur am ausgewählten Ort; die Routen bleiben ebenfalls an eine Auswahl gebunden.

Zentrale und Express besitzen wiederverwendbare 3D-Waren für alle vorhandenen
Materialarten. Sichtbar sind höchstens sechs beziehungsweise drei belegte
Regalplätze. Ein Regionalbestand mit Designmöbeln oder Steinen sieht dadurch
nicht länger leer aus. Das Steinwerk bekommt ebenfalls einen Biber-Stapler für
seine tatsächlichen Steinpaletten; loses Gestein und Kies bleiben Schüttgut.

## Bestandssicherheit und Kompatibilität

Alle Transporte besitzen genau eine Ladung. Abfahrt entnimmt sie dem Quellbestand,
Entladen schreibt sie einmal dem Ziel gut. Eingang, Ausgang, Warenannahme,
Regionalvorrat, Straße und Baustelle bleiben getrennte Eigentümer. Animationen
verändern kein Inventar. Vorhandene überfüllte Altbestände werden nicht gekürzt.

Die Migration legt leere Werkseingänge an; sie füllt diese nicht durch Teleportation.
Alte Eingänge eines neu zugewiesenen Lieferlinienbetriebs bleiben am dortigen
Abholregal erhalten. Passt eine schon fahrende Lieferung nach einer Linienänderung
nicht mehr zum Rezept, wird sie am tatsächlichen Ziel abgeholt. Unbeteiligte
Werkslieferungen blockieren den Start einer Lieferlinie nicht mehr.

Ein Baustellenbedarf wird einmal über die Lager verteilt reserviert. Regionalware
wird dabei nicht mehrfach gezählt. Bereits für eine andere Fabrik gebundene
Produkte gelten nicht fälschlich als verfügbares Baustellenmaterial. Ein eigenes
vorgemerktes Bauziel behält seinen Materialschutz.

Wirklich volle Gesamtlager, fehlende Rohstoffe, Pausen und fehlende Straßen können
die Produktion weiterhin begrenzen. Die Oberfläche erklärt diese Zustände.
Es gibt keine verdeckte Warenlöschung, keinen unbegrenzten Fuhrpark und keinen
automatischen Einkauf gegen den Willen des Spielers. Muttern und Schrauben werden
im vorhandenen Projekt weiter mit Spielmünzen beschafft; neue Hardwarefabriken
gehören zum noch offenen Masterumbau.

## Prüfungen und Grenzen

Die automatisierten Firmen werden aus Testdaten erzeugt. Ein privater Spielstand
oder ein echtes Android-Gerät liegt hier nicht vor.

Geprüft sind unter anderem alle zehn Produktionsfamilien mit vollen Ausgängen,
echte regionale Abholung und Baustellenlieferung, vollständige Warenbilanzen,
volle und pausierte Lager, automatischer Wiederanlauf nach freiem Regalplatz,
echte Werkseingänge ohne Anforderungstipp, Herkunft alter Linienwaren,
Bauteamanreise/Rückfahrt, unerreichbare Baustellen, faire Baustellenwellen und
eine identische Fortsetzung nach vollpräziser JSON-Speicherung.

Im kontrollierten Test erhält jede Produktionsfamilie ihre erste Abholung
innerhalb von 105 simulierten Sekunden. Sämtliche vorgegebenen Ausgänge werden
anschließend vollständig abgeholt; die Warenbilanz bleibt erhalten. Das ist
ein definierter Netztest, keine garantierte Lieferzeit für beliebige Spielstände.

Die OpenGL-Prüfungen verwenden die tatsächliche Hauptwelt: Sprinter mit Biber,
Passagiere, Auswahl, Werkzeug-/Leiterarbeit, Werk- und Baustellenansichten,
Menüsuche, Zurück-Navigation sowie kleine Bildschirme mit großer Schrift.
Unveränderte Dateien der gebauten APK werden zusätzlich am Desktop geprüft.

Die Offline-Berechnung der neuen Simulation wurde separat optimiert:
**22,1 → 17,9 Sekunden** für acht Stunden auf dem Desktop. Der vollständige
generierte Firmenstand ist davor/danach bytegleich. Dies ist ein Vergleich der
reinen Optimierung innerhalb dieser Fassung, kein Geschwindigkeitsversprechen
gegenüber einer älteren Version und keine gemessene Handy-Startzeit.

Echte Android-Temperatur, Akkuverbrauch und Dauer-FPS stehen aus. Der gesamte
[Masterumbau](WORLD-REWORK-286.md) bleibt offen. Dieses Update bearbeitet die
vorhandene Logistik, Baustellenmitarbeiter und Bedienung.

Android-Code **3005**, gleiches Paket und dasselbe Testzertifikat.
Als Update installieren; nicht deinstallieren und keine App-Daten löschen.
