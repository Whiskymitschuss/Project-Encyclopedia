extends RefCounted

const STEEL=Color("eff2d9")
const DARK=Color("415a6d")
const WOOD=Color("d59b53")
const BLUE=Color("368dd2")
const RED=Color("ef7840")

static func create(kind: String, level: int) -> Node3D:
 # Shared factory finishes: lacquer, brushed metal, and unpolished timber.
 for color in [BLUE,RED,Color("27b6a7"),Color("b876c2")]:
  var paint=Models.material(color)
  paint.roughness=0.9
  paint.metallic=0.0
 var metal=Models.material(STEEL)
 metal.roughness=0.3
 metal.metallic=0.45
 Models.material(WOOD).roughness=0.9
 var root=Node3D.new()
 root.set_meta("open_factory",true)
 root.set_meta("kind",kind)
 # One shared floor inside the campus; retain a private slab for remote factories.
 var floor_mesh=Models.paving_box(root,Vector3(19,0.16,23),Vector3(0,0.46,0),ProductionCampus.CONCRETE,"plaster",1.0)
 floor_mesh.name="FactoryFloor"
 floor_mesh.set_meta("animated",true)
 # Paint clears the shared floor by > 5 cm: no coplanar borders or flicker.
 for side in [-1,1]:
  for z in range(-9,11,3): block(root,Vector3(0.3,0.025,1.5),Vector3(side*3.1,0.585,z),Color("ffdb51"))
 for x in [-7,-4,4,7]:
  var dash=block(root,Vector3(1.5,0.025,0.3),Vector3(x,0.585,10),Color("ffe58e"))
  dash.rotation.y=-0.5
 if kind in ["station","warehouse"]:
  depot(root,kind,level)
  IndustryEvolution.add_to(root,kind,level)
  CraftedFrontage.decorate(root,kind,level,false)
  Models.bake(root)
  return root
 var handler=load("res://Components/YardHandling.gd").new()
 handler.name="YardHandling"
 handler.depot_handler=true
 root.add_child(handler)
 var input=Node3D.new()
 input.name="InputStock"
 root.add_child(input)
 input.position=Vector3(-6.3,0.45,-4.5)
 var input_key=Catalog.RECIPES[kind]["in"].keys()[0]
 if kind in ["sawmill","paper","pellet"]: large_logs(input,6)
 else: planks(input,Vector3.ZERO,8)
 Models.bake(input)
 var output=Node3D.new()
 output.name="OutputStock"
 root.add_child(output)
 output.position=Vector3(6.3,0.45,5.5)
 if kind in ["furniture","design"]:
  for z in [-1.5,1.5]: chair(output,Vector3(0,0,z),Color("dda155") if kind=="furniture" else Color("ad78c1"))
 elif kind in ["paper","pellet"]:
  for z in [-1.5,1.5]: block(output,Vector3(2.5,1.7,2.0),Vector3(0,0.85,z),Color("e6d5a6"))
 else: planks(output,Vector3.ZERO,10)
 Models.bake(output)
 roller_bed(root,-7,-1.5)
 roller_bed(root,1.8,8.5)
 var machine=load("res://Components/ProductionMachine.gd").new()
 machine.name="Processing"
 machine.kind=kind
 machine.input_key=input_key
 machine.output_key=Catalog.RECIPES[kind].out.keys()[0]
 root.add_child(machine)
 var feed=Node3D.new()
 feed.name="Feed"
 feed.position=Vector3(0,2.6,-6)
 machine.add_child(feed)
 if kind=="sawmill":
  var log=Models.cylinder(feed,0.74,4.5,Vector3(0,0,0),Color("895633"))
  log.rotation.x=PI/2
  var end=Models.cylinder(feed,0.65,0.05,Vector3(0,0,2.28),Color("edc38a"))
  end.rotation.x=PI/2
  block(root,Vector3(4.9,0.8,3),Vector3(0,1.2,0),BLUE)
  for x in [-2.0,2.0]: block(root,Vector3(0.65,4,2.2),Vector3(x,2.4,0),RED)
  block(root,Vector3(4.8,0.65,2.2),Vector3(0,4.5,0),RED)
  block(root,Vector3(1.7,2,1.7),Vector3(-2.4,2.8,0),Color("27b6a7"))
  var rotor=Node3D.new()
  rotor.name="Rotor"
  rotor.position=Vector3(0,2.8,0)
  machine.add_child(rotor)
  var blade=Models.cylinder(rotor,1.65,0.16,Vector3.ZERO,STEEL)
  blade.rotation.z=PI/2
  for i in 12:
   var angle=i*TAU/12
   var tooth=block(rotor,Vector3(0.2,0.45,0.25),Vector3(0,cos(angle)*1.65,sin(angle)*1.65),STEEL)
   tooth.rotation.x=-angle
  Models.bake(rotor)
  sawdust_bin(root)
 elif kind=="kiln":
  planks(feed,Vector3.ZERO,3)
  block(root,Vector3(5.8,4.7,4.4),Vector3(0,2.8,0),Color("d59356"))
  block(root,Vector3(4.8,3.8,0.2),Vector3(0,2.5,2.25),Color("643c35"))
  var door=block(machine,Vector3(4.7,3.5,0.25),Vector3(0,2.6,2.45),Color("eaad62"))
  door.name="ToolHead"
  for x in [-1.8,1.8]:
   Models.cylinder(root,0.4,5,Vector3(x,6,-1),STEEL)
   Models.cylinder(root,0.65,0.25,Vector3(x,8.6,-1),DARK)
 elif kind in ["furniture","design","joinery","prefab"]:
  planks(feed,Vector3.ZERO,3)
  var tone=Color("b876c2") if kind=="design" else BLUE
  block(root,Vector3(5.4,1.3,4.5),Vector3(0,1.3,0),tone)
  block(root,Vector3(5.6,0.3,4.7),Vector3(0,2.1,0),STEEL)
  for x in [-2.3,2.3]: block(root,Vector3(0.45,3.7,0.5),Vector3(x,3.4,-1),tone)
  block(root,Vector3(5.0,0.55,0.65),Vector3(0,5.1,-1),tone)
  var tool=Node3D.new()
  tool.name="ToolHead"
  tool.position=Vector3(0,3.6,-1)
  machine.add_child(tool)
  block(tool,Vector3(1.1,1.6,1.1),Vector3.ZERO,Color("f1bd4a"))
  Models.cylinder(tool,0.18,1,Vector3(0,-1.2,0),STEEL)
  if kind=="prefab":
   for x in [-2,0,2]: block(root,Vector3(0.25,4.5,0.25),Vector3(x,3,-2.5),WOOD)
   for y in [1,5]: block(root,Vector3(4.5,0.3,0.25),Vector3(0,y,-2.5),WOOD)
 else:
  planks(feed,Vector3.ZERO,2)
  var tone=Color("5ea95d") if kind=="pellet" else Color("4bafc2")
  block(root,Vector3(5.4,2.8,4),Vector3(0,2,0),tone)
  for x in [-1.5,1.5]: Models.cylinder(root,1.2,2.6,Vector3(x,4.5,0),STEEL,1.7)
  var tool=block(machine,Vector3(2.3,0.35,2),Vector3(0,2.5,2.2),Color("e4b950"))
  tool.name="ToolHead"
 var product=Node3D.new()
 product.name="Product"
 product.visible=false
 product.position=Vector3(0,1.9,2.1)
 machine.add_child(product)
 if kind in ["furniture","design"]: chair(product,Vector3.ZERO,WOOD if kind=="furniture" else Color("ac79c6"))
 elif kind in ["paper","pellet"]: block(product,Vector3(1.7,1.4,1.9),Vector3(0,0.7,0),Color("f2e1b9"))
 elif kind=="prefab":
  for x in [-1,0,1]: block(product,Vector3(0.2,2.5,0.3),Vector3(x,1.25,0),WOOD)
  for y in [0.2,2.3]: block(product,Vector3(2.3,0.2,0.3),Vector3(0,y,0),WOOD)
 else: planks(product,Vector3.ZERO,3)
 Models.bake(feed)
 Models.bake(product)
 # Control station and service markings remain within the existing footprint.
 block(root,Vector3(1.2,1.3,1),Vector3(-3.8,1.3,1.2),BLUE)
 block(root,Vector3(0.9,0.6,0.15),Vector3(-3.8,2,1.75),Color("a1f3c3"))
 for z in [-4.5,-2.5,0,2.5,4.5]: block(root,Vector3(0.3,0.08,1.3),Vector3(-4.6,0.585,z),Color("ffe085"))
 if level>=5:
  for x in [-5,5]: block(root,Vector3(4.2,0.16,2.3),Vector3(x,6.1,-9),Color("326a9d"))
 if level>=10:
  Models.cylinder(root,1.0,5,Vector3(7,3,-7.5),STEEL)
  block(root,Vector3(2.6,1.3,2.6),Vector3(7,1.1,-7.5),BLUE)
 IndustryEvolution.add_to(root,kind,level)
 CraftedFrontage.decorate(root,kind,level,false)
 Models.bake(root)
 return root

static func roller_bed(root: Node3D, from: float, to: float) -> void:
 var center=(from+to)/2
 block(root,Vector3(3.3,0.55,to-from),Vector3(0,1.25,center),BLUE)
 for x in [-1.65,1.65]:
  block(root,Vector3(0.15,0.35,to-from),Vector3(x,1.65,center),STEEL)
  for z in [from+0.4,to-0.4]: block(root,Vector3(0.25,0.9,0.25),Vector3(x,0.8,z),STEEL)
 for step in range(ceili(from),floori(to)+1):
  var roll=Models.cylinder(root,0.22,3.1,Vector3(0,1.65,step),Color("9eafb1"))
  roll.rotation.z=PI/2

static func planks(root: Node3D, at: Vector3, count: int) -> void:
 for i in count:
  block(root,Vector3(0.65,0.3,3.6),at+Vector3((i%3-1)*0.78,0.25+int(i/3.0)*0.34,0),WOOD.lightened((i%2)*0.06))
 for z in [-1.1,1.1]: block(root,Vector3(2.7,0.25,0.3),at+Vector3(0,0.05,z),Color("94613e"))

static func large_logs(root: Node3D, count: int) -> void:
 for i in count:
  var point=Vector3((i%3-1)*1.25,0.65+int(i/3.0)*1.0,0)
  var log=Models.cylinder(root,0.62,5,point,Color("835232"))
  log.rotation.x=PI/2
  for end in [-1,1]:
   var face=Models.cylinder(root,0.54,0.04,point+Vector3(0,0,end*2.52),Color("edc389"))
   face.rotation.x=PI/2
   var ring=Models.cylinder(root,0.23,0.05,point+Vector3(0,0,end*2.55),Color("cc995e"))
   ring.rotation.x=PI/2

static func chair(root: Node3D, at: Vector3, color: Color) -> void:
 block(root,Vector3(1.8,0.4,1.8),at+Vector3(0,1.4,0),color)
 block(root,Vector3(1.8,1.4,0.3),at+Vector3(0,2.1,-0.75),color)
 for x in [-0.65,0.65]:
  for z in [-0.65,0.65]: block(root,Vector3(0.25,1.3,0.25),at+Vector3(x,0.7,z),Color("ad7947"))

static func sawdust_bin(root: Node3D) -> void:
 for side in [-1,1]: block(root,Vector3(0.22,3.8,3.2),Vector3(7.5+side*1.6,2.1,-3),Color("eabf57"))
 block(root,Vector3(3.4,3.8,0.22),Vector3(7.5,2.1,-4.6),Color("eabf57"))
 block(root,Vector3(3.4,1.3,0.22),Vector3(7.5,0.9,-1.4),Color("eabf57"))
 block(root,Vector3(3.2,0.3,3.2),Vector3(7.5,0.55,-3),DARK)
 var fill=block(root,Vector3(3,2.7,3),Vector3(7.5,1.7,-3),WOOD)
 fill.name="SawdustFill"

static func depot(root: Node3D, kind: String, level: int) -> void:
 for side in [-1,1]:
  var pile=Node3D.new()
  pile.name="DepotLeft" if side<0 else "DepotRight"
  pile.position=Vector3(side*4.8,0.5,0)
  root.add_child(pile)
  large_logs(pile,6+mini(level,3))
  Models.bake(pile)
 for x in [-8,8]:
  block(root,Vector3(0.6,5.5,0.6),Vector3(x,3,0),Color("f5bd49"))
 block(root,Vector3(16.4,0.6,0.7),Vector3(0,5.8,0),Color("f5bd49"))
 var hoist=load("res://Components/LoadingHoist.gd").new()
 hoist.name="LoadingHoist"
 root.add_child(hoist)
 if kind=="warehouse":
  for x in [-7,0,7]:
   block(root,Vector3(0.3,4.8,0.3),Vector3(x,2.9,7),BLUE)
  for y in [1,3,5]: block(root,Vector3(14.5,0.2,2.7),Vector3(0,y,7),BLUE)
  planks(root,Vector3(-4.5,1.2,7),6)
  planks(root,Vector3(4.5,3.2,7),6)
 else:
  block(root,Vector3(3,1.0,4),Vector3(0,1,7.5),Color("f1b844"))
  block(root,Vector3(2.5,1.8,1.5),Vector3(0,2.1,8.5),BLUE)
  for x in [-1.6,1.6]:
   for z in [6.5,8.5]:
    var wheel=Models.cylinder(root,0.55,0.3,Vector3(x,0.85,z),DARK)
    wheel.rotation.z=PI/2

static func block(root: Node3D,size: Vector3,at: Vector3,color: Color) -> MeshInstance3D:
 if minf(size.x,minf(size.y,size.z))>=0.4:
  return Models.crafted_box(root,size,at,color,"timber" if color==WOOD else "paint",0.24)
 return Models.box(root,size,at,color)
