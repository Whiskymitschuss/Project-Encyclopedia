class_name Placement
extends RefCounted

const ROADS = [-160.0,-60.0,-28.0,4.0,36.0,68.0,100.0,132.0,164.0]
const FOOTPRINT = Vector2(19,23)

static func snap(point: Vector3) -> Vector3:
 return Vector3(snappedf(point.x,2.0),0,snappedf(point.z,2.0))

static func size_for(rotation: int) -> Vector2:
 return Vector2(23,19) if posmod(rotation,180)==90 else FOOTPRINT

static func position_of(record: Dictionary, fallback: Vector3) -> Vector3:
 var point = record.get("position",[])
 if point is Array and point.size()==2: return Vector3(float(point[0]),0,float(point[1]))
 return fallback

static func bounds(point: Vector3, rotation: int) -> Rect2:
 var size_value = size_for(rotation)
 return Rect2(Vector2(point.x,point.z)-size_value/2,size_value)

static func terrain_reason(point: Vector3, rotation: int, _districts: int = 0) -> String:
 # Geographic access is owned by WorldAccess. This helper protects actual roads,
 # rather than projecting every central road infinitely across the whole island.
 if not is_finite(point.x) or not is_finite(point.z): return "Ungültiger Standort"
 var rectangle=bounds(point,rotation).grow(3.5)
 for c in TownRules.base_cells(_districts):
  if rectangle.has_point(Vector2(c)): return "Straße freihalten"
 return ""

static func approach(point: Vector3, rotation: int, town: Dictionary = {}) -> PackedVector3Array:
 var cells=TownRules.base_cells() if town.is_empty() else TownRules.road_cells(town)
 var nearest=TownRules.nearest(point,cells,22)
 if nearest==null: return PackedVector3Array()
 var road=TownRules.point(nearest)
 var direction=(road-point).normalized()
 var half=size_for(rotation)/2
 var edge=minf(half.x/maxf(absf(direction.x),0.001),half.y/maxf(absf(direction.z),0.001))
 return PackedVector3Array([point+direction*edge+Vector3.UP*0.68,road-direction*3.5+Vector3.UP*0.68])
