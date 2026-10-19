class_name LogisticsRoutes
extends RefCounted


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
 var cells = TownRules.road_cells(state.town)
 var start = TownRules.nearest(a,cells,32.0)
 var end = TownRules.nearest(b,cells,32.0)
 if start==null or end==null: return []
 var network = TownRules.graph(cells)
 var raw = network.get_point_path(network.get_closest_point(Vector2(start)),network.get_closest_point(Vector2(end)))
 if raw.is_empty(): return []
 var result: Array = []
 # Docks terminate at the footprint edge, never inside the factory.
 var dock_a = a+(TownRules.point(start)-a).normalized()*(12.5)
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
