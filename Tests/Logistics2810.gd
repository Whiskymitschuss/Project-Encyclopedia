extends SceneTree

var game
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func company() -> Dictionary:
 game.state=game.initial_state()
 var s=game.state
 s.workers=0
 s.trucks=0
 s.vehicle=3
 s.builders=2
 s.company_xp=600
 s.reserve=false
 s.auto_export=false
 s.city_services.enabled=false
 for b in s.buildings: b.paused=true
 s.buildings[3].paused=false
 s.buildings.append({"kind":"central_depot","level":1,"paused":false,"position":[44,20]})
 s.buildings.append({"kind":"express","level":1,"paused":false,"position":[-44,116]})
 return s
func producer(s: Dictionary,kind: String,at: Vector2=Vector2(-44,20)) -> int:
 s.buildings.append({"kind":kind,"level":4,"paused":true,"position":[at.x,at.y]})
 return s.buildings.size()-1
func site(s: Dictionary,id: int,key: String,amount: float) -> Dictionary:
 var job={"id":id,"type":"home","kind":"house","plot":1,"position":[-44,148],"total":70.0,"left":70.0,"materials":{key:amount},"delivered":{}}
 ConstructionRules.attach(job)
 job.phase=5 if key=="dry" else 4 if key=="roofs" else 3
 s.jobs.append(job)
 return job
func total(s: Dictionary,key: String,receipts: Array=[]) -> float:
 var stock=UXRules.material_stock(s,key)
 var amount=float(stock.stored)+float(stock.transit)
 for job in receipts: amount+=float(job.delivered.get(key,0))
 return amount
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
 var expected={}
 var producers=[]
 for kind in Catalog.RECIPES:
  var index=producer(s,kind,Vector2(-44+(producers.size()%3)*24,-12+floori(producers.size()/3.0)*32))
  producers.append(index)
  for key in Catalog.RECIPES[kind].out:
   if key=="sawdust": continue
   CentralLogistics.stock(s,index)[key]=96.0
   expected[key]=float(expected.get(key,0))+96
 var quarry=producer(s,"quarry",Vector2(-44,84))
 var stoneworks=producer(s,"stoneworks",Vector2(-20,84))
 StoneIndustry.synchronize(s)
 StoneIndustry.site(s,quarry).stock.rock=24
 StoneIndustry.site(s,stoneworks).stock.stone=24
 StoneIndustry.site(s,stoneworks).stock.gravel=24
 expected.rock=24; expected.stone=24; expected.gravel=24
 var first_pickup={}
 var peak=0
 for second in 1800:
  game.step(1)
  peak=maxi(peak,s.hub.shipments.size())
  for trip in s.hub.shipments:
   if trip.target in ["central","express"]: first_pickup.get_or_add(str(int(trip.origin)),second)
 for index in producers:
  check(first_pickup.has(str(index)),"Every factory family receives an actual automatic pickup: "+s.buildings[index].kind)
  check(CentralLogistics.stock(s,index).values().all(func(value): return float(value)<0.00001),"Full output is completely collected from "+s.buildings[index].kind)
 check(first_pickup.has(str(quarry)) and first_pickup.has(str(stoneworks)),"Quarry rock and both mineral outputs are collected without a manual supply request")
 for key in expected: check(absf(total(s,key)-float(expected[key]))<0.00001,"Mixed collection and warehouse unloading conserve "+key)
 check(peak<=CentralLogistics.fleet_size(s),"All factories share a finite real depot fleet, including regional pickup capacity")
 # A nearby express directly receives a producer's output, then a separate
 # construction fleet delivers it. There is no bypass from factory to site.
 s=company()
 var kiln=producer(s,"kiln",Vector2(-44,84))
 CentralLogistics.stock(s,kiln).dry=12
 var job=site(s,901,"dry",6)
 game.step(1)
 var collection=s.hub.shipments.filter(func(trip): return int(trip.origin)==kiln)
 check(collection.size()==1 and collection[0].target=="express" and int(collection[0].destination)==6,"Nearest express receives a real automatic factory pickup")
 check(float(s.hub.express.get("6",{}).get("dry",0))==0 and float(job.delivered.get("dry",0))==0,"Dispatch cannot credit express stock or a construction receipt before unloading")
 check(s.crew.missions.size()==1 and float(job.left)==70 and job.crew_present==0,"A real cabin-to-site Sprinter starts, and construction cannot work before the crew arrives")
 var used_express=false
 var surplus_return=false
 for second in 600:
  game.step(1)
  for trip in s.construction_shipments:
   if int(trip.job)==901 and int(trip.origin)==6: used_express=true
  for trip in s.hub.shipments:
   if int(trip.origin)==6 and trip.target=="central" and trip.key=="dry": surplus_return=true
 check(used_express and float(job.delivered.get("dry",0))==6 and not job in s.jobs,"Express → construction is a real separate freight movement and arrived staff finish the work")
 check(absf(total(s,"dry",[job])-12)<0.00001 and (s.resources.dry==0 or surplus_return),"The regional delivery and any real surplus return conserve goods without a central teleport")
 check(s.crew.missions.is_empty() and CrewTransport.reserved(s)==0 and game.free_builders()==2,"The finished team is picked up and driven home before becoming available again")
 # Other depots keep working while central operations are explicitly paused.
 s=company()
 s.buildings[5].paused=true
 kiln=producer(s,"kiln",Vector2(-44,84))
 CentralLogistics.stock(s,kiln).dry=12
 job=site(s,902,"dry",6)
 for second in 600: game.step(1)
 check(float(job.delivered.get("dry",0))==6 and not job in s.jobs,"A paused central warehouse does not disable a connected regional factory/express/site chain")
 # A truly full network cannot erase goods to disguise a throughput problem.
 s=company()
 kiln=producer(s,"kiln")
 CentralLogistics.stock(s,kiln).dry=96
 s.resources.dry=CentralLogistics.capacity(s)
 CentralLogistics.stock(s,6,true).dry=DepotNetwork.capacity(s,6)
 var before=total(s,"dry")
 for second in 60: game.step(1)
 check(s.hub.shipments.is_empty() and total(s,"dry")==before,"A full central and regional warehouse leave owned output intact and create no impossible pickup")
 check(LogisticsDispatch.collection_status(s,kiln).contains("Lager voll"),"A genuine full-network limit has an explicit actionable collection reason")
 s.hub.express["6"].dry=60
 before=total(s,"dry")
 for second in 180: game.step(1)
 check(float(s.hub.express["6"].dry)>60 and absf(total(s,"dry")-before)<0.00001,"Freeing regional shelf space automatically resumes collection without manual factory commands")
 # All plants, not only an opt-in workshop, receive local inputs by road.
 s=company()
 var joinery=producer(s,"joinery")
 s.buildings[joinery].paused=false
 s.resources.boards=80; s.resources.dry=80
 game.step(1)
 check(FactorySupply.managed(s,joinery) and float(game.flow.get("building:%s"%joinery,0))==0,"Every workshop enrolls automatically with an empty input rack; first-tick production cannot consume remote warehouse stock")
 check(s.hub.shipments.any(func(trip): return trip.target=="factory" and int(trip.destination)==joinery),"Automatic input shortage sends an actual depot truck without a request tap")
 for second in 600: game.step(1)
 check(total(s,"parts")>0,"An automatically supplied joinery really manufactures and collects building parts")
 # Migration does not strand raw inputs when a legacy workshop joins the line.
 s=company()
 s.buildings[1].paused=false; s.buildings[0].paused=false; s.buildings[4].paused=false
 var furniture=producer(s,"furniture")
 s.buildings[furniture].paused=false
 DeliveryChain.start(s)
 s.hub.inputs[str(furniture)]={"dry":9.5}
 LogisticsDispatch.synchronize(s)
 check(not s.hub.inputs.has(str(furniture)) and CentralLogistics.stock(s,furniture).dry==9.5 and s.resources.dry==0,"Reassigned old input stock stays physically on its factory collection rack, with no loss or central teleport")
 # Save continuation includes scheduling ages, local inventories and passengers.
 s=company()
 kiln=producer(s,"kiln",Vector2(-44,84))
 CentralLogistics.stock(s,kiln).dry=12
 job=site(s,903,"dry",6)
 for second in 10: game.step(1)
 var saved=JSON.parse_string(JSON.stringify(s,"",true,true))
 game.simulate(240)
 var continued=game.state.duplicate(true)
 game.restore(saved)
 game.simulate(240)
 check(equivalent(continued,game.state),"Full-precision JSON resumes freight, fair dispatch and real crew commutes identically")
 # One current bill is protected once across split inventories, not in full at
 # every warehouse. Surplus remains usable by downstream production.
 s=company()
 LogisticsDispatch.synchronize(s)
 s.resources.boards=3
 CentralLogistics.stock(s,6,true).boards=3
 job=site(s,904,"boards",8)
 job.phase=2
 var available=0.0
 for source in DepotNetwork.supply_sources(s,Vector3(-44,0,84),"boards"): available+=float(source.available)
 check(absf(available-2)<0.00001,"A four-board construction bill reserves four of six split-depot boards once, leaving two real boards usable")
 s.jobs=[]
 s.plan={"kind":"house","plot":1,"auto":false}
 s.resources.furniture=3
 CentralLogistics.stock(s,6,true).furniture=3
 available=0
 for source in DepotNetwork.supply_sources(s,Vector3(-44,0,84),"furniture"): available+=float(source.available)
 check(absf(available-4)<0.00001,"An explicit future building plan keeps its two furniture units while leaving the actual surplus usable")
 # Separate factory exit racks have separate room; one shared output-demand
 # denominator must not throttle an unrelated second kiln.
 s=company()
 var a=producer(s,"kiln")
 var b=producer(s,"kiln",Vector2(-20,20))
 s.buildings[a].paused=false; s.buildings[b].paused=false
 LogisticsDispatch.synchronize(s)
 s.hub.inputs[str(a)]={"boards":4.0}; s.hub.inputs[str(b)]={"boards":4.0}
 CentralLogistics.stock(s,a).dry=94
 game.step(1)
 check(absf(float(game.flow.get("building:%s"%a,0))-1.68)<0.00001 and absf(float(game.flow.get("building:%s"%b,0))-1.68)<0.00001,"Each kiln uses its own real output space and accepted local inputs")
 # Available materials cannot make staff teleport to an unreachable site.
 s=company()
 job=site(s,905,"dry",0)
 job.position=[900,900]
 for second in 180: game.step(1)
 check(job.left==70 and s.crew.missions.is_empty() and CrewTransport.onsite(s,job)==0,"An unreachable cabin/site route cannot create a commute or award any construction work")
 check(CrewTransport.status(s,job).contains("Straßenanschluss"),"A missing staff road is explained independently from material supply")
 # Unassigning an arrived crew does not immediately free people still waiting
 # at that site. It takes a real pickup and return to the cabin.
 s=company()
 job=site(s,906,"dry",0)
 for second in 300:
  game.step(1)
  if CrewTransport.onsite(s,job)>0: break
 job.paused=true
 check(game.assign_builders(906,0) and game.free_builders()==1,"Unassigned staff still on site remain reserved until their actual return")
 check(game.assign_builders(906,1),"The same arrived people can be reassigned to their own site without inventing a second team")
 game.assign_builders(906,0)
 var left=float(job.left)
 for second in 600: game.step(1)
 check(game.free_builders()==2 and CrewTransport.onsite(s,job)==0 and s.crew.missions.is_empty() and job.left==left,"The paused unassigned team is picked up, driven home and released without additional work")
 # Final regional goods must not be stranded when there is no nearby site.
 s=company()
 var design=producer(s,"design",Vector2(-44,84))
 CentralLogistics.stock(s,design).design=9.5
 var regional_pickup=false
 var return_pickup=false
 for second in 600:
  game.step(1)
  for trip in s.hub.shipments:
   if trip.key!="design": continue
   if int(trip.origin)==design and trip.target=="express": regional_pickup=true
   if int(trip.origin)==6 and trip.target=="central": return_pickup=true
 check(regional_pickup and return_pickup and absf(s.resources.design-9.5)<0.00001,"Unsold regional final goods take an actual express-to-central consolidation trip")
 check(absf(total(s,"design")-9.5)<0.00001,"Regional surplus consolidation conserves fractional final goods")
 # Closing the old line while a new-network input truck is on the road keeps
 # that parcel recoverable at the actual destination after the recipe changes.
 s=company()
 for index in [0,1,4]: s.buildings[index].paused=false
 furniture=producer(s,"furniture")
 s.buildings[furniture].paused=false
 DeliveryChain.start(s)
 LogisticsDispatch.synchronize(s)
 s.resources.furniture=20
 check(CentralLogistics.launch(s,5,4,"furniture",6,"factory",s.resources) and game.stop_delivery(),"The legacy line can close without canceling a real network cargo already bound for its shop")
 for second in 600: game.step(1)
 check(absf(total(s,"furniture")-20)<0.00001 and absf(s.resources.furniture-20)<0.00001,"The obsolete shop input is unloaded to its real collection rack and physically recovered, never lost with the closed buffer")
 # A large or prioritised site may not allocate every truck before a small
 # neighbour gets its first real delivery.
 for priority in [false,true]:
  s=company()
  LogisticsDispatch.synchronize(s)
  var large=site(s,920,"boards",80)
  large.phase=3
  large.priority=priority
  var small=site(s,921,"boards",8)
  small.phase=3
  CentralLogistics.stock(s,6,true).boards=80
  before=total(s,"boards",[large,small])
  ConstructionRules.dispatch(s)
  check(s.construction_shipments.any(func(trip): return int(trip.job)==920) and s.construction_shipments.any(func(trip): return int(trip.job)==921),"A small paid site gets a real truck beside a large site in the first dispatch wave; priority=%s" % priority)
  check(s.construction_shipments.size()<=CentralLogistics.fleet_size(s) and absf(total(s,"boards",[large,small])-before)<0.00001,"Fair site dispatch preserves the dedicated fleet and every reserved board; priority=%s" % priority)
 # Finished-product availability cannot count one regional shelf twice, or
 # count parcels already committed to another factory as construction stock.
 s=company()
 LogisticsDispatch.synchronize(s)
 job=site(s,930,"furniture",6)
 job.phase=5
 CentralLogistics.stock(s,6,true).furniture=3
 check(ConstructionRules.processing_required(s,"boards"),"Three regional furniture units cannot satisfy a six-unit site bill through duplicate depot counting")
 s.resources.furniture=3
 var designer=producer(s,"design")
 CentralLogistics.launch(s,6,designer,"furniture",3,"factory",CentralLogistics.stock(s,6,true))
 check(ConstructionRules.processing_required(s,"boards"),"Furniture committed to a design factory is not falsely available for the waiting construction site")
 CentralLogistics.stock(s,6,true).boards=3
 var sources=UXRules.material_sources(s,"boards").filter(func(source): return int(source.index)==6 and float(source.amount)>0)
 check(sources.size()==1,"Material help presents a regional inventory once, consistently with its real ownership")
 s=company()
 LogisticsDispatch.synchronize(s)
 job=site(s,940,"boards",8)
 job.requested=false
 job.phase=3
 CentralLogistics.stock(s,6,true).boards=8
 check(ConstructionRules.dispatch(s)>0 and s.construction_shipments.any(func(trip): return int(trip.job)==940),"A paid active legacy site no longer stalls behind an obsolete manual-request flag in the automatic network")
 print("LOGISTICS 2810 FIRST PICKUPS: ",JSON.stringify(first_pickup))
 print("LOGISTICS 2810: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
