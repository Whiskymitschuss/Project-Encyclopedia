extends SceneTree
var game
var checks=0
var failures=[]
var bills=[]
const WEIGHTS={"wood":1.0,"boards":2.0,"furniture":4.0}
func _initialize() -> void: call_deferred("run")
func check(ok: bool, why: String) -> void:
 checks+=1
 if not ok: failures.append(why); printerr("FAILED: ",why)
func freight(s: Dictionary) -> Array:
 return s.construction_shipments+s.delivery.shipments+s.stone.shipments+s.trade.shipments
func cargo(s: Dictionary) -> Dictionary:
 var result={}
 for t in freight(s): result[("c" if t.target=="construction" else "d")+str(int(t.id))]=[t.key,t.amount,t.arrived]
 return result
func units(s: Dictionary, jobs: Array) -> float:
 var n=float(s.delivery.sold)*4
 for key in WEIGHTS: n+=float(s.resources[key])*WEIGHTS[key]
 for b in s.delivery.buffers.values():
  for key in WEIGHTS: n+=float(b[key])*WEIGHTS[key]
 for b in s.delivery.recovered.values():
  for key in b: n+=float(b[key])*WEIGHTS.get(key,0)
 for t in freight(s):
  if not t.arrived: n+=float(t.amount)*WEIGHTS.get(t.key,0)
 for job in jobs:
  for key in job.delivered: n+=float(job.delivered[key])*WEIGHTS.get(key,0)
 return n
func source(t: Dictionary) -> int:
 return int(t.origin) if t.has("origin") else int(game.state.delivery.nodes[t.source])
func run() -> void:
 await process_frame
 game=root.get_node("Game");game.set_process(false);game.set_block_signals(true)
 for name in ["yard","junction"]:
  var old=JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/traffic294-"+name+".json"))
  var expected_cargo=cargo(old)
  var total=units(old,old.jobs)
  game.restore(old)
  bills=game.state.jobs.duplicate()
  check(cargo(game.state)==expected_cargo and is_equal_approx(units(game.state,bills),total),"Old "+name+" queue is rescheduled without crediting, deleting or duplicating any cargo")
  check(int(game.state.traffic.get("dock_revision",0))==1,"Migration is explicitly versioned and runs once")
  var once=game.snapshot()
  game.restore(once)
  bills=game.state.jobs.duplicate()
  check(cargo(game.state)==expected_cargo and game.state.delivery.shipments==once.delivery.shipments,"A second restore does not restart the transport plan again")
  game.state.workers=0
  game.state.city_services.enabled=false
  game.state.auto_export=false
  for i in game.state.buildings.size():
   if not DeliveryChain.owns(game.state,i): game.state.buildings[i].paused=true
  var ids=freight(game.state).map(func(t): return ("c" if t.target=="construction" else "d")+str(int(t.id)))
  var sold=int(game.state.delivery.sold)
  var jobs=game.state.jobs.size()
  var bounded=true
  var exclusive=true
  var stalled=0
  var longest=0
  var last_sold=sold
  for second in 1200:
   game.step(1)
   check(absf(units(game.state,bills)-total)<0.00001,"Material remains accounted for across reserves, yards, trucks, construction and sales: "+name+" / "+str(second))
   bounded=bounded and freight(game.state).size()<=int(game.state.trucks)
   var active={}
   for t in freight(game.state):
    if float(t.age)<=0.001: continue
    var origin=source(t)
    active[origin]=int(active.get(origin,0))+1
   if second>180:
    for count in active.values(): exclusive=exclusive and count<=1
   if int(game.state.delivery.sold)>last_sold: stalled=0;last_sold=int(game.state.delivery.sold)
   else: stalled+=1
   longest=maxi(longest,stalled)
  check(bounded,"Actual purchased fleet bounds both running and queued loads")
  check(exclusive,"Each yard has one circulating freight truck after old returns clear")
  check(freight(game.state).all(func(t): return not (("c" if t.target=="construction" else "d")+str(int(t.id))) in ids),"Every original cargo trip finishes and returns: "+name)
  check(int(game.state.delivery.sold)>sold+3 and longest<300,"Orders keep receiving actual furniture while multiple sites share the road: "+name)
  check(game.state.jobs.size()<jobs,"Construction also advances instead of permanently yielding to the shop")
  check(game.state.city_services.missions.is_empty() and game.state.city_services.fires.is_empty(),"Previously assigned municipal and fire missions complete")
  print("RECOVERED ",name," sold_delta=",int(game.state.delivery.sold)-sold," completed_sites=",jobs-game.state.jobs.size()," longest_sale_gap=",longest)
 # The unloading manoeuvre changes heading and bay continuously, with no jump
 # at the boundary between delivery and the empty return.
 var t={"path":[[-40,0.95,4],[40,0.95,4]],"load":2.0,"drive":10.0,"travel":14.0,"total":26.0}
 var before=TrafficRules.sample(t,13.9999)
 var after=TrafficRules.sample(t,14.0001)
 check(before.position.distance_to(after.position)<0.01 and before.direction.dot(after.direction)>0.99,"Unloading joins the separate return bay continuously")
 var inbound=TrafficRules.sample(t,12)
 check(inbound.position.distance_to(before.position)>6,"Incoming goods and the empty return use separate sides of the apron")
 print("TRAFFIC RECOVERY 0.29.4: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
