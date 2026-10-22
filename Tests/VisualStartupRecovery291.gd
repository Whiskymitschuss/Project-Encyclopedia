extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func settle() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.restore(game.initial_state())
 var boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 current_scene=boot
 await settle()
 game.queue_catchup(28800,Journey.resume_capture(game.state),28800)
 await settle()
 var curtain=game.catchup_curtain
 check(curtain!=null and curtain.visible and curtain.layer>0,"A real rendered loading screen covers the intro while recovery is pending")
 check(game.state.elapsed==0 and game.catchup_running,"The initial loading frame is presented before any manual offline processing")
 for resolution in [Vector2i(360,640),Vector2i(540,960),Vector2i(591,1280),Vector2i(1280,800)]:
  root.size=resolution
  await settle()
  var bounds=Rect2(Vector2.ZERO,root.get_visible_rect().size)
  var later=curtain.find_children("*","Button",true,false)[0]
  check(bounds.encloses(curtain.caption.get_global_rect()),"Recovery title fits on screen "+str(resolution))
  check(bounds.encloses(later.get_global_rect()) and later.size.y>=48,"Safe exit remains visible and touch-sized "+str(resolution))
  check(curtain.progress.size.x>=280 and bounds.encloses(curtain.progress.get_global_rect()),"Recovery progress is readable without clipping "+str(resolution))
  var transform=root.get_screen_transform()
  check(absf(transform.x.length()-transform.y.length())<0.001,"Loading UI preserves its aspect ratio "+str(resolution))
  var frame=root.get_texture().get_image()
  check(not frame.is_empty(),"Loading screen produces an actual OpenGL frame "+str(resolution))
  if resolution==Vector2i(591,1280): frame.save_png("/workspace/timber-startfix291-loading.png")
 game.process_catchup(1000000,120)
 await settle()
 check(curtain.progress.value>0 and curtain.detail.text.contains("480"),"Progress visibly updates across frames during a long absence")
 boot.start_game()
 check(not boot.starting,"Covered Play cannot bypass incomplete recovery")
 # Restore simulates restarting after a canceled run, keeping the same profile.
 var saved=game.initial_state()
 saved.tutorial=5
 game.restore(saved)
 await settle()
 check(game.catchup_curtain==null and boot.process_mode==Node.PROCESS_MODE_INHERIT,"Canceling recovery removes its input barrier and restores the intro")
 game.queue_catchup(10,Journey.resume_capture(game.state),10)
 await settle()
 game.process_catchup(1000000,120)
 await settle()
 check(not game.catching_up and game.catchup_curtain==null,"Successful recovery reveals the real intro")
 root.size=Vector2i(540,960)
 await settle()
 var point=root.get_screen_transform()*boot.play.get_global_rect().get_center()
 for pressed in [true,false]:
  var event=InputEventScreenTouch.new()
  event.position=point
  event.pressed=pressed
  Input.parse_input_event(event)
  await process_frame
 for i in 12: await process_frame
 check(current_scene!=null and current_scene.scene_file_path=="res://Scenes/Main.tscn" and current_scene.get("hud")!=null,"After recovery, a physical Play touch opens the actual world and HUD")
 print("STARTUP RECOVERY OPENGL: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
