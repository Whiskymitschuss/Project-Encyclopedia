# Hintergrundmusik · 0.28.28-alpha.2

„Whimsical Forest Adventure“ aus der bereitgestellten MP3 ist als Hintergrundmusik
integriert. Die Datei wurde unverändert übernommen: 131,352 Sekunden, Stereo,
48 kHz, 2.921.644 Bytes. [Herkunft und SHA256](../Assets/Audio/whimsical-forest-adventure.json).

Ein appweiter Player spielt über Start-/Ladebildschirm und Spiel hinweg. Kein
Neustart oder zweiter überlagerter Titel beim Szenenwechsel. Godots nativer
MP3-Loop wiederholt den ganzen Titel; vorhandene Anfangs-/Endstille der Aufnahme
wird nicht abgeschnitten. Laden erfolgt über den Thread-Loader. Nach dem Laden
verarbeitet das Musikskript keine Frames mehr; der Audio-Server übernimmt die
komprimierte Wiedergabe. Beim Beenden werden Player und Stream freigegeben.

Der bestehende Sounds-Schalter pausiert auch Musik. Zusätzlich gibt es in den
Einstellungen einen Musik-Schalter und einen Lautstärkeregler. Standard 35 % mit
zusätzlicher Absenkung um 6 dB als Hintergrundmischung. Reglerbewegungen ändern
den Pegel sofort, speichern aber erst nach der Geste beziehungsweise beim
Fokuswechsel. Kein neuer Speicherauftrag für jeden Reglerwert. Einstellungen
bleiben über Speichern, Laden und Prestige erhalten. Ältere Spielstände erhalten
die neuen Vorgaben ohne Zurücksetzen ihrer Wirtschaft. Hintergrund-/Fokusverlust
pausiert die Wiedergabe; Rückkehr setzt sie fort. Keine neuen Berechtigungen.

Die Speicherentlastung und lokale Hängerdiagnose aus 0.28.27 bleiben enthalten.
Das Musikupdate behauptet keinen neuen FPS-Gewinn und keine Behebung aller
Handy-Hänger. Wetter bleibt aus. Android-Code 3024, bisheriges Paket/Testzertifikat.

Geprüft werden der echte MP3-Endübergang, stumme/pausierte Wiedergabe,
Szenenwechsel ohne doppelte Player, der echte Einstellungsregler, dauerhafte
Einstellungen, alte Speicherstände und unveränderte Warenbestände. Grafiktests
nutzen Linux-Softwaregrafik und Dummy-Audio; sie bestätigen die Decoder- und
Steuerungsabläufe, keine subjektive Klangprüfung auf einem Handy. Prüfzahlen
stehen in [source-checks.json](music-2828-alpha2/source-checks.json).

Geänderte Laufzeitdateien: `Audio/Music.gd`, `Assets/Audio/`, `project.godot`,
`Managers/Game.gd`, `SaveSystem/SaveFiles.gd`, `UI/HUD.gd`, `export_presets.cfg`.
Dazu zwei gezielte Musiktests, Testrunner, Dokumentation und passende Testpakete.

Bei einzelnen sofortigen Testabbrüchen mit laufender Dummy-Audiowiedergabe meldet
Godot am Prozessende ein verbliebenes MP3-/Playback-Paar. Der gezielte Musiktest
stoppt den Player und lässt den Audio-Server vor Testende abarbeiten; dieser
Abschluss ist sauber. Das native Geräteverhalten ist noch nicht geprüft.

Alpha 2 korrigiert zusätzlich die Touch-Weiterleitung: Der Lautstärkeregler ist
als eigener Gestenbereich markiert; auch Bewegungsereignisse und die laufende
Reglergeste bleiben bis zum Loslassen beim Regler. Damit fängt der Menü-
Scrollcontainer das Ziehen nicht ab. Ein echter ScreenTouch-/ScreenDrag-Test scheitert vor der Korrektur
und prüft danach sowohl den geänderten Pegel als auch dessen Speicherung.
