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
