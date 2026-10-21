# Alpha 2 · Rückmeldungen aus dem Handytest

0.29-alpha.2 verbessert die in fünf Android-Screenshots gemeldeten Probleme.
Paket, Testzertifikat und Speicherverzeichnis bleiben gleich. Als Update über
Alpha 1 installieren; bestehende Firma und angefangene Lieferungen bleiben erhalten.

| Aufgabe | Änderung und Grund | Mehrwert | Geschätzte Qualitätswirkung |
| --- | --- | --- | --- |
| Feuer und Rauch | Unregelmäßige Shader-Flammen statt Kegeln, weicher durchscheinender Rauch mit Wind und Auftrieb, dünnere Wasserstrahlen. Brandstärke wächst zunächst und sinkt mit wirklichem Löschfortschritt. | Ein lokaler Brand wirkt lebendig und nachvollziehbar. Rauch bleibt auch im Akkumodus sichtbar. | Hoch |
| Lesbarkeit beim Einsatz | Kleine Anzeige mit festen Bildschirmmaßen und zwei Fortschrittsbalken; keine riesigen frei skalierenden Brand- und LKW-Texte. Fahrzeugdetails bleiben per Antippen zugänglich. | Einsatzort und Umgebung bleiben auf schmalen Handys sichtbar. | Hoch |
| Freies Baufeld | Gemeinsame Freiflächenprüfung für normale Bäume, den früher ausgenommenen BOSS-Baum und Forstmaschinen. Auch laufende Baustellen und Straßen räumen Vegetation. | Keine Häuser, die in Bäumen stehen. | Hoch |
| Umzug der Arbeiter | Forstmaschinen suchen freie Flächen im gewählten Biom. Holzträger nutzen verfügbare Straßenwege. Bauarbeiter behalten ihre Figuren beim Baustellenwechsel und laufen zur neuen Aufgabe. | Die Stadt wächst ohne zurückgelassene Arbeiter im alten Forstcamp. | Hoch |
| Verkehr | Zur Straßenbreite passende Fahrzeuggrößen, getrennte Fahrspuren, Abstände, reservierter Kreuzungsbereich und wechselnde Ampelphasen für Fracht, Dienste und Busse. Enge benachbarte Abzweige werden gemeinsam geregelt. Wartezeit stoppt den gespeicherten Fahrfortschritt. Getrennte Ladebuchten halten Anlieferung und Abholung auseinander. | Keine vorzeitig gelieferten Waren, während ihr LKW noch wartet. | Hoch |
| Ampeltechnik | Bei aktiven Gemeindediensten ein gespeicherter Ausfall nach jeweils 15 simulierten Minuten; höchstens ein Ausfall gleichzeitig. Gelbes Blinklicht und langsamer Wechselverkehr. Technikerwagen von der Fahrzeuggarage, sonst Gemeindehilfe, mit Anfahrt, zwölf Sekunden Arbeit und Rückfahrt. | Sichtbare Störungen werden tatsächlich repariert, ohne einen Fracht-LKW zu erfinden. | Mittel bis hoch |
| Bauleiterin Mara | Automatisch freie Teams auf arbeitsbereite Baustellen verteilen; Priorität beachten, manuelle Zuordnung respektieren. Bau- und Ladenlinie wechseln bei knapper Flotte ab, wenn passende Ware und Straßen vorhanden sind. | Mehrere Aufträge blockieren sich seltener; vorhandene Arbeiter werden weiter eingesetzt. | Hoch |
| Ursachen statt Stillstand | Bauleitung nennt Materialmangel, belegte LKWs, fehlende Straßen, Pause oder fehlendes Team. Ladenlinie bekommt eine zusätzliche Diagnose. Material und zusätzliche Teams bleiben echte Käufe. | Spieler erkennen den nächsten sinnvollen Schritt, ohne geschenkte Rohstoffe. | Hoch |

## Bedienung

**Mehr → Produktion & Transport → Verkehr & Ampeltechnik** zeigt Ausfälle,
Technikereinsatz und wartende LKWs. Mit „Einsatzort ansehen“ dorthin springen.
Die Reparatur erfolgt automatisch und kostet in dieser Alpha keine zusätzlichen Münzen.

**Mehr → Baustellen & Materialdepot** öffnet Bauleiterin Mara. Standardmäßig
aktiv, abschaltbar. „+ Arbeiter“/„− Arbeiter“ schaltet die automatische Einteilung
für diese Baustelle aus; „Team wieder der Bauleitung geben“ aktiviert sie erneut.
Die Forst-Arbeiterzahl im HUD und das Bauteam sind weiterhin getrennte Belegschaften.

Fehlt Holz, Bretter, Hardware oder eine Straße, erzeugt die Bauleitung keine
Ersatzware. Die angezeigte Ursache und die bestehenden Materialknöpfe helfen weiter.
Ampeln verlängern Fahrzeiten: Anzeigen sind verbleibende Fahrzeit ohne zukünftige
Ampelwartezeit, keine garantierte Lieferfrist. Staus können Ladenaufträge verspäten.

## Technische Grenzen

Verkehr nutzt deterministische Schritte von 0,2 Sekunden innerhalb der bestehenden
Simulation. An einer Kreuzung räumt jeweils ein Fahrzeug den Konfliktbereich;
die erste Alpha-Regelung priorisiert Sicherheit vor maximalem Durchsatz. Neue
Ampeln und Techniker sind durch Fahrzeugsimulation und Anzeige-Budgets begrenzt.
Die Wirkung auf große echte Android-Städte muss im Handytest überprüft werden.

Ein Brand beschädigt oder zerstört weiterhin keine Gebäude. Der angezeigte
Brandzustand ist die vorhandene Rettungssimulation; Reparatur von Brandschäden
ist keine zusätzliche Mechanik. Die Bauarbeiterwege sind sichtbare Darstellung
der echten Teamzuordnung, kein eigener Fußweg-Arbeitszeitaufschlag.

Prüfresultate und Auslieferungsdaten stehen in [VALIDATION.md](VALIDATION.md).

[Gerenderte Einsatzansicht aus dem automatisierten Test](alpha2/preview-fire.png).
