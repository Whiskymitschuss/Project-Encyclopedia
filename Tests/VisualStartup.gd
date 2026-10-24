extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func settle() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func tap(button: Button) -> void:
 var point=root.get_screen_transform()*button.get_global_rect().get_center()
 for pressed in [true,false]:
  var event=InputEventScreenTouch.new()
  event.index=0
  event.position=point
  event.pressed=pressed
  Input.parse_input_event(event)
  await process_frame
 await settle()
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.title_requested=true
 var boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 current_scene=boot
 boot.set_process(false)
 for resolution in [Vector2i(360,640),Vector2i(540,960),Vector2i(591,1280),Vector2i(1280,800)]:
  root.size=resolution
  await settle()
  boot._process(0)
  await settle()
  var screen_transform=root.get_screen_transform()
  check(absf(screen_transform.x.length()-screen_transform.y.length())<0.001,"Startup display scale is uniform "+str(resolution))
  check(boot.column.get_global_rect().position.y>=20,"Intro content stays below screen top "+str(resolution))
  check(boot.column.get_global_rect().end.y<=boot.size.y-20,"Intro content fits above screen bottom "+str(resolution))
  check(boot.play.size.y>=48,"Play keeps a touch-sized target "+str(resolution))
  check(boot.logo.stretch_mode in [TextureRect.STRETCH_KEEP_ASPECT_CENTERED,TextureRect.STRETCH_KEEP_ASPECT_COVERED],"Cover preserves its aspect ratio "+str(resolution))
  var image=root.get_texture().get_image()
  check(not image.is_empty(),"Actual startup frame renders "+str(resolution))
  image.save_png("/workspace/timber-startup-%sx%s.png" % [resolution.x,resolution.y])
 root.size=Vector2i(540,960)
 await settle()
 # Also exercise a truly narrow logical canvas rather than relying only on stretch.
 boot.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
 boot.size=Vector2(360,640)
 await settle()
 check(boot.column.get_global_rect().position.y>=20 and boot.column.get_global_rect().end.y<=620,"A 360x640 logical intro fits without clipping")
 var deadline=Time.get_ticks_msec()+10000
 while not boot.ready_to_play and Time.get_ticks_msec()<deadline:
  boot._process(0)
  await process_frame
 check(boot.ready_to_play and boot.play.visible,"Explicit title return keeps a usable Continue action without a timed intro")
 game.state.tutorial=5
 await tap(boot.play)
 for i in 8: await process_frame
 check(current_scene!=null and current_scene.scene_file_path=="res://Scenes/Main.tscn","Real Play touch opens the playable world")
 check(current_scene.get("hud")!=null,"The real game HUD is available after the intro")
 print("STARTUP OPENGL: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
