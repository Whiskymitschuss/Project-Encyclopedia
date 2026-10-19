# Timber Loot Tycoon: verbindlicher Wiederaufbauplan

## Ziel

Spielbare mobile 3D-Aufbauwirtschaft in Godot 4.x, GDScript, freundliche zusammenhängende Low-Poly-Landschaft. Holzindustrie entwickelt sich zur Bauwirtschaft und einer Immobilien-Stadt. Bestehende Ideen stammen aus dem Chat; frühere Quelldateien sind nicht verfügbar.

## Kern

Baumfällen → Rucksack → Sammelstation → Holz → Bretter → Trockenholz → Möbel → automatischer Export. Spätere Betriebe verwerten Holz und Sägespäne zu Wandmodulen, Dachmodulen, Bauelementen, Pellets, Papier und Designmöbeln. Materialbestände werden tatsächlich verbraucht. Baustellen gehen durch bezahlte Bauphasen; fertige Häuser erwirtschaften Miete.

## Welt und Bedienung

Zehn Biome, große verbundene Landschaft mit vielen Bäumen, Straßen auf Land, mehrere unabhängige Sägewerke/Hütten/Lager/Fabriken. Sichtbare Fördergüter, arbeitende NPCs, fahrende LKWs, beleuchtete Gebäude, Tag/Nacht, Wetter, Partikel und eigene Soundeffekte. Antippen, Kameraschwenken und Zoom; bedienbare Menüs im Hochformat. Kleine Viewports und reduzierte Qualität berücksichtigen.

## Progression

15 Werkzeugstufen bis Titan-Bagger; Arbeiter, Fahrzeuge, Forschungsrichtungen, Missionen und Großkundenaufträge. Loot mit sechs Seltenheiten und sechs Währungen/Ressourcentypen im Inventar. Booster und Bossbäume. Prestige mit sichtbaren permanenten Boni und steigenden Kosten; Freischaltung der Prestige-Welt. Zehn Stadtgrundstücke mit unterschiedlichen Immobilien und öffentlichen Gebäuden; Ausbau der Grundstücke, Miete, Upgrades. Forschungszentrum und Garage. Holzsorten/Biome besitzen unterschiedliche Erträge.

## Technik und Nachweis

Getrennte Managers, Components, UI, Buildings, NPCs, Vehicles, Economy und SaveSystem. Versioniertes Save/Load mit Backup, Offline-Fortschritt, begrenzte bewegte Objekte und instanzierte Wälder. Automatisierte Tests prüfen Ressourcenbilanzen, bezahlten Bau, Upgrades, Loot, Save/Load, Offline-Zeit und Prestige. Android-Export nur nach realer erfolgreicher Erstellung als vorhanden melden. Hardwaretests und ein 50-Stunden-Balancing erfordern gesonderten Nachweis.

## Sicherungsregel

Vor größeren Änderungen einen geprüften Meilenstein committen und zu GitHub pushen. Push durch `git ls-remote` verifizieren. Quell-ZIP und Git-Bundle als zusätzliche lokale Sicherungen erstellen. Nie einen nur lokalen Dateipfad als gesichert oder als funktionierenden Handy-Download ausgeben.
