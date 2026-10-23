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
 var worker_script=load("res://NPCs/Worker.gd")
 var game=root.get_node("Game")
 game.set_process(false)
 game.restore(JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/forestry288-company.json")))
 var s=game.state
 s.workers=31.0
 s.tool=11.0
 s.resources.wood=802
 s.resources.boards=200
 s.companion_enabled=false
 s.tutorial=5
 s.construction_intro=true
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.size=Vector2i(591,1280)
 root.content_scale_size=root.size
 root.add_child(scene)
 scene.set_process(false)
 scene.hud.ux.set_process(false)
 scene.life.set_process(false)
 scene.sync_actors()
 var foresters=[]
 var machines=[]
 for actor in scene.actors.get_children():
  actor.set_process(false)
  if actor.get_script()==worker_script and actor.role=="forester": foresters.append(actor)
  elif actor.has_meta("forestry_tier"): machines.append(actor)
 check(foresters.size()>=4 and machines.size()>0,"31 saved workers with a purchased harvester retain visible beaver woodcutters beside machinery")
 check(scene.life.people().size()+machines.size()<=22,"The complete hired crew and resident representatives keep the existing bounded mobile crowd budget")
 if foresters.is_empty() or machines.is_empty():
  scene.queue_free()
  await process_frame
  quit(1)
  return
 var worker=foresters[0]
 var machine=machines[0]
 scene.focus=ForestryFlow.work_position(s)
 scene.zoom=340
 scene.set_camera()
 await settle()
 var meshes=worker.body.find_children("*","MeshInstance3D",true,false)
 check(not meshes.is_empty() and meshes.all(func(mesh): return mesh.visibility_range_end==0),"Hired forest beavers no longer vanish at the old 260m camera-distance cutoff in an orthographic overview")
 game.step(1)
 game.step(1)
 check(float(game.flow.harvest)>0 and float(s.journey.stats.get("automatic_wood",0))>0,"The real company's crew earns wood after a genuine collection without any chop/deposit call")
 var before=s.duplicate(true)
 worker.phase=0
 worker.work_left=0
 worker._process(0.2)
 machine.work_left=0
 machine._process(0.2)
 check(worker.working and worker.axe.visible and not worker.pack.visible,"An actual hired beaver visibly swings the axe for accepted autonomous production")
 check(machine.working,"The actual purchased forestry machine operates alongside that beaver")
 scene.focus=ForestryFlow.work_position(s)
 scene.zoom=72
 scene.set_camera()
 var on_screen=scene.camera.unproject_position(worker.global_position+Vector3.UP*1.5)
 check(on_screen.y<scene.hud.bottom_panel.get_global_rect().position.y and on_screen.y>scene.hud.header_panel.get_global_rect().end.y,"The focused working beaver is visible between the HUD panels rather than hidden under the bottom material bar")
 scene.on_harvested(0,0)
 check(scene.trees[0].any(func(tree): return tree.regrow>0),"Accepted automatic production triggers a real falling tree in the working forest")
 check(s==before,"Beaver limbs, machinery and falling trees cannot mint or consume inventory")
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber289-crew.png")
 # Real construction freight finishing must not destroy/reset the forest crew.
 var identity=worker.get_instance_id()
 check(not s.construction_shipments.is_empty(),"The regression fixture includes real parallel construction freight")
 ConstructionRules.transport_tick(s,2000)
 scene.sync_actors()
 check(is_instance_valid(worker) and worker.get_instance_id()==identity and worker.is_inside_tree(),"Ending a real construction truck run preserves the forester and its earned work cycle")
 check(ForestryFlow.loading(s,worker.production_index),"An actual wood pickup is reserved or being loaded at the worker's own station")
 game.flow={"harvest":0}
 worker.work_left=0
 worker.phase=1
 machine.work_left=0
 before=s.duplicate(true)
 var blade=machine.saw.rotation.y
 worker._process(0.2)
 machine._process(0.2)
 check(worker.handling and worker.pack.visible and not worker.axe.visible and not worker.working,"Workers prepare the actual booked log load with a carrying animation instead of pretending to cut more trees")
 check(machine.handling and not machine.working and machine.saw.rotation.y==blade,"The harvester handles actual outbound logs with its blade stopped when there is no accepted felling")
 check(s==before,"Preparing a reserved load does not credit its inventory twice")
 CentralLogistics.tick(s,2000)
 worker.work_left=0
 machine.work_left=0
 worker._process(0.1)
 machine._process(0.1)
 check(not worker.handling and not worker.working and not worker.pack.visible and not machine.handling and not machine.cargo.visible,"Without either accepted harvest or a real loading task, the crew does not fake work or retain a phantom log load")
 scene.hud.open_menu("team")
 await settle()
 var labels=scene.hud.contents.find_children("*","Label",true,false)
 check(labels.any(func(label): return label.text.begins_with("31 / ")),"The real team card renders the restored worker count as an integer")
 check(labels.any(func(label): return label.text.contains("Automatisch gewonnen seit Update:")),"The live team card shows its independent automatic production ledger")
 var auto_before=float(s.journey.stats.automatic_wood)
 game.chop()
 game.deposit()
 check(float(s.journey.stats.automatic_wood)==auto_before,"Manual actions in this main-world company cannot disguise a stalled automatic crew")
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber289-team.png")
 var focus_button=null
 for button in scene.hud.contents.find_children("*","Button",true,false):
  if button.text=="HOLZFÄLLER ANSEHEN": focus_button=button; break
 check(focus_button!=null,"A team action locates the actual active forest")
 if focus_button!=null:
  scene.focus=Vector3(100,0,140)
  focus_button.pressed.emit()
  check(scene.focus==ForestryFlow.work_position(s) and scene.zoom==86 and not scene.hud.overlay.visible,"The actual team button focuses the crew and closes the menu")
 for quality in [0,1]:
  s.quality=quality
  scene.sync_actors()
  var count=0
  var axemen=0
  var rigs=0
  for actor in scene.actors.get_children():
   if actor.get_script()==worker_script and actor.role=="resident": continue
   count+=1
   if actor.get_script()==worker_script and actor.role=="forester": axemen+=1
   if actor.has_meta("forestry_tier"): rigs+=1
  check(axemen>0 and rigs>0 and count<=(8 if quality==0 else 16),"Both beavers and harvesters survive within the hired actor budget in quality %s" % quality)
 for resolution in [Vector2i(360,640),Vector2i(540,960)]:
  root.size=resolution
  root.content_scale_size=resolution
  s.ux.large_text=true
  scene.hud.ux.apply_accessibility()
  scene.hud.open_menu("team")
  await settle()
  check(scene.hud.scroll.size.y>=140 and scene.hud.contents.size.x<=resolution.x,"Live worker status remains usable with large text at "+str(resolution))
 scene.queue_free()
 await process_frame
 await process_frame
 print("VISUAL FORESTRY 289: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
