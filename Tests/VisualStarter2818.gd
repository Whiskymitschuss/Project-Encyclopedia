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
 ForestCycle.take(s,1,2.704*maxi(0,int(s.workers)-ForestCycle.busy(s)))
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 game.state=game.initial_state();var s=game.state
 s.workers=8;s.tool=11;s.biome=1;s.unlocked=2;s.tutorial=5;s.construction_intro=true
 s.city_services.enabled=false;s.companion_enabled=false;s.time=10
 for biome in [0,1]:
  for index in 100:ForestCycle.stand(s,biome).cells[str(index)]={"state":"stump","wood":0.0}
 s.forest.erase("next_plant_biome")
 game.restore(JSON.parse_string(JSON.stringify(s,"",true,true)));s=game.state
 tick(s)
 root.size=Vector2i(591,1280);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.life.set_process(false);scene.hud.ux.set_process(false);scene.forest_world.set_process(false)
 scene.focus=Catalog.biome_position(0);scene.zoom=95;scene.set_camera()
 scene.forest_world.sync_trees(false);scene.forest_world.update_planters(0.1);await settle()
 check(s.biome==1 and scene.forest_world.planters.size()>0,"The actual inactive starter forest has visible planting missions without switching production")
 var tasks=s.forest.tasks.filter(func(task):return int(task.biome)==0)
 check(not tasks.is_empty(),"Old starter stumps receive authoritative missions in the actual main scene")
 if tasks.is_empty():print("VISUAL STARTER 2818: ",checks," checks, ",failures.size()," failures");quit(1);return
 var task=tasks[0]
 root.get_texture().get_image().save_png("/workspace/timber2818-starter-bare.png")
 while not task.planted:tick(s)
 scene.forest_world.sync_trees(false);scene.forest_world.update_planters(0.1);await settle()
 var cell=s.forest.stands["0"].cells[str(int(task.cell))]
 var scale_value=scene.tree_batches[0][0].multimesh.get_instance_transform(int(task.cell)).basis.get_scale().x
 check(cell.state=="growing" and scale_value>0.01 and scale_value<float(scene.trees[0][int(task.cell)].scale),"An actually planted old starter stump grows a small real tree")
 root.get_texture().get_image().save_png("/workspace/timber2818-starter-seedlings.png")
 var deadline=float(cell.ready_at)
 while float(s.elapsed)<deadline:tick(s)
 scene.forest_world.sync_trees(false);scene.forest_world.update_planters(0.1);await settle()
 scale_value=scene.tree_batches[0][0].multimesh.get_instance_transform(int(task.cell)).basis.get_scale().x
 check(not s.forest.stands["0"].cells.has(str(int(task.cell))) and absf(scale_value-float(scene.trees[0][int(task.cell)].scale))<0.00001,"The inactive starter tree reaches maturity in the real main-world renderer")
 root.get_texture().get_image().save_png("/workspace/timber2818-starter-recovered.png")
 var before=s.duplicate(true)
 scene.forest_world.sync_trees(false);scene.forest_world.update_planters(0.2)
 check(s==before,"Drawing the inactive forest cannot create seedlings, wood or scheduler progress")
 for size_value in [Vector2i(360,640),Vector2i(591,1280)]:
  root.size=size_value;root.content_scale_size=root.size
  for large in [false,true]:
   s.ux.large_text=large;scene.hud.ux.apply_accessibility();scene.hud.open_menu("team");await settle()
   check(scene.hud.contents.size.x<=scene.hud.scroll.size.x+1,"All-forest overview fits the actual small/large text menu")
   check(scene.hud.contents.find_children("*","Label",true,false).any(func(label):return label.text.contains("Starter-Wald:") and label.text.contains("Eichenwald:")),"Actual menu reports both old and selected forest")
 scene.hud.ux.apply_accessibility();scene.hud.open_menu("team");await settle()
 var buttons=scene.hud.contents.find_children("*","Button",true,false).filter(func(button):return button.text=="STARTER-WALD ANSEHEN")
 check(buttons.size()==1,"A direct starter-field camera action exists in the actual team menu")
 if not buttons.is_empty():buttons[0].pressed.emit()
 await settle()
 check(not scene.hud.overlay.visible and scene.focus.distance_to(Catalog.biome_position(0))<0.01 and s.biome==1,"The starter camera action closes the menu and preserves the selected production forest")
 print("VISUAL STARTER 2818: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
