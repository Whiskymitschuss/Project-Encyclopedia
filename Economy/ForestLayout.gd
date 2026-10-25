class_name ForestLayout
extends RefCounted
static var layout=[]
static var planting_cache={}

static func records() -> Array:
 if not layout.is_empty(): return layout
 var random=RandomNumberGenerator.new()
 random.seed=718233
 for biome in 10:
  var center=Catalog.biome_position(biome)
  var cells=[]
  for i in 100:
   var point=center+Vector3((i%10-4.5)*6+random.randf_range(-0.65,0.65),0,(int(i/10.0)-4.5)*5.2+random.randf_range(-0.65,0.65))
   if absf(point.x-80)<8: point.x=90
   if absf(point.x+80)<8: point.x=-90
   for project in Catalog.PROJECTS:
    if signf(point.x)==signf(project.position.x) and absf(point.x)>80 and absf(point.z-Catalog.project_road_z(project))<7: point.z-=14
    if point.distance_to(project.position)<18: point.x-=signf(point.x)*16
   var scale_value=random.randf_range(0.75,1.25)
   var record={"point":point,"scale":scale_value,"tones":[]}
   cells.append(record)
   # World foliage colours consume these same three seeded samples.
   for part in 3: record.tones.append(random.randf_range(0,0.13))
  layout.append(cells)
 return layout
static func point(biome: int,index: int) -> Vector3: return records()[biome][index].point
static func rectangles(state: Dictionary) -> Array:
 var result=[WorldAccess.HIGHWAY_SITE.grow(3),Rect2(316,70,30,142)]
 # Paid forestry machinery reserves its stands independently of camera detail.
 if int(state.tool)>=10:
  var center=Catalog.biome_position(int(state.biome))
  for x in [-26,-10,10,26]: result.append(Rect2(Vector2(center.x+x-4.5,center.z-9.5),Vector2(9,9)))
 for i in state.buildings.size(): result.append(Placement.bounds(LogisticsRoutes.building_position(state,i),int(state.buildings[i].get("rotation",0)),state.buildings[i].kind).grow(3))
 for i in state.homes.size(): result.append(Placement.bounds(LogisticsRoutes.home_position(state,i),int(state.homes[i].get("rotation",0))).grow(3))
 for job in state.jobs:
  if job.type in ["building","home"]:
   var fallback=Catalog.industry_position(int(job.get("slot",0))) if job.type=="building" else Catalog.home_position(int(job.plot))
   result.append(Placement.bounds(Placement.position_of(job,fallback),int(job.get("rotation",0)),str(job.kind)).grow(3))
 for road in state.town.roads:
  var radius=float(TownRules.TYPES[road.kind].width)/2+2
  for raw in road.cells:
   var p=Vector2(TownRules.cell(raw)); result.append(Rect2(p-Vector2.ONE*radius,Vector2.ONE*radius*2))
 return result
static func blocked(state: Dictionary,biome: int,index: int) -> bool:
 var p=point(biome,index)
 for rectangle in rectangles(state):
  if rectangle.has_point(Vector2(p.x,p.z)): return true
 return false
static func path(biome: int,index: int) -> Array:
 var center=Catalog.biome_position(biome)
 var target=point(biome,index)
 return [center+Vector3(34,0,34),Vector3(center.x+34,0,target.z+2.4),target+Vector3(0,0,2.4),target+Vector3(0,0,1.2)]
static func planting_path(state: Dictionary,biome: int,index: int,obstacles: Array=[]) -> Array:
 var bounds=rectangles(state) if obstacles.is_empty() else obstacles
 var key=str(biome)+":"+str(index)+":"+str(hash(bounds))
 if planting_cache.has(key) and planting_cache[key].bounds==bounds:
  return planting_cache[key].path.duplicate()
 var target=point(biome,index)
 var route=[]
 if not bounds.any(func(rect):return rect.has_point(Vector2(target.x,target.z))):
  var original=path(biome,index)
  if not bounds.any(func(rect):return intersects(original,rect.grow(0.4))):route=original
  else:
   # Keep the ordinary private aisle when clear; try the other forest sides
   # and approach the stump from a free side when a machine or plot blocks it.
   var center=Catalog.biome_position(biome)
   var best=INF
   for gate in [Vector3(34,0,34),Vector3(-34,0,34),Vector3(34,0,-29),Vector3(-34,0,-29)]:
    var start=center+gate
    for direction in [Vector3(0,0,1),Vector3(0,0,-1),Vector3(1,0,0),Vector3(-1,0,0)]:
     var aisle=target+direction*2.4
     var end=target+direction*1.2
     for corner in [Vector3(start.x,0,aisle.z),Vector3(aisle.x,0,start.z)]:
      var candidate=[start,corner,aisle,end]
      if bounds.any(func(rect):return intersects(candidate,rect.grow(0.4))):continue
      var length=0.0
      for i in range(1,candidate.size()):length+=candidate[i-1].distance_to(candidate[i])
      if length<best:route=candidate;best=length
 if planting_cache.size()>=512:planting_cache.clear()
 planting_cache[key]={"bounds":bounds,"path":route.duplicate()}
 return route
static func task_path(task: Dictionary) -> Array:
 if not task.has("route"):return path(int(task.biome),int(task.cell))
 var result=[]
 for point in task.route:result.append(LogisticsRoutes.vector(point))
 return result
static func walkable(state: Dictionary,biome: int,index: int) -> bool:
 return not planting_path(state,biome,index).is_empty()
static func intersects(route: Array,rectangle: Rect2) -> bool:
 for i in range(1,route.size()):
  var a=Vector2(route[i-1].x,route[i-1].z)
  var b=Vector2(route[i].x,route[i].z)
  if rectangle.has_point(a) or rectangle.has_point(b): return true
  var corners=[rectangle.position,Vector2(rectangle.end.x,rectangle.position.y),rectangle.end,Vector2(rectangle.position.x,rectangle.end.y)]
  for side in 4:
   if Geometry2D.segment_intersects_segment(a,b,corners[side],corners[(side+1)%4])!=null: return true
 return false
static func reserved(state: Dictionary,rectangle: Rect2) -> bool:
 for task in state.get("forest",{}).get("tasks",[]):
  if intersects(task_path(task),rectangle.grow(0.5)): return true
 return false

# Shared by felling representatives and the already authoritative planting paths.
# Choose a reachable standing tree, not a point on the outside spectator path.
static func worksite(state: Dictionary,slot: int,count: int) -> Dictionary:
 var biome=int(state.biome)
 var center=Catalog.biome_position(biome)
 var u=(slot+0.5)/maxi(1,count)
 # Leave the large boss trunk and its crown clear in the middle of the front.
 var across=lerpf(-27,-9,u*2) if u<0.5 else lerpf(9,27,(u-0.5)*2)
 var preferred=center+Vector3(across,0,24)
 var rectangles=rectangles(state)
 rectangles.append(Rect2(center.x-2,center.z+23,4,4)) # Boss trunk, not an ordinary work tree.
 var cells=state.get("forest",{}).get("stands",{}).get(str(biome),{}).get("cells",{})
 var candidates=[]
 for index in 100:
  if cells.get(str(index),{"state":"mature"}).state!="mature": continue
  var target=point(biome,index)
  if rectangles.any(func(rect): return rect.has_point(Vector2(target.x,target.z))): continue
  candidates.append({"index":index,"point":target,"distance":target.distance_squared_to(preferred)})
 candidates.sort_custom(func(a,b): return a.distance<b.distance)
 for candidate in candidates:
  var approach=planting_path(state,biome,int(candidate.index))
  if approach.is_empty():continue
  var origin: Vector3=approach[-1]
  if absf(origin.x-center.x)<8 and origin.z>center.z+17: continue
  var landing=center+Vector3(across*0.8,0,ForestryFlow.LANDING_EDGE)
  var route=approach.duplicate();route.reverse()
  var gate: Vector3=route[-1]
  var exits=[
   [Vector3(gate.x,0,landing.z),landing],
   [Vector3(center.x-34,0,gate.z),Vector3(center.x-34,0,landing.z),landing],
   [Vector3(center.x+34,0,gate.z),Vector3(center.x+34,0,landing.z),landing]]
  var complete=[]
  for exit in exits:
   var trial=route.duplicate();trial.append_array(exit)
   if not rectangles.any(func(rect):return intersects(trial,rect.grow(0.4))):complete=trial;break
  if complete.is_empty():continue
  route=complete
  return {"cell":int(candidate.index),"origin":route[0],"landing":landing,"route":LogisticsRoutes.encode(PackedVector3Array(route))}
 return {}
