# Android-Test 0.27 — freie Welt & Handel

**Timber Loot Neu**, Paket `com.whiskymitschuss.timberloot.reborn`,
Version `0.27-test`, Code 2700. Als Update über die Versionen ab 0.23 installieren;
**nicht vorher deinstallieren**. Testsignatur und Speicherbereich bleiben gleich.

APK: `releases/Timber-Loot-Tycoon-v0.27-test.apk`. Android 7.0+, ARM64/ARMv7,
OpenGL ES 3.0 und nur optionale Vibration. Freies Bauen und Straßenexport benötigen
keine zusätzlichen Android-Berechtigungen und keine Internetverbindung im Spiel.

[Änderungen und Bedienung](WORLD-TRADE27.md), [Prüfbericht](VALIDATION.md).
0.27 ist eine Debug-signierte Testfassung. Echter Android-Gerätetest sowie mobile
Framerate, Wärme und Akkuverhalten dieser Version stehen aus.

Build mit `python3 scripts/build_android.py`; derselbe vorhandene Testschlüssel wird
verwendet und sein öffentlicher Zertifikatsfingerabdruck geprüft. Kein Ersatzschlüssel.
Private Schlüssel, Fotos und Spielstände werden nicht veröffentlicht.

## Historische Dokumentation 0.26

# Android-Test 0.26 — Detailwelt

**Timber Loot Neu**, Paket `com.whiskymitschuss.timberloot.reborn`,
Version `0.26-test`, Code 2600. Als Update über 0.23, 0.24 oder 0.25 installieren;
**nicht vorher deinstallieren**. Testsignatur und Speicherordner bleiben erhalten.

APK: `releases/Timber-Loot-Tycoon-v0.26-test.apk`. Android 7.0+, ARM64/ARMv7,
OpenGL ES 3.0, weiterhin ausschließlich die optionale Vibrationsberechtigung.
Fotomodus und integrierte Galerie speichern PNGs im privaten App-Speicher, ohne
zusätzliche Speicherberechtigung. Keine automatische Übertragung in die Android-
Systemgalerie oder Teilen-Funktion. App-Daten löschen oder Deinstallation entfernt
auch diese lokalen Fotos.

[Zehn umgesetzte Ideen](DETAIL-PASS26.md), [Prüfbericht](VALIDATION.md).
0.26 ist Debug-signiert. Android-Installation/Start, hörbarer Klang und mobile
Framerate, Wärme und Akkuverhalten sind noch nicht auf einem Handy geprüft.
Build weiterhin mit `python3 scripts/build_android.py`; der vorhandene Schlüssel
bleibt unter `/workspace/.timber-runtime/android/TimberLoot-Reborn-debug.keystore`,
außerhalb von Git und Quellarchiv. Der Helfer erzeugt keinen Ersatzschlüssel.

## Historische Dokumentation 0.25

# Android-Test 0.25 — Waldleben

**Timber Loot Neu**, Paket `com.whiskymitschuss.timberloot.reborn`,
Version `0.25-test`, Code 2500. Als Update über 0.23 oder 0.24 installieren;
**nicht vorher deinstallieren**. Testsignatur und Speicherordner bleiben gleich.
Die sieben Qualitätsaufgaben sind in [QUALITY-PASS.md](QUALITY-PASS.md) dokumentiert.
Logo, überspringbares Intro, Brandschutz und bestehende Spielstände bleiben erhalten.

APK: `releases/Timber-Loot-Tycoon-v0.25-test.apk`. Android 7.0+, ARM64/ARMv7,
OpenGL ES 3.0. Nur optionale Vibration. Die App ist eine Debug-signierte Testfassung;
Gerätetest, mobile Framerate, Wärmeentwicklung und Akkuverhalten von 0.25 stehen aus.
Die Installation von 0.23 wurde vom Nutzer bestätigt.

Reproduzierbarer Build: `python3 scripts/build_android.py`. Der Helfer verwendet die
Versionswerte aus dem Export-Preset und lehnt ein anderes Zertifikat ab.
Der private Testschlüssel liegt weiterhin ausschließlich unter
`/workspace/.timber-runtime/android/TimberLoot-Reborn-debug.keystore`.
Er wird weder neu erzeugt noch mit APK oder Quellcode veröffentlicht.

## Historische Dokumentation 0.24

# Android-Test 0.24 — Update der neuen App-Linie

**Timber Loot Neu**, Paket `com.whiskymitschuss.timberloot.reborn`,
Version `0.24-test`, Code 2400. Paket, Testzertifikat und Godot-Datenordner
`TimberLootReborn` bleiben wie bei 0.23. **Über die vorhandene 0.23 installieren,
nicht deinstallieren und keine App-Daten löschen.** Neue Brandschutzeinrichtungen
werden nur durch bewusste Käufe hinzugefügt; alte Profile bleiben gültig.

Die Datei liegt unter `releases/Timber-Loot-Tycoon-v0.24-test.apk`.
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0, nur optionale Vibration. Das neue
App-Symbol und Startintro aus 0.23 bleiben erhalten. Die ursprüngliche Linie
`com.whiskymitschuss.timberloot` bis 0.20 ist weiterhin ein anderes Paket.

Der Nutzer hat Installation, Intro und Spielstart von 0.23 im Chat bestätigt.
Ein entsprechender Gerätetest von 0.24 steht bis zur Rückmeldung weiterhin aus.
Automatisierte Tests ersetzen keine Messungen von Framerate, Temperatur und Akku.

`python3 scripts/build_android.py` verwendet Version und Paket direkt aus dem
Export-Preset. Nach dem Signieren muss der Zertifikatsfingerabdruck mit der
veröffentlichten 0.23 übereinstimmen; ein abweichender Signierer wird abgelehnt.
Der vorhandene Schlüssel unter
`/workspace/.timber-runtime/android/TimberLoot-Reborn-debug.keystore` bleibt
unverändert, außerhalb von Git. Fehlt er, bricht der Helfer ab und erzeugt keinen
Ersatz. APK-Bericht, ZIP-Ausrichtung und verpackte Startszene werden geprüft.

## Historische Dokumentation 0.23

# Android-Test 0.23 — neue App-Linie

Die neue Test-App heißt **Timber Loot Neu**, Paket
`com.whiskymitschuss.timberloot.reborn`, Version `0.23-test`, Code 2300.
Android 7.0+, ARM64/ARMv7, OpenGL ES 3.0. Nur die optionale Vibrationsberechtigung.

Der Nutzer hat am 21.10.2026 ausdrücklich einem Neustart ohne Spielstandübernahme
zugestimmt. Deshalb verwendet diese Linie einen neu erzeugten Testschlüssel und
`TimberLootReborn` als separaten Godot-Datenordner. Die alte App
`com.whiskymitschuss.timberloot` und ihre APK 0.20 bleiben erhalten.
**Diese APK wird separat installiert, nicht als Update über die alte App.**

## Installation

Auf GitHub die Datei `releases/Timber-Loot-Tycoon-v0.23-test.apk` öffnen und
**Download raw file** wählen. Die heruntergeladene APK im Handy-Dateimanager öffnen
und die Installation aus dieser Quelle bei Bedarf erlauben. Im Launcher danach
**Timber Loot Neu** starten. Die bisherige App muss dafür nicht deinstalliert werden.
Ein echter Gerätetest dieser Fassung steht aus.

## Build

```bash
python3 scripts/build_android.py
python3 scripts/build_android.py --verify-only
```

Der Helfer verwendet Godot 4.6.3 mit den per hinterlegten Prüfsummen geprüften
Android-Templates, SDK Platform 36 und Build Tools 36.0.0. Java mit `keytool`
ist vorhanden. Es gibt keine Gradle-Abhängigkeiten.

Der neue Testschlüssel liegt ausschließlich außerhalb des Repositories unter
`/workspace/.timber-runtime/android/TimberLoot-Reborn-debug.keystore`, Modus 0600.
Er wurde einmal für diesen ausdrücklich autorisierten Neustart angelegt. Der
Build-Helfer erzeugt nie automatisch einen Ersatz, wenn dieser Schlüssel später
fehlt. Für zukünftige Updates dieser neuen Linie muss genau dieser Schlüssel
sicher außerhalb von Git erhalten bleiben. Die Quell-ZIPs und Git-Bundles enthalten
keine Schlüssel. Es handelt sich um Testsignierung, nicht um eine Store-Signierung.

Geprüft werden APK-Signatur v2 und Zertifikatsfingerabdruck, 16-KB-Ausrichtung,
Paket/Version, API 24+, beide ARM-Architekturen, Hochformat, OpenGL und erlaubte
Berechtigungen. Startszene, Spielszene, neues Logo und Introskript müssen im Paket
vorhanden sein; Tests, Releases und Hilfsskripte müssen fehlen. Der Bericht
`.apk.json` enthält Quell-Commit, Größe und SHA256.

## Historische APK 0.20

`releases/Timber-Loot-Tycoon-v0.20-test.apk` bleibt mit ihrer alten Paketkennung
und Signatur unverändert verfügbar. Der zugehörige private Schlüssel ist in dieser
Cloud-Instanz nicht vorhanden. Die neue Linie behauptet keine Update-Kompatibilität.
