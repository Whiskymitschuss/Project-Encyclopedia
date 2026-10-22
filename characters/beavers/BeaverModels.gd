class_name BeaverModels
extends RefCounted

# Standing adults are about 1.9 world units including helmet. Seated road
# operators use the same anatomy at 0.55, keeping vehicles and staff compatible.
# Shape, face, age details and silhouette vary independently of work clothes.
const VARIANTS=[
 {"name":"Ben","fur":"a76c3e","body":1.0,"head":Vector3(0.73,0.66,0.57),"ears":0.22,"tail":Vector2(0.44,0.78),"muzzle":0.30},
 {"name":"Bruno","fur":"70513c","body":1.18,"head":Vector3(0.88,0.68,0.63),"ears":0.20,"tail":Vector2(0.54,0.83),"muzzle":0.36},
 {"name":"Pip","fur":"ca9559","body":0.84,"head":Vector3(0.70,0.71,0.53),"ears":0.25,"tail":Vector2(0.36,0.66),"muzzle":0.27},
 {"name":"Oskar","fur":"958473","body":1.04,"head":Vector3(0.79,0.62,0.60),"ears":0.20,"tail":Vector2(0.48,0.74),"muzzle":0.34},
 {"name":"Finn","fur":"a77248","body":0.89,"head":Vector3(0.66,0.70,0.53),"ears":0.23,"tail":Vector2(0.39,0.91),"muzzle":0.28},
 {"name":"Mira","fur":"b47d50","body":0.95,"head":Vector3(0.75,0.65,0.57),"ears":0.25,"tail":Vector2(0.43,0.75),"muzzle":0.29},
 {"name":"Nuri","fur":"b88a59","body":0.78,"head":Vector3(0.74,0.73,0.55),"ears":0.27,"tail":Vector2(0.34,0.60),"muzzle":0.27},
 {"name":"Taro","fur":"584534","body":1.11,"head":Vector3(0.81,0.69,0.63),"ears":0.19,"tail":Vector2(0.58,0.85),"muzzle":0.35},
 {"name":"Sunny","fur":"d29b4c","body":0.97,"head":Vector3(0.72,0.68,0.58),"ears":0.24,"tail":Vector2(0.43,0.79),"muzzle":0.34},
 {"name":"Nova","fur":"89664f","body":1.02,"head":Vector3(0.78,0.72,0.55),"ears":0.23,"tail":Vector2(0.49,0.88),"muzzle":0.30}]
const CLOTHES={"forester":Color("f47e35"),"industry":Color("328bc2"),"logistics":Color("79ad50"),"civilian":Color("aa7bb5"),"fire":Color("29485f")}
static var scenes={}
static var sphere_mesh: SphereMesh
static var palette: StandardMaterial3D

static func ball(parent: Node3D,at: Vector3,size: Vector3,color: Color) -> void:
 if sphere_mesh==null:
  sphere_mesh=SphereMesh.new()
  sphere_mesh.radius=1
  sphere_mesh.height=2
  sphere_mesh.radial_segments=10
  sphere_mesh.rings=5
 var mesh=MeshInstance3D.new()
 mesh.mesh=sphere_mesh
 mesh.material_override=Models.material(color)
 mesh.position=at
 mesh.scale=size
 parent.add_child(mesh)

static func part(parent: Node3D,name_value: String,at: Vector3) -> Node3D:
 var node=Node3D.new()
 node.name=name_value
 node.position=at
 parent.add_child(node)
 return node

static func create(variant_id: int,profession: String="civilian",seated: bool=false) -> Node3D:
 var id=posmod(variant_id,10)
 if not CLOTHES.has(profession): profession="civilian"
 var key="%s/%s/%s" % [id,profession,seated]
 if not scenes.has(key):
  var root=build(id,profession,seated)
  own(root,root)
  var scene=PackedScene.new()
  scene.pack(root)
  scenes[key]=scene
  root.free()
 return scenes[key].instantiate()

static func own(node: Node,root: Node) -> void:
 for child in node.get_children():
  child.owner=root
  own(child,root)

static func build(id: int,profession: String,seated: bool) -> Node3D:
 var data=VARIANTS[id]
 var fur=Color(data.fur)
 var muzzle=Color("efcc91")
 var shirt=CLOTHES[profession]
 var root=Node3D.new()
 root.set_script(load("res://characters/beavers/BeaverRig.gd"))
 root.seated=seated
 root.name="Beaver"
 if not seated: root.scale=Vector3.ONE*0.60*[1.0,1.10,0.88,0.95,1.04,0.98,0.81,1.06,0.97,1.02][id]
 root.set_meta("species","beaver")
 root.set_meta("variant_id",id)
 root.set_meta("profession",profession)
 root.set_meta("variant_name",data.name)
 var shift=-0.75 if seated else 0.0
 var torso=part(root,"Torso",Vector3(0,1.63+shift,0))
 ball(torso,Vector3.ZERO,Vector3(0.56*data.body,0.71,0.43),shirt)
 ball(torso,Vector3(0,0.11,0.33),Vector3(0.35*data.body,0.44,0.16),fur)
 if profession!="civilian":
  for side in [-1,1]: Models.box(torso,Vector3(0.10,0.93,0.08),Vector3(side*0.35*data.body,0,0.40),Color("ffdf77"))
  Models.box(torso,Vector3(1.03*data.body,0.10,0.09),Vector3(0,-0.29,0.44),Color("ffdf77"))
 else:
  Models.box(torso,Vector3(0.65,0.13,0.12),Vector3(0,0.57,0.4),Color("7dc1ab"))
 if profession=="industry":
  Models.box(torso,Vector3(1.12*data.body,0.15,0.85),Vector3(0,-0.45,0),Color("654b39"))
  Models.box(torso,Vector3(0.20,0.28,0.12),Vector3(0.4,-0.35,0.46),Color("b8c7c9"))
 var head=part(root,"Head",Vector3(0,2.60+shift,0.04))
 ball(head,Vector3.ZERO,data.head,fur)
 for side in [-1,1]:
  ball(head,Vector3(side*data.head.x*0.86,0.39,-0.05),Vector3(data.ears,data.ears,0.16),fur)
  ball(head,Vector3(side*data.head.x*0.9,0.39,0.075),Vector3(data.ears*0.6,data.ears*0.61,0.06),Color("d7a57c"))
  var eye=part(head,"EyeLeft" if side<0 else "EyeRight",Vector3(side*0.27,0.14,0.51))
  var young=id in [2,6]
  ball(eye,Vector3.ZERO,Vector3(0.185,0.24 if young else 0.21,0.085),Color("fff7e4"))
  ball(eye,Vector3(0,-0.01,0.073),Vector3(0.092,0.13,0.05),Color("352c28"))
  ball(eye,Vector3(0.028,0.04,0.114),Vector3(0.031,0.039,0.02),Color.WHITE)
  var brow=part(head,"BrowLeft" if side<0 else "BrowRight",Vector3(side*0.27,0.4,0.54))
  ball(brow,Vector3.ZERO,Vector3(0.22,0.09 if id==3 else 0.05,0.07),Color("d4c7b4") if id==3 else fur.darkened(0.35))
  brow.rotation.z=side*(0.23 if id==9 else -0.08)
  ball(head,Vector3(side*0.20,-0.16,0.58),Vector3(data.muzzle,0.22,0.24),muzzle)
  Models.crafted_box(head,Vector3(0.16,0.28,0.10),Vector3(side*0.095,-0.39,0.72),Color("fff3cf"),"plaster",0.035)
 ball(head,Vector3(0,-0.02,0.82),Vector3(0.19,0.115,0.12),Color("47372e"))
 if id==9: ball(head,Vector3(-0.33,0.36,0.35),Vector3(0.24,0.23,0.20),Color("e6d9c2"))
 if id in [4,5,6]:
  for i in 3: ball(head,Vector3((i-1)*0.12,0.61+0.06*i,0.15),Vector3(0.13,0.18,0.15),fur)
 if profession!="civilian":
  Models.cylinder(head,0.77,0.10,Vector3(0,0.55,0),Color("ffc643"))
  ball(head,Vector3(0,0.62,0),Vector3(0.64,0.31,0.57),Color("ffd45a"))
  Models.box(head,Vector3(0.11,0.18,0.92),Vector3(0,0.87,0),Color("ffe68c"))
 var tail=part(root,"Tail",Vector3(0,0.53,-0.35))
 ball(tail,Vector3(0,0,-0.58),Vector3(data.tail.x,0.14,data.tail.y),fur.darkened(0.4))
 for row in [-1,0,1]:
  var mark=Models.box(tail,Vector3(data.tail.x*1.35,0.035,0.055),Vector3(0,0.14,-0.57+row*0.28),fur.darkened(0.58))
  mark.rotation.y=0.36
 for i in 4:
  var arm=i>=2
  var limb=part(root,["LeftLeg","RightLeg","LeftArm","RightArm"][i],Vector3((-1 if i%2==0 else 1)*(0.59*data.body if arm else 0.24), (2.1 if arm else 1.1)+shift,0))
  ball(limb,Vector3(0,-0.34,0),Vector3(0.19,0.4 if arm else 0.36,0.21),shirt if arm else Color("38536b"))
  ball(limb,Vector3(0,-0.73,0.06),Vector3(0.20,0.17,0.21 if arm else 0.29),fur if arm else Color("3e3b35"))
  if seated: limb.rotation.x=-1.25 if arm else -1.48
  bake(limb)
 if seated:
  var steering=part(root,"Steering",Vector3(0,0.97,0.68))
  var ring=Models.cylinder(steering,0.34,0.07,Vector3.ZERO,Color("354a54"))
  ring.rotation.x=0.4
 for node in [torso,tail,head,head.get_node("EyeLeft"),head.get_node("EyeRight"),head.get_node("BrowLeft"),head.get_node("BrowRight")]: bake(node)
 return root

static func driver(parent: Node3D,at: Vector3,size: float=0.55,id: int=0,profession: String="logistics") -> Node3D:
 var rig=create(id,profession,true)
 rig.name="Driver"
 rig.position=at
 rig.scale=Vector3.ONE*size
 parent.add_child(rig)
 return rig

static func cockpit(parent: Node3D,at: Vector3,size: Vector3,color: Color,id: int=0,profession: String="logistics") -> Node3D:
 # Solid sills and roof, open windows. No opaque glass obscures the operator.
 Models.crafted_box(parent,Vector3(size.x,0.25,size.z),at,color,"paint",0.08)
 Models.crafted_box(parent,Vector3(size.x+0.12,0.15,size.z+0.12),at+Vector3(0,size.y,0),color,"paint",0.06)
 for side in [-1,1]:
  for end in [-1,1]: Models.box(parent,Vector3(0.10,size.y,0.10),at+Vector3(side*(size.x/2-0.06),size.y/2,end*(size.z/2-0.06)),color)
 var rig=driver(parent,at+Vector3(0,0.12,0.10),minf(0.66,(size.y-0.25)/2.55),id,profession)
 return rig

static func bake(parent: Node3D) -> void:
 # Vertex colours reduce a multi-colour body part to one mobile draw call.
 # PackedScene caching then shares these meshes between all identical rigs.
 var builder=SurfaceTool.new()
 builder.begin(Mesh.PRIMITIVE_TRIANGLES)
 var old=[]
 for child in parent.get_children():
  if not child is MeshInstance3D: continue
  old.append(child)
  var normal_basis=child.basis.inverse().transposed()
  var color=child.material_override.albedo_color
  var arrays=child.mesh.surface_get_arrays(0)
  var indices=arrays[Mesh.ARRAY_INDEX]
  var vertices=arrays[Mesh.ARRAY_VERTEX]
  var normals=arrays[Mesh.ARRAY_NORMAL]
  var order=indices if indices!=null and not indices.is_empty() else range(vertices.size())
  for index in order:
   builder.set_normal((normal_basis*normals[index]).normalized())
   builder.set_color(color)
   builder.add_vertex(child.transform*vertices[index])
 if old.is_empty(): return
 builder.index()
 var result=MeshInstance3D.new()
 result.mesh=builder.commit()
 if palette==null:
  palette=StandardMaterial3D.new()
  palette.vertex_color_use_as_albedo=true
  palette.roughness=0.82
 result.material_override=palette
 # All rigs disappear beyond the normal mobile crowd visibility budget.
 result.visibility_range_end=260
 for child in old:
  parent.remove_child(child)
  child.free()
 parent.add_child(result)
