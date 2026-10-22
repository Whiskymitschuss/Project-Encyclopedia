extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func total(state: Dictionary,key: String) -> float:
 var amount=float(state.resources.get(key,0))
 for group in [state.hub.outputs,state.hub.express]:
  for stock in group.values(): amount+=float(stock.get(key,0))
 for trip in state.hub.shipments+state.construction_shipments:
  if not trip.arrived: amount+=float(trip.amount)
 for job in state.jobs: amount+=float(job.get("delivered",{}).get(key,0))
 return amount
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 var state=game.state
 state.buildings.append({"kind":"central_depot","level":1,"paused":false,"position":[44,20]})
 var center=state.buildings.size()-1
 state.buildings.append({"kind":"express","level":1,"paused":false,"position":[-44,116]})
 var express=state.buildings.size()-1
 check(CentralLogistics.active(state) and CentralLogistics.capacity(state)==2500,"A real built central warehouse activates larger capacity without deleting the old warehouse")
 check(game.placement_reason(Vector3(44,0,20),0,center).is_empty(),"The larger central depot fits a genuine free double-width plot")
 check(Placement.size_for(0,"central_depot")==Vector2(31,23) and Placement.size_for(90,"central_depot")==Vector2(23,31),"Large depot footprint rotates with its model")
 check(not game.placement_reason(Vector3(62,0,20),0).is_empty(),"A neighbouring building cannot overlap the larger depot")
 var job={"id":900,"type":"home","kind":"townhall","plot":20,"position":[-44,148],"left":70.0,"total":70.0,"materials":{"boards":8.0},"delivered":{}}
 ConstructionRules.attach(job)
 job.phase=2
 state.jobs=[job]
 var source=CentralLogistics.construction_sources(state,job,"boards")
 check(source.size()==1 and int(source[0].index)==express,"A distant site chooses its nearest road-connected regional express")
 CentralLogistics.stock(state,1).boards=8.0
 var original=total(state,"boards")
 CentralLogistics.dispatch(state)
 check(state.hub.shipments.size()==1 and state.hub.shipments[0].target=="central" and state.resources.boards==0,"Finished sawmill pallets are withdrawn into an actual white-blue pickup, never credited early")
 check(ConstructionRules.dispatch(state)==0,"A site cannot bypass the depot and steal a finished sawmill pallet")
 var pickup=state.hub.shipments[0]
 CentralLogistics.tick(state,float(pickup.travel)-0.01)
 check(state.resources.boards==0,"Central stock remains empty until the truck finishes unloading")
 CentralLogistics.tick(state,0.02)
 check(state.resources.boards==8 and pickup.arrived,"Unloading credits the exact pickup once")
 CentralLogistics.tick(state,0.1)
 check(state.resources.boards==8,"An arrived truck cannot credit its cargo a second time")
 CentralLogistics.dispatch(state)
 var replenishment=state.hub.shipments.filter(func(trip): return trip.target=="express")
 check(replenishment.size()==1 and state.resources.boards<8,"The distant depot receives a real replenishment trip from central stock")
 check(total(state,"boards")==original,"Collection and regional replenishment conserve every board")
 # Shared industry trucks may all be occupied: construction has its own fleet.
 state.trucks=0
 for tick in 360:
  CentralLogistics.tick(state,1)
  CentralLogistics.dispatch(state)
  ConstructionRules.transport_tick(state,1)
  ConstructionRules.dispatch(state)
 check(float(job.delivered.get("boards",0))==4,"Regional stock supplies exactly the current construction phase with dedicated delivery drivers")
 check(total(state,"boards")==original,"A complete central → express → site cycle conserves its stock and cargo")
 check(state.hub.shipments.is_empty() and state.construction_shipments.is_empty(),"Every assigned pickup, replenishment and construction return finishes without mutual waiting")
 check(state.jobs[0].phase==2,"Logistics never awards construction progress or bypasses the workers")
 job.phase=4
 for tick in 360:
  CentralLogistics.tick(state,1)
  CentralLogistics.dispatch(state)
  ConstructionRules.transport_tick(state,1)
  ConstructionRules.dispatch(state)
 check(float(job.delivered.boards)==8 and total(state,"boards")==original,"Later phases consume the remaining real regional stock without duplication")
 # A missing road must neither reserve nor withdraw goods.
 var empty=game.initial_state()
 empty.buildings.append({"kind":"central_depot","level":1,"position":[270,-150]})
 CentralLogistics.stock(empty,1).boards=6
 CentralLogistics.dispatch(empty)
 check(empty.hub.shipments.is_empty() and CentralLogistics.stock(empty,1).boards==6,"Disconnected central yards retain output stock and create no phantom trip")
 game.restore(JSON.parse_string(JSON.stringify(state)))
 check(total(game.state,"boards")==original and game.state.hub.express.has(str(express)),"JSON save restoration preserves all depot, site and regional stock")
 # Static delivery bays also reserve a finite slot for same-road neighbouring sites.
 var queue=game.initial_state()
 for i in 5:
  FreightFlow.enqueue(queue,queue.hub.shipments,{"id":i,"target":"central","origin":0,"destination":1,"path":[[0,0.95,0],[0,0.95,0]],"load":2.0,"drive":2.0,"travel":6.0,"total":10.0,"age":0.0,"arrived":false})
 check(queue.hub.shipments[-1].depart_in>queue.hub.shipments[0].depart_in,"Zero-length adjacent-depot trips still receive distinct finite loading slots")
 for trip in queue.hub.shipments: FreightFlow.advance(trip,300)
 check(queue.hub.shipments.all(func(trip): return float(trip.age)>=float(trip.total)),"Even shared stationary bays have no permanent waiting cycle")
 # All manufactured cargo uses the same real pickup pipeline, not just boards.
 var goods=game.initial_state()
 goods.buildings.append({"kind":"central_depot","level":2,"position":[44,20]})
 var keys=["wood","boards","dry","furniture","walls","roofs","parts","design","paper","pellets"]
 for key in keys: CentralLogistics.stock(goods,1)[key]=3.5
 for step in 900:
  CentralLogistics.tick(goods,1)
  CentralLogistics.dispatch(goods)
 for key in keys:
  check(absf(float(goods.resources[key])-3.5)<0.00001,"Actual pickup and unloading conserve fractional "+key)
 check(goods.hub.shipments.is_empty(),"The complete mixed-goods fleet returns to its parking bays")
 # Real production now leaves its output at the producer for collection.
 game.state=game.initial_state()
 game.state.city_services.enabled=false
 game.state.reserve=false
 game.state.buildings.append({"kind":"central_depot","level":1,"position":[44,20]})
 game.step(1)
 check(game.state.resources.wood==0 and (float(game.state.hub.outputs.get("0",{}).get("wood",0))>0 or game.state.hub.shipments.size()>0),"Actual worker harvest goes to the collection station or pickup cargo, never teleports into the central warehouse")
 var saved=JSON.parse_string(JSON.stringify(game.snapshot()))
 game.restore(saved)
 game.simulate(180)
 check(int(game.state.hub.next_id)>300000 and UXRules.material_stock(game.state,"boards").stored>0,"The real simulation keeps harvesting, producing and collecting with the central fleet")
 print("CENTRAL LOGISTICS 284: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
