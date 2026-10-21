# 0.21 — Brandschutz

Ab dem ersten bewohnten Stadtgebäude können alle 420 simulierten Sekunden bis zu
zwei Gebäudebrände entstehen. Es gibt keine zerstörten Gebäude, verlorenen Vorräte
oder Strafzahlungen. Brände sind eine zusätzliche Rettungsaufgabe, keine Kaufpflicht.

Die Feuerwehr teilt sich die begrenzten Plätze der vorhandenen Gemeindedienste.
Sie fährt über gespeicherte Straßen zum tatsächlichen Brandort, löscht 36 Sekunden
vor Ort und fährt zurück. Eine eigene Wache ersetzt die Nachbarschaftshilfe;
ihre vorhandene Ausbaustufe erhöht die Fahrzeugkapazität. Ohne freien Wagen oder
Straßenverbindung bleibt der Einsatz ausdrücklich wartend. Brandorte und Fahrwege
sind gegen Versetzen beziehungsweise Straßenabriss geschützt.

Unter Welt/Gemeindedienste sind Einsätze, Löschfortschritt und Kamerasprung zum
Brandort erreichbar. Meldungen und Abschlüsse erscheinen in der Ereigniszentrale.
Neue Gemeindefahrten ausschalten stoppt neue Brandereignisse; bereits gemeldete
Brände werden weiter versorgt. Speichern und Offline-Simulation erhalten den
Fortschritt; die Stadtkasse bekommt den bisherigen Gemeindebonus genau einmal.
Alte Schema-1-Spielstände starten ohne nachträglich erfundene Brandereignisse.

Validierung: vollständige bestehende Headless-Suite plus 24 neue Brandprüfungen,
inklusive Flottenlimit, Ankunft vor Löschen, JSON-Wiederaufnahme, blockierte Route,
Ereignisbudget, Gebäudeschutz und ausbleibende Doppelvergütung. Gerätetests stehen aus.
