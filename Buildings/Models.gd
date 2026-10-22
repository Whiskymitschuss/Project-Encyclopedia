class_name Models
extends RefCounted

const WORLD_LABEL_LAYER=1<<19

static var materials: Dictionary = {}
static var grain: ImageTexture

static func material(color: Color, glow: bool = false) -> StandardMaterial3D:
 var key = str(color)+str(glow)
 if materials.has(key): return materials[key]
 var result = StandardMaterial3D.new()
 result.albedo_color = color
 result.roughness = 0.76
 if grain == null:
  var image = Image.create(32,32,false,Image.FORMAT_RGB8)
  for y in 32:
   for x in 32:
    var value = 0.96+float((x*13+y*7)%5)*0.01
    if y%8==0: value = 0.91
    image.set_pixel(x,y,Color(value,value,value))
  image.generate_mipmaps()
  grain = ImageTexture.create_from_image(image)
 # Flat painted silhouettes; timber and paving use SurfaceLibrary deliberately.
 # A stretched grain texture on every box made roads and vehicle panels streaky.
 if glow:
  result.emission_enabled = true
  result.emission = color
  result.emission_energy_multiplier = 0.65
 materials[key] = result
 return result

static func box(parent: Node3D, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
 var node = MeshInstance3D.new()
 var mesh = BoxMesh.new()
 mesh.size = size
 node.mesh = mesh
 node.material_override = material(color)
 node.position = at
 parent.add_child(node)
 return node

static func crafted_box(parent: Node3D,size: Vector3,at: Vector3,color: Color,finish: String="plaster",radius: float=0.16) -> MeshInstance3D:
 var node=MeshInstance3D.new()
 node.mesh=CraftedGeometry.rounded_box(size,radius)
 node.material_override=SurfaceLibrary.material(color,finish)
 node.position=at
 parent.add_child(node)
 return node

static func paving_box(parent: Node3D,size: Vector3,at: Vector3,color: Color,finish: String="paving",radius: float=0.65) -> MeshInstance3D:
 var node=MeshInstance3D.new()
 node.mesh=CraftedGeometry.rounded_slab(size,radius)
 node.material_override=SurfaceLibrary.material(color,finish)
 node.position=at
 parent.add_child(node)
 return node

static func cylinder(parent: Node3D, radius: float, height: float, at: Vector3, color: Color, top: float = -1.0) -> MeshInstance3D:
 var node = MeshInstance3D.new()
 var mesh = CylinderMesh.new()
 mesh.top_radius = radius if top < 0 else top
 mesh.bottom_radius = radius
 mesh.height = height
 mesh.radial_segments = 7
 mesh.rings = 1
 node.mesh = mesh
 node.material_override = material(color)
 node.position = at
 parent.add_child(node)
 return node

static func label(parent: Node3D, title: String, at: Vector3, size: int = 32) -> Label3D:
 var node = Label3D.new()
 node.layers=WORLD_LABEL_LAYER
 node.text = title
 node.position = at
 node.font_size = size
 node.pixel_size = 0.035
 node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
 node.modulate = Color("f7f0da")
 node.outline_modulate = Color("214549")
 node.outline_size = 8
 node.no_depth_test = true
 parent.add_child(node)
 return node

static func roof(parent: Node3D, width: float, depth: float, y: float, color: Color) -> void:
 for side in [-1,1]:
  var p = crafted_box(parent,Vector3(width*0.58,0.5,depth+1.3),Vector3(side*width*0.24,y,0),color,"roof",0.1)
  p.rotation.z = side * -0.43
  for z in range(-int(depth/2),int(depth/2)+1,2):
   var strip = box(parent,Vector3(width*0.58,0.10,0.10),Vector3(side*width*0.24,y+0.26,z),color.lightened(0.1))
   strip.rotation.z = side * -0.43

static func log_pile(parent: Node3D, at: Vector3, count: int = 4) -> void:
 for i in count:
  var p = cylinder(parent,0.4,3.2,at+Vector3((i%3)*0.8,0.4+int(i/3.0)*0.7,0),Color("bc8b58"))
  p.rotation.x = PI/2
  var end = cylinder(parent,0.32,0.04,at+Vector3((i%3)*0.8,0.4+int(i/3.0)*0.7,-1.62),Color("f2d197"))
  end.rotation.x = PI/2

static func building(kind: String, level: int, city: bool = false) -> Node3D:
 if kind in ["central_depot","express"] and not city: return load("res://Buildings/CentralDepotModels.gd").create(kind,level)
 if city: return load("res://Buildings/TownModels.gd").create(kind,level)
 if kind in ["quarry","stoneworks"]: return load("res://Buildings/StoneModels.gd").create(kind,level)
 if not city and (Catalog.RECIPES.has(kind) or kind in ["station","warehouse"]):
  return load("res://Buildings/FactoryModels.gd").create(kind,level)
 var root = Node3D.new()
 var definition = Catalog.HOMES[kind] if city else Catalog.BUILDINGS[kind]
 var tone = Color(definition.color)
 if Game.state.skin == "Modern": tone = tone.lerp(Color("82b2c3"),0.6)
 var floors = mini(1+int((level-1)/4.0),4)
 if not city and kind!="cabin": floors = 1
 if city and kind in ["apartments","office","hotel"]: floors += 1
 var width = 12.0
 var depth = 11.0
 var height = 3.6*floors
 box(root,Vector3(19,0.35,23),Vector3(0,0.15,0),Color("dbcba2"))
 for x in [-9,9]: box(root,Vector3(0.25,0.2,22.6),Vector3(x,0.4,0),Color("fff2c9"))
 if city and kind == "park":
  box(root,Vector3(17,0.2,20),Vector3(0,0.4,0),Color("82b76d"))
  box(root,Vector3(3,0.1,20),Vector3(0,0.55,0),Color("e3d5ab"))
  cylinder(root,2.0,0.9,Vector3(0,0.8,0),Color("8babb4"))
  cylinder(root,1.6,0.05,Vector3(0,1.27,0),Color("76c7d2"))
  for x in [-5,5]:
   cylinder(root,0.4,3,Vector3(x,1.8,-4),Color("b18a5f"))
   cylinder(root,2.4,4,Vector3(x,4.3,-4),Color("5d9c64"),0.5)
   load("res://Buildings/CozyProps.gd").bench(root,Vector3(x,0,4))
   load("res://Buildings/CozyProps.gd").planter(root,Vector3(x,0,7.5))
  bake(root)
  return root
 box(root,Vector3(width,0.7,depth),Vector3(0,0.65,0),Color("91a59c"))
 crafted_box(root,Vector3(width,height,depth),Vector3(0,height/2+0.9,0),Color("f0dfb7") if city else tone.lightened(0.23))
 for x in [-5.9,5.9]:
  box(root,Vector3(0.5,height+0.4,depth+0.2),Vector3(x,height/2+0.9,0),tone)
 for floor_id in floors:
  for x in [-3.5,3.5]:
   var win = box(root,Vector3(2.0,1.6,0.15),Vector3(x,2.7+floor_id*3.6,5.6),Color("91c8cc"))
   win.material_override = material(Color("eacb83"),true)
   box(root,Vector3(2.5,0.2,0.6),Vector3(x,1.8+floor_id*3.6,5.7),tone)
   box(root,Vector3(0.15,1.65,0.2),Vector3(x,2.7+floor_id*3.6,5.7),tone)
 box(root,Vector3(1.7,2.6,0.25),Vector3(0,2.15,5.6),Color("38565b"))
 box(root,Vector3(2.4,0.3,2),Vector3(0,0.8,6.3),Color("d5cbad"))
 roof(root,width,depth,height+2.0,tone.darkened(0.10))
 box(root,Vector3(1.1,2.8,1.2),Vector3(-3,height+2.8,-2),Color("87978f"))
 if not city:
  if kind!="cabin": log_pile(root,Vector3(-6,0.6,8),5)
  if kind=="sawmill":
   for side in [-1,1]: box(root,Vector3(0.22,3.8,3.2),Vector3(7.5+side*1.6,2.1,-3),Color("eabf57"))
   box(root,Vector3(3.4,3.8,0.22),Vector3(7.5,2.1,-4.6),Color("eabf57"))
   box(root,Vector3(3.4,1.3,0.22),Vector3(7.5,0.9,-1.4),Color("eabf57"))
   box(root,Vector3(3.2,0.3,3.2),Vector3(7.5,0.55,-3),Color("737f86"))
   var fill = box(root,Vector3(3.0,2.7,3.0),Vector3(7.5,1.7,-3),Color("e9c18a"))
   fill.name="SawdustFill"
  if kind in ["market","cabin"]:
   for x in [-4,-2,0,2,4]:
    var awning=box(root,Vector3(2,0.3,3.2),Vector3(x,4.3,6.5),Color("fff0cf") if x in [-2,2] else tone)
    awning.rotation.x=0.15
   if kind=="cabin": load("res://Buildings/CozyProps.gd").rest_area(root)
   for x in ([] if kind=="cabin" else [-5,5]):
    box(root,Vector3(2.5,0.65,1),Vector3(x,0.9,7.5),Color("a2774a"))
    for offset in [-0.7,0,0.7]: cylinder(root,0.28,0.5,Vector3(x+offset,1.5,7.5),Color("ed785a"),0.12)
  if Catalog.RECIPES.has(kind):
   box(root,Vector3(4.8,0.7,8.8),Vector3(5,1.1,8),Color("3f5e64"))
   box(root,Vector3(3.5,0.25,9),Vector3(5,1.65,8),Color("6e7f7b"))
   for z in range(4,13,2):
    var roll = cylinder(root,0.23,4,Vector3(5,1.8,z),Color("b5c1ae"))
    roll.rotation.z = PI/2
  if kind in ["sawmill","joinery","design"]:
   var saw = cylinder(root,1.1,0.2,Vector3(5,2.4,5),Color("d6e0cc"))
   saw.rotation.z = PI/2
   saw.name = "Saw"
  if kind == "kiln":
   box(root,Vector3(7,2.7,4),Vector3(0,2,7),Color("a0674f"))
   for x in [-2,0,2]: box(root,Vector3(1.2,1.7,0.2),Vector3(x,2,9.1),Color("e8b365"))
   for x in [-3,3]:
    cylinder(root,0.5,6.4,Vector3(x,5.1,-2),Color("a2b7c2"))
    cylinder(root,0.75,0.3,Vector3(x,8.4,-2),Color("e8d8ac"))
  if kind=="furniture":
   for x in [-4,-1,2]:
    box(root,Vector3(2.2,1.6,1.8),Vector3(x,1.2,8),Color("da9953"))
    box(root,Vector3(2.3,0.2,2.0),Vector3(x,2.1,8),Color("f1cc8c"))
  if kind in ["garage","warehouse","station"]:
   box(root,Vector3(7,3.4,0.2),Vector3(0,2.6,5.7),Color("607d82"))
   for y in [1.5,2.3,3.1]: box(root,Vector3(7,0.1,0.2),Vector3(0,y,5.9),Color("a7b4a5"))
  if kind == "research":
   cylinder(root,1.7,0.4,Vector3(0,height+4,0),Color("bad9d5"),0.3)
   for x in [-4,0,4]: box(root,Vector3(2.8,2.7,0.3),Vector3(x,2.8,5.7),Color("63cde0"))
   cylinder(root,0.12,4,Vector3(0,height+4,0),Color("ebd389"))
  if kind=="garage":
   for x in [-3,2]:
    box(root,Vector3(2.7,1.0,4),Vector3(x,1,8),Color("f4c75f"))
    box(root,Vector3(2.5,1.7,1.5),Vector3(x,2,9),Color("62becb"))
    for side in [-1,1]:
     for z in [7,9]:
      var wheel=cylinder(root,0.5,0.3,Vector3(x+side*1.4,0.8,z),Color("355466"))
      wheel.rotation.z=PI/2
  if level >= 5:
   for x in [-4,0,4]: box(root,Vector3(3,0.2,3),Vector3(x,height+2.7,0),Color("436b8c"))
  if level >= 10:
   cylinder(root,1.5,8,Vector3(8,4.5,-3),Color("c2d0c5"))
 else:
  for x in [-7,7]:
   box(root,Vector3(1.7,0.7,12),Vector3(x,0.7,-1),Color("77a366"))
  if kind == "clinic":
   box(root,Vector3(2.8,0.6,0.2),Vector3(0,height+0.1,5.8),Color("e37e73"))
   box(root,Vector3(0.6,2.8,0.2),Vector3(0,height+0.1,5.9),Color("e37e73"))
 if not city: IndustryEvolution.add_to(root,kind,level)
 root.set_meta("height",maxf(float(root.get_meta("height",0)),height+4.2))
 CraftedFrontage.decorate(root,kind,level,false)
 bake(root)
 return root

static func bake(root: Node3D) -> void:
 var batches = {}
 var old = []
 for child in root.get_children():
  if not child is MeshInstance3D or (child.name in ["Saw","Crane","SawdustFill"] or child.get_meta("animated",false)): continue
  var key = child.material_override
  if not batches.has(key):
   var surface = SurfaceTool.new()
   surface.begin(Mesh.PRIMITIVE_TRIANGLES)
   surface.set_material(key)
   batches[key] = surface
  batches[key].append_from(child.mesh,0,child.transform)
  old.append(child)
 for key in batches:
  var combined = MeshInstance3D.new()
  combined.mesh = batches[key].commit()
  root.add_child(combined)
 for child in old:
  root.remove_child(child)
  child.free()

static func construction(progress: float) -> Node3D:
 var root = Node3D.new()
 box(root,Vector3(19,0.35,23),Vector3(0,0.3,0),Color("c3b99b"))
 for x in [-6,6]:
  for z in [-5,5]:
   box(root,Vector3(0.6,2+progress*7,0.6),Vector3(x,1+progress*3.5,z),Color("d2ab71"))
 for y in [2,5]:
  box(root,Vector3(13,0.4,0.5),Vector3(0,y,-5),Color("d6b079"))
  box(root,Vector3(13,0.4,0.5),Vector3(0,y,5),Color("d6b079"))
 box(root,Vector3(0.7,13,0.7),Vector3(8,6.5,-5),Color("ecc263"))
 var arm = box(root,Vector3(15,0.6,0.6),Vector3(3,13,-5),Color("ecc263"))
 arm.name = "Crane"
 BeaverModels.cockpit(root,Vector3(6.5,11.2,-4.3),Vector3(1.7,1.6,1.8),Color("ecc263"),3,"industry")
 box(root,Vector3(0.1,7,0.1),Vector3(-3,9.5,-5),Color("485d61"))
 log_pile(root,Vector3(-6,0.4,7),5)
 bake(root)
 return root
