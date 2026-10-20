class_name TownRules
extends RefCounted

const STEP = 4
const TYPES = {"asphalt":{"name":"Straße","width":6.0,"price":7.0,"color":"697f80"},"path":{"name":"Fußweg","width":2.4,"price":2.0,"color":"d9bd88"}}

static func initial() -> Dictionary:
 return {"districts":0,"roads":[],"stops":[],"lines":[],"next_stop":1,"next_line":1,"rent_auto":false,"rent_manager":false,"rent_collected":0.0,"trips_total":0}

static func snap(point: Vector3) -> Vector2i:
 return Vector2i(roundi(point.x/STEP)*STEP,roundi(point.z/STEP)*STEP)

static func point(cell: Vector2i) -> Vector3:
 return Vector3(cell.x,0,cell.y)

static func cell(value: Array) -> Vector2i:
 return Vector2i(int(value[0]),int(value[1]))

static func path(a: Vector2i, b: Vector2i, horizontal_first: bool = true) -> Array:
 var result = [a]
 var corner = Vector2i(b.x,a.y) if horizontal_first else Vector2i(a.x,b.y)
 for end in [corner,b]:
  var current: Vector2i = result.back()
  while current != end:
   current += Vector2i(signi(end.x-current.x),signi(end.y-current.y))*STEP
   result.append(current)
 return result

static func base_cells(districts: int = 0) -> Dictionary:
 var result = {}
 for x in [-80,0,80]:
  for z in range(-172,181,STEP): result[Vector2i(x,z)] = true
 for z in Placement.ROADS:
  for x in range(-80,81,STEP): result[Vector2i(x,int(z))] = true
 # Project access roads are real roads too. The closest grid centre stays on their asphalt.
 for project in Catalog.PROJECTS:
  var z = int(Catalog.project_road_z(project))
  var side = signi(int(project.position.x))
  for x in range(80,185,STEP): result[Vector2i(side*x,z)] = true
  for link_z in range(z-4,z+5,STEP): result[Vector2i(side*80,link_z)] = true
 for district in districts:
  var side = 1 if district==0 else -1
  for x in range(80,297,STEP): result[Vector2i(side*x,-160)] = true
  for z in range(-160,149,STEP): result[Vector2i(side*200,z)] = true
 return result

static func road_cells(town: Dictionary, exclude: int = -1) -> Dictionary:
 var result = base_cells(int(town.districts))
 for i in town.roads.size():
  if i==exclude or town.roads[i].kind!="asphalt": continue
  for p in town.roads[i].cells: result[cell(p)] = true
 return result

static func nearest(point_value: Vector3, cells: Dictionary, max_distance: float = 8.0) -> Variant:
 var best = null
 var distance = max_distance*max_distance+0.001
 for c in cells:
  var d = point_value.distance_squared_to(point(c))
  if d<distance: best=c; distance=d
 return best

static func graph(cells: Dictionary) -> AStar2D:
 var result = AStar2D.new()
 var ids = {}
 for c in cells:
  var id = ids.size()
  ids[c] = id
  result.add_point(id,Vector2(c))
 for c in ids:
  for offset in [Vector2i(STEP,0),Vector2i(0,STEP)]:
   if ids.has(c+offset): result.connect_points(ids[c],ids[c+offset])
 return result

static func route(town: Dictionary, stops: Array, exclude_road: int = -1) -> Dictionary:
 if stops.size()<2 or stops.size()>8: return {}
 var points = []
 for id in stops:
  var found = false
  for stop in town.stops:
   if int(stop.id)==int(id): points.append(Vector2(cell(stop.cell))); found=true; break
  if not found: return {}
 var cells = road_cells(town,exclude_road)
 for p in points:
  if not cells.has(Vector2i(p)): return {}
 var network = graph(cells)
 var legs = []
 var duration = 0.0
 for i in points.size():
  var a: Vector2 = points[i]
  var b: Vector2 = points[(i+1)%points.size()]
  if a==b: return {}
  var sequence = network.get_point_path(network.get_closest_point(a),network.get_closest_point(b))
  if sequence.size()<2: return {}
  var length = 0.0
  for j in range(1,sequence.size()): length += sequence[j-1].distance_to(sequence[j])
  var travel = length/12.0
  legs.append({"points":sequence,"travel":travel,"start":duration,"length":length})
  duration += 4.0+travel
 return {"legs":legs,"duration":duration}

static func bus_sample(plan: Dictionary, phase: float) -> Dictionary:
 if plan.is_empty(): return {"position":Vector3.ZERO,"direction":Vector3.FORWARD,"waiting":true}
 var clock = fposmod(phase,float(plan.duration))
 for leg in plan.legs:
  var points: PackedVector2Array = leg.points
  var local = clock-float(leg.start)
  if local < 0 or local >= 4.0+float(leg.travel): continue
  if local<4.0:
   var direction = points[1]-points[0]
   return {"position":Vector3(points[0].x,0.95,points[0].y),"direction":Vector3(direction.x,0,direction.y),"waiting":true}
  var encoded=[]
  for p in points: encoded.append([p.x,0.95,p.y])
  var sample=LogisticsRoutes.sample(encoded,(local-4.0)/maxf(float(leg.travel),0.001))
  return {"position":sample.position,"direction":sample.direction,"waiting":false}
 return bus_sample(plan,0)
