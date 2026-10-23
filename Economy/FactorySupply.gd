class_name FactorySupply
extends RefCounted

# Opt-in local factory inputs. Orders own no goods; only a dispatched truck
# withdraws warehouse stock, and only its completed unload credits the factory.
static func requirements(state: Dictionary,index: int) -> Dictionary:
 if index<0 or index>=state.buildings.size(): return {}
 var kind=str(state.buildings[index].kind)
 if DeliveryChain.owns(state,index):
  if kind=="sawmill": return {"wood":2.0}
  if kind=="furniture": return {"boards":2.0}
  if kind=="market": return {"furniture":1.0}
  return {}
 if kind=="stoneworks": return {"rock":3.0}
 return Catalog.RECIPES.get(kind,{}).get("in",{})

static func managed(state: Dictionary,index: int) -> bool:
 return state.hub.get("inputs",{}).has(str(index)) and not DeliveryChain.owns(state,index)

static func stock(state: Dictionary,index: int) -> Dictionary:
 if DeliveryChain.owns(state,index): return state.delivery.buffers[state.buildings[index].kind]
 if state.buildings[index].kind=="stoneworks": return StoneIndustry.site(state,index).get("stock",{})
 return state.hub.get("inputs",{}).get(str(index),{})

static func capacity(state: Dictionary,index: int) -> float:
 if DeliveryChain.owns(state,index): return DeliveryChain.capacity(state,state.buildings[index].kind)
 if state.buildings[index].kind=="stoneworks": return StoneIndustry.capacity(state,index)
 return minf(96,8+int(state.buildings[index].level)*4)

static func incoming(state: Dictionary,index: int,key: String) -> float:
 var total=0.0
 for trip in state.hub.shipments:
  if trip.target=="factory" and int(trip.destination)==index and trip.key==key and not trip.arrived: total+=float(trip.amount)
 if DeliveryChain.owns(state,index): total+=DeliveryChain.reserved(state.delivery,state.buildings[index].kind,key)
 if state.buildings[index].kind=="stoneworks":
  for trip in state.stone.shipments:
   if int(trip.destination)==index and trip.key==key and not trip.arrived: total+=float(trip.amount)
 return total

static func queued(state: Dictionary,index: int,key: String) -> float:
 for order in state.hub.get("requests",[]):
  if int(order.index)==index and order.key==key: return float(order.remaining)
 return 0.0

static func blocked(state: Dictionary,index: int) -> String:
 if requirements(state,index).is_empty(): return "Dieser Betrieb benötigt keine Warenlieferung"
 var center=CentralLogistics.depot(state)
 if center<0: return "Zentrallager bauen"
 if state.buildings[center].get("paused",false): return "Zentrallager pausiert"
 if state.buildings[index].get("paused",false) or (DeliveryChain.owns(state,index) and state.delivery.paused): return "Betrieb pausiert · zuerst fortsetzen"
 if LogisticsRoutes.road_route(state,center,index).size()<2: return "Straßenverbindung zum Zentrallager fehlt"
 return ""

static func enqueue(state: Dictionary,index: int) -> void:
 for key in requirements(state,index):
  var amount=maxf(0,capacity(state,index)-float(stock(state,index).get(key,0))-incoming(state,index,key))
  var found=false
  for order in state.hub.requests:
   if int(order.index)==index and order.key==key:
    order.remaining=amount
    found=true
    break
  if not found and amount>=0.25: state.hub.requests.append({"index":index,"key":key,"remaining":amount})

static func request(state: Dictionary,index: int) -> String:
 var reason=blocked(state,index)
 if not reason.is_empty(): return reason
 if not DeliveryChain.owns(state,index): state.hub.inputs.get_or_add(str(index),{})
 StoneIndustry.synchronize(state)
 enqueue(state,index)
 dispatch(state,true,index)
 return status(state,index)

static func maintain(state: Dictionary) -> void:
 # Continue the requested supply service without converting untouched legacy
 # factories or preloading their inputs by teleportation during migration.
 for id in state.hub.inputs:
  var index=int(id)
  if index<0 or index>=state.buildings.size() or DeliveryChain.owns(state,index) or not blocked(state,index).is_empty(): continue
  for key in requirements(state,index):
   if float(stock(state,index).get(key,0))+incoming(state,index,key)+queued(state,index,key)<maxf(float(requirements(state,index)[key])*2,capacity(state,index)*0.35):
    enqueue(state,index)
    break
 # A line reassignment can change a recipe; unallocated obsolete requests have
 # no cargo to refund. Existing trucks retain their original destination.
 state.hub.requests=state.hub.requests.filter(func(order): return requirements(state,int(order.index)).has(order.key) and float(order.remaining)>0.00001)

static func fulfilled(state: Dictionary,index: int,key: String,amount: float) -> void:
 for order in state.hub.requests:
  if int(order.index)==index and order.key==key: order.remaining=maxf(0,float(order.remaining)-amount)

static func pending(state: Dictionary) -> bool:
 for order in state.hub.requests:
  var protected=ConstructionRules.reserved_materials(state,order.key) if order.key=="furniture" else ConstructionRules.processing_reserve(state,order.key)
  if float(order.remaining)>=0.25 and blocked(state,int(order.index)).is_empty() and float(state.resources.get(order.key,0))>protected: return true
 return false

static func dispatch(state: Dictionary,immediate: bool=false,preferred: int=-1) -> void:
 var free=CentralLogistics.available_trucks(state)
 if free<=0 or state.hub.requests.is_empty(): return
 if not immediate:
  free-=CentralLogistics.collection_reserve(state)
  if DeliveryChain.central_busy(state)==0 and DeliveryChain.supply_pending(state): free-=1
 var center=CentralLogistics.depot(state)
 var orders=state.hub.requests
 if orders.is_empty(): return
 var cursor=int(state.hub.factory_cursor)%orders.size()
 if immediate:
  for i in orders.size():
   if int(orders[i].index)==preferred: cursor=i; break
 for offset in orders.size():
  var position=(cursor+offset)%orders.size()
  var order=orders[position]
  if free<=0: break
  var index=int(order.index)
  if float(order.remaining)<0.25 or not blocked(state,index).is_empty(): continue
  var room=capacity(state,index)-float(stock(state,index).get(order.key,0))-incoming(state,index,order.key)
  # Protect actual construction bills exactly as the automatic wood line does.
  var protected=ConstructionRules.reserved_materials(state,order.key) if order.key=="furniture" else ConstructionRules.processing_reserve(state,order.key)
  var amount=minf(float(order.remaining),minf(room,minf(12+int(state.vehicle)*2,maxf(0,float(state.resources.get(order.key,0))-protected))))
  if amount<0.25: continue
  if DeliveryChain.owns(state,index):
   var path=LogisticsRoutes.road_route(state,center,index)
   var drive=maxf(2,LogisticsRoutes.length(path)/(10+int(state.vehicle)))
   state.resources[order.key]-=amount
   FreightFlow.enqueue(state,state.delivery.shipments,{"id":state.delivery.next_id,"origin":center,"destination":index,"source":"central_depot","target":state.buildings[index].kind,"fleet":"central","key":order.key,"amount":amount,"mode":"truck","path":path,"age":0.0,"load":6.0,"drive":drive,"unload":6.0,"travel":drive+12,"total":drive*2+14,"arrived":false})
   state.delivery.next_id+=1
  elif not CentralLogistics.launch(state,center,index,order.key,amount,"factory",state.resources): continue
  fulfilled(state,index,order.key,amount)
  state.hub.factory_cursor=(position+1)%orders.size()
  free-=1
  if immediate: break

static func status(state: Dictionary,index: int) -> String:
 var reason=blocked(state,index)
 if not reason.is_empty(): return reason
 var parts=[]
 for key in requirements(state,index):
  var text="%s: %s vor Ort" % [Catalog.RESOURCES[key],Catalog.number(float(stock(state,index).get(key,0)))]
  var inbound=incoming(state,index,key)
  var waiting=queued(state,index,key)
  if inbound>0: text+=" · %s im LKW" % Catalog.number(inbound)
  if waiting>0:
   text+=" · %s angefordert" % Catalog.number(waiting)
   var protected=ConstructionRules.reserved_materials(state,key) if key=="furniture" else ConstructionRules.processing_reserve(state,key)
   if float(state.resources.get(key,0))<=protected: text+=" (im Zentrallager fehlend/reserviert)"
   elif CentralLogistics.available_trucks(state)<=0: text+=" (wartet auf freien LKW)"
   else: text+=" (Disposition läuft)"
  parts.append(text)
 return "\n".join(parts)

static func busy_inputs(state: Dictionary) -> bool:
 for trip in state.hub.shipments:
  if trip.target=="factory": return true
 return false
