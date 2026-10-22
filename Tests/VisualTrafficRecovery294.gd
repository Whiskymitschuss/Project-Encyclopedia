extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, why: String) -> void:
 checks+=1
 if not ok: failures.append(why); printerr("FAILED: ",why)
func settle() -> void:
 for i in 4: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 game.restore(JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/traffic294-junction.json")))
 game.state.companion_enabled=false
 game.state.tutorial=5
 game.state.time=14
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.focus=Vector3(0,0,15);scene.zoom=130;scene.set_camera()
 root.size=Vector2i(591,1280)
 await settle()
 var sold=game.state.delivery.sold
 game.set_block_signals(true)
 for i in 300:
  game.step(1)
  if i%30!=0: continue
  await settle()
  var ships=game.state.construction_shipments+game.state.delivery.shipments
  var visible=[]
  for t in ships:
   var model=scene.delivery_world.visuals.get(scene.delivery_world.visual_key(t))
   check(model!=null and model.visible==not t.get("traffic_hidden",false),"Queued loads stay in the depot; circulating freight uses its own visible model")
   if model!=null and model.visible: visible.append(model.position)
  for a in visible.size():
   for b in range(a+1,visible.size()): check(visible[a].distance_to(visible[b])>=2.5,"Visible freight cabs do not occupy the same road position")
 game.set_block_signals(false)
 game.changed.emit()
 await settle()
 check(game.state.delivery.sold>sold,"Actual furniture is sold while the former junction gridlock renders")
 var frozen=game.state.duplicate(true)
 scene.delivery_world._process(0.25)
 check(game.state==frozen,"Rendering never advances queue tickets, goods or trip clocks")
 root.get_texture().get_image().save_png("/tmp/timber-traffic294.png")
 scene.hud.open_menu("traffic")
 await settle()
 check(scene.hud.modal_title.text=="VERKEHR & AMPELTECHNIK","Traffic and depot information remains reachable in the actual HUD")
 scene.queue_free()
 await process_frame
 print("VISUAL TRAFFIC RECOVERY 0.29.4: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
