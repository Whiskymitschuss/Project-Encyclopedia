extends SceneTree

var checks=0
var failures=[]
var Game

func check(value: bool, message: String) -> void:
 checks+=1
 if not value: failures.append(message); printerr("FAILED: ",message)

func _initialize() -> void:
 call_deferred("run")

func fresh() -> void:
 Game.state=Game.initial_state()
 Game.state.unlocked=10
 Game.state.buildings=[]
 Game.state.workers=0
 Game.state.trucks=0
 Game.state.auto_export=false
 Game.town_route_cache.clear()
 Game.flow.clear()

func run() -> void:
 await process_frame
 Game=root.get_node("Game")
 Game.set_process(false)
 fresh()
 Game.state.homes=[{"kind":"house","level":1,"plot":0}]
 var coins=float(Game.state.coins)
 Game.simulate(10)
 check(is_equal_approx(Game.state.coins,coins),"Manual rent never also credits the wallet")
 check(is_equal_approx(Game.rent_total(),20),"A house banks its actual ten-second rent")
 check(Game.collect_rent(0)==20,"Tapping a home collects its bank")
 check(Game.collect_rent(0)==0 and Game.state.coins==coins+20,"Cannot collect the same rent twice")
 check(Game.collect_rent(5)==0,"Invalid rental index cannot change money")
 Game.simulate(28800)
 check(is_equal_approx(Game.rent_total(),57600),"Eight hours offline retains collectible rent")
 var saved=JSON.parse_string(JSON.stringify(Game.snapshot()))
 Game.restore(saved)
 check(is_equal_approx(Game.rent_total(),57600) and not Game.state.town.rent_auto,"Saved manual bank survives JSON restore")
 Game.collect_rent()
 Game.state.coins=5000
 check(Game.set_rent_auto(true),"New profile can purchase the house manager")
 check(Game.state.coins==2500 and Game.state.town.rent_manager,"Manager charges exactly once")
 Game.simulate(5)
 check(Game.state.coins==2510 and Game.rent_total()==0,"Manager credits rent directly without a second bank")
 Game.set_rent_auto(false)
 Game.set_rent_auto(true)
 check(Game.state.coins==2510,"Owned manager can be toggled without buying again")
 saved=Game.snapshot()
 saved.erase("town")
 Game.restore(saved)
 check(Game.state.town.rent_auto and Game.state.town.rent_manager,"Pre-0.13 saves retain their automatic rent for free")
 fresh()
 Game.state.coins=1000000
 var old_coins=Game.state.coins
 check(not Game.expand_district() and Game.state.coins==old_coins,"District prerequisites checked before charging")
 Game.state.region=2
 Game.state.homes=[{"kind":"apartments","level":2,"plot":0}]
 check(Game.expand_district(),"Twenty residents and all regions unlock east district")
 check(Game.city_plot_count()==24 and Game.state.coins==old_coins-35000,"East district adds twelve plots at stated price")
 check(Game.placement_reason(Catalog.home_position(12)).is_empty(),"New eastern plot is actually buildable")
 check(Game.placement_reason(Catalog.home_position(24)).is_empty(),"Western land is buildable before optional road expansion")
 Game.state.buildings.append({"kind":"prefab","level":1})
 for key in Game.state.resources: Game.state.resources[key]=1000
 check(Game.order_home("landhouse",12),"An eastern home can be paid for and constructed")
 Game.simulate(61)
 check(Game.state.homes.size()==2 and Game.home_position(1).x>=212,"New house completes in its real eastern district")
 check(Game.expand_district() and Game.city_plot_count()==36,"Second district extends to 36 available plots")
 check(not Game.expand_district(),"Two districts is a hard cap")
 fresh()
 Game.state.coins=10000
 var route=TownRules.path(Vector2i(-80,-160),Vector2i(-120,-160))
 var cost=Game.road_cost("asphalt",route)
 check(cost==280,"Road cost excludes the already built starting cell")
 check(Game.build_road("asphalt",route),"Connected road can be built")
 check(Game.state.coins==10000-cost,"Construction charges once at confirmation")
 old_coins=Game.state.coins
 check(not Game.build_road("asphalt",route) and Game.state.coins==old_coins,"Duplicate road has no charge")
 var water=TownRules.path(Vector2i(-120,-160),Vector2i(-340,-160))
 check(not Game.build_road("asphalt",water) and Game.state.coins==old_coins,"Road into water is rejected without payment")
 check(not Game.build_road("asphalt",TownRules.path(Vector2i(-120,120),Vector2i(-120,152))),"Disconnected asphalt is rejected")
 check(not Game.build_road("asphalt",TownRules.path(Vector2i(184,-160),Vector2i(220,-160))),"Disconnected district road still requires an actual network link")
 check(Game.build_road("path",TownRules.path(Vector2i(-120,120),Vector2i(-120,152))),"Independent garden path is allowed")
 Game.state.buildings.append({"kind":"sawmill","level":1,"position":[-44,-44]})
 old_coins=Game.state.coins
 check(not Game.build_road("asphalt",TownRules.path(Vector2i(-80,-60),Vector2i(-44,-44))) and Game.state.coins==old_coins,"Roads cannot cross production buildings")
 Game.state.buildings=[]
 check(Game.build_stop(Vector3(-120,0,-160)),"Bus stop attaches to a player-built road")
 check(not Game.remove_road(0),"A stop protects its road from demolition")
 check(not Game.build_stop(Vector3(-116,0,-160)),"Stops cannot overlap")
 check(not Game.build_stop(Vector3(-120,0,120)),"Walking paths cannot support a bus stop")
 check(Game.build_stop(Vector3(-80,0,-120)),"Second stop attaches to the permanent network")
 old_coins=Game.state.coins
 check(not Game.create_bus_line([1,2]) and Game.state.coins==old_coins,"Empty town cannot buy a passenger service")
 Game.state.homes=[{"kind":"house","level":1,"plot":0}]
 check(not Game.create_bus_line([1,1]),"Duplicate stop does not create a zero-length fare exploit")
 check(not Game.create_bus_line([1,999]),"Unknown stop cannot form a line")
 check(Game.create_bus_line([1,2]),"Two connected stops and residents can launch a real route")
 var plan=Game.transit_plan([1,2])
 check(not plan.is_empty() and plan.duration>8,"Route includes travel and dwell time")
 var line=Game.state.town.lines[0]
 old_coins=Game.state.coins
 Game.step(float(plan.duration)-0.01)
 check(Game.state.coins==old_coins and int(line.trips)==0,"Incomplete round trip never earns a fare")
 Game.step(0.02)
 check(Game.state.coins>old_coins and int(line.trips)==1,"A completed circuit earns the stated net fare")
 check(not Game.remove_stop(1),"Active service protects its stop")
 var standing=TownRules.bus_sample(plan,1)
 var driving=TownRules.bus_sample(plan,5)
 check(standing.waiting and not driving.waiting and standing.position!=driving.position,"Bus sample distinguishes actual stop and movement phases")
 for t in 100:
  var sample=TownRules.bus_sample(plan,plan.duration*t/100.0)
  check(TownRules.nearest(sample.position-Vector3(0,0.95,0),TownRules.road_cells(Game.state.town),2.1)!=null,"Bus route remains on the road network")
 saved=JSON.parse_string(JSON.stringify(Game.snapshot()))
 Game.restore(saved)
 check(not Game.transit_plan(Game.state.town.lines[0].stops).is_empty(),"Numeric stop IDs and route survive JSON save")
 var trips=int(Game.state.town.lines[0].trips)
 Game.simulate(float(plan.duration)*4)
 check(int(Game.state.town.lines[0].trips)==trips+4,"Offline simulation runs the same scheduled circuits")
 check(Game.remove_bus_line(0) and Game.remove_stop(1) and Game.remove_road(0),"Stopped route and stop can be removed before their road")
 # Removing a connector must preserve a line even when both stops keep their own roads.
 fresh()
 Game.state.coins=100000
 Game.state.homes=[{"kind":"house","level":1,"plot":0}]
 check(Game.build_road("asphalt",TownRules.path(Vector2i(-80,-140),Vector2i(-120,-140))),"A connected branch is constructed")
 check(Game.build_road("asphalt",TownRules.path(Vector2i(-120,-140),Vector2i(-120,-100))),"A second stretch extends that branch")
 check(Game.build_stop(Vector3(-120,0,-100)) and Game.build_stop(Vector3(-80,0,-80)),"Stops attach at both ends of the branch route")
 check(Game.create_bus_line([1,2]),"Extended player roads support a bus line")
 check(not Game.remove_road(0),"Active line also protects intermediate connector roads")
 var damaged=Game.snapshot()
 damaged.town.roads.remove_at(0)
 Game.restore(damaged)
 old_coins=Game.state.coins
 Game.simulate(120)
 check(Game.state.coins==old_coins and Game.state.town.lines[0].trips==0,"An interrupted saved route cannot invent fares")
 # Validate actual scene/UI interactions and machine tier switches.
 fresh()
 Game.state=Game.initial_state()
 Game.state.tutorial=5
 Game.state.workers=6
 Game.state.tool=10
 Game.state.coins=1000000
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene.sync_actors()
 var machine_count=0
 for actor in scene.actors.get_children():
  if actor.has_meta("forestry_tier"): machine_count+=1; check(actor.tier==10,"Mini forestry model uses saved tool tier")
 check(machine_count>0 and machine_count<=5,"Purchased machinery is visible with bounded instance count")
 Game.flow.harvest=1.0
 for actor in scene.actors.get_children():
  if actor.has_meta("forestry_tier"):
   var before=actor.boom.rotation.x
   actor._process(0.5)
   check(actor.working and actor.boom.rotation.x!=before,"Real harvest flow animates the felling arm and saw")
 Game.state.tool=14
 scene.sync_actors()
 for actor in scene.actors.get_children():
  if actor.has_meta("forestry_tier"): check(actor.tier==14 and actor.scale.x>1,"Titan upgrade replaces the small machine")
 Game.state.tool=0
 scene.sync_actors()
 machine_count=0
 for actor in scene.actors.get_children():
  if actor.has_meta("forestry_tier"): machine_count+=1
 check(machine_count==0,"Early axe tiers still use human foresters")
 for kind in Catalog.HOMES:
  var model=load("res://Buildings/Models.gd").building(kind,5,true)
  check(model.get_meta("town_kind","")==kind and model.get_meta("height",0)>0,"Distinct city model: "+kind)
  scene.add_child(model)
  var inside=true
  for mesh in model.find_children("*","MeshInstance3D",true,false):
   for corner in 8:
    var p=mesh.global_transform*mesh.get_aabb().get_endpoint(corner)
    inside=inside and absf(p.x)<=9.51 and absf(p.z)<=11.51
  check(inside,"City details remain inside their own parcel: "+kind)
  model.queue_free()
 scene.hud.open_menu("networks")
 check(scene.hud.modal_title.text=="STRASSEN & WEGE","Road construction has a direct mobile menu")
 scene.hud.open_menu("transit")
 check(scene.hud.modal_title.text=="BUS & HALTESTELLEN","Transit has a direct mobile menu")
 old_coins=Game.state.coins
 scene.begin_placement({"network":true,"kind":"asphalt"})
 scene.network_at(Vector3(-80,0,-160),true)
 scene.network_at(Vector3(-120,0,-160),true)
 check(not scene.hud.placement_confirm.disabled,"Valid two-tap road preview can be confirmed")
 check(Game.state.coins==old_coins and Game.state.town.roads.is_empty(),"Road preview is free and does not mutate the network")
 scene.cancel_placement()
 check(Game.state.coins==old_coins,"Cancelling road preview is free")
 scene.begin_placement({"network":true,"kind":"asphalt"})
 scene.network_at(Vector3(-80,0,-160),true)
 scene.network_at(Vector3(-120,0,-160),true)
 scene.placement_action("confirm")
 check(Game.state.town.roads.size()==1 and Game.state.coins<old_coins,"World confirmation builds a real saved road")
 check(scene.placement.is_empty() and not scene.hud.placement_panel.visible,"Confirmation closes the preview")
 scene.hud.close_menu()
 Game.state.homes=[{"kind":"house","level":1,"plot":0,"position":[-44,84],"rent_bank":100.0}]
 Game.state.town.stops=[]
 Game.state.town.lines=[]
 Game.state.town.next_stop=1
 check(Game.build_stop(Vector3(0,0,68)) and Game.build_stop(Vector3(80,0,68)),"Two physically clear city bus stops can be placed")
 check(Game.create_bus_line([1,2]),"A service launches through the live world")
 var actual_bus=null
 for child in scene.town_layer.get_children():
  if child.get_script()==load("res://Vehicles/Bus.gd"): actual_bus=child
 check(actual_bus!=null,"Scheduled line creates its own visible bus")
 if actual_bus!=null:
  actual_bus._process(0.1)
  check(actual_bus.waiting,"Visible bus starts at its boarding stop")
  Game.state.town.lines[0].phase=6.0
  actual_bus._process(0.1)
  check(actual_bus.moving and actual_bus.position.distance_to(Vector3(0,0,68))>10,"Bus visibly moves along the economic route")
 scene.town_layer.refresh_rents()
 var label=scene.town_layer.rent_labels[0].label
 var projected=scene.camera.unproject_position(label.global_position)
 check(scene.town_layer.tap_rent(projected) and Game.rent_total()==0,"Tapping the world coin label really collects that house's rent")
 Game.state.town.districts=1
 check(Game.move_building(1,Vector3(248,0,-112)),"A working sawmill can move into an expanded district")
 check(LogisticsRoutes.road_route(Game.state,0,1).is_empty(),"A remote parcel without an access road cannot invent a freight route")
 check(Game.build_road("asphalt",TownRules.path(Vector2i(200,-128),Vector2i(248,-128))),"The player can connect an expanded industrial parcel with a real access road")
 var expanded=LogisticsRoutes.road_route(Game.state,0,1)
 check(expanded.size()>1,"Expanded industrial district receives freight after its access road is built")
 check(scene.get("network")==null,"Expanded districts do not recreate obsolete conveyor decks")
 scene.queue_free()
 await process_frame
 print("TOWN: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
