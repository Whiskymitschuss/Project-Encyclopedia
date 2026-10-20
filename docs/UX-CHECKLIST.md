# Stadtgefühl 0.19 — vollständiges UX-Paket

| Wunsch | Tatsächliche Bedienung |
| --- | --- |
| Gebäudekarte unten | Haus oder Betrieb in der Welt antippen; Griff hochwischen oder Details wählen. Die obere Welt bleibt bedienbar. |
| Fehlmaterial lösen | Material an Baustelle oder Gebäudekarte antippen; verfügbaren Bestand, Produktionsquelle und LKW ansehen. Muttern, Schrauben und freigeschaltetes Notmaterial lassen sich für Spielmünzen kaufen. |
| Lieferwege hervorheben | Baustelle, Betrieb oder LKW auswählen; Wege anzeigen beziehungsweise ausblenden. Markiert werden tatsächliche gespeicherte Straßenfahrten. |
| Angekommen / unterwegs / fehlt | Baustellenkarte, Materialhilfe und ausführliche Baustellenverwaltung zeigen die Mengen getrennt. Ladenbestände werden nicht als zusätzliche private Fabrikbestände gezählt. |
| Bauen mit Vorschau | Unten Bauen öffnet die horizontale Wischpalette. Tippen beginnt eine unbezahlte Vorschau mit Drehung, Materialbedarf, Preis und Anschlussanzeige. Bestätigen führt den echten Bauauftrag aus. |
| Straßen mit dem Finger | Wege auswählen, Start berühren und bis zum Ziel ziehen. Kurve wechseln und Preis bestätigen. Vorschau zurücknehmen oder letzte unbenutzte gebaute Straße mit Erstattung rückgängig machen. |
| Betriebe als Gruppe | Wege → Viertel markieren: Bereich aufziehen und bestätigen. Namen ändern, Mitglieder und vollständigen Ausbauplan prüfen, gemeinsam bestätigen. Aufträge verwenden normale Materialbaustellen und begrenzte Bauarbeiter; frei werdende Kollegen übernehmen den nächsten Gruppenauftrag. |
| Ruhige Ereignisleiste | Hinweise am oberen linken Rand öffnen. Einträge führen zu tatsächlichen Engpässen und Bauorten; Abschlüsse bleiben gespeichert, auch bei Offline-Bau. Keine zusätzlichen Pflichtdialoge. |
| Übersichtskarte | Welt öffnet eine tatsächliche Karte mit Häusern, Betrieben, Bauplätzen, Baustellen, Waldregionen, Straßen und Stadtvierteln. Orte antippen. Gesperrte Gebiete zeigen die bestehenden echten Kosten/Voraussetzungen. |
| Benno | Begrüßung und tatsächlicher Offline-Ertrag bleiben erhalten. Konkrete fertige Gebäude und echte Versorgungsprobleme bestimmen seine Hinweise. Er bleibt hinter offenen Karten und Bauwerkzeugen verborgen. |
| Rückmeldung | Tatsächliches Entladen erzeugt eine begrenzte kurze Warenanzeige. UI-Sound, Baufeier und optionale Android-Vibration sind mit ihren eigenen Einstellungen verbunden. |
| Lesbarkeit | Feste Materialieningänge/-ausgänge, Zahlen und Zustandstexte neben Farben, skalierbare Schrift und Kontrast. Effekte reduzierbar; Einstellungen bleiben bei Prestige erhalten. |

# Zehn Baustufen je Stadtgebäude

Vierzehn Typen und 140 tatsächliche Modelle. Jede angrenzende Stufe verändert die Geometrie, hat einen eigenen Namen und bleibt innerhalb des vorhandenen Grundstücks. Hochhäuser erhalten tatsächliche Etagen. Feuerwachen kombinieren wachsende Fahrzeughallen und Leitstellen; Kliniken Behandlungsflügel, Rettungszufahrt und auf höheren Stufen Dachinfrastruktur. Hotels wachsen durch Etagen, Flügel und Gästeanlagen. Häuser, Landhäuser, Villen, Läden, Büros, Polizei, Taxis, Schulen, Nachtclubs und Parks besitzen eigene Entwicklungen.

Beim fertiggestellten Haus unter **Stufen 1–10** die Modelle in einer eigenen echten 3D-Vorschau durchsehen. Diese Vorschau gibt keine Waren, Gebäude oder Ausbaulevel. Erst der abgeschlossene reale Ausbau verändert das gespeicherte Gebäude.

# Prüfumfang und Grenzen

`Tests/CityUX.gd` prüft alle 140 tatsächlichen Geometrien und Grundrisse, Rechnung und Kauf von Viertelplänen, Schutz vor veränderten Preisen, Rücknahme mit korrekter Erstattung, JSON-Speicherung, alten Spielstand, Einstellungen bei Prestige und verdrahtete Menüs. `Tests/VisualCityUX.gd` prüft gerenderte Modelle und echte Engine-Touch-Eingabepfade: Gebäudegriff, Baupalette, Straßen, Kartenmarker, Eingabefeld mit Tastatur, Viertelauswahl, Materialquelle und fahrender LKW. Große Schrift und kleines Hochformatfenster werden berücksichtigt. Bestehende Produktions-, Speicher-, Bau-, Stadt- und Liefertests bleiben im vollständigen Lauf.

Die Eingabegesten sind synthetische Desktop-Ereignisse, kein physischer Android-Touchtest. Vibration, reale Android-Leistung und Geräteskalierung sind auf Hardware zu prüfen. Die bestehenden gemeinsamen Puffer zusätzlicher fortgeschrittener Fabriken werden dadurch nicht zu neuen individuellen LKW-Produktionsketten. Die vorhandenen Stadtdienste sind weiterhin ihre bisherige tatsächliche Gemeindesimulation; die UX erzeugt keine erfundenen Brände oder Hafenexporte.
