# Holzfäller und Abholung · 0.28.7-alpha.1

Die Holzernte und die dazugehörige Abholung wurden im bestehenden Spiel korrigiert.
Basis bleibt 0.28; Paket, Testzertifikat und bestehende Firmen bleiben erhalten.

## Nachgestellte Stillstände

Mit 17 Arbeitern, Werkzeugstufe 10, Sammelstation Stufe 7, leerem Sägewerk und
voller Zentrale standen vorher drei bereits beladene Abhol-LKW dauerhaft vor
vollen Lagerplätzen. Nach 240 Simulationssekunden waren weiterhin alle drei
Fahrzeuge belegt, der Sägewerkseingang leer und die Holzernte bei null.
Eine zusätzliche Sammelstation mit freiem Platz wurde bei der Ernte ignoriert.

## Korrektur

- Bereits beladene Abhol-LKW dürfen nach der tatsächlichen Entladezeit in eine
  begrenzte Warenannahme der Zentrale entladen. Die Ware wird dort separat
  gespeichert, gezählt und bei freiem Platz einmalig eingelagert. Die LKW
  kehren regulär zurück und können anschließend wieder Werke versorgen.
- Die Annahme schafft keine zusätzlichen Fahrzeuge und gibt kein kostenloses
  Material. Neue Abholungen belegen reguläre Lagerplätze; der Annahmebestand
  und bereits ankommende Ware zählen gegen deren Reservierung.
- Manuelles Abliefern aus dem Rucksack kann bereits zugesagte Plätze nicht
  erneut besetzen. Passt nichts hinein, bleibt das Holz im Rucksack.
- Die Ernte nutzt alle aktiven Sammelstationen entsprechend ihrer tatsächlich
  freien Kapazität und Arbeitsleistung. Eine volle erste Station sperrt eine
  freie zweite Station nicht mehr. Pausierte Stationen produzieren nicht.
- Ein gespeicherter Überbestand führt nicht mehr zu negativer Ernte oder zum
  Abschneiden vorhandener Vorräte beim Verbuchen einer Nullproduktion.
- Die Sammelstation zeigt fehlende Holzfäller, volle/reservierte Lagerplätze,
  Pausen, fehlende Straßen oder den laufenden Abholauftrag an. Die Materialhilfe
  und das Zentrallager weisen den Bestand in der Warenannahme aus.

Im reproduzierten Rückstau laufen das echte Sägewerk, der Verkauf und anschließend
auch die autonome Holzernte wieder an. Das benötigt keinen manuellen Fällklick,
keinen Neustart und kein Zurücksetzen von Spielständen.

## Sichtbare Waldarbeit

Biber und Forstmaschinen beginnen Arbeitsbewegungen mit tatsächlich angenommener
Ernte. Bei einem Lagerstopp beenden sie ihren begonnenen Bewegungs-/Tragezyklus und
warten danach. Reduzierte Bewegung stoppt die Darstellung, nicht die Wirtschaft.
Automatische Baumfälle werden nahe der arbeitenden Waldmannschaft ausgewählt,
nicht beim entfernten Kamerafokus in der Stadt.

Die bisher 18 × 18 Meter großen freigeräumten Maschinenplätze wurden auf eine
zum Fahrzeug passende Fläche von 9 × 9 Metern begrenzt. Die kleine Fahrbewegung
bleibt innerhalb dieses Standbereichs. Dadurch stehen erreichbare Bäume nahe den
Maschinen; das Fahrgestell bleibt frei. Gelände und Walddeko verwenden dieselbe
Flächendefinition.

Animationen buchen keine Waren. Es bleibt eine Darstellung der vorhandenen
aggregierten Ernte, keine Behauptung einer schon vollständig implementierten
Einzelstamm-Verfolgung. Der [offene Masterumbau](WORLD-REWORK-286.md) bleibt offen.

## Prüfungen

`Tests/Forestry287.gd` reproduziert die volle Warenannahme, prüft Abholung,
anschließende Verarbeitung/Verkäufe und erneut angenommene Ernte. Enthalten sind
Warenbilanz, begrenzte Flotte, Lagerreservierung, mehrere Sammelstationen, Pausen,
Überbestände und die identische Fortsetzung nach JSON-Speicherung.

`Tests/VisualForestry287.gd` verwendet die tatsächliche Hauptwelt: Statuskarte,
Warenannahme-Anzeige, Erntestart, Biber-/Maschinenanimation, begrenztes Nachlaufen,
Baumfall nahe der Maschine, freie Standflächen und kleine Displays mit Großschrift.
Der vorhandene Animationstest für Holzfäller startet nun zuvor einen echten
Produktionstakt; eine Fällbewegung ohne angenommene Ernte wäre unzutreffend.

[Prüfbericht](alpha1-logging/automated-checks.json) ·
[Waldansicht](alpha1-logging/forest.png).

Echte volle Lager dürfen die Ernte weiterhin begrenzen. Kein Holz wird heimlich
verkauft, entsorgt oder an einem Lager vorbei teleportiert, um eine höhere Zahl
anzuzeigen. Bei bewusst pausierten Betrieben oder fehlenden Straßen ist die
angezeigte Ursache zu beheben. Fahrzeiten und reale Flottenkapazität gelten weiter.

Die Prüfungen verwenden erzeugte Testfirmen, keinen privaten Spielerstand.
Android-Gerätelauf, Wärmeentwicklung und langfristiger Durchsatz auf S26 Ultra /
S24 FE müssen weiterhin am Gerät gemessen werden.
