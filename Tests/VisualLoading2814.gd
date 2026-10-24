extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func settle() -> void:
 for i in 6: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 var store=root.get_node("Store")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.title_requested=true
 var before=game.state.duplicate(true)
 var boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 current_scene=boot
 boot.set_process(false)
 var deadline=Time.get_ticks_msec()+10000
 while not boot.ready_to_play and Time.get_ticks_msec()<deadline:
  boot._process(0)
  await process_frame
 check(boot.ready_to_play and not boot.starting,"Only explicit title return holds the ready cover")
 for resolution in [Vector2i(360,640),Vector2i(540,960),Vector2i(591,1280),Vector2i(1280,800)]:
  root.size=resolution
  root.content_scale_size=resolution
  await settle()
  var art=boot.artwork
  check(art.background.texture!=null and art.background.texture.get_size()==Vector2(1024,1536),"Original beaver cover is loaded at "+str(resolution))
  check(art.column.get_global_rect().position.x>=0 and art.column.get_global_rect().end.x<=resolution.x,"Loading controls fit horizontally at "+str(resolution))
  check(art.column.get_global_rect().end.y<=resolution.y-20,"Loading and return action clear the screen bottom at "+str(resolution))
  check(art.brand.get_global_rect().position.y>=20 and art.brand.get_global_rect().end.x<=resolution.x,"Live game wordmark clears the top and side edges at "+str(resolution))
  check(art.meter.size.y>=24 and art.play.size.y>=48,"Progress and return action stay readable at "+str(resolution))
  check(boot.find_children("*","SubViewport",true,false).is_empty(),"Cover has no additional 3D renderer at "+str(resolution))
  root.get_texture().get_image().save_png("/workspace/timber2814-cover-%sx%s.png" % [resolution.x,resolution.y])
 check(game.state==before,"All cover layouts leave the company unchanged")
 root.size=Vector2i(591,1280)
 root.content_scale_size=root.size
 game.save(true)
 var original=FileAccess.get_sha256(store.PATH)
 game.start_replay(120,Journey.resume_capture(game.state))
 await settle()
 var overlay=game.replay_overlay
 check(overlay.artwork.background.texture==boot.artwork.background.texture,"Offline replay reuses the same cover texture")
 check(overlay.meter.value==game.replay_progress()*100,"Offline loading percentage comes directly from the real worker")
 check(overlay.find_children("*","Button",true,false).all(func(button): return not button.visible),"Offline loading does not present a primary close-app or Continue button")
 check(FileAccess.get_sha256(store.PATH)==original and game.state==before,"Displaying real replay cannot save or adopt a partial company")
 root.get_texture().get_image().save_png("/workspace/timber2814-loading.png")
 deadline=Time.get_ticks_msec()+15000
 while game.catching_up and Time.get_ticks_msec()<deadline:
  game.poll_replay()
  await process_frame
 check(not game.catching_up,"The existing worker still commits a complete replay")
 boot.enter_requested=true
 boot._process(0)
 boot.start_game()
 for i in 12: await process_frame
 check(current_scene!=null and current_scene.scene_file_path=="res://Scenes/Main.tscn","The loaded cover enters the actual main scene once")
 check(current_scene.get("hud")!=null,"Main-world HUD remains integrated after the new cover")
 print("VISUAL LOADING 2814: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
