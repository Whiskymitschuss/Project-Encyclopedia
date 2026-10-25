class_name ForestCycle
extends RefCounted
const GROW_SECONDS=45.0
const LEGACY_GROW_SECONDS=90.0
const WALK_SPEED=8.0
static func initial() -> Dictionary: return {"stands":{},"tasks":[],"next_id":1,"assignment":-1,"revision":0,"harvested":0.0,"planted":0,"retry_at":0.0}
static func stand(state: Dictionary,biome: int) -> Dictionary:
 var id=str(biome)
 if not state.forest.stands.has(id): state.forest.stands[id]={"cells":{},"cursor":90}
 return state.forest.stands[id]
static func timber_per_tree(biome: int) -> float: return 24.0*(1+biome*0.4)
static func limit(state: Dictionary) -> int:
 if int(state.forest.assignment)>=0: return clampi(int(state.forest.assignment),0,int(state.workers))
 var workers=int(state.workers)
 var cells=state.forest.stands.get(str(int(state.biome)),{}).get("cells",{})
 var unavailable=0
 for cell in cells.values():
  if cell.state!="mature": unavailable+=1
 # Preserve ordinary felling capacity in a healthy forest. Rebuild depleted
 # stands before they turn into an endless queue of empty planting sites.
 var fraction=0.5+0.3*clampf((unavailable-30.0)/40.0,0,1)
 return mini(workers,maxi(1,ceili(workers*fraction)))
static func busy(state: Dictionary) -> int: return state.forest.tasks.size()
static func take(state: Dictionary,biome: int,wanted: float) -> float:
 if wanted<=0: return 0.0
 var data=stand(state,biome)
 var result=0.0
 var first=int(data.cursor)
 var rectangles=ForestLayout.rectangles(state)
 for offset in 100:
  var index=(first+offset)%100
  var id=str(index)
  var cell=data.cells.get(id,{"state":"mature","wood":timber_per_tree(biome)})
  if cell.state!="mature": continue
  var p=ForestLayout.point(biome,index)
  var route=ForestLayout.path(biome,index)
  if rectangles.any(func(rectangle): return rectangle.has_point(Vector2(p.x,p.z)) or ForestLayout.intersects(route,rectangle.grow(0.4))): continue
  var amount=minf(maxf(0,wanted-result),float(cell.wood))
  if amount<=0: break
  cell.wood-=amount; result+=amount
  data.cells[id]=cell
  if float(cell.wood)<=0.000001:
   cell.state="stump"; cell.wood=0.0
   state.forest.retry_at=0.0
   state.forest.revision+=1
   data.cursor=(index+1)%100
  else: data.cursor=index
  if result>=wanted-0.000001: break
 state.forest.harvested+=result
 return result
static func tick(state: Dictionary,delta: float) -> void:
 var done=[]
 for task in state.forest.tasks:
  task.age+=maxf(0,delta)
  if not task.planted and float(task.age)>=float(task.walk)+4:
   var cell=stand(state,int(task.biome)).cells.get(str(int(task.cell)),{})
   if not cell.is_empty() and cell.state=="stump" and not ForestLayout.blocked(state,int(task.biome),int(task.cell)):
    cell.state="growing"; cell.planted_at=float(state.elapsed); cell.grow_seconds=GROW_SECONDS; cell.ready_at=float(state.elapsed)+GROW_SECONDS
    state.forest.planted+=1; state.forest.revision+=1
   task.planted=true
  if float(task.age)>=float(task.total): done.append(task)
 for task in done: state.forest.tasks.erase(task)
 for biome in state.forest.stands:
  var cells=state.forest.stands[biome].cells
  for id in cells.keys():
   var cell=cells[id]
   if cell.state!="growing": continue
   # Old saves stored only the deadline of their 90-second seedlings. Keep
   # their elapsed growth, rather than restarting it or granting inventory.
   if not cell.has("grow_seconds"):
    cell.planted_at=float(cell.ready_at)-LEGACY_GROW_SECONDS
    cell.grow_seconds=GROW_SECONDS
    cell.ready_at=float(cell.planted_at)+GROW_SECONDS
    state.forest.revision+=1
   if float(cell.ready_at)<=float(state.elapsed):
    cells.erase(id); state.forest.revision+=1
 var free=maxi(0,limit(state)-busy(state))
 if free<=0 or float(state.elapsed)<float(state.forest.retry_at): return
 state.forest.retry_at=float(state.elapsed)+1
 var biomes=state.forest.stands.keys()
 biomes.sort_custom(func(a,b): return int(a)<int(b))
 var current=str(int(state.biome))
 if current in biomes: biomes.erase(current); biomes.push_front(current)
 for biome in biomes:
  var cells=state.forest.stands[biome].cells
  var ids=cells.keys(); ids.sort_custom(func(a,b): return int(a)<int(b))
  for id in ids:
   if free<=0: return
   if cells[id].state!="stump" or ForestLayout.blocked(state,int(biome),int(id)) or not ForestLayout.walkable(state,int(biome),int(id)): continue
   if state.forest.tasks.any(func(task): return int(task.biome)==int(biome) and int(task.cell)==int(id)): continue
   var route=ForestLayout.path(int(biome),int(id))
   var distance=0.0
   for i in range(1,route.size()): distance+=route[i-1].distance_to(route[i])
   var walk=maxf(2,distance/WALK_SPEED)
   state.forest.tasks.append({"id":state.forest.next_id,"biome":int(biome),"cell":int(id),"age":0.0,"walk":walk,"total":walk*2+4,"planted":false})
   state.forest.next_id+=1; free-=1
static func availability(state: Dictionary) -> Dictionary:
 var biome=int(state.biome)
 var cells=state.forest.stands.get(str(biome),{}).get("cells",{})
 var result={"mature":0,"stumps":0,"growing":0,"next_ready":INF}
 var rectangles=ForestLayout.rectangles(state)
 for index in 100:
  var point=ForestLayout.point(biome,index)
  if rectangles.any(func(rect): return rect.has_point(Vector2(point.x,point.z))): continue
  var cell=cells.get(str(index),{"state":"mature"})
  if cell.state=="mature":
   var route=ForestLayout.path(biome,index)
   if not rectangles.any(func(rect): return ForestLayout.intersects(route,rect.grow(0.4))): result.mature+=1
  elif cell.state=="stump": result.stumps+=1
  elif cell.state=="growing":
   result.growing+=1
   var deadline=float(cell.ready_at) if cell.has("grow_seconds") else float(cell.ready_at)-LEGACY_GROW_SECONDS+GROW_SECONDS
   result.next_ready=minf(float(result.next_ready),maxf(0,deadline-float(state.elapsed)))
 return result

static func wait_reason(state: Dictionary) -> String:
 var info=availability(state)
 if int(info.mature)>0: return ""
 if int(info.growing)>0: return "Jungbäume erntereif in %s s" % ceili(float(info.next_ready))
 if limit(state)==0 and int(info.stumps)>0: return "Baumpflanzer deaktiviert · Team öffnen"
 if busy(state)>0: return "Baumpflanzer forsten auf"
 return "Waldzugang prüfen · keine erreichbaren Bäume"

static func status(state: Dictionary) -> String:
 var info=availability(state)
 var timing="Nächster Baum erntereif in %s s" % ceili(float(info.next_ready)) if int(info.growing)>0 else "Pflanzteam deaktiviert · Automatisch wählen" if limit(state)==0 and int(info.stumps)>0 else "Neue Bäume: %s s Wachstum nach dem Pflanzen" % int(GROW_SECONDS)
 return "%s Holzfäller verfügbar · %s Biber pflanzen oder kehren zurück\nAktueller Wald: %s erntereif · %s Jungbäume · %s offene Pflanzstellen\nPflanzteam: %s\n%s" % [maxi(0,int(state.workers)-busy(state)),busy(state),info.mature,info.growing,info.stumps,"automatisch bis %s Helfer" % limit(state) if int(state.forest.assignment)<0 else "bis %s Helfer zugewiesen" % limit(state),timing]
