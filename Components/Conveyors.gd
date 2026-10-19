class_name ConveyorNetwork
extends Node3D

const SOURCES = {"sawmill":["station"],"warehouse":["station"],"kiln":["sawmill"],"furniture":["kiln"],"prefab":["kiln"],"joinery":["sawmill"],"pellet":["sawmill"],"paper":["sawmill"],"design":["furniture"],"market":["furniture"]}
var links: Array = []
var goods: MultiMesh
var road_spans: Array = []

func build() -> void:
 road_spans.clear()
 for project in Catalog.PROJECTS:
  var side=signf(project.position.x)
  road_spans.append([Vector2(side*80,Catalog.project_road_z(project)),Vector2(side*184,Catalog.project_road_z(project))])
 for road in Game.state.town.roads:
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
 var grid = AStarGrid2D.new()
 grid.region = Rect2i(-151,-88,303,178) if int(Game.state.town.districts)>0 else Rect2i(-39,-78,79,162)
 grid.cell_size = Vector2(2,2)
 grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
 grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
 grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
 grid.update()
 if int(Game.state.town.districts)>0:
  # Inter-district conveyors use the land corridors around standing forests.
  for biome in 10:
   var center=Catalog.biome_position(biome)
   if absf(center.x)<80: continue
   for x in range(floori((center.x-42)/2),ceili((center.x+42)/2)+1):
    for z in range(floori((center.z-35)/2),ceili((center.z+35)/2)+1):
     var id=Vector2i(x,z)
     if grid.is_in_boundsv(id): grid.set_point_solid(id,true)
  for project in Catalog.PROJECTS: mark_footprint(grid,project.position,0)
 for i in Game.state.buildings.size(): mark_footprint(grid,Game.building_position(i),int(Game.state.buildings[i].get("rotation",0)))
 for i in Game.state.homes.size(): mark_footprint(grid,Game.home_position(i),int(Game.state.homes[i].get("rotation",0)))
 for i in Game.state.buildings.size():
  var building = Game.state.buildings[i]
  if not SOURCES.has(building.kind): continue
  var target = Game.building_position(i)
  var provider = -1
  var closest = INF
  for j in Game.state.buildings.size():
   if Game.state.buildings[j].kind not in SOURCES[building.kind]: continue
   var distance = target.distance_squared_to(Game.building_position(j))
   if distance < closest: provider = j; closest = distance
  if provider<0: continue
  var start = port(grid,Game.building_position(provider),int(Game.state.buildings[provider].get("rotation",0)),target)
  var end = port(grid,target,int(building.get("rotation",0)),Game.building_position(provider))
  if start == Vector2i(999,999) or end==Vector2i(999,999): continue
  var raw = grid.get_point_path(start,end)
  if raw.size()<2: continue
  var points = PackedVector3Array()
  for p in raw: points.append(Vector3(p.x,elevation(p),p.y))
  var simplified = PackedVector3Array([points[0]])
  for k in range(1,points.size()-1):
   var a = (points[k]-points[k-1]).normalized()
   var b = (points[k+1]-points[k]).normalized()
   if a.dot(b)<0.999: simplified.append(points[k])
  simplified.append(points[-1])
  var length = 0.0
  for k in range(1,simplified.size()):
   length += simplified[k-1].distance_to(simplified[k])
   deck(simplified[k-1],simplified[k])
  links.append({"points":simplified,"length":length,"phase":float(i)/7.0,"target":i,"kind":building.kind})
  if links.size() >= (12 if Game.state.quality==0 else 24): break
 Models.bake(self)
 goods = MultiMesh.new()
 goods.transform_format = MultiMesh.TRANSFORM_3D
 goods.use_colors = true
 var mesh = BoxMesh.new()
 mesh.size = Vector3(1.4,0.65,1.2)
 goods.mesh = mesh
 goods.instance_count = links.size()*3
 var view = MultiMeshInstance3D.new()
 view.multimesh = goods
 var mat = Models.material(Color("f7c779")).duplicate()
 mat.vertex_color_use_as_albedo = true
 view.material_override = mat
 add_child(view)

func mark_footprint(grid: AStarGrid2D, at: Vector3, rotation: int) -> void:
 var rectangle = Placement.bounds(at,rotation).grow(0.5)
 for x in range(floori(rectangle.position.x/2),ceili(rectangle.end.x/2)+1):
  for z in range(floori(rectangle.position.y/2),ceili(rectangle.end.y/2)+1):
   var id = Vector2i(x,z)
   if grid.is_in_boundsv(id): grid.set_point_solid(id,true)

func port(grid: AStarGrid2D, at: Vector3, rotation: int, towards: Vector3) -> Vector2i:
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

func elevation(point: Vector2) -> float:
 var distance = absf(point.x)
 for x in [-80,80]: distance=minf(distance,absf(point.x-x))
 for z in Placement.ROADS: distance = minf(distance,absf(point.y-z))
 for span in road_spans:
  distance=minf(distance,point.distance_to(Geometry2D.get_closest_point_to_segment(point,span[0],span[1])))
 for district in int(Game.state.town.districts):
  var side=1 if district==0 else -1
  distance=minf(distance,absf(point.x-side*200))
  if point.x*side>=80: distance=minf(distance,absf(point.y+160))
 # Cross roads on raised conveyor bridges; truck and bus clearance remains free.
 return 1.8+4.6*clampf((12.0-distance)/8.0,0,1)

func deck(from: Vector3, to: Vector3) -> void:
 var center = (from+to)/2
 var basis = Basis.looking_at((to-from).normalized(),Vector3.UP)
 var length = from.distance_to(to)
 var belt = Models.box(self,Vector3(2.4,0.3,length+0.15),center,Color("3f6670"))
 belt.basis = basis
 for side in [-1,1]:
  var rail = Models.box(self,Vector3(0.15,0.65,length+0.15),center+basis.x*side*1.25+Vector3(0,0.25,0),Color("f3c45b"))
  rail.basis = basis
 if (center.y>3 or length>6) and elevation(Vector2(center.x,center.z))<6.0:
  for side in [-1,1]: Models.box(self,Vector3(0.35,center.y,0.35),Vector3(center.x,center.y/2,center.z)+basis.x*side*1.0,Color("6f8e93"))

func point_at(link: Dictionary, distance: float) -> Vector3:
 var points = link.points
 for i in range(1,points.size()):
  var length = points[i-1].distance_to(points[i])
  if distance<=length: return points[i-1].lerp(points[i],distance/maxf(length,0.001))
  distance -= length
 return points[-1]

func _process(delta: float) -> void:
 if goods==null: return
 for i in links.size():
  var link = links[i]
  var rate = float(Game.flow.get("building:%s" % link.target,0))
  if link.kind=="market": rate=float(Game.flow.get("export",0))
  if link.kind=="warehouse": rate=float(Game.flow.get("harvest",0))
  if rate>0: link.phase=fmod(float(link.phase)+delta*4.5/maxf(link.length,1),1.0)
  for j in 3:
   var position_value = point_at(link,fmod(float(link.phase)+j/3.0,1)*float(link.length))+Vector3(0,0.6,0)
   goods.set_instance_transform(i*3+j,Transform3D(Basis.IDENTITY,position_value))
   goods.set_instance_color(i*3+j,Color("fff2bf") if link.kind in ["furniture","design","market"] else Color.WHITE)
