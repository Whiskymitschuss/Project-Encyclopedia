class_name DeliveryChain
extends RefCounted

# Buffers and goods in transit are exclusively owned here, never counted twice
# in the shared warehouse. Rendering is a read-only view of this simulation.
const KINDS = ["station","sawmill","furniture","market"]
const LINKS = [["station","sawmill","wood"],["sawmill","furniture","boards"],["furniture","market","furniture"]]

static func initial() -> Dictionary:
 return {"recovered":{},"active":false,"nodes":{},"buffers":{},"progress":{},"shipments":[],"next_id":1,"orders":0,"on_time":0,"late_orders":0,"sold":0,"order":{},"last_receipt":"","paused":false}

static func start(state: Dictionary) -> bool:
 if state.delivery.active: return false
 var nodes=choose_nodes(state)
 if nodes.is_empty(): return false
 var data = initial()
 data.active = true
 data.nodes = nodes
 for kind in KINDS: data.buffers[kind] = {"wood":0.0,"boards":0.0,"furniture":0.0}
 data.order = next_order(state,data)
 state.delivery = data
 return true

static func choose_nodes(state: Dictionary) -> Dictionary:
 var nodes = {}
 for kind in KINDS:
  for i in state.buildings.size():
   if state.buildings[i].kind==kind and not state.buildings[i].get("paused",false): nodes[kind]=i; break
  if not nodes.has(kind): return {}
 return nodes

static func next_order(state: Dictionary, data: Dictionary) -> Dictionary:
 return {"amount":3+mini(int(data.orders)/3,5),"delivered":0,"left":maxf(150,300-int(state.prestige)*10-mini(int(data.orders)*3,90)),"late":false}

static func owns(state: Dictionary, index: int) -> bool:
 if not state.delivery.active: return false
 # JSON restores numeric references as floats. Array membership distinguishes
 # int from float, which previously enabled the old shared recipe as well.
 for selected in state.delivery.nodes.values():
  if int(selected)==index: return true
 return false

static func capacity(state: Dictionary, kind: String) -> float:
 var index=int(state.delivery.nodes[kind])
 if LogisticsDispatch.enabled(state): return TransportCapacity.buffer(state,index)
 var level = int(state.buildings[index].level)
 return minf(48,4+level*2)

static func general_busy(state: Dictionary) -> int:
 var count=0
 for trip in state.delivery.shipments:
  if trip.mode=="truck" and trip.get("fleet","")!="central": count+=1
 return count

static func central_busy(state: Dictionary) -> int:
 var count=0
 for trip in state.delivery.shipments:
  if trip.get("fleet","")=="central": count+=1
 return count

static func supply_pending(state: Dictionary) -> bool:
 var data=state.delivery
 if not data.active or data.paused: return false
 var center=CentralLogistics.depot(state)
 if center<0 or state.buildings[center].get("paused",false): return false
 for link in LINKS:
  var target=str(link[1])
  var key=str(link[2])
  var index=int(data.nodes[target])
  if state.buildings[index].get("paused",false): continue
  var room=capacity(state,target)-float(data.buffers[target][key])-reserved(data,target,key)
  if room<1 or float(state.resources.get(key,0))<1: continue
  var protected=ConstructionRules.reserved_materials(state,key) if key=="furniture" else ConstructionRules.processing_reserve(state,key)
  if room>=1 and float(state.resources.get(key,0))-protected>=1 and LogisticsRoutes.road_route(state,center,index).size()>=2: return true
 return false

static func reserved(data: Dictionary, kind: String, key: String) -> float:
 var result = 0.0
 for s in data.shipments:
  if s.target==kind and s.key==key and not s.get("arrived",false): result += float(s.amount)
 return result

static func tick(state: Dictionary, delta: float, routes: Dictionary, speed_bonus: float = 1.0) -> Dictionary:
 var report = {"coins":0.0,"sold":0,"tickets":0,"sawdust":0.0,"produced":{},"orders":0,"flow":{}}
 var data = state.delivery
 var centralized=CentralLogistics.active(state)
 var finished = []
 for shipment in data.shipments:
  FreightFlow.advance(shipment,delta)
  if not shipment.arrived and float(shipment.age)>=float(shipment.travel):
   # Restored or reassigned trucks can meet an already occupied shelf. Keep
   # their real cargo on the truck until unloading fits; never credit twice.
   if float(data.buffers[shipment.target].get(shipment.key,0))+float(shipment.amount)>capacity(state,str(shipment.target))+0.00001:
    shipment.age=float(shipment.travel)
    continue
   data.buffers[shipment.target][shipment.key] += float(shipment.amount)
   shipment.arrived = true
  if float(shipment.age)>=float(shipment.total): finished.append(shipment)
 for shipment in finished: data.shipments.erase(shipment)
 if not data.active: return report
 if data.paused: return report
 # Validate assignments; individual building pauses affect only that workplace.
 for kind in KINDS:
  var index = int(data.nodes.get(kind,-1))
  if index<0 or index>=state.buildings.size(): return report
 for kind in data.recovered:
  var keys = data.recovered[kind].keys()
  keys.sort()
  for key in keys:
   var amount = minf(float(data.recovered[kind][key]),maxf(0,capacity(state,kind)-float(data.buffers[kind][key])))
   data.recovered[kind][key] -= amount
   data.buffers[kind][key] += amount
 # Arrival precedes production and dispatch. A dispatch can never teleport goods
 # into a downstream recipe in the same simulation tick.
 var protected_wood = 0.0 if centralized else ConstructionRules.processing_reserve(state,"wood")
 var take = 0.0 if centralized or state.buildings[int(data.nodes.station)].get("paused",false) else minf(maxf(0,float(state.resources.wood)-protected_wood),maxf(0,capacity(state,"station")-float(data.buffers.station.wood)))
 data.buffers.station.wood += take
 state.resources.wood -= take
 for kind in ["sawmill","furniture"]:
  if state.buildings[int(data.nodes[kind])].get("paused",false): continue
  var key = "wood" if kind=="sawmill" else "boards"
  var product = "boards" if kind=="sawmill" else "furniture"
  var buf = data.buffers[kind]
  var index = int(data.nodes[kind])
  var duration = (3.0 if kind=="sawmill" else 6.0)/maxf(1,int(state.buildings[index].level)*speed_bonus)
  if kind=="sawmill":
   var rate=1.0/duration
   var result=SawmillProduction.advance(state,index,delta,rate,maxf(0,capacity(state,kind)-float(buf.boards)))
   buf.boards+=float(result.finished)
   report.sawdust+=float(result.finished)
   report.produced.boards=float(result.finished)
   var cycles=minf(rate*SawmillProduction.line_count(state,index)*delta,minf(float(buf.wood)/2,minf(SawmillProduction.intake_room(state,index,rate),maxf(0,capacity(state,kind)-float(buf.boards)-SawmillProduction.pending(state,index)))))
   buf.wood-=cycles*2
   SawmillProduction.accept(state,index,cycles,rate)
   report.flow["building:%s" % index]=maxf(float(result.working),cycles/maxf(delta,0.001))
   continue
  if float(buf[key])>=2 and float(buf[product])<capacity(state,kind):
   data.progress[kind] = float(data.progress.get(kind,0))+delta
   var cycles = mini(floori(float(data.progress[kind])/duration),mini(floori(float(buf[key])/2),floori(capacity(state,kind)-float(buf[product]))))
   if cycles>0:
    buf[key] -= cycles*2
    buf[product] += cycles
    report.produced[product]=cycles
    data.progress[kind] = maxf(0,float(data.progress[kind])-cycles*duration)
    if kind=="sawmill": report.sawdust += cycles
   report.flow["building:%s" % index] = 1.0/duration
  else: data.progress[kind] = 0.0
 # Reserve newly produced goods for construction before a downstream truck
 # can load them. Dispatch withdraws real source stock into its own road cargo.
 ConstructionRules.dispatch(state)
 # A shop pays only for furniture that physically reached its own buffer.
 if not state.buildings[int(data.nodes.market)].get("paused",false):
  var order = data.order
  var sold = mini(floori(float(data.buffers.market.furniture)),int(order.amount)-int(order.delivered))
  if sold>0:
   data.buffers.market.furniture -= sold
   order.delivered += sold
   data.sold += sold
   report.sold += sold
   report.coins += sold*float(Catalog.PRICES.furniture)*(0.7 if order.late else 1.0)
  if int(order.delivered)>=int(order.amount):
   if not order.late:
    report.coins += 90+int(order.amount)*10
    report.tickets += 1
    data.on_time += 1
    data.last_receipt = "Pünktlich geliefert · Bonus + 1 Loot-Ticket"
   else:
    data.late_orders += 1
    data.last_receipt = "Spät geliefert · 70 % Verkaufspreis, nächster Auftrag"
   data.orders += 1
   report.orders+=1
   data.order = next_order(state,data)
  else:
   order.left = maxf(0,float(order.left)-delta)
   if order.left<=0: order.late = true
 # The unified network dispatches these same local input buffers alongside
 # every other factory. Do not race it with a second independently greedy loop.
 if LogisticsDispatch.enabled(state): return report
 var free = CentralLogistics.available_trucks(state) if centralized else maxi(0,int(state.trucks)-general_busy(state)-state.construction_shipments.size()-state.stone.shipments.size()-ExportTrade.busy(state)-(1 if state.stone.ready and state.stone.turn=="stone" else 0))
 # Keep one pickup/replenishment in service when both duties need the central
 # fleet. Existing hub assignments already satisfy that share, including returns.
 if free>0 and centralized: free=maxi(0,free-CentralLogistics.collection_reserve(state))
 # Start downstream, then rotate after successful assignments so permanently
 # stocked shop orders cannot starve a sawmill's next ingredient delivery.
 var order_of_links=[2,1,0]
 var cursor=int(state.hub.get("supply_cursor",0))%3
 for offset in 3:
  var i=order_of_links[(cursor+offset)%3]
  var source = LINKS[i][0]
  var target = LINKS[i][1]
  var key = LINKS[i][2]
  var route = routes.get(target,[])
  if route.size()<2 and not centralized: continue
  if free<=0 or state.buildings[int(data.nodes[target])].get("paused",false): continue
  var room = capacity(state,target)-float(data.buffers[target][key])-reserved(data,target,key)
  var protected=0.0 if centralized else ConstructionRules.reserved_materials(state,key) if key=="furniture" else ConstructionRules.processing_reserve(state,key,float(data.buffers[source][key]))
  var batch = mini(4+int(state.vehicle)*2,mini(floori(maxf(0,float(data.buffers[source][key])-protected)),floori(room)))
  if centralized: batch=0
  var origin=-1
  var warehouse_load=false
  if batch<=0 and room>=1:
   var reserve=ConstructionRules.reserved_materials(state,key) if key=="furniture" else ConstructionRules.processing_reserve(state,key)
   var available=maxf(0,float(state.resources.get(key,0))-reserve)
   batch=mini(4+int(state.vehicle)*2,mini(floori(available),floori(room)))
   if batch>0:
    for index in state.buildings.size():
     if state.buildings[index].kind!=("central_depot" if centralized else "warehouse") or state.buildings[index].get("paused",false): continue
     var supply_route=LogisticsRoutes.road_route(state,index,int(data.nodes[target]))
     if supply_route.size()<2: continue
     route=supply_route
     origin=index
     warehouse_load=true
     break
    if not warehouse_load: batch=0
  if batch<=0: continue
  var travel = maxf(2,LogisticsRoutes.length(route)/(12.0+int(state.vehicle)))
  # The truck remains assigned while unloading and driving back empty.
  var drive = travel
  var handling=6.0 if centralized else 2.0
  travel+=handling*2
  var total = travel+drive+2
  if warehouse_load: state.resources[key]-=batch
  else: data.buffers[source][key] -= batch
  FreightFlow.enqueue(state,data.shipments,{"id":data.next_id,"origin":origin,"source":"central_depot" if centralized and warehouse_load else "warehouse" if warehouse_load else source,"fleet":"central" if centralized and warehouse_load else "general","target":target,"key":key,"amount":batch,"mode":"truck","path":route.duplicate(true),"load":handling,"drive":drive,"unload":handling,"travel":travel,"total":total,"age":0.0,"arrived":false})
  FactorySupply.fulfilled(state,int(data.nodes[target]),key,batch)
  data.next_id += 1
  state.hub.supply_cursor=(cursor+offset+1)%3
  free-=1
 return report

static func status(state: Dictionary, kind: String) -> Dictionary:
 var data = state.delivery
 var key = {"station":"wood","sawmill":"wood","furniture":"boards","market":"furniture"}[kind]
 var amount = float(state.resources.wood) if kind=="station" and CentralLogistics.active(state) else float(data.buffers[kind][key])
 var need = int(capacity(state,kind)) if kind=="station" else 2
 if kind=="market": amount = float(data.order.delivered); need = int(data.order.amount)
 var output_key = "boards" if kind=="sawmill" else "furniture"
 var full = kind in ["sawmill","furniture"] and float(data.buffers[kind][output_key])>=capacity(state,kind)
 # Input and output retain their own icons. A full board pallet must never
 # replace the input log counter and then apparently turn back into logs.
 var result = {"key":key,"amount":amount,"need":need,"ready":amount>=need,"full":full,"empty":amount<1,"text":"Ausgang voll" if full else "Bereit" if amount>=need else "Wartet auf Lieferung"}
 if kind=="sawmill" and SawmillProduction.pending(state,int(data.nodes.sawmill))>0 and not full:
  result.ready=true
  result.text="Entrinden → Sägen → Hobeln"
 if kind in ["sawmill","furniture"]:
  result.output_key=output_key
  result.output_amount=float(data.buffers[kind][output_key])
  result.output_capacity=int(capacity(state,kind))
 return result


static func migrate_belts(state: Dictionary) -> void:
 var data=state.delivery
 if not data.has("recovered"): data.recovered={}
 var kept=[]
 for shipment in data.shipments:
  if shipment.get("mode","")!="belt": kept.append(shipment); continue
  if shipment.get("arrived",false): continue
  var source=str(shipment.source)
  if not data.recovered.has(source): data.recovered[source]={}
  var key=str(shipment.key)
  data.recovered[source][key]=float(data.recovered[source].get(key,0))+float(shipment.amount)
 data.shipments=kept
