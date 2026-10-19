class_name LogisticsRoutes
extends RefCounted

const SOURCES = {"sawmill":["station"],"warehouse":["station"],"kiln":["sawmill"],"furniture":["kiln"],"prefab":["kiln"],"joinery":["sawmill"],"pellet":["sawmill"],"paper":["sawmill"],"design":["furniture"],"market":["furniture"]}

static func building_position(state: Dictionary, index: int) -> Vector3:
 var b = state.buildings[index]
 return Placement.position_of(b,Catalog.industry_position(int(b.get("slot",index))))

static func home_position(state: Dictionary, index: int) -> Vector3:
 var h = state.homes[index]
 return Placement.position_of(h,Catalog.home_position(int(h.plot)))

static func belts(state: Dictionary) -> Array:
 var chain = state.get("delivery",{})
 var active = chain.get("active",false)
 var links: Array = []
 var road_spans = road_spans_for(state)
 var grid = AStarGrid2D.new()
 grid.region = Rect2i(-151,-88,303,178) if int(state.town.districts)>0 else Rect2i(-39,-78,79,162)
 grid.cell_size = Vector2(2,2)
 grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
 grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
 grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
 grid.update()
 if int(state.town.districts)>0:
  # Inter-district conveyors use the land corridors around standing forests.
  for biome in 10:
   var center=Catalog.biome_position(biome)
   if absf(center.x)<80: continue
   for x in range(floori((center.x-42)/2),ceili((center.x+42)/2)+1):
    for z in range(floori((center.z-35)/2),ceili((center.z+35)/2)+1):
     var id=Vector2i(x,z)
     if grid.is_in_boundsv(id): grid.set_point_solid(id,true)
  for project in Catalog.PROJECTS: mark_footprint(grid,project.position,0)
 for i in state.buildings.size(): mark_footprint(grid,building_position(state,i),int(state.buildings[i].get("rotation",0)))
 for i in state.homes.size(): mark_footprint(grid,home_position(state,i),int(state.homes[i].get("rotation",0)))
 for job in state.jobs:
  if job.type in ["building","home"]: mark_footprint(grid,ConstructionRules.job_position(state,job),int(job.get("rotation",0)))
 for i in state.buildings.size():
  var building = state.buildings[i]
  if not SOURCES.has(building.kind): continue
  if active and i==int(chain.nodes.market): continue
  var target = building_position(state,i)
  var provider = -1
  var closest = INF
  var source_kinds = ["sawmill"] if active and i==int(chain.nodes.furniture) else SOURCES[building.kind]
  var forced = int(chain.nodes.station) if active and i==int(chain.nodes.sawmill) else int(chain.nodes.sawmill) if active and i==int(chain.nodes.furniture) else -1
  for j in state.buildings.size():
   if state.buildings[j].kind not in source_kinds: continue
   if forced>=0 and j!=forced: continue
   var distance = target.distance_squared_to(building_position(state,j))
   if distance < closest: provider = j; closest = distance
  if provider<0: continue
  var start = port(grid,building_position(state,provider),int(state.buildings[provider].get("rotation",0)),target)
  var end = port(grid,target,int(building.get("rotation",0)),building_position(state,provider))
  if start == Vector2i(999,999) or end==Vector2i(999,999): continue
  var raw = grid.get_point_path(start,end)
  if raw.size()<2: continue
  var points = PackedVector3Array()
  for p in raw: points.append(Vector3(p.x,elevation(state,p,road_spans),p.y))
  var simplified = PackedVector3Array([points[0]])
  for k in range(1,points.size()-1):
   var a = (points[k]-points[k-1]).normalized()
   var b = (points[k+1]-points[k]).normalized()
   if a.dot(b)<0.999: simplified.append(points[k])
  simplified.append(points[-1])
  var length = 0.0
  for k in range(1,simplified.size()):
   length += simplified[k-1].distance_to(simplified[k])

  links.append({"points":simplified,"length":length,"phase":float(i)/7.0,"target":i,"source":provider,"kind":building.kind})

 return links

static func mark_footprint(grid: AStarGrid2D, at: Vector3, rotation: int) -> void:
 var rectangle = Placement.bounds(at,rotation).grow(0.5)
 for x in range(floori(rectangle.position.x/2),ceili(rectangle.end.x/2)+1):
  for z in range(floori(rectangle.position.y/2),ceili(rectangle.end.y/2)+1):
   var id = Vector2i(x,z)
   if grid.is_in_boundsv(id): grid.set_point_solid(id,true)

static func port(grid: AStarGrid2D, at: Vector3, rotation: int, towards: Vector3) -> Vector2i:
 var size_value = Placement.size_for(rotation)/2+Vector2(3,3)
 var result = Vector2i(999,999)
 var best = INF
 for offset in [Vector3(size_value.x,0,0),Vector3(-size_value.x,0,0),Vector3(0,0,size_value.y),Vector3(0,0,-size_value.y)]:
  var p = at+offset
  var id = Vector2i(roundi(p.x/2),roundi(p.z/2))
  if not grid.is_in_boundsv(id) or grid.is_point_solid(id): continue
  var distance = p.distance_squared_to(towards)
  if distance<best: result=id; best=distance
 return result

static func elevation(state: Dictionary, point: Vector2, road_spans: Array) -> float:
 var distance = absf(point.x)
 for x in [-80,80]: distance=minf(distance,absf(point.x-x))
 for z in Placement.ROADS: distance = minf(distance,absf(point.y-z))
 for span in road_spans:
  distance=minf(distance,point.distance_to(Geometry2D.get_closest_point_to_segment(point,span[0],span[1])))
 for district in int(state.town.districts):
  var side=1 if district==0 else -1
  distance=minf(distance,absf(point.x-side*200))
  if point.x*side>=80: distance=minf(distance,absf(point.y+160))
 # Cross roads on raised conveyor bridges; truck and bus clearance remains free.
 return 1.8+4.6*clampf((12.0-distance)/8.0,0,1)


static func road_route(state: Dictionary, source: int, target: int) -> Array:
 return road_to_point(state,source,building_position(state,target))

static func road_to_point(state: Dictionary, source: int, target: Vector3) -> Array:
 var cells = TownRules.road_cells(state.town)
 var a = building_position(state,source)
 var b = target
 var start = TownRules.nearest(a,cells,32.0)
 var end = TownRules.nearest(b,cells,32.0)
 if start==null or end==null: return []
 var network = TownRules.graph(cells)
 var raw = network.get_point_path(network.get_closest_point(Vector2(start)),network.get_closest_point(Vector2(end)))
 if raw.is_empty(): return []
 var result: Array = []
 # Docks terminate at the footprint edge, never inside the factory.
 var dock_a = a+(TownRules.point(start)-a).normalized()*(Placement.size_for(int(state.buildings[source].get("rotation",0))).y/2+1)
 var dock_b = b+(TownRules.point(end)-b).normalized()*(11.5+1)
 result.append([dock_a.x,0.95,dock_a.z])
 for v in raw: result.append([v.x,0.95,v.y])
 result.append([dock_b.x,0.95,dock_b.z])
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
 var along = length(points)*clampf(fraction,0,1)
 for i in range(1,points.size()):
  var a = vector(points[i-1])
  var b = vector(points[i])
  var d = a.distance_to(b)
  if along<=d and d>0.00001: return {"position":a.lerp(b,along/d),"direction":(b-a).normalized()}
  along -= d
 return {"position":vector(points[-1]),"direction":(vector(points[-1])-vector(points[-2])).normalized()}


static func road_spans_for(state: Dictionary) -> Array:
 var road_spans: Array = []
 for project in Catalog.PROJECTS:
  var side=signf(project.position.x)
  road_spans.append([Vector2(side*80,Catalog.project_road_z(project)),Vector2(side*184,Catalog.project_road_z(project))])
 for road in state.town.roads:
  if road.kind!="asphalt": continue
  var start=Vector2(TownRules.cell(road.cells[0]))
  var previous=start
  var last_direction=Vector2.ZERO
  for i in range(1,road.cells.size()):
   var p=Vector2(TownRules.cell(road.cells[i]))
   var direction=(p-previous).normalized()
   if last_direction!=Vector2.ZERO and direction!=last_direction:
    road_spans.append([start,previous])
    start=previous
   last_direction=direction
   previous=p
  road_spans.append([start,previous])
 return road_spans
