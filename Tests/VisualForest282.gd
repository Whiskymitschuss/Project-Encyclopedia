extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func settle() -> void:
 for i in 6: await process_frame
 await RenderingServer.frame_post_draw
func touch(at: Vector2,down: bool) -> void:
 var event=InputEventScreenTouch.new()
 event.position=root.get_screen_transform()*at
 event.pressed=down
 Input.parse_input_event(event)
 await process_frame
func tap(button: Button) -> void:
 var at=button.get_global_rect().get_center()
 await touch(at,true)
 await touch(at,false)
 await settle()
func find(node: Node,text: String) -> Button:
 for b in node.find_children("*","Button",true,false):
  if b.text.begins_with(text): return b
 return null
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 var store=root.get_node("Store")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.city_services.enabled=false
 game.state.coins=10000
 game.state.homes=[{"kind":"house","level":3,"plot":0,"rent_bank":55,"position":[-40,116]}]
 root.size=Vector2i(540,960)
 root.content_scale_size=Vector2i(540,960)
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.set_process(false)
 var hud=scene.hud
 hud.ux.set_process(false)
 scene.focus=game.home_position(0)
 scene.zoom=90
 scene.set_camera()
 await settle()
 var at=scene.camera.unproject_position(game.home_position(0)+Vector3(0,4,0))
 await touch(at,true)
 while Time.get_ticks_msec()-scene.hold_started<650: await process_frame
 scene._process(0)
 check(scene.placement.get("city",false) and int(scene.placement.get("index",-1))==0,"A real long press opens home relocation")
 await touch(at,false)
 check(game.home_position(0)==Vector3(-40,0,116),"Releasing a long press never commits the move")
 scene.placement_point=Vector3(-40,0,148)
 scene.update_ghost()
 await settle()
 await tap(hud.placement_confirm)
 check(game.home_position(0)==Vector3(-40,0,148),"Physical confirmation completes the long-press move")
 hud.ux.select_building(0,true)
 await settle()
 var undo=find(hud.ux.sheet_body,"LETZTES VERSETZEN")
 hud.ux.sheet_scroll.ensure_control_visible(undo)
 await settle()
 await tap(undo)
 check(game.home_position(0)==Vector3(-40,0,116) and game.state.homes[0].rent_bank==55,"Physical undo restores location and keeps earned rent")
 hud.close_menu()
 hud.ux.hide_panels(true)
 game.track_materials()
 game.state.elapsed+=10
 game.state.resources.boards+=5
 game.track_materials()
 hud.update_stats()
 check(hud.material_bar.captions.boards.text.contains("↗"),"Main HUD shows an observed rising stock trend")
 await tap(hud.material_bar.controls.boards)
 check(hud.current=="material_help","Stock counter still opens actual supply help")
 check(hud.contents.find_children("*","Label",true,false).any(func(label): return label.text.contains("Bestandstrend")),"Material help includes the measured per-minute trend")
 hud.open_menu("operations")
 await settle()
 check(hud.modal_title.text=="BETRIEBSÜBERSICHT" and find(hud.contents,"Holz · QUELLEN")!=null,"A real missing input has a direct remedy in Operations")
 await tap(find(hud.contents,"Holz · QUELLEN"))
 check(hud.current=="material_help" and hud.ux.material_key=="wood","Touching an actual bottleneck opens the correct resource")
 hud.open_menu("performance")
 await settle()
 await tap(find(hud.contents,"KAMERARUNDE STARTEN"))
 check(scene.performance_tour!=null,"Performance comparison starts the actual fixed camera tour")
 var tour=scene.performance_tour
 await create_timer(1.0).timeout
 await tap(tour.button)
 check(game.performance_results.frames>0 and game.performance_results.fps>0 and game.performance_results.p95_ms>0,"The tour measures rendered frame intervals and returns real results")
 check(hud.current=="performance" and scene.performance_tour==null,"Stopping restores the camera and opens the measurement result")
 hud.close_menu()

 # Use the actual render loop while replay is held off from committing by
 # this test's disabled Game processor. Closing/minimizing cannot save half.
 game.save(true)
 var hash=FileAccess.get_sha256(store.PATH)
 var elapsed=game.state.elapsed
 game.start_replay(120,Journey.resume_capture(game.state))
 await settle()
 check(game.replay_overlay.is_inside_tree() and game.replay_overlay.meter.value>=0,"The exported replay UI renders a real progress indicator")
 check(FileAccess.get_sha256(store.PATH)==hash and game.state.elapsed==elapsed,"Rendered replay never changes the committed save before adoption")
 for dimensions in [Vector2i(360,640),Vector2i(540,960)]:
  root.content_scale_size=dimensions
  root.size=dimensions
  await settle()
  var box=game.replay_overlay.meter.get_parent()
  check(box.get_global_rect().position.x>=0 and box.get_global_rect().end.x<=dimensions.x,"Startup progress stays within "+str(dimensions))
 game.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 var deadline=Time.get_ticks_msec()+10000
 while game.replay_progress()<1 and Time.get_ticks_msec()<deadline: await process_frame
 check(game.replay_progress()==1 and not RenderingServer.is_render_loop_enabled(),"Worker finishes even with the main render loop disabled")
 game.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 while game.catching_up and Time.get_ticks_msec()<deadline:
  game.poll_replay()
  await process_frame
 check(not game.catching_up and RenderingServer.is_render_loop_enabled(),"Resuming adopts a complete company and restores rendering")
 hud.open_menu("return")
 await settle()
 check(find(hud.contents,"ZUM SÄGEWERK")!=null and find(hud.contents,"LIEFERUNGEN")!=null,"Return balance links to the real production and freight views")
 for size in [Vector2i(360,640),Vector2i(540,960),Vector2i(1100,700)]:
  root.content_scale_size=size
  root.size=size
  game.state.ux.large_text=true
  for tab in ["operations","performance","return"]:
   hud.open_menu(tab)
   await settle()
   check(hud.overlay.get_global_rect().end.x<=hud.size.x+1 and hud.scroll.size.y>=120,"New operational panels fit large text at "+str(size)+tab)
 root.content_scale_size=Vector2i(540,960)
 root.size=Vector2i(540,960)
 game.state.ux.large_text=false
 hud.close_menu()
 scene.focus=Vector3(-21,0,-43)
 scene.zoom=120
 scene.set_camera()
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber282-art-direction.png")
 scene.queue_free()
 await process_frame
 print("VISUAL FOREST 282: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
