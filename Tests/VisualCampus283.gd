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
func find(node: Node,prefix: String) -> Button:
 for item in node.find_children("*","Button",true,false):
  if item.text.begins_with(prefix): return item
 return null
func tap(button: Button) -> void:
 var point=root.get_screen_transform()*button.get_global_rect().get_center()
 for pressed in [true,false]:
  var event=InputEventScreenTouch.new()
  event.position=point
  event.pressed=pressed
  Input.parse_input_event(event)
  await process_frame
 await settle()
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.city_services.enabled=false
 game.state.companion_enabled=false
 root.size=Vector2i(540,960)
 root.content_scale_size=root.size
 var before=game.state.duplicate(true)
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.set_process(false)
 scene.sync_actors()
 scene.hud.ux.set_process(false)
 var hud=scene.hud
 await settle()
 check(game.state==before,"New yard, forest compartments and HUD never migrate positions, change stocks or award progress")
 check(scene.base_streets.get_node_or_null("OpenProductionYard")!=null,"The actual world retains the forest and production detail root without a blanket slab")
 var trees=scene.trees[0]
 check(trees.size()==100 and absf(trees[0].point.z-trees[9].point.z)<1.5 and trees[10].point.z>trees[0].point.z+3,"The working forest has ten coherent planted rows, retaining its hundred harvestable trees")
 check(TownRules.road_cells(game.state.town)==TownRules.base_cells(),"Presentation leaves the real freight graph intact")
 var footpaths=game.state.duplicate(true)
 footpaths.town.roads=[{"kind":"path","cells":[[-140,-84],[-136,-84]]}]
 # Load rendering helpers after autoload initialization, as the real world does.
 var context=load("res://Components/StreetScape.gd").context(footpaths)
 check(not load("res://Components/ProductionCampus.gd").clear(Vector2(-140,-84),context,1.2),"Forest fences also leave a newly placed pedestrian path clear")
 check(hud.header_panel.size.y<80 and hud.mission_button.get_global_rect().end.y<130,"Compact wallet and goal free the upper world view")
 check(hud.material_bar.columns==3 and hud.bottom_panel.size.y<270,"Six real material counters fit two readable rows on a normal phone")
 scene.focus=game.building_position(1)
 scene.zoom=85
 scene.set_camera()
 scene.update_yard_handlers()
 await settle()
 var handler=scene.yard_handlers[0]
 handler.set_process(false)
 var machine=handler.get_parent().get_node("Processing")
 game.flow["building:%s" % machine.building_index]=1
 var position=handler.position
 handler._process(0.8)
 check(not handler.active and handler.position==position,"Production alone never invents a loaded forklift trip")
 var dock_trip={"id":883,"source":"station","origin":0,"destination":machine.building_index,"target":"sawmill","mode":"truck","key":"wood","amount":6,"path":LogisticsRoutes.road_route(game.state,0,machine.building_index),"age":8.0,"load":2.0,"drive":5.0,"unload":2.0,"travel":9.0,"total":16.0,"arrived":false}
 game.state.hub.shipments=[dock_trip]
 var stock=game.state.duplicate(true)
 handler._process(0.8)
 check(handler.active and handler.position!=position and handler.payload.visible,"An actual unloading phase drives the forklift with the real cargo type")
 check(game.state==stock,"Forklift presentation cannot duplicate materials or book a shipment")
 dock_trip.age=9
 handler._process(1)
 check(handler.payload.visible,"Unaccepted cargo stays on the forks while the destination inventory is full")
 game.state.ux.motion=false
 position=handler.position
 handler._process(1)
 check(handler.position==position,"Reduced motion freezes the new handler")
 dock_trip.arrived=true
 handler._process(0.1)
 check(not handler.payload.visible and handler.position==position,"Reduced motion keeps movement frozen while reflecting the actual completed cargo handoff")
 game.state.ux.motion=true
 handler._process(0.1)
 check(not handler.payload.visible,"The pallet disappears only after the authoritative inventory transfer")
 for i in 40: handler._process(0.25)
 check(handler.position==handler.points[0] and not handler.cycle_running,"The unloaded forklift returns empty to its own parking position")
 game.state.hub.shipments=[]
 game.state.ux.motion=true
 var worker=scene.actors.get_child(0)
 worker.set_process(false)
 worker.phase=0
 worker._process(0.1)
 check(worker.working and worker.axe.visible and not worker.pack.visible,"The forester visibly chops before loading the wood")
 worker.phase=5
 worker._process(0.1)
 check(worker.pack.visible and not worker.axe.visible,"The forester carries wood from forest toward the depot")
 worker.phase=14
 worker._process(0.1)
 check(not worker.pack.visible,"The return walk is empty after unloading")
 game.state.ux.motion=false
 var phase=worker.phase
 worker._process(1)
 check(worker.phase==phase,"Reduced motion also freezes the worker cycle")
 game.state.ux.motion=true
 var depot=scene.world_buildings.get_child(0)
 var hoist=depot.get_node("LoadingHoist")
 var trip={"id":888,"origin":0,"source":"station","target":"construction","job":999,"mode":"truck","key":"wood","amount":2,"age":0.5,"load":2.0,"drive":2.0,"travel":6.0,"total":10.0,"arrived":false,"path":[[-45,0.95,-43],[-45,0.95,-28]]}
 game.state.construction_shipments=[trip]
 hoist._process(0)
 var trolley=hoist.trolley.position
 trip.age=1.5
 hoist._process(0)
 check(hoist.active and hoist.trolley.position!=trolley,"Depot trolley and hook follow the real loading phase")
 game.state.ux.motion=false
 trolley=hoist.trolley.position
 trip.age=1.9
 hoist._process(0)
 check(hoist.trolley.position==trolley,"Reduced motion freezes the loading hoist")
 game.state.ux.motion=true
 game.state.construction_shipments=[]
 # Stress the presentation budget using existing buildings, without advancing the economy.
 for i in 8: game.state.buildings.append({"kind":"sawmill","level":1,"paused":false})
 scene.rebuild()
 scene.update_yard_handlers()
 check(scene.yard_handlers.filter(func(item): return item.presentation_enabled).size()<=6,"Standard mode permits at most six nearby workshop handlers")
 game.state.quality=0
 scene.update_yard_handlers()
 check(scene.yard_handlers.filter(func(item): return item.presentation_enabled).size()<=2,"Battery mode permits at most two workshop handlers")
 game.state.quality=1
 game.state.buildings=game.initial_state().buildings
 scene.rebuild()
 game.state.tutorial=0
 hud.open_menu("welcome")
 await settle()
 check(hud.coach.portrait.is_visible_in_tree() and hud.companion.portrait.running,"World introduction uses the animated existing Benno portrait")
 var content=hud.story_detail.text
 var initial_action=find(hud.contents,"LOS GEHT’S")
 var action_rect=initial_action.get_global_rect()
 for ratio in [0.0,0.25,0.6,1.0]:
  hud.story_detail.visible_ratio=ratio
  await settle()
  check(initial_action.get_global_rect()==action_rect,"Typewriter progress keeps the tutorial touch action stationary")
 await tap(find(hud.contents,"HOF ENTDECKEN"))
 check(hud.story_step==1 and hud.story_detail.text!=content and scene.focus==game.building_position(0),"Physical story touch advances the dialogue and focuses the actual depot")
 await tap(find(hud.contents,"HOF ENTDECKEN"))
 check(hud.story_step==2 and scene.focus==game.building_position(1),"Second story touch leads to the real open sawmill")
 var start=find(hud.contents,"LOS GEHT’S")
 hud.scroll.ensure_control_visible(start)
 await settle()
 await tap(start)
 check(game.state.onboarding.active and hud.coach.panel.visible,"Story leads into the existing playable tutorial")
 check(hud.coach.panel.get_global_rect().end.y<hud.chop_button.get_global_rect().position.y,"Dialogue leaves the real chop button unobstructed")
 for size in [Vector2i(360,640),Vector2i(540,960),Vector2i(1100,700)]:
  root.size=size
  root.content_scale_size=size
  hud.close_menu()
  await settle()
  hud.update_stats()
  await settle()
  check(hud.header_panel.get_global_rect().end.x<=size.x and hud.bottom_panel.get_global_rect().end.y<=size.y,"Compact interface remains within "+str(size))
  for button in hud.material_bar.controls.values():
   check(button.size.x>=44 and button.size.y>=44,"Material touch target remains usable at "+str(size))
  for alert in scene.production_alerts.pool:
   if alert.panel.is_visible_in_tree(): check(not alert.panel.get_global_rect().intersects(hud.coach.panel.get_global_rect()),"Transient warnings never cover the guide")
 root.size=Vector2i(540,960)
 root.content_scale_size=root.size
 game.end_tutorial()
 hud.close_menu()
 scene.focus=Vector3(-34,0,-38)
 scene.zoom=125
 scene.set_camera()
 hud.update_stats()
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber283-yard.png")
 scene.focus=Catalog.biome_position(0)+Vector3(14,0,16)
 scene.zoom=100
 scene.set_camera()
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber283-forest.png")
 var existing=game.state.duplicate(true)
 hud.open_menu("more")
 await settle()
 await tap(find(hud.contents,"BENNOS WERKSHOF"))
 check(hud.current=="welcome" and hud.story_step==0,"An existing company can revisit the new world introduction through More")
 await tap(find(hud.contents,"WEITERSPIELEN"))
 check(game.state==existing and not hud.overlay.visible,"Revisiting the introduction never resets completed onboarding or changes company data")
 hud.open_menu("welcome")
 await settle()
 hud.story_detail.visible_characters=-1
 hud.set_process(false)
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber283-story.png")
 scene.queue_free()
 await process_frame
 print("VISUAL CAMPUS 283: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
