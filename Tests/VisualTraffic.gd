extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func draw() -> void:
 for i in 6: await process_frame
 await RenderingServer.frame_post_draw
func shot(name_value: String) -> void:
 await draw()
 root.get_texture().get_image().save_png("/workspace/timber-traffic-"+name_value+".png")
func event_touch(at: Vector2, pressed: bool) -> void:
 var event=InputEventScreenTouch.new()
 event.position=root.get_screen_transform()*at
 event.index=0
 event.pressed=pressed
 Input.parse_input_event(event)
 await process_frame
func event_drag(at: Vector2, amount: Vector2) -> void:
 var event=InputEventScreenDrag.new()
 event.position=root.get_screen_transform()*at
 event.relative=root.get_screen_transform().basis_xform(amount)
 event.index=0
 Input.parse_input_event(event)
 await process_frame
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.coins=180000
 game.state.company_xp=360
 game.state.region=2
 game.state.workers=12
 game.state.trucks=3
 game.state.vehicle=6
 game.state.time=11
 game.state.weather=0
 for kind in ["furniture","prefab","garage"]:
  var p=game.free_position(Catalog.industry_position(game.state.buildings.size()))
  game.state.buildings.append({"kind":kind,"level":3,"paused":false,"position":[p.x,p.z]})
 for kind in ["police","taxi","fire","clinic","house","landhouse","shop","park","nightclub","school"]:
  var i=game.state.homes.size()
  var p=game.free_position(Catalog.home_position(i))
  game.state.homes.append({"kind":kind,"level":2,"plot":i,"position":[p.x,p.z],"rent_bank":120.0 if Catalog.HOMES[kind].rent>0 else 0.0})
 for key in game.state.resources: game.state.resources[key]=120
 check(game.start_delivery(),"Actual existing production sites form the freight line")
 game.state.delivery.buffers.station.wood=6
 game.state.delivery.buffers.sawmill.boards=6
 game.state.delivery.buffers.furniture.furniture=2
 game.step(1)
 check(game.state.delivery.shipments.size()==3,"Three different road loads share three bought trucks")
 for job in game.state.delivery.shipments: job.age=float(job.load)+float(job.drive)*0.45
 for kind in CityServices.TYPES: check(game.request_city_service(kind),"A real service assignment is dispatched: "+kind)
 for mission in game.state.city_services.missions: mission.age=float(mission.drive)*0.55
 for i in 6: CityServices.create_walk(game.state,game.city_route_cache)
 for trip in game.state.city_services.walkers: trip.age=float(trip.total)*0.4
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.focus=Vector3(0,0,105)
 scene.zoom=113
 scene.set_camera()
 await draw()
 check(scene.city_traffic.vehicles.size()==4,"Every service type has a visible vehicle with its own model")
 check(scene.city_traffic.people.size()>=6,"Real resident trips create rendered pedestrians")
 for car in scene.city_traffic.vehicles.values():
  check(car.wheels.size()==4 and car.passenger!=null,"Service cars have wheels and a dedicated passenger model")
 for node in scene.delivery_world.visuals.values():
  check(node.trailer!=null and node.trailer.name=="Lowbed","Tier six uses a rendered articulated lowbed")
  check(node.cargo.visible and node.cargo.get_parent()==node.trailer,"Actual freight is attached to its trailer")
 await shot("city")
 var taxi=null
 for mission in game.state.city_services.missions:
  if mission.kind=="taxi": taxi=mission
 taxi.age=float(taxi.drive)+float(taxi.work)+float(taxi.second_drive)*0.4
 await draw()
 check(scene.city_traffic.vehicles[int(taxi.id)].passenger.visible,"Taxi passenger becomes visible only after actual boarding")
 scene.hud.open_menu("services")
 await shot("services")
 check(scene.hud.modal_title.text=="EINSATZZENTRALE & STADTLEBEN" and scene.hud.overlay.is_visible_in_tree(),"Service dispatch and income UI actually render")
 scene.hud.close_menu()
 scene.focus=Vector3(-20,0,-25)
 scene.zoom=99
 scene.set_camera()
 await shot("freight")
 var before=root.get_texture().get_image().get_data()
 for job in game.state.delivery.shipments: job.age=float(job.load)+float(job.drive)*0.75
 await draw()
 check(before!=root.get_texture().get_image().get_data(),"Changing actual shipment progress changes the rendered traffic scene")
 for size_value in [Vector2i(540,960),Vector2i(360,640)]:
  root.size=size_value
  scene.hud.build_category="Stadt"
  scene.hud.open_menu("catalog")
  await draw()
  var scroll=scene.hud.scroll
  var rect=scroll.get_global_rect()
  var start=Vector2(rect.get_center().x,rect.end.y-40)
  var coins=game.state.coins
  await event_touch(start,true)
  for i in range(1,7): await event_drag(start-Vector2(0,25*i),Vector2(0,-25))
  await event_touch(start-Vector2(0,150),false)
  check(scroll.scroll_vertical>90,"Physical touch events scroll content on portrait window "+str(size_value))
  check(game.state.coins==coins and scene.placement.is_empty(),"A real swipe cannot buy or place anything")
  check(not scroll.get_v_scroll_bar().visible,"No narrow scrollbar is required")
  if size_value.x==540: await shot("build")
 scene.queue_free()
 await process_frame
 print("VISUAL TRAFFIC: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
