extends SceneTree
var checks=0
var failures=[]
func _initialize(): call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func settle():
 for i in 5:await process_frame
 await RenderingServer.frame_post_draw
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 game.state=game.initial_state();var s=game.state
 s.workers=31;s.biome=1;s.unlocked=2;s.tool=11;s.tutorial=5;s.construction_intro=true
 s.city_services.enabled=false;s.companion_enabled=false;s.time=10
 ForestCycle.take(s,1,100000)
 s.elapsed+=1;ForestCycle.tick(s,1)
 root.size=Vector2i(591,1280);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.life.set_process(false);scene.hud.ux.set_process(false);scene.forest_world.set_process(false)
 scene.focus=Catalog.biome_position(1);scene.zoom=90;scene.set_camera()
 scene.forest_world.sync_trees(false);scene.forest_world.update_planters(0.1);scene.forest_world.update_work_status()
 await settle()
 check(scene.forest_world.planters.size()>0 and scene.forest_world.planters.size()<=3 and scene.forest_world.planters.values().any(func(worker):return worker.visible),"Actual depleted main-world forest has a bounded visible planting team")
 check(scene.forest_world.work_status.text.contains("forsten"),"An empty stand explains real replanting work")
 root.get_texture().get_image().save_png("/workspace/timber2817-bare.png")
 var task=s.forest.tasks[0]
 while not task.planted:
  s.elapsed+=1;ForestCycle.tick(s,1)
 scene.forest_world.sync_trees(false);scene.forest_world.update_planters(0.1);scene.forest_world.update_work_status();await settle()
 var cell=s.forest.stands["1"].cells[str(int(task.cell))]
 var scale_value=scene.tree_batches[1][0].multimesh.get_instance_transform(int(task.cell)).basis.get_scale().x
 check(cell.grow_seconds==45 and scale_value>0.01 and scale_value<float(scene.trees[1][int(task.cell)].scale),"A planted real seedling renders small with its own saved 45-second duration")
 check(scene.forest_world.work_status.text.contains("erntereif"),"Main world shows the actual next maturity countdown")
 root.get_texture().get_image().save_png("/workspace/timber2817-seedlings.png")
 var before=s.duplicate(true)
 scene.forest_world.sync_trees(false);scene.forest_world.update_planters(0.2)
 check(s==before,"Rendering growth and beaver motion cannot advance planting or create inventory")
 var deadline=float(cell.ready_at)
 while float(s.elapsed)<deadline:
  s.elapsed+=1;ForestCycle.tick(s,1)
 scene.forest_world.sync_trees(false);scene.forest_world.update_planters(0.1);scene.forest_world.update_work_status();await settle()
 scale_value=scene.tree_batches[1][0].multimesh.get_instance_transform(int(task.cell)).basis.get_scale().x
 check(absf(scale_value-float(scene.trees[1][int(task.cell)].scale))<0.00001 and not s.forest.stands["1"].cells.has(str(int(task.cell))),"Only an actually mature tree regains its full main-world mesh")
 root.get_texture().get_image().save_png("/workspace/timber2817-recovered.png")
 for size_value in [Vector2i(360,640),Vector2i(591,1280)]:
  root.size=size_value;root.content_scale_size=root.size
  for large in [false,true]:
   s.ux.large_text=large;scene.hud.ux.apply_accessibility();scene.hud.open_menu("team");await settle()
   check(scene.hud.contents.size.x<=scene.hud.scroll.size.x+1,"Growth status fits the actual team menu: %s / %s" % [size_value,large])
   check(scene.hud.contents.find_children("*","Label",true,false).any(func(label):return label.text.contains("erntereif")),"Actual menu explains the new growth duration")
 s.ux.large_text=false
 print("VISUAL REGROWTH 2817: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
