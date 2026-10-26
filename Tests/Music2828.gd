extends SceneTree
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 var music=root.get_node("Music");var store=root.get_node("Store")
 check(not music.player.playing and not music.loading,"Headless economy runs do not start an audio decoder or music loader")
 var original=game.snapshot()
 var legacy=original.duplicate(true);legacy.erase("music_enabled");legacy.erase("music_volume")
 game.restore(legacy)
 check(game.state.music_enabled and is_equal_approx(game.state.music_volume,0.35),"Existing saves receive soft background-music defaults without a reset")
 check(game.state.resources==original.resources and game.state.coins==original.coins,"Adding music preferences preserves the complete economy")
 var stream=load(music.TRACK)
 check(stream is AudioStreamMP3 and stream.get_length()>130 and stream.get_length()<133,"The supplied complete 131-second track is a real decodable MP3 resource")
 game.state.music_volume=0.7;game.state.music_enabled=false
 check(game.save(true),"Music preferences pass the existing durable save transaction")
 var saved=store.load_game();game.restore(saved)
 check(not game.state.music_enabled and is_equal_approx(game.state.music_volume,0.7),"Music toggle and volume persist through save and restore")
 check(game.state.muted==original.muted and game.state.ambient_enabled==original.ambient_enabled,"Music controls do not overwrite the existing sound/ambient preferences")
 var invalid=saved.duplicate(true);invalid.music_volume=1.5
 check(not store.valid_shape(invalid),"Out-of-range saved music volume cannot replace a valid file")
 invalid.music_volume=-0.1
 check(not store.valid_shape(invalid),"Negative saved music volume is rejected")
 invalid.music_volume="bad"
 check(not store.valid_shape(invalid),"Non-numeric saved music volume is rejected")
 invalid=saved.duplicate(true);invalid.music_enabled="bad"
 check(not store.valid_shape(invalid),"Music-enabled data must remain a boolean")
 game.restore(original)
 print("MUSIC 2828: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
