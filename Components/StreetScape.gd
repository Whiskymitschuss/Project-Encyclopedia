class_name StreetScape
extends RefCounted

const ASPHALT=TycoonStyle.ASPHALT
const WALK=TycoonStyle.SAND
const CURB=Color("f0ead5")

static func context(state: Dictionary) -> Dictionary:
 var plots=[]
 for i in state.buildings.size(): plots.append(Placement.bounds(LogisticsRoutes.building_position(state,i),int(state.buildings[i].get("rotation",0)),state.buildings[i].kind))
 for i in state.homes.size(): plots.append(Placement.bounds(LogisticsRoutes.home_position(state,i),int(state.homes[i].get("rotation",0))))
 for job in state.jobs:
  if job.type not in ["home","building"]: continue
  var fallback=Catalog.home_position(int(job.plot)) if job.type=="home" else Catalog.industry_position(int(job.get("slot",0)))
  plots.append(Placement.bounds(Placement.position_of(job,fallback),int(job.get("rotation",0)),str(job.get("kind",""))))
 for stop in state.town.stops: plots.append(Rect2(Vector2(TownRules.cell(stop.cell))-Vector2(5,5),Vector2(10,10)))
 var cells=TownRules.road_cells(state.town)
 var walkways=[]
 for road in state.town.roads:
  if road.kind=="path":
   for cell in road.cells: walkways.append(Vector2(TownRules.cell(cell)))
 var junctions=[]
 for cell in cells:
  var count=0
  for d in [Vector2i(4,0),Vector2i(-4,0),Vector2i(0,4),Vector2i(0,-4)]:
   if cells.has(cell+d): count+=1
  if count>=3: junctions.append(Vector2(cell))
 return {"plots":plots,"junctions":junctions,"cells":cells,"walkways":walkways}

static func strip(parent: Node3D,at: Vector3,size: Vector3,paved: bool,_ctx: Dictionary={}) -> void:
 # Placement preview only. The real map is one union in StreetSurface.build.
 var surface=Models.box(parent,Vector3(size.x,0.08,size.z),Vector3(at.x,StreetSurface.ROAD_Y-0.04,at.z),ASPHALT if paved else ProductionCampus.SAND)
 surface.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
