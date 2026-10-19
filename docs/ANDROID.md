# Android-Test 0.16.0

Die Test-App heißt **Timber Loot**, Paket `com.whiskymitschuss.timberloot`. Sie benötigt Android 7.0 oder neuer und ein ARM64-/ARMv7-Gerät mit OpenGL ES 3.0. Die Version ist `0.16.0-test`, Versionscode 1600. Keine Android-Berechtigungen, keine Werbung, keine Kontenpflicht.

## Update von 0.7 bis 0.15

Die Paketkennung, der lokale Testsignaturschlüssel und der Speicherpfad bleiben gleich. Die neue APK als Update über die vorhandene App installieren; nicht deinstallieren und keine App-Daten löschen. Schema-1-Spielstände bleiben kompatibel. Alte Profile behalten automatische Miete; neue Profile sammeln sie am Haus. Straßen und Buslinien werden in derselben Speicherdatei ergänzt. Vor Auslieferung wird die Signatur mit der bisherigen 0.15-APK verglichen. Ein echter Update-Installationsversuch auf einem Telefon bleibt offen.

## Installation nur mit dem Handy

1. Auf GitHub `releases/Timber-Loot-Tycoon-v0.16-test.apk` öffnen. Bei einem privaten Repository mit dem berechtigten GitHub-Konto anmelden.
2. **Download raw file** bzw. das Download-Symbol wählen. Die APK vollständig herunterladen.
3. Im Handy-Dateimanager **Downloads** öffnen und die APK antippen.
4. Falls Android nachfragt, dem Browser/Dateimanager **Installation aus dieser Quelle** erlauben; danach **Installieren → Öffnen**.

Eine GitHub-Seite ohne heruntergeladene APK lässt sich nicht installieren. Die älteren kaputten Chat-Dateilinks werden hierfür nicht benötigt. Handy-Einstellungen oder eine Neuinstallation von ChatGPT beheben den früheren Übertragungsfehler nicht.

Eine erstmalige Installation beginnt mit einem neuen lokalen Profil; ein Update der vorhandenen 0.7–0.15-App erhält deren Spielstand. Verlorene ursprüngliche Cloud-/Browser-Spielstände können nicht übernommen werden.

## Build und Prüfung

```bash
python3 scripts/build_android.py
python3 scripts/build_android.py --verify-only
```

Das Skript verwendet Godot 4.6.3, die passenden offiziellen Android-Templates, SDK Platform 36, Build Tools 36.0.0 und Platform Tools. Prüfsummen der offiziellen Downloads sind im Setup-Skript fest hinterlegt. Der nicht-Gradle-basierte Debug-Export benötigt Java mit `keytool`. Das Ergebnis liegt in `exports/`; nach bestandener Prüfung wird es als separate Testdatei in `releases/` gesichert. APK-Dateien dürfen nicht in den nächsten APK-Export eingeschlossen werden.

Geprüft werden v2-Signatur, 16-KB-ZIP-Ausrichtung, Hauptszene, Ressourcen, Paketkennung, Android-Mindestversion, ARM-Architekturen, Hochformat, OpenGL statt Vulkan und fehlende Berechtigungen. Eine `.apk.json` dokumentiert Größe und SHA256. Dies ersetzt keine Installation oder Leistungsprüfung auf einem echten Gerät; diese stehen noch aus.

Der lokale Debug-Schlüssel liegt außerhalb von Git in `/workspace/.timber-runtime/android/TimberLoot-debug.keystore`. Er muss für spätere installierbare Updates erhalten bleiben. Mit anderem Schlüssel verlangt Android eine Neuinstallation; eine Deinstallation löscht den Spielstand. Für eine Veröffentlichung ist ein eigener sicherer Release-Signierungsprozess nötig. Die gespeicherte APK bleibt unabhängig vom lokalen Schlüssel installierbar.

Die optionale ADB-Geräteerkennung kann in dieser Cloud am schreibgeschützten Benutzerverzeichnis scheitern. Dateiexport, Signieren und Paketprüfung benötigen keine USB-Verbindung. Ein angeschlossenes Testgerät oder Android-Emulator steht hier nicht zur Verfügung.
