extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func settle() -> void:
 for i in 4: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.restore(JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/forestry288-company.json")))
 var s=game.state
 s.tutorial=5
 s.construction_intro=true
 s.companion_enabled=false
 game.flow={"harvest":0}
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.size=Vector2i(591,1280)
 root.content_scale_size=root.size
 root.add_child(scene)
 scene.set_process(false)
 scene.hud.ux.set_process(false)
 scene.sync_actors()
 scene.focus=Catalog.biome_position(0)
 scene.zoom=85
 scene.set_camera()
 await settle()
 var bar=scene.hud.material_bar
 bar.refresh()
 check(bar.warehouse_counts.wood.text.begins_with("L 0/") and bar.captions.wood.text.contains("↻") and bar.controls.wood.tooltip_text.contains("Abholung"),"A full forest and empty central shelf expose the pickup wait on the actual main screen")
 bar.controls.wood.pressed.emit()
 await settle()
 check(scene.hud.contents.find_children("*","Button",true,false).any(func(button): return button.text.contains("Abholvorrat 104/104")),"Tapping the main wood tile opens the actual collection-point stock and reason")
 scene.hud.close_menu()
 scene.hud.ux.hide_panels(true)
 var machines=[]
 for actor in scene.actors.get_children():
  if actor.has_meta("forestry_tier"):
   machines.append(actor)
   actor.set_process(false)
 check(not machines.is_empty(),"The advanced saved-company fixture creates the actual beaver-driven forestry machines")
 if machines.is_empty():
  scene.queue_free()
  await process_frame
  quit(1)
  return
 game.step(1)
 game.step(1)
 check(float(s.gathered)>3060.85 and float(game.flow.harvest)>0,"A real priority pickup frees the forest output and accepts a new harvested load")
 var before=s.duplicate(true)
 for machine in machines: machine._process(0.5)
 check(machines.any(func(machine): return machine.working),"The actual machines restart their earned work animation after the repaired pickup")
 scene.on_harvested(0,0)
 check(scene.trees[0].any(func(tree): return tree.regrow>0),"Working machinery triggers an actual main-world falling tree")
 scene.delivery_world._process(0.1)
 check(scene.delivery_world.visuals.size()>0,"Priority pickup cargo appears as a real road vehicle in the advanced company's world")
 check(s==before,"Rendering machines, tree falls and trucks leaves actual inventory and freight ownership unchanged")
 bar.refresh()
 check(not bar.captions.wood.text.contains("↻"),"The wait label clears once the actual harvest resumes")
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber288-forest.png")
 for resolution in [Vector2i(360,640),Vector2i(540,960)]:
  root.size=resolution
  root.content_scale_size=resolution
  s.ux.large_text=true
  scene.hud.ux.apply_accessibility()
  game.flow.harvest=0
  CentralLogistics.stock(s,0).wood=104
  bar.refresh()
  await settle()
  var label=bar.warehouse_counts.wood
  check(bar.controls.wood.get_global_rect().encloses(label.get_global_rect()) and label.get_minimum_size().x<=label.size.x,"Actual pickup wait remains readable at large font on "+str(resolution))
 scene.queue_free()
 await process_frame
 await process_frame
 print("VISUAL FORESTRY 288: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
