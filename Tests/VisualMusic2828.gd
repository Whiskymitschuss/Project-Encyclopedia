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
 root.get_node("RuntimeStats").set_process(false)
 var music=root.get_node("Music");var store=root.get_node("Store")
 game.restore(JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/forestry288-company.json")))
 game.state.tutorial=5;game.state.onboarding.active=false;game.state.construction_intro=true;game.state.companion_enabled=false;game.state.city_services.enabled=false
 game.state.muted=false;game.state.music_enabled=true;music.apply_settings()
 var limit=Time.get_ticks_msec()+10000
 while music.player.stream==null and Time.get_ticks_msec()<limit:await process_frame
 check(music.player.stream is AudioStreamMP3 and not music.loading,"The app-wide player asynchronously loads the actual supplied MP3")
 if music.player.stream==null:quit(1);return
 check(music.player.stream.loop and music.player.stream.loop_offset==0,"The whole song loops from its beginning")
 check(music.player.playing and not music.player.stream_paused,"Background music starts with sound enabled")
 check(not music.is_processing(),"Loaded music has no per-frame script polling")
 var player=music.player
 player.seek(player.stream.get_length()-0.08)
 await create_timer(0.4).timeout
 check(player.playing and player.get_playback_position()<1.0,"Actual MP3 playback wraps at the end instead of stopping")
 game.state.muted=true;music.apply_settings()
 var at=player.get_playback_position();await create_timer(0.15).timeout
 check(player.stream_paused and absf(player.get_playback_position()-at)<0.08,"The existing sound mute pauses music without advancing its position")
 game.state.muted=false;music.apply_settings()
 check(not player.stream_paused,"Unmuting resumes the existing stream")
 music._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
 check(player.stream_paused,"Losing app focus pauses background music")
 music._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 music._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 check(player.stream_paused,"Resume does not bypass an outstanding focus-loss pause")
 music._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
 check(not player.stream_paused,"Returning to the app resumes music")
 var resources=game.state.resources.duplicate(true)
 root.size=Vector2i(591,1280);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.life.set_process(false)
 scene.hud.open_menu("settings")
 var buttons=scene.hud.contents.find_children("*","Button",true,false)
 var toggle=buttons.filter(func(b):return b.text=="Musik: AN")
 check(toggle.size()==1,"The real settings menu exposes the independent music toggle")
 if not toggle.is_empty():toggle[0].pressed.emit()
 check(not game.state.music_enabled and player.stream_paused,"The music button pauses only music")
 check(not game.state.muted,"Music can be disabled while existing effects stay enabled")
 buttons=scene.hud.contents.find_children("*","Button",true,false)
 toggle=buttons.filter(func(b):return b.text=="Musik: AUS")
 if not toggle.is_empty():toggle[0].pressed.emit()
 var slider=scene.hud.contents.find_child("MusicVolume",true,false)
 check(slider is HSlider and slider.custom_minimum_size.y>=44,"Music volume has a touch-sized slider")
 if slider!=null:slider.value=70;slider.drag_ended.emit(true)
 check(is_equal_approx(game.state.music_volume,0.7) and absf(player.volume_db-(-6+linear_to_db(0.7)))<0.01,"The actual volume slider changes music gain")
 # Exercise actual touch routing through the menu scroll container.
 if slider!=null:
  slider.value=20
  for i in 5:await process_frame
  scene.hud.scroll.ensure_control_visible(slider)
  for i in 5:await process_frame
  var transform=root.get_screen_transform()
  var first=transform*(slider.global_position+Vector2(slider.size.x*0.2,slider.size.y*0.5))
  var last=transform*(slider.global_position+Vector2(slider.size.x*0.85,slider.size.y*0.5))
  print("TOUCH MUSIC: rect=",slider.get_global_rect()," scroll=",scene.hud.scroll.get_global_rect()," passthrough=",slider.get_meta("gesture_passthrough",false)," emulate=",ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"))
  var down=InputEventScreenTouch.new();down.index=0;down.position=first;down.pressed=true
  Input.parse_input_event(down);await process_frame
  var drag=InputEventScreenDrag.new();drag.index=0;drag.position=last;drag.relative=last-first
  Input.parse_input_event(drag)
  for i in 2:await process_frame
  var up=InputEventScreenTouch.new();up.index=0;up.position=last;up.pressed=false
  Input.parse_input_event(up)
  for i in 3:await process_frame
 check(slider!=null and not slider.get_meta("gesture_active",false) and scene.hud.scroll.pointer==-99,"Releasing the slider returns gesture ownership without leaving the menu stuck")
 check(slider!=null and slider.value>=60,"A real touch drag reaches the slider instead of being consumed by menu scrolling")
 limit=Time.get_ticks_msec()+10000
 while store.is_saving() and Time.get_ticks_msec()<limit:await process_frame
 var saved=store.load_game()
 check(saved.music_enabled and is_equal_approx(saved.music_volume,game.state.music_volume),"The completed gesture persists through the background save worker")
 check(game.state.resources==resources,"Music, focus changes and settings leave factory/warehouse inventories untouched")
 scene.queue_free()
 for i in 3:await process_frame
 check(music.player==player and music.get_children().filter(func(n):return n is AudioStreamPlayer).size()==1,"Scene changes retain one music player without overlapping tracks")
 check(player.playing and not player.stream_paused,"Music continues when the world scene is removed")
 # Let the audio server retire its stopped decoder before SceneTree exits.
 music.shutdown()
 await create_timer(0.15).timeout
 print("VISUAL MUSIC 2828: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
