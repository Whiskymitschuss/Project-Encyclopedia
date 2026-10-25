extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message);printerr("FAILED: ",message)
func settle() -> void:
 for frame in 6: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 game.state=game.initial_state();var s=game.state
 s.tutorial=5;s.construction_intro=true;s.city_services.enabled=false;s.companion_enabled=false;s.auto_export=false
 s.workers=8;s.vehicle=3;s.time=10
 s.buildings[1].level=5
 var chosen=["furniture","kiln","central_depot","prefab","stoneworks","quarry"]
 for kind in chosen:
  var at=game.free_position(Catalog.industry_position(s.buildings.size()),0,-1,-1,kind)
  s.buildings.append({"kind":kind,"level":5,"paused":false,"position":[at.x,at.z]})
 s.homes.append({"kind":"townhall","level":5,"plot":0,"position":[-44,116],"rent_bank":0})
 LogisticsDispatch.synchronize(s);StoneIndustry.synchronize(s)
 s.hub.inputs["1"]={"wood":80.0}
 for second in 3: game.step(1)
 root.size=Vector2i(591,1280);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.life.set_process(false);scene.hud.ux.set_process(false)
 scene.focus=Vector3(0,0,-20);scene.zoom=150;scene.set_camera()
 await settle()
 var mill: Node3D
 for model in scene.world_buildings.get_children():
  if model.get_meta("kind","")=="sawmill":mill=model;break
 check(mill!=null and mill.has_node("TycoonHall") and mill.get_meta("design_version",0)==2816,"The actual main-world sawmill uses the new authored hall")
 check(mill.has_node("Processing") and mill.has_node("YardHandling") and mill.has_node("Connections/Loading"),"The real machine, forklift and loading anchors survive the visual rework")
 var before=s.duplicate(true)
 var process=mill.get_node("Processing");process.set_process(false);process._process(0.3)
 check(s==before,"New architecture and moving production retain the original material ledger")
 root.get_texture().get_image().save_png("/workspace/timber2816-world.png")
 scene.focus=game.building_position(1);scene.zoom=52;scene.set_camera();await settle()
 root.get_texture().get_image().save_png("/workspace/timber2816-sawmill.png")
 for level in [1,3,5,7,10]:
  s.buildings[1].level=level;scene.rebuild();await settle()
  for model in scene.world_buildings.get_children():
   if model.get_meta("kind","")=="sawmill":mill=model;break
  check(mill.get_node("Architecture").get_child_count()==level and mill.has_node("TycoonHall/TradeEmblem"),"Main-world stage %s retains genuine structural growth and its trade sign" % level)
  root.get_texture().get_image().save_png("/workspace/timber2816-sawmill-%s.png" % level)
 var hall: Node3D
 scene.focus=game.home_position(0);scene.zoom=45;scene.set_camera()
 for level in [1,3,5,8,10]:
  s.homes[0].level=level;scene.rebuild();await settle()
  hall=null
  for model in scene.world_buildings.get_children():
   if model.get_meta("town_kind","")=="townhall":hall=model;break
  check(hall!=null and hall.has_node("CivicArchitecture") and hall.get_meta("design_version",0)==2816,"Real town hall stage %s uses its new civic architecture" % level)
  root.get_texture().get_image().save_png("/workspace/timber2816-townhall-%s.png" % level)
 for index in range(5,s.buildings.size()):
  scene.focus=game.building_position(index);scene.zoom=53;scene.set_camera();await settle()
  root.get_texture().get_image().save_png("/workspace/timber2816-"+str(s.buildings[index].kind)+".png")
  check(not root.get_texture().get_image().is_empty(),"Main-world family renders: "+str(s.buildings[index].kind))
 for size_value in [Vector2i(360,640),Vector2i(591,1280)]:
  root.size=size_value;root.content_scale_size=root.size
  for large in [false,true]:
   s.ux.large_text=large
   scene.hud.ux.apply_accessibility();scene.hud.open_menu("logistics");await settle()
   check(scene.hud.contents.size.x<=scene.hud.scroll.size.x+1,"Restyled menu fits %s, large text %s" % [size_value,large])
 s.ux.large_text=false
 print("VISUAL DESIGN 2816: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
