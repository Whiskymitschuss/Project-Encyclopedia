class_name DeliveryChain
extends RefCounted

# Buffers and goods in transit are exclusively owned here, never counted twice
# in the shared warehouse. Rendering is a read-only view of this simulation.
const KINDS = ["station","sawmill","furniture","market"]
const LINKS = [["station","sawmill","wood"],["sawmill","furniture","boards"],["furniture","market","furniture"]]

static func initial() -> Dictionary:
 return {"active":false,"nodes":{},"buffers":{},"progress":{},"shipments":[],"next_id":1,"orders":0,"on_time":0,"late_orders":0,"sold":0,"order":{},"last_receipt":"","paused":false}

static func start(state: Dictionary) -> bool:
 if state.delivery.active: return false
 var nodes = {}
 for kind in KINDS:
  for i in state.buildings.size():
   if state.buildings[i].kind==kind and not state.buildings[i].get("paused",false): nodes[kind]=i; break
  if not nodes.has(kind): return false
 var data = initial()
 data.active = true
 data.nodes = nodes
 for kind in KINDS: data.buffers[kind] = {"wood":0.0,"boards":0.0,"furniture":0.0}
 data.order = next_order(state,data)
 state.delivery = data
 return true

static func next_order(state: Dictionary, data: Dictionary) -> Dictionary:
 return {"amount":3+mini(int(data.orders)/3,5),"delivered":0,"left":maxf(75,180-int(state.prestige)*10-mini(int(data.orders)*3,45)),"late":false}

static func owns(state: Dictionary, index: int) -> bool:
 return state.delivery.active and index in state.delivery.nodes.values()

static func capacity(state: Dictionary, kind: String) -> float:
 var level = int(state.buildings[int(state.delivery.nodes[kind])].level)
 return minf(48,4+level*2)

static func reserved(data: Dictionary, kind: String, key: String) -> float:
 var result = 0.0
 for s in data.shipments:
  if s.target==kind and s.key==key and not s.get("arrived",false): result += float(s.amount)
 return result

static func tick(state: Dictionary, delta: float, routes: Dictionary, speed_bonus: float = 1.0) -> Dictionary:
 var report = {"coins":0.0,"sold":0,"tickets":0,"sawdust":0.0,"flow":{}}
 var data = state.delivery
 if not data.active or data.paused: return report
 # Freeze this line while one of its selected buildings is paused.
 for kind in KINDS:
  var index = int(data.nodes.get(kind,-1))
  if index<0 or index>=state.buildings.size(): return report
  if state.buildings[index].get("paused",false): return report
 # Arrival precedes production and dispatch. A dispatch can never teleport goods
 # into a downstream recipe in the same simulation tick.
 var finished = []
 for shipment in data.shipments:
  shipment.age = float(shipment.age)+delta
  if not shipment.arrived and float(shipment.age)>=float(shipment.travel):
   data.buffers[shipment.target][shipment.key] += float(shipment.amount)
   shipment.arrived = true
  if float(shipment.age)>=float(shipment.total): finished.append(shipment)
 for shipment in finished: data.shipments.erase(shipment)
 var protected_wood = 0.0
 for job in state.jobs: protected_wood += ConstructionRules.remaining(job,"wood")
 var take = minf(maxf(0,float(state.resources.wood)-protected_wood),maxf(0,capacity(state,"station")-float(data.buffers.station.wood)))
 data.buffers.station.wood += take
 state.resources.wood -= take
 for kind in ["sawmill","furniture"]:
  var key = "wood" if kind=="sawmill" else "boards"
  var product = "boards" if kind=="sawmill" else "furniture"
  var buf = data.buffers[kind]
  var index = int(data.nodes[kind])
  var duration = (3.0 if kind=="sawmill" else 6.0)/maxf(1,int(state.buildings[index].level)*speed_bonus)
  if float(buf[key])>=2 and float(buf[product])<capacity(state,kind):
   data.progress[kind] = float(data.progress.get(kind,0))+delta
   var cycles = mini(floori(float(data.progress[kind])/duration),mini(floori(float(buf[key])/2),floori(capacity(state,kind)-float(buf[product]))))
   if cycles>0:
    buf[key] -= cycles*2
    buf[product] += cycles
    data.progress[kind] = maxf(0,float(data.progress[kind])-cycles*duration)
    if kind=="sawmill": report.sawdust += cycles
   report.flow["building:%s" % index] = 1.0/duration
  else: data.progress[kind] = 0.0
 # A shop pays only for furniture that physically reached its own buffer.
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
  data.order = next_order(state,data)
 else:
  order.left = maxf(0,float(order.left)-delta)
  if order.left<=0: order.late = true
 var reserve_truck = 0
 for job in state.jobs:
  if not job.has("phases") or job.get("paused",false) or (not state.construction_auto and not job.get("requested",false)): continue
  for key in job.materials:
   if ConstructionRules.phase_need(job,key)-ConstructionRules.incoming(state,int(job.id),key)>0.0001 and float(state.resources[key])>0:
    reserve_truck=1
 var truck_count = mini(2,maxi(0,int(state.trucks)-state.construction_shipments.size()-reserve_truck))
 for i in LINKS.size():
  var source = LINKS[i][0]
  var target = LINKS[i][1]
  var key = LINKS[i][2]
  var route = routes.get(target,[])
  if route.size()<2: continue
  var busy = 0
  for s in data.shipments:
   if (i==2 and s.mode=="truck") or (i<2 and s.source==source and s.mode=="belt"): busy += 1
  if busy >= (truck_count if i==2 else 3): continue
  var room = capacity(state,target)-float(data.buffers[target][key])-reserved(data,target,key)
  var batch = mini(2+mini(int(state.vehicle),4),mini(floori(float(data.buffers[source][key])),floori(room)))
  if batch<=0: continue
  var travel = maxf(2,LogisticsRoutes.length(route)/(10.0+int(state.vehicle)) if i==2 else LogisticsRoutes.length(route)/5.0)
  # The truck remains assigned while unloading and driving back empty.
  var drive = travel
  if i==2: travel+=4.0
  var total = travel+drive+2 if i==2 else travel
  data.buffers[source][key] -= batch
  data.shipments.append({"id":data.next_id,"source":source,"target":target,"key":key,"amount":batch,"mode":"truck" if i==2 else "belt","path":route.duplicate(true),"load":2.0 if i==2 else 0.0,"drive":drive,"unload":2.0 if i==2 else 0.0,"travel":travel,"total":total,"age":0.0,"arrived":false})
  data.next_id += 1
 return report

static func status(state: Dictionary, kind: String) -> Dictionary:
 var data = state.delivery
 var key = {"station":"wood","sawmill":"wood","furniture":"boards","market":"furniture"}[kind]
 var amount = float(data.buffers[kind][key])
 var need = int(capacity(state,kind)) if kind=="station" else 2
 if kind=="market": amount = float(data.order.delivered); need = int(data.order.amount)
 var output_key = "boards" if kind=="sawmill" else "furniture"
 var full = kind in ["sawmill","furniture"] and float(data.buffers[kind][output_key])>=capacity(state,kind)
 if full:
  key=output_key
  amount=float(data.buffers[kind][output_key])
  need=int(capacity(state,kind))
 return {"key":key,"amount":amount,"need":need,"ready":amount>=need,"full":full,"empty":amount<1,"text":"Ausgang voll" if full else "Bereit" if amount>=need else "Wartet auf Lieferung"}
