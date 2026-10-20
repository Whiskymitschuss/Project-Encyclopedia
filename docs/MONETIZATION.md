# Einnahmemodell — Vorschlag, noch keine Kauf-Funktion

Ziel: Timber Loot Tycoon soll Geld verdienen können, während die zehn Kapitel und ihre Produktions-, Bau- und Rathausketten vollständig ohne Zahlung spielbar bleiben. Der Spieler soll für etwas Schönes bezahlen können, das er behalten möchte.

## Empfohlener erster Ansatz

| Geplantes Angebot | Möglicher Inhalt | Erste Preisidee |
| --- | --- | --- |
| Unterstützerpaket | Benno-Arbeitsoutfit, ein ausdrücklich als Unterstützertitel gekennzeichneter Titel und ein Dekoset | etwa 5 € einmalig |
| Baustil-Paket | Zusammenpassende Fassaden, Dachfarben, Vorgärten und Verwaltungsdeko | etwa 3–8 € einmalig |
| Fahrzeugdesigns | Zusammenpassende Lackierungen für LKW, Anhänger und Tiefbett | etwa 3–5 € einmalig |
| Spätere große Erweiterung | Eigenständiger zusätzlicher Schauplatz mit ausreichend neuer spielbarer Geschichte | erst nach Fertigstellung des Grundspiels bewerten |

Die Preise sind Vorschläge zur Erprobung, keine bereits angebotenen Produkte. Gekaufte Fahrzeugdesigns ändern weder Transportkapazität noch Geschwindigkeit. Häuser und Rathaus werden weiterhin mit Spielmünzen, wirklichen Baustoffen und Bauarbeitern ausgebaut. Erspielte Kapitelpokale und Leistungstitel bleiben ausschließlich an ihre Spielziele gebunden. Bereits kostenlos vorhandene oder über Loot verdiente Skins werden nicht nachträglich zu Kaufartikeln.

Ein klarer kleiner Kosmetikkatalog bietet sich für den Anfang besser an als viele Währungen, rotierende Pflichtangebote oder lange Werbeunterbrechungen. Ein Kauf braucht eine erkennbare Vorschau, einen eindeutigen Endpreis und einen dauerhaft wiederherstellbaren Inhalt. Ausgaben dürfen nicht zur Reparatur künstlich erzeugter Produktionsprobleme nötig sein.

## Vor dem Verkauf prüfen

Zuerst das Kapitelupdate mit freiwilligen Handy-Testspielern beobachten: Finden sie den ersten Verkauf? Verstehen sie die Rathauslieferung? Erreichen sie das zweite Kapitel? Öffnen sie das Spiel an einem späteren Tag aus eigener Lust wieder? Für diese Entwicklungsfassung werden keine Werbe- oder Analysedienste ergänzt. Automatisierte Godot-Prüfungen beantworten diese Fragen nicht.

Erst danach ein hochwertiges zusammenpassendes Unterstützer-/Kosmetikpaket ausarbeiten und dessen Nachfrage testen. Der erste Verkaufskatalog sollte klein bleiben. Inhalte müssen in einer tatsächlichen 3D-Vorschau gut aussehen und in der Stadt sichtbar sein.

## Was dafür technisch noch nötig ist

Echte Android-Käufe benötigen eine Store-Veröffentlichung, eingerichtete Produkte und eine funktionsfähige Google-Play-Billing-Anbindung. Kaufprüfung, Wiederherstellung, abgebrochene Käufe und Rückerstattungen gehören zur Implementierung; ein lokales Inventarflag allein ist keine Bezahlfunktion. Die Test-APK 0.19.1 enthält weiterhin keine Echtgeldkäufe, keine Zahlungsabwicklung, keine Werbung und keine neuen Netzwerkberechtigungen. Es gibt deshalb noch keinen wirkungslosen Kaufbutton im Spiel.

## Einnahmen realistisch betrachten

Als einfache Monatsrechnung: monatlich aktive Spieler × Käuferanteil im Monat × durchschnittlicher Kaufbetrag. Rein hypothetisch wären 1.000 aktive Spieler × 2 % Käufer × 6 € gleich 120 € Bruttoumsatz vor Storegebühren und Steuern. Die 2 % sind keine Prognose. Ein einmaliges Unterstützerpaket wird von derselben Person nicht jeden Monat erneut gekauft.

Darum zuerst ein Spiel entwickeln, zu dem Menschen zurückkehren, danach wenige attraktive freiwillige Käufe testen und erst mit echten Ergebnissen über Werbung, Reichweite oder zusätzliche Pakete entscheiden.
