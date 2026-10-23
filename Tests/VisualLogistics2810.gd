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
func find(parent: Node,caption: String) -> Button:
 for button in parent.find_children("*","Button",true,false):
  if button.text==caption: return button
 return null
func tap(button: Button) -> void:
 if button==null: check(false,"Touch target exists"); return
 var ancestor=button.get_parent()
 var scroll_touch=false
 while ancestor!=null:
  if ancestor is ScrollContainer: scroll_touch=true; break
  ancestor=ancestor.get_parent()
 for down in [true,false]:
  var event: InputEvent=InputEventScreenTouch.new() if scroll_touch else InputEventMouseButton.new()
  if not scroll_touch: event.button_index=MOUSE_BUTTON_LEFT
  event.position=root.get_screen_transform()*button.get_global_rect().get_center()
  event.pressed=down
  Input.parse_input_event(event)
  await process_frame
 await settle()
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 var s=game.state
 s.workers=0; s.trucks=0; s.builders=2; s.vehicle=3
 s.tutorial=5; s.construction_intro=true; s.company_xp=600
 s.reserve=false; s.auto_export=false; s.city_services.enabled=false; s.companion_enabled=false
 for b in s.buildings: b.paused=true
 s.buildings[3].paused=false
 s.buildings.append({"kind":"central_depot","level":1,"paused":false,"position":[44,20]})
 s.buildings.append({"kind":"express","level":1,"paused":false,"position":[-44,116]})
 s.resources.boards=20
 var job={"id":951,"type":"home","kind":"house","plot":1,"position":[-44,148],"materials":{"boards":8},"delivered":{},"total":980.0,"left":980.0}
 ConstructionRules.attach(job,2)
 s.jobs=[job]
 game.step(1)
 root.size=Vector2i(591,1280)
 root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.set_process(false)
 scene.life.set_process(false)
 scene.hud.ux.set_process(false)
 scene.crew_world.set_process(false)
 var site=null
 for child in scene.world_buildings.get_children():
  if child.get("job_id")==951: site=child; break
 var worker=null
 for child in site.get_children():
  if child.get("role")=="construction": worker=child; break
 worker.set_process(false)
 worker._process(0)
 check(not worker.visible and worker.work_state=="commuting","Assigned beavers do not appear on site before their real Sprinter arrives")
 var mission=s.crew.missions[0]
 for second in 240:
  if float(mission.get("depart_in",0))<=0 and float(mission.age)>float(mission.load) and not mission.arrived: break
  game.step(1)
 scene.crew_world._process(0.1)
 var van=scene.crew_world.vans.get(int(mission.id))
 check(van!=null and van.visible and van.moving and van.people==2,"A real moving main-world Sprinter carries the actual dispatched two-person crew")
 if van!=null:
  van._process(0.1)
  check(van.get_node_or_null("Driver")!=null and van.passengers.filter(func(person): return person.visible).size()==2,"The van has a beaver driver and the correct visible passenger representatives")
  check(van.get_node_or_null("SlidingDoor")!=null and van.get_child_count()>8,"The vehicle integrates an animated door, wheels, a roof ladder and work tools")
 var before=s.duplicate(true)
 scene.crew_world._process(0.2)
 if van!=null: van._process(0.2)
 check(s==before,"Vehicle wheels, steering, doors and passengers cannot advance the commute or invent staff/materials")
 scene.hud.ux.select_truck({"kind":"truck","domain":"crew","id":int(mission.id)})
 await settle()
 check(scene.hud.ux.sheet_title.text.contains("SPRINTER") and scene.selection_world.trip_domain(mission)=="crew","The moving Sprinter uses the real vehicle inspector and staff-route selection without being mislabelled as material freight")
 scene.hud.ux.hide_panels(true)
 if van!=null:
  scene.focus=van.global_position+Vector3(0,0,4)
  scene.zoom=65
  scene.set_camera()
  await settle()
  var picked=scene.selection_world.pick_truck(scene.camera.unproject_position(van.global_position+Vector3(0,2,0)))
  check(picked.get("domain","")=="crew" and int(picked.get("id",-1))==int(mission.id),"The actual moving van is selectable from its projected main-world position")
  root.get_texture().get_image().save_png("/workspace/timber2810-van.png")
 for second in 1800:
  if int(job.phase)==3 and ConstructionRules.phase_ready(job) and CrewTransport.working(s,job)==2: break
  game.step(1)
 check(int(job.phase)==3 and float(job.delivered.get("boards",0))>=6 and CrewTransport.working(s,job)==2,"Actual delivered boards and arrived staff advance the same main-world site to the walls phase")
 while fposmod(float(s.elapsed),10)<3 or fposmod(float(s.elapsed),10)>=4: game.step(1)
 worker._process(0)
 check(worker.visible and worker.work_state=="climbing" and worker.placed_ladder.visible and worker.position.y>0.6,"The real arrived beaver climbs a visible ladder during elevated construction")
 check(absf(worker.placed_ladder.global_position.y-(site.global_position.y+0.6))<0.001,"The ladder stays grounded while the worker climbs")
 game.step(1); game.step(1)
 before=s.duplicate(true)
 worker._process(0)
 check(worker.hammer.visible and worker.work_state=="hammering","Elevated workers visibly switch to their hand tool")
 check(s==before,"Ladders and hammer motions never consume or duplicate delivered construction materials")
 scene.focus=ConstructionRules.job_position(s,job)+Vector3(0,0,5)
 scene.zoom=70
 scene.set_camera()
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber2810-crew.png")
 var hud=scene.hud
 check(hud.navigation_buttons.any(func(item): return item.name=="Logistik"),"Logistics has a direct primary-navigation entry")
 hud.open_menu("logistics")
 await settle()
 check(hud.modal_title.text=="LOGISTIK" and find(hud.contents,"Betriebe")!=null,"The integrated logistics screen has dedicated factories, sites and trip views")
 check(hud.modal_title.is_visible_in_tree() and hud.modal_title.size.x>100 and hud.modal_title.size.y>=20,"The logistics title occupies a visible readable header area")
 await tap(find(hud.contents,"Betriebe"))
 check(hud.logistics_tab=="factories","A real touch opens the factory inventory/collection view")
 await tap(find(hud.contents,"Bestände"))
 check(hud.current=="stock" and hud.menu_back.visible,"Opening stocks retains a visible back action instead of losing the logistics context")
 await tap(hud.menu_back)
 check(hud.current=="logistics" and hud.logistics_tab=="factories","The native Back button restores the previous logistics tab under desktop mouse/touch emulation")
 await tap(find(hud.contents,"Baustellen"))
 check(hud.logistics_tab=="sites" and hud.contents.find_children("*","Label",true,false).any(func(label): return label.text.contains("vor Ort")),"The site view explains actual arrived staff separately from assigned staff and freight")
 hud.close_menu()
 hud.open_menu("more")
 await settle()
 var search=hud.contents.find_children("*","LineEdit",true,false)[0]
 search.grab_focus()
 for character in "Forschung":
  var key=InputEventKey.new(); key.unicode=character.unicode_at(0); key.pressed=true
  Input.parse_input_event(key)
  await process_frame
 await settle()
 var research=find(hud.contents,"Forschung  ›")
 check(search.has_focus() and research!=null and research.is_visible_in_tree(),"Typing in menu search filters existing controls without losing keyboard focus")
 check(not find(hud.contents,"Straßen & Wege  ›").is_visible_in_tree(),"Unrelated menu sections disappear while searching")
 await tap(research)
 check(hud.current=="research","A filtered menu result opens the actual research feature")
 hud.previous_menu()
 hud.close_menu()
 hud.open_menu("logistics")
 hud.logistics_tab="overview"
 hud.render_menu()
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber2810-logistics.png")
 for resolution in [Vector2i(360,640),Vector2i(540,960)]:
  root.size=resolution; root.content_scale_size=resolution
  s.ux.large_text=true
  for tab in ["overview","factories","sites","trips"]:
   hud.logistics_tab=tab
   hud.open_menu("logistics")
   hud.ux.apply_accessibility()
   await settle()
   check(hud.scroll.size.y>=120 and hud.contents.size.x<=hud.scroll.size.x+1,"The real logistics %s tab stays within a narrow large-font scroll viewport at %s" % [tab,resolution])
  hud.open_menu("more")
  hud.ux.apply_accessibility()
  await settle()
  check(hud.contents.size.x<=hud.scroll.size.x+1,"Search and category menus fit narrow large-font screens at "+str(resolution))
 # Reduced motion must also cover the newly added construction animations.
 s.ux.motion=false
 worker._process(0)
 var pose=worker.position
 s.elapsed+=1
 worker._process(0)
 check(worker.position==pose,"Reduced motion gives construction staff a stable working pose")
 # Actual regional receipts must be visible even for goods outside the former
 # three hardcoded express rack keys.
 s.resources.stone=4; s.resources.design=3.5
 CentralLogistics.launch(s,5,6,"stone",4,"express",s.resources)
 CentralLogistics.launch(s,5,6,"design",3.5,"express",s.resources)
 CentralLogistics.tick(s,600)
 var rack=null
 for model in scene.world_buildings.get_children():
  var controller=model.get_node_or_null("DepotStock")
  if controller!=null and int(controller.building_index)==6: rack=controller; break
 check(rack!=null,"The actual regional warehouse stock controller is present in the main world")
 if rack==null:
  scene.queue_free(); await process_frame; quit(1); return
 before=s.duplicate(true)
 rack._process(0.5)
 check(rack.stacks.any(func(entry): return entry.key=="stone" and entry.node.visible) and rack.stacks.any(func(entry): return entry.key=="design" and entry.node.visible),"Real regional stone and design-furniture receipts appear as their own warehouse cargo meshes")
 check(rack.stacks.filter(func(entry): return entry.node.visible).size()<=3 and s==before,"Express rack visibility is bounded and cannot book or duplicate inventory")
 check(rack.stacks.size()==Catalog.RESOURCES.size(),"Reusable depot cargo representations cover every material SKU")
 # The real stoneworks scene includes the same actual-load forklift service.
 s.ux.motion=true
 s.buildings.append({"kind":"stoneworks","level":1,"paused":true,"position":[-20,20]})
 StoneIndustry.synchronize(s)
 scene.rebuild()
 var stone_index=s.buildings.size()-1
 var stone_model=null
 for model in scene.world_buildings.get_children():
  var controller=model.get_node_or_null("StonePlant")
  if controller!=null and int(controller.building_index)==stone_index: stone_model=model; break
 if stone_model==null:
  check(false,"The main-world stoneworks controller is present")
  scene.queue_free(); await process_frame; quit(1); return
 var handler=stone_model.get_node_or_null("YardHandling")
 check(handler!=null and handler.operator!=null,"The main-world stoneworks includes a beaver-operated forklift")
 StoneIndustry.site(s,stone_index).stock.stone=5
 CentralLogistics.launch(s,stone_index,5,"stone",5,"central",StoneIndustry.site(s,stone_index).stock)
 var stone_trip=s.hub.shipments[-1]
 FreightFlow.advance(stone_trip,float(stone_trip.get("depart_in",0))+3.5)
 scene.focus=game.building_position(stone_index)
 scene.zoom=75
 scene.set_camera()
 before=s.duplicate(true)
 if handler!=null: handler._process(0.1)
 check(CargoTransfer.has_forklift(s,stone_trip,true) and handler!=null and handler.cycle_key=="stone" and handler.payload.visible,"A real reserved stone-block pickup drives the stoneworks forklift and its stone pallet")
 check(s==before,"Stone forklift geometry and payload transitions do not credit any goods")
 scene.queue_free()
 await process_frame; await process_frame
 print("VISUAL LOGISTICS 2810: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
