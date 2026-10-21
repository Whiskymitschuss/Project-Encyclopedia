extends SceneTree
var game
var checks=0
var failures=[]
func equivalent(a: Variant, b: Variant) -> bool:
 if (a is float or a is int) and (b is float or b is int): return absf(float(a)-float(b))<0.00000001
 if a is Dictionary and b is Dictionary:
  if a.size()!=b.size(): return false
  for key in a:
   if not b.has(key) or not equivalent(a[key],b[key]): return false
  return true
 if a is Array and b is Array:
  if a.size()!=b.size(): return false
  for i in a.size():
   if not equivalent(a[i],b[i]): return false
  return true
 return a==b
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func fresh() -> void:
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.workers=0
 game.tick_clock=0
 game.city_route_cache.clear()
func touch(position: Vector2, pressed: bool) -> void:
 var event=InputEventScreenTouch.new()
 event.index=0
 event.position=position
 event.pressed=pressed
 root.push_input(event,true)
 await process_frame
func drag(position: Vector2, relative: Vector2) -> void:
 var event=InputEventScreenDrag.new()
 event.index=0
 event.position=position
 event.relative=relative
 root.push_input(event,true)
 await process_frame
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 fresh()
 for kind in CityServices.TYPES:
  check(game.request_city_service(kind),"A municipal vehicle can serve a real early company: "+kind)
 check(game.state.city_services.missions.size()==4,"Four actual municipal jobs exist")
 for job in game.state.city_services.missions:
  var cells=TownRules.road_cells(game.state.town)
  for path in [job.outward,job.second,job.back]:
   for i in range(1,path.size()-1): check(cells.has(Vector2i(path[i][0],path[i][2])),"Service route uses the drivable road graph")
  check(CityServices.sample(job).lights==(job.kind!="taxi"),"Emergency beacons are tied to a real service trip")
 check(not game.request_city_service("police"),"One external police vehicle cannot accept two simultaneous assignments")
 var coins=game.state.coins
 game.step(1)
 check(game.state.city_services.treasury==0,"Dispatch alone never pays municipal income")
 var saved=JSON.parse_string(JSON.stringify(game.snapshot(),"",true,true))
 game.simulate(180)
 var online=game.state.duplicate(true)
 game.restore(saved)
 var target=game.state.city_services.missions[0].target_ref
 check(CityServices.uses_building(game.state,int(target.index),target.type=="home"),"JSON-loaded service missions still protect their actual destination from moving")
 game.simulate(180)
 game.state.last_seen=online.last_seen
 check(equivalent(game.state,online),"Municipal routes, pedestrians and income have identical foreground/offline progress")
 check(game.state.city_services.treasury>0 and game.state.coins==coins,"Finished municipal jobs accumulate real collectible income without stealing normal coins")
 check(game.state.city_services.completed.get("taxi",0)>0 and game.state.city_services.completed.get("ambulance",0)>0,"Taxis and emergency services complete their actual travel and work")
 var amount=game.state.city_services.treasury
 check(game.collect_city_income()==amount and game.state.coins==coins+amount,"City treasury can be collected exactly once")
 check(game.collect_city_income()==0,"Repeated collection cannot duplicate fares")
 game.state.city_services.enabled=false
 game.simulate(300)
 check(game.state.city_services.missions.is_empty() and game.state.city_services.walkers.is_empty(),"Disabling new trips drains the active traffic cleanly")
 fresh()
 game.state.homes=[{"kind":"police","level":6,"plot":0},{"kind":"taxi","level":1,"plot":1},{"kind":"house","level":1,"plot":2},{"kind":"park","level":1,"plot":3}]
 check(game.request_city_service("police") and game.request_city_service("police"),"A built upgraded police station supports additional actual vehicles")
 check(not game.state.city_services.missions[0].external and int(game.state.city_services.missions[0].source_ref.index)==0,"Owned service vehicles depart from their actual saved station")
 check(game.request_city_service("taxi"),"A taxi station can dispatch to a real resident")
 var taxi=game.state.city_services.missions[-1]
 taxi.age=float(taxi.drive)+float(taxi.work)+1
 check(CityServices.sample(taxi).passenger,"Taxi has an actual boarded-passenger state between pickup and destination")
 taxi.age=float(taxi.served_at)+1
 check(not CityServices.sample(taxi).passenger,"Passenger is absent after the destination is reached")
 check(CityServices.create_walk(game.state,game.city_route_cache),"Residents get walkable trips between actual places")
 var legacy=game.snapshot()
 legacy.erase("city_services")
 game.restore(legacy)
 check(game.state.city_services.enabled and game.state.city_services.missions.is_empty(),"Old saves gain an empty service ledger without changing their city")
 fresh()
 game.state.homes=[{"kind":"house","level":1,"plot":0}]
 check(CityServices.create_walk(game.state,game.city_route_cache),"An actual resident leaves their home on a walk")
 check(game.move_building(0,Vector3(-40,0,116),0,true) and game.state.city_services.walkers.is_empty() and game.state.city_services.treasury==0,"Moving a home safely cancels its walk without awarding a fare or blocking placement")
 fresh()
 game.state.coins=10000
 game.state.homes=[{"kind":"house","level":1,"plot":0,"position":[-116,-120]}]
 game.state.unlocked=2
 check(game.build_road("asphalt",TownRules.path(Vector2i(-80,-140),Vector2i(-116,-140))),"A real access road connects the resident to town")
 check(game.request_city_service("police"),"Municipal service uses the new access road")
 check(not game.remove_road(0),"A road used by an active service trip cannot disappear under its vehicle")
 game.state.city_services.enabled=false
 game.simulate(300)
 check(game.remove_road(0),"The road can be removed once the service vehicle and pedestrians return")
 fresh()
 game.state.buildings.append({"kind":"furniture","level":1,"paused":false,"position":[-20,-12]})
 game.start_delivery()
 game.state.delivery.buffers.station.wood=6
 var old=game.snapshot()
 old.delivery.shipments=[{"id":100,"mode":"belt","source":"station","target":"sawmill","key":"wood","amount":4.0,"arrived":false},{"id":101,"mode":"belt","source":"sawmill","target":"furniture","key":"boards","amount":1.0,"arrived":true}]
 old.delivery.buffers.furniture.boards=1
 old.delivery.erase("recovered")
 game.restore(old)
 check(game.state.delivery.shipments.is_empty(),"Saved conveyor parcels become recovered freight, not invisible elevated trucks")
 check(game.state.delivery.recovered.station.wood==4 and game.state.delivery.buffers.station.wood==6,"Full source buffers keep overflow migration cargo without losing or duplicating stock")
 check(game.state.delivery.buffers.furniture.boards==1,"Previously arrived belt loads are not credited twice")
 check(game.stop_delivery() and game.state.resources.wood==10,"Dissolving a migrated line returns every queued and stored unit")
 fresh()
 game.state.buildings.append({"kind":"furniture","level":1,"paused":false,"position":[-20,-12]})
 game.state.resources.wood=80
 game.start_delivery()
 for second in 480:
  game.step(1)
  var count=game.state.construction_shipments.size()
  for job in game.state.delivery.shipments:
   check(job.mode=="truck" and job.path.size()>1,"Every chain leg is actual road freight")
   count+=1
  check(count<=int(game.state.trucks),"All three links share the purchased fleet without free trucks")
 check(game.state.delivery.sold>0,"A single starter vehicle can service all three legs without starving downstream production")
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 for i in 3: await process_frame
 check(scene.get("network")==null,"No removed conveyor network is recreated by a world rebuild")
 game.state.trucks=3
 game.state.delivery.buffers.furniture.furniture=2
 game.step(1)
 for tier in [2,3,4,6,9]:
  game.state.vehicle=tier
  scene.delivery_world._process(0.1)
  for truck in scene.delivery_world.visuals.values():
   check(truck.tier==tier,"A transport upgrade changes the real active vehicle model")
   if tier>=4: check(truck.trailer!=null and truck.cargo.get_parent()==truck.trailer,"Trailer and lowbed carry the actual cargo on an articulated platform")
 for kind in CityServices.TYPES: game.request_city_service(kind)
 for i in 2: await process_frame
 scene.city_traffic._process(0.1)
 check(scene.city_traffic.vehicles.size()>0,"Real municipal jobs create visible service vehicles")
 check(scene.city_traffic.people.size()>0,"Actual walks and taxi pickups create city NPCs")
 var hud=scene.hud
 hud.open_menu("services")
 await process_frame
 check(hud.modal_title.text=="EINSATZZENTRALE & STADTLEBEN","Municipal services have a direct functioning mobile menu")
 hud.build_category="Stadt"
 hud.open_menu("catalog")
 for i in 3: await process_frame
 var scroll=hud.scroll
 check(not scroll.get_v_scroll_bar().visible,"Build menu does not depend on grabbing a narrow scrollbar")
 var old_focus=scene.focus
 var old_coins=game.state.coins
 var rect=scroll.get_global_rect()
 var start=Vector2(rect.get_center().x,rect.end.y-30)
 await touch(start,true)
 for i in range(1,6): await drag(start-Vector2(0,i*25),Vector2(0,-25))
 await touch(start-Vector2(0,125),false)
 check(scroll.scroll_vertical>80,"A finger swipe directly over catalogue content actually scrolls")
 check(game.state.coins==old_coins and scene.placement.is_empty(),"Swiping over build buttons cannot purchase or place a building")
 check(scene.focus==old_focus,"The world camera stays still behind the scrolling menu")
 scroll.velocity=0
 scroll.scroll_vertical=0
 await process_frame
 var button=null
 for control in hud.contents.get_children():
  if control is Button and "BAUSTELLEN" in control.text: button=control; break
 check(button!=null,"A real tap target exists inside the scroll container")
 await touch(button.get_global_rect().get_center(),true)
 await touch(button.get_global_rect().get_center(),false)
 check(hud.current=="construction","A short finger tap still activates the intended button exactly once")
 # A canceled OS touch never executes a catalogue action.
 hud.open_menu("catalog")
 for i in 3: await process_frame
 button=hud.contents.get_child(0)
 await touch(button.get_global_rect().get_center(),true)
 var canceled=InputEventScreenTouch.new()
 canceled.index=0
 canceled.position=button.get_global_rect().get_center()
 canceled.canceled=true
 root.push_input(canceled,true)
 await process_frame
 check(hud.current=="catalog","An interrupted OS gesture never activates a purchase or navigation")
 scene.queue_free()
 await process_frame
 print("TRAFFIC & TOUCH: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
