# Rückkehr zur 0.28 · 0.28.1-alpha.1

## Wiederhergestellte Spielbasis

**Geändert:** Der aktive Spielcode und die Tests stammen wieder aus dem tatsächlich
verteilten Alpha-1-Quellstand `d14b53774d5505a93ee1e7b845b2b4753fd9b804`.
Die Ampel-, Bauleiter- und Ladeablaufänderungen ab 0.29 sind zurückgenommen.
Historie, alte Veröffentlichungen und die isolierte Test-/Build-Infrastruktur bleiben.

**Grund:** Auf dem Handy bleiben seit 0.29 dieselben LKW stehen. Weitere Korrekturen
an dieser Verkehrssteuerung haben den gemeldeten Fehler nicht verlässlich beseitigt.
**Spielernutzen:** Wieder die vertraute 0.28 als Grundlage, statt weiterer 0.29-Regeln.
**Geschätzte Qualitätswirkung:** Hoch für Zuverlässigkeit; keine Gerätegarantie.

Die sichtbare Versionsnummer ist 0.28.1-alpha.1. Android-Code 2951 liegt absichtlich
über 2942, damit diese Rückkehr als Update über 0.29.4 installiert werden kann.
Paket, Speicherverzeichnis und bestehendes Testzertifikat bleiben gleich.
Nicht deinstallieren und keine App-Daten löschen.

Die unveränderte Spielbasis besteht in isolierten Profilen alle 19630 Prüfungen
in 24 Headless-Suiten sowie Main-/Boot-Smokes. Gerätetests stehen aus.
Die späteren, ausdrücklich gewünschten Änderungen an Häusern, Materialanzeige und
mobiler Lastbegrenzung werden gesondert dokumentiert und geprüft.
