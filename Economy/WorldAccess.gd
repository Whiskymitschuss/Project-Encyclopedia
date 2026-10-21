class_name WorldAccess
extends RefCounted

# Matches the level terrace in ValleyLandscape, before coast, river and hills.
const LAND = Rect2(-310,-183,620,368)
const BIOME_RADIUS = Vector2(43,39)
const HIGHWAY_SITE = Rect2(284,155,60,47)

static func biome_reason(rectangle: Rect2, unlocked: int) -> String:
 for i in range(clampi(unlocked,0,Catalog.BIOMES.size()),Catalog.BIOMES.size()):
  var center=Catalog.biome_position(i)
  var closest=Vector2(clampf(center.x,rectangle.position.x,rectangle.end.x),clampf(center.z,rectangle.position.y,rectangle.end.y))
  var normalized=(closest-Vector2(center.x,center.z))/BIOME_RADIUS
  if normalized.length_squared()<=1.0: return "Biom gesperrt · %s zuerst erschließen" % Catalog.BIOMES[i].name
 return ""

static func land_reason(rectangle: Rect2, unlocked: int) -> String:
 if not LAND.encloses(rectangle): return "Auf ebenem Festland bauen · Gewässer und Berghänge freihalten"
 return biome_reason(rectangle,unlocked)

static func building_reason(point: Vector3, rotation: int, unlocked: int) -> String:
 if not is_finite(point.x) or not is_finite(point.z): return "Ungültiger Standort"
 var rectangle=Placement.bounds(point,rotation)
 var reason=land_reason(rectangle,unlocked)
 if not reason.is_empty(): return reason
 if rectangle.intersects(HIGHWAY_SITE): return "Autobahnanschluss und Auffahrt freihalten"
 return ""
