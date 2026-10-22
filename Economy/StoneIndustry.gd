class_name StoneIndustry
extends RefCounted

# The simulation owns stock, a loaded bucket, batch escrow and road cargo.
# Models only read these records. Every numeric save reference is normalized.
static var definitions: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://Economy/stone_industry.json"))
const KINDS=["quarry","stoneworks"]
const KEYS=["rock","stone","gravel"]

static func initial() -> Dictionary:
 return {"sites":{},"shipments":[],"next_id":1000000,"turn":"wood","ready":false,"delivered":0.0,"mined":0.0,"cycles":0,"intro":false,"cursor":0}

static func site(state: Dictionary, index: int) -> Dictionary:
 return state.stone.sites.get(str(index),{})

static func synchronize(state: Dictionary) -> void:
 for i in state.buildings.size():
  var b=state.buildings[i]
  if b.kind not in KINDS or state.stone.sites.has(str(i)): continue
  var deposit=(int(definitions.extraction.deposit)+(int(b.level)-1)*int(definitions.extraction.deposit_per_level)) if b.kind=="quarry" else 0
  state.stone.sites[str(i)]={"stock":{"rock":0.0,"stone":0.0,"gravel":0.0},"reserve":float(deposit),"vein_size":float(deposit),"veins":1,"bucket":0.0,"phase":0,"phase_work":0.0,"recipe":"blocks","batch":{},"mined":0.0,"cycles":0}

static func capacity(state: Dictionary, index: int) -> float:
 return 8.0+int(state.buildings[index].level)*4.0

static func warehouse_capacity(state: Dictionary) -> float:
 return CentralLogistics.capacity(state)

static func incoming(state: Dictionary, target: int, key: String) -> float:
 var total=0.0
 for s in state.stone.shipments:
  if int(s.destination)==target and s.key==key and not s.arrived: total+=float(s.amount)
 return total

static func uses_building(state: Dictionary, index: int) -> bool:
 for shipment in state.stone.shipments:
  if int(shipment.origin)==index or int(shipment.dock)==index: return true
 return false

static func transport_tick(state: Dictionary, delta: float) -> void:
 var done=[]
 for shipment in state.stone.shipments:
  FreightFlow.advance(shipment,delta)
  if not shipment.arrived and float(shipment.age)>=float(shipment.travel):
   var stock=state.resources if int(shipment.destination)<0 else site(state,int(shipment.destination)).get("stock",{})
   var cap=warehouse_capacity(state) if int(shipment.destination)<0 else capacity(state,int(shipment.destination))
   if stock.is_empty() or float(stock.get(shipment.key,0))+float(shipment.amount)>cap+0.00001:
    shipment.age=float(shipment.travel)
    continue
   stock[shipment.key]=float(stock.get(shipment.key,0))+float(shipment.amount)
   shipment.arrived=true
   if int(shipment.destination)<0: state.stone.delivered+=float(shipment.amount)
  if shipment.arrived and float(shipment.age)>=float(shipment.total): done.append(shipment)
 for shipment in done: state.stone.shipments.erase(shipment)

static func quarry_tick(state: Dictionary, index: int, delta: float, bonus: float) -> bool:
 var data=site(state,index)
 var level=int(state.buildings[index].level)
 var sizes=definitions.extraction.buckets
 var bucket_size=float(sizes[clampi(level-1,0,sizes.size()-1)])
 var left=delta*bonus*(1+(level-1)*0.08)
 var active=false
 while left>0.000001:
  if int(data.phase)==0 and float(data.phase_work)<=0:
   if float(data.reserve)<=0 or capacity(state,index)-float(data.stock.rock)-float(data.bucket)<minf(bucket_size,float(data.reserve)): break
  active=true
  var duration=float(definitions.extraction.phase_seconds[int(data.phase)])
  var work=minf(left,maxf(0,duration-float(data.phase_work)))
  data.phase_work+=work
  left-=work
  if float(data.phase_work)<duration-0.000001: break
  data.phase_work=0.0
  match int(data.phase):
   0:
    data.bucket=minf(bucket_size,float(data.reserve))
    data.reserve-=float(data.bucket)
   2:
    data.stock.rock+=float(data.bucket)
    data.mined+=float(data.bucket)
    state.stone.mined+=float(data.bucket)
    data.bucket=0.0
    data.cycles+=1
    state.stone.cycles+=1
  data.phase=(int(data.phase)+1)%4
 return active

static func factory_tick(state: Dictionary, index: int, delta: float, bonus: float) -> bool:
 var data=site(state,index)
 var left=delta*bonus*(1+(int(state.buildings[index].level)-1)*0.15)
 var active=false
 while left>0.000001:
  if data.batch.is_empty():
   var recipe=definitions.recipes[data.recipe]
   var ready=true
   for key in recipe["in"]:
    if float(data.stock[key])<float(recipe["in"][key]): ready=false
   for key in recipe.out:
    if float(data.stock[key])+float(recipe.out[key])>capacity(state,index): ready=false
   if not ready: break
   for key in recipe["in"]: data.stock[key]-=float(recipe["in"][key])
   data.batch={"recipe":data.recipe,"left":float(recipe.seconds),"input":recipe["in"].duplicate(true),"output":recipe.out.duplicate(true)}
  active=true
  var work=minf(left,float(data.batch.left))
  left-=work
  data.batch.left=maxf(0,float(data.batch.left)-work)
  if float(data.batch.left)>0.000001: break
  for key in data.batch.output: data.stock[key]+=float(data.batch.output[key])
  data.batch={}
 return active

static func tick(state: Dictionary, delta: float, bonus: float) -> Dictionary:
 synchronize(state)
 transport_tick(state,delta)
 var flow={}
 for i in state.buildings.size():
  var b=state.buildings[i]
  if b.kind not in KINDS or b.get("paused",false): continue
  var running=quarry_tick(state,i,delta,bonus) if b.kind=="quarry" else factory_tick(state,i,delta,bonus)
  if running: flow["building:%s" % i]=1.0
 return flow

static func route(state: Dictionary, source: int, target: int, cache: Dictionary) -> Array:
 var a=LogisticsRoutes.building_position(state,source)
 var b=LogisticsRoutes.building_position(state,target)
 var key=hash([a,b,state.town.roads,int(state.town.districts)])
 if not cache.has(key):
  if cache.size()>96: cache.clear()
  cache[key]=LogisticsRoutes.between(state,a,b)
 return cache[key]

static func requests(state: Dictionary, cache: Dictionary) -> Array:
 synchronize(state)
 var result=[]
 var depot=-1
 for i in state.buildings.size():
  if state.buildings[i].kind=="warehouse" and not state.buildings[i].get("paused",false): depot=i; break
 if depot<0: return result
 # Clear finished goods first so output space cannot permanently block supply.
 for i in state.buildings.size():
  if state.buildings[i].kind not in KINDS: continue
  var data=site(state,i)
  if data.is_empty(): continue
  for key in ["stone","gravel"]:
   if CentralLogistics.active(state): continue
   var amount=minf(float(data.stock[key]),warehouse_capacity(state)-float(state.resources[key])-incoming(state,-1,key))
   if amount<1: continue
   var path=route(state,i,depot,cache)
   if path.size()>1: result.append({"origin":i,"destination":-1,"dock":depot,"key":key,"amount":amount,"path":path})
 for target in state.buildings.size():
  if state.buildings[target].kind!="stoneworks" or state.buildings[target].get("paused",false): continue
  var room=capacity(state,target)-float(site(state,target).stock.rock)-incoming(state,target,"rock")
  if room<1: continue
  for source in state.buildings.size():
   if state.buildings[source].kind!="quarry": continue
   var amount=minf(room,float(site(state,source).stock.rock))
   if amount<1: continue
   var path=route(state,source,target,cache)
   if path.size()>1:
    result.append({"origin":source,"destination":target,"dock":target,"key":"rock","amount":amount,"path":path})
    break
 return result

static func busy(state: Dictionary) -> int:
 return (0 if CentralLogistics.active(state) else state.construction_shipments.size())+state.delivery.shipments.size()+state.stone.shipments.size()+ExportTrade.busy(state)

static func dispatch(state: Dictionary, cache: Dictionary) -> int:
 var free=maxi(0,int(state.trucks)-busy(state))
 var count=0
 # Regenerate reservations after every allocation, never reuse a stale request.
 while free>0:
  var choices=requests(state,cache)
  if choices.is_empty(): break
  var request=choices[posmod(int(state.stone.cursor),choices.size())]
  state.stone.cursor=int(state.stone.cursor)+1
  var weight=float(definitions.materials[request.key].weight)
  var units=maxi(1,floori(float(4+int(state.vehicle)*2)/weight))
  var amount=minf(units,floorf(float(request.amount)))
  if amount<1: break
  site(state,int(request.origin)).stock[request.key]-=amount
  var drive=maxf(2,LogisticsRoutes.length(request.path)/(10.0+int(state.vehicle)))
  request.merge({"id":state.stone.next_id,"domain":"stone","source":"mineral","target":"mineral","mode":"truck","amount":amount,"age":0.0,"arrived":false,"load":2.0,"unload":2.0,"drive":drive,"travel":drive+4,"total":drive*2+6},true)
  FreightFlow.enqueue(state,state.stone.shipments,request)
  state.stone.next_id=int(state.stone.next_id)+1
  state.stone.turn="wood"
  free-=1
  count+=1
 return count

static func status(state: Dictionary, index: int) -> String:
 var b=state.buildings[index]
 var data=site(state,index)
 if data.is_empty(): return "Wird in Betrieb genommen"
 if b.get("paused",false): return "Produktion pausiert · laufende LKWs liefern weiter"
 if b.kind=="quarry":
  var has_factory=false
  for other in state.buildings:
   if other.kind=="stoneworks": has_factory=true; break
  if not has_factory: return "Steinwerk bauen · Gestein wartet in der Abholmulde"
 if b.kind=="quarry":
  if float(data.reserve)<=0 and float(data.bucket)<=0 and int(data.phase)==0: return "Felsader erschöpft · neue Ader erschließen"
  if float(data.stock.rock)+float(data.bucket)>=capacity(state,index): return "Abholmulde voll · wartet auf Muldenkipper"
  return ["Gestein lösen","Schaufel schwenken","Abholmulde beladen","Arm zurückführen"][int(data.phase)]
 if not data.batch.is_empty(): return "%s in Arbeit · %s Arbeitssekunden" % [definitions.recipes[data.batch.recipe].name,ceili(data.batch.left)]
 var recipe=definitions.recipes[data.recipe]
 for key in recipe.out:
  if float(data.stock[key])+float(recipe.out[key])>capacity(state,index): return "Ausgang voll · wartet auf Abholung"
 if float(data.stock.rock)<3: return "Wartet auf Gesteinslieferung"
 return "Bereit für den nächsten Arbeitsgang"
