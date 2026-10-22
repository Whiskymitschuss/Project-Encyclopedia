class_name ProductionCampus
extends RefCounted

# Presentation only: the saved street graph, lots and freight routes stay authoritative.
const YARD=Rect2(-64,-58,128,128)
const CONCRETE=Color("b9b2af")
const SAND=Color("d7bb95")

static func inside(point: Vector3) -> bool:
 return YARD.has_point(Vector2(point.x,point.z))

static func clear(point: Vector2,ctx: Dictionary,radius: float=2) -> bool:
 for plot in ctx.plots:
  if plot.grow(radius).has_point(point): return false
 for cell in ctx.cells:
  if point.distance_to(Vector2(cell))<5+radius: return false
 for cell in ctx.get("walkways",[]):
  if point.distance_to(cell)<2+radius: return false
 return true

static func build(parent: Node3D,ctx: Dictionary) -> void:
 var yard=Node3D.new()
 yard.name="OpenProductionYard"
 parent.add_child(yard)
 # Each factory keeps its own paving. A blanket slab hid vacant lots and
 # visually joined homes, public streets and workshops into one grey carpet.
 yard.set_meta("shared_slab",false)
 # Forest compartments have broad sandy rims, with removable fences away from lots/roads.
 for biome in 10:
  var p=Catalog.biome_position(biome)
  Models.paving_box(yard,Vector3(76,0.05,66),p+Vector3(0,0.46,0),SAND,"plaster",2)
  Models.paving_box(yard,Vector3(69,0.07,59),p+Vector3(0,0.56,0),Color(Catalog.BIOMES[biome].ground).lerp(Color("98ce65"),0.55),"plaster",1.8)
  for x in range(-32,33,8):
   var at=Vector2(p.x+x,p.z+31)
   if not clear(at,ctx,1.2): continue
   Models.box(yard,Vector3(0.5,2.5,0.5),Vector3(at.x,1.6,at.y),Color("88522f"))
   Models.box(yard,Vector3(7.2,0.3,0.28),Vector3(at.x+3.6,2.2,at.y),Color("b67c44"))
 Models.bake(yard)

static func wall(parent: Node3D,at: Vector2,horizontal: bool) -> void:
 var size=Vector3(3.8,1.8,0.35) if horizontal else Vector3(0.35,1.8,3.8)
 Models.box(parent,size,Vector3(at.x,1.4,at.y),Color("fff3e3"))
 size.y=0.65
 Models.box(parent,size+Vector3(0.03,0,0.03),Vector3(at.x,1.1,at.y),Color("d6503a"))
