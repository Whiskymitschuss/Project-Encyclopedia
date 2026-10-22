extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,why: String) -> void:
 checks+=1
 if not ok: failures.append(why); printerr("FAILED: ",why)
func settle() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 var fixture=JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/offline292-city.json"))
 fixture.tutorial=5
 game.restore(fixture)
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 current_scene=scene
 await settle()
 scene.hud.close_menu()
 var saved=game.state.duplicate(true)
 game.queue_catchup(1800,Journey.resume_capture(game.state),1800)
 check(scene.process_mode==Node.PROCESS_MODE_DISABLED and game.catchup_worker!=null,"Existing 3D world is frozen before its independent worker starts")
 await settle()
 check(game.catchup_curtain!=null and game.catchup_curtain.visible,"Actual OpenGL loading screen covers the paused world")
 check(game.state==saved,"Rendered world retains its original company while computation is detached")
 var work=game.catchup_worker
 var before=float(work.progress().remaining)
 game.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 OS.delay_msec(200)
 var progress=work.progress()
 check(progress.complete or float(progress.remaining)<before,"Worker advances during a blocked OpenGL loop and minimized application notification")
 check(game.state==saved,"Background work cannot modify the currently rendered company")
 game.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 for i in 1500:
  game.process_catchup()
  if not game.catching_up: break
  await process_frame
 await settle()
 check(not game.catching_up and game.catchup_worker==null,"App return joins and releases the worker")
 check(game.state.elapsed>=1800 and game.state.homes.size()==20,"Existing city receives actual offline production without resetting its buildings")
 check(scene.process_mode==Node.PROCESS_MODE_INHERIT and game.catchup_curtain==null,"World processing and input resume after full adoption")
 scene.hud.close_menu()
 await settle()
 var trees=int(game.state.trees)
 var point=root.get_screen_transform()*scene.hud.chop_button.get_global_rect().get_center()
 for pressed in [true,false]:
  var event=InputEventScreenTouch.new()
  event.position=point
  event.pressed=pressed
  Input.parse_input_event(event)
  await process_frame
 await settle()
 check(game.state.trees==trees+1,"Physical touch works again in the real world after background recovery")
 root.get_texture().get_image().save_png("/workspace/timber292-resumed-world.png")
 print("BACKGROUND RECOVERY OPENGL: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
