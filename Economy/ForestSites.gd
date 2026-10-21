class_name ForestSites
extends RefCounted

# All natural vegetation and forestry camps obey the same occupied ground.
static func obstacles(state: Dictionary, margin: float = 3.0) -> Array:
 var result=[WorldAccess.HIGHWAY_SITE.grow(margin),Rect2(316,70,30,142)]
 for i in state.buildings.size(): result.append(Placement.bounds(LogisticsRoutes.building_position(state,i),int(state.buildings[i].get("rotation",0))).grow(margin))
 for i in state.homes.size(): result.append(Placement.bounds(LogisticsRoutes.home_position(state,i),int(state.homes[i].get("rotation",0))).grow(margin))
 for job in state.jobs:
  if job.type in ["building","home"]: result.append(Placement.bounds(ConstructionRules.job_position(state,job),int(job.get("rotation",0))).grow(margin))
 for cell in TownRules.road_cells(state.town):
  result.append(Rect2(Vector2(cell)-Vector2.ONE*(3.6+margin),Vector2.ONE*(7.2+margin*2)))
 return result

static func clear_at(point: Vector3, obstacles: Array, radius: float = 0.0) -> bool:
 var p=Vector2(point.x,point.z)
 for rect in obstacles:
  if rect.grow(radius).has_point(p): return false
 return true

static func worksite(biome: int, index: int, obstacles: Array, used: Array, radius: float = 7.0) -> Variant:
 var center=Catalog.biome_position(biome)
 # A bounded search stays inside the selected biome; no work in locked forests.
 for i in 96:
  var angle=(i+index*7)*2.399963
  var r=7.0+sqrt(float(i)/96.0)*27.0
  var point=center+Vector3(cos(angle)*r,0,sin(angle)*r*0.84)
  if not clear_at(point,obstacles,radius): continue
  var free=true
  for other in used:
   if point.distance_to(other)<radius*1.6: free=false; break
  if free: return point
 return null
