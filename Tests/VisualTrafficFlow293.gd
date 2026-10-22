extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func settle() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.restore(JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/traffic293-gridlock.json")))
 game.state.tutorial=5
 game.state.companion_enabled=false
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.focus=Vector3(-24,0,-6)
 scene.zoom=85
 scene.set_camera()
 root.size=Vector2i(591,1280)
 await settle()
 check(scene.delivery_world.visuals.size()==8,"All eight real saved freight trips create distinct models")
 var sold=game.state.delivery.sold
 game.set_block_signals(true)
 # The old loaded queue is re-dispatched once from its depots in 0.29.4.
 for i in 180: game.step(1)
 game.set_block_signals(false)
 game.changed.emit()
 await settle()
 check(game.state.delivery.sold>sold,"Rendered city sells actual deliveries after recovering the old queue")
 for t in game.state.delivery.shipments:
  var model=scene.delivery_world.visuals[scene.delivery_world.visual_key(t)]
  check(model.position.is_equal_approx(TrafficRules.sample(t,TrafficRules.visual_age(t,game.tick_clock)).position),"Displayed truck uses its collision-checked actual route position")
 game.state.time=14
 await settle()
 root.get_texture().get_image().save_png("/tmp/timber-traffic293.png")
 scene.hud.open_menu("traffic")
 await settle()
 check(scene.hud.modal_title.text=="VERKEHR & AMPELTECHNIK","Updated traffic information is reachable through the actual HUD")
 scene.queue_free()
 await process_frame
 print("VISUAL TRAFFIC FLOW 0.29.3: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
