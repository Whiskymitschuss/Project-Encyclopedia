extends SceneTree
var failures=[]
var checks=0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func draw() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func shot(name_value: String) -> void:
 await draw()
 root.get_texture().get_image().save_png("/workspace/timber-stone-"+name_value+".png")
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.city_services.enabled=false
 game.state.workers=9
 game.state.tool=5
 game.state.vehicle=6
 game.state.trucks=4
 game.state.company_xp=220
 game.state.coins=32000
 game.state.time=10
 game.state.weather=0
 for kind in ["quarry","stoneworks","quarry","stoneworks"]:
  var point=[Vector3(-20,0,-12),Vector3(20,0,-12),Vector3(44,0,-12),Vector3(-44,0,20)][game.state.buildings.size()-5]
  check(game.placement_reason(point).is_empty(),"Each demonstration site uses a legal free parcel")
  game.state.buildings.append({"kind":kind,"level":1,"paused":false,"position":[point.x,point.z]})
 StoneIndustry.synchronize(game.state)
 game.set_stone_recipe(8,"gravel")
 var loaded=false
 for i in 300:
  game.step(1)
  var dump=false
  var stones=false
  for shipment in game.state.stone.shipments:
   if not shipment.arrived:
    if shipment.key=="rock": dump=true
    if shipment.key=="stone": stones=true
  if dump and stones and float(StoneIndustry.site(game.state,5).bucket)>0:
   loaded=true
   break
 check(loaded,"An actual simulation reaches simultaneous mineral loads and a loaded shovel")
 game.tick_clock=0.25
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.focus=Vector3(-1,0,-15)
 scene.zoom=125
 scene.set_camera()
 await draw()
 check(scene.get("network")==null,"The new chapter does not recreate any inter-building conveyors")
 check(scene.delivery_world.badges.size()==4,"Every real mineral site has its own material counter")
 var excavator=null
 var plant=null
 for model in scene.world_buildings.get_children():
  if model.get_meta("kind","")=="stoneworks":
   var index=int(model.get_node("StonePlant").building_index)
   var data=StoneIndustry.site(game.state,index)
   check(model.get_node("Stock/StonePile").visible==(data.stock.stone>0) and model.get_node("Stock/GravelPile").visible==(data.stock.gravel>0),"Finished building stones and loose gravel have distinct stock models tied to their actual quantities")
  if model.get_meta("kind","")=="quarry" and model.position.x<0:
   excavator=model.get_node("Excavator")
   plant=model.get_node("StonePlant")
 check(excavator!=null and excavator.turret!=null and excavator.boom!=null and excavator.stick!=null and excavator.bucket!=null,"Excavator has an articulated turret, boom, stick and actual bucket")
 check(excavator.load_mesh.visible==(StoneIndustry.site(game.state,5).bucket>0),"The visible shovel load follows its actual saved material")
 for shipment in game.state.stone.shipments:
  var truck=scene.delivery_world.visuals[scene.delivery_world.visual_key(shipment)]
  check(truck.cargo.visible==not shipment.arrived,"Every rendered truck shows loaded or empty status from the simulation")
  if shipment.key in ["rock","gravel"]: check(truck.get("bed")!=null,"Bulk raw material uses a real tipper model")
  if shipment.key=="stone": check(truck.cargo_stone and truck.trailer!=null,"Palletized building stones travel on the upgraded flatbed trailer")
 for shipment in game.state.stone.shipments:
  if shipment.key!="stone" or shipment.arrived: continue
  var saved_age=float(shipment.age)
  shipment.age=float(shipment.travel)
  game.tick_clock=0
  scene.delivery_world._process(0.1)
  var node=scene.delivery_world.visuals[scene.delivery_world.visual_key(shipment)]
  var parked=node.position
  game.tick_clock=0.8
  scene.delivery_world._process(0.1)
  check(node.position==parked and node.cargo.visible,"A loaded truck waiting for warehouse space stays at the dock without visual return jitter")
  shipment.age=saved_age
  game.tick_clock=0.25
  break
 await shot("industry")
 scene.focus=Vector3(-20,0,-12)
 scene.zoom=68
 scene.set_camera()
 await shot("quarry")
 var old=Vector3(excavator.turret.rotation.y,excavator.boom.rotation.x,excavator.bucket.rotation.x)
 game.simulate(0.5)
 game.tick_clock=0
 await draw()
 check(Vector3(excavator.turret.rotation.y,excavator.boom.rotation.x,excavator.bucket.rotation.x)!=old,"Real extraction progress animates the turret, arm or tipping bucket according to its actual phase")
 scene.hud.open_menu("stone")
 await shot("menu")
 check(scene.hud.modal_title.text=="STEINBRUCH & BAUSTOFFE" and scene.hud.scroll.get_v_scroll_bar().max_value>scene.hud.scroll.size.y,"Production choices, depot and sites exist in the working scrollable mobile menu")
 scene.hud.close_menu()
 scene.begin_placement({"kind":"stoneworks","city":false,"index":-1})
 scene.focus=scene.placement_point
 scene.zoom=100
 scene.set_camera()
 await draw()
 check("Bretter" in scene.hud.placement_materials.text and "Später per LKW" in scene.hud.placement_materials.text,"Construction preview shows actual later deliveries before purchase")
 check(scene.hud.placement_materials.get_global_rect().end.y<scene.hud.placement_confirm.get_global_rect().position.y,"Material description fits above the confirmation controls")
 await shot("preview")
 scene.cancel_placement()
 # Level-four-plus city blueprints must be placeable before their goods arrive.
 game.state.buildings.append({"kind":"prefab","level":1,"paused":false,"position":[-44,52]})
 scene.rebuild()
 for key in game.state.resources: game.state.resources[key]=0
 scene.begin_placement({"kind":"house","city":true,"index":-1})
 scene.placement_point=Vector3(-40,0,116)
 scene.update_ghost()
 check(not scene.hud.placement_confirm.disabled,"A valid paid city blueprint is not wrongly blocked by materials that should arrive after construction starts")
 check("Später per LKW" in scene.hud.placement_materials.text,"City placement correctly distinguishes later material deliveries from immediate coin costs")
 scene.cancel_placement()
 root.size=Vector2i(360,640)
 scene.hud.show_building(6)
 await draw()
 check(scene.hud.scroll.size.x>0 and scene.hud.scroll.size.y>0,"Mining management fits a smaller portrait viewport")
 scene.queue_free()
 await process_frame
 print("VISUAL STONE: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
