extends SceneTree
var game
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func company(wood: float=802) -> Dictionary:
 game.restore(JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/forestry288-company.json")))
 var s=game.state
 s.workers=31.0
 s.tool=11.0
 s.resources.wood=wood
 s.resources.boards=200
 s.resources.dry=6
 s.resources.furniture=0
 s.resources.walls=211
 s.resources.roofs=282
 return s
func total(s: Dictionary,key: String) -> float:
 var stock=UXRules.material_stock(s,key)
 return float(stock.stored)+float(stock.transit)
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
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 var s=company()
 check(not CentralLogistics.urgent_wood(s).is_empty(),"A full forest output is served even when manually deposited warehouse wood is already 802")
 check(CentralLogistics.pickup_capacity(s,"wood")==72 and CentralLogistics.pickup_capacity(s,"boards")==18,"Forestry trucks haul four real log bundles while other freight keeps its existing capacity")
 var before=total(s,"wood")
 CentralLogistics.dispatch(s)
 check(s.hub.shipments.any(func(t): return t.key=="wood" and t.amount==72),"The existing central fleet actually withdraws a bulk log load at the forest station")
 check(total(s,"wood")==before and s.resources.wood==802,"Dispatch owns real wood but never credits the warehouse before unloading")
 check(CentralLogistics.urgent_wood(s).is_empty(),"An assigned forestry truck satisfies the reserved service until its return")
 # No chop or deposit calls anywhere inside either control run.
 var measurements=[]
 for initial_wood in [802.0,1015.0]:
  s=company(initial_wood)
  var gathered=float(s.gathered)
  var harvested=0.0
  var quiet=0
  var max_quiet=0
  var peak=0
  var line_sold=float(s.delivery.sold)
  var site_dispatched=int(s.next_shipment)
  for second in 1800:
   game.step(1)
   harvested+=float(game.flow.harvest)
   quiet=0 if float(game.flow.harvest)>0 else quiet+1
   max_quiet=maxi(max_quiet,quiet)
   peak=maxi(peak,s.hub.shipments.size()+DeliveryChain.central_busy(s))
  check(harvested>=1000,"Thirty-one saved workers actually harvest at least 1000 wood in thirty unattended minutes, starting with warehouse %s" % initial_wood)
  check(max_quiet<180,"Forest output cannot remain uncollected for three minutes while warehouse capacity is free: %s" % initial_wood)
  check(absf(float(s.gathered)-gathered-harvested)<0.000001,"The generated stock comes from real automatic harvest, without any manual chop or granted resource")
  check(absf(float(s.journey.stats.automatic_wood)-harvested)<0.000001,"The separate automatic counter matches the actual accepted worker yield")
  check(peak<=CentralLogistics.fleet_size(s),"The new forestry share does not create additional central trucks")
  check(float(s.delivery.sold)>line_sold and int(s.next_shipment)>site_dispatched,"Plant processing, actual shop sales and construction trips continue beside forestry")
  measurements.append({"manual_initial_wood":initial_wood,"automatic_harvest":harvested,"max_no_harvest_seconds":max_quiet})
 # Manual actions must not make idle workers appear productive in the report.
 var automatic=float(s.journey.stats.automatic_wood)
 s.bag=0
 game.chop()
 game.deposit()
 check(float(s.journey.stats.automatic_wood)==automatic,"Manual chop and manual deposit cannot increment automatic forestry statistics")
 check(ForestryFlow.team_status(s,game.flow).contains(Catalog.number(automatic)),"The actual team status reports independent worker production")
 var saved=JSON.parse_string(JSON.stringify(s,"",true,true))
 game.simulate(180)
 var expected=game.state.duplicate(true)
 game.restore(saved)
 game.simulate(180)
 check(equivalent(game.state,expected),"Larger cargo, priority, statistics and active deliveries restore identically from JSON")
 s=company()
 for b in s.buildings:
  if b.kind=="station": b.paused=true
 automatic=float(s.journey.stats.get("automatic_wood",0))
 game.simulate(120)
 check(float(s.journey.stats.get("automatic_wood",0))==automatic,"An explicit station pause still forbids automatic felling")
 check(ForestryFlow.team_status(s,game.flow).contains("Sammelstation pausiert"),"Team status explains a paused collection station")
 s.ux.motion=false
 check(ForestryFlow.team_status(s,game.flow).contains("Arbeitsanimationen sind ausgeschaltet"),"Team status identifies a genuine presentation pause independently of production")
 # Larger loads need enough bounded acceptance space for the real existing fleet.
 game.state=game.initial_state()
 s=game.state
 s.vehicle=3
 s.buildings.append({"kind":"central_depot","level":1,"position":[44,20]})
 var source=CentralLogistics.stock(s,0)
 source.wood=216
 for i in 3: CentralLogistics.launch(s,0,5,"wood",72,"central",source)
 s.resources.wood=CentralLogistics.capacity(s)
 before=total(s,"wood")
 for i in 600: CentralLogistics.tick(s,1)
 check(s.hub.shipments.is_empty() and s.hub.receiving.wood==216,"Even an already overbooked full store can unload all three owned bulk pickups and return their trucks")
 check(total(s,"wood")==before,"Bulk receiving retains every log and never duplicates unloading")
 check(CentralLogistics.storage_room(s,"wood")==0,"The larger receiving area does not permit speculative collection into a full store")
 print("FORESTRY 289 MEASURES: ",JSON.stringify(measurements))
 print("FORESTRY 289: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
