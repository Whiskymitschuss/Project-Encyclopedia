extends SceneTree
var game
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func company(line: bool=true) -> Dictionary:
 game.state=game.initial_state()
 var s=game.state
 s.workers=6; s.vehicle=1; s.auto_export=false; s.reserve=false; s.city_services.enabled=false
 s.buildings[2].level=8; s.buildings[1].level=2
 s.buildings.append({"kind":"central_depot","level":1,"paused":false,"position":[44,20]})
 s.buildings.append({"kind":"furniture","level":2,"paused":false,"position":[21,-12]})
 s.buildings.append({"kind":"kiln","level":2,"paused":false,"position":[-21,20]})
 s.resources.wood=4000; s.resources.boards=15; s.resources.dry=80; s.resources.furniture=4
 if line: DeliveryChain.start(s)
 LogisticsDispatch.synchronize(s)
 return s
func equivalent(s: Dictionary) -> float:
 var total=SawmillProduction.pending_total(s)*2
 for pair in [["wood",1],["boards",2],["dry",4],["furniture",10],["walls",10],["roofs",10]]:
  var stock=UXRules.material_stock(s,pair[0])
  total+=(float(stock.stored)+float(stock.transit))*float(pair[1])
 return total
func same(a: Variant,b: Variant) -> bool:
 if (a is float or a is int) and (b is float or b is int): return absf(float(a)-float(b))<0.00000001
 if a is Dictionary and b is Dictionary:
  if a.size()!=b.size(): return false
  for key in a:
   if not b.has(key) or not same(a[key],b[key]): return false
  return true
 if a is Array and b is Array:
  if a.size()!=b.size(): return false
  for i in a.size():
   if not same(a[i],b[i]): return false
  return true
 return a==b
func run() -> void:
 await process_frame
 game=root.get_node("Game");game.set_process(false)
 var s=company()
 check(CentralLogistics.fleet_size(s)==5,"A completed level-one network has five real warehouse trucks")
 check(FactorySupply.capacity(s,1)==128 and FactorySupply.stock(s,1).wood==0 and s.resources.wood==4000,"Larger level-two buffers do not create any inventory")
 check(CentralLogistics.pickup_capacity(s,"wood")==84 and CentralLogistics.pickup_capacity(s,"boards")==56,"Vehicle-one freight carries bulk logs and larger pallet loads")
 game.step(1)
 var incoming=s.hub.shipments.filter(func(t): return t.target=="factory" and int(t.destination)==1)
 check(incoming.size()==1 and incoming[0].amount>8 and FactorySupply.stock(s,1).wood==0,"A real larger wood load is withdrawn once and cannot be used before unload")
 for i in 10: LogisticsDispatch.dispatch(s)
 check(s.hub.shipments.filter(func(t): return t.target=="factory" and int(t.destination)==1 and t.key=="wood").size()==1,"Repeated dispatch cannot fill the same input with duplicate pending trucks")
 check(FactorySupply.status(s,1).contains("Ankunft in"),"Werk status shows the actual scheduled delivery including road reservation")
 var booked=incoming[0]
 var old_load=float(booked.amount)
 s.coins=100000
 var coins=float(s.coins)
 var cost=TransportCapacity.upgrade_cost(s,1)
 var raw=float(s.resources.wood)
 check(game.upgrade_transport(1) and s.coins==coins-cost,"A workshop transport upgrade pays its displayed cost exactly once")
 check(FactorySupply.capacity(s,1)==160 and CentralLogistics.pickup_capacity(s,"wood",5,1)==105,"A real workshop upgrade expands stock space and destination loading volume")
 check(booked.amount==old_load and s.resources.wood==raw,"A transport upgrade does not rewrite cargo already on the road or grant materials")
 var before_fleet=CentralLogistics.fleet_size(s)
 var site_fleet=CentralLogistics.construction_fleet_size(s)
 var general=s.trucks
 coins=s.coins;cost=TransportCapacity.fleet_cost(s)
 check(game.buy_central_truck() and s.coins==coins-cost and CentralLogistics.fleet_size(s)==before_fleet+1,"Buying a warehouse truck charges once and adds exactly one truck")
 check(s.trucks==general and CentralLogistics.construction_fleet_size(s)==site_fleet,"A purchased warehouse truck is not also duplicated into the export or site fleet")
 check(game.buy_central_truck(),"The starting warehouse has two paid expansion slots")
 coins=s.coins
 check(not game.buy_central_truck() and s.coins==coins,"A full parking allocation cannot take payment for another truck")
 s.buildings.append({"kind":"garage","level":1,"paused":false})
 check(game.buy_central_truck(),"A completed garage opens additional warehouse purchase slots")
 s.coins=0
 var level=TransportCapacity.dock_level(s,1)
 check(not game.upgrade_transport(1) and TransportCapacity.dock_level(s,1)==level,"Insufficient funds cannot improve a workshop")
 s.coins=100000
 while TransportCapacity.dock_level(s,1)<4: game.upgrade_transport(1)
 coins=s.coins
 check(not game.upgrade_transport(1) and s.coins==coins and not game.upgrade_transport(-1),"Maximum and invalid workshop upgrades never charge or change stock")
 var saved=JSON.parse_string(JSON.stringify(s,"",true,true))
 game.simulate(240)
 var expected=s.duplicate(true)
 game.restore(saved);s=game.state
 game.simulate(240)
 check(same(s,expected),"Paid transport levels, purchased fleet, queued freight and production survive exact save continuation")
 # A full finite fleet is not a lock on a factory that still owns its inputs.
 s=company();s.workers=0
 s.delivery.buffers.sawmill.wood=20
 var source=CentralLogistics.stock(s,0);source.wood=10
 for i in CentralLogistics.fleet_size(s): CentralLogistics.launch(s,0,5,"wood",1,"central",source)
 game.step(1)
 check(CentralLogistics.available_trucks(s)==0 and float(game.flow.get("building:1",0))>0 and s.delivery.buffers.sawmill.wood<20,"A factory with local stock continues while every warehouse truck is reserved")
 check(FactorySupply.status(s,1).contains("Nachschub wartet"),"Waiting for future supply is distinguished from a production stop")
 # Same generated company as the measured old 3-truck / 8-log baseline.
 s=company()
 var working=0;var starved=0;var quiet=0;var longest=0;var peak=0
 for second in 1200:
  game.step(1)
  if float(game.flow.get("building:1",0))>0: working+=1;quiet=0
  elif float(FactorySupply.stock(s,1).get("wood",0))<2 and SawmillProduction.pending(s,1)<=0:
   starved+=1;quiet+=1;longest=maxi(longest,quiet)
  peak=maxi(peak,s.hub.shipments.size())
 var completed=float(s.sawmills.sites["1"].completed)
 check(working>=800 and completed>=400,"Without manual orders the small automatic sawmill works most of the twenty-minute scenario")
 check(int(s.delivery.sold)>=40,"Real boards continue downstream into delivered and sold furniture")
 check(longest<60 and peak<=CentralLogistics.fleet_size(s),"No minute-long input starvation or phantom extra trucks in the generated company")
 print("THROUGHPUT 2815 MEASURE: ",JSON.stringify({"seconds":1200,"fleet":CentralLogistics.fleet_size(s),"input_capacity":FactorySupply.capacity(s,1),"working":working,"starved":starved,"longest_starvation":longest,"finished_boards":completed,"sold_furniture":s.delivery.sold,"trips":int(s.hub.next_id)-300000,"peak":peak}))
 # Full generic recipe chain, including drying and prefab products, conserves
 # wood equivalents across warehouse, local buffers, in-process work and cargo.
 s=company(false);s.workers=0
 s.buildings.append({"kind":"prefab","level":1,"paused":false,"position":[21,52]})
 var balance=equivalent(s)
 for second in 1200: game.step(1)
 check(float(s.journey.stats.get("boards",0))>100 and float(s.journey.stats.get("dry",0))>0 and float(s.journey.stats.get("furniture",0))>0,"Generic sawmill, drying and furniture factories produce automatically without a request tap")
 check(float(s.journey.stats.get("walls",0))>0 and float(s.journey.stats.get("roofs",0))>0,"The same finite network also supplies prefab wall and roof production")
 check(absf(equivalent(s)-balance)<0.0001,"Larger loads and local buffers preserve all wood equivalents through the complete generic recipe chain")
 # Full sixteen-truck reservations keep the same collision-free road scheduler.
 s=company();s.workers=0;s.buildings[5].level=8;s.hub.extra_trucks=6
 var original=float(s.resources.wood)
 for i in CentralLogistics.fleet_size(s): CentralLogistics.launch(s,5,1,"wood",1,"factory",s.resources)
 var collision_free=true
 for i in s.hub.shipments.size():
  for j in range(i):
   var a=s.hub.shipments[i];var b=s.hub.shipments[j]
   var offset=float(a.depart_in)-float(b.depart_in)
   for window in FreightFlow.windows(a,b):
    if offset>window.x-0.0001 and offset<window.y+0.0001: collision_free=false
 check(s.hub.shipments.size()==16 and CentralLogistics.available_trucks(s)==0 and collision_free,"All sixteen real trucks retain non-overlapping route and dock reservations")
 for second in 1200: CentralLogistics.tick(s,1)
 check(s.hub.shipments.is_empty() and float(s.resources.wood)+float(FactorySupply.stock(s,1).wood)==original,"The full fleet unloads each parcel once and returns every reserved truck")
 var old=s.duplicate(true);old.hub.erase("extra_trucks")
 for building in old.buildings: building.erase("transport_level")
 var stock=float(s.resources.wood)
 game.restore(old);s=game.state
 check(int(s.hub.extra_trucks)==0 and TransportCapacity.dock_level(s,1)==0 and s.resources.wood==stock,"Old saves gain transport defaults without free stock, lost materials or purchased upgrades")
 # No pause bypass or stock invention under real constraints.
 s=company();s.delivery.paused=true
 game.step(1)
 check(not s.hub.shipments.any(func(t): return t.target=="factory" and int(t.destination)==1),"Explicit production pauses still suppress automatic supply")
 s=company();s.buildings[1].position=[900,900]
 game.step(1)
 check(not s.hub.shipments.any(func(t): return t.target=="factory" and int(t.destination)==1),"More trucks cannot invent a route to an unconnected workshop")
 s=company();s.workers=0;s.delivery.paused=true
 for key in s.resources: s.resources[key]=0
 game.step(1)
 check(s.hub.shipments.is_empty(),"An empty network cannot manufacture a load to hide a stock shortage")
 print("THROUGHPUT 2815: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
