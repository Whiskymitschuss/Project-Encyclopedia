class_name DepotNetwork
extends RefCounted

# Inventory dictionaries are references to one physical owner. A dispatch
# withdraws from exactly one of them; neither a route nor an order owns goods.
static func depots(state: Dictionary) -> Array:
 var result=[]
 if not CentralLogistics.active(state): return result
 for i in state.buildings.size():
  var b=state.buildings[i]
  if b.kind not in ["central_depot","express"] or b.get("paused",false): continue
  result.append(i)
 return result

static func capacity(state: Dictionary,index: int) -> float:
 return CentralLogistics.capacity(state) if state.buildings[index].kind=="central_depot" else 96.0+(clampi(int(state.buildings[index].level),1,int(Catalog.BUILDINGS.express.max))-1)*24

static func room(state: Dictionary,index: int,key: String) -> float:
 if state.buildings[index].kind=="central_depot": return CentralLogistics.storage_room(state,key)
 return maxf(0,capacity(state,index)-float(state.hub.express.get(str(index),{}).get(key,0))-CentralLogistics.incoming(state,index,key))

static func inventories(state: Dictionary,index: int) -> Array:
 if state.buildings[index].kind=="central_depot": return [state.hub.receiving,state.resources]
 return [state.hub.express.get(str(index),{})]

static func quantity(state: Dictionary,index: int,key: String) -> float:
 var amount=0.0
 for stock in inventories(state,index): amount+=float(stock.get(key,0))
 return amount

static func pickup(state: Dictionary,origin: int,key: String) -> Dictionary:
 var best={}
 var distance=INF
 for index in depots(state):
  if index==origin or room(state,index,key)<0.25: continue
  var route=LogisticsRoutes.road_route(state,origin,index)
  if route.size()<2: continue
  var length=LogisticsRoutes.length(route)
  # A nearby express is a real receiving depot, not merely a remote-site cache.
  if length<distance or (is_equal_approx(length,distance) and state.buildings[index].kind=="central_depot"):
   best={"index":index,"room":room(state,index,key),"path":route}
   distance=length
 return best

static func current_need(state: Dictionary,key: String) -> float:
 var amount=0.0
 for job in state.jobs:
  if job.get("paused",false) or int(job.get("workers",0))<=0: continue
  amount+=maxf(0,ConstructionRules.phase_need(job,key)-ConstructionRules.incoming(state,int(job.id),key))
 return amount

static func supply_sources(state: Dictionary,target: Vector3,key: String,protect: bool=true,exclude: int=-1) -> Array:
 var candidates=[]
 var total=0.0
 for index in depots(state):
  if index==exclude: continue
  var route=LogisticsRoutes.road_to_point(state,index,target)
  if route.size()<2: continue
  var stocks=inventories(state,index)
  if state.buildings[index].kind=="central_depot": stocks=[state.resources,state.hub.receiving]
  for stock_index in stocks.size():
   var stock=stocks[stock_index]
   var available=float(stock.get(key,0))
   if available<=0: continue
   candidates.append({"index":index,"stock":stock,"available":available,"path":route,"distance":LogisticsRoutes.length(route),"staged":state.buildings[index].kind=="central_depot" and stock_index==1})
   total+=available
 var needed=current_need(state,key)
 var plan=Catalog.HOMES.get(str(state.plan.get("kind","")),{}).get("materials",{})
 needed=maxf(needed,float(plan.get(key,0)))
 if needed<=0 and state.reserve: needed=float({"boards":10,"dry":5,"furniture":4,"walls":2,"roofs":2,"parts":2,"paper":2}.get(key,0))
 var held=ConstructionRules.processing_reserve(state,key,total,needed) if protect else 0.0
 var result=[]
 # Protect the current bill once across the network, not once per dictionary.
 # Duplicate protection previously made two usable half-loads look unavailable.
 for candidate in candidates:
  var reserve=minf(held,float(candidate.available))
  held-=reserve
  candidate.available-=reserve
  if float(candidate.available)>=0.25: result.append(candidate)
 result.sort_custom(func(a,b):
  if not is_equal_approx(float(a.distance),float(b.distance)): return float(a.distance)<float(b.distance)
  if int(a.index)!=int(b.index): return int(a.index)<int(b.index)
  return bool(a.staged) and not bool(b.staged))
 return result

static func construction_sources(state: Dictionary,job: Dictionary,key: String) -> Array:
 var at=ConstructionRules.job_position(state,job)
 var choices=[]
 var center=CentralLogistics.depot(state)
 var direct=LogisticsRoutes.road_to_point(state,center,at) if center>=0 and not state.buildings[center].get("paused",false) else []
 var central_distance=LogisticsRoutes.length(direct) if direct.size()>=2 else INF
 var nearest={}
 var distance=INF
 for index in depots(state):
  var path=LogisticsRoutes.road_to_point(state,index,at)
  if path.size()<2: continue
  var length=LogisticsRoutes.length(path)
  if state.buildings[index].kind=="express" and length<distance and (central_distance>80 and length<central_distance*0.8):
   nearest={"kind":"express","index":index,"stock":state.hub.express.get(str(index),{})}
   distance=length
  for stock in inventories(state,index):
   if float(stock.get(key,0))>0:
    choices.append({"kind":state.buildings[index].kind,"index":index,"stock":stock,"distance":length})
 if not nearest.is_empty(): return [nearest]
 choices.sort_custom(func(a,b): return float(a.distance)<float(b.distance) if not is_equal_approx(float(a.distance),float(b.distance)) else int(a.index)<int(b.index))
 if not choices.is_empty(): return choices
 if direct.size()>=2: return [{"kind":"central_depot","index":center,"stock":state.resources}]
 return []
