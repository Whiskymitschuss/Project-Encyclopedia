extends SceneTree
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 var stats=root.get_node("RuntimeStats");stats.set_process(false)
 var profiles=load("res://Components/GraphicsProfiles.gd")
 check(profiles.PROFILES.size()==4,"Four explicit graphics profiles are available")
 for i in 4:
  var p=profiles.profile(i)
  check(p.fps==(30 if i<2 else 60),"Profile %s has the requested frame target" % p.name)
 check(profiles.effective(3,3,true)==0 and profiles.effective(3,3,false)==3,"Measured overload can relieve Ultra; manual opt-out is respected")
 check(profiles.recommendation(0,0,0,{}).contains("genügend"),"No device recommendation is fabricated without measured frames")
 check(profiles.recommendation(180,4.7,395,{}).contains("Sparmodus"),"Actual slow frames produce a conservative profile recommendation")
 check(profiles.recommendation(180,30,34,{"gpu_ms":7,"cpu_ms":3}).contains("Hoch"),"An optional positive GPU measurement can suggest a higher profile")
 var partitions=[]
 for hz in [5,25,50]:
  var simulator=game.get_script().new();simulator.simulation_only=true;simulator.set_block_signals(true)
  simulator.restore(game.initial_state());simulator.state.last_seen=0
  simulator.state.tutorial=5;simulator.state.onboarding.active=false
  simulator.state.city_services.enabled=false;simulator.state.companion_enabled=false
  for frame in hz*60:simulator._process_measured(1.0/hz)
  partitions.append(simulator.state.duplicate(true));simulator.free()
 check(float(partitions[0].gathered)>0,"Frame-rate comparison runs real autonomous wood production, not an idle company")
 check(partitions[0]==partitions[1] and partitions[1]==partitions[2],"Five, 25 and 50 presentation FPS produce the same complete 60-second economy")
 var vehicles=load("res://Components/VehicleBlueprints.gd")
 var orphan_before=Node.get_orphan_node_ids().size()
 for fleet in ["general","central","construction"]:
  for tier in [2,4,6,9]:
   for dump in [false,true]:
    var truck=vehicles.truck(tier,fleet,dump)
    truck.tier=tier;truck.fleet=fleet;truck.road_freight=true;truck.cargo_boards=not dump
    root.add_child(truck)
    check(not truck.prepared_nodes.is_empty() and truck.cargo!=null and not truck.wheels.is_empty(),"Prepared %s tier %s %s binds its real cargo and wheels" % ["dump" if dump else "truck",tier,fleet])
    if not dump:check(truck.cargo==truck.get_node(truck.prepared_nodes.cargos.boards),"The loaded truck selects the correct board pallet, not another hidden SKU")
    truck.free()
 var van=vehicles.crew_van();root.add_child(van)
 check(not van.prepared_nodes.is_empty() and van.passengers.size()==4 and van.door!=null,"The prepared crew van retains beaver passengers and its sliding door")
 van.free()
 for i in 3:await process_frame
 check(Node.get_orphan_node_ids().size()==orphan_before,"Prepared nested drivers leave no orphan nodes after vehicle destruction")
 game.state=game.initial_state();var s=game.state
 s.tutorial=5;s.onboarding.active=false;s.companion_enabled=false;s.city_services.enabled=false;s.ux.adaptive_detail=false
 s.buildings.append({"kind":"kiln","level":4,"position":[44,20]})
 var initial=s.duplicate(true)
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene;scene.set_process(false)
 var cached=scene.world_buildings.get_child(1)
 var roads=scene.base_streets.get_children().map(func(node):return node.get_instance_id())
 var created=scene.visual_cache.created
 for i in 12:scene.rebuild()
 check(scene.world_buildings.get_child(1)==cached and scene.visual_cache.created==created,"Repeated nonstructural updates retain factory instances and generate no geometry")
 check(scene.base_streets.get_children().map(func(node):return node.get_instance_id())==roads,"Unchanged lots do not regenerate roads or sidewalks")
 var retained=scene.world_buildings.get_child(0)
 s.buildings[1].level=2;scene.rebuild()
 check(scene.world_buildings.get_child(1)!=cached and scene.world_buildings.get_child(0)==retained,"An upgrade replaces only its own factory model")
 check(scene.base_streets.get_children().map(func(node):return node.get_instance_id())==roads,"An upgrade inside the reserved lot leaves the road mesh intact")
 var kiln=scene.world_buildings.get_child(5).get_node("Processing")
 check(kiln.kind=="kiln" and kiln.input_key=="boards" and kiln.output_key=="dry","Prebuilt scenes retain the serialized machine recipe, not default sawmill settings")
 scene.focus=Vector3(340,0,250);scene.zoom=65;scene.set_camera();scene.chunks.update_view(true)
 check(scene.chunks.sleeping_models>0,"Off-camera cells suspend rendering and animation of real building models")
 var before=s.duplicate(true)
 var expected=game.get_script().new();expected.simulation_only=true;expected.set_block_signals(true);expected.restore(before)
 expected.rng.seed=817;game.rng.seed=817
 expected.simulate(120);game.simulate(120)
 check(game.state==expected.state,"The same complete company evolves identically with off-camera cells asleep")
 expected.free()
 scene.focus=game.building_position(1);scene.zoom=65;scene.set_camera();scene.chunks.update_view(true)
 var mill=scene.world_buildings.get_child(1)
 check(mill.visible and mill.process_mode!=Node.PROCESS_MODE_DISABLED,"Camera return wakes the same factory and its animation controllers")
 check(mill.has_node("Processing") and mill.has_node("YardHandling"),"Machine and beaver-operated forklift attachment nodes remain intact")
 scene.chunks.restore_all()
 var last=s.duplicate(true)
 var count=scene.find_children("*","Node",true,false).size()
 for i in 10:scene.rebuild()
 for i in 3:await process_frame
 check(scene.find_children("*","Node",true,false).size()<=count+100,"Repeated rebuild checks do not accumulate duplicate models or orphaned UI")
 check(s==last,"Rendering, cache reuse and visibility changes do not mutate company state")
 scene.queue_free();await process_frame
 # Exercise the real staged startup instead of only an isolated loader.
 game.restore(initial);game.state.ux.adaptive_detail=false;game.rng.seed=917
 game.staged_world_requested=true
 var staged=load("res://Scenes/Main.tscn").instantiate();root.add_child(staged);current_scene=staged
 var waiting=game.state.duplicate(true)
 var tap=InputEventMouseButton.new();tap.button_index=MOUSE_BUTTON_LEFT;tap.pressed=false;tap.position=Vector2(100,200)
 staged._unhandled_input(tap)
 check(staged.initializing_world and game.state==waiting,"World input stays blocked while asynchronous resources and camera are still being prepared")
 var began=Time.get_ticks_usec()
 var stage_deadline=Time.get_ticks_msec()+10000
 while not staged.is_processing() and Time.get_ticks_msec()<stage_deadline:
  await process_frame
 check(staged.is_processing() and game.live_world,"Staged resource loading completes and releases the actual playable main world")
 check(stats.startup_sections.has("Arbeiter") and staged.actors.get_child_count()>0,"Worker construction occurs before releasing the loading cover")
 var passed=(Time.get_ticks_usec()-began)/1000000.0
 check(float(game.state.elapsed)<=passed+1.0,"Staged loading accounts for elapsed production time at most once")
 staged.queue_free()
 for i in 4:await process_frame
 check(Node.get_orphan_node_ids().size()==orphan_before,"Repeated staged/main-world load and teardown leave no orphan nodes")
 print("PERFORMANCE 2826: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
