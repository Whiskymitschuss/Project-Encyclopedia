class_name CentralLogistics
extends RefCounted

# Resources belong to the central store; outputs, express stock and road cargo
# have separate ownership. No credit before unloading and no shared-fleet lock.
static func initial() -> Dictionary:
 return {"outputs":{},"express":{},"shipments":[],"next_id":300000,"cursor":0}

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

static func output_room(state: Dictionary,index: int,key: String) -> float:
 return maxf(0,64+int(state.buildings[index].level)*8-float(state.hub.outputs.get(str(index),{}).get(key,0)))

static func fleet_size(state: Dictionary) -> int:
 var index=depot(state)
 return mini(6,2+int(state.buildings[index].level)) if index>=0 else 0

static func incoming(state: Dictionary,index: int,key: String) -> float:
 var amount=0.0
 for trip in state.hub.shipments:
  if int(trip.destination)==index and trip.key==key and not trip.arrived: amount+=float(trip.amount)
 return amount

static func tick(state: Dictionary,delta: float) -> void:
 var completed=[]
 for trip in state.hub.shipments:
  FreightFlow.advance(trip,delta)
  if not trip.arrived and float(trip.age)>=float(trip.travel):
   var destination=state.resources if trip.target=="central" else stock(state,int(trip.destination),true)
   var limit=capacity(state) if trip.target=="central" else 96.0
   if float(destination.get(trip.key,0))+float(trip.amount)>limit+0.00001:
    trip.age=float(trip.travel)
    continue
   destination[trip.key]=float(destination.get(trip.key,0))+float(trip.amount)
   trip.arrived=true
  if trip.arrived and float(trip.age)>=float(trip.total): completed.append(trip)
 for trip in completed: state.hub.shipments.erase(trip)

static func pickup_sources(state: Dictionary) -> Array:
 var result=[]
 for id in state.hub.outputs:
  var index=int(id)
  if index>=0 and index<state.buildings.size(): result.append({"index":index,"stock":state.hub.outputs[id],"kind":state.buildings[index].kind})
 if state.delivery.active:
  for entry in [["station","wood"],["sawmill","boards"],["furniture","furniture"]]:
   var index=int(state.delivery.nodes.get(entry[0],-1))
   if index>=0: result.append({"index":index,"stock":state.delivery.buffers[entry[0]],"kind":entry[0],"only":entry[1]})
 for id in state.stone.sites:
  var index=int(id)
  if state.buildings[index].kind=="stoneworks": result.append({"index":index,"stock":state.stone.sites[id].stock,"kind":"stoneworks","keys":["stone","gravel"]})
 return result

static func launch(state: Dictionary,origin: int,destination: int,key: String,amount: float,target: String,source_stock: Dictionary) -> bool:
 var route=LogisticsRoutes.road_route(state,origin,destination)
 if route.size()<2 or amount<=0: return false
 var drive=maxf(2,LogisticsRoutes.length(route)/(10+int(state.vehicle)))
 var trip={"id":state.hub.next_id,"source":state.buildings[origin].kind,"origin":origin,"destination":destination,"target":target,"fleet":"central","key":key,"amount":amount,"mode":"truck","path":route,"age":0.0,"load":6.0,"drive":drive,"unload":6.0,"travel":drive+12,"total":drive*2+14,"arrived":false}
 source_stock[key]=float(source_stock.get(key,0))-amount
 FreightFlow.enqueue(state,state.hub.shipments,trip)
 state.hub.next_id+=1
 return true

static func construction_sources(state: Dictionary,job: Dictionary,key: String) -> Array:
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
 if best>=0: return [{"kind":"express","index":best,"stock":stock(state,best,true)}]
 return [{"kind":"central_depot","index":center,"stock":state.resources}]

static func dispatch(state: Dictionary) -> void:
 var center=depot(state)
 if center<0 or state.buildings[center].get("paused",false): return
 var free=fleet_size(state)-state.hub.shipments.size()
 if free<=0: return
 # Long-distance replenishment has priority, but cannot consume pickup capacity.
 var express_budget=maxi(1,fleet_size(state)/2)
 for job in state.jobs:
  if not job.has("phases") or job.get("paused",false): continue
  for key in job.materials:
   if free<=0 or express_budget<=0: break
   var sources=construction_sources(state,job,key)
   if sources.is_empty() or sources[0].kind!="express": continue
   var source=sources[0]
   var needed=maxf(0,ConstructionRules.phase_need(job,key)-ConstructionRules.incoming(state,int(job.id),key)-float(source.stock.get(key,0))-incoming(state,int(source.index),key))
   var amount=minf(needed,minf(float(state.resources.get(key,0)),12+int(state.vehicle)*2))
   if amount>0 and launch(state,center,int(source.index),key,amount,"express",state.resources): free-=1; express_budget-=1
 var sources=pickup_sources(state)
 if sources.is_empty(): return
 var cursor=int(state.hub.cursor)%sources.size()
 for offset in sources.size():
  var source=sources[(cursor+offset)%sources.size()]
  for key in source.stock.keys():
   if source.has("only") and key!=source.only: continue
   if source.has("keys") and key not in source.keys: continue
   var amount=minf(float(source.stock[key]),minf(12+int(state.vehicle)*2,maxf(0,capacity(state)-float(state.resources.get(key,0))-incoming(state,center,key))))
   if amount<0.25 or free<=0: continue
   if launch(state,int(source.index),center,key,amount,"central",source.stock): free-=1
 state.hub.cursor=(cursor+1)%sources.size()

static func target_name(state: Dictionary,trip: Dictionary) -> String:
 return UXRules.factory_name(state,int(trip.destination)) if trip.target in ["central","express"] else ""

static func recall_express(state: Dictionary,index: int) -> float:
 var center=depot(state)
 if center<0 or state.buildings[index].kind!="express": return 0
 var available=fleet_size(state)-state.hub.shipments.size()
 var result=0.0
 var regional=stock(state,index,true)
 for key in regional:
  if available<=0: break
  var amount=minf(float(regional[key]),minf(12+int(state.vehicle)*2,maxf(0,capacity(state)-float(state.resources[key])-incoming(state,center,key))))
  if amount>0 and launch(state,index,center,key,amount,"central",regional): available-=1; result+=amount
 return result
