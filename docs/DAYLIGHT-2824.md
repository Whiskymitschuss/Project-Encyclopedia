# Dauerhaftes Tageslicht · 0.28.24-alpha.1

Auf ausdrücklichen Wunsch ist die Wetter- und Tageszeitsteuerung abgeschaltet.
Die Hauptwelt erzeugt weder Regen-Emitter noch Pfützen-Controller. Der frühere
WetWeather-Controller und sein Skript wurden entfernt. Nebel bleibt aus, seine
Dichte null. Das feste Mittagslicht hat einen gleichbleibenden Sonnenwinkel,
Lichtfarbe, Energie, Umgebung und Himmel. Keine laufenden Lichtübergänge.

Die Baumkronen verwenden einen statischen ForestCanopy-Shader ohne Winduniforms,
Sinusbewegung oder Wind-Updates. Produktionsdampf darf weiterhin senkrecht
aufsteigen; Wetterwind existiert nicht. Materialbibliothek und Fenster bleiben
auch bei alten Wetter-/Nachtaufrufen trocken und im Tageslicht.

Neue Spielstände starten bei 12 Uhr und Wetter 0. Beim Laden alter Regen-/Nacht-
Spielstände werden ausschließlich diese beiden Darstellungsfelder normalisiert.
Jeder Wirtschaftstakt hält sie fest. `elapsed`, Bau-, Wachstums-, Produktions-,
Liefer- und Offline-Zeiten laufen unverändert weiter. Bestände und Fortschritte
werden nicht zurückgesetzt. Keine zusätzliche Einstellung oder Berechtigung.

Die bisherigen Wetter-/Nachttests prüfen jetzt ausdrücklich das gewünschte feste
Tageslicht. Neue Prüfungen decken alte Spielstände, einen vollständigen früheren
Wetter-/Tageszyklus und fehlende Wetterobjekte ab. Der OpenGL-Test vergleicht
wirklich gerenderte Waldbilder über alle alten Wetterwerte und Nacht: identische
Pixel nach Einfrieren unabhängiger Arbeiter-/Produktionsanimationen.

Android-Code 3019; gleiches Paket und bisheriges Testzertifikat. Als Update
installieren, nicht deinstallieren und keine App-Daten löschen.
Kein physischer Android-Gerätetest und keine garantierte Gesamtbildrate.
