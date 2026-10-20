extends SceneTree

var game
var checks=0
var failures=[]
var accounted_jobs=[]
const WEIGHTS={"wood":1.0,"boards":2.0,"furniture":4.0}

func _initialize() -> void: call_deferred("run")
func check(ok: bool, detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func equivalent(a: Variant,b: Variant) -> bool:
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
func company() -> void:
 game.state=game.initial_state()
 game.state.company_xp=800
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.city_services.enabled=false
 game.state.companion_enabled=false
 game.state.workers=0
 game.state.trucks=2
 game.state.vehicle=4
 game.state.coins=771800
 game.state.buildings[0].level=5
 game.state.buildings[1].level=5
 game.state.buildings[4].level=4
 game.state.buildings.append({"kind":"furniture","level":3,"paused":false,"position":[-20,-12]})
 game.state.buildings.append({"kind":"prefab","level":1,"paused":true,"position":[20,-12]})
 game.flow.clear()
 game.delivery_route_cache.clear()
 game.tick_clock=0
 accounted_jobs=[]
 check(game.start_delivery(),"Level-eight company opens its existing wood line")
func units() -> float:
 var total=float(game.state.delivery.sold)*4
 for key in WEIGHTS: total+=float(game.state.resources[key])*WEIGHTS[key]
 for kind in game.state.delivery.buffers:
  for key in WEIGHTS: total+=float(game.state.delivery.buffers[kind][key])*WEIGHTS[key]
 for kind in game.state.delivery.recovered:
  for key in game.state.delivery.recovered[kind]: total+=float(game.state.delivery.recovered[kind][key])*WEIGHTS.get(key,0)
 for s in game.state.delivery.shipments+game.state.construction_shipments:
  if not s.arrived: total+=float(s.amount)*WEIGHTS.get(s.key,0)
 for job in accounted_jobs:
  for key in job.delivered: total+=float(job.delivered[key])*WEIGHTS.get(key,0)
 return total
func bill(id: int,amount: float,point: Vector3) -> Dictionary:
 var job={"id":id,"type":"building","kind":"garage","slot":7,"position":[point.x,point.z],"total":70.0,"left":60.0,"materials":{"boards":amount},"delivered":{}}
 ConstructionRules.attach(job,1)
 job.phase=1
 return job
func valid_stock() -> bool:
 for key in game.state.resources:
  if float(game.state.resources[key])< -0.000001: return false
 for kind in game.state.delivery.buffers:
  for key in game.state.delivery.buffers[kind]:
   if float(game.state.delivery.buffers[kind][key])< -0.000001: return false
 return true
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 company()
 game.state.resources.wood=100
 game.state.resources.parts=2
 game.state.delivery.buffers.station.wood=14
 game.state.delivery.buffers.sawmill.wood=2
 game.state.delivery.buffers.sawmill.boards=6
 game.state.delivery.buffers.furniture.boards=5
 check(game.company_level()==8 and not game.state.construction_auto,"Regression reproduces the screenshot level without level-ten automation")
 check(game.order_home("park",0),"Real city project advertises twenty boards rather than requiring them upfront")
 var job=game.state.jobs[0]
 accounted_jobs=[job]
 check(job.requested and float(job.materials.boards)==20,"Paid construction immediately requests the actual twenty-board bill")
 var total=units()
 var pickup={}
 for i in 15:
  game.step(1)
  for s in game.state.construction_shipments:
   if s.key=="boards": pickup=s; break
  if not pickup.is_empty(): break
 check(not pickup.is_empty() and pickup.source=="sawmill" and int(pickup.origin)==1,"Construction loads real local boards directly at the assigned sawmill")
 check(float(game.state.resources.boards)==0,"Local boards never teleport through the global warehouse")
 check(float(job.delivered.get("boards",0))==0 and not pickup.arrived,"Loading a truck cannot prematurely credit the site")
 check("Sägewerk" in ConstructionRules.logistics_status(game.state,job) and "Baustelle" in ConstructionRules.logistics_status(game.state,job),"Actual source and destination are readable while cargo is underway")
 check(absf(units()-total)<0.000001,"Direct pickup preserves wood equivalents across every buffer and cargo owner")
 var saved=JSON.parse_string(JSON.stringify(game.state,"",true,true))
 game.simulate(60)
 var expected=game.state.duplicate(true)
 game.restore(saved)
 check(DeliveryChain.owns(game.state,1) and DeliveryChain.owns(game.state,5),"JSON float building references retain exclusive ownership of sawmill and furniture recipes")
 game.simulate(60)
 if not equivalent(game.state,expected):
  for key in expected:
   if not equivalent(game.state[key],expected[key]): printerr("DIFF ",key,": ",game.state[key]," expected ",expected[key])
 check(equivalent(game.state,expected),"Saving during direct pickup resumes exactly the same road cargo and construction state")
 # Use the restored job for the remainder of the resource-accounting run.
 job=game.state.jobs[0]
 accounted_jobs=[job]
 var empty_return=false
 for i in 600:
  game.step(1)
  for s in game.state.construction_shipments:
   if s.arrived: empty_return=true
  check(valid_stock(),"No negative stocks during integrated construction tick %s" % i)
  check(game.state.delivery.shipments.size()+game.state.construction_shipments.size()+game.state.stone.shipments.size()<=int(game.state.trucks),"Wood line and building deliveries share the purchased fleet at tick %s" % i)
  check(absf(units()-total)<0.000001,"No wood, boards or furniture are duplicated, reversed or lost at tick %s" % i)
  if game.state.jobs.is_empty(): break
 check(game.state.jobs.is_empty() and game.state.homes.size()==1 and game.state.homes[0].kind=="park","Twenty directly supplied boards and delivered parts finish the real city park")
 check(float(job.delivered.boards)==20 and float(job.delivered.parts)==2,"Construction receives exactly its advertised bill")
 check(empty_return,"A completed delivery remains assigned for an empty return")
 company()
 game.state.delivery.buffers.sawmill.boards=5
 var a=bill(700,16,Vector3(44,0,-12))
 var b=bill(701,16,Vector3(-44,0,20))
 game.state.jobs=[a,b]
 accounted_jobs=[a,b]
 total=units()
 ConstructionRules.dispatch(game.state)
 check(game.state.construction_shipments.size()==2,"Two sites can reserve separate partial loads from one actual output")
 check(float(game.state.delivery.buffers.sawmill.boards)==0,"The five-board pallet cannot be loaded twice")
 check(ConstructionRules.incoming(game.state,700,"boards")==4 and ConstructionRules.incoming(game.state,701,"boards")==1,"Reservations split into four and one without over-delivery")
 check(ConstructionRules.dispatch(game.state)==0 and absf(units()-total)<0.000001,"Repeated dispatch neither duplicates goods nor overbooks trucks")
 check(game.cancel_construction(700) and absf(units()-total)<0.000001,"Cancelling a direct factory pickup safely returns its cargo once")
 check(game.cancel_construction(701) and game.state.resources.boards==5,"Both partial loads refund to actual warehouse stock without loss")
 company()
 game.state.delivery.buffers.sawmill.boards=4
 job=bill(702,16,Vector3(44,0,-12))
 job.paused=true
 game.state.jobs=[job]
 check(ConstructionRules.dispatch(game.state)==0 and game.state.delivery.buffers.sawmill.boards==4,"Paused construction reserves no new output")
 job.paused=false
 job.position=[310,220]
 check(ConstructionRules.dispatch(game.state)==0 and game.state.delivery.buffers.sawmill.boards==4,"Unreachable construction leaves local source stock untouched")
 check("Keine Straßenverbindung" in ConstructionRules.logistics_status(game.state,job),"An unreachable pickup reports the route problem")
 job.position=[44,-12]
 game.state.delivery.paused=true
 game.step(1)
 check(game.state.construction_shipments.size()==1,"Independent construction can collect existing output while the wood line is paused")
 var legacy=game.snapshot()
 legacy.erase("construction_logistics_version")
 legacy.jobs[0].requested=false
 legacy.jobs[0].paused=true
 var cargo_before=legacy.construction_shipments.duplicate(true)
 var stock_before=legacy.delivery.buffers.duplicate(true)
 game.restore(legacy)
 check(game.state.jobs[0].requested and game.state.jobs[0].paused,"Old pending sites enable deliveries without overriding an explicit construction pause")
 check(game.state.construction_shipments==cargo_before and game.state.delivery.buffers==stock_before,"Migration preserves existing loaded trucks and local material quantities")
 company()
 game.state.company_xp=1600
 game.state.construction_auto=true
 job=bill(703,16,Vector3(44,0,-12))
 game.state.jobs=[job]
 game.state.delivery.buffers.sawmill.boards=4
 game.step(1)
 check(game.state.resources.boards==0 and game.state.construction_shipments.size()==1,"Level-ten automation uses direct cargo rather than an invisible warehouse transfer")
 company()
 game.state.delivery.buffers.sawmill.wood=1
 game.state.delivery.buffers.sawmill.boards=DeliveryChain.capacity(game.state,"sawmill")
 var info=DeliveryChain.status(game.state,"sawmill")
 check(info.key=="wood" and info.amount==1 and info.output_key=="boards" and info.full,"A full output keeps the wood input icon and a separate board output counter")
 game.state.delivery.buffers.sawmill.boards=0
 info=DeliveryChain.status(game.state,"sawmill")
 check(info.key=="wood" and info.output_key=="boards" and info.output_amount==0,"Collecting boards does not switch the material identity back to logs")
 company()
 game.state.buildings.append({"kind":"stoneworks","level":1,"paused":true,"position":[44,-12]})
 StoneIndustry.synchronize(game.state)
 StoneIndustry.site(game.state,7).stock.stone=5
 job=bill(704,0,Vector3(-44,0,20))
 job.materials={"stone":5.0}
 ConstructionRules.attach(job,1)
 job.phase=1
 game.state.jobs=[job]
 ConstructionRules.dispatch(game.state)
 check(game.state.construction_shipments.size()==1 and game.state.construction_shipments[0].source=="stoneworks" and StoneIndustry.site(game.state,7).stock.stone==0,"Construction can collect actual finished building stones directly from a stone factory")
 print("LOGISTICS FIX: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
