extends SceneTree

var game
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
func company(central: bool=true) -> Dictionary:
 game.state=game.initial_state()
 var s=game.state
 s.workers=0
 s.trucks=2
 s.vehicle=3
 s.company_xp=600
 s.city_services.enabled=false
 s.auto_export=false
 s.reserve=false
 s.buildings[0].level=5
 s.buildings[1].level=5
 s.buildings.append({"kind":"furniture","level":2,"paused":false,"position":[-20,-12]})
 if central: s.buildings.append({"kind":"central_depot","level":1,"paused":false,"position":[44,20]})
 DeliveryChain.start(s)
 return s
func site(id: int,materials: Dictionary,workers: int=1) -> Dictionary:
 var job={"id":id,"type":"home","kind":"apartments","plot":id%12,"position":[-44,84],"materials":materials,"delivered":{},"total":14.0,"left":14.0}
 ConstructionRules.attach(job,workers)
 return job
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 # An occupied construction queue must not embargo every ingredient of the
 # furniture required to finish the job at its head. Both existing modes matter.
 for central in [false,true]:
  var s=company(central)
  s.resources.wood=600
  s.resources.boards=200
  var home=site(1,{"furniture":6.0})
  home.phase=5
  s.jobs.append(home)
  for i in 8:
   var queued=site(i+2,{"wood":300.0,"boards":80.0},0)
   s.jobs.append(queued)
  var expected=600+200*2
  var accounted=s.jobs.duplicate()
  for tick in 900: game.step(1)
  check(float(home.delivered.get("furniture",0))==6,"Furniture reaches the waiting home despite future wood/board bills; central=%s" % central)
  check(not home in s.jobs,"Real construction finishes after unloading, central=%s" % central)
  var actual=float(s.resources.wood)+float(s.resources.boards)*2+float(s.resources.furniture)*4+float(s.delivery.sold)*4
  for group in [s.delivery.buffers,s.hub.outputs,s.hub.express]:
   for stock in group.values(): actual+=float(stock.get("wood",0))+float(stock.get("boards",0))*2+float(stock.get("furniture",0))*4
  for trip in FreightFlow.all_trips(s):
   if not trip.arrived: actual+=float(trip.amount)*{"wood":1.0,"boards":2.0,"furniture":4.0}.get(trip.key,0)
  for job in accounted:
   for key in job.delivered: actual+=float(job.delivered[key])*{"wood":1.0,"boards":2.0,"furniture":4.0}.get(key,0)
  check(absf(actual-expected)<0.00001,"Materials remain conserved through reserve recovery and construction, central=%s" % central)
 # Existing companies may use shared recipe production without ever assigning
 # the four-stop wood line. The repair must work for those saves as well.
 for central in [false,true]:
  var recipes=company(central)
  recipes.delivery=DeliveryChain.initial()
  recipes.resources.wood=600
  recipes.resources.boards=200
  recipes.resources.dry=38
  var home=site(60,{"furniture":6.0})
  home.phase=5
  recipes.jobs=[home]
  for i in 8: recipes.jobs.append(site(61+i,{"wood":300.0,"boards":80.0},0))
  game.step(1)
  check(float(game.flow.get("building:5",0))>0 and ProductionPresentation.describe(game,5).kind=="running","Legacy recipe workers and their status use ingredients needed by construction, central=%s" % central)
  for tick in 600: game.step(1)
  check(float(home.delivered.get("furniture",0))==6 and not home in recipes.jobs,"A legacy recipe company supplies its real waiting construction without switching delivery modes, central=%s" % central)
 # Newly harvested fractional input must also reach preparation, rather than
 # being consumed forever by the sawmill making that same site's future boards.
 for central in [false,true]:
  var fresh=company(central)
  fresh.workers=1
  fresh.coins=100000
  fresh.buildings[1].level=1
  fresh.resources.nuts=1
  fresh.resources.screws=2
  check(game.upgrade(1),"A real low-stock sawmill upgrade can be ordered, central=%s" % central)
  for tick in 900:
   game.step(1)
   if fresh.jobs.is_empty(): break
  check(fresh.jobs.is_empty() and fresh.buildings[1].level==2,"Fresh harvest feeds both construction and future board production, central=%s" % central)
 # A built central depot owns a real fleet even without a general-purpose truck.
 var s=company()
 s.trucks=0
 s.resources.wood=100
 s.resources.boards=100
 var peak=0
 for tick in 600:
  game.step(1)
  var assigned=s.hub.shipments.size()
  for trip in s.delivery.shipments:
   if trip.get("fleet","")=="central": assigned+=1
  peak=maxi(peak,assigned)
 check(peak<=CentralLogistics.fleet_size(s),"Pickup and plant deliveries share the actual central fleet for the full run")
 check(s.delivery.sold>0,"The central fleet feeds factories and delivers furniture without borrowing a general truck")
 check(peak>0 and ExportTrade.available_trucks(s)==0 and StoneIndustry.busy(s)==0,"Dedicated logistics neither invents nor occupies general-purpose vehicles")
 # A constant ready shop order must not monopolize every returning truck while
 # a factory's outputs needed by construction wait for collection.
 s=company()
 s.trucks=0
 s.resources.wood=100
 s.resources.boards=200
 s.resources.furniture=200
 s.buildings.append({"kind":"prefab","level":10,"paused":true,"position":[-44,20]})
 var producer=s.buildings.size()-1
 CentralLogistics.stock(s,producer).walls=144
 CentralLogistics.stock(s,producer).roofs=144
 var roof_site=site(50,{"roofs":8.0})
 roof_site.phase=4
 s.jobs=[roof_site]
 var served={}
 for tick in 600:
  game.step(1)
  for trip in s.delivery.shipments: served[trip.target]=true
 check(served.has("sawmill") and served.has("furniture") and served.has("market"),"Every connected branch receives service while warehouse goods and shop demand stay available")
 check(float(roof_site.delivered.get("roofs",0))==8,"Mixed factory output and construction pickups cannot starve behind continuous shop replenishment")
 var roof_stock=UXRules.material_stock(s,"roofs")
 check(absf(float(roof_stock.stored)+float(roof_stock.transit)+float(roof_site.delivered.get("roofs",0))-144)<0.00001,"Fair collection of mixed output conserves every roof module")
 # One deliberately paused workshop cannot stop the other workshop or unloads.
 s=company(false)
 s.buildings[1].paused=true
 s.resources.boards=20
 for tick in 200: game.step(1)
 check(s.delivery.sold>0,"Furniture workers process warehouse boards while the sawmill alone is paused")
 check(s.delivery.buffers.sawmill.boards==0 and float(game.flow.get("building:1",0))==0,"The paused sawmill itself remains stopped")
 check(ProductionPresentation.describe(game,5).kind!="paused" and not "Pausiert" in game.production_status(5),"Factory badges and building details agree that a different building's pause does not stop this worker")
 # A standard, individually ordered site gets a crew after the previous one.
 s=company(false)
 s.builders=1
 var first=site(41,{})
 var next=site(42,{},0)
 s.jobs=[first,next]
 for tick in 60: game.step(1)
 check(s.jobs.is_empty() and s.homes.size()==2,"Ordinary paid sites automatically reuse a released construction crew")
 s=company(false)
 next=site(43,{},0)
 s.jobs=[next]
 game.assign_builders(43,0)
 game.simulate(30)
 check(next.workers==0 and next in s.jobs,"An explicit manual zero-worker assignment remains respected")
 var snapshot=game.snapshot()
 snapshot.jobs[0].erase("auto_crew")
 game.restore(JSON.parse_string(JSON.stringify(snapshot)))
 check(game.state.jobs[0].get("auto_crew",false),"Old jobs missing a crew policy acquire automatic handoff on load")
 game.simulate(30)
 check(game.state.jobs.is_empty(),"A restored old unstaffed job can actually finish")
 # Report the actual regional leg, rather than implying central stock is
 # already at the express. Inspection itself must never reserve or move stock.
 s=company()
 s.buildings.append({"kind":"express","level":1,"paused":false,"position":[-44,116]})
 var remote=site(44,{"boards":8.0})
 remote.position=[-44,148]
 remote.phase=2
 s.jobs=[remote]
 s.resources.boards=8
 var before=s.duplicate(true)
 check("Nachschub zum Abhol-Express" in ConstructionRules.logistics_status(s,remote),"An empty regional depot reports its missing replenishment leg")
 check(s==before,"Inspecting delivery status never changes stock or creates a shipment")
 CentralLogistics.dispatch(s)
 check("Abhol-Express" in ConstructionRules.logistics_status(s,remote),"A real regional replenishment is visible in the site's supply status")
 var cargo=s.hub.shipments[0]
 cargo.depart_in=12
 check("Abfahrt in 12" in ConstructionRules.logistics_status(s,remote),"Queued cargo is identified as a reserved departure, not a moving truck")
 var saved=JSON.parse_string(JSON.stringify(s,"",true,true))
 game.simulate(90)
 var expected=game.state.duplicate(true)
 game.restore(saved)
 game.simulate(90)
 check(equivalent(game.state,expected),"Regional freight, crew handoff and resumed production replay identically after JSON restoration")
 print("SUPPLY 286: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
