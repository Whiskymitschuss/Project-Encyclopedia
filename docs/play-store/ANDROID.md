# Android-Veröffentlichung: konkrete Lücken

Die vorhandene `Android Test`-Konfiguration und `scripts/build_android.py`
erstellen signierte **Debug-APKs**. Sie sind für kompatible Testupdates gedacht.
ARM64 ist konfiguriert, Internet-/Speicherberechtigungen sind deaktiviert;
Vibration ist aktiviert. Den endgültigen Manifest-Merge immer am Artefakt prüfen.

Noch nicht vorhanden/geprüft:

- Produktions-AAB mit Gradle, Release-Export und `debuggable=false`.
- Bewusste Entscheidung über Play-App-Signing und separat gesicherten Upload-Key.
  Keine privaten Schlüssel in Git; den bisherigen Testschlüssel nicht ersetzen.
- Explizite, zum Einreichungszeitpunkt gültige SDK-/Target-API-Konfiguration.
- Tatsächliche native ELF-Segmentausrichtung, ZIP-Ausrichtung und Betrieb in
  einer Android-Umgebung mit 16-KiB-Seiten. Ein `zipalign`-Aufruf allein belegt
  keine native Kompatibilität. Auch alle hinzugefügten Plugins müssten geprüft werden.
- Installation eines aus genau diesem AAB generierten Play-/bundletool-Splits,
  physischer Geräte-/Langzeittest, Manifest-/Berechtigungs- und Signaturprüfung.

Das bisherige Paket ist `com.whiskymitschuss.timberloot.reborn`. Eine andere
Signatur kann bestehende Testinstallationen nicht einfach überschreiben.
Bei einer späteren Produktionssignatur oder Paketänderung muss der Umgang mit
den lokalen Testspielständen vorab geklärt und getestet sein. Keine Empfehlung
zum Deinstallieren als vermeintliche Migration.

Öffentliche Store-Vorgaben wurden in dieser Umgebung **nicht live verifiziert**.
Vor Einreichung anhand offizieller Quellen und des konkreten Kontos prüfen:

- [Target API](https://support.google.com/googleplay/android-developer/answer/11926878)
- [App Bundles](https://developer.android.com/guide/app-bundle)
- [16-KiB-Seiten](https://developer.android.com/guide/practices/page-sizes)
- [Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)
- [Nutzerdaten und Datenschutz](https://support.google.com/googleplay/android-developer/answer/10144311)

Die Ingame-Hilfe beschreibt den lokalen Datenfluss, enthält aber bewusst keine
erfundenen Betreiber-/Kontaktangaben. Eine öffentliche Richtlinie, Data-Safety-
Antworten und Medienrechte müssen vor Veröffentlichung konkret vorliegen.
Für die hochgeladene Hintergrundmusik ist die kommerzielle Nutzung nicht allein
durch den Upload nachgewiesen. Kein Claim über Play-Freigabe oder Lizenzstatus.
