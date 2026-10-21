# Prüfung 0.25 — Waldleben und Qualitätsüberarbeitung

- Vollständiges `bash scripts/test.sh`: **19.456 Prüfungen in 21 Headless-Suiten**,
  keine Fehler. Zusätzlich reale Ersthaus-Progression in 1.682 simulierten Sekunden
  ohne geschenkte Ressourcen sowie Starttests für Hauptwelt und Intro.
- **324 gerenderte Prüfungen in acht OpenGL-Suiten**: HUD, Intro, Gebäudekarte,
  City-UX, Feuerwehr, Hydranten, Architektur und Qualitätsfeedback. Die beiden neuen
  Suiten prüfen 32 Verhaltensfälle und 41 tatsächliche Grafik-/Layoutfälle.
- Bei der Bildprüfung gefundene Probleme wurden behoben: zu hohe Zielspur, mehrzeilig
  umbrechendes Münzfeedback und durch HUD/Rauch verdeckte Brandanzeigen. Betroffene
  Tests danach gezielt erneut ausgeführt. Zielanimation ohne Tween-Neuanlagen pro Refresh.
- 360×640, 540×960, 591×1280 und 1280×800; normale und große Schrift, gleichmäßige
  Bildskalierung, echte Touch-Auswahl und Scrollen. Der Zielbalken bleibt im Button,
  Währungen überschneiden sich nicht und Einnahmen bleiben innerhalb der Kopfkarte.
- Neue Verhaltenstests: echte Verkaufserlöse, keine Belohnung bei leerem Verkauf,
  genau ein Rettungssignal pro Abschluss, Pause/Materialfluss, reduzierte Bewegung,
  feste Effektbudgets, Meldungsreihenfolge, begrenzte Historie und fünf Gebäudestufen.
- Gerendert nachgewiesen: Baumwind verändert das OpenGL-Bild ohne Zustandsänderung;
  Premiumausbau ändert die sichtbare Architektur; Funken/Dunst/Licht und Brandbalken
  folgen dem tatsächlichen Einsatz. Wiederholtes Erfolgsfeedback wächst nicht über
  vier Effektplätze hinaus und verschwindet nach Ablauf.
- Vorschauen aus **inszenierten isolierten Testprofilen**, keine Handyaufnahmen:
  [Feuerwehr und HUD](preview-quality25-fire.png),
  [Premium-Sägewerk](preview-quality25-premium.png),
  [Wald](preview-quality25-forest.png).

Die Grafiktests verwenden Mesa/llvmpipe mit Xvfb. Startszene: 331 Draw Calls und
694.984 Dreiecke; inszenierte Stadt tagsüber: 431 / 696.198, nachts 524 / 697.248.
Das sind Desktop-Testwerte, kein Nachweis einer mobilen Bildrate. Sichtweite,
gebündelte Architektur und Effektobergrenzen bleiben aktiv. Akkumodus reduziert
Partikel, Wind und Brandlicht; reduzierte Bewegung unterdrückt dekorative Animationen.

Ein gelegentlicher ObjectDB-Hinweis beim Prozessende wurde im gezielten ausführlichen
Gebäudekarten-Nachlauf nicht reproduziert. Die Zielanimation erzeugt nun keine Tweens
mehr. Die vorhandenen Hinweise zu V-Sync unter Xvfb und ADBs nicht beschreibbarem
Heimverzeichnis betreffen den Testhost; Grafiktests und APK-Export sind davon getrennt.
Kein echter Android-Test von 0.25, keine Mobil-Framerate-/Akku-/Temperaturmessung,
keine neue Langzeit-Balancing- oder Store-Freigabe. 0.23 wurde vom Nutzer bestätigt.

Änderungen, Gründe, Spielernutzen und geschätzte Qualitätswirkung für jede Aufgabe:
[QUALITY-PASS.md](QUALITY-PASS.md).

## Auslieferung 0.25

APK aus Quell-Commit `f5de63c1166300e6083e6a4834c660929968ce52`, Version 0.25-test / Code 2500.
63091750 Bytes, SHA256 `b22b55074ce9dd1a675e83bd066cd3cd92458e30f0f1e6ef5e4f154f12c20e9a`.
Signatur wie 0.23/0.24, Paket unverändert. V2-Signatur, 16-KB-ZIP-Ausrichtung,
beide ARM-Architekturen, API 24+, Hochformat, Berechtigungen und Startszene geprüft.
Neue Feedbackskripte und Windshader sind tatsächlich im APK enthalten.

Passende Quell-ZIP: 329 Dateien, 19534243 Bytes,
SHA256 `ef3ba247f9effd276bdb8d5107f8f27634f4c79537cbccad7f916bcc5a2f1a04`.
Jede Datei gegen den Git-Blob des APK-Quellstands geprüft; keine Schlüssel,
Spielstände oder alten Release-Artefakte im Quellarchiv.

## Externer Download 0.25 geprüft

APK und Quell-ZIP unter dem festen Tag `v0.25.0-waldleben` vollständig per HTTPS
zurückgeladen. Beide liefern HTTP 200; Größe und SHA256 stimmen mit den lokal
geprüften Dateien überein. [Download-Prüfbericht](download-verification-25.json).
Das ist kein Android-Gerätetest.

## Historische Prüfung 0.24

# Prüfung 0.24 — Rauchmelder, Hydranten und Disposition

- Vollständiges `bash scripts/test.sh`: **19.424 Headless-Prüfungen**, keine Fehler;
  Spielszene und Startszene schließen ebenfalls erfolgreich ab.
- Darin **38 neue Brandschutzprüfungen**: exakte/zweifache/abgelehnte Käufe,
  keine Nebenwirkung reiner Abfragen, 44-m-Grenze, Straßenanbindung, tatsächliche
  Löschzeit, Quelle und Schlauchroute, gleichwertige Fortsetzung nach JSON-Laden,
  Detektion, manueller Alarm, unveränderte disponierte Zeiten, Altspielstände und
  Schutz einer ausschließlich von einer Schlauchleitung verwendeten Straße.
- Vollständiges `bash scripts/test_visual.sh`: **269 OpenGL-Prüfungen**, keine Fehler:
  23 UI-, 28 Start-, 87 Karten-/Touch-, 45 Stadt-UX-, 50 Brand-/Format- und 36 neue
  Brandschutzprüfungen. Software-OpenGL ist kein Android-Leistungsnachweis.
- Echte Touch-Ereignisse kaufen beide Einrichtungen und alarmieren einen Brand;
  Preise, Münzabzug und deaktivierte Folgebestellung werden überprüft. Die gekaufte
  Wasserquelle erscheint tatsächlich im Einsatz und hat eine begrenzte, statisch
  zusammengefasste Schlauchdarstellung. Rendering verändert keine Spielwerte.
- Vier Fensterformate einschließlich großer Schrift geprüft. Die neuen Bilder
  zeigen ein eigens aufgebautes Testprofil: [Welt](preview-protection24-world.png),
  [Einsatzzentrale](preview-protection24-services.png).
- Paket und Datenordner bleiben in der 0.23-Linie. Der Build-Helfer prüft die
  tatsächliche Zertifikatskontinuität gegen den öffentlichen 0.23-Fingerabdruck.
  Ein Kontrolllauf mit der historischen 0.20-APK wurde erwartungsgemäß wegen
  abweichendem Signierer abgelehnt, ohne die historische Datei zu verändern.
- Der Nutzer hat 0.23 im Chat als funktionierend bestätigt. Ein Handytest von 0.24,
  Temperatur/Akku und Langzeit-Balancing werden damit nicht vorweggenommen.

## Auslieferung 0.24

APK-Quellstand `34b5ee44807c827f022b95c805e8ba6690fe30e2`. Paket unverändert zur 0.23,
Version 0.24-test / Code 2400. APK: 63070697 Bytes,
SHA256 `657eae7c5d2e4dd1d3f548b12a7c95ecc6f143e9b04949b43471eb1a5d6b355e`.
Der tatsächliche Zertifikatsfingerabdruck ist weiterhin
`a49068da04643fb31c8d142035aaecaade43061142d7bd4571117890abbd41e9`.
V2-Signatur, 16-KB-ZIP-Ausrichtung, API 24+, beide ARM-Architekturen,
Hochformat/OpenGL und ausschließlich optionale Vibration geprüft. Startszene und
neue Brandschutzklasse sind tatsächlich im Paket enthalten.

Das passende Quell-ZIP enthält 312 Dateien, einzeln gegen den angegebenen
Git-Commit geprüft. Kein privater Schlüssel und keine APK im Quell-ZIP.

## Externer Download 0.24 geprüft

APK und passendes Quell-ZIP wurden nach dem Push vom festen Tag
`v0.24.0-brandschutz` vollständig über HTTPS zurückgeladen. Beide liefern HTTP 200;
Größen und SHA256 stimmen mit den gebauten Originalen überein.
[Download-Prüfbericht](download-verification-24.json). Dies ist kein Gerätetest.

## Historische Prüfung 0.23

# Prüfung 0.23 — neues Logo und Startintro

- Vollständiger `bash scripts/test.sh`: **19.386 Prüfungen**, keine Fehler, dazu
  Hauptszene und neue Startszene als eigene Headless-Smoke-Starts.
- Zwölf neue Startprüfungen: Bildressource, Seitenverhältnis, drei Intro-Phasen,
  zeitlicher Abschluss, unveränderte Spielzustände, reduzierte Bewegung,
  Überspringen, Schutz vor doppeltem Start und tatsächlicher Szenenwechsel ins Spiel.
- 28 zusätzliche OpenGL-Startprüfungen: vier Fensterformate, separate schmale
  logische Ansicht, passende Inhalts-/Touchflächen, tatsächliches Rendering sowie
  echte Touch-Ereignisse auf Überspringen und Spielen. Keine Geräteprüfung.
- [Gerenderter Startbildschirm](preview-startup23.png).
- Neue Paketkennung und neuer Testschlüssel sind auf ausdrücklichen Wunsch
  eingerichtet. Die alte APK 0.20 bleibt unverändert; keine Update-Kompatibilität
  zwischen den beiden Paketkennungen wird behauptet.

## Abschließende Auslieferungsprüfung 0.23

- Vollständiges `bash scripts/test_visual.sh`: **233 OpenGL-Prüfungen**, keine
  Fehler: 23 bestehende UI-, 28 Startintro-, 87 Karten-/Touch-, 45 Stadt-UX- und
  50 Brand-/Formatprüfungen. Software-OpenGL ersetzt keine Messung auf einem Handy.
- APK gebaut und geprüft: Paket `com.whiskymitschuss.timberloot.reborn`,
  Launchername `Timber Loot Neu`, Version 0.23-test, Code 2300, API 24+,
  ARM64/ARMv7, v2-Signatur und 16-KB-Ausrichtung. Ausschließlich optionale Vibration.
- `project.binary` in der APK enthält tatsächlich `res://Scenes/Boot.tscn` als
  Startszene; Logo, Introskript und Spielszene sind enthalten. Test- und
  Release-Verzeichnisse sind ausgeschlossen.
- APK: 63062152 Bytes, SHA256 `c03b2c999342dcad08dd4eba626ca0b8fa057ba448da5baf1556b46342491110`.
- Neuer Zertifikatsfingerabdruck: `a49068da04643fb31c8d142035aaecaade43061142d7bd4571117890abbd41e9`.
  Er unterscheidet sich ausdrücklich von der alten APK 0.20; die Paketkennung
  ist ebenfalls verschieden. Kein automatischer Ersatzschlüssel im Build-Helfer.
- Quell-ZIP: 303 Dateien, einzeln gegen den tatsächlichen APK-Quellcommit
  `6906cc4f52ecac6d6149031545dfa36c226ce6b0` geprüft. Vollständige Archivdaten im
  zugehörigen `.apk.json` und `releases/SHA256SUMS.txt`.

## Externer Download geprüft

APK und passendes Quell-ZIP wurden nach dem GitHub-Push vom festen Tag
`v0.23.0-neubeginn` vollständig über HTTPS zurückgeladen: beide HTTP 200,
Dateigrößen und SHA256 stimmen mit den gebauten Originalen überein.
[Maschinenlesbarer Prüfbericht](download-verification-23.json).
Dies bestätigt die ausgelieferten Dateien, keinen Start auf echter Android-Hardware.

## Historische Prüfung 0.21/0.22

# Prüfung 0.21/0.22 — Brandschutz, Einsatzstadt und Oberfläche

- Vollständiges `bash scripts/test.sh`: **19.374 Headless-Prüfungen**, keine Fehler,
  dazu der bestehende erste-Haus-Verlauf und abschließende Hauptszenenstart.
  Darin 24 neue Brandprüfungen zu tatsächlichen Zielen, Flottenbegrenzung,
  Straßenverbindung, Ankunft vor Löschen, JSON-Wiederaufnahme, Ereignisbudget,
  Gebäudeschutz und einmaliger Vergütung.
- Nach der letzten Priorisierung der Karteninhalte zusätzlich gezielt **1.931
  Headless-Prüfungen** (Verkehr/Touch und Gebäudekarten), keine Fehler. Diese sind
  eine getrennte Wiederholung und werden nicht zur vollständigen Suite addiert.
- `bash scripts/test_visual.sh`: **205 Desktop-OpenGL-Prüfungen**, keine Fehler:
  23 UI-/3D-Icon-, 87 tatsächliche Touch-/Karten-, 45 Stadt-UX- und 50 neue
  Brand-/Format-/Zugänglichkeitsprüfungen. Der Helfer nutzt einen bestehenden
  Bildschirm oder startet selbst Xvfb und räumt seine temporären Profile auf.
- Die neuen Grafikprüfungen rendern Flammen und Rauch am tatsächlichen Brandort,
  prüfen aufsteigenden Rauch, Ankunft vor Wasser/Mannschaft, begrenzte Effekte,
  Akkumodus, reduzierte Bewegung und das Entfernen nach dem Löschen. Rendering
  darf weder Geld noch Simulationsfortschritt verändern.
- Fenstergrößen 360×640, 540×960, 591×1280 und 1280×800: gleichmäßige Skalierung
  beider Achsen, begrenzte Lesebreite, sichtbare Navigation, scrollbare Inhalte
  und keine Überschneidung von Kopfzeile/Ziel bei normaler oder großer Schrift.
- Vorschauen: [Einsatz in der Welt](preview-fire22.png) und
  [Einsatzzentrale](preview-fire-services22.png), aus einem ausdrücklich aufgebauten
  Testprofil. Keine echten Nutzerspielstände wurden verändert.
- Software-OpenGL unter Linux ist kein Android-Geräte-, Leistungs- oder
  Langzeitbalancingnachweis. Audio wurde für die Grafiktests ausdrücklich durch
  den Dummy-Treiber ersetzt; Ton auf echter Hardware bleibt ungeprüft.
- Android-Export ist auf 0.22 / Code 2200 vorbereitet, aber **nicht gebaut**.
  Der bestehende Testsignaturschlüssel fehlt. Der Helfer bricht jetzt vor Downloads
  ab, statt einen inkompatiblen Ersatzschlüssel zu erzeugen. Die vorhandene
  signierte APK 0.20 bleibt unverändert.

## Historischer Prüfbericht 0.20

# Prüfung 0.20 — Waldstadt und gerundete Weltmodelle

- Vollständiges `bash scripts/test.sh`: **19.350 Headless-Prüfungen**, einschließlich 128 neuer Prüfungen für gerundete Geometrien, Normalen, Begrenzungen, Materialprofile und Kurvenfahrten. Erste normale Hausprogression weiterhin 1.682 simulierte Sekunden; Rathaus 1 bei 393 und Rathaus 2 bei 855 Sekunden. Kein Nutzerspielstand wurde für die Prüfungen verwendet.
- Nach der abschließenden Sichtweitenoptimierung zusätzlich **4.397 gezielte Headless-Prüfungen**: komplette Szene (4.092), Landschaft (177) und neue Weltgeometrie (128). Die vollständige ursprüngliche Suite sowie diese gezielten Wiederholungen sind getrennte Prüfläufe.
- Die bestehenden Stadtprüfungen erzeugen weiterhin alle fünfzehn Stadttypen auf Stufe 1–10: **150 tatsächliche Modelle**. Jede Stufe bleibt unterscheidbar und innerhalb des bisherigen Grundstücks. Produktions-/Transport-/Speicher-/Kapitelprüfungen bleiben Teil der vollständigen Suite.
- **128 neue Geometrie-/Regelprüfungen**: endliche Normalen, korrekte Vorderseiten, ursprüngliche Abmessungen, gemeinsame Meshes, gerundete Bäume mit nach außen gerichteten Normalen, erhaltene Wegpunkte, identische numerische Kurven nach JSON-Laden, 101 Positionen innerhalb des Straßenkorridors, Nachtlicht auch für neu erzeugte Fenster, funktionierende Maschinenknoten und begrenzte Sichtweite kleiner Details.
- **155 gezielte Desktop-OpenGL-Prüfungen nach der Sichtweitenoptimierung**: 14 neue Welt-/Detailstufenprüfungen, 9 Landschaftsprüfungen, 45 bestehende Stadt-/UX-Prüfungen und 87 Touch-/Gebäudekartenprüfungen. Echte Engine-GUI-Ereignisse prüfen weiterhin Auswahl, Scrollen, Schließen, Baupalette und Materialhilfe. Die neue Weltprüfung bestätigt die sichtbare Instanzauswahl, einfachere entfernte Geometrie und unveränderte Wirtschaft beim Kamerabewegen.
- Die Kurven sind eine abgeleitete Fahrdarstellung. Bezahlte Waren, ursprüngliche Straßenzellen, Reservierungen, Schutz vor Straßenabriss und gespeicherte Lieferuhren bleiben maßgeblich. Es werden keine neuen Fahrstrecken in den Graphen geschrieben. Gleiches Android-Paket und Speicherformat 1; kein Konvertieren oder Zurücksetzen vorhandener Firmen.
- Tatsächliche Renderings bei 540×960: neuer Starter-Spielstand sowie ausdrücklich aufgebautes Stadt-/Haus-/Nachtprofil. Wald und Fabriken verwenden echte Weltgeometrie. Die Vorschaubilder werden durch `Tests/VisualCrafted.gd` erzeugt.
- Im gleichen Desktop-Renderprofil sank die gemeldete Grafikmenge nach Sichtweitenauswahl und vereinfachten entfernten Baumformen am Start von **1.507.858 auf 685.674 Primitiven**, im Stadtbild von **1.559.568 auf 684.272**. Das sind Renderer-Zähler einschließlich Schatten, keine Smartphone-Framerate. Die finalen fünf Ansichten melden 253–457 Zeichenaufrufe und 587.556–738.394 Primitiven. Akkumodus, feste Instanzbudgets und sechs Vegetations-Batches bleiben aktiv.
- Android-Installation, Leistung, Akkulaufzeit und thermisches Verhalten dieser Version sind noch nicht auf echter Hardware geprüft. Der vorhandene Straßengraph bleibt rechtwinklig; frei gezeichnete Straßenbögen und die übrige vollständige Biom-Erneuerung sind weitere Schritte. [Umfang und Bedienung](WALDSTADT.md).

## Auslieferung 0.20

- APK-Quellstand: `f19ab74fe973d7586a5506749dd85f8f8d42865c`.
- APK: 58,422,147 Bytes; SHA256 `0b1928681b8d58b9720eedd97094d6b1d895a62702d8adb1d3d2d44c81cdaa86`.
- Quell-ZIP: 282 Dateien, 15,270,924 Bytes; SHA256 `bd5d6961c54522d8d2388294609ae4ac816c62198e065c3af834255e0f4d0231`. Alle Einträge gegen die Git-Blobs des APK-Quellstands geprüft. Das vollständige Git-Bundle ist ebenfalls verifiziert.
- Gleiches Zertifikat wie 0.19.2: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`. Paket `com.whiskymitschuss.timberloot`, Code 2000, API 24+, ARM64/ARMv7, v2-Signatur, 16-KB-Ausrichtung, Hochformat und erlaubte Vibration geprüft. Neue Modell-/Material-/Straßenressourcen sind im APK enthalten; Tests, Dokumentation, Releases und Hilfsskripte ausgeschlossen.
- Frische unabhängige GitHub-Kopie: **4.397 Headless-Prüfungen** (Szene, Landschaft und neue Geometrie), **14 Desktop-OpenGL-Prüfungen** mit echten Renderings, sauberer Quell-Checkout. Kein Nutzerspielstand für Tests verwendet.

APK, passende Quell-ZIP und alle fünf neuen Vorschauen wurden vom festen Tag `v0.20.0-waldstadt` vollständig per HTTPS mit HTTP 200 zurückgeladen. Größen und SHA256 stimmen mit gebautem Original und unabhängiger GitHub-Wiederherstellung überein. [Download-Prüfbericht](download-verification-20.json).

## Historischer Prüfbericht 0.19.2

# Prüfung 0.19.2 — Begrenzte Gebäudekarte

- Im alten Layout führt ein provozierter vorübergehender Inhalts-Mindestbedarf von 1.100 Pixeln dazu, dass die Karte über die Welt wächst und Bedienelemente oben aus dem Bild geraten: zwei gezielte Prüfungen schlagen vor der Korrektur fehl. Die isolierte normale Wiederholung allein stellte das Handyproblem in der Cloud nicht nach; der zusätzliche Layout-Stress prüft deshalb ausdrücklich die fehlende Höhenbegrenzung.
- Karte auf maximal 360 logische Pixel und den tatsächlich verfügbaren Bereich unter dem HUD begrenzt. Titel mit maximal zwei Zeilen und Schließen befinden sich außerhalb des Inhalts-Scrollbereichs. Text-/Mindesthöhenänderungen innerhalb des Scrollbereichs verschieben nicht mehr das gesamte Fenster. Bei schmalen logischen Ansichten stehen Aktionen untereinander.
- **19.222 Headless-Prüfungen**: vollständiges `bash scripts/test.sh`, einschließlich 437 neuer Layoutprüfungen, bisheriger Produktions-/Speicher-/Kapitelprüfungen und Hauptszenenstart. Normale erste Hausprogression weiterhin 1.682 simulierte Sekunden; Rathaus 1 bei 393 und Rathaus 2 bei 855 Sekunden ohne Ressourcen-Geschenke. Keine Änderung an Wirtschafts-, Preis-, Rohstoff- oder Speicherlogik.
- **437 Layoutprüfungen auch unter Desktop-OpenGL**: 144 programmatische Gebäudeauswahlen mit anschließenden Aktualisierungen; Fenstergrößen 540×960, 591×1280 und 360×640, jeweils mit normaler/großer Schrift. Zusätzlich vorübergehend überhoher Inhalt und anschließende Wiederherstellung. Die aufwendige Hintergrundgeometrie wird für diesen Layout-Stress ausgeblendet; der echte HUD bleibt aktiv.
- **87 neue Desktop-Touch-Prüfungen** über synthetische ScreenTouch-/ScreenDrag-Ereignisse: 32 wiederholte tatsächliche GUI-Tipps auf das Sägewerkssymbol, periodische Aktualisierung, vollständig unveränderte Wirtschaft während Auswahl, gedrückt gehaltenes Ziel bleibt bestehen, abgebrochener Tipp löst keine Aktion aus, Finger-Scrollen ohne Weltbewegung, erhaltene Leseposition, dauerhaft erreichbares Schließen und funktionierende Materialhilfe. Eine ausdrücklich auf 360×640 gesetzte logische HUD-Fläche testet die geringe Höhe unabhängig von der automatischen Canvas-Skalierung. Echte Baustelle und aktive Lieferung verwenden dieselben Grenzen.
- **45 bestehende grafische Stadt-/UX-Prüfungen erneut bestanden**, einschließlich Gebäudekarte, Hochwisch-Details, Palette, Straßen, echte LKW-Auswahl und Materialquellen. Zusammen mit Layout und neuer Eingabe ergeben sich 569 gezielte Desktop-OpenGL-Prüfungen dieser Korrektur.
- Welt-Materialanzeigen werden bei Überschneidung mit Gebäudekarte oder Baupalette verborgen und bleiben außerhalb dieser Flächen weiterhin bedienbar. Ein tatsächliches Rendering aus dem isolierten Testprofil liegt in [Vorschau](preview-card-fixed.png); es verwendet keinen Nutzerspielstand.
- Android-Version 0.19.2-test, Code 1920. Paket, Speicherpfad, Schema 1 und Testschlüssel bleiben erhalten. Ein echter Android-Hardwaretest des Updates steht weiterhin aus; Desktop-Eingabe und provozierte Layoutbedingungen belegen keine gerätespezifische Fehlerfreiheit.

## Auslieferung 0.19.2

- APK-Quellstand: `226519915f46e3f8e883190f6670422b8cbab86f`.
- APK: 58,396,802 Bytes; SHA256 `ad54a55a0b35d5370603c6e13f41f1eafedeb0639659c6800d52c150935198e3`.
- Quell-ZIP: 263 Dateien, 13,333,293 Bytes; SHA256 `a82d0385b2aa4bc943abd13fa582a2014cfecfee8ce9515083fb3a956f57c4da`. Alle Einträge gegen die Git-Blobs des APK-Quellstands geprüft. Das vollständige Git-Bundle wurde ebenfalls verifiziert.
- Zertifikat identisch mit 0.19.1: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`. Paket `com.whiskymitschuss.timberloot`, Code 1920, API 24+, ARM64/ARMv7, v2-Signatur, 16-KB-Ausrichtung und Hochformat geprüft. Keine neuen Berechtigungen. Tests, Dokumentation, Skripte und Release-Dateien sind aus dem APK ausgeschlossen.
- Eine unabhängige frische GitHub-Kopie importiert das Projekt und besteht die **437 Layout- sowie 87 neuen Desktop-OpenGL-/Touch-Prüfungen** erneut. Ihr Quell-Checkout bleibt sauber. Die vollständige Headless-Suite und die übrigen gezielten Grafikprüfungen wurden im ursprünglichen Checkout ausgeführt.

APK, passende Quell-ZIP und Karten-Vorschau wurden vom festen Tag `v0.19.2-cardfix` vollständig per HTTPS mit HTTP 200 zurückgeladen. Größen und SHA256 stimmen mit gebautem Original und unabhängiger GitHub-Wiederherstellung überein. [Download-Prüfbericht](download-verification-192.json).

## Historischer Prüfbericht 0.19.1

# Prüfung 0.19.1 — Zehn Kapitel und Rathaus

- Gesamter Prüfumfang: **18.785 Headless-Prüfungen**. Vollständige bisherige Suite plus abschließende gezielte Läufe für die betroffenen Kapitel- und Stadtregeln. Der erste gewöhnliche Hausbau bleibt bei 1.682 simulierten Sekunden ohne Ressourcen-Geschenke. Alle fünfzehn Stadttypen auf Stufe 1–10: 150 echte Modelle, unterscheidbare Meshes/Namen und unveränderte Grundstücksgrenzen.
- **215 neue Kapitel-/Rathaus-Prüfungen**: zehn Kapitel mit drei Zielen und Rathausabschluss; echte Ereigniszähler für globale sowie physische lokale Produktion; angekommene Ladungen genau einmal; volle Ausgänge und Pause; Annahme-Baselines; kein Fortschritt durch alte/gekaufte Vorräte; keine doppelten Prämien; Speichern und Prestige; kein vorgezogener Rathausausbau.
- Neue Startprogression ohne Münz-/Material-Geschenke: erstes Rathaus nach **393 simulierten Sekunden**, zweite Rathausstufe bei **855 Sekunden**. Bestehende Hilfsarbeiter, Produktion, LKWs, echte Verkäufe, Sägewerksausbau und Neueinstellungen werden verwendet. Keine gemessene Spielerdauer oder Aussage zur Spielerbindung.
- Ein ausdrücklich vorbereitetes fortgeschrittenes Profil prüft alle zehn tatsächlichen Rathaus-Baustellen nacheinander durch normale LKW-Anlieferungen und Bauarbeiter. Material-/Preisangebot und tatsächlicher Ausbau stimmen überein. Eine Zwischenstufe wird per JSON während des Bauauftrags gespeichert und fortgesetzt. Der Rathausstand verändert das Modell erst bei tatsächlicher Fertigstellung.
- Eigenes Verwaltungsgrundstück erlaubt das Rathaus auch bei vollständig belegten Wohnbauplätzen und null Einwohnern; kein zirkulärer Regionszwang. Ein Rathaus zählt nicht als Wohnhaus/Hochhaus und erfüllt nicht die entsprechende Zielbedingung. Mietbonus anhand tatsächlicher Hauskonten geprüft.
- Rückkehrbilanz verändert keine Bestände. Wiederholtes Ansehen und Resume-Meldungen zahlen nicht doppelt; bereits simulierte Hintergrundsekunden sowie ein veraltetes erstes Frame-Delta werden nicht erneut gerechnet. Alte Profile bekommen keine erfundenen Produktionsmengen oder heimlichen Auszahlungen.
- **223 Desktop-OpenGL-Prüfungen**: bisherige 183 plus 40 neue Kapitelprüfungen. Synthetische ScreenTouch-Ereignisse durch die tatsächliche Engine-GUI wählen Ziele, holen Prämien ab, öffnen Rathausvorschau, platzieren und bezahlen den realen Bau und nehmen Kurzaufträge an/ab. Laufender Fortschritt aktiviert dieselben Controls, ohne den Touch-Zielknoten während des Drückens auszutauschen.
- Kapitel, Rathaus, Auszeichnungen, Kurzaufträge und Rückkehrbilanz mit großer Schrift/Kontrast bei 540×960 und 360×640. Tatsächlich gerenderter 3D-Pokal mit einzeiliger Seitenanzeige. Fünf neue Vorschauen stammen aus dem isolierten Kapitel-Testprofil, nicht aus einem Nutzerspielstand.
- Android-Installation, Hardware-Touch, Vibration, Framerate, Akku, reale Spielerbindung und Langzeit-Balancing sind hier **nicht** durch Gerätetests belegt. Keine neuen Werbe-/Analyseanbieter oder Netzwerkberechtigungen. Details und alle Anforderungen: [Kapitel 1–10](CHAPTERS.md).

## Auslieferung 0.19.1

- APK-Quellstand: `cae1e85f08e2346ae490179dd2161fce587a8855`.
- APK: 58,396,701 Bytes; SHA256 `bd9fd6e2f1f9597f52eb965fbdeb24799eac8117dc3dfde56d867418ae98773a`.
- Quell-ZIP: 256 Dateien, 12,981,993 Bytes; SHA256 `5d58bf9f18af538d6fd488d183a9ff9decb134f0ea6abb9e2343558d3d4446a2`. Alle Einträge stimmen mit den Git-Blobs des APK-Quellstands überein.
- Gleiches Zertifikat wie 0.19: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`. Paket `com.whiskymitschuss.timberloot`, Code 1910, API 24+, ARM64/ARMv7, v2-Signatur und 16-KB-Ausrichtung geprüft. Runtime-Kapitel-, Rathaus- und Pokalressourcen enthalten; Tests, Hilfsskripte, Dokumentation und Releases aus dem APK ausgeschlossen.
- Monetarisierung bleibt ausdrücklich ein Plan. Keine Kaufabwicklung, Werbung oder neue Netzwerkberechtigung in dieser Test-App.

Eine unabhängige frische GitHub-Kopie bestätigt die vollständigen **18.785 Headless-Prüfungen**, den unveränderten ersten-Haus-Verlauf, den Hauptszenenstart und die **40 neuen Desktop-OpenGL-/Touch-Prüfungen** erneut. Der Quell-Checkout bleibt dabei sauber. Die übrigen 183 Grafikprüfungen gehören zum ursprünglichen Gesamtprüflauf.

APK, passende Quell-ZIP und alle fünf neuen Vorschauen wurden vom festen Tag `v0.19.1-journey` vollständig per HTTPS mit HTTP 200 zurückgeladen. Größen und SHA256 stimmen mit Original und unabhängiger Wiederherstellung überein. [Download-Prüfbericht](download-verification-191.json).

## Historischer Prüfbericht 0.19

# Prüfung 0.19 — Stadtgefühl und zehn echte Architekturstadien

- **18.518 Headless-Prüfungen**: bisherige 17.771 plus 747 neue Stadt-/UX-Prüfungen. Vollständiges `bash scripts/test.sh` bestanden, einschließlich Import, erster Hausbau nach unveränderten 1.682 simulierten Sekunden ohne Geschenke und Hauptszenenstart. Nutzerprofile werden nicht für Tests oder Aufnahmen benutzt.
- Alle 14 Stadtgebäudetypen auf sämtlichen Stufen 1–10 erzeugt: 140 tatsächliche Modelle. Meta-/UI-Namen stimmen überein, jeder benachbarte Ausbau verändert echte Mesh-Geometrie, alle Mesh-Ecken bleiben im gespeicherten Grundstück. Wohnhochhaus, Krankenhaus und Hauptfeuerwache sind tatsächliche wachsende Gebäude. Die normale bezahlte Materialbaustelle verändert die Architektur erst beim Arbeitsabschluss.
- Konkrete Materialhilfe unterscheidet gemeinsames Lager, lokale Produktionsausgänge und echte LKW-Ladungen. Ein zusätzlicher alter Produzent zeigt gemeinsamen Lagerbestand nicht als einen zweiten lokalen Vorrat. Baustelleninformationen trennen angekommen, unterwegs und tatsächlich noch fehlend.
- Benannte Viertel wählen reale Mitglieder über ihre Grenzen. Gesamtrechnung entspricht den tatsächlichen Einzelpreisen, auch unter Prestige. Zu wenig Geld oder ein veränderter Angebotspreis erzeugt keine Teilkäufe. Bereits laufende/maximale Upgrades werden nicht erneut bezahlt. Material und Bauarbeiter bleiben normale begrenzte Simulationsbestände.
- Ein einzelnes reales Bauteam baut mehrere gruppierte Materialprojekte nacheinander fertig. Die begrenzte Reserve großer Gruppen lässt Produktionsraum im Lager frei; normale bestehende Baustellenreserven bleiben erhalten. Wartende Gruppenbaustellen belegen keine Lieferfahrzeuge ohne Bauteam. Nach einem tatsächlichen Abschluss erscheint der neu zugewiesene sichtbare Bauarbeiter an der nächsten Baustelle. Explizite manuelle Zuweisung hat Vorrang.
- Neue Straßen zuerst tatsächlich gebaut und bezahlt, dann sicher rückgängig gemacht: exakt ursprünglicher Kaufpreis, kein zweiter Geldgewinn. Aktive gespeicherte Fahrwege verhindern Abriss/Rücknahme. Historie ist begrenzt und wird gespeichert. Viertelmarkierungen sind kostenlos und entfernen bei Löschung keine Gebäude.
- JSON-Restore erhält Gruppen, Ereignisse, Schrift/Kontrast, Vibration und Bewegungseinstellung. Alte Profile bekommen sichere Defaults. Prestige erhält Zugänglichkeit, Ton und Akkumodus, übernimmt aber keine alten Viertel oder Stadtmeldungen in die neue Firma. Echte Bauabschlüsse landen auch ohne existierende UI in der begrenzten persistenten Ereignishistorie.
- **183 Desktop-OpenGL-Prüfungen**: bisherige 138 plus 45 neue Stadt-/UX-Prüfungen. Tatsächlich gerenderte Hochhäuser und eigene Architektur-Viewport-Vorschau. Kamerastrahl trifft auch obere Hochhausetagen; Gebäudekarte überdeckt die feste Navigation nicht. Hochwischen öffnet Details, Benno bleibt hinter Karten verborgen.
- Physische Eingabepfade der Engine mit synthetischen ScreenTouch-/ScreenDrag-/Key-Ereignissen: horizontale Baupalette, kurzer Baukarten-Tipp, keine Kosten beim Wischen oder vor Bestätigung, Straßenzeichnen mit einem Finger, Bestätigung und Rücknahme, antippbare Übersicht, Fokus und Tastatureingabe am Viertelnamen, echte Regionsauswahl, Materialquelle und fahrender LKW mit markierter gespeicherter Straßenroute. Große Schrift und 540×960/360×640 getestet.
- Sieben gerenderte Vorschauen aus ausdrücklich aufgebauten Demonstrationsprofilen. Die reale Android-Eingabehardware, Vibration, Framerate, Akku und thermische Leistung wurden hier nicht geprüft. Die vorhandene Weltgröße und übrigen fortgeschrittenen gemeinsamen Produktionspuffer werden durch diese UX-Erweiterung nicht als neu erfundene Gameplay-Systeme ausgegeben. [Vollständige UX-Zuordnung](UX-CHECKLIST.md).

## Auslieferung 0.19

- APK-Quellstand: `81e784afb4c28fda17a315ad3287a7d061225930`.
- APK: 58,363,391 Bytes, SHA256 `6ae401c2656db11618360565d25661983aa19947393d30954319ee7bb2372c68`.
- Quell-ZIP: 239 Dateien, 12,099,048 Bytes, SHA256 `9cbda93ae25d2073babc5640ef73c4363081eb4a9d55ad37252dee1ffc4674b8`. Jede Datei gegen den Git-Blob des APK-Quellstands geprüft.
- Gleiches Zertifikat wie 0.18: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`. Versionscode 1900, Speicherformat 1, unveränderter Paket-/Speichername, API 24+, ARM64/ARMv7, v2-Signatur, 16-KB-ZIP-Ausrichtung, Hochformat und GL Compatibility geprüft. Die einzige deklarierte Berechtigung ist VIBRATE; sie unterstützt die optionale, anfangs ausgeschaltete Vibration.
- Neue Laufzeitmodule für Architektur, Stadt-UX, Übersicht, Vorschau, Palette und Routenmarkierung sind im APK enthalten. Tests, Build-Helfer, Release-Dateien und Dokumentationsbilder sind ausgeschlossen.

- Unabhängige frische GitHub-Kopie `/workspace/timber-restore-19`: alle **18.518 Headless- und 183 Desktop-OpenGL-Prüfungen**, erster-Haus-Verlauf und Hauptszenenstart erneut bestanden. Beide Arbeitskopien waren vor dieser Dokumentation sauber und auf demselben vollständigen Release-Commit.
- APK, passende Quell-ZIP und alle sieben neuen Vorschauen vom festen Tag `v0.19.0-cityux` vollständig per HTTPS mit HTTP 200 heruntergeladen. Größen und SHA256 stimmen mit Original und unabhängiger Wiederherstellung überein. Bericht: [download-verification-19.json](download-verification-19.json).

## Historischer Prüfbericht 0.18

# Prüfung 0.18 — Direkte Baustellenversorgung und stabile Materialanzeigen

- **17.771 Headless-Prüfungen**: die unveränderten bisherigen 17.337 Prüfungen plus 434 gezielte Logistikprüfungen. `bash scripts/test.sh` vollständig bestanden, einschließlich Import, erstem Haus nach 1.682 simulierten Sekunden ohne geschenkte Ressourcen und Hauptszenenstart.
- Nachgestelltes Unternehmenslevel-8-Profil mit aktiver Holzlinie, zwei LKWs, vollem Stationspuffer, lokalem Bretterausgang, global null Brettern und bezahltem Quartierspark. Ohne Level-10-Automatik oder manuelle Lagerentnahme holen tatsächliche Straßenladungen zwanzig Bretter am Sägewerk und zwei Bauelemente am Lager ab. Erst nach Lieferung und sieben Arbeitsphasen entsteht der echte Park.
- Pro Simulationstakt Erhaltung des Holzäquivalents über gemeinsame und lokale Vorräte, Waren unterwegs, Baustellenquittungen und Ladenverkäufe; keine negativen Mengen oder Überbuchung des gemeinsam gekauften Fuhrparks. Zwei Baustellen teilen fünf echte Bretter in Vierer- und Einser-Ladungen; wiederholtes Anfordern dupliziert nichts. Bauabbruch gibt diese Ladungen genau einmal zurück.
- JSON-Speichern mitten in der direkten Lieferung und anschließende Simulation ergeben denselben vollständigen Zustand wie der ununterbrochene Lauf, numerische Toleranz 1e-8. Insbesondere behalten float-geladene Gebäudereferenzen ihre ausschließliche Zuordnung zur Holzlinie, sodass alte gemeinsame Rezepte nicht zusätzlich laufen.
- Migration alter nicht angeforderter Materialprojekte aktiviert die Versorgung, erhält aber ausdrückliche Pausen, Rechnungen, Fortschritt, Puffer und bestehende Ladungen. Pausierter Bau entnimmt keine neue Ware; eine pausierte Holzlinie darf bereits vorhandene Ausgänge für unabhängige Baustellen abgeben. Unerreichbare Ziele entnehmen kein Material und melden die fehlende Straßenverbindung. Fertige Bausteine werden auch direkt am Steinwerk aufgenommen.
- **138 Desktop-OpenGL-Prüfungen**: 23 UI, 9 Landschaft, 22 bisherige Holz-/Baustellenanzeigen, 27 Verkehr/Touch, 27 Stein und 30 neue gerenderte Logistikprüfungen. Tatsächliche Holz- und Bretterfahrten mit bewusst gleichen numerischen IDs behalten getrennte Modelle. Boards bleiben während des Transports sichtbar, verschwinden nach tatsächlicher Entladung und die Rückfahrt heißt LEER. Erneute Takte schreiben keine zweite Quittung.
- Sägewerk und Möbelwerk besitzen dauerhaft getrennte Ein-/Ausgangssymbole und Zähler; volle und abgeholte Bretter wechseln nicht mehr die Holz-Identität. Ausgangszeilen passen bei 540×960 und 360×640 in ihre Weltanzeigen. Im Baustellenmenü stehen tatsächlicher Ursprung und bereits reservierte ankommende Mengen. Zwei Vorschauen stammen ausschließlich aus aufgebauten Demonstrationsprofilen.
- Android-Installation, Touch-Hardware und mobile Leistung der neuen Version wurden hier nicht auf einem realen Gerät geprüft. Das Update enthält keine vollständige neue Logistiksimulation für sämtliche alten fortgeschrittenen Fabriken oder eine Kollisions-/Ampelsteuerung.

## Auslieferung 0.18

- APK-Quellstand: `7ea1dfd7643fe95228d0d696d14ff3cb3c149fd7`.
- APK: 58,300,624 Bytes, SHA256 `279d5dcadd02f56b53c9b93ac2304fd743765fa3f348aa70444eed9b86c859a8`.
- Quell-ZIP: 210 Dateien, 10,537,974 Bytes, SHA256 `3313f02c382d64e3a853b0c8333ac6d2017d773e0d54555280039e5939fa57fd`. Jede Datei gegen den Git-Blob des APK-Quellstands geprüft.
- Gleiches Zertifikat wie 0.17: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`. Versionscode 1800, Schema 1, zusätzlich versionierte Baustellenmigration 1, API 24+, ARM64/ARMv7, v2-Signatur, 16-KB-ZIP-Ausrichtung, Hochformat, GL Compatibility und keine Berechtigungen geprüft. Neue Laufzeitlogik ist enthalten; Tests, Build-Helfer und Release-Dateien sind ausgeschlossen.

- Unabhängige frische GitHub-Kopie `/workspace/timber-restore-18`: alle **17.771 Headless- und 138 Desktop-OpenGL-Prüfungen**, erster-Haus-Verlauf und Hauptszenenstart erneut bestanden. Beide Arbeitskopien waren vor dieser Dokumentation sauber und auf demselben vollständigen Release-Commit.
- APK, passende Quell-ZIP und beide neuen Vorschauen vom festen Tag `v0.18.0-logistics` vollständig per HTTPS mit HTTP 200 heruntergeladen. Größen und SHA256 stimmen mit Original und unabhängiger Wiederherstellung überein. Bericht: [download-verification-18.json](download-verification-18.json).

## Historischer Prüfbericht 0.17

# Prüfung 0.17 — Steinrevier und Materialvorschau

- Vollständige Suite mit 231 Regel-, 4.092 Szenen-, 52 Platzierungs-, 42 Werkstatt-, 23 Begleiter-, 30 Alltagsszenen-, 213 Stadt-, 177 Landschafts-, 6.057 Holz-Lieferketten-, 56 Baustellen-, 1.494 Verkehrs-/Touch- und 4.870 neuen Steinprüfungen: **17.337 Headless-Prüfungen**, dazu erster-Haus-Verlauf nach 1.682 simulierten Sekunden ohne Geschenke und Hauptszenenstart. Der abschließende Stein-Test wurde nach der Korrektur wartender LKW-Darstellung erneut ausgeführt.
- Freischaltung erst auf Unternehmenslevel 5, keine Kosten oder Baustelle bei gesperrtem Kauf. Alte Spielstände erhalten null neue Rohstoffe. Atomarer Save-/Load-Weg erhält bezahlte Baupläne und deren ursprüngliche Materialrechnung. Erster Steinbruch lässt sich durch echte Holz-/Bretterlieferungen fertig bauen; ein späterer Ausbau wartet auch auf die letzte fehlende Kies-Einheit.
- Datengetriebene Rezepte, Materialnamen/-werte, Transportgewicht und vorhandene Icons geprüft. Schaufelmaterial wird erst nach dem Graben aus dem begrenzten Vorkommen entnommen; die Mulde erhält es erst beim tatsächlichen Ausschütten. Voller Ausgang und fehlender LKW stoppen die Gewinnung. Neue Felsader wird genau einmal bezahlt und kann einen nicht erschöpften Vorrat nicht überschreiben.
- Rezeptarbeit benötigt reale lokale Eingänge. Verbrauchten Rohstoff hält ein gespeicherter laufender Auftrag, bis daraus die korrekte Ausgabe entsteht. Pausieren hält die Arbeit an. Ein Produktwechsel verändert keine bereits angefangene Charge. Volle Ausgänge verbrauchen keine weiteren Rohstoffe.
- 600 Simulationstakte mit Erhaltung des Gesteinsäquivalents über Vorkommen, Schaufel, Abholmulde, LKW, lokalen Puffer, Arbeitsauftrag und fertige Lagerware. Bausteine entsprechen 3/5 Gestein pro Einheit, Kies 3/4. Jede lokale Kapazität und der gemeinsame gekaufte Fuhrpark werden pro Takt geprüft. Keine negativen Bestände, keine Gutschrift vor Entladung und keine doppelte Warenbuchung.
- Zwei Fahrzeuge führen eine Vierer- und eine Einser-Teilladung aus, ohne den Zielraum doppelt zu reservieren. Wird das Lager während der Fahrt gefüllt, bleibt die Ware auf dem wartenden LKW; nach Freigabe des Platzes wird sie einmal entladen. Unerreichbare Betriebe erzeugen keine Ersatzroute. Aktive Ursprünge und Ziele sind vor Standortänderungen geschützt.
- JSON-Save mitten im Abbau und laufenden Straßenfahrten liefert nach 300 weiteren Sekunden dieselben verschachtelten Daten wie die ununterbrochene Simulation. Numerische Toleranz 1e-8; `last_seen` wird als Wanduhr aus dem Vergleich ausgeschlossen. Mehrere Steinwerke liefern unabhängig Bausteine und Kies. Ein gekaufter LKW bedient über 1.600 Takte sowohl Holzlinie als auch Steinkette. Notmaterial lässt sich unter Geldboostern nicht mit Gewinn weiterverkaufen.
- Desktop OpenGL: **108 Prüfungen** aus 23 UI-, 9 Landschafts-, 22 Holzliefer-/Baustellen-, 27 Verkehrs- und 27 neuen Steinprüfungen. Vier neue Aufnahmen zeigen ausdrücklich aufgebaute, auf legale freie Grundstücke geprüfte Demonstrationsprofile. Keine Nutzerprofile wurden dafür verändert.
- Gerenderte Prüfung: geladene Schaufel, bewegter Oberwagen, unterschiedliche Kipper-/Paletten-Auflieger, echte Füllstände und mobile Produktionswahl. Ein beladener LKW am vollen Lager bleibt auch bei interpolierter Darstellung am Dock stehen. Bauvorschau zeigt die spätere Materialrechnung oberhalb der Bestätigung; Stadtbaustellen ab Level 4 werden bei gültigem Platz nicht mehr durch erst später anzuliefernde Materialien blockiert. Kleines Hochformatfenster geprüft. Touchgesten bleiben synthetische Desktop-Tests; reale Android-Hardware wurde hier nicht verwendet.
- Offen bleiben direkte Schaufelübergabe an einen wartenden Kipper, Steinplatten und zusätzliche Sand-/Metall-/Betonketten, vollständige Fahrzeugidentitäten/Kollisionen und echte mobile Leistungs- und Updateprüfungen. Siehe [Industrie-Masterplan](INDUSTRY-ROADMAP.md).

## Auslieferung 0.17

- APK-Quellstand: `662573b23cb9b3781b2f07085a314161070c4cb8`.
- APK: 58,296,429 Bytes, SHA256 `c0885fa3e9b514e54e04d5765891910262b792af78cf12bf00a37b3799f22c3f`.
- Quell-ZIP: 203 Dateien, 9,994,951 Bytes, SHA256 `163898d035ef3437979e0f899eb10b0d880fc4c4d507f1aba29fa867006911bc`. Jede Datei gegen den Git-Blob des APK-Quellstands geprüft; Release-Dateien sind aus dem Quellarchiv ausgeschlossen.
- Gleiches Zertifikat wie 0.16: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`. Versionscode 1700, Speicherformat 1, API 24+, ARM64/ARMv7, v2-Signatur, 16-KB-ZIP-Ausrichtung, Hochformat, GL Compatibility und keine Berechtigungen geprüft. Neue Skripte, SVG-Rohstofficons und `Economy/stone_industry.json` sind enthalten. Die Produktionsdaten wurden direkt aus dem APK gelesen und geprüft. Tests, Build-Helfer und Release-Dateien sind ausgeschlossen.
- Frische unabhängige GitHub-Kopie unter `/workspace/timber-restore-17`: Erstimport, alle **17.337 Headless-Prüfungen**, erster-Haus-Verlauf und Hauptszenenstart bestanden.

- Auch alle **108 OpenGL-Prüfungen** bestehen in der unabhängigen GitHub-Kopie. Die Wiederherstellung ist sauber; Änderungen nach dem APK-Quellstand betreffen ausschließlich Auslieferungsdateien und Dokumentation.
- APK, passende Quell-ZIP und vier neue Vorschauen vom festen Tag `v0.17.0-stone` vollständig per HTTPS mit HTTP 200 heruntergeladen. Alle Dateigrößen und SHA256 stimmen mit Original und unabhängiger GitHub-Wiederherstellung überein. Bericht: [download-verification-17.json](download-verification-17.json).

## Historischer Prüfbericht 0.16

# Prüfung 0.16 — Straßenfracht, Stadtdienste und Finger-Scrollen

- Vollständiger Lauf von `bash scripts/test.sh`: 225 Regel-, 4.092 Szenen-, 52 Platzierungs-, 42 Werkstatt-, 23 Begleiter-, 30 Alltagsszenen-, 213 Stadt-, 177 Landschafts-, 6.057 Lieferketten-, 56 Baustellen- und 1.494 Verkehrs-/Touchprüfungen: **12.461 Headless-Prüfungen**. Dazu der unveränderte erste-Haus-Verlauf nach 1.682 simulierten Sekunden ohne geschenkte Ressourcen und der Hauptszenenstart.
- Alle drei Materialstrecken sind Straßenfracht und teilen den tatsächlich gekauften Fuhrpark einschließlich Rückfahrten mit Bauprojekten. 460 Takte Stoffbilanz und weitere 480 Takte Flotten-/Ein-LKW-Prüfung. Kein neuer Bestand vor Entladung. Nachgelagerte Fahrten haben Vorrang. Unterbrochene beziehungsweise unerschlossene Zufahrten erfinden keine Strecke; ein vom Spieler gebauter Anschluss macht das entfernte Grundstück erreichbar.
- Migration ehemaliger Bandladungen: voller Ausgangspuffer, gesondert erhaltener Überlauf, keine Doppelgutschrift bereits angekommener Ware, vollständige Rückgabe beim Auflösen der Linie. Alte Spielstände ohne Stadtdienste erhalten sichere Standardwerte.
- Tatsächliche Gemeindefahrten für Polizei, Feuerwehr, Rettungsdienst und Taxis, begrenzte Dienstflotten, eigene Standorte mit Upgrades, Fahrgast erst nach Abholung und kein Fahrgast nach dem Absetzen. Einnahmen erst nach Hilfe beziehungsweise Fahrtabschluss; einmalige Abholung der Stadtkasse. Neue Fahrten ausschalten lässt bestehende Wege sauber enden.
- JSON-Speichern während laufender Dienste und anschließende Simulation liefern dieselben verschachtelten Zahlen und Zustände wie der fortgesetzte ursprüngliche Lauf. Ganzzahl-/Fließkomma-Darstellung wird numerisch verglichen, Toleranz 1e-8. Die Wanduhr `last_seen` wird beim Vergleich ausgeschlossen. Gespeicherte Standort-Referenzen schützen auch nach dem JSON-Roundtrip korrekt die aktive Fahrt. Ein versetztes Wohnhaus beendet seinen Spaziergang ohne Gutschrift; laufende Fahrzeugziele bleiben geschützt. Straßen können unter aktiven Fahrten nicht entfernt werden.
- Tatsächlich durch den Viewport geleitete ScreenTouch-/ScreenDrag-Ereignisse über Katalogkarten: Scrollweg, kein versehentlicher Bau-/Kaufauftrag, unbewegte Weltkamera, funktionierender kurzer Tipp und abgebrochene OS-Touchgeste. Die Scrollleiste ist nicht erforderlich. Keine reinen Aufrufe von Button-Callbacks als Ersatz für die Gestenprüfung.
- Desktop OpenGL: 23 UI-, 9 Landschafts-, 22 Liefer-/Baustellen- und 27 neue Verkehrsprüfungen, zusammen **81**. Echte gerenderte Dienstfahrzeuge, sechs Bewohnerwege, tatsächliche geladene Tiefbett-Auflieger, Taxi-Einstieg und sich bewegende Ladungen. Zusätzliche synthetisch eingespeiste ScreenTouch-/ScreenDrag-Ereignisse über `Input.parse_input_event` bei 540×960 und 360×640, einschließlich der Bildschirm-/Viewport-Skalierung. Das prüft den Eingabepfad der Engine mit Bildschirmkoordinaten, keine physische Touch-Hardware.
- Vier neue Vorschauen aus einem ausdrücklich aufgebauten Demonstrationsprofil: Stadtverkehr, Fracht, Dienste und gewischter Baukatalog. Vorhandene Nutzerprofile wurden nicht für Tests oder Aufnahmen verwendet.
- Keine Behauptung einer vollständigen Kollisions-/Ampelsimulation oder einer neuen End-to-End-Logistik für sämtliche alten fortgeschrittenen Fabriken. Die offenen Master-Phasen bleiben in [Industrie-Masterplan](INDUSTRY-ROADMAP.md) dokumentiert. Kein Android-Geräte-, Touch- oder Leistungsnachweis für die neue Version.

## Auslieferung 0.16

- APK-Quellstand: `c8c9e032f643d965e432773af4b6d334c62d3ed1`.
- APK: 58,257,975 Bytes, SHA256 `64253ea0dd1eaeee5f2e4e9cdb2105a86e36c2999a219b1a527319caaaafcab4`.
- Quell-ZIP: 177 Dateien, 8,892,181 Bytes, SHA256 `f17dc81dcbaff01bfd59c3a656e7d9dd6bd5a2b5e69ea9225f8346cd1391a081`. Jede Datei gegen den Git-Blob des APK-Quellstands geprüft; Release-Dateien sind aus dem Quellarchiv ausgeschlossen.
- Gleiches Zertifikat wie 0.15: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`. Versionscode 1600, Speicherformat 1, API 24+, ARM64/ARMv7, v2-Signatur, 16-KB-ZIP-Ausrichtung, Hochformat, GL Compatibility und keine Berechtigungen geprüft. Alle neuen Laufzeitskripte sind im APK enthalten; das entfernte Conveyor-Skript sowie Tests, Build-Helfer und Release-Dateien sind ausgeschlossen.

- Frische unabhängige GitHub-Kopie unter `/workspace/timber-restore-16`: Erstimport, alle **12.461 Headless-Prüfungen**, erster-Haus-Verlauf, Hauptszenenstart sowie alle **81 OpenGL-Prüfungen** erneut bestanden. Die Kopie hat einen sauberen Git-Status.
- APK, passende Quell-ZIP und alle vier neuen Vorschauen vom festen Tag `v0.16.0-traffic` vollständig per HTTPS mit HTTP 200 heruntergeladen. Alle SHA256 und Dateigrößen stimmen mit den Originalen und der unabhängigen GitHub-Kopie überein. Bericht: [download-verification-16.json](download-verification-16.json).

## Historischer Prüfbericht 0.15

# Prüfung 0.15 — Lieferwerk, erster Abschnitt des Industrie-Masterplans

- Lokaler vollständiger Lauf von `bash scripts/test.sh`: 225 Regel-, 4.092 Szenen-, 56 Platzierungs-, 42 Werkstatt-, 23 Begleiter-, 30 Alltagsszenen-, 216 Stadt-, 177 Landschafts-, 3.457 Lieferketten- und 56 Baustellenprüfungen: **8.374 Headless-Prüfungen** ohne Fehler. Zusätzlich erster-Haus-Verlauf ohne Geld-/Materialgeschenke nach 1.682 simulierten Sekunden und Hauptszenenstart.
- Lieferkette: lokale Ein-/Ausgangspuffer, reale Fahrzeiten, Holzäquivalent-Erhaltung über 260 Takte, ankommende Kapazitätsreservierung, produktionsabhängige Bandladungen, Möbelverkauf erst nach Ankunft, pünktlicher Bonus, 70-%-Spätpreis, Pause und Rückgabe der Vorräte beim Auflösen. Laufende Zuordnungen schützen Gebäude vor Standortänderungen.
- Baustellen: Geld-Upgrades vor Level 4, Migration vorhandener Firmen, sieben Phasen mit exakt aufgeteiltem Gesamtbedarf, Warten auf Material, reale Teilladungen und Straßenpunkte, begrenzter gemeinsam verwendeter Fuhrpark, fehlende spätere Hardware, exakte Depotkäufe, Pausieren, gemeinsame Crew-Zuweisung, Priority-Dispatch, zwei parallele Projekte, unerreichbarer Zielpunkt, sicherer Abbruch einschließlich Ladung und Ablehnung bei vollem Rückgabelager.
- Echter atomarer Save-/Load-Weg während einer Baustellenfahrt und Fortsetzung aller Arbeits-/Transportdaten. JSON-Zahlen werden als Zahlen verglichen; Fließkommatoleranz 1e-8, alle Struktur-/Mengenbedingungen bleiben erhalten. Ein dabei entdeckter Fehler durch JSON-Schlüsselreihenfolge wurde durch eine feste Dispatch-Reihenfolge beseitigt. Schreibende JSON-Ausgabe verwendet volle Fließkommagenauigkeit.
- Neue Szene prüft tatsächliche Materialanzeigen, deren Antippen, lokale Maschinen, Möbel-LKW-Ladung und sieben Bauteile. Bauarbeiter warten ohne Phantommaterial, tragen erst nach gültiger Lieferung und wechseln zum Werkzeugzustand. Frühe und alte Baustellen bleiben mit der bisherigen Fertigstellung kompatibel.
- Desktop OpenGL: 23 UI-, 9 Landschafts- und 22 Liefer-/Baustellenprüfungen, insgesamt **54** ohne Fehler. Enthalten sind tatsächlich gerenderte Materialicons, freie HUD-Bereiche, Ladung auf Hin-/Rückfahrt, reale teilweise belieferte Baustelle und kleine Portraitfenster mit skalierter UI.
- Vier Vorschauen aus einem ausdrücklich aufgebauten Demonstrationsprofil; keine Nutzerprofile werden dafür verwendet. Sie zeigen Lieferwelt, Materialbaustelle und deren Menüs. Kein echter Android-Geräte- oder Leistungsnachweis. Offene Master-Phasen: [Industrie-Masterplan](INDUSTRY-ROADMAP.md).

## Auslieferung 0.15

- APK-Quellstand: `7ca882361dc542394440f2b911725d8e4e78128f`.
- APK: 58.240.874 Bytes, SHA256 `cc18ae1e7ae29061beeff725b4ad74cd5e504a98e90ea79011ad111e58246c1a`.
- Quell-ZIP: 160 Dateien, 7.868.511 Bytes, SHA256 `a713e233e6d6f53670ed357c2f63b20f516f861bb9ccf498c69dcabfcd544cb2`. Jede Datei gegen den Git-Blob des APK-Quellstands geprüft.
- Gleiches Zertifikat wie 0.14: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`. Versionscode 1500, Speicherformat 1, API 24+, ARM64/ARMv7, v2-Signatur, 16-KB-ZIP-Ausrichtung, Hochformat, GL Compatibility und keine Berechtigungen geprüft. Alle neuen Laufzeitskripte liegen im APK; Tests, Build-Helfer und Release-Dateien sind ausgeschlossen.
- Frische unabhängige GitHub-Kopie unter `/workspace/timber-restore-15`: Erstimport, vollständige 8.374 Headless-Prüfungen, erster-Haus-Verlauf und Hauptszenenstart bestanden. Anschließend auch alle 54 OpenGL-Prüfungen in dieser unabhängigen Kopie bestanden.

- APK, passende Quell-ZIP und vier Vorschauen vom festen Tag `v0.15.0-delivery` vollständig per HTTPS mit HTTP 200 heruntergeladen. Alle Bytezahlen und SHA256 stimmen mit Originaldateien und der unabhängigen GitHub-Wiederherstellung überein. Bericht: `download-verification-15.json`.

## Historischer Prüfbericht 0.14

# Prüfung 0.14 — Ein lebendiges Waldtal

- 220 Regel-, 4.092 Szenen-, 56 Platzierungs-, 42 Werkstatt-, 23 Begleiter-, 30 Alltagsszenen-, 216 Stadt- und 177 Landschaftsprüfungen: 4.856 Headless-Prüfungen. Weiterhin frischer erster-Haus-Verlauf nach 1.682 simulierten Sekunden und abschließender Hauptszenenstart. Die Szenenanzahl berücksichtigt die Positionen der neu verteilten 1.000 Bäume; die bisherigen Bedingungen wurden nicht entfernt.
- Neue Landschaftsprüfung: tatsächlich gerendertes Gelände/Wasser, unveränderte Wirtschaft, flache alte und neue Bauflächen, Hügel, ausgesparter Bach und See, kontinuierliche Biomfarben, begrenzter fester Dekorationspool, freier Standort in einer Wiese, Vegetationsräumung beim echten Verschieben und Straßenbau, unveränderte Gebäudepositionen und eigener Akkumodus. Dekoration ersetzt keine nutzbaren Bäume.
- 23 bestehende OpenGL-Prüfungen plus neun neue Grafikprüfungen: Farbverarbeitung, ein separat gerenderter echter instanzierter Laubbaum mit grüner statt schwarzer Krone, tatsächlicher Instanzpuffer vor/nach Verschieben, sichtbare Wasserpixel im Bach sowie gültiger Vordergrund bei weitem Zoom.
- Der Kamerafehler wird bei 650 Einheiten Zoom mit 540×960 und 540×1170 geprüft: Auch die untere sichtbare Spielfläche liegt vor der Kamera und trifft den Boden. Das frühere flache Leerfeld unter der abgeschnittenen Landschaft wird damit gezielt abgedeckt.
- OpenGL-Aufnahmen aus ausdrücklich aufgebautem Demonstrationsprofil: frischer Einstieg, Gesamtansicht, Industrie, Bach/Brücke und 19-Uhr-Nebel bei der alten weiten Zoomstufe. Spielstände des Nutzers werden nicht für Aufnahmen verwendet.
- Wirtschaft, gespeicherte Gebäude und eigenes Straßennetz bleiben erhalten; feste Schotterzufahrten sind befahrbar. Bach, Picknickplatz und Aussichtsturm sind Landschaftselemente ohne neue Erträge oder Fahrlinien. Reale Android-Installation/Touch, Akku, Temperatur und Leistung dieser Version bleiben auf Hardware zu prüfen.

## Auslieferung 0.14

- APK-Quellstand: `8fdd1a6bd54cbfffe312b018c1785aa12293ddda`.
- APK: 58.181.415 Bytes, SHA256 `0634691f9fe0357572a417a5031dcfbeee2b87585eb252f0040fc43976f4fbb7`.
- Quell-ZIP: 126 Dateien, 6.847.459 Bytes, SHA256 `77fbc20fe249a91c4f7c0246baad6067d86a6ad3f8c1d5d51008ad5b8bbe7256`. Jede Datei einzeln gegen den Git-Blob des APK-Quellstands geprüft.
- Zertifikat SHA256: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`, identisch zu 0.13. Versionscode 1400, Speicherformat 1, v2-Signatur und 16-KB-ZIP-Ausrichtung geprüft; GL Compatibility, keine Berechtigungen. `ValleyLandscape` im APK enthalten; Tests und Release-Dateien ausgeschlossen.
- Frische unabhängige GitHub-Kopie: `/workspace/timber-restore-14`. Erstimport, 4.856 Headless-Prüfungen, erster-Haus-Verlauf und Hauptszenenstart dort erneut bestanden. Anschließend auch alle 32 OpenGL-Prüfungen in dieser Kopie bestanden.

- APK, passende Quell-ZIP und drei Landschaftsvorschauen vom festen Tag `v0.14.0-valley` vollständig per HTTPS mit HTTP 200 heruntergeladen. Alle SHA256 stimmen mit Originaldateien und der frischen GitHub-Wiederherstellung überein. Bericht: `download-verification-14.json`.

## Historischer Prüfbericht 0.13

# Prüfung 0.13 — Die erste Kleinstadt

- 220 Regel-, 4.139 Szenen-, 56 Platzierungs-, 42 Werkstatt-, 23 Begleiter-, 30 Alltagsszenen- und 216 neue Stadtprüfungen: 4.726 Headless-Prüfungen. Dazu frischer erster-Haus-Verlauf nach 1.682 simulierten Sekunden und Hauptszenenstart.
- Mietprüfungen: manuelle Konten, exakte Auszahlung, keine Doppelabholung, acht Stunden Offline-Miete, JSON-Roundtrip, einmalig bezahlte Hausverwaltung und kostenlose Beibehaltung automatischer Miete für alte Profile.
- Bauprüfungen: Voraussetzungen und Preis vor Erschließung, 24/36 verfügbare Grundstücke, tatsächlich fertig gebautes Haus im Ostviertel, Straßenanschluss, Meterpreis nur für neue Strecke, Abbruch ohne Kosten, Ablehnung bei Wasser, gesperrtem Viertel, Gebäuden oder fehlendem Anschluss. Asphalt und unabhängige Fußwege bleiben unterscheidbar.
- Verkehr: physisch freie Haltestellen, keine Busse auf Fußwegen, eindeutige Stationen, Einwohner-Voraussetzung, echte Graphverbindung, Bewegung und vier Sekunden Aufenthalt, Fahrgeld erst bei abgeschlossener Rundfahrt, JSON-/Offline-Fortschritt, Schutz von Haltestellen und Zwischenverbindungen gegen Abriss. Beschädigte/unverbundene gespeicherte Routen verdienen kein Geld.
- Szenenprüfungen: Werkzeug- und Transportstufen wechseln die sichtbaren Modelle, begrenzte Forstmaschinenzahl, bewegter Sägearm bei tatsächlichem Erntefluss, alle zwölf Gebäudemodelle samt Details innerhalb ihrer Grundstücksfläche, direkter Straßen-/Buszugang, echte Bestätigung aus der Weltvorschau, sichtbarer fahrender Linienbus, Antippen des Mietlabels und Förderverbindung für einen verschobenen Betrieb im Ostviertel.
- Zusätzliche 23 echte OpenGL-Prüfungen für 3D-Menüs, Portrait, Transparenz, Beleuchtung und Resume. Stadt, Maschinen, neue Bauflächen, Straßen-Vorschau und Busmenü werden aus einem ausdrücklich aufgebauten Demonstrationsprofil gerendert. Nutzerprofile werden dafür nicht verwendet.
- Begrenzungen: vereinfachte Nachfrage je Linie und gemeinsame Produktionspuffer; keine vollständige Kollisions-/Stausimulation und keine individuellen Exportfahrten. Echte Android-Updateinstallation, Touch/Safe Area, Ton, Temperatur und Akku bleiben für 0.13 auf Hardware zu prüfen. Der Nutzer hat zuvor 0.11 auf seinem Telefon als funktionierend bestätigt.

## Auslieferung 0.13

- APK-Quellstand: `7bc708e2e5d2e37865570c3d6007bf8c883831a4`.
- APK: 58.164.761 Bytes, SHA256 `8d293e89aa975fe5b49e8313a8a57b0210edc0a49aa3f77e8df90b5399be3225`.
- Quell-ZIP: 112 Dateien, 4.697.731 Bytes, SHA256 `8933dc51e059bd43120dcabec36e2b1ff5ecfd660c37cbf6ffcffc0d278f428d`. Jede Datei stimmt mit ihrem Git-Blob des APK-Quellstands überein.
- Zertifikat SHA256: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`, unverändert zu 0.12. Versionscode 1300, Speicherformat 1, v2-Signatur und 16-KB-ZIP-Ausrichtung geprüft; GL Compatibility, keine Berechtigungen. Neue Stadt-, Straßen-, Bus- und Forstmaschinen-Skripte sind im Paket enthalten; Tests und Release-Dateien sind ausgeschlossen.
- Frische unabhängige GitHub-Kopie: `/workspace/timber-restore-13`. Erstimport, vollständige Headless-Suite, erster-Haus-Verlauf und Hauptszenenstart dort erneut bestanden. Anschließend auch die 23 OpenGL-Prüfungen in dieser Kopie bestanden.

- APK, passende Quell-ZIP, Stadt- und Busvorschau vom festen Tag `v0.13.0-town` vollständig per HTTPS mit HTTP 200 zurückgeladen. SHA256 stimmen mit Originaldateien und der unabhängigen GitHub-Wiederherstellung überein. Bericht: `download-verification-13.json`.

## Historischer Prüfbericht 0.12

# Prüfung 0.12 — Waldleben

- 220 Regel-, 4.135 Szenen-, 56 Platzierungs-, 42 Werkstatt-, 23 Begleiter- und 30 neue Alltagsszenenprüfungen: 4.506 Headless-Prüfungen plus frischer erster-Haus-Verlauf und abschließender Start. Die unveränderte Wirtschaft erreicht das erste Haus weiterhin nach 1.682 simulierten Sekunden.
- Neue Prüfungen: kompatible alte Profile; keine Feier für Bestandsgebäude oder bloße Bauaufträge; Pausengast ohne zusätzliches Personal; Sitzpose/Tasse und Rückkehr; vollständiger Laufweg innerhalb des ursprünglichen und verschobenen/gedrehten Grundstücks; gegenseitige Begrüßung mit Abklingzeit; Schalter/Restore/Prestige; echte bezahlte Fertigstellung am gewählten Standort; begrenzte Zuschauer und fester Partikelpool; unveränderte Ressourcenrechnung; Akkumodus; Vorgartenspaziergang am tatsächlichen gedrehten Haus.
- Die bisherigen 23 echten OpenGL-Prüfungen für UI und Benno bestehen weiterhin. Bildausgabe von Hüttenvorplatz mit Pausengast und einer tatsächlich im Capture-Profil fertig gebauten Hütte geprüft. Beschriftung höher gesetzt, um Gebäudenamen nicht zu überdecken.
- Alle Capture-Bilder verwenden einen ausdrücklich aufgebauten Demonstrationsstand. Das Einfrieren des Pausengasts für das Foto verändert keine Nutzerdaten. Die Eröffnungsaufnahme verwendet einen bezahlten Bauauftrag und dessen echte Fertigstellung im Demonstrationsprofil.
- Der Nutzer hat Version 0.11 als auf seinem Handy funktionierend bestätigt. Für 0.12 sind reale Geräte-, Sound-, Temperatur- und längere Häufigkeitstests noch offen. Klang wird im Grafiktest mit Dummy-Audiotreiber erzeugt; hier wurden keine Lautsprecher geprüft.
- Straßennetze, Baukosten und Wirtschaft bleiben unverändert. Alltagsszenen sind kosmetisch, keine neue Schicht für Arbeitszeiten oder Fußgänger-Kollisionen. Park-/Hüttenausstattung ist Teil ihrer bestehenden Grundstücksfläche.

## Auslieferung 0.12

- APK-Quellstand: `6f083f473916141bcd5ae917641e463284a62c43`.
- APK: 58.114.729 Bytes, SHA256 `d52e3c4f4d9a50a20bf843d2d2ae721fc2ade62f3292c571ed899ad4763cc9a0`.
- Quell-ZIP: 91 Dateien, 3.148.768 Bytes, SHA256 `ef04674ddaa0e75e21ff65cc291c04e1f045d0ff730116108e46dbbe3211f30c`. Alle enthaltenen Dateien stimmen mit den Git-Blobs des APK-Quellstands überein.
- Zertifikat SHA256: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`, unverändert zu 0.11. Versionscode 1200, Speicherformat 1, v2-Signatur und 16-KB-ZIP-Ausrichtung geprüft; GL Compatibility, keine Berechtigungen.
- Neue unabhängige GitHub-Kopie: `/workspace/timber-restore-12`. Vollständige Headless-Suite nach Erstimport sowie anschließende OpenGL-Prüfung dort erneut bestanden. APK, passende Quell-ZIP und beide Vorschauen vom festen Tag `v0.12.0-cozy` vollständig per HTTPS mit HTTP 200 zurückgeladen. Alle SHA256 stimmen mit Originaldateien und GitHub-Wiederherstellung überein. Bericht: `download-verification-12.json`.

## Historischer Prüfbericht 0.11

# Prüfung 0.11 — Benno im Wald

- 220 Regel-, 4.135 Szenen-, 56 Platzierungs-, 42 Werkstatt- und 23 neue Begleiterprüfungen: zusammen 4.476 Headless-Prüfungen. Weiterhin frischer erster-Haus-Verlauf nach 1.682 simulierten Sekunden sowie abschließender Szenenstart.
- Begleiterprüfungen: kompatibles altes Profil, Begrüßung ohne Währungsänderung, Winkeauslöser, wegklickbare Blase, keine angebliche Fertigstellung bei bloßem Bauauftrag, Reaktion auf Fertigstellung, Menüs und Platzierung frei, Hinweise aus echtem Vorrat, Abschalten ohne Ereignisstau, Einstellung nach Restore/Prestige, erneutes Einschalten, nur einmaliger gleicher Tipp, tatsächlicher Offline-Bericht nur einmal und Rückkehrbegrüßung und korrekter Baum-Missionsschwelle nach Prestige.
- 23 OpenGL-Prüfungen: bisherige 3D-Menüs plus getrennte Portraitbeleuchtung, wirklich gerenderter transparenter Biber, sichtbare Silhouette und Änderung der gerenderten Pixel beim Winken.
- Begrüßung und Biber, Werkstatt, Baukatalog, Platzierung und neue Willkommen-Grafik unter OpenGL geprüft. Die fortgeschrittenen Capture-Bilder verwenden einen ausdrücklich aufgebauten Demonstrationsstand und eine inszenierte Feierblase; ihre Ressourcen sind kein Nutzerspielstand.
- APK-Gerätetest, Benachrichtigungen/Resume unter Android und langfristige Begleiterhäufigkeit bleiben auf Hardware zu prüfen. Kein Sprachsynthese-/Voiceover-System, keine Loginpflicht, keine täglichen Verluststrafen oder erzwungenen Belohnungsdialoge.

## Auslieferung 0.11

- APK-Quellstand: `66aab5d885a18d5446b4450fa6c9fc05724a7c5e`.
- APK: 58.102.026 Bytes, SHA256 `3588bc86c9f0364438e171aaed11e3dd8b9223bfe90c8d1add7a954c11b2997a`.
- Quell-ZIP: 82 Dateien, 2.580.510 Bytes, SHA256 `6f6e72f015b2900f377f049195421f1ac2a615530569beab3f786112a9039d0d`. Dateiinhalte einzeln gegen ihre Git-Blobs des APK-Quellstands geprüft.
- Zertifikat SHA256: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`, identisch zur bisherigen APK. Versionscode 1100, Schema 1, unveränderte Paketkennung und Speicherdatei, v2-Signatur und 16-KB-ZIP-Ausrichtung geprüft.
- Neue unabhängige GitHub-Kopie unter `/workspace/timber-restore-11`. Erstimport, vollständige Headless-Suite und anschließend separate OpenGL-Prüfung. Alle 4.476 Headless-Prüfungen, der erste-Haus-Verlauf, Hauptszenenstart und die 23 OpenGL-Prüfungen bestehen auch dort. APK, Quell-ZIP und Benno-Vorschau vom unveränderlichen Tag `v0.11.0-benno` vollständig per HTTPS mit HTTP 200 zurückgeladen; alle SHA256 stimmen mit den Originaldateien sowie den Dateien aus der GitHub-Wiederherstellung überein. Bericht: `download-verification-11.json`.

## Historischer Prüfbericht 0.10

# Prüfung 0.10 — Sculpted World

- 220 Regel-, 4.135 Szenen-/Geometrie- und 56 Platzierungsprüfungen. Der frische Spielverlauf erreicht das erste Haus weiterhin nach 1.682 simulierten Sekunden ohne zusätzliche Ressourcen.
- 42 Werkstattprüfungen einschließlich Schatten an/aus durch Standard-/Akkumodus. Zusammen 4.453 Headless-Prüfungen plus Progressionslauf und abschließender Hauptszenenstart.
- Separate echte OpenGL-Prüfung: sieben gerenderte 3D-Symbole jeweils auf sichtbare Silhouette, transparente Ränder und farbige beleuchtete Details geprüft. Die 3D-Szene der Symbole ist von der Welt getrennt. Druckzustand ändert das Flächenbild und Inhaltsabstand. Nach Anwendungsfortsetzung wird neu gerendert. 19 Prüfungen.
- OpenGL-Aufnahmen von Einstieg, offener Werkstatt, Baukatalog, Bauvorschau, Einführung und aufgebauter Stadt. Der fortgeschrittene Stand ist eine explizite Capture-Demonstration; kein Benutzerspielstand wird dafür verändert.
- Kein Größenlimit von 55 MB: Symbole, Oberflächen und Modelle werden ressourcenschonend aus eigener Geometrie und Vektoren erzeugt. Die Paketgröße allein ist kein Maß für Grafikqualität.
- Schattenleistung, Temperatur, Safe Area und Wiederaufnahme auf realen Android-Geräten sind weiterhin separat zu prüfen. Der Akkumodus stellt einen Ausweichmodus ohne neue Weltschatten bereit. Die Prüfungen hier sind keine Messung auf einem Telefon.

## Auslieferung 0.10

- APK-Quellstand: `54a6e86abaea53ac6a829e7a6c6598129320bc71`.
- APK: 56.585.744 Bytes, SHA256 `b44b4a8bfbd83339407d06e3a2c4b9cf246f069bf6fea96a678a6adb91150e2d`.
- Quell-ZIP: 69 Dateien, 1.947.082 Bytes, SHA256 `305f51e32f7f83226989e1c3d8466752a9c2b87b53f5d0aa99fb764d94aec796`. Jede enthaltene Datei stimmt mit ihrem Git-Blob am APK-Quellstand überein.
- Zertifikat SHA256: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005`, unverändert zu 0.9. Versionscode 1000, Spielstandschema 1, GL Compatibility, keine Berechtigungen.
- Wiederherstellung: neue unabhängige Kopie von GitHub unter `/workspace/timber-restore-10`. Zuerst Import mit `bash scripts/godot.sh --headless --editor --import --quit`, dann `bash scripts/test.sh`. Die gesonderte OpenGL-Prüfung ist `Tests/VisualUI.gd` und benötigt einen verfügbaren X11-/OpenGL-Bildschirm. Grafikprüfung nach dem Import ausführen; ein direkter Skriptstart vor dem Erstimport hat noch keinen globalen GDScript-Klassenindex.
- APK, passende Quell-ZIP und Vorschau vom festen Tag `v0.10.0-sculpt` vollständig per HTTPS zurückgeladen, jeweils HTTP 200 und identischer SHA256. Bericht: `download-verification-10.json`. In der neu geklonten Kopie bestehen nach dem Erstimport sämtliche 4.453 Headless-Prüfungen, der erste-Haus-Verlauf, Hauptszenenstart sowie die 19 OpenGL-Prüfungen erneut.

## Historischer Prüfbericht 0.9

# Prüfung 0.9 — Open Workshop

- Bestehende 220 Regel-, 4.135 Szenen-/Geometrie- und 56 Platzierungs-/Einführungsprüfungen unverändert im Umfang bestanden. Der frische Verlauf erreicht das erste Haus weiter nach 1.682 simulierten Sekunden ohne Zusatzressourcen.
- 40 zusätzliche Werkstattprüfungen: tatsächlich leere Maschine steht; echte Umwandlung treibt das Sägeblatt an; sofortige Pause friert Werkzeug und Werkstück ein; Materialmangel stoppt; ein Bediener arbeitet passend zur Maschine; alle acht Produktionsarten werden auf Stufen 1/10/100 instanziiert, ohne Ressourcen zu ändern; HUD bleibt bei drei Bildschirmgrößen innerhalb der Zeichenfläche.
- OpenGL-Bildausgabe unter Mesa/Xvfb: neuer Einstieg, offene Säge, Stadtansicht, Baukatalog, Platzierung und Willkommen aufgenommen. Die ausgebaute Welt und Materialvorräte sind ausschließlich ein Demonstrationsprofil des Capture-Skripts; kein bestehender Nutzerspielstand wird dafür geändert.
- Schema 1, Speicherdatei und Paketkennung unverändert. Paket/Versionscode 900, v2-Signatur und 16-KB-ZIP-Ausrichtung geprüft; Zertifikat stimmt mit 0.8 überein. Aus GitHub neu nach `/workspace/timber-restore-09` geklont; alle 4.451 Prüfungen, der frische Verlauf und der Hauptszenenstart erneut bestanden. Reale Geräteinstallation, Touch und mobile Leistung dieser Version sind noch nicht geprüft.
- Die Referenzbilder dienen als Richtung für offene Produktionsflächen und übersichtliche Bedienung. Modelle und Symbole sind eigene Geometrie/Vektoren. Es werden keine Screenshots oder Spielressourcen fremder Spiele in die App eingebunden.

## Auslieferungsstand 0.9

- Quell-Commit: `8a9f0eb7f1486d1d5b1f24616f057d718c3e62be`.
- APK: 56.577.150 Bytes, SHA256 `9ec4fe4252eb8914b908a50f0fa935b181a1e693f0def026e8f9420e379a15c1`.
- Quell-ZIP: 62 Dateien, 1.569.317 Bytes, SHA256 `6bc0400009cd0a514d63d338275179f5ccebc7cf52701264482c0b3bfec5fc4f`. Jede Datei gegen Git-Blob des APK-Quellstands geprüft.
- Zertifikat SHA256: `08b5b5b8d6edb6590545fe77f6f14248f6f14256c9edc781989ac41100ff1005` (unverändert).
- Beide externen HTTPS-Downloads vom unveränderlichen Tag `v0.9.0-workshop` vollständig mit HTTP 200 zurückgeladen und SHA256 mit den Originaldateien verglichen. Auch die APK und ZIP aus der unabhängigen GitHub-Kopie stimmen überein. Bericht: `download-verification-09.json`.

## Historischer Prüfbericht 0.8

# Prüfung 0.8 — Living Industry

- 220 Regelprüfungen: zusätzlich volles Sägespäne-Lager, korrekte Überlaufmenge, optionaler Verkauf, Weiterverarbeitung und Wiederanlauf einer gespeicherten Firma mit 2.500 Holz/Sägespänen. Restore kopiert Daten unabhängig, ohne den geladenen Ausgangsstand zu verändern.
- 56 Platzierungs-/Einführungsprüfungen: Straßen/Wasser/Überlappung, kostenlose abgebrochene Vorschau, bezahlte Baustelle, gesperrte doppelte Platzierung, Rotation und gespeicherter Standort, kostenloses Verschieben samt Erhalt von Stufe/Geld, frei positionierte Häuser, altes Profil ohne Zwangstutorial, neue Einführung, Spänebox und Förderverbindungen mit Straßendurchfahrt.
- Weiterhin 4.135 Szenen-/Geometrieprüfungen, frischer Verlauf bis zum ersten Haus und abschließender Hauptszenenstart.
- OpenGL-Bilder von frischer Welt, Baukatalog, Platzierungsvorschau, Willkommen und ausgebautem Demonstrationsstand geprüft.
- Android-Updateprüfung: neue Versionsnummer 800, unveränderte Paketkennung und bisheriger Testsignaturschlüssel. Paket- und Downloadprüfung werden beim finalen Export erneut ausgeführt.
- Finaler APK-Export bestanden: 56.560.291 Bytes, SHA256 `37c679d49c73a17f3d4672b9e4328060e47034bc9a9e86f58db01bdb967fffb1`, Quell-Commit `dfcaff6d05191fdd12b949b8eeec792eb6b24cc1`. Signatur stimmt mit der gespeicherten 0.7-APK überein; keine Android-Berechtigungen, ARM64/ARMv7, OpenGL, Hochformat und 16-KB-ZIP-Ausrichtung geprüft.
- Grenzen: echte Touch-/Installations-/Leistungsprüfung auf einem Telefon bleibt offen. Förderstrecken zeigen aktive Produktion und gemeinsame Materialpuffer; es gibt keine zusätzliche Fahrzeugkollision oder diskrete Simulation jedes einzelnen Bretts.

Wiederherstellung 0.8: Der frische GitHub-Klon `/workspace/timber-restore-08` wurde bis zum Quell-Commit `dfcaff6d05191fdd12b949b8eeec792eb6b24cc1` aktualisiert. Darin bestanden alle 220 Regel-, 4.135 Szenen-/Geometrie- und 56 Platzierungs-/Einführungsprüfungen, der frische Spielpfad und der Hauptszenenstart erneut.

Der folgende Bericht dokumentiert den ursprünglichen 0.7-Meilenstein; seine Hashwerte beziehen sich auf diese ältere Fassung.

# Prüfbericht zum Wiederaufbau

Stand: 19. Oktober 2026. Godot 4.6.3, GDScript; Version 0.7.0-test.

## Automatisierte Prüfungen

- **207 Regelprüfungen, keine Fehler:** Rucksack und Lagergrenzen; echte Ein-/Ausgänge der Verarbeitung; atomare Bezahlung; laufender Bau und Upgrades; doppelte Aufträge; Miete; Forschung; 100 Loot-Ziehungen; Boosterablauf; einmalige Missions-/Auftragsprämien; identische Vordergrund-/Offline-Simulation; Prestige und steigende Kosten; Crafting; Ausrüsten; permanente Loot-Upgrades; Regionen; Materialreservierung und automatische Einzelbestellung; drei Projektstufen; faire Materialzuteilung unabhängig von Betriebsreihenfolge; Save/Load und beschädigtes Hauptsave mit Backup-Fallback.
- **Frischer Spielverlauf:** Das erste Haus wird ohne Geld-/Materialgeschenke nach 1.682 simulierten Sekunden fertig. Danach erwirtschaftet es Ertrag. Startbedingungen sind dieselben wie im Spiel. Die Teststeuerung verwendet normale Aktionen, Aufträge und Verkäufe.
- **4.135 Szenen-/Geometrieprüfungen, keine Fehler:** Zehn Waldgruppen mit zusammen 1.000 Bäumen; Bäume auf Land und abseits der Straßen/Zufahrten; mobile Menüs und Grundstücksauswahl; aktiver Materialplaner; sofort sichtbare bezahlte Baustelle und Entfernung des Gerüsts nach Abschluss; Baumabbau; Welt-/Heimkamera und kleines Fenster.
- **Hauptszene:** Abschließender Headless-Start ohne GDScript-/Laufzeitfehler.
- **Echte Bildausgabe:** OpenGL-Start unter Xvfb und Mesa llvmpipe; frische Welt, ausgebauter Demonstrationsstand und Industrie-Menü aufgenommen und visuell geprüft. Dabei gefundener Kopfbereich-Umbruch korrigiert. Desktop-Audio im Capture-Lauf auf Dummy gesetzt; die selbst erzeugten Audio-Wellen sind implementiert, Lautsprecher wurden hier nicht geprüft.

## Android

Signierter Debug-Export für ARM64/ARMv7. APK-Integrität, Signatur, 16-KB-ZIP-Ausrichtung, Android 7.0+, Hochformat, OpenGL und keine angeforderten Berechtigungen werden im Build-Skript geprüft. Der endgültige Hash steht bei der APK im Paketbericht. Kein echter Handy-/Emulator-Starttest.

## Sicherung

Git-Meilensteine werden zum Repository übertragen. Abschließend wird aus GitHub in ein neues Verzeichnis geklont, der gespeicherte Stand geprüft und die APK mit dem lokalen SHA256 verglichen. Quell-ZIP und vollständiges Git-Bundle mit SHA256-Manifest ergänzen die externe Git-Sicherung. Ein nicht bestätigter Push gilt nicht als Sicherung.

Ergebnis der Wiederherstellungsprüfung: GitHub-Commit `6d4d65f65cc9d35ff635ec25a42084b29c53449b` wurde erfolgreich nach `/workspace/timber-restore-check` geklont. Dort bestand die vollständige Testsuite erneut (207 Regeln, frischer Verlauf, 4.135 Szenen-/Geometrieprüfungen, abschließender Start). Die zurückgeladene APK stimmt mit SHA256 `893e4ec1ea95a18881d1abf9ee0ac8caf16797699fd1d3bbb908755a4788041e` überein.

Beide direkten HTTPS-Downloads von `raw.githubusercontent.com` wurden vollständig abgerufen: APK HTTP 200, 56.531.203 Bytes; Quell-ZIP HTTP 200, 763.308 Bytes. Beide SHA256-Werte entsprechen `releases/SHA256SUMS.txt`. Das Quellarchiv enthält 43 Dateien, einschließlich Hauptszene, Regeln, Tests und Build-Helfern, ohne Cache, APK oder privaten Schlüssel.

## Offene Nachweise

Kein 50-Stunden-Spieltest, kein Android-Leistungs-/Akkuprofil, keine abschließende Touch-/Safe-Area-/Hintergrundprüfung, keine iOS-/Store-Freigabe. Die erwähnten 28 Minuten sind simulierte Wirtschaft, kein gemessener menschlicher Spieldurchlauf. Screenshots des ausgebauten Gebiets belegen die Darstellung und keine erspielte Progression.
