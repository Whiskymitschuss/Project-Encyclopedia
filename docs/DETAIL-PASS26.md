# Detailpass 0.26 – die zehn umgesetzten Ideen

Die Qualitätseinschätzungen sind Designprognosen; ein Nutzertest von 0.26 steht aus.
Alle Ergänzungen verwenden die vorhandene Wirtschaft, Wege, Bauzeiten und Ereignisse.

## 1. Rauch folgt dem Wind

- **Geändert:** Eine gemeinsame, langsam variierende Windrichtung steuert Baumkronen,
  Kaminrauch, Trocknerdampf, Brandrauch und Funken. Gedrehte Gebäude rechnen die
  Richtung in ihr lokales Koordinatensystem um.
- **Grund:** Effekte sollen räumlich zusammenpassen.
- **Spielerwert:** Glaubwürdigere, zusammenhängende Landschaft ohne neue Wettermechanik.
- **Geschätzter Qualitätseffekt:** mittel bis hoch, ständig in der Welt sichtbar.

## 2. Feuerwehr zum Hören

- **Geändert:** Entfernung und Richtung beeinflussen Sirenen, Feuerknistern und
  Löschwasser. Sirenen enden bei echter Ankunft; Wasser beginnt erst während der
  tatsächlichen Löscharbeit. Sechs Schleifen und vier kurze Stimmen werden wiederverwendet.
- **Grund:** Ein Einsatz soll auch ohne Blick auf die Zentrale wahrnehmbar sein.
- **Spielerwert:** Bessere Orientierung und erkennbare Einsatzphasen. Hörpunkt am
  betrachteten Gelände statt an der weit entfernten isometrischen Kamera.
- **Geschätzter Qualitätseffekt:** hoch bei Einsätzen. Audio wurde technisch mit
  Dummy-Ausgabe geprüft; Klang und Lautstärke auf einem Handy bleiben zu beurteilen.

## 3. Baumfällen mit Gewicht

- **Geändert:** Knacken beim Fällen, zeitversetzter Aufschlag und sichtbarer Stumpf
  am echten Baumstandort. Er verschwindet beim bisherigen visuellen Nachwachsen.
- **Grund:** Das Fallen erhält Anfang, Gewicht und sichtbare Folge.
- **Spielerwert:** Unmittelbar verständlicheres Fällfeedback; keine zusätzliche Holzquelle.
- **Geschätzter Qualitätseffekt:** hoch bei der häufigsten manuellen Aktion.

## 4. Wetter auf Oberflächen

- **Geändert:** Straßen und geeignete Dach-/Pflastermaterialien werden im Regen
  dunkler und glatter; 28 kleine Pfützen liegen auf dem echten Straßennetz.
  Im Akkumodus sind es zehn. Nach Regen trocknen Materialien sanft zurück.
- **Grund:** Wetter soll sich auch am Boden zeigen.
- **Spielerwert:** Mehr Atmosphäre ohne teure Spiegelungs- oder Bildschirmfilter.
- **Geschätzter Qualitätseffekt:** mittel. Neu gebaute Oberflächen übernehmen den
  laufenden Wetterzustand; Fenster behalten ihre bestehende Tag-/Nachtbeleuchtung.

## 5. Tiere im Wald

- **Geändert:** Sechs kleine Vögel und drei Hasen mit Flug-/Flügel-/Hüpfbewegungen;
  Holzfällen und nahe Waldarbeiter lösen Fluchtbewegung aus. Bodenanker meiden
  Straßen und belegte Grundstücke. Akkumodus: drei Vögel und ein Hase.
- **Grund:** Lebewesen geben dem Wald einen eigenen Rhythmus.
- **Spielerwert:** Ein lebendigerer Wald, ohne Jagd, Futterbedarf oder neue Aufgaben.
- **Geschätzter Qualitätseffekt:** mittel, besonders im nahen Wald.

## 6. Sichtbares Be- und Entladen

- **Geändert:** Vorhandene Holz-/Palettenladungen bewegen sich beim Beladen vom
  tatsächlichen Betrieb zum Fahrzeug und am Ziel zum Empfänger. Gespeicherte
  Lade-, Fahr- und Entladezeiten bestimmen die Animation; Rückfahrten bleiben leer.
- **Grund:** Materialübergaben sollen nicht wie plötzliches Ein-/Ausblenden wirken.
- **Spielerwert:** Besser nachvollziehbare Lieferkette. Kein zweites unsichtbares
  Materialkonto, keine veränderte Fahrzeit oder vorzeitige Lieferung.
- **Geschätzter Qualitätseffekt:** mittel bis hoch beim Beobachten der Logistik.

## 7. Enthüllung beim Bauabschluss

- **Geändert:** Erst nach dem wirklichen Abschluss gibt ein zurückweichendes
  Gerüst mit Baudunst das neue Modell frei. Eine kurze Höhenanimation endet bei
  exakt normaler Gebäudegröße. Vier Effektplätze werden wiederverwendet.
- **Grund:** Ein fertiggestellter Ausbau braucht einen erkennbaren Moment.
- **Spielerwert:** Sichtbare Belohnung für Bauinvestitionen; Bestand und Grundriss
  bleiben maßgeblich. Reduzierte Bewegung zeigt sofort das fertige Modell.
- **Geschätzter Qualitätseffekt:** hoch bei Neu- und Ausbauten.

## 8. Produktionsprobleme auf einen Blick

- **Geändert:** Bis zu drei kurze, nicht anklickbare Hinweise direkt am Betrieb
  erklären Pause, fehlendes/reserviertes Material oder vollen Ausgang. Holzlinie,
  allgemeine Rezepte und Steinindustrie werden aus ihren tatsächlichen Beständen
  ausgewertet. Ein ausgewählter Betrieb behält seinen Hinweis sichtbar.
- **Grund:** Stillstand soll ohne Menüs verständlich sein.
- **Spielerwert:** Schnelleres Erkennen der Ursache; Hinweise verdecken weder HUD,
  Gebäudekarte noch die bestehenden Materialschaltflächen.
- **Geschätzter Qualitätseffekt:** hoch für Orientierung und Spielfluss.

## 9. Ruhigere Kamera

- **Geändert:** Navigation und Zoom laufen weich zum Ziel. Ziehen folgt dem Finger
  direkt und bremst nach Loslassen kurz ab. Sichtweite und Detailstufen folgen dem
  tatsächlich gerenderten Ausschnitt. Menüs, Platzierung und abgebrochene Gesten
  stoppen die Trägheit; reduzierte Bewegung schaltet sofort um.
- **Grund:** Eine bewegte Kamera soll kontrollierbar bleiben.
- **Spielerwert:** Weniger harte Sprünge, verlässliche Gebäudefokussierung und
  weiterhin präzises Straßenzeichnen. Kein Dehnen des Seitenverhältnisses.
- **Geschätzter Qualitätseffekt:** hoch, bei fast jeder Kamerainteraktion.

## 10. Stadtpanorama und Fotogalerie

- **Geändert:** **Mehr → Fotomodus & Galerie** öffnet drei isometrische Winkel,
  Zoom und Aufnahme. HUD, Weltbeschriftungen und Auswahlmarkierungen verschwinden
  aus der Aufnahme. PNGs lassen sich in der integrierten Galerie durchblättern.
  Beim Verlassen kehrt der vorherige Bildausschnitt zurück.
- **Grund:** Spieler sollen ihren aufgebauten Ort festhalten können.
- **Spielerwert:** Saubere, unverzerrte Bilder ohne Spieleingaben beim Antippen.
  Fotos liegen auf diesem Gerät im App-Speicher und werden nicht automatisch gelöscht.
- **Geschätzter Qualitätseffekt:** mittel bis hoch für Ausdruck und Bindung.
  Die Galerie befindet sich im Spiel; eine automatische Übergabe an die Android-
  Systemgalerie oder eine Teilen-Funktion ist in dieser Version nicht enthalten.

## Grenzen und Prüfung

Die Darstellung schreibt keine neuen Werte in bestehende Spielstände. Es gibt keine
neuen Kernmechaniken, Betriebssystemberechtigungen oder fremden Grafik-/Sounddownloads.
Audio ist prozedural erzeugt und wiederverwendet. Dekorative Bewegung berücksichtigt
Bewegungs- und Umgebungsoptionen; Effekte besitzen feste Obergrenzen.

[Prüfbericht](VALIDATION.md) trennt Simulation, echte OpenGL-Bilder, Android-Paketprüfung
und noch ausstehende Handytests. Vorschaubilder zeigen isolierte, inszenierte Testprofile.
