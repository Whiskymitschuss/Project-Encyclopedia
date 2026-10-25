class_name LogisticsRoutes
extends RefCounted

static var curve_cache: Dictionary={}
static var route_cache: Dictionary={}
# Derived presentation data only; never written into trips or saves.
static var sample_cache: Dictionary={}
static var sample_builds=0

static func driving_path(points: Array) -> Array:
 # Keep authoritative saved checkpoints intact: reservations, road protection,
 # online/offline clocks and old deliveries continue to use the same graph.
 # The derived driving line rounds only orthogonal road corners, within asphalt.
 var key=hash(points)
 if curve_cache.has(key) and curve_cache[key].source==points: return curve_cache[key].line
 var compact=[]
 for p in points:
  var b=vector(p)
  if not compact.is_empty() and b.distance_to(compact.back())<0.0001: continue
  if compact.size()>=2:
   var a: Vector3=compact[-2]
   var c: Vector3=compact[-1]
   if (c-a).normalized().dot((b-c).normalized())>0.9999: compact.pop_back()
  compact.append(b)
 if compact.size()<2: return points
 var result=[points[0].duplicate()]
 for i in range(1,compact.size()-1):
  var a: Vector3=compact[i-1]
  var b: Vector3=compact[i]
  var c: Vector3=compact[i+1]
  var incoming=(b-a).normalized()
  var outgoing=(c-b).normalized()
  var axis_a=absf(incoming.x)<0.001 or absf(incoming.z)<0.001
  var axis_b=absf(outgoing.x)<0.001 or absf(outgoing.z)<0.001
  if not axis_a or not axis_b or absf(incoming.dot(outgoing))>0.01:
   result.append([b.x,b.y,b.z]); continue
  var radius=minf(1.6,minf(a.distance_to(b),c.distance_to(b))*0.35)
  var start=b-incoming*radius
  var end=b+outgoing*radius
  for step in 7:
   var t=step/6.0
   var p=start.lerp(b,t).lerp(b.lerp(end,t),t)
   result.append([p.x,p.y,p.z])
 result.append(points[-1].duplicate())
 if curve_cache.size()>=128: curve_cache.clear()
 curve_cache[key]={"source":points.duplicate(true),"line":result}
 return result

static func building_position(state: Dictionary, index: int) -> Vector3:
 var b = state.buildings[index]
 return Placement.position_of(b,Catalog.industry_position(int(b.get("slot",index))))

static func home_position(state: Dictionary, index: int) -> Vector3:
 var h = state.homes[index]
 return Placement.position_of(h,Catalog.home_position(int(h.plot)))

static func road_route(state: Dictionary, source: int, target: int) -> Array:
 return road_to_point(state,source,building_position(state,target))

static func road_to_point(state: Dictionary, source: int, target: Vector3) -> Array:
 return between(state,building_position(state,source),target)

static func between(state: Dictionary, a: Vector3, b: Vector3) -> Array:
 var key=hash([a,b,state.town.roads,int(state.town.districts)])
 if route_cache.has(key):
  var saved=route_cache[key]
  if saved.a==a and saved.b==b and saved.roads==state.town.roads and saved.districts==int(state.town.districts): return saved.path.duplicate(true)
 var path=calculate(state,a,b)
 if route_cache.size()>=128: route_cache.clear()
 route_cache[key]={"a":a,"b":b,"roads":state.town.roads.duplicate(true),"districts":int(state.town.districts),"path":path.duplicate(true)}
 return path

static func calculate(state: Dictionary, a: Vector3, b: Vector3) -> Array:
 var cells = TownRules.road_cells(state.town)
 var start = TownRules.nearest(a,cells,32.0)
 var end = TownRules.nearest(b,cells,32.0)
 if start==null or end==null: return []
 var network = TownRules.graph(cells)
 var raw = network.get_point_path(network.get_closest_point(Vector2(start)),network.get_closest_point(Vector2(end)))
 if raw.is_empty(): return []
 var result: Array = []
 # Park parallel on the road. A short perpendicular private approach cannot
 # safely contain a truck nose and a trailer beside an open conveyor.
 for v in raw: result.append([v.x,0.95,v.y])
 result.push_front(result[0].duplicate())
 result.append(result[-1].duplicate())
 return result

static func encode(points: PackedVector3Array) -> Array:
 var result: Array = []
 for p in points: result.append([p.x,p.y,p.z])
 return result

static func length(points: Array) -> float:
 var result = 0.0
 for i in range(1,points.size()): result += vector(points[i-1]).distance_to(vector(points[i]))
 return result

static func vector(p: Array) -> Vector3:
 return Vector3(float(p[0]),float(p[1]),float(p[2]))

static func sample(points: Array, fraction: float) -> Dictionary:
 if points.size()<2: return {"position":Vector3.ZERO,"direction":Vector3.FORWARD}
 var key=hash(points)
 var data=sample_cache.get(key,{})
 if data.is_empty() or data.source!=points:
  var line=driving_path(points)
  var positions=PackedVector3Array()
  var ends=PackedFloat64Array()
  var total=0.0
  for point in line: positions.append(vector(point))
  for i in range(1,positions.size()):
   total+=positions[i-1].distance_to(positions[i])
   ends.append(total)
  data={"source":points.duplicate(true),"positions":positions,"ends":ends,"total":total}
  # FIFO eviction avoids invalidating every active truck at once.
  if sample_cache.size()>=512: sample_cache.erase(sample_cache.keys()[0])
  sample_cache[key]=data
  sample_builds+=1
 var along=float(data.total)*clampf(fraction,0,1)
 var positions: PackedVector3Array=data.positions
 var ends: PackedFloat64Array=data.ends
 var low=0
 var high=ends.size()-1
 while low<high:
  var middle=(low+high)>>1
  if ends[middle]<along: low=middle+1
  else: high=middle
 # A duplicate first/last checkpoint is legal in older saved routes.
 while low<ends.size():
  var start=ends[low-1] if low>0 else 0.0
  var distance=ends[low]-start
  if along<=ends[low] and distance>0.00001:
   var a=positions[low];var b=positions[low+1]
   return {"position":a.lerp(b,(along-start)/distance),"direction":(b-a).normalized()}
  low+=1
 return {"position":positions[-1],"direction":(positions[-1]-positions[-2]).normalized()}

static func presentation_sample(points: Array, fraction: float) -> Dictionary:
 # Legacy saves retain their route, clocks and cargo; only their short private
 # approach is displayed at the adjacent public-road loading position.
 if points.size()<3 or float(points[-1][1])>1.1: return sample(points,fraction)
 var first=vector(points[0])
 var start=vector(points[1])
 var end=vector(points[-2])
 var last=vector(points[-1])
 var total=length(points)
 var along=clampf(fraction,0,1)*total
 if first.distance_to(start)>0.01 and along<=first.distance_to(start):
  return {"position":start,"direction":(vector(points[2])-start).normalized()}
 if last.distance_to(end)>0.01 and along>=total-last.distance_to(end):
  return {"position":end,"direction":(end-vector(points[-3])).normalized()}
 return sample(points,fraction)
