# Vorbereitete Spielressourcen

690 erzeugte Ressourcen: vorhandene Gebäudemodelle Stufe 1–10 einschließlich
beider Stile, 120 Biber-Rigs, Fahrzeugfamilien und Landschaft. Shared-Dateien
vermeiden identische Industriebauten je Gebäudestil. Das sind echte Szenen und
Meshes der bestehenden Hauptwelt, keine Ersatzwürfel.

Erzeugen: `python3 scripts/bake_runtime.py` (isoliertes Profil).
Prüfen: `python3 scripts/bake_runtime.py --verify-only`.
Der Android-Builder verweigert den Export bei geänderten Geometriequellen,
fehlenden oder veralteten Ressourcen. `manifest.json` enthält SHA256 aller
Quellen und erzeugten Dateien. LODs erhalten die nahe Originalgeometrie.

Ressourcenladen verwendet Godots Thread-Loader. Instanziierung und Änderungen
am Szenenbaum erfolgen auf dem Hauptthread. Unveränderte Szeneinstanzen und
Inventare werden nicht durch neue Simulationen ersetzt.
