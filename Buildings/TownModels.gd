class_name TownModels
extends RefCounted

const CREAM = Color("fff0cc")
const GLASS = Color("64c8da")
const DARK = Color("285467")

static func block(root: Node3D, size: Vector3, at: Vector3, color: Color) -> void:
 Models.box(root,size,at,color)

static func windows(root: Node3D, width: float, y: float, z: float, count: int, tone: Color) -> void:
 for i in count:
  var x = (i-(count-1)/2.0)*width
  block(root,Vector3(1.7,1.6,0.22),Vector3(x,y,z),DARK)
  block(root,Vector3(1.4,1.3,0.25),Vector3(x,y,z+0.04),GLASS)
  block(root,Vector3(2.0,0.17,0.55),Vector3(x,y-0.9,z+0.1),tone)

static func entrance(root: Node3D, x: float = 0, z: float = 5.6) -> void:
 block(root,Vector3(1.9,2.8,0.2),Vector3(x,2.0,z),DARK)
 block(root,Vector3(1.5,1.6,0.23),Vector3(x,2.4,z+0.02),GLASS)
 block(root,Vector3(3,0.3,2.0),Vector3(x,0.65,z+0.5),Color("d6d8bc"))
 block(root,Vector3(0.13,0.25,0.15),Vector3(x+0.6,1.8,z+0.18),Color("ffd366"))

static func wing(root: Node3D, size: Vector3, at: Vector3, tone: Color, pitched: bool = true) -> void:
 block(root,size,at,tone)
 block(root,Vector3(size.x+0.6,0.4,size.z+0.6),Vector3(at.x,0.6,at.z),Color("9da99b"))
 if pitched:
  var roof = Node3D.new()
  root.add_child(roof)
  roof.position = Vector3(at.x,at.y+size.y/2+0.7,at.z)
  Models.roof(roof,size.x,size.z,0,tone.darkened(0.25))
  Models.bake(roof)
 else:
  block(root,Vector3(size.x+0.8,0.45,size.z+0.8),Vector3(at.x,at.y+size.y/2+0.2,at.z),CREAM)

static func garden(root: Node3D, tone: Color) -> void:
 for x in [-8,8]:
  block(root,Vector3(1.1,0.65,14),Vector3(x,0.8,0),tone)
  load("res://Buildings/CozyProps.gd").planter(root,Vector3(x,0,8.7))
 block(root,Vector3(2.5,0.1,4),Vector3(0,0.5,9),Color("e7d4a3"))

static func create(kind: String, level: int) -> Node3D:
 var root = Node3D.new()
 root.set_meta("town_kind",kind)
 var tone = Color(Catalog.HOMES[kind].color)
 if Game.state.skin=="Modern": tone=tone.lerp(Color("7ab8d2"),0.25)
 block(root,Vector3(19,0.35,23),Vector3(0,0.15,0),Color("dbceac"))
 var floors = mini(1+int((level-1)/3.0),4)
 var top = 7.0
 match kind:
  "house","landhouse":
   var size = Vector3(11,3.7+min(floors-1,1)*3.1,10)
   wing(root,size,Vector3(-1,0.9+size.y/2,-1),tone)
   windows(root,3.4,2.8,4.1,2,CREAM)
   if floors>1: windows(root,3.4,5.9,4.1,2,CREAM)
   entrance(root,-1,4.2)
   block(root,Vector3(10,0.25,3.4),Vector3(-1,4.2,5.5),Color("bf7045"))
   for x in [-5.5,3.5]: block(root,Vector3(0.3,3.4,0.3),Vector3(x,2.2,6.8),CREAM)
   if kind=="landhouse":
    wing(root,Vector3(4,3,6),Vector3(5.8,2.3,-2),tone.darkened(0.12))
    for x in [-6,-4]: block(root,Vector3(1.4,0.3,3),Vector3(x,0.6,8.8),Color("8fa951"))
    block(root,Vector3(4,0.8,0.3),Vector3(4.5,1,9),CREAM)
   garden(root,Color("75a66b"))
   top=size.y+3.2
  "apartments","hotel","office":
   floors += 1
   var height = floors*3.2
   wing(root,Vector3(13,height,11),Vector3(0,0.8+height/2,-1),tone,kind=="apartments")
   for floor_id in floors:
    var y=2.6+floor_id*3.2
    windows(root,3.6,y,4.6,3,CREAM)
    for side in [-1,1]:
     block(root,Vector3(0.18,1.7,7.6),Vector3(side*6.6,y,-1),GLASS)
    if kind=="apartments" and floor_id>0:
     for x in [-3.6,3.6]:
      block(root,Vector3(3,0.25,1.7),Vector3(x,y-1,5.2),CREAM)
      block(root,Vector3(3,0.85,0.15),Vector3(x,y-0.5,6.0),DARK)
   entrance(root)
   if kind=="hotel":
    block(root,Vector3(8,0.45,4),Vector3(0,4.3,6.1),Color("d38869"))
    for x in [-3.6,3.6]: block(root,Vector3(0.3,3.6,0.3),Vector3(x,2.4,7.4),CREAM)
    block(root,Vector3(8,1.4,0.3),Vector3(0,height+1.7,4.9),DARK)
    for x in [-2,-1,0,1,2]: Models.cylinder(root,0.27,0.25,Vector3(x,height+2.6,4.9),Color("ffc94f"))
   if kind=="office":
    for x in [-6,6]: block(root,Vector3(0.4,height,11.2),Vector3(x,height/2+0.9,-1),CREAM)
    block(root,Vector3(5,1.4,4),Vector3(1,height+1.8,-2),Color("7595a4"))
    block(root,Vector3(4,0.15,2.7),Vector3(-3,height+1.2,-2),GLASS)
   garden(root,Color("6b9d75"))
   top=height+4.2
  "villa":
   wing(root,Vector3(9,6.3,10),Vector3(-3,4,-2),tone,false)
   wing(root,Vector3(6,3.5,7),Vector3(4,2.6,-0.5),CREAM,false)
   windows(root,3.4,5.4,3.1,2,DARK)
   entrance(root,-2,3.1)
   block(root,Vector3(6,0.2,3.8),Vector3(4,0.6,7.6),CREAM)
   block(root,Vector3(5.3,0.08,3.1),Vector3(4,0.75,7.6),Color("42c7de"))
   for x in [-6,-3]: block(root,Vector3(1.7,0.3,3.3),Vector3(x,0.9,7.3),Color("f0cc78"))
   top=10
  "shop":
   wing(root,Vector3(13,4.2,10),Vector3(0,2.9,-1),tone,false)
   for x in [-4,4]: block(root,Vector3(3.8,2.7,0.2),Vector3(x,2.6,4.1),GLASS)
   entrance(root,0,4.2)
   for x in [-5,-3,-1,1,3,5]:
    var awning=Models.box(root,Vector3(2,0.35,3.6),Vector3(x,4.9,5.4),CREAM if x in [-5,-1,3] else Color("ef7856"))
    awning.rotation.x=0.1
   for x in [-5,5]:
    block(root,Vector3(2.6,1,1.5),Vector3(x,1,8),Color("a98450"))
    for offset in [-0.8,0,0.8]: Models.cylinder(root,0.35,0.5,Vector3(x+offset,1.7,8),Color("edab4b"),0.18)
   top=7
  "police","taxi":
   wing(root,Vector3(13,4.8,10),Vector3(-0.5,3.2,-1),tone,false)
   windows(root,3.3,3.2,4.2,3,CREAM)
   entrance(root,0,4.2)
   block(root,Vector3(10,1.3,0.3),Vector3(0,5.8,4.4),DARK)
   if kind=="police":
    Models.cylinder(root,0.7,0.15,Vector3(-4,5.8,4.65),Color("f7d578"))
    Models.cylinder(root,0.15,3.6,Vector3(5.5,7.6,-3),DARK)
    block(root,Vector3(2.8,0.2,0.2),Vector3(5.5,9,-3),DARK)
   else:
    for x in [-4,-2,0,2,4]: block(root,Vector3(0.7,0.7,0.1),Vector3(x,5.8,4.65),Color("ffd868"))
    for x in [-5,0,5]: block(root,Vector3(0.15,0.05,4),Vector3(x,0.55,8.3),CREAM)
   top=10
  "fire":
   wing(root,Vector3(14,4.6,11),Vector3(-0.6,3.1,-0.5),tone,false)
   for x in [-3.8,2.5]:
    block(root,Vector3(5.2,3.7,0.2),Vector3(x,2.7,5.1),DARK)
    for y in [1.2,1.9,2.6,3.3,4]: block(root,Vector3(4.9,0.13,0.3),Vector3(x,y,5.3),Color("f3bd88"))
   wing(root,Vector3(3,9,4),Vector3(6.2,5.3,-4),tone,false)
   block(root,Vector3(1.6,1.7,0.2),Vector3(6.2,7.2,-1.8),GLASS)
   # A compact fire engine is parked on the apron, inside the plot.
   block(root,Vector3(3.1,1.4,4.5),Vector3(-3,1.4,8.1),Color("e74f40"))
   block(root,Vector3(2.7,1.0,1.2),Vector3(-3,2.4,9.6),GLASS)
   block(root,Vector3(2.5,0.2,0.5),Vector3(-3,3,9.1),Color("4db8e4"))
   for x in [-4.6,-1.4]:
    for z in [6.8,9.3]:
     var wheel=Models.cylinder(root,0.55,0.3,Vector3(x,0.85,z),DARK)
     wheel.rotation.z=PI/2
   top=12
  "clinic":
   wing(root,Vector3(14,5.3,11),Vector3(0,3.5,-1),CREAM,false)
   windows(root,3.5,3.6,4.6,3,tone)
   entrance(root)
   block(root,Vector3(8,0.4,3.3),Vector3(0,4.5,6.3),tone)
   block(root,Vector3(1,3.6,0.4),Vector3(0,7,4.7),Color("ed6c66"))
   block(root,Vector3(3.6,1,0.4),Vector3(0,7,4.7),Color("ed6c66"))
   top=10.5
  "school":
   wing(root,Vector3(14,4.7,7),Vector3(0,3.1,-3),tone)
   for x in [-5.5,5.5]: wing(root,Vector3(3,3.7,8),Vector3(x,2.7,3.0),tone)
   windows(root,3.4,3.1,0.6,3,CREAM)
   entrance(root,0,0.7)
   block(root,Vector3(4.0,0.1,5.2),Vector3(0,0.5,6),Color("b3c8b2"))
   Models.cylinder(root,0.1,7.5,Vector3(7.6,4.2,7.6),DARK)
   block(root,Vector3(2.0,1.3,0.15),Vector3(8.3,7.1,7.6),Color("f5ba4b"))
   top=9
  "nightclub":
   wing(root,Vector3(14,5.2,12),Vector3(0,3.4,-1),tone.darkened(0.25),false)
   block(root,Vector3(12,1.4,0.3),Vector3(0,5.1,5.2),DARK)
   for x in [-4,-2,0,2,4]:
    var light=Models.box(root,Vector3(1.2,0.3,0.2),Vector3(x,5.1,5.4),Color("f986d1"))
    light.material_override=Models.material(Color("f986d1"),true)
   entrance(root,0,5.2)
   for x in [-6,6]: block(root,Vector3(0.3,3.2,0.3),Vector3(x,2.3,8),Color("f5d077"))
   block(root,Vector3(12,0.2,2),Vector3(0,4.1,6.8),Color("76cbe4"))
   block(root,Vector3(7,0.25,3),Vector3(0,0.6,8.6),Color("6b86b3"))
   top=9
  "park":
   block(root,Vector3(17,0.15,21),Vector3(0,0.4,0),Color("8bce73"))
   block(root,Vector3(3,0.1,21),Vector3(0,0.55,0),Color("e7cf97"))
   block(root,Vector3(17,0.1,2.5),Vector3(0,0.55,0),Color("e7cf97"))
   Models.cylinder(root,2.2,0.9,Vector3(0,1,0),Color("9fbebf"))
   Models.cylinder(root,1.9,0.1,Vector3(0,1.5,0),Color("59c5de"))
   Models.cylinder(root,0.3,1.7,Vector3(0,2,0),CREAM)
   for x in [-5,5]:
    Models.cylinder(root,0.35,2.7,Vector3(x,1.8,-5),Color("ad7b48"))
    Models.cylinder(root,2.5,4.1,Vector3(x,4.4,-5),Color("56a862"),0.4)
    load("res://Buildings/CozyProps.gd").bench(root,Vector3(x,0,4))
    load("res://Buildings/CozyProps.gd").planter(root,Vector3(x,0,8.3))
   top=7
 if level>=5 and kind!="park":
  for x in [-5,0,5]: block(root,Vector3(1.8,0.3,0.6),Vector3(x,0.7,10.4),Color("8fc36b"))
 root.set_meta("height",top)
 Models.bake(root)
 return root
