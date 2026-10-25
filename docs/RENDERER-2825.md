# Vulkan-Vergleich für SM-S721B · 0.28.25-alpha.1

Die Nutzermessung der .24 zeigt ungefähr 7 FPS / P95 393,6 ms bei 44 %
3D-Auflösung, Entlastungsstufe 3/3 und etwa 580 Zeichenaufrufen. Erfasste
Skripte: Spielverwaltung Ø 0,8 / P95 8,04 ms, Welt Ø 2,8 / P95 1,19 ms,
Wirtschaftstakt Ø 5,89 / P95 10,11 ms, Speichern Ø 12,54 / P95 15,59 ms.
Die Bereiche haben unterschiedliche Abtastraten und überschneiden sich.
Sie erklären die rund 143 ms mittlere Bildzeit nicht alleine. Das grenzt die
Suche auf weitere Engine-/Render-/Treiberarbeit ein; es beweist noch keinen
bestimmten GPU-Defekt oder ausschließlich GPU-Rechenlast.

## Zwei vergleichbare APKs

Android verwendet im Vulkan-Test den Godot-Mobile-Renderer. Die zweite APK
verwendet OpenGL Compatibility. Beide enthalten dieselbe Spielwelt, dieselbe
Version 0.28.25-alpha.1, denselben Android-Code 3020, Paket und bisherigen
Testschlüssel. Sie können als Updates gegeneinander installiert werden, ohne
Daten zu löschen. Es gibt keinen Spielstand- oder Fortschrittsreset.

Der Vulkan-Export meldet Vulkan-Hardware als Installationsvoraussetzung gemäß
Godots Android-Exporter. Für ältere Geräte und die Rückkehr zum alten Backend
liegt deshalb ausdrücklich eine passende OpenGL-APK bei. Zusätzlich bleibt
Godots OpenGL-Rückfall bei gescheiterter Vulkan-Initialisierung aktiviert;
dieser ist kein Ersatz für die separate OpenGL-APK bei Installationsproblemen.
Desktop bleibt standardmäßig OpenGL. Kein Gradle-Wechsel, keine neue Berechtigung.

`python3 scripts/build_android.py --renderer gl_compatibility --output ...-opengl.apk`
erzeugt die zweite Variante mit einer exklusiv angelegten temporären override.cfg.
Vorhandene Override-Dateien werden nicht überschrieben; fremde Änderungen nicht
gelöscht. Die Datei wird nach dem Export entfernt und niemals ins APK gepackt.
Projektdatei und Quell-Commit bleiben gleich. Paketbericht und Manifestprüfung
halten das tatsächliche Android-Backend jeder Variante fest.

## Diagnose und unveränderte Funktionen

Die Leistungsanzeige ergänzt den tatsächlichen GPU-Namen. Eine optionale,
zehn Sekunden begrenzte Messung erfasst Root-Viewport-Render-CPU und GPU mit
Godots Render-Timern. Skriptzeiten sind darin nicht enthalten. Nicht verfügbare
Timer werden als nicht verfügbar gezeigt, nicht als 0-ms-GPU behauptet.
Im Hintergrund wird die Messung abgebrochen. Keine automatische Übertragung.

Wetter bleibt vollständig abgeschaltet: festes Tageslicht, kein Regen, Nebel,
Wind oder Pfützen. Produktion, Bestände, Logistik, Eingaben, Biber und Upgrades
verwenden dieselben vorhandenen Systeme. Die Änderung ist in der Hauptwelt.

## Nachweis und Grenzen

Beide Backends werden mit der echten Hauptwelt, GPU-Abfragen und tatsächlichen
Pixeln geprüft. Vulkan auf dem Desktop nutzt Mesa Lavapipe; das ist ein
Software-Renderer, nicht die Xclipse-GPU des SM-S721B. Der Vulkan-Softwaretest
ist nicht schneller als OpenGL und begründet keine Handy-FPS-Zusage.
Dieser Build dient dem konkreten Backendvergleich auf dem betroffenen Gerät.

Die bisher bitgenaue OpenGL-Tageslichtprüfung bleibt bitgenau. Für Vulkan
berücksichtigt sie sehr kleine gerenderte Abweichungen: gemessener mittlerer
RGB-Fehler etwa 0,00000883; strikte Toleranz 0,0001. Zusätzlich bleiben die
Lichtzustände und die vollständige Abwesenheit aller Wetterobjekte geprüft.
Ein Vulkan-Initialisierungsausfall wurde mit dem Softwaretest absichtlich
erzeugt; Godot startete anschließend die echte Hauptwelt unter OpenGL.
Auf Android wird derselbe Rückfallpfad durch die Engine unterstützt.

Kein physischer Android-Gerätetest, kein bestätigter Geschwindigkeitsgewinn auf
dem Samsung. Bitte zuerst Vulkan installieren und dieselbe Stadt vergleichen.
Unter „Leistungsvergleich“ muss dabei `mobile/vulkan` erscheinen. Falls weiter
langsam, kann die kurze Grafikzeitmessung die verbleibende Renderarbeit zeigen.
