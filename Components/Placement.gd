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

static func terrain_reason(point: Vector3, rotation: int, districts: int = 0) -> String:
 if not is_finite(point.x) or not is_finite(point.z): return "Ungültiger Standort"
 if absf(point.x)>68 or point.z < -146 or point.z>152:
  var side_unlocked = (point.x>0 and districts>=1) or (point.x<0 and districts>=2)
  if side_unlocked and absf(point.x)>=212 and absf(point.x)<=288 and point.z>=-144 and point.z<=136:
   if absf(absf(point.x)-200)<size_for(rotation).x/2+4: return "Zufahrt zum Stadtviertel freihalten"
   return ""
  return "Im Baugebiet platzieren · neue Stadtviertel unter Stadt erschließen"
 var size_value = size_for(rotation)/2
 for road_x in [-80,0,80]:
  if absf(point.x-road_x)<size_value.x+3.5: return "Straße freihalten"
 for road_z in ROADS:
  if absf(point.z-road_z)<size_value.y+3.5: return "Straße freihalten"
 return ""

static func approach(point: Vector3, rotation: int) -> PackedVector3Array:
 var nearest = float(ROADS[0])
 for road in ROADS:
  if absf(point.z-float(road))<absf(point.z-nearest): nearest = float(road)
 var side = signf(nearest-point.z)
 return PackedVector3Array([point+Vector3(0,0.68,side*size_for(rotation).y/2),Vector3(point.x,0.68,nearest-side*3.5)])
