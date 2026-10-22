extends SceneTree
var game
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func fixture() -> Dictionary:
 return JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/traffic293-gridlock.json"))
func units() -> float:
 var d=game.state.delivery
 var n=float(game.state.resources.wood)+float(game.state.resources.boards)*2+float(game.state.resources.furniture)*4+float(d.sold)*4
 for b in d.buffers.values(): n+=float(b.wood)+float(b.boards)*2+float(b.furniture)*4
 for b in d.recovered.values():
  for key in b: n+=float(b[key])*{"wood":1,"boards":2,"furniture":4}[key]
 for t in d.shipments:
  if not t.arrived: n+=float(t.amount)*{"wood":1,"boards":2,"furniture":4}[t.key]
 return n
func trip(id: int, path: Array, age: float) -> Dictionary:
 return {"id":id,"job":1,"mode":"truck","source":"warehouse","target":"construction","key":"wood","amount":2.0,"path":path,"age":age,"load":2.0,"drive":10.0,"unload":2.0,"travel":14.0,"total":26.0,"arrived":false}
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 game.set_block_signals(true)
 # This is generated test data captured from the shipped 0.29.2 APK at second
 # 120. Opposing queues never move again in that version; no player save used.
 for tier in [3,6]:
  game.restore(fixture())
  game.state.workers=0
  game.state.vehicle=tier
  var initial=units()
  var original_ids=game.state.delivery.shipments.map(func(t): return int(t.id))
  var sold=int(game.state.delivery.sold)
  var stale=0
  var longest=0
  var first_sale=-1
  for second in 600:
   game.step(1)
   if int(game.state.delivery.sold)>sold and first_sale<0: first_sale=second
   stale=stale+1 if int(game.state.delivery.sold)==sold and second>=180 else 0
   sold=int(game.state.delivery.sold)
   longest=maxi(longest,stale)
   check(absf(units()-initial)<0.00001,"Gridlock recovery conserves actual wood, boards, furniture and sales (tier %s, %s)" % [tier,second])
   check(game.state.delivery.shipments.size()<=int(game.state.trucks),"Recovery uses only the purchased fleet")
  # 0.29.4 re-dispatches old pending cargo once in depot order. Check the
  # bounded recovery separately from sustained flow after that initial queue.
  check(first_sale>=0 and first_sale<180,"Re-dispatched saved cargo reaches the shop within three simulated minutes")
  check(longest<120 and sold>10,"Saved opposing queues resume sustained sales after depot recovery, including long trailers (tier %s): sold %s, longest gap %s" % [tier,sold,longest])
  check(game.state.delivery.shipments.all(func(t): return not int(t.id) in original_ids),"Every originally blocked truck delivers and returns; no permanent hostage load")
  check(game.state.delivery.on_time>0,"Recovered production can complete real orders on time")
 # Both directions of the same road can use a green phase together.
 game.restore(game.initial_state())
 game.state.city_services.enabled=false
 var a=trip(1,[[-40,0.95,4],[40,0.95,4]],5.25)
 var b=trip(2,[[40,0.95,4],[-40,0.95,4]],5.25)
 game.state.construction_shipments=[a,b]
 TrafficRules.prepare(game.state,1)
 check(is_equal_approx(float(a.traffic_delta),1) and is_equal_approx(float(b.traffic_delta),1),"Oncoming trucks in separate lanes both advance under their shared green")
 check(TrafficRules.sample(a,6.25).position.distance_to(TrafficRules.sample(b,6.25).position)>=3,"Opposing traffic keeps its actual separate lanes")
 # A fire engine requests green but waits for existing cross traffic to clear.
 game.restore(game.initial_state())
 game.state.city_services.enabled=false
 game.state.traffic.clock=16
 var mission={"id":1,"kind":"fire","fire_id":1,"age":3.2,"drive":10.0,"work":36.0,"served_at":46.0,"total":56.0,"served":false,"reward":0.0,"source_ref":{"type":"entry","index":-1},"target_ref":{"type":"entry","index":-1},"destination_ref":{"type":"entry","index":-1},"outward":[[-40,0.95,4],[40,0.95,4]],"second":[],"back":[[40,0.95,4],[-40,0.95,4]]}
 var cell=Vector2i(0,4)
 check(TrafficRules.signal_phase(game.state,cell)=="z","The ordinary phase is red for the approaching engine")
 game.state.city_services.missions=[mission]
 check(TrafficRules.signal_phase(game.state,cell)=="x","A real assigned fire mission requests green for its approach")
 var crossing=trip(1,[[0,0.95,-36],[0,0.95,44]],7)
 game.state.construction_shipments=[crossing]
 TrafficRules.prepare(game.state,1)
 check(mission.traffic_wait=="Kreuzung räumt" and float(mission.traffic_delta)<1,"Emergency priority still waits for a truck already crossing")
 ConstructionRules.transport_tick(game.state,1)
 CityServices.tick(game.state,1,{})
 for i in 100:
  TrafficRules.prepare(game.state,1)
  ConstructionRules.transport_tick(game.state,1)
  CityServices.tick(game.state,1,{})
 check(game.state.city_services.missions.is_empty() and game.state.construction_shipments.is_empty(),"Truck and engine both complete and release their vehicle after safe crossing")
 mission.age=3.2
 game.state.city_services.missions=[mission]
 check(TrafficRules.break_signal(game.state,cell) and TrafficRules.signal_phase(game.state,cell)=="fault","An emergency does not pretend a broken signal has been repaired")
 # A restored queue and a continuous run must still use identical economics.
 game.restore(fixture())
 game.simulate(90)
 var expected=game.state.duplicate(true)
 game.restore(fixture())
 for i in 90: game.step(1)
 check(game.state==expected,"Restoring an existing gridlock preserves exact foreground/offline results")
 print("TRAFFIC FLOW 0.29.3: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
