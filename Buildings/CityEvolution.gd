class_name CityEvolution
extends RefCounted

const CREAM=Color("fff0cc")
const GLASS=Color("63cce0")
const DARK=Color("2b5267")
const GREEN=Color("73b86c")
const Props=preload("res://Buildings/CozyProps.gd")

static func box(root: Node3D,size: Vector3,at: Vector3,color: Color) -> void:
 Models.box(root,size,at,color)
static func slab(root: Node3D,width: float,depth: float,height: float,color: Color,x: float=0,z: float=-1) -> void:
 box(root,Vector3(width,height,depth),Vector3(x,0.8+height/2,z),color)
 box(root,Vector3(width+0.4,0.25,depth+0.4),Vector3(x,height+0.95,z),CREAM)
static func facade(root: Node3D,width: float,depth: float,count: int,color: Color,x: float=0,z: float=-1,balconies: bool=false) -> void:
 for floor_id in count:
  var y=2.15+floor_id*2.7
  box(root,Vector3(width+0.1,0.13,depth+0.1),Vector3(x,y+1.2,z),color)
  for col in 3:
   var at_x=x+(col-1)*width*0.27
   box(root,Vector3(1.7,1.5,0.18),Vector3(at_x,y,z+depth/2+0.08),DARK)
   box(root,Vector3(1.4,1.23,0.20),Vector3(at_x,y,z+depth/2+0.1),GLASS)
   if balconies and floor_id>0:
    box(root,Vector3(2.3,0.18,1),Vector3(at_x,y-0.85,z+depth/2+0.5),CREAM)
    box(root,Vector3(2.3,0.55,0.1),Vector3(at_x,y-0.5,z+depth/2+1),DARK)
  for side in [-1,1]:
   box(root,Vector3(0.18,1.5,depth*0.67),Vector3(x+side*(width/2+0.05),y,z),GLASS)
static func door(root: Node3D,x: float,z: float,color: Color) -> void:
 box(root,Vector3(1.8,2.5,0.2),Vector3(x,2,z),DARK)
 box(root,Vector3(1.5,1.8,0.23),Vector3(x,2.2,z+0.03),GLASS)
 box(root,Vector3(3.5,0.25,2),Vector3(x,0.6,z+0.8),CREAM)
 box(root,Vector3(3.7,0.25,1.8),Vector3(x,3.5,z+0.7),color)
static func roof(root: Node3D,width: float,depth: float,y: float,x: float,z: float,tone: Color) -> void:
 var node=Node3D.new()
 root.add_child(node)
 node.position=Vector3(x,y,z)
 Models.roof(node,width,depth,0,tone)
static func sign_plate(root: Node3D,text_value: String,at: Vector3,tone: Color) -> void:
 box(root,Vector3(7,1,0.28),at,tone)
 # A short emblem is geometry, keeping distant models cheap to render.
 for i in mini(5,text_value.length()): box(root,Vector3(0.6,0.45,0.1),at+Vector3((i-2)*1.1,0,0.2),CREAM)
static func parking(root: Node3D,number: int,tone: Color,z: float=8.4) -> void:
 for i in number:
  var x=(i-(number-1)*0.5)*3.0
  box(root,Vector3(0.12,0.03,3.5),Vector3(x-1.35,0.4,z),CREAM)
  box(root,Vector3(2,0.9,3.2),Vector3(x,0.95,z),tone)
  box(root,Vector3(1.7,0.75,1.6),Vector3(x,1.7,z),GLASS)
static func create(kind: String,level: int,skin: String = "Rustikal") -> Node3D:
 var n=clampi(level,1,10)
 var root=Node3D.new()
 root.set_meta("town_kind",kind)
 root.set_meta("evolution_level",n)
 root.set_meta("stage_name",TownEvolution.title(kind,n))
 var tone=Color("e65d4b") if kind=="fire" else Color(Catalog.HOMES[kind].color)
 if skin=="Modern": tone=tone.lerp(GLASS,0.2)
 box(root,Vector3(19,0.32,23),Vector3(0,0.16,0),Color("dccdaa"))
 var f=TownEvolution.floors(kind,n)
 var h=f*2.7
 var top=6.0
 match kind:
  "apartments","office","hotel":
   var width=10.0+n*0.2 if kind=="hotel" else 11.0 if n<6 else 10.0
   slab(root,width,9,h,tone,-1,-2)
   facade(root,width,9,f,CREAM,-1,-2,kind=="apartments")
   door(root,-1,2.7,tone.darkened(0.2))
   if n>=3:
    var wing_h=2.7*maxi(1,int((n+1)/3.0))
    slab(root,4.4,8,wing_h,tone.lightened(0.15),5.8,-0.5)
    for j in maxi(1,int(n/3.0)): box(root,Vector3(3.8,1.3,0.18),Vector3(5.8,2.1+j*2.7,3.6),GLASS)
   if n>=5:
    box(root,Vector3(11,0.4,3.2),Vector3(-0.5,4.1,5.1),Color("f3b76c"))
    for x in [-5,4]: box(root,Vector3(0.28,3.4,0.28),Vector3(x,2.2,6.3),CREAM)
   if kind=="hotel":
    sign_plate(root,"HOTEL",Vector3(-1,h+1.8,2.6),DARK)
    if n>=6:
     box(root,Vector3(7,0.15,3),Vector3(2,0.55,8.5),CREAM)
     box(root,Vector3(6,0.06,2.2),Vector3(2,0.68,8.5),GLASS)
   if kind=="office":
    for x in [-5.6,3.6]: box(root,Vector3(0.4,h+0.7,9.2),Vector3(x,h/2+1,-2),DARK)
    if n>=7: box(root,Vector3(6,1.5,5),Vector3(-1,h+1.8,-2),tone.darkened(0.25))
   top=h+3.4
  "house","landhouse","villa":
   var home_f=1+int((n-1)/3.0)
   var home_h=home_f*2.7
   var size=Vector3(8.0+n*0.12,home_h,7.0+n*0.1)
   slab(root,size.x,size.z,size.y,tone,-2,-2)
   facade(root,9,8,home_f,CREAM,-2,-2)
   roof(root,9,8,home_h+1.7,-2,-2,tone.darkened(0.3))
   door(root,-2,2.2,tone.darkened(0.2))
   if n>=2:
    box(root,Vector3(10,0.2,3),Vector3(-2,3.7,4),Color("c57950"))
    for x in [-6.3,2.3]: box(root,Vector3(0.23,3,0.23),Vector3(x,2,5),CREAM)
   if n>=3:
    slab(root,4.5,7,2.7+int(n/6.0)*2.7,tone.lightened(0.12),5.3,-2)
    door(root,5.3,1.6,DARK)
   if kind in ["villa","landhouse"] and n>=5:
    slab(root,4,5,2.7,CREAM,5.3,4.5)
    box(root,Vector3(2.8,0.18,3),Vector3(5.3,3.8,4.5),GLASS)
   if n>=5 and kind=="house":
    slab(root,3.3,2.7,2.7,tone.lightened(0.12),2.4,3.3)
    box(root,Vector3(2.5,1.4,0.2),Vector3(2.4,2.3,4.75),GLASS)
   if n>=8:
    box(root,Vector3(3.4,0.2,2),Vector3(-2,home_h+1.5,2.2),CREAM)
    box(root,Vector3(3.4,0.7,0.15),Vector3(-2,home_h+1.9,3.1),DARK)
   if n>=9: slab(root,4,3.4,2.7,tone,1,-7.8)
   if kind=="villa":
    box(root,Vector3(6.5,0.22,3),Vector3(-2,0.65,8.5),CREAM)
    box(root,Vector3(5.6,0.07,2.2),Vector3(-2,0.8,8.5),GLASS)
   if kind=="landhouse":
    for x in [-6,-3,0]: box(root,Vector3(1.6,0.3,2.5),Vector3(x,0.7,8.4),GREEN)
   top=home_h+4.6
  "fire","taxi","police":
   var bays=mini(5,1+int((n-1)/2.0))
   var hall_h=4.0+n*0.08
   slab(root,14,10,hall_h,tone,-0.5,-1.5)
   for i in bays:
    var x=-5.5+i*(11.0/maxi(1,bays-1)) if bays>1 else -2.0
    var w=minf(4,10.8/bays)
    box(root,Vector3(w,3.1,0.2),Vector3(x,2.3,3.6),DARK)
    for j in 5: box(root,Vector3(w-0.15,0.11,0.23),Vector3(x,1+j*0.6,3.8),Color("f3b47d") if kind=="fire" else GLASS)
   if n>=2:
    var admin=2.7*(1+int(n/2.0))
    slab(root,4.5,5,admin,CREAM,5.5,-4)
    for j in 1+int(n/2.0): box(root,Vector3(3.6,1.5,0.2),Vector3(5.5,2.2+j*2.7,-1.4),GLASS)
    top=maxf(top,admin+2)
   if kind=="fire":
    var tower=5.0+n*0.65
    slab(root,2.6,3.5,tower,tone.darkened(0.12),-6,-4.5)
    for j in 1+int(n/2.0): box(root,Vector3(1.2,0.9,0.2),Vector3(-6,3+j*1.1,-2.65),GLASS)
    top=maxf(top,tower+2)
    parking(root,mini(3,1+int(n/4.0)),Color("e95749"))
   elif kind=="taxi": parking(root,mini(4,1+int(n/3.0)),Color("f2c34e"))
   else:
    parking(root,mini(3,1+int(n/4.0)),Color("548fb7"))
    Models.cylinder(root,0.1,3,Vector3(5.5,top+0.5,-4),DARK)
    top+=3
   sign_plate(root,kind,Vector3(0,hall_h+1.5,3.8),DARK)
  "clinic","school":
   slab(root,11,9,h,CREAM,-1,-2)
   facade(root,11,9,f,tone,-1,-2)
   door(root,-1,2.6,tone)
   if n>=2: slab(root,4.8,7,2.7*maxi(1,int(n/3.0)),tone,5.5,-0.8)
   if n>=4:
    box(root,Vector3(10,0.35,3),Vector3(-1,4,5.2),tone)
    for x in [-5,3]: box(root,Vector3(0.25,3.2,0.25),Vector3(x,2.2,6.3),CREAM)
   if kind=="clinic":
    box(root,Vector3(0.8,2.8,0.3),Vector3(-1,h+2,2.7),Color("e66966"))
    box(root,Vector3(2.8,0.8,0.3),Vector3(-1,h+2,2.7),Color("e66966"))
    parking(root,mini(2,1+int(n/6.0)),CREAM,8.7)
    if n>=8:
     box(root,Vector3(7,0.15,6),Vector3(-1,h+1.3,-2),DARK)
     for x in [-2.5,0.5]: box(root,Vector3(0.35,0.05,3),Vector3(x,h+1.42,-2),CREAM)
     box(root,Vector3(3.3,0.05,0.35),Vector3(-1,h+1.42,-2),CREAM)
   else:
    for x in [-5,0,5]: Props.bench(root,Vector3(x,0,8))
    Models.cylinder(root,0.1,5,Vector3(8,3.2,7),DARK)
    box(root,Vector3(1.5,1,0.1),Vector3(8,5,7),Color("f4c34d"))
   top=h+4.2
  "shop","nightclub":
   slab(root,13,11,h,tone,0,-1.7)
   facade(root,13,11,f,CREAM,0,-1.7)
   door(root,0,4,tone)
   sign_plate(root,kind,Vector3(0,h+1.6,4),DARK)
   if kind=="shop":
    for i in 6:
     var awning=Models.box(root,Vector3(2,0.25,3),Vector3(-5+i*2,4,5.1),CREAM if i%2 else Color("ed8c61"))
     awning.rotation.x=0.12
    if n>=4:
     for x in [-5,5]: box(root,Vector3(2.5,1,1.8),Vector3(x,1.1,8.5),Color("b99154"))
   else:
    for i in 2+int(n/2.0):
     var lamp=Models.box(root,Vector3(0.65,0.22,0.16),Vector3(-4.5+i*1.35,h+1.7,4.2),Color("f7a2d6"))
     lamp.material_override=Models.material(Color("f7a2d6"),true)
    if n>=5: box(root,Vector3(10,0.2,3),Vector3(0,h+1.3,-1.5),Color("74bed4"))
   top=h+3
  "park":
   box(root,Vector3(17,0.1,21),Vector3(0,0.4,0),GREEN)
   box(root,Vector3(2.2,0.07,21),Vector3(0,0.5,0),Color("f1d49c"))
   box(root,Vector3(17,0.07,2.2),Vector3(0,0.5,0),Color("f1d49c"))
   Models.cylinder(root,1.5+n*0.08,0.65,Vector3(0,0.9,0),CREAM)
   Models.cylinder(root,1.25+n*0.08,0.08,Vector3(0,1.25,0),GLASS)
   if n>=4: Models.cylinder(root,0.3,1.8,Vector3(0,1.7,0),CREAM)
   for i in mini(8,2+n/2):
    var x=-5 if i%2==0 else 5
    var z=-7+int(i/2.0)*4.3
    Models.cylinder(root,0.22,2.2,Vector3(x,1.5,z),Color("ad7c4c"))
    Models.cylinder(root,1.5,2.8,Vector3(x,3.6,z),Color("459f6b"),0.4)
   if n>=6:
    for x in [-5,5]: Props.bench(root,Vector3(x,0,8.3))
   if n>=8:
    for x in [-1.8,1.8]: box(root,Vector3(0.35,3.3,0.35),Vector3(x,2.1,9.5),CREAM)
    box(root,Vector3(4.2,0.3,0.6),Vector3(0,3.9,9.5),Color("dba65a"))
   if n>=10:
    for x in [-6,6]: Models.cylinder(root,0.4,1.6,Vector3(x,1.3,0),CREAM)
   top=7
 # Each individual level has new landscaped frontage and roof installations,
 # including intermediate levels that share a broad architectural category.
 for i in n:
  var x=-8.2 if i%2==0 else 8.2
  var z=-9.0+int(i/2.0)*3.8
  box(root,Vector3(1.8,0.25+0.03*n,0.65),Vector3(x,0.55,z),Color("75ac67"))
  if i%2==0: Models.cylinder(root,0.3,0.35,Vector3(x,0.92,z),Color("edbe63"),0.18)
 if kind not in ["park","house","landhouse","villa"]:
  var roof_y=(4.0+n*0.08 if kind in ["fire","taxi","police"] else h)+1.1
  for i in int(n/2.0):
   box(root,Vector3(1.3,0.13,1.3),Vector3(-3+(i%3)*2,roof_y,-4+int(i/3.0)*2),Color("487d9a"))
 root.set_meta("height",top)
 root.set_meta("floors",f)
 Models.bake(root)
 return root
