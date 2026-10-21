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
func check(ok: bool,description: String) -> void:
 checks+=1
 if not ok: failures.append(description); printerr("FAILED: ",description)
func fresh() -> void:
 game.state=game.initial_state()
 game.tick_clock=0
 game.state.workers=0
 game.state.city_services.enabled=false
 game.state.coins=1000000
func link() -> bool:
 return game.build_road("asphalt",TownRules.path(Vector2i(80,176),ExportTrade.GATE))
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 fresh()
 for point in [Vector3(250,0,0),Vector3(-250,0,0),Vector3(250,0,-100),Vector3(210,0,20)]:
  check(game.placement_reason(point).is_empty(),"Free mainland accepts construction: "+str(point))
 check(not game.placement_reason(Vector3(0,0,20)).is_empty(),"Actual roads remain protected")
 check(not game.placement_reason(Vector3(302,0,20)).is_empty(),"The whole footprint must fit on level land")
 check(not game.placement_reason(Vector3(235,0,239)).is_empty(),"Lake and river are protected")
 check(not game.placement_reason(Vector3(294,0,164)).is_empty(),"Private motorway infrastructure cannot be built over")
 var locked=Catalog.biome_position(1)
 check(game.placement_reason(locked).contains("Biom gesperrt"),"Locked biome center cannot be built on")
 var edge=locked+Vector3(51,0,0)
 check(WorldAccess.building_reason(edge,0,1).contains("Biom gesperrt"),"An outside center cannot overhang a locked biome")
 check(WorldAccess.building_reason(edge,90,1).contains("Biom gesperrt"),"Rotated footprint cannot overhang a locked biome")
 var before=game.snapshot()
 check(not game.order_building("station",locked) and game.state.coins==before.coins and game.state.jobs==before.jobs,"Locked construction cannot spend coins or create jobs")
 var coins=float(game.state.coins)
 check(game.unlock_biome() and game.state.coins==coins-float(Catalog.BIOMES[1].cost)*game.difficulty(),"Biome unlock charges its actual cost")
 check(WorldAccess.building_reason(locked,0,int(game.state.unlocked)).is_empty(),"The unlocked biome becomes usable land")
 check(game.order_building("station",locked),"Construction can start in a newly unlocked forest")
 var legacy=game.snapshot()
 legacy.unlocked=1
 legacy.erase("trade")
 game.restore(JSON.parse_string(JSON.stringify(legacy)))
 check(game.state.jobs.size()==1 and game.state.jobs[0].position==[Placement.snap(locked).x,Placement.snap(locked).z],"Previously paid jobs survive migration even in newly protected zones")
 check(game.state.trade==ExportTrade.initial(),"Old saves receive an empty trade ledger without resetting the company")
 fresh()
 game.state.buildings.append({"kind":"prefab","level":1})
 for key in game.state.resources: game.state.resources[key]=5000
 var home_count=0
 for z in [-112,-80,-48,-16,16,48,80]:
  for x in [-280,-248,248,280]:
   if game.order_home("house",game.next_city_plot(),Vector3(x,0,z)): home_count+=1
 check(home_count>24 and game.state.jobs.size()==home_count,"Housing has no old regional or district plot cap")
 game.state.homes.append({"kind":"house","level":1,"plot":99,"position":[248,116]})
 # Ensure the reserved town hall ID cannot be assigned to a normal home.
 for i in 99: game.state.homes.append({"kind":"house","level":1,"plot":i,"position":[248,116]})
 check(game.next_city_plot()==101,"Town hall logical ID stays reserved beyond the old plot limit")
 fresh()
 game.state.buildings=[]
 for i in 24: game.state.buildings.append({"kind":"station","level":1,"position":[-40,20]})
 check(game.order_building("station",Vector3(248,0,0)),"Industry can grow beyond the former 24-building cap")
 fresh()
 var locked_path=TownRules.path(Vector2i(80,-160),Vector2i(140,-116))
 check(not game.road_reason("asphalt",locked_path).is_empty(),"New roads cannot cut through locked biomes")
 check(not game.stop_reason(Vector3(80,0,-116)).is_empty(),"A new stop cannot overhang a locked biome beside a legacy road")
 check(game.build_road("asphalt",TownRules.path(Vector2i(80,176),Vector2i(120,176))),"Unlocked mainland roads need no district purchase")
 game.state.resources.furniture=16
 game.simulate(100)
 check(game.state.trade.sold==0 and game.state.trade.shipments.is_empty(),"A partial road cannot trigger invisible trade")
 check(game.build_road("asphalt",TownRules.path(Vector2i(120,176),ExportTrade.GATE)),"The player can complete and pay for the remaining approach")
 check(not ExportTrade.route(game.state).is_empty(),"A continuous graph reaches the exact public highway cell")
 var available=float(game.state.resources.furniture)
 var paid=float(game.state.coins)
 game.step(1)
 check(game.state.trade.shipments.size()==1 and game.state.resources.furniture==available-4,"Loading reserves a real LKW and removes exactly its cargo")
 check(game.state.coins==paid and game.state.trade.sold==0,"Loading cannot pay in advance")
 var trip=game.state.trade.shipments[0]
 check(ConstructionRules.dispatch(game.state)==0 and ExportTrade.available_trucks(game.state)==0,"An export truck is unavailable to other freight domains")
 check(not game.remove_road(1),"Roads used by an outward export are protected")
 check(not game.move_building(int(trip.origin),Vector3(248,0,-80)),"An export's source dock remains fixed during its trip")
 var quoted=float(trip.amount)*float(trip.unit_price)
 game.state.auto_export=false
 game.state.boosters.money={"left":200,"factor":9.0}
 var saved=JSON.parse_string(JSON.stringify(game.snapshot()))
 var arrival_seconds=0
 for i in 600:
  game.step(1)
  arrival_seconds+=1
  if trip.arrived: break
 check(game.state.coins==paid+quoted and game.state.trade.revenue==quoted and game.state.trade.sold==4,"Arrival pays the saved quote exactly once even after price settings change")
 check(game.state.trade.shipments.size()==1 and game.state.trade.shipments[0].arrived,"Empty return still occupies the same truck")
 check(not game.remove_road(1),"Return journey still protects all public route cells")
 var online=game.snapshot()
 game.restore(saved)
 for i in arrival_seconds: game.step(1)
 check(game.state.resources==online.resources and equivalent(game.state.trade,online.trade) and game.state.coins==online.coins,"JSON restore and offline/online advancement settle the same cargo exactly once")
 for i in 600:
  if game.state.trade.shipments.is_empty(): break
  game.step(1)
 check(game.state.trade.shipments.is_empty() and game.state.coins==paid+quoted,"Return frees the truck without a second payout")
 check(game.remove_road(1),"A completed round trip releases its road reservation")
 check(game.move_building(4,Vector3(248,0,-80)),"A completed trip releases its source building")
 check(game.state.resources.furniture==available-4,"Pausing new exports never discards or duplicates undelivered stock")
 fresh()
 game.state.resources.furniture=20
 game.state.auto_export=true
 game.state.town.roads=[{"kind":"asphalt","cells":[[300,172],[300,176]]}]
 check(ExportTrade.route(game.state).is_empty(),"An isolated highway endpoint cannot teleport cargo across a broken network")
 game.state.town.roads=[]
 check(link(),"Full motorway approach is legal with only the first biome unlocked")
 game.state.buildings[4].paused=true
 check(ExportTrade.route(game.state).is_empty(),"Paused markets cannot originate a new export")
 game.state.buildings[4].paused=false
 check(ExportTrade.dispatch(game.state,18,65*1.15) and game.state.trade.shipments[0].amount==2,"Export respects the exact material reserve")
 game.state.trade.gateway="harbor"
 check(ExportTrade.route(game.state).is_empty(),"A future harbor cannot silently operate as an active freight gateway")
 ExportTrade.tick(game.state,1000)
 check(game.state.trade.shipments.is_empty() and game.state.trade.sold==2,"Already booked highway cargo completes if a future gateway setting changes")
 fresh()
 check(link(),"Shared-fleet scenario connects the real motorway")
 game.state.resources.furniture=12
 game.state.resources.wood=40
 game.state.resources.boards=40
 game.state.company_xp=120
 check(game.upgrade(1),"Shared-fleet scenario creates a material-based construction job")
 check(ExportTrade.dispatch(game.state,0,74.75),"The owned truck first departs on a real export")
 check(ConstructionRules.dispatch(game.state)==0 and game.state.construction_shipments.is_empty(),"A waiting material job cannot reuse a truck during its export")
 game.state.buildings.append({"kind":"quarry","level":1,"position":[-20,-12]})
 game.state.buildings.append({"kind":"stoneworks","level":1,"position":[20,-12]})
 StoneIndustry.synchronize(game.state)
 StoneIndustry.site(game.state,5).stock.rock=8
 check(not StoneIndustry.requests(game.state,{}).is_empty(),"A competing quarry has a valid road and actual waiting cargo")
 check(StoneIndustry.dispatch(game.state,{})==0,"Stone logistics cannot reuse the truck either")
 game.state.auto_export=false
 ExportTrade.tick(game.state,1000)
 check(ConstructionRules.dispatch(game.state)>0 and game.state.construction_shipments.size()==1,"The returning export releases the LKW to the waiting construction job")
 check(not ExportTrade.dispatch(game.state,0,74.75),"A busy construction truck cannot be reassigned to another export")
 fresh()
 check(link(),"Dispatch priority scenario connects the highway")
 game.state.resources.furniture=12
 game.state.resources.wood=40
 game.state.resources.boards=40
 game.state.company_xp=120
 game.upgrade(1)
 game.step(1)
 check(game.state.construction_shipments.size()==1 and game.state.trade.shipments.is_empty(),"Normal simulation dispatches needed construction materials before new exports")
 fresh()
 check(link(),"Capacity scenario connects the highway")
 game.state.resources.furniture=50
 game.state.buildings[4].level=3
 game.state.research.logistics=1
 check(ExportTrade.dispatch(game.state,0,74.75) and game.state.trade.shipments[0].amount==7,"Market upgrades and logistics research increase actual loaded export cargo")
 var booked=game.state.trade.shipments[0]
 game.state.auto_export=false
 ExportTrade.tick(game.state,float(booked.total))
 check(game.state.trade.ledgers.highway.sold==7 and game.state.trade.ledgers.harbor.sold==0 and game.state.trade.ledgers.airport.sold==0,"Highway settlement cannot invent future sea or air freight revenue")
 var ledger=game.state.trade.duplicate(true)
 game.sell("furniture",0.25)
 check(game.state.trade==ledger,"A local warehouse sale never counts as highway cargo")
 fresh()
 check(game.build_road("asphalt",TownRules.path(Vector2i(-80,180),Vector2i(-304,180))),"Roads use the entire level terrace beyond the former road boundary")
 check(not game.road_reason("asphalt",TownRules.path(Vector2i(300,176),Vector2i(304,176))).is_empty(),"Public road building cannot cover the private motorway ramp")
 print("WORLD & HIGHWAY TRADE 27: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
