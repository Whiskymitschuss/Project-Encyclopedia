class_name StreetScape
extends RefCounted

const ASPHALT=Color("485f70")
const WALK=Color("d9cba7")
const CURB=Color("f0ead5")

static func context(state: Dictionary) -> Dictionary:
 var plots=[]
 for i in state.buildings.size(): plots.append(Placement.bounds(LogisticsRoutes.building_position(state,i),int(state.buildings[i].get("rotation",0))))
 for i in state.homes.size(): plots.append(Placement.bounds(LogisticsRoutes.home_position(state,i),int(state.homes[i].get("rotation",0))))
 for job in state.jobs:
  if job.type not in ["home","building"]: continue
  var fallback=Catalog.home_position(int(job.plot)) if job.type=="home" else Catalog.industry_position(int(job.get("slot",0)))
  plots.append(Placement.bounds(Placement.position_of(job,fallback),int(job.get("rotation",0))))
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

static func strip(parent: Node3D,at: Vector3,size: Vector3,paved: bool,ctx: Dictionary={}) -> void:
 var vertical=size.z>size.x
 if vertical and size.z>300:
  for section in [[-172.0,-58.0],[-58.0,30.0],[30.0,180.0]]:
   strip(parent,Vector3(at.x,at.y,(section[0]+section[1])*0.5),Vector3(size.x,size.y,section[1]-section[0]),paved,ctx)
  return
 if at.z<=-60:
  var haul_size=Vector3(10,size.y,size.z) if vertical else Vector3(size.x,size.y,10)
  Models.paving_box(parent,haul_size,at,ProductionCampus.SAND,"plaster",0.8)
  return
 if ProductionCampus.inside(at):
  Models.box(parent,size,at,ProductionCampus.CONCRETE)
  for side in [-1,1]:
   var p=at+Vector3(side*(size.x/2-0.3),size.y/2+0.02,0) if vertical else at+Vector3(0,size.y/2+0.02,side*(size.z/2-0.3))
   Models.box(parent,Vector3(0.15,0.03,size.z) if vertical else Vector3(size.x,0.03,0.15),p,Color("fff4df"))
  return
 Models.paving_box(parent,size+Vector3(1.0,-0.04,1.0),at-Vector3(0,0.09,0),Color("b0b79c"),"plaster",0.8)
 Models.paving_box(parent,size,at,ASPHALT if paved else Color("b5a78a"),"asphalt" if paved else "plaster",0.65)
 if not paved: return
 var length=size.z if vertical else size.x
 var width=size.x if vertical else size.z
 var forward=Vector3.BACK if vertical else Vector3.RIGHT
 var side=Vector3.RIGHT if vertical else Vector3.BACK
 for d in range(-int(length/2)+3,int(length/2)-2,9):
  var p=at+forward*d
  var clear=true
  for j in ctx.get("junctions",[]):
   if Vector2(p.x,p.z).distance_to(j)<5.0: clear=false; break
  if clear: Models.box(parent,Vector3(0.18,0.025,2.5) if vertical else Vector3(2.5,0.025,0.18),p+Vector3(0,size.y/2+0.016,0),Color("e8d9ac"))
 # Sidewalk modules leave junctions, occupied lots, and bus shelters clear.
 for sign_value in [-1,1]:
  var count=floori(length/4.0)
  for i in count:
   var p=at+forward*(-length/2+2+i*4)+side*sign_value*(width/2+0.85)
   var rect=Rect2(Vector2(p.x,p.z)-Vector2(0.75,1.9) if vertical else Vector2(p.x,p.z)-Vector2(1.9,0.75),Vector2(1.5,3.8) if vertical else Vector2(3.8,1.5))
   var blocked=false
   for b in ctx.get("plots",[]):
    if rect.intersects(b): blocked=true; break
   for j in ctx.get("junctions",[]):
    if Vector2(p.x,p.z).distance_to(j)<6.5: blocked=true; break
   if blocked: continue
   Models.crafted_box(parent,Vector3(1.5,0.20,3.9) if vertical else Vector3(3.9,0.20,1.5),p+Vector3(0,0.10,0),WALK,"paving",0.07)
   var edge=p-side*sign_value*0.67
   Models.crafted_box(parent,Vector3(0.18,0.25,3.9) if vertical else Vector3(3.9,0.25,0.18),edge+Vector3(0,0.1,0),CURB,"plaster",0.04)

static func junctions(parent: Node3D,ctx: Dictionary) -> void:
 for p in ctx.junctions:
  if ProductionCampus.YARD.has_point(p): continue
  if p.y<=-60:
   Models.box(parent,Vector3(10,0.1,10),Vector3(p.x,0.87,p.y),ProductionCampus.SAND)
   continue
  # A single flush cap removes crossing lane dashes and rounds the corners.
  Models.paving_box(parent,Vector3(7.3,0.10,7.3),Vector3(p.x,0.87,p.y),ASPHALT,"asphalt",0.65)
  for side in [-1,1]:
   if not ctx.cells.has(Vector2i(p)+Vector2i(0,side*4)): continue
   for i in 4:
    Models.box(parent,Vector3(0.65,0.025,1.45),Vector3(p.x-1.65+i*1.1,0.94,p.y+side*5.5),Color("e8e1c9"))
  for sx in [-1,1]:
   for sz in [-1,1]:
    if not ctx.cells.has(Vector2i(p)+Vector2i(sx*4,0)) or not ctx.cells.has(Vector2i(p)+Vector2i(0,sz*4)): continue
    var rect=Rect2(p+Vector2(minf(sx*3.3,sx*5.3),minf(sz*3.3,sz*5.3)),Vector2(2,2))
    var free=true
    for plot in ctx.plots:
     if rect.intersects(plot): free=false; break
    if free: corner(parent,p,Vector2(sx,sz))

static func corner(parent: Node3D,p: Vector2,side: Vector2) -> void:
 var center=p+side*5.1
 Models.paving_box(parent,Vector3(1.8,0.08,1.8),Vector3(p.x+side.x*4.2,0.91,p.y+side.y*4.2),ASPHALT,"asphalt",0.05)
 var surface=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 8:
  var a=center+Vector2(cos(PI+i*PI/16),sin(PI+i*PI/16))*side*1.7
  var b=center+Vector2(cos(PI+(i+1)*PI/16),sin(PI+(i+1)*PI/16))*side*1.7
  for at in [center,a,b] if side.x*side.y>0 else [center,b,a]:
   surface.set_normal(Vector3.UP)
   surface.set_uv(at/4.0)
   surface.add_vertex(Vector3(at.x,0.99,at.y))
  var mid=(a+b)/2
  var edge=Models.crafted_box(parent,Vector3(0.2,0.22,a.distance_to(b)+0.04),Vector3(mid.x,0.98,mid.y),CURB,"plaster",0.04)
  edge.rotation.y=atan2(b.x-a.x,b.y-a.y)
 var mesh=MeshInstance3D.new()
 mesh.mesh=surface.commit()
 mesh.material_override=SurfaceLibrary.material(WALK,"paving")
 parent.add_child(mesh)
