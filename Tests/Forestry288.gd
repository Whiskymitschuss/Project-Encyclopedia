extends SceneTree
var game
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func company() -> Dictionary:
 game.restore(JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/forestry288-company.json")))
 return game.state
func small() -> Dictionary:
 game.state=game.initial_state()
 var s=game.state
 s.workers=17
 s.tool=10
 s.vehicle=3
 s.city_services.enabled=false
 s.buildings[0].level=5
 s.buildings.append({"kind":"furniture","level":3,"position":[-20,-12]})
 s.buildings.append({"kind":"central_depot","level":1,"position":[44,20]})
 DeliveryChain.start(s)
 return s
func total(s: Dictionary,key: String) -> float:
 var stock=UXRules.material_stock(s,key)
 return float(stock.stored)+float(stock.transit)
func equivalent(a: Variant,b: Variant) -> bool:
 if (a is float or a is int) and (b is float or b is int): return absf(float(a)-float(b))<0.00000001
 if a is Dictionary and b is Dictionary:
  if a.size()!=b.size(): return false
  for k in a:
   if not b.has(k) or not equivalent(a[k],b[k]): return false
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
 # Existing collection of finished goods must not waive a needed raw-wood slot.
 var s=small()
 s.resources.boards=50
 CentralLogistics.stock(s,0).wood=104
 CentralLogistics.stock(s,1).boards=18
 CentralLogistics.launch(s,1,6,"boards",18,"central",CentralLogistics.stock(s,1))
 var wood=total(s,"wood")
 check(CentralLogistics.collection_reserve(s)==1,"An occupied board-pickup truck does not count as an emergency raw-wood pickup")
 DeliveryChain.tick(s,1,{},1)
 check(CentralLogistics.available_trucks(s)>=1,"Automatic factory supply leaves a genuine truck for empty central wood stock")
 CentralLogistics.dispatch(s)
 check(s.hub.shipments.any(func(t): return t.key=="wood" and t.target=="central"),"The actual remaining truck loads wood at the collection station")
 check(total(s,"wood")==wood and s.resources.wood==0,"Priority does not teleport cargo, duplicate wood or credit an unarrived pickup")
 check(CentralLogistics.available_trucks(s)==0,"Priority respects the existing central fleet limit")
 check(CentralLogistics.urgent_wood(s).is_empty(),"An existing wood shuttle satisfies emergency priority, including its reserved departure and return")
 for tick in 240: CentralLogistics.tick(s,1)
 check(s.resources.wood>0 and s.hub.shipments.is_empty(),"Priority freight physically unloads and returns without remaining permanently reserved")
 # Manually requested factory supply must leave the same raw-material slot.
 s=small()
 s.resources.boards=60
 CentralLogistics.stock(s,0).wood=104
 CentralLogistics.stock(s,1).boards=18
 CentralLogistics.launch(s,1,6,"boards",18,"central",CentralLogistics.stock(s,1))
 s.buildings.append({"kind":"prefab","level":3,"position":[-44,20]})
 FactorySupply.request(s,7)
 # Immediate user requests may use one truck; following automatic requests
 # must preserve the last collection slot, even with another pickup in flight.
 FactorySupply.maintain(s)
 FactorySupply.dispatch(s)
 check(CentralLogistics.available_trucks(s)>=1,"Repeated automatic requested-plant supply cannot consume the last wood-recovery truck")
 CentralLogistics.dispatch(s)
 check(s.hub.shipments.any(func(t): return t.key=="wood" and t.target=="central"),"Requested works and a busy finished-goods pickup still allow forestry recovery")
 # Resume round-robin after the actual successful producer, not an empty slot.
 s=small()
 s.delivery.active=false
 s.resources.wood=100
 var a=CentralLogistics.stock(s,0)
 a.wood=0
 CentralLogistics.stock(s,1).boards=0
 CentralLogistics.stock(s,5).furniture=54
 CentralLogistics.stock(s,3).boards=18
 CentralLogistics.launch(s,3,6,"boards",9,"central",CentralLogistics.stock(s,3))
 CentralLogistics.launch(s,3,6,"boards",9,"central",CentralLogistics.stock(s,3))
 CentralLogistics.dispatch(s)
 check(s.hub.cursor==0,"The producer cursor advances beyond the actual assignment after skipping three empty producers")
 check(s.hub.shipments[-1].origin==5,"The one free truck loads the first genuinely ready producer")
 s=small()
 CentralLogistics.stock(s,0).wood=104
 s.buildings[0].position=[900,900]
 check(CentralLogistics.urgent_wood(s).is_empty(),"An unreachable forest does not lock a priority slot indefinitely")
 s.buildings[0].position=[-45,-43]
 s.buildings[6].paused=true
 check(CentralLogistics.collection_reserve(s)==0,"Explicitly paused depots never reserve an emergency truck")
 # A large company resembling the screenshot, with twelve homes and many sites.
 s=company()
 var gathered=float(s.gathered)
 var sold=float(s.delivery.sold)
 var max_empty=0
 var empty=0
 var peak=0
 var harvested_after_halfway=0.0
 var construction_before=int(s.next_shipment)
 for tick in 1800:
  game.step(1)
  empty=empty+1 if float(s.resources.wood)<0.001 else 0
  max_empty=maxi(max_empty,empty)
  peak=maxi(peak,s.hub.shipments.size()+DeliveryChain.central_busy(s))
  if tick>=900: harvested_after_halfway+=float(game.flow.harvest)
 check(max_empty<180,"A full forest output and busy mixed logistics cannot leave the central wood stock empty for three minutes")
 check(float(s.gathered)>gathered+100 and harvested_after_halfway>0,"Actual forestry resumes repeatedly in both halves of a thirty-minute advanced-company run")
 check(float(s.delivery.sold)>sold,"Actual factory inputs produce furniture that is delivered and sold")
 check(int(s.next_shipment)>construction_before,"Construction receives real material trips alongside central pickup and plant supply")
 check(peak<=CentralLogistics.fleet_size(s),"The advanced-company run never allocates extra central trucks")
 var saved=JSON.parse_string(JSON.stringify(s,"",true,true))
 game.simulate(300)
 var expected=s.duplicate(true)
 game.restore(saved)
 game.simulate(300)
 check(equivalent(game.state,expected),"Queued freight, fair cursors and production continue identically after full-precision JSON restoration")
 # Large phase bills cannot overbook the limited regional receiving area.
 s=small()
 s.delivery.active=false
 s.buildings.append({"kind":"express","level":1,"position":[-44,116]})
 s.resources.boards=1000
 CentralLogistics.stock(s,7,true).boards=90
 var job={"id":900,"type":"home","kind":"townhall","plot":20,"position":[-44,148],"left":70.0,"total":70.0,"materials":{"boards":800.0},"delivered":{}}
 ConstructionRules.attach(job)
 job.phase=4
 s.jobs=[job]
 var original=total(s,"boards")
 CentralLogistics.dispatch(s)
 var regional=CentralLogistics.stock(s,7,true)
 check(float(regional.boards)+CentralLogistics.incoming(s,7,"boards")<=96.00001,"Regional replenishment reserves its real receiving capacity before dispatch")
 for tick in 300: CentralLogistics.tick(s,1)
 check(s.hub.shipments.is_empty() and regional.boards==96,"A large site bill cannot strand replenishment trucks against an overfilled express")
 check(total(s,"boards")==original,"Capacity-limited replenishment conserves every board")
 print("FORESTRY 288: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
