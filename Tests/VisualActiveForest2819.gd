extends SceneTree
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func settle():
 for frame in 5:await process_frame
 await RenderingServer.frame_post_draw
func tick(s: Dictionary):
 s.elapsed+=1;ForestCycle.tick(s,1)
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 game.state=game.initial_state();var s=game.state
 s.workers=31;s.tool=14;s.biome=1;s.unlocked=2;s.research.forestry=10
 s.boosters.workers={"factor":2.0,"left":2000.0}
 s.tutorial=5;s.construction_intro=true;s.city_services.enabled=false;s.companion_enabled=false;s.time=10
 for index in 100:ForestCycle.stand(s,1).cells[str(index)]={"state":"stump","wood":0.0}
 ForestCycle.stand(s,0)
 var center=Catalog.biome_position(1)
 s.buildings.append({"kind":"warehouse","level":1,"position":[center.x+34,center.z+34]})
 s.buildings.append({"kind":"central_depot","level":1,"paused":true,"position":[44,20]})
 LogisticsDispatch.synchronize(s)
 CentralLogistics.stock(s,0).wood=CentralLogistics.output_capacity(s,0)
 tick(s)
 root.size=Vector2i(591,1280);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.life.set_process(false);scene.hud.ux.set_process(false);scene.forest_world.set_process(false)
 scene.focus=center;scene.zoom=90;scene.set_camera()
 scene.forest_world.sync_trees(false);scene.forest_world.update_planters(0.1);await settle()
 check(not scene.forest_world.planters.is_empty(),"The actual bare active forest shows assigned beaver planters")
 var id=scene.forest_world.planters.keys()[0]
 var task=s.forest.tasks.filter(func(item):return int(item.id)==int(id))[0]
 var route=ForestLayout.task_path(task)
 var worker=scene.forest_world.planters[id]
 check(route!=ForestLayout.path(1,int(task.cell)) and worker.position.distance_to(route[0]+Vector3.UP*0.6)<0.1,"A real main-world planter starts on its saved free side aisle")
 check(not ForestLayout.rectangles(s).any(func(rect):return ForestLayout.intersects(route,rect.grow(0.4))),"The displayed mission avoids the real obstructing warehouse and machine pads")
 root.get_texture().get_image().save_png("/workspace/timber2819-active-bare.png")
 while not task.planted:tick(s)
 scene.forest_world.sync_trees(false);scene.forest_world.update_planters(0.1);await settle()
 var cell=s.forest.stands["1"].cells[str(int(task.cell))]
 check(cell.grow_seconds==18 and cell.ready_at-float(cell.planted_at)==18,"The actual researched mission creates a real saved eighteen-second seedling")
 var scale_value=scene.tree_batches[1][0].multimesh.get_instance_transform(int(task.cell)).basis.get_scale().x
 check(scale_value>0.01 and scale_value<float(scene.trees[1][int(task.cell)].scale),"The active oak seedling really appears in the main-world MultiMesh")
 root.get_texture().get_image().save_png("/workspace/timber2819-active-growing.png")
 var before=s.duplicate(true)
 scene.forest_world.sync_trees(false);scene.forest_world.update_planters(0.1)
 check(s==before,"Route and growth animation never create inventory or advance mission clocks")
 var deadline=float(cell.ready_at)
 while float(s.elapsed)<deadline:tick(s)
 scene.forest_world.sync_trees(false);scene.forest_world.update_planters(0.1);await settle()
 scale_value=scene.tree_batches[1][0].multimesh.get_instance_transform(int(task.cell)).basis.get_scale().x
 check(not s.forest.stands["1"].cells.has(str(int(task.cell))) and absf(scale_value-float(scene.trees[1][int(task.cell)].scale))<0.00001,"A genuinely matured active oak tree regains full main-world geometry")
 check(CentralLogistics.stock(s,0).wood==CentralLogistics.output_capacity(s,0),"A full collection output stays full while its forest independently regrows")
 check(s.biome==1 and int(ForestCycle.availability(s,0).mature)==100,"The recovered starter forest and selected active forest remain intact")
 root.get_texture().get_image().save_png("/workspace/timber2819-active-recovered.png")
 for size_value in [Vector2i(360,640),Vector2i(591,1280)]:
  root.size=size_value;root.content_scale_size=root.size
  for large in [false,true]:
   s.ux.large_text=large;scene.hud.ux.apply_accessibility();scene.hud.open_menu("team");await settle()
   check(scene.hud.contents.size.x<=scene.hud.scroll.size.x+1,"Growth and access diagnostics fit the actual small/large-text menu")
   check(scene.hud.contents.find_children("*","Label",true,false).any(func(label):return label.text.contains("gesperrt")),"The actual forest overview distinguishes protected/blocked planting cells")
 print("VISUAL ACTIVE FOREST 2819: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
