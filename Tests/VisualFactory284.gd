extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func settle() -> void:
 for frame in 6: await process_frame
 await RenderingServer.frame_post_draw
func bounds(node: Node3D,relative: Node3D) -> AABB:
 var result=AABB()
 var started=false
 for mesh in node.find_children("*","MeshInstance3D",true,false):
  var box=relative.global_transform.affine_inverse()*mesh.global_transform*mesh.get_aabb()
  result=result.merge(box) if started else box
  started=true
 for batch in node.find_children("*","MultiMeshInstance3D",true,false):
  var box=relative.global_transform.affine_inverse()*batch.global_transform*batch.get_aabb()
  result=result.merge(box) if started else box
  started=true
 return result
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.city_services.enabled=false
 game.state.companion_enabled=false
 game.state.workers=0
 game.state.resources.boards=3024
 game.state.buildings.append({"kind":"central_depot","level":2,"position":[44,20]})
 var center=game.state.buildings.size()-1
 game.state.buildings.append({"kind":"express","level":1,"position":[-44,116]})
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.size=Vector2i(540,960)
 root.content_scale_size=root.size
 root.add_child(scene)
 scene.set_process(false)
 scene.hud.ux.set_process(false)
 await settle()
 var depot=scene.world_buildings.get_child(center)
 check(depot.get_node("FactoryFloor").visible==false,"The central yard shares one visible floor with the campus")
 var planted_on_floor=scene.landscape.records.filter(func(record): return load("res://Components/ProductionCampus.gd").YARD.has_point(record.point) and not record.blocked)
 check(planted_on_floor.is_empty(),"No decorative flowers, grass or rocks grow through the shared factory concrete")
 check(depot.get_node_or_null("DepotHandler0")!=null and depot.get_node_or_null("DepotHandler1")!=null,"The larger loading hall contains two independently animated forklift operators")
 var rack=depot.get_node("DepotStock")
 rack.set_process(false)
 rack._process(0.5)
 check(rack.stacks[1].node.visible and not rack.stacks[0].node.visible,"Rack pallets reflect actual central boards; empty wood storage stays empty")
 for tier in [2,3,4,6,9]:
  var truck=load("res://Vehicles/Truck.gd").new()
  truck.road_freight=true
  truck.tier=tier
  truck.fleet="central"
  scene.add_child(truck)
  truck.set_process(false)
  var extent=bounds(truck,truck)
  check(extent.size.x<2.5 and extent.size.z<6.6,"Carrier tier %s fits its 3 m lane and short loading bay" % tier)
  check(truck.get_node_or_null("Driver")!=null,"Carrier tier %s has an actual seated driver" % tier)
  if tier>=4: check(truck.cargo.get_parent()==truck.trailer,"Articulated cargo retains its real trailer parent")
  truck.queue_free()
 var route=LogisticsRoutes.road_route(game.state,1,center)
 var trip={"id":881,"source":"sawmill","origin":1,"destination":center,"target":"central","fleet":"central","mode":"truck","key":"boards","amount":6,"path":route,"age":0.8,"load":2.0,"drive":5.0,"unload":2.0,"travel":9.0,"total":16.0,"arrived":false}
 game.state.hub.shipments=[trip]
 scene.delivery_world._process(0.1)
 var visual=scene.delivery_world.visuals["central:881"]
 check(visual.fleet=="central" and visual.visible,"The real depot trip uses its distinct white-blue road model")
 check(not visual.get_node("RouteLabel").visible,"Loading text cannot expand across the world view")
 var before=game.state.duplicate(true)
 var rest=visual.cargo.get_meta("rest_position")
 CargoTransfer.apply(game,visual,trip,1)
 check(visual.cargo.position.distance_to(rest)<0.21,"Loading cargo stays on its truck instead of crossing a machine or canopy")
 check(game.state==before,"Cargo presentation never changes inventory or shipment state")
 trip.age=8
 scene.delivery_world._process(0.1)
 var handler=depot.get_node("DepotHandler0")
 handler.set_process(false)
 var parked=handler.position
 handler._process(1)
 check(handler.active and handler.position!=parked,"An actual central unloading phase starts the depot forklift")
 trip.arrived=true
 for tick in 40: handler._process(0.25)
 check(not handler.cycle_running and handler.position==handler.points[0] and not handler.payload.visible,"After unloading the forklift completes its empty return and parks")
 game.state.resources.boards=3024
 scene.hud.update_stats()
 await settle()
 check(scene.hud.material_bar.counters.boards.text=="3024","Four-digit material stock stays exact and readable")
 for resolution in [Vector2i(360,640),Vector2i(540,960),Vector2i(1100,700)]:
  root.size=resolution
  root.content_scale_size=resolution
  await settle()
  scene.hud.update_stats()
  await settle()
  check(scene.hud.material_bar.columns==3,"Readable two-row material bar at "+str(resolution))
  for control in scene.hud.material_bar.controls.values():
   check(control.size.x>=44 and control.size.y>=44,"Material button remains a real finger target at "+str(resolution))
 root.size=Vector2i(540,960)
 root.content_scale_size=root.size
 scene.focus=Vector3(20,0,-10)
 scene.zoom=115
 scene.set_camera()
 scene.hud.update_stats()
 trip.arrived=false
 trip.age=4
 scene.delivery_world._process(0.1)
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber284-factory.png")
 scene.focus=Vector3(44,0,20)
 scene.zoom=80
 scene.set_camera()
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber284-central.png")
 scene.queue_free()
 await process_frame
 print("VISUAL FACTORY 284: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
