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
func mill(scene: Node) -> Node:
 for model in scene.world_buildings.get_children():
  var process=model.get_node_or_null("Processing")
  if process!=null and int(process.building_index)==1: return model
 return null
func run() -> void:
 await process_frame
 var saw_models=load("res://Buildings/SawmillModels.gd")
 var game=root.get_node("Game");game.set_process(false)
 root.get_node("RuntimeStats").set_process(false)
 game.state=game.initial_state();var s=game.state
 s.tutorial=5;s.construction_intro=true;s.companion_enabled=false;s.city_services.enabled=false;s.auto_export=false
 s.workers=8;s.coins=100000;s.company_xp=600
 s.buildings[1].level=7;s.buildings[1].saw_lines=3
 s.buildings.append({"kind":"central_depot","level":2,"paused":false,"position":[44,20]})
 LogisticsDispatch.synchronize(s)
 s.hub.inputs["1"]={"wood":80.0}
 for tick in 3: game.step(1)
 # A real stump and an actually assigned planting task are shared with the view.
 ForestCycle.take(s,0,24)
 s.elapsed+=1;ForestCycle.tick(s,1)
 root.size=Vector2i(591,1280);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene)
 scene.set_process(false);scene.hud.ux.set_process(false);scene.life.set_process(false);scene.forest_world.set_process(false)
 scene.sync_actors()
 scene.focus=game.building_position(1);scene.zoom=65;scene.set_camera()
 await settle()
 var model=mill(scene);var process=model.get_node("Processing")
 process.set_process(false);process._process(0.5)
 check(process.lanes.size()==3 and process.lanes.all(func(lane): return lane.node.visible),"Three actually owned parallel lines are visible in the main sawmill")
 check(model.get_node("Architecture").get_child_count()==7 and model.get_meta("stage_name")==saw_models.STAGES[6],"The actual completed economic level selects its physical architectural stage")
 for lane in process.lanes:
  check(lane.node.has_node("Debarker") and lane.node.has_node("Operator") and lane.rotor!=null and lane.planer!=null,"Each line has its own debarker, saw, planer and beaver operator")
 var before=s.duplicate(true)
 process._process(0.3)
 check(s==before,"The three visible production lines cannot advance work or write inventory")
 root.get_texture().get_image().save_png("/workspace/timber2812-mill.png")
 var silhouettes=[]
 for level in range(1,11):
  s.buildings[1].level=level;s.buildings[1].saw_lines=SawmillProduction.line_limit(level)
  scene.rebuild();await settle()
  model=mill(scene)
  check(model.get_meta("evolution_level")==level and model.get_node("Architecture").get_child_count()==level,"Stage %s is integrated into the actual main world" % level)
  silhouettes.append(model.get_node("Architecture").find_children("*","MeshInstance3D",true,false).size())
  root.get_texture().get_image().save_png("/workspace/timber2812-stage-%02d.png" % level)
 check(silhouettes.size()==10 and silhouettes[0]!=silhouettes[9],"Building development changes structural geometry, not just root scale or paint")
 # Actual planting/growth drives the existing instanced forest.
 check(not s.forest.tasks.is_empty(),"The main-world planting display uses an actual assigned worker task")
 if s.forest.tasks.is_empty():
  print("VISUAL TIMBER 2812: %s checks, %s failures" % [checks,failures.size()]);quit(1);return
 var task=s.forest.tasks[0]
 while float(task.age)<float(task.walk)+1: game.step(1)
 scene.focus=ForestLayout.point(int(task.biome),int(task.cell));scene.zoom=70;scene.set_camera()
 scene.forest_world.sync_trees(false);scene.forest_world.update_planters(0.1)
 await settle()
 check(not scene.forest_world.planters.is_empty(),"An actual planting task has a bounded beaver representative")
 var worker=scene.forest_world.planters.get(int(task.id))
 if worker!=null:
  check(worker.visible and worker.position.distance_to(ForestLayout.point(int(task.biome),int(task.cell)))<2,"The actual planter reaches its planting position instead of being teleported onto the stump")
  check(worker.get_node_or_null("Beaver/RightArm/Spade")!=null and worker.get_node_or_null("Beaver/LeftArm/SeedlingTray")!=null,"The planter carries a spade and seedling tray")
 var tree=scene.trees[int(task.biome)][int(task.cell)]
 check(tree.regrow>0,"A harvested real tree remains a stump until its planting/growth process completes")
 before=s.duplicate(true)
 scene.forest_world.sync_trees(false);scene.forest_world.update_planters(0.2)
 check(s==before,"Planter animation and instanced tree scale never create seedlings or timber")
 root.get_texture().get_image().save_png("/workspace/timber2812-planting.png")
 while not task.planted: game.step(1)
 scene.forest_world.sync_trees(false)
 var grown_scale=scene.tree_batches[int(task.biome)][0].multimesh.get_instance_transform(int(task.cell)).basis.get_scale().x
 check(grown_scale>0.01 and grown_scale<float(tree.scale),"An actually planted cell renders a small growing tree instead of an instantly mature replacement")
 scene.hud.open_menu("team");await settle()
 check(scene.hud.contents.find_children("*","Button",true,false).any(func(button): return button.text=="Automatisch"),"Real team controls expose automatic and manual planter allocation")
 scene.hud.open_menu("timber_campus");await settle()
 check(scene.hud.modal_title.text=="DEIN HOLZWERKSHOF","The campus planner is connected to the ordinary main-world menu")
 root.get_texture().get_image().save_png("/workspace/timber2812-campus.png")
 scene.hud.show_building(1);await settle()
 check(scene.hud.contents.find_children("*","Label",true,false).any(func(label): return label.text.contains("Fertigungslinien")),"The selected sawmill explains its actual owned production lines and intermediate stock")
 for size_value in [Vector2i(360,640),Vector2i(540,960)]:
  root.size=size_value;root.content_scale_size=size_value;s.ux.large_text=true
  for tab in ["team","timber_campus","mill_stages"]:
   scene.hud.open_menu(tab);await settle()
   check(scene.hud.scroll.size.y>0 and scene.hud.overlay.get_global_rect().end.x<=size_value.x+1,"New industry controls fit the small/large-text menu: "+tab+str(size_value))
 scene.queue_free();await process_frame
 print("VISUAL TIMBER 2812: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
