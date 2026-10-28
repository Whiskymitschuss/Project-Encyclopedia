# Version 1.0 vorbereiten

Stand: 28.10.2026, fortgesetzt mit 0.28.29-alpha.1. **Noch keine Store-Freigabe.**
Die Hilfe und Berichtserweiterung sind integriert. Die vollständige Simulation
vom ersten Spielstart bis Rathaus 10 ist inzwischen mit zwei Spielerregeln
belegt: [Verläufe und gefundene Blockaden](../journey-1-10/README.md).

## Festgelegter Umfang

Zunächst das vorhandene Offline-Spiel stabilisieren: Wald und Wiederaufforstung,
Sägewerk und weitere Werke, begrenzte Lager, automatische Transporte, Baustellen
und Bauteams, Kapitel/Rathaus 1–10, Speichern und Offline-Fortschritt. Biber,
Fahrzeuge, Straßen, Menüs und Musik bleiben erhalten. Keine zusätzlichen
Wirtschaftssysteme, Konten, Werbung oder Käufe für diese Vorbereitung.
Studiointro und weitere Gebäude sind gegenüber den Hängern nachrangig.

## Was dieser Schritt tatsächlich ändert

- `UI/PlayerHelp.gd`: Produktionshilfe mit direkten Wegen zu Werken, Fahrten,
  Baustellen, Lager und Pflanzern. Erreichbar aus Einstellungen, Spielmenü und
  der durchsuchbaren Hilfe unter Mehr. Große Schrift und Kontrast bleiben nutzbar.
- Lokale Speicher- und Datenschutzhilfe erklärt Deinstallation, fehlenden
  Cloud-Save sowie freiwilliges Kopieren eines Berichts. Sie ersetzt keine
  öffentliche Datenschutzerklärung mit Betreiberangaben.
- `UI/AlphaDesk.gd`: Hänger, Startabschnitte und Speicherstatus im neuen Bericht.
  „Aktuelle Messwerte anhängen“ erhält eigene Angaben und ergänzt auch einen
  bereits gespeicherten Entwurf. Nichts wird automatisch versendet.
- `scripts/play_readiness.py`: reproduzierbare Konfigurationsprüfung; explizit
  offene Geräte-, AAB-, Rechts- und Console-Prüfungen bleiben offen. Selbst ein
  AAB-Exportflag würde diese nicht automatisch erfüllen.

## Die nächsten Freigaben, in Reihenfolge

1. **Hänger auf dem Gerät reproduzieren und beheben.** Dieselbe Kandidatenversion
   und Stadt verwenden. Mindestens 30 Minuten spielen, Kamera bewegen, Menüs
   öffnen, bauen, speichern und mehrfach Hintergrund/Rückkehr testen. Version,
   Modell, Grafikprofil, FPS/P95, Zahl/längste Hänger und den aktuellen Bericht
   sichern. Kalten Start und Rückkehr nach acht Stunden separat messen.
   Ziel: belastbare 30 FPS im Standardprofil auf definierten Zielgeräten,
   keine wiederkehrenden Sekundenhänger, Weltaufbau möglichst unter 5–10 s.
   Ein 180-Frame-Mittel allein beweist keine stabile Sitzung. Die zuletzt
   gemeldeten 4,7 FPS/395 ms und 5–10-s-Hänger gelten weiterhin als offen.
2. **Rathaus 1–10 menschlich prüfen und balancieren.** `Tests/Journey.gd`
   belegt reale frühe Fortschritte bis Rathaus 2; spätere Kapitelprüfungen setzen
   Münzen, Gebäude und Materialien voraus. Sie prüfen Regeln, nicht die gesamte
   Erreichbarkeit. `Tests/JourneyPlaythrough.gd` ergänzt jetzt zwei vollständige
   Durchläufe mit verdienten Ressourcen, Einführung, Save/Reload und Offline-
   Vergleich. Für menschliche Testläufe Zeit, Pflichtaktionen, Wartephasen und
   Warenengpässe protokollieren. Keine Gratisressourcen für den Abnahmedurchlauf.
3. **Spielstand und Langzeitketten sichern.** Produktions-/Lagerbestände und Ware
   in laufenden LKW vor/nach Speichern, Neustart, Background und Offline-Zeit
   vergleichen. Volles Lager muss pausieren und nach Entnahme weiterlaufen.
   Kein doppelter Offline-Ertrag, keine verlorenen/duplizierten Transportmengen.
   Testupdate über die vorhandene App installieren, nicht vorher deinstallieren.
4. **Echten Release-Build vorbereiten.** Siehe [Android](ANDROID.md). Erst einen
   nachvollziehbaren Kandidaten bauen, danach konkrete Artefakt-/Geräteprüfung.
5. **Store-Inhalte vervollständigen.** Betreiber/Kontakt, öffentliche
   Datenschutzrichtlinie, Data Safety, Alters-/Inhaltsbewertung, Rechtebelege,
   Titel/Beschreibung, reale Screenshots und erforderliche Grafiken. Aktuelle
   Kontovorgaben und Testzugang in Play Console prüfen. Erst danach Einreichung.

## Nachprüfen

```sh
python3 scripts/play_readiness.py
python3 scripts/play_readiness.py --strict
python3 scripts/test_play_readiness.py
bash scripts/test_visual.sh VisualPlayerHelp
bash scripts/test.sh Journey Hitches2827 Music2828
```

Der strikte Audit endet beim jetzigen Stand absichtlich mit Code **2**. Code 0
ohne `--strict` bedeutet lediglich „Bericht erstellt“. Die Prüfung liest keine
Schlüssel und keine privaten App-Daten. [Konfigurationsbefund](source-audit.json).

Gerätemessungen, Grafiktests mit Software-GPU und Wirtschaftstests mit
simulierter Zeit sind getrennte Nachweise. Die vorliegende Änderung löst die
gemeldeten Handy-Hänger nicht nachweislich und verändert keine Produktionsregeln.

## Ergebnis des früheren Schnelldurchlaufs vor dem Rathaus-Update

Der vollständige `scripts/test.sh`-Lauf endet erfolgreich: **21.690 Prüfungen in
53 Ergebnisgruppen**, plus sechs Python-Audit-Tests. Er deckt unter anderem Wald,
Produktion, Transporte, Bau, Speicher-/Offline-Regeln, Straßen, Verkehr und
Fortschrittsregeln ab. Import und Hauptszenen-Smoke liefen ebenfalls durch.

Sieben zusätzliche OpenGL-Grafikmodule prüfen Start, Logistik, Wald, Lager,
Gebäudekarte, Stadtmenüs und die Oberfläche: **280 Prüfungen, null Fehlschläge**.
Neue Hilfe und Musikbedienung: weitere **50 OpenGL-Prüfungen**. Die Hilfe lief
auch mit softwarebasiertem Vulkan: **29 Prüfungen, null Fehlschläge**. Ein erster
Vulkan-Versuch ohne gesetzten lokalen ICD fiel auf OpenGL zurück und wurde vom
Testhelfer als Fehler abgewiesen; mit explizitem Software-ICD war Vulkan aktiv.

Mehrere ältere Tests melden beim Beenden noch `ObjectDB instances leaked`.
Diese Warnungen sind nicht als behoben markiert und sind kein Nachweis für
einen während des Spielens wachsenden Speicherverbrauch. Native Android-/Windows-
Tests und ein Langzeitlauf bleiben ausstehend. [Einzelergebnisse](checks.json).
