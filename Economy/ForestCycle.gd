class_name ForestCycle
extends RefCounted
const GROW_SECONDS=90.0
static func initial() -> Dictionary: return {"stands":{},"tasks":[],"next_id":1,"assignment":-1,"revision":0,"harvested":0.0,"planted":0,"retry_at":0.0}
static func stand(state: Dictionary,biome: int) -> Dictionary:
 var id=str(biome)
 if not state.forest.stands.has(id): state.forest.stands[id]={"cells":{},"cursor":90}
 return state.forest.stands[id]
static func timber_per_tree(biome: int) -> float: return 24.0*(1+biome*0.4)
static func limit(state: Dictionary) -> int:
 return mini(int(state.workers),maxi(1,ceili(int(state.workers)/2.0))) if int(state.forest.assignment)<0 else clampi(int(state.forest.assignment),0,int(state.workers))
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
  if rectangles.any(func(rectangle): return rectangle.has_point(Vector2(p.x,p.z))): continue
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
    cell.state="growing"; cell.ready_at=float(state.elapsed)+GROW_SECONDS
    state.forest.planted+=1; state.forest.revision+=1
   task.planted=true
  if float(task.age)>=float(task.total): done.append(task)
 for task in done: state.forest.tasks.erase(task)
 for biome in state.forest.stands:
  var cells=state.forest.stands[biome].cells
  for id in cells.keys():
   if cells[id].state=="growing" and float(cells[id].ready_at)<=float(state.elapsed):
    cells.erase(id); state.forest.revision+=1
 var free=maxi(0,limit(state)-busy(state))
 if free<=0 or float(state.elapsed)<float(state.forest.retry_at): return
 state.forest.retry_at=float(state.elapsed)+5
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
   var walk=maxf(2,distance/6.0)
   state.forest.tasks.append({"id":state.forest.next_id,"biome":int(biome),"cell":int(id),"age":0.0,"walk":walk,"total":walk*2+4,"planted":false})
   state.forest.next_id+=1; free-=1
static func status(state: Dictionary) -> String:
 var stumps=0; var growing=0
 for data in state.forest.stands.values():
  for cell in data.cells.values():
   if cell.state=="stump": stumps+=1
   elif cell.state=="growing": growing+=1
 return "%s Holzfäller verfügbar · %s Biber pflanzen oder kehren zurück\n%s offene Pflanzstellen · %s Jungbäume · %s gepflanzt\nPflanzteam: %s" % [maxi(0,int(state.workers)-busy(state)),busy(state),stumps,growing,int(state.forest.planted),"automatisch bis %s Helfer" % limit(state) if int(state.forest.assignment)<0 else "bis %s Helfer zugewiesen" % limit(state)]
