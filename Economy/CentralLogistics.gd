class_name CentralLogistics
extends RefCounted

# Resources belong to the central store; outputs, express stock and road cargo
# have separate ownership. No credit before unloading and no shared-fleet lock.
static func initial() -> Dictionary:
 return {"outputs":{},"express":{},"shipments":[],"next_id":300000,"cursor":0,"key_cursors":{},"supply_cursor":0,"inputs":{},"requests":[],"factory_cursor":0,"receiving":{},"extra_trucks":0,"network_version":0,"waiting":{},"service_cursor":0,"site_last_served":{},"site_sequence":0,"site_class_cursor":0}

static func depot(state: Dictionary) -> int:
 for i in state.buildings.size():
  if state.buildings[i].kind=="central_depot": return i
 return -1

static func active(state: Dictionary) -> bool: return depot(state)>=0

static func stock(state: Dictionary,index: int,express: bool=false) -> Dictionary:
 var group=state.hub.express if express else state.hub.outputs
 var id=str(index)
 if not group.has(id): group[id]={}
 return group[id]

static func capacity(state: Dictionary) -> float:
 var result=500.0
 for b in state.buildings:
  if b.kind=="warehouse": result+=int(b.level)*500
  elif b.kind=="central_depot": result+=int(b.level)*1500
 return result

static func storage_room(state: Dictionary,key: String) -> float:
 # Manual deposits and fresh pickups cannot occupy an already booked shelf.
 return maxf(0,capacity(state)-float(state.resources.get(key,0))-float(state.hub.get("receiving",{}).get(key,0))-incoming(state,depot(state),key))

static func receiving_capacity(state: Dictionary) -> float:
 return maxf(96,fleet_size(state)*pickup_capacity(state,"wood"))

static func output_capacity(state: Dictionary,index: int) -> float:
 if LogisticsDispatch.enabled(state) and TransportCapacity.supported(state,index): return TransportCapacity.buffer(state,index)
 return 64+int(state.buildings[index].level)*8

static func output_room(state: Dictionary,index: int,key: String) -> float:
 return maxf(0,output_capacity(state,index)-float(state.hub.outputs.get(str(index),{}).get(key,0)))

static func pickup_capacity(state: Dictionary,key: String,origin: int=-1,destination: int=-1) -> float:
 var base=12+int(state.vehicle)*2
 if LogisticsDispatch.enabled(state):
  return base*(6 if key=="wood" else 4)*TransportCapacity.load_multiplier(state,origin,destination)
 return base*(4 if key=="wood" else 1)

static func fleet_size(state: Dictionary) -> int:
 var index=depot(state)
 if index<0: return 0
 if LogisticsDispatch.enabled(state):
  return mini(16,TransportCapacity.fleet_base(state)+maxi(0,int(state.hub.get("extra_trucks",0))))
 return mini(6,2+int(state.buildings[index].level))

static func construction_fleet_size(state: Dictionary) -> int:
 return TransportCapacity.fleet_base(state) if LogisticsDispatch.enabled(state) else fleet_size(state)

static func available_trucks(state: Dictionary) -> int:
 var assigned=state.hub.shipments.size()+DeliveryChain.central_busy(state)
 return maxi(0,fleet_size(state)-assigned)

static func collection_busy(state: Dictionary) -> int:
 var count=0
 for trip in state.hub.shipments:
  if trip.target in ["central","express"]: count+=1
 return count

static func factory_busy(state: Dictionary) -> int:
 return DeliveryChain.central_busy(state)+state.hub.shipments.size()-collection_busy(state)

static func urgent_wood(state: Dictionary) -> Dictionary:
 # A busy furniture/board loop must not consume the final truck while the
 # forest has real output and its collection point is filling. An existing
 # wood shuttle fulfils this priority; its empty return owns the same truck.
 var center=depot(state)
 if center<0 or state.buildings[center].get("paused",false): return {}
 if storage_room(state,"wood")<0.25: return {}
 for trip in state.hub.shipments:
  if trip.target=="central" and trip.key=="wood": return {}
 for source in pickup_sources(state):
  if float(source.stock.get("wood",0))<0.25: continue
  if source.has("only") and source.only!="wood": continue
  if source.has("keys") and "wood" not in source.keys: continue
  var limit=64+int(state.buildings[int(source.index)].level)*8
  if source.has("only") and source.only=="wood": limit=DeliveryChain.capacity(state,"station")
  var ready=minf(pickup_capacity(state,"wood"),limit*0.75)
  if float(state.resources.wood)>=12+int(state.vehicle)*2 and float(source.stock.wood)<ready: continue
  if LogisticsRoutes.road_route(state,int(source.index),center).size()>=2: return source
 return {}

static func collection_reserve(state: Dictionary) -> int:
 if not urgent_wood(state).is_empty(): return 1
 return 1 if collection_busy(state)==0 and work_pending(state) else 0

static func work_pending(state: Dictionary) -> bool:
 var center=depot(state)
 if center<0 or state.buildings[center].get("paused",false): return false
 for source in pickup_sources(state):
  for key in source.stock:
   if source.has("only") and key!=source.only: continue
   if source.has("keys") and key not in source.keys: continue
   if float(source.stock[key])<0.25 or storage_room(state,key)<0.25: continue
   if LogisticsRoutes.road_route(state,int(source.index),center).size()>=2: return true
 for job in state.jobs:
  if not job.has("phases") or job.get("paused",false) or int(job.get("workers",0))<=0: continue
  for key in job.materials:
   if float(state.resources.get(key,0))<=0: continue
   var sources=construction_sources(state,job,key)
   if sources.is_empty() or sources[0].kind!="express": continue
   var source=sources[0]
   if float(source.stock.get(key,0))+incoming(state,int(source.index),key)>=96: continue
   if ConstructionRules.phase_need(job,key)-ConstructionRules.incoming(state,int(job.id),key)-float(source.stock.get(key,0))-incoming(state,int(source.index),key)>0: return true
 return false

static func incoming(state: Dictionary,index: int,key: String) -> float:
 var amount=0.0
 for trip in state.hub.shipments:
  if int(trip.destination)==index and trip.key==key and not trip.arrived: amount+=float(trip.amount)
 return amount

static func tick(state: Dictionary,delta: float) -> void:
 # A bounded receiving area lets already loaded/legacy pickups finish unloading
 # even if a manual deposit occupied their reservation. Goods remain at the
 # depot; shelving never credits twice and requires real warehouse capacity.
 for key in state.hub.receiving:
  var amount=minf(float(state.hub.receiving[key]),maxf(0,capacity(state)-float(state.resources.get(key,0))))
  state.hub.receiving[key]-=amount
  state.resources[key]=float(state.resources.get(key,0))+amount
 var completed=[]
 for trip in state.hub.shipments:
  FreightFlow.advance(trip,delta)
  if not trip.arrived and float(trip.age)>=float(trip.travel):
   if trip.target=="central":
    var shelved=minf(float(trip.amount),maxf(0,capacity(state)-float(state.resources.get(trip.key,0))))
    var staged=float(trip.amount)-shelved
    if float(state.hub.receiving.get(trip.key,0))+staged>receiving_capacity(state)+0.00001:
     trip.age=float(trip.travel)
     continue
    state.resources[trip.key]=float(state.resources.get(trip.key,0))+shelved
    if staged>0: state.hub.receiving[trip.key]=float(state.hub.receiving.get(trip.key,0))+staged
   else:
    var recovered=trip.target=="factory" and not FactorySupply.requirements(state,int(trip.destination)).has(trip.key)
    var destination=stock(state,int(trip.destination)) if recovered else FactorySupply.stock(state,int(trip.destination)) if trip.target=="factory" else stock(state,int(trip.destination),true)
    var limit=maxf(64+int(state.buildings[int(trip.destination)].level)*8,float(destination.get(trip.key,0))+float(trip.amount)) if recovered else FactorySupply.capacity(state,int(trip.destination)) if trip.target=="factory" else DepotNetwork.capacity(state,int(trip.destination))
    if float(destination.get(trip.key,0))+float(trip.amount)>limit+0.00001:
     trip.age=float(trip.travel)
     continue
    destination[trip.key]=float(destination.get(trip.key,0))+float(trip.amount)
   trip.arrived=true
  if trip.arrived and float(trip.age)>=float(trip.total): completed.append(trip)
 for trip in completed: state.hub.shipments.erase(trip)

static func source_ids(group: Dictionary) -> Array:
 # JSON serializers may sort dictionary keys. A saved round-robin cursor must
 # refer to the same producer order before and after loading (2 precedes 10).
 var ids=group.keys()
 ids.sort_custom(func(a,b): return int(a)<int(b))
 return ids

static func pickup_sources(state: Dictionary) -> Array:
 var result=[]
 for id in source_ids(state.hub.outputs):
  var index=int(id)
  if index>=0 and index<state.buildings.size(): result.append({"index":index,"stock":state.hub.outputs[id],"kind":state.buildings[index].kind,"owner":"output"})
 for id in source_ids(state.stone.sites):
  if state.buildings[int(id)].kind=="quarry":
   if LogisticsDispatch.enabled(state):
    result.append({"index":int(id),"stock":state.stone.sites[id].stock,"kind":"quarry","only":"rock","owner":"mineral"})
    continue
   for order in state.hub.requests:
    if order.key=="rock" and float(order.remaining)>0:
     result.append({"index":int(id),"stock":state.stone.sites[id].stock,"kind":"quarry","only":"rock","owner":"mineral"})
     break
 if state.delivery.active:
  for entry in [["station","wood"],["sawmill","boards"],["furniture","furniture"]]:
   var index=int(state.delivery.nodes.get(entry[0],-1))
   if index>=0: result.append({"index":index,"stock":state.delivery.buffers[entry[0]],"kind":entry[0],"only":entry[1],"owner":"line"})
 for id in source_ids(state.hub.inputs):
  if DeliveryChain.owns(state,int(id)) and not LogisticsDispatch.enabled(state):
   result.append({"index":int(id),"stock":state.hub.inputs[id],"kind":state.buildings[int(id)].kind})
 for id in source_ids(state.stone.sites):
  var index=int(id)
  if state.buildings[index].kind=="stoneworks": result.append({"index":index,"stock":state.stone.sites[id].stock,"kind":"stoneworks","keys":["stone","gravel"],"owner":"mineral"})
 return result

static func launch(state: Dictionary,origin: int,destination: int,key: String,amount: float,target: String,source_stock: Dictionary) -> bool:
 var route=LogisticsRoutes.road_route(state,origin,destination)
 if route.size()<2 or amount<=0: return false
 var drive=maxf(2,LogisticsRoutes.length(route)/(10+int(state.vehicle)))
 var handling=TransportCapacity.handling_seconds(state,origin,destination) if LogisticsDispatch.enabled(state) else 6.0
 var trip={"id":state.hub.next_id,"source":state.buildings[origin].kind,"origin":origin,"destination":destination,"target":target,"fleet":"central","key":key,"amount":amount,"mode":"truck","path":route,"age":0.0,"load":handling,"drive":drive,"unload":handling,"travel":drive+handling*2,"total":drive*2+handling*2+2,"arrived":false}
 source_stock[key]=float(source_stock.get(key,0))-amount
 FreightFlow.enqueue(state,state.hub.shipments,trip)
 state.hub.next_id+=1
 return true

static func construction_sources(state: Dictionary,job: Dictionary,key: String) -> Array:
 if LogisticsDispatch.enabled(state): return DepotNetwork.construction_sources(state,job,key)
 var center=depot(state)
 if center<0 or state.buildings[center].get("paused",false): return []
 var position=ConstructionRules.job_position(state,job)
 var direct=LogisticsRoutes.road_to_point(state,center,position)
 if direct.size()<2: return []
 var best=-1
 var distance=LogisticsRoutes.length(direct)
 var nearest=INF
 if distance>80:
  for i in state.buildings.size():
   if state.buildings[i].kind!="express" or state.buildings[i].get("paused",false): continue
   if LogisticsRoutes.road_route(state,center,i).size()<2: continue
   var route=LogisticsRoutes.road_to_point(state,i,position)
   if route.size()<2: continue
   var length=LogisticsRoutes.length(route)
   if length<distance*0.8 and length<nearest:
    nearest=length
    best=i
 if best>=0: return [{"kind":"express","index":best,"stock":state.hub.express.get(str(best),{})}]
 return [{"kind":"central_depot","index":center,"stock":state.resources}]

static func dispatch(state: Dictionary) -> void:
 if LogisticsDispatch.enabled(state):
  LogisticsDispatch.dispatch(state)
  return
 var center=depot(state)
 if center<0 or state.buildings[center].get("paused",false): return
 var free=available_trucks(state)
 if free<=0: return
 # Symmetric to plant dispatch: keep a factory delivery in service while
 # collections are busy, without allocating an extra truck or holding a mutex.
 if factory_busy(state)==0 and (DeliveryChain.supply_pending(state) or FactorySupply.pending(state)): free=maxi(0,free-1)
 if free<=0: return
 var urgent=urgent_wood(state)
 if not urgent.is_empty():
  var amount=minf(float(urgent.stock.wood),minf(pickup_capacity(state,"wood"),storage_room(state,"wood")))
  if launch(state,int(urgent.index),center,"wood",amount,"central",urgent.stock): free-=1
 # Long-distance replenishment has priority, but cannot consume pickup capacity.
 var express_budget=maxi(1,fleet_size(state)/2)
 for job in state.jobs:
  if not job.has("phases") or job.get("paused",false) or int(job.get("workers",0))<=0: continue
  for key in job.materials:
   if free<=0 or express_budget<=0: break
   if ConstructionRules.phase_need(job,key)-ConstructionRules.incoming(state,int(job.id),key)<=0: continue
   var sources=construction_sources(state,job,key)
   if sources.is_empty() or sources[0].kind!="express": continue
   var source=sources[0]
   var needed=maxf(0,ConstructionRules.phase_need(job,key)-ConstructionRules.incoming(state,int(job.id),key)-float(source.stock.get(key,0))-incoming(state,int(source.index),key))
   var room=maxf(0,96-float(source.stock.get(key,0))-incoming(state,int(source.index),key))
   var amount=minf(room,minf(needed,minf(float(state.resources.get(key,0)),12+int(state.vehicle)*2)))
   if amount>0 and launch(state,center,int(source.index),key,amount,"express",state.resources): free-=1; express_budget-=1
 var sources=pickup_sources(state)
 if sources.is_empty(): return
 var cursor=int(state.hub.cursor)%sources.size()
 for offset in sources.size():
  var source=sources[(cursor+offset)%sources.size()]
  var keys=source.stock.keys()
  keys.sort()
  if keys.is_empty(): continue
  var source_id=str(source.index)
  var key_cursor=int(state.hub.key_cursors.get(source_id,0))%keys.size()
  for key_offset in keys.size():
   var key=keys[(key_cursor+key_offset)%keys.size()]
   if source.has("only") and key!=source.only: continue
   if source.has("keys") and key not in source.keys: continue
   var amount=minf(float(source.stock[key]),minf(pickup_capacity(state,key),maxf(0,storage_room(state,key))))
   if amount<0.25 or free<=0: continue
   if launch(state,int(source.index),center,key,amount,"central",source.stock):
    free-=1
    state.hub.key_cursors[source_id]=(key_cursor+key_offset+1)%keys.size()
    state.hub.cursor=(cursor+offset+1)%sources.size()
    # Move past the producer that actually received a truck, including when
    # earlier candidates were empty. One assignment per source in this round.
    break

static func target_name(state: Dictionary,trip: Dictionary) -> String:
 return UXRules.factory_name(state,int(trip.destination)) if trip.target in ["central","express","factory"] else ""

static func recall_express(state: Dictionary,index: int) -> float:
 var center=depot(state)
 if center<0 or state.buildings[index].kind!="express": return 0
 if state.buildings[center].get("paused",false): return 0
 var available=available_trucks(state)
 var result=0.0
 var regional=stock(state,index,true)
 for key in regional:
  if available<=0: break
  var amount=minf(float(regional[key]),minf(12+int(state.vehicle)*2,storage_room(state,key)))
  if amount>0 and launch(state,index,center,key,amount,"central",regional): available-=1; result+=amount
 return result
