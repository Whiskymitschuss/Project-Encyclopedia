class_name LogisticsDispatch
extends RefCounted

const CLASSES=["pickup","supply","regional"]
const BATCH_WAIT=18.0

static func enabled(state: Dictionary) -> bool:
 return CentralLogistics.active(state) and int(state.hub.get("network_version",0))>=1

static func synchronize(state: Dictionary) -> void:
 if not CentralLogistics.active(state): return
 state.hub.network_version=1
 state.hub.get_or_add("waiting",{})
 state.hub.get_or_add("service_cursor",0)
 # Reassigned legacy line inputs remain at their actual workplace. Put those
 # recoverable parcels on its collection rack, never into the central stock.
 for id in CentralLogistics.source_ids(state.hub.inputs):
  if not DeliveryChain.owns(state,int(id)): continue
  var recoverable=CentralLogistics.stock(state,int(id))
  for key in state.hub.inputs[id]: recoverable[key]=float(recoverable.get(key,0))+float(state.hub.inputs[id][key])
  state.hub.inputs.erase(id)
 # Existing warehouse contents stay where they are. Empty local inputs enroll
 # every workshop in automatic, physically transported replenishment.
 for i in state.buildings.size():
  if not Catalog.RECIPES.has(state.buildings[i].kind) and state.buildings[i].kind!="stoneworks": continue
  if not FactorySupply.requirements(state,i).is_empty() and not DeliveryChain.owns(state,i): state.hub.inputs.get_or_add(str(i),{})

static func source_limit(state: Dictionary,source: Dictionary,key: String) -> float:
 if str(source.get("owner",""))=="line": return DeliveryChain.capacity(state,str(source.kind))
 if str(source.get("owner",""))=="mineral": return StoneIndustry.capacity(state,int(source.index))
 return CentralLogistics.output_capacity(state,int(source.index))

static func age(state: Dictionary,id: String) -> float:
 return maxf(0,float(state.elapsed)-float(state.hub.get("waiting",{}).get(id,state.elapsed)))

static func pickup_tasks(state: Dictionary) -> Array:
 var result=[]
 for source in CentralLogistics.pickup_sources(state):
  var keys=source.stock.keys()
  keys.sort()
  for key in keys:
   if not Catalog.RESOURCES.has(key) or key=="sawdust": continue
   if source.has("only") and key!=source.only: continue
   if source.has("keys") and key not in source.keys: continue
   var quantity=float(source.stock[key])
   if quantity<0.25: continue
   var booked=false
   for trip in state.hub.shipments:
    if trip.target in ["central","express"] and int(trip.origin)==int(source.index) and trip.key==key: booked=true; break
   if booked: continue
   var depot=DepotNetwork.pickup(state,int(source.index),key)
   if depot.is_empty(): continue
   var id="p:%06d:%s:%s" % [int(source.index),str(source.get("owner","output")),key]
   var limit=source_limit(state,source,key)
   var capacity=CentralLogistics.pickup_capacity(state,key,int(source.index),int(depot.index))
   var need=DepotNetwork.current_need(state,key)
   var score=age(state,id)+minf(1,quantity/maxf(1,limit))*24+(24 if need>0 else 0)
   # Empty wood shelves get prompt service; this is a bonus, never an absolute
   # branch that can starve the rest of the producer queue forever.
   if key=="wood" and float(state.resources.wood)<capacity*0.5: score+=30
   result.append({"id":id,"class":"pickup","source":source,"origin":int(source.index),"destination":int(depot.index),"key":key,"amount":minf(quantity,minf(capacity,float(depot.room))),"stock":source.stock,"target":"central" if state.buildings[int(depot.index)].kind=="central_depot" else "express","score":score,"ready":quantity>=minf(capacity,limit*0.5) or need>0 or age(state,id)>=BATCH_WAIT})
 return result

static func supply_tasks(state: Dictionary,preferred: int=-1) -> Array:
 var result=[]
 for i in state.buildings.size():
  var needs=FactorySupply.requirements(state,i)
  if needs.is_empty() or state.buildings[i].get("paused",false) or (DeliveryChain.owns(state,i) and state.delivery.paused): continue
  for key in needs:
   if FactorySupply.incoming(state,i,key)>0.00001: continue
   var available=float(FactorySupply.stock(state,i).get(key,0))+FactorySupply.incoming(state,i,key)
   var capacity=FactorySupply.capacity(state,i)
   if capacity-available<0.25 or (i!=preferred and FactorySupply.queued(state,i,key)<=0 and available>=maxf(float(needs[key])*2,capacity*0.5)): continue
   var sources=DepotNetwork.supply_sources(state,LogisticsRoutes.building_position(state,i),key)
   if sources.is_empty(): continue
   var source=sources[0]
   var id="s:%06d:%s" % [i,key]
   var score=age(state,id)+maxf(0,1-available/capacity)*24
   for product in outputs(state,i):
    if DepotNetwork.current_need(state,product)>0: score+=20; break
   result.append({"id":id,"class":"supply","origin":int(source.index),"destination":i,"key":key,"amount":minf(capacity-available,minf(CentralLogistics.pickup_capacity(state,key,int(source.index),i),float(source.available))),"stock":source.stock,"target":"factory","score":score,"ready":true})
 return result

static func regional_tasks(state: Dictionary) -> Array:
 var demand={}
 for job in state.jobs:
  if not job.has("phases") or job.get("paused",false) or int(job.get("workers",0))<=0: continue
  for key in job.materials:
   var need=maxf(0,ConstructionRules.phase_need(job,key)-ConstructionRules.incoming(state,int(job.id),key))
   if need<=0: continue
   var sources=DepotNetwork.construction_sources(state,job,key)
   if sources.is_empty() or sources[0].kind!="express": continue
   var id="r:%06d:%s" % [int(sources[0].index),key]
   if not demand.has(id): demand[id]={"destination":int(sources[0].index),"key":key,"need":0.0}
   demand[id].need+=need
 var result=[]
 var ids=demand.keys()
 ids.sort()
 for id in ids:
  var d=demand[id]
  var index=int(d.destination)
  var key=str(d.key)
  var need=maxf(0,float(d.need)-DepotNetwork.quantity(state,index,key)-CentralLogistics.incoming(state,index,key))
  if need<=0: continue
  var sources=DepotNetwork.supply_sources(state,LogisticsRoutes.building_position(state,index),key,false,index)
  if sources.is_empty(): continue
  var source=sources[0]
  result.append({"id":id,"class":"regional","origin":int(source.index),"destination":index,"key":key,"amount":minf(need,minf(DepotNetwork.room(state,index,key),minf(CentralLogistics.pickup_capacity(state,key),float(source.available)))),"stock":source.stock,"target":"express","score":age(state,id)+24,"ready":true})
 # Consolidate regional surplus by real return freight. Otherwise final goods
 # can fill an express forever while exports and orders see an empty center.
 var center=CentralLogistics.depot(state)
 if center<0 or state.buildings[center].get("paused",false): return result
 for index in DepotNetwork.depots(state):
  if state.buildings[int(index)].kind!="express": continue
  var regional=state.hub.express.get(str(index),{})
  var keys=regional.keys()
  keys.sort()
  for key in keys:
   if not Catalog.RESOURCES.has(key): continue
   var quantity=float(regional[key])
   if quantity<0.25: continue
   var held=regional_reserve(state,int(index),key)
   var excess=maxf(0,quantity-held)
   var room=CentralLogistics.storage_room(state,key)
   if excess<0.25 or room<0.25: continue
   if state.hub.shipments.any(func(trip): return int(trip.origin)==int(index) and trip.key==key and trip.target=="central"): continue
   if LogisticsRoutes.road_route(state,int(index),center).size()<2: continue
   var id="b:%06d:%s" % [int(index),key]
   var batch=CentralLogistics.pickup_capacity(state,key)
   result.append({"id":id,"class":"regional","origin":int(index),"destination":center,"key":key,"amount":minf(excess,minf(room,batch)),"stock":regional,"target":"central","score":age(state,id)+minf(1,quantity/DepotNetwork.capacity(state,int(index)))*16,"ready":excess>=batch or age(state,id)>=BATCH_WAIT})
 return result

static func regional_reserve(state: Dictionary,index: int,key: String) -> float:
 var amount=0.0
 for job in state.jobs:
  if job.get("paused",false) or int(job.get("workers",0))<=0: continue
  var sources=DepotNetwork.construction_sources(state,job,key)
  if not sources.is_empty() and int(sources[0].index)==index:
   amount+=maxf(0,ConstructionRules.remaining(job,key)-ConstructionRules.incoming(state,int(job.id),key))
 for i in state.buildings.size():
  if state.buildings[i].get("paused",false) or (DeliveryChain.owns(state,i) and state.delivery.paused): continue
  var needs=FactorySupply.requirements(state,i)
  if not needs.has(key): continue
  var best=-1
  var distance=INF
  for depot in DepotNetwork.depots(state):
   var path=LogisticsRoutes.road_route(state,int(depot),i)
   if path.size()<2: continue
   var length=LogisticsRoutes.length(path)
   if length<distance: distance=length; best=int(depot)
  if best==index: amount+=maxf(0,float(needs[key])*2-float(FactorySupply.stock(state,i).get(key,0))-FactorySupply.incoming(state,i,key))
 return amount

static func outputs(state: Dictionary,index: int) -> Array:
 var kind=str(state.buildings[index].kind)
 if kind=="station": return ["wood"]
 if kind=="quarry": return ["rock"]
 if kind=="stoneworks": return ["stone","gravel"]
 if DeliveryChain.owns(state,index): return ["boards"] if kind=="sawmill" else ["furniture"] if kind=="furniture" else []
 return Catalog.RECIPES.get(kind,{}).get("out",{}).keys().filter(func(key): return key!="sawdust")

static func tasks(state: Dictionary) -> Array:
 return pickup_tasks(state)+supply_tasks(state)+regional_tasks(state)

static func dispatch(state: Dictionary) -> void:
 if not enabled(state) or CentralLogistics.available_trucks(state)<=0: return
 var candidates=tasks(state)
 for task in candidates: state.hub.waiting.get_or_add(task.id,float(state.elapsed))
 var present={}
 for task in candidates: present[task.id]=true
 for id in state.hub.waiting.keys():
  if not present.has(id): state.hub.waiting.erase(id)
 # One circulating forestry shuttle sustains the raw-material source. It can
 # never consume a second slot; all other trucks alternate the general queue.
 var forest_busy=false
 for trip in state.hub.shipments:
  if trip.key=="wood" and trip.target in ["central","express"]: forest_busy=true; break
 if not forest_busy:
  var forest=candidates.filter(func(task): return task["class"]=="pickup" and task.key=="wood" and task.ready)
  if not forest.is_empty():
   forest.sort_custom(func(a,b): return float(a.score)>float(b.score) if not is_equal_approx(float(a.score),float(b.score)) else str(a.id)<str(b.id))
   var task=forest[0]
   if CentralLogistics.launch(state,int(task.origin),int(task.destination),"wood",float(task.amount),str(task.target),task.stock):
    state.hub.waiting.erase(task.id)
    if CentralLogistics.available_trucks(state)>0: candidates=tasks(state)
 # Recompute real capacity after every withdrawal; no task list can reserve
 # stale warehouse stock or an express shelf twice in the same tick.
 while CentralLogistics.available_trucks(state)>0:
  candidates=candidates.filter(func(task): return task.ready and float(task.amount)>=0.25)
  if candidates.is_empty(): break
  var selected={}
  for offset in CLASSES.size():
   var slot=(int(state.hub.service_cursor)+offset)%CLASSES.size()
   var group=candidates.filter(func(task): return task["class"]==CLASSES[slot])
   if group.is_empty(): continue
   group.sort_custom(func(a,b): return float(a.score)>float(b.score) if not is_equal_approx(float(a.score),float(b.score)) else str(a.id)<str(b.id))
   selected=group[0]
   state.hub.service_cursor=(slot+1)%CLASSES.size()
   break
  if selected.is_empty(): break
  if not CentralLogistics.launch(state,int(selected.origin),int(selected.destination),str(selected.key),float(selected.amount),str(selected.target),selected.stock): break
  if selected["class"]=="supply": FactorySupply.fulfilled(state,int(selected.destination),str(selected.key),float(selected.amount))
  state.hub.waiting.erase(selected.id)
  if CentralLogistics.available_trucks(state)>0: candidates=tasks(state)

static func request_supply(state: Dictionary,index: int) -> void:
 if index<0: return
 var candidates=supply_tasks(state,index).filter(func(task): return int(task.destination)==index)
 for task in candidates: state.hub.waiting[task.id]=float(state.elapsed)-60.0
 if candidates.is_empty() or CentralLogistics.available_trucks(state)<=0: return
 var task=candidates[0]
 if CentralLogistics.launch(state,int(task.origin),index,str(task.key),float(task.amount),"factory",task.stock):
  FactorySupply.fulfilled(state,index,str(task.key),float(task.amount))
  state.hub.waiting.erase(task.id)

static func collection_status(state: Dictionary,index: int) -> String:
 var parts=[]
 for source in CentralLogistics.pickup_sources(state):
  if int(source.index)!=index: continue
  for key in source.stock:
   if source.has("only") and key!=source.only: continue
   if source.has("keys") and key not in source.keys: continue
   if key=="sawdust" or float(source.stock[key])<0.25: continue
   var line="%s %s" % [Catalog.number(float(source.stock[key])),Catalog.RESOURCES.get(key,key)]
   var booked=false
   for trip in state.hub.shipments:
    if int(trip.origin)==index and trip.key==key and trip.target in ["central","express"]:
     line+=" · "+FreightFlow.status(trip); booked=true; break
   if not booked:
    var depot=DepotNetwork.pickup(state,index,key)
    if depot.is_empty():
     var connected=false
     for destination in DepotNetwork.depots(state):
      if LogisticsRoutes.road_route(state,index,int(destination)).size()>=2: connected=true; break
     line+=" · Lager voll" if connected else " · Straßenanschluss oder aktives Lager fehlt"
    else: line+=" → "+UXRules.factory_name(state,int(depot.index))+" · "+("wartet auf freien LKW" if CentralLogistics.available_trucks(state)<=0 else "automatische Abholung")
   parts.append(line)
 return "\n".join(parts) if not parts.is_empty() else "Kein Fertigwarenbestand zur Abholung"
