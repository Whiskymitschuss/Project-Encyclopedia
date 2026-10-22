extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func equivalent(a: Variant,b: Variant) -> bool:
 if (a is int or a is float) and (b is int or b is float): return absf(float(a)-float(b))<0.00000001
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
func position(trip: Dictionary) -> Variant:
 if float(trip.get("depart_in",0))>0: return null
 var age=float(trip.age)
 var returning=age>=float(trip.travel)
 var progress=(age-float(trip.travel))/float(trip.drive) if returning else (age-float(trip.load))/float(trip.drive)
 if progress<=0.05 or progress>=0.95: return null
 var sample=LogisticsRoutes.sample(trip.path,1-progress if returning else progress)
 var direction: Vector3=-sample.direction if returning else sample.direction
 return sample.position+Vector3(direction.z,0,-direction.x)*1.5
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 var store=root.get_node("Store")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.city_services.enabled=false
 game.state.workers=0
 game.state.buildings.append({"kind":"furniture","level":1,"paused":false})
 check(game.start_delivery(),"Real delivery line starts")
 game.state.delivery.buffers.station.wood=4
 game.step(1)
 check(game.state.delivery.shipments.size()==1,"An actual four-log truck is dispatched")
 var order=game.state.delivery.order.duplicate(true)
 game.state.delivery.paused=true
 game.state.buildings[1].paused=true
 game.simulate(120)
 check(game.state.delivery.shipments.is_empty(),"Pausing a selected factory cannot strand an already dispatched truck")
 check(game.state.delivery.buffers.sawmill.wood==4,"The real cargo arrives exactly once while production stays paused")
 check(game.state.delivery.order==order and game.state.delivery.buffers.sawmill.boards==0,"Pause still protects the order clock and production")

 # Exercise following, crossing and opposite-direction reservations together.
 var state=game.initial_state()
 var routes=[[[0,0.95,-40],[0,0.95,40]],[[0,0.95,40],[0,0.95,-40]],[[-40,0.95,0],[40,0.95,0]],[[40,0.95,0],[-40,0.95,0]]]
 for i in 16:
  FreightFlow.enqueue(state,state.delivery.shipments,{"id":i,"target":"sawmill","source":"station","mode":"truck","key":"wood","amount":4,"path":routes[i%4],"load":1.0,"drive":10.0,"travel":12.0,"total":23.0,"age":0.0,"arrived":false})
 check(state.delivery.shipments[2].depart_in>0,"Crossing/following departures really wait at the depot")
 var restored=JSON.parse_string(JSON.stringify(state,"",true,true))
 var collisions=0
 for step in 1200:
  var on_road=[]
  for trip in state.delivery.shipments:
   FreightFlow.advance(trip,0.25)
   var at=position(trip)
   if at!=null:
    for previous in on_road:
     if at.distance_to(previous)<2.8: collisions+=1
    on_road.append(at)
  for trip in restored.delivery.shipments: FreightFlow.advance(trip,0.25)
  state.delivery.shipments=state.delivery.shipments.filter(func(trip): return trip.age<trip.total)
  restored.delivery.shipments=restored.delivery.shipments.filter(func(trip): return trip.age<trip.total)
 check(collisions==0,"Sixteen crossing, following and opposing road trucks retain physical separation: "+str(collisions))
 check(state.delivery.shipments.is_empty(),"All reserved trips and returns finish; there is no mutual-wait deadlock")
 check(equivalent(state,restored),"Saved depot queues continue identically after JSON restoration")

 game.state=game.initial_state()
 game.state.resources.wood=6
 game.track_materials()
 game.state.resources.wood=4
 game.state.construction_shipments=[{"key":"wood","amount":2,"arrived":false}]
 game.state.elapsed=10
 game.track_materials()
 check(game.material_trend("wood").ready and game.material_trend("wood").rate==0,"Moving stock into a truck does not fake a falling material trend")
 game.state.resources.wood=3
 game.state.elapsed=20
 game.track_materials()
 check(game.material_trend("wood").rate<0,"Actual stock consumption produces a falling trend")
 game.state.resources.wood=10
 game.state.jobs=[{"materials":{"wood":6},"delivered":{}}]
 var bill=UXRules.build_quote(game.state,"wood",8)
 check(bill.available==6 and bill.missing==2,"Build quote protects other sites and does not count their cargo twice")

 game.state=game.initial_state()
 game.state.homes=[{"kind":"house","level":3,"plot":0,"rent_bank":42,"position":[-40,116]}]
 game.state.city_services.enabled=false
 check(game.move_building(0,Vector3(-40,0,148),90,true),"Home move records a real reversible operation")
 game.restore(JSON.parse_string(JSON.stringify(game.snapshot())))
 check(game.undo_building_move(),"The last house move can be undone even after save/reload")
 check(game.home_position(0)==Vector3(-40,0,116) and game.state.homes[0].rent_bank==42 and game.state.homes[0].level==3,"Undo preserves home level and earned rent")
 check(not game.undo_building_move(),"An already undone move cannot repeat")

 game.state=game.initial_state()
 game.state.city_services.enabled=false
 game.state.resources.wood=20
 var initial=game.snapshot()
 game.restore(initial)
 game.simulate(120)
 var expected=game.state.duplicate(true)
 expected.last_seen=initial.last_seen
 game.restore(initial)
 check(game.save(true),"A valid company is saved before asynchronous replay")
 var old_hash=FileAccess.get_sha256(store.PATH)
 game.start_replay(120,Journey.resume_capture(game.state))
 check(game.catching_up and paused and not game.save(true),"Replay isolates its copy and blocks partial saves")
 check(FileAccess.get_sha256(store.PATH)==old_hash and game.state.elapsed==initial.elapsed,"The actual save and live company remain untouched while the worker runs")
 var deadline=Time.get_ticks_msec()+10000
 while game.catching_up and Time.get_ticks_msec()<deadline:
  game.poll_replay()
  await process_frame
 check(not game.catching_up and not paused,"Asynchronous replay completes and restores the scene tree")
 check(equivalent(game.state,expected),"The worker produces exactly the synchronous simulation result")
 var canceled=load("res://Managers/CompanyReplay.gd").new()
 canceled.start(game.get_script(),game.state,28800)
 canceled.cancel()
 check(store.valid_shape(store.load_game()),"Canceling a worker never replaces the committed save with a partial company")
 print("FOREST 282: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
