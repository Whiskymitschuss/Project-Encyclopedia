# Versorgung und Biberwelt · 0.28.6-alpha.1

Die gemeldeten Stillstände wurden mit erzeugten Firmenständen nachgestellt und
im vorhandenen Wirtschaftssystem korrigiert. Die Basis bleibt 0.28. Es werden
keine Gebäude, Lagerbestände oder laufenden Frachten zurückgesetzt.

## Behobene Versorgungslücken

| Änderung | Ursache und Umsetzung | Nutzen | Geschätzter Einfluss |
|---|---|---|---|
| Zutaten für fehlendes Baumaterial | Vollständige künftige Baurechnungen konnten sämtliche Bretter vor der Möbelfertigung schützen. Die Verarbeitung erkennt jetzt auch mehrstufige Abhängigkeiten zu fehlenden Baumaterialien und lässt dafür einen Arbeitsvorrat frei. Fertigwaren bleiben vor automatischem Verkauf geschützt. Bereits bezahlte Rechnungen werden weiterhin berücksichtigt. | Möbel, Bretter und andere benötigte Produkte können trotz großer Bauwarteschlange entstehen. | Hoch |
| Knappe Holzernte | Aktuelle Bauphasen laden verfügbare Ware vor konkurrierender Verarbeitung. Andernfalls konnte das Sägewerk jede kleine neue Holzmenge verbrauchen, bevor die Vorbereitung beliefert wurde. | Kleine Firmen können gleichzeitig bauen und die später benötigten Bretter herstellen. | Hoch |
| Eigene Lagerflotte | Fabriklieferungen der Zentrale nutzten bisher den allgemeinen Fuhrpark. Abholung und Fabrikversorgung teilen jetzt die tatsächliche weiß-blaue Lagerflotte. Steintransport und Export zählen diese Fahrzeuge nicht mehr als allgemeine LKW. Die schwarz-weiße Baustellenflotte bleibt getrennt. | Eine fertige Zentrale versorgt die Holzlinie auch ohne freien allgemeinen LKW; keine erfundenen zusätzlichen Fahrzeuge. | Hoch |
| Faire Disposition | Ständige Ladenlieferungen konnten die Abholung anderer Produkte verdrängen; bei gemischten Ausgängen kam zudem immer die erste Warenart zuerst. Abholung und Fabrikversorgung halten bei tatsächlichem Bedarf jeweils einen Auftrag in Bedienung. Lieferziele und Warenarten wechseln nach erfolgreichen Zuteilungen. Diese Reihenfolge wird gespeichert. | Dachmodule und andere Baustoffe bleiben bei laufenden Ladenaufträgen nicht dauerhaft am Hersteller liegen. | Hoch |
| Einzelne Betriebspause | Ein pausiertes Sägewerk stoppte die ganze Lieferlinie. Jetzt pausiert nur der gewählte Arbeitsplatz. Andere Betriebe dürfen vorhandene Ware verarbeiten; bereits gestartete Fahrten beenden ihren Auftrag. | Eine Pause unterbricht keine unabhängige Verarbeitung. | Hoch |
| Bauteams | Bisher rückten Teams nur bei Viertel-Sammelaufträgen automatisch nach. Nun gilt die automatische Übergabe auch für einzelne bezahlte Bau-/Ausbauaufträge. Bestehende Aufträge ohne diese Einstellung werden beim Laden ergänzt; ausdrückliche manuelle Zuweisungen bleiben erhalten. Unbesetzte Baustellen belegen keine neuen Liefer-LKW. | Wartende Baustellen bleiben nach Abschluss des vorigen Auftrags nicht dauerhaft ohne Personal. | Hoch |
| Ehrliche Lieferanzeige | Der Status unterscheidet reservierte Abfahrt, Beladen, Fahrt, Entladen und leere Rückfahrt. Entfernte Baustellen zeigen auch den Nachschub zum Abhol-Express und fehlende Straßen oder pausierte Zentrale. Das reine Nachsehen erzeugt keine Bestände. | Erkennbar, welcher Teil einer Lieferung noch fehlt. | Mittel bis hoch |
| Materialübersicht | Die große Zahl bleibt der Gesamtbestand aus Lager und Betrieben; darunter steht separat der tatsächliche Lageranteil. Die Kartenhöhe folgt den Schriftmaßen. Die Materialhilfe zeigt Baustellenstatus und echte Lieferphasen. | Lokale Werkstattbestände lassen sich von abholbarer Lagerware unterscheiden. | Mittel |
| Touch-Abstände | Welt-Warenbadges verwendeten einen festen unteren Randabstand und konnten nach Größen-/Schriftwechsel die Materialkarten verdecken. Sie berücksichtigen jetzt die tatsächlichen HUD-Grenzen; die Bedienleiste folgt auch Änderungen ihrer Mindesthöhe. | Materialkarten bleiben nach Fensterwechsel und mit Großschrift antippbar. | Mittel |

Die Einschätzungen beschreiben den erwarteten Nutzen, keine gemessene Verbesserung
auf einem bestimmten Handy. Originale private Spielstände wurden nicht verwendet.
Ware wird weiterhin erst nach tatsächlichem Entladen gutgeschrieben. Animationen
und Sichtweite entscheiden nicht über den wirtschaftlichen Fortschritt.

## Fortgesetzter Weltumbau

Zentrallager, Abhol-Express, Steinbruch und Steinwerk erhalten jetzt ebenfalls
zehn aufeinander aufbauende Architektur-Erweiterungen in ihren echten Hauptwelt-
Modellen. Dazu gehören Seitenschutz, Verladeportal, Regalgalerie, Dachtechnik,
Dispositionsbüro und Logistikleitstand beziehungsweise Werkzeugunterstand,
Stützwand, Schutzgalerie, Technikbucht, Siloanlage, Wartungssteg und Filteranlage.
Jede abgeschlossene Stufe verändert tatsächliche Mesh-Geometrie. Alle Ergänzungen
bleiben innerhalb der bestehenden Grundstücke: Zentrale 31 × 23, sonst 19 × 23.
Die vorhandenen Bestandsanzeigen, Bagger, Produktionscontroller und beiden
Zentralstapler bleiben angeschlossen. Anschlusspunkte sind benannt; kleinere
Aufbauten verschwinden früher aus der Fernansicht.

Damit besitzen alle **18 bereits vorhandenen Betriebsarten** Architektur-
Erweiterungen für die sichtbaren Stufen 1–10. Die wirtschaftlichen Maximalstufen
älterer Betriebe bleiben erhalten; oberhalb 10 bleibt deren letzte Architektur.
Dies sind modulare Erweiterungen vorhandener Modelle, keine Behauptung von
180 komplett neu entworfenen Fabrikgrundrissen. Geschätzter visueller Nutzen:
mittel bis hoch. Die folgenden Bildschirmaufnahmen sind zusätzliche QA-Ansichten,
keine getrennte Spielwelt.

## Prüfungen und tatsächlicher Reststand

`Tests/Supply286.gd` prüft große konkurrierende Rechnungen, knappe neue Holzernte,
Warenbilanz, unabhängige Pausen, gemeinsame Kapazität der Lagerflotte, automatische
und manuelle Bauteams, alte Aufträge, regionale Lieferstatus und JSON-Fortsetzung.
`Tests/Infrastructure286.gd` prüft 40 neue Architektur-Konfigurationen auf reale
Geometrieänderungen, Grundstücksgrenzen und Anschlusspunkte.
`Tests/VisualSupply286.gd` prüft die Hauptwelt-Integration, tatsächliche Fahrzeuge,
Lagerzeilen und Touch-Flächen auf kleinen Handyformaten.

Aktuelle vollständige Prüfergebnisse: [automated-checks.json](alpha1-supply/automated-checks.json).
[Hauptwelt](alpha1-supply/supply.png) · [Stufenvergleich 1/5/10](alpha1-supply/infrastructure.png).

**Der große Masterauftrag bleibt offen.** Der [Stand von 0.28.5](WORLD-REWORK-285.md)
gilt weiter, mit diesen Ergänzungen zu Gebäudestufen und Versorgung. Insbesondere
fehlen weiterhin ein durchgehender eigener Fußgängergraph, vollständige
Ein-/Aussteige- und Werkzeugwechselabläufe, eigenständige editierbare Szenen für
jede gewünschte neue Fabrik sowie Paletten-, Ziegel-, Beton-, Erz-, Stahl-,
Träger- und Schraubenproduktion. Dekorative Aufbauten sind keine zusätzlichen
wirtschaftlichen Maschinen. Nicht jede allgemeine Fabrik nutzt bereits lokale
Eingangsfrachten; der bestehende gemeinsame Rezeptbestand bleibt außerhalb der
zugewiesenen Holzlinie erhalten. Die Holzfällanimation ist noch kein vollständiger
Einzelauftrag mit individuell verfolgtem Stamm bis zum Endprodukt.

Nächste Baugruppe: getrennte, hindernisbewusste Arbeits-/Fußwege und weitere
Berufsabläufe; danach zusätzliche Materialketten mit echten Inventaren.

Desktop-Godot-/OpenGL-Prüfungen und Tests unveränderter APK-Ressourcen ersetzen
keinen Lauf auf dem S26 Ultra oder S24 FE. Temperatur, Akku, echte Handy-Startzeit
und langfristiger Produktionsdurchsatz müssen weiterhin am Gerät geprüft werden.
