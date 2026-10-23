# Waldabholung und Startzeit · 0.28.8-alpha.1

Das Foto mit 104 Holz außerhalb des Zentrallagers und Lagerbestand 0 zeigt einen
anderen Fall als der volle Zentralbestand aus 0.28.7. Der private Spielstand und
die installierte Versionsnummer liegen für diese Prüfung nicht vor. Eine größere,
erzeugte Firma stellt die Verdrängung der Holzabholung durch andere Transporte nach.

## Tatsächlich geändert

- Bei knappem zentralem Holzbestand hält die automatische Werksversorgung einen
  LKW für die erreichbare Holzabholung frei. Ein beliebiger Bretter-/Möbel-LKW
  erfüllt diese Aufgabe nicht mehr. Bereits eingeteiltes Holz einschließlich
  leerer Rückfahrt zählt; es wird keine zusätzliche Flotte erzeugt.
- Die Abholrunde setzt nach dem tatsächlich bedienten Produzenten fort. Leere
  vorherige Einträge verschieben den Zeiger nicht mehr auf einen bereits
  abgearbeiteten Bereich. Pro Quelle wird in einer Runde eine Ladung disponiert.
- Produzentenschlüssel werden numerisch sortiert. Dadurch bleibt die Reihenfolge
  nach JSON-Speicherung stabil, einschließlich mehrstelliger Gebäudeindizes und
  getrennter Warenbestände am selben Gebäude. Ein gefundener Unterschied zwischen
  direkter und gespeicherter Fortsetzung wurde damit korrigiert.
- Abhol-Express berücksichtigt vor einer neuen Fahrt die wirkliche freie Kapazität
  einschließlich aller bereits zugesagten Ladungen. Eine große Baurechnung kann
  neue LKW nicht mehr gegen einen überbuchten Entladeplatz schicken.
- Auf der Holzkarte steht bei vollständig belegten aktiven Sammelstationen
  „Abholung“. Antippen öffnet die vorhandene Warenhilfe mit Betriebsstatus und
  tatsächlich disponierten Lieferungen. „Lager 0“ bleibt ausdrücklich sichtbar.

Die bisherigen Regeln für Pausen, Straßenverbindungen, Warenbesitz und echte
Entladezeiten bleiben gültig. Ein voller Wald-Ausgang kann weiterhin zeitweise
warten; die Produktion folgt echten Lager- und Transportkapazitäten. Die Darstellung
bucht keine zusätzlichen Bäume oder Waren.

## Startzeit

Die Offline-Simulation berechnet weiterhin jede tatsächlich vergangene Sekunde
bis zu acht Stunden. Es werden keine Erträge gekürzt und keine groben Zeitschritte
eingeführt. Die Änderung vermeidet doppelte Baureserve-, Kapazitäts-, Rezept- und
Straßenprüfungen für identische oder bereits erledigte Vorgänge. Bauteamverteilung
zählt freie Teams einmal statt für jede wartende Baustelle erneut.

Vergleich auf diesem Desktop, jeweils acht Offline-Stunden:

| Erzeugte Firma | Vorher | Nur Optimierung | Ergebnis |
|---|---:|---:|---|
| Bestehende Rückkehr-Testfirma | 17,233 s | 12,116 s | vollständig identisch |
| Größere Firma mit voller Sammelstation und leerem Holzlager | 24,252 s | 14,265 s | vollständig identisch |

Das entspricht rund 30 % beziehungsweise 41 % weniger Rechenzeit. Der Vergleich
isoliert die Optimierung gegenüber 0.28.7; die anschließend korrigierte Disposition
ändert bewusst tatsächliche Transportentscheidungen und ist separat getestet.
[Messdaten](alpha1-recovery/startup-benchmark.json) und
`python3 scripts/benchmark_startup.py` enthalten die reproduzierbare Versuchsanordnung.
Dies sind keine zugesicherten Handy-Ladezeiten. Ein echter Kaltstart der fertigen
Fassung wird zusätzlich mit Fortschrittsanzeige und geschütztem Spielstand geprüft.

## Nachweise und Grenzen

`Forestry288` prüft die dringende Abholung neben automatischer und angeforderter
Werksversorgung, faire Quellenreihenfolge, Pausen und unerreichbare Quellen,
Flottenlimit und Warenbilanz. Ein 30-Minuten-Lauf mit zwölf Häusern und vielen
Baustellen prüft wiederholte echte Ernte, Verarbeitung/Verkauf und Baulieferungen.
Die gespeicherte Firma setzt ihre tatsächlichen Transporte identisch fort.

`VisualForestry288` verwendet die Hauptwelt, echte Maschinen, Baumfälle,
Frachtfahrzeuge, den Holzbestand und dessen bedienbare Statusanzeige. Kleine
Displays mit großer Schrift werden geprüft. `VisualColdStart288` startet einen
neuen Prozess mit acht Stunden Abwesenheit derselben größeren Testfirma.

[Prüfbericht](alpha1-recovery/automated-checks.json) ·
[APK-Ressourcenprüfung](alpha1-recovery/packaged-checks.json) ·
[Waldansicht](alpha1-recovery/forest.png).

Keine privaten Spielerprofile für Tests verwendet. Kein physischer Android-Lauf,
keine Temperaturmessung auf S26 Ultra/S24 FE. Der komplette
[Welt-Masterumbau](WORLD-REWORK-286.md) bleibt offen.
