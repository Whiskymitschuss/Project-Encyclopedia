class_name UXRules
extends RefCounted

static func initial() -> Dictionary:
 return {"vibration":false,"large_text":false,"high_contrast":false,"motion":true,"groups":[],"next_group":1,"next_road":1,"events":[],"next_event":1,"road_undo":[]}
static func title(state: Dictionary,city: bool,index: int) -> String:
 var records=state.homes if city else state.buildings
 if index<0 or index>=records.size(): return "Gebäude"
 var b=records[index]
 return TownEvolution.title(b.kind,int(b.level)) if city else str(Catalog.BUILDINGS[b.kind].name)
static func upgrade_bill(state: Dictionary,city: bool,index: int) -> Dictionary:
 var records=state.homes if city else state.buildings
 if index<0 or index>=records.size(): return {}
 var b=records[index]
 var maximum=10 if city else int(Catalog.BUILDINGS[b.kind].max)
 if int(b.level)>=maximum: return {}
 for job in state.jobs:
  if job.type==("home_upgrade" if city else "upgrade") and int(job.index)==index: return {}
 var materials={}
 var coins=0.0
 var difficulty=pow(1.6,int(state.prestige))
 if city:
  if b.kind=="townhall" and not Journey.hall_unlocked(state,int(b.level)+1): return {}
  var d=Catalog.HOMES[b.kind]
  coins=float(d.cost)*pow(1.4,int(b.level))*difficulty
  for key in d.materials: materials[key]=ceilf(float(d.materials[key])*0.5*int(b.level))
  if b.kind=="townhall":
   coins=Journey.hall_cost(int(b.level)+1)*difficulty
   materials=Journey.hall_materials(int(b.level)+1)
 else:
  var copies=0
  for other in state.buildings:
   if other.kind==b.kind: copies+=1
  coins=ceilf(float(Catalog.BUILDINGS[b.kind].cost)*pow(1.24,int(b.level))*(1+copies*0.4)*difficulty)
  materials=ConstructionRules.materials(b.kind,int(b.level)+1,company_level(state)>=5) if company_level(state)>=4 else {}
 return {"city":city,"index":index,"coins":coins,"materials":materials,"target":int(b.level)+1}
static func company_level(state: Dictionary) -> int:
 var thresholds=[0,20,60,120,220,360,550,800,1150,1600,2200,3000,4000,5200,6700,8500,10600,13000,15800,19000]
 var level=1
 for i in thresholds.size():
  if int(state.company_xp)>=int(thresholds[i]): level=i+1
 return level
static func factory_name(state: Dictionary,index: int) -> String:
 var kind=state.buildings[index].kind
 var ordinal=0
 for i in range(index+1):
  if state.buildings[i].kind==kind: ordinal+=1
 return "%s %s" % [Catalog.BUILDINGS[kind].name,ordinal]
static func material_sources(state: Dictionary,key: String) -> Array:
 var result=[]
 var staged=float(state.hub.get("receiving",{}).get(key,0))
 if staged>0 and CentralLogistics.depot(state)>=0: result.append({"index":CentralLogistics.depot(state),"amount":staged,"name":"Zentrallager · Warenannahme","kind":"central_depot"})
 for id in state.hub.inputs:
  if float(state.hub.inputs[id].get(key,0))>0: result.append({"index":int(id),"amount":float(state.hub.inputs[id][key]),"name":factory_name(state,int(id))+" · Werkseingang","kind":state.buildings[int(id)].kind})
 for id in state.hub.outputs:
  if float(state.hub.outputs[id].get(key,0))>0: result.append({"index":int(id),"amount":float(state.hub.outputs[id][key]),"name":factory_name(state,int(id)),"kind":state.buildings[int(id)].kind})
 for id in state.hub.express:
  result.append({"index":int(id),"amount":float(state.hub.express[id].get(key,0)),"name":factory_name(state,int(id)),"kind":"express"})
 for source in ConstructionRules.sources(state,key):
  if LogisticsDispatch.enabled(state) and source.get("storage","") in ["regional","receiving"]: continue
  result.append({"index":int(source.index),"amount":float(source.stock.get(key,0)),"name":factory_name(state,int(source.index)),"kind":source.kind})
 for i in state.buildings.size():
  var b=state.buildings[i]
  var produces=Catalog.RECIPES.has(b.kind) and Catalog.RECIPES[b.kind].out.has(key)
  if key=="wood" and b.kind=="station": produces=true
  if b.kind=="stoneworks" and key in ["stone","gravel"]: produces=true
  if b.kind=="quarry" and key=="rock": produces=true
  if not produces: continue
  var exists=false
  for source in result:
   if int(source.index)==i: exists=true
  if not exists:
   var mineral=StoneIndustry.site(state,i) if b.kind in StoneIndustry.KINDS else {}
   result.append({"index":i,"amount":float(mineral.get("stock",{}).get(key,0)),"shared":mineral.is_empty() and not CentralLogistics.active(state),"name":factory_name(state,i),"kind":b.kind})
 return result
static func material_counts(state: Dictionary,job: Dictionary,key: String) -> Dictionary:
 var delivered=float(job.get("delivered",{}).get(key,0))
 var total=float(job.materials.get(key,0))
 var transit=ConstructionRules.incoming(state,int(job.get("id",-1)),key)
 return {"arrived":delivered,"incoming":transit,"missing":maxf(0,total-delivered-transit),"total":total}
static func material_stock(state: Dictionary,key: String) -> Dictionary:
 var warehouse=float(state.resources.get(key,0))
 var receiving=float(state.hub.get("receiving",{}).get(key,0))
 var regional=0.0
 for stock in state.hub.express.values(): regional+=float(stock.get(key,0))
 var local=receiving
 for group in [state.delivery.buffers,state.delivery.recovered]:
  for stock in group.values(): local+=float(stock.get(key,0))
 for group in [state.hub.outputs,state.hub.express,state.hub.inputs]:
  for stock in group.values(): local+=float(stock.get(key,0))
 for site in state.stone.sites.values(): local+=float(site.get("stock",{}).get(key,0))
 var transit=0.0
 for trip in FreightFlow.all_trips(state):
  if trip.key==key and not trip.arrived: transit+=float(trip.amount)
 # A truck's cargo was already withdrawn. An arrived truck has already
 # credited its destination; neither may be counted twice as available stock.
 return {"warehouse":warehouse,"regional":regional,"local":local,"transit":transit,"stored":warehouse+local,"receiving":receiving}
static func build_quote(state: Dictionary,key: String,needed: float) -> Dictionary:
 var pickup=0.0
 for source in ConstructionRules.sources(state,key): pickup+=float(source.stock.get(key,0))
 var committed=ConstructionRules.reserved_materials(state,key)
 var inbound_reserved=0.0
 for trip in state.construction_shipments:
  if not trip.arrived and trip.key==key: inbound_reserved+=float(trip.amount)
 var available=maxf(0,pickup-maxf(0,committed-inbound_reserved))
 return {"available":available,"committed":committed,"incoming":inbound_reserved,"missing":maxf(0,needed-available)}
static func group_members(state: Dictionary,group: Dictionary) -> Array:
 var bounds=Rect2(Vector2(float(group.bounds[0]),float(group.bounds[1])),Vector2(float(group.bounds[2]),float(group.bounds[3])))
 var result=[]
 for city in [false,true]:
  var records=state.homes if city else state.buildings
  for i in records.size():
   var at=LogisticsRoutes.home_position(state,i) if city else LogisticsRoutes.building_position(state,i)
   if bounds.has_point(Vector2(at.x,at.z)): result.append({"city":city,"index":i})
 return result
static func group_bill(state: Dictionary,group: Dictionary) -> Dictionary:
 var result={"coins":0.0,"materials":{},"targets":[]}
 for member in group_members(state,group):
  var bill=upgrade_bill(state,member.city,int(member.index))
  if bill.is_empty(): continue
  result.targets.append(bill)
  result.coins+=float(bill.coins)
  for key in bill.materials: result.materials[key]=float(result.materials.get(key,0))+float(bill.materials[key])
 return result
static func push_event(state: Dictionary,key: String,text_value: String,point: Vector3,menu: String="",severity: int=0) -> void:
 var events=state.ux.events
 for event in events:
  if event.key==key: return
 events.push_front({"id":state.ux.next_event,"key":key,"text":text_value,"position":[point.x,point.z],"menu":menu,"severity":severity,"elapsed":float(state.elapsed),"read":false})
 state.ux.next_event=int(state.ux.next_event)+1
 while events.size()>24: events.pop_back()
static func current_hints(state: Dictionary) -> Array:
 var result=[]
 for job in state.jobs:
  if not job.has("phases") or job.get("paused",false): continue
  if int(job.workers)==0:
   result.append({"id":"crew:%s" % int(job.id),"text":"Baustelle wartet auf Bauarbeiter","position":ConstructionRules.job_position(state,job),"menu":"construction","job":int(job.id)})
  elif not ConstructionRules.phase_ready(job):
   result.append({"id":"material:%s" % int(job.id),"text":ConstructionRules.status(job),"position":ConstructionRules.job_position(state,job),"menu":"construction","job":int(job.id)})
 if state.delivery.active and state.delivery.order.get("late",false): result.append({"id":"late","text":"Ladenauftrag überfällig · Lieferung bleibt möglich","menu":"delivery"})
 if float(state.resources.sawdust)>=StoneIndustry.warehouse_capacity(state)*0.8: result.append({"id":"sawdust","text":"Spänebox fast voll · verkaufen oder verarbeiten","menu":"sawdust"})
 if state.delivery.active:
  for kind in ["sawmill","furniture"]:
   if DeliveryChain.status(state,kind).full: result.append({"id":"full:"+kind,"text":"%s · Ausgang voll" % Catalog.BUILDINGS[kind].name,"menu":"delivery","position":LogisticsRoutes.building_position(state,int(state.delivery.nodes[kind]))})
 return result
