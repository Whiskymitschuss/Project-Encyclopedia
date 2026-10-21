# Alpha 1 — Einstieg, Stabilität und Testerverteilung

**0.28-alpha.1**, Android-Code **2801**, Launchername **Timber Loot Alpha**.
Gleiches Paket und gleiches Testzertifikat wie die Testversionen ab 0.23;
Spielstände bleiben bei einer Update-Installation erhalten.

## Einladender Einstieg — abgeschlossen

**Änderung:** Neuer Startbildschirm mit eigenem, isometrischem 3D-Diorama:
Wald → Werkstatt → kleine Stadt. Bestehende Modelle und das Biber-Logo bleiben
erkennbar. Orthografische Kamera und native Viewportgröße bewahren das Seitenverhältnis.
Spielen ist sofort möglich; Intro überspringen und reduzierte Bewegung funktionieren.
Wiederkehrende Spieler können sofort weiterspielen. Die Welt lädt erst nach der
Spielaktion; die Wirtschaft läuft nicht im Titelbildschirm weiter.

**Grund und Spielernutzen:** Der Start zeigt, was der Spieler später selbst aufbaut.
Ein klarer Startknopf führt ohne Wartepflicht zur echten Welt. Große Schrift und
kleine Bildschirme bekommen ausreichend Platz. **Geschätzte Qualitätswirkung: hoch.**

## Geführte erste Minuten — abgeschlossen

**Änderung:** Kurzer Empfang durch Benno, dann eine kleine kontextuelle Karte in der
Spielwelt. Echte Aktionen führen durch Fällen, Abliefern, Bretterproduktion, Verkauf,
bezahltes Platzieren und tatsächliche Fertigstellung der ersten Hütte. Die echte
Schaltfläche wird hervorgehoben. Keine Währungs- oder Materialgeschenke, keine
vorgefertigte Scheinwelt. Anschließend führt ein Knopf zu den bestehenden Kapitelzielen.
„Später“ pausiert die Anleitung; Wiederaufnehmen und Laden behalten den Fortschritt.
Bestehende Spieler werden nicht erneut in die Anleitung gezwungen.

**Grund und Spielernutzen:** Lernen durch wenige verständliche Handlungen, mit einer
sichtbaren ersten Erweiterung und einem nächsten Ziel. Der vierte Schritt verschwindet
nicht mehr vor der Platzierung aus der Zielanzeige. **Geschätzte Qualitätswirkung: hoch.**

## Fehlerkorrekturen und kleine Displays — abgeschlossen

- Android-Zurück schließt Fotomodus, Auswahlkarte, Bauvorschau oder Menü und öffnet
  sonst das Spielmenü. Speichern und Zurückkehren zum Titel sind erreichbar.
- Touch-Ereignisse werden vor einem Szenenwechsel abgeschlossen. Der Zugriff auf
  einen bereits abgelösten Viewport nach dem Antippen entfällt.
- Scrollbereiche reichen Berührungen an echte Texteditoren weiter. Testberichte
  lassen sich bearbeiten; Entwürfe bleiben beim Menüwechsel erhalten.
- Ungültige oder extrem große Straßenraster-Endpunkte werden vor der Wegerzeugung
  zurückgewiesen, statt eine endlose Schleife oder riesige Arrays zu erzeugen.
- Speicherdateien werden auf wesentliche Struktur und ungültige Zahlen geprüft.
  Eine gültige Sicherung wird bei defekter Hauptdatei genutzt. Sind beide beschädigt,
  überschreibt Autosave sie nicht. Eine ausdrücklich ausgewählte neue Firma kopiert
  zuerst die ursprünglichen Dateien unverändert in den lokalen Wiederherstellungsordner.
  Automatische Speicherfehler werden beim ersten Auftreten sichtbar gemeldet.
- Auf schmalen Displays zeigen kürzere Navigationsnamen und ein kompakter
  Ressourcenstreifen die wichtigsten Werte. Aktionsknöpfe behalten lesbare Beschriftungen
  und Platz für große Schrift. Das Feedbackmenü beginnt mit Kopieren, Sichern und Editor.

**Grund und Spielernutzen:** Die Alpha soll sich auch außerhalb eines inszenierten
Testprofils sicher bedienen lassen. Abbrechen, Laden, Rückkehr und Texteingabe
sind normale Wege des Spielers. **Geschätzte Qualitätswirkung: hoch.**

## Testerpaket und Rückmeldung — abgeschlossen

APK plus kurze [Installation](alpha1/START-HIER.txt), [Testplan](alpha1/TESTPLAN.txt)
und [Feedbackvorlage](alpha1/FEEDBACK.txt) als gemeinsames ZIP zum Weitergeben.
**Mehr → Alpha 1 · Testen & Feedback** erstellt im Spiel einen bearbeitbaren Bericht.
Er enthält Version, Betriebssystem, Gerätemodell, Ansicht und wenige Fortschrittszahlen.
Eine feste Liste begrenzt die Inhalte: kein kompletter Spielstand, keine Kontaktdaten,
keine eindeutige Gerätekennung, keine Pfade oder Zugangsdaten. Nutzertexte werden erst
durch eigenes Kopieren und Versenden weitergegeben. „Sichern“ schreibt nur in den
privaten App-Speicher, ohne neue Android-Berechtigung.

**Grund und Spielernutzen:** Tester können reproduzierbare Fehler und verständliches
Feedback melden. Der Eigentümer kann die APK gezielt weitergeben. Der bisherige
GitHub-Download ist **kein Zugangssystem mit Einladungen**. Es werden keine Tester
automatisch angeschrieben. **Geschätzte Qualitätswirkung: mittel bis hoch.**

Die Qualitätswirkung ist eine Design-Einschätzung, keine gemessene Nutzerstudie.
[Prüfungen und tatsächliche Grenzen](VALIDATION.md), [Android-Installation](ANDROID.md).

## Noch keine Zusage dieser Alpha

Hafen-/Schiffs- und Flughafen-/Luftexport bleiben geplant. Fotos bleiben in der
internen Galerie. Kein Cloud-Save. Die Alpha ist Debug-signiert; echte Android-
Installation, Geräteklang, Framerate, Wärme, Akku und langfristige Balance müssen
mit Testern auf realen Handys geprüft werden. Automatisierte Prüfungen belegen
keine vollständige Fehlerfreiheit oder Store-Reife.
