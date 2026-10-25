class_name TycoonArchitecture
extends RefCounted

# All shells are presentation-only and keep the existing 19 x 23 m footprint.
# The centre-front vehicle entry and the outer forklift ring remain open.
static func bake_static(root: Node3D) -> void:
 # Flatten only this authored, entirely static shell before material batching.
 # Machine, stock, operator and forklift nodes are outside this subtree.
 for mesh in root.find_children("*","MeshInstance3D",true,false):
  if mesh.get_parent()==root: continue
  var transform=mesh.transform
  var parent=mesh.get_parent()
  while parent!=root:
   transform=parent.transform*transform
   parent=parent.get_parent()
  mesh.get_parent().remove_child(mesh)
  root.add_child(mesh)
  mesh.transform=transform
 Models.bake(root)

static func box(root: Node3D,size: Vector3,at: Vector3,color: Color,finish: String="paint") -> void:
 Models.crafted_box(root,size,at,color,finish,minf(0.13,minf(size.x,minf(size.y,size.z))*0.18))

static func emblem(root: Node3D,kind: String,at: Vector3,tone: Color) -> void:
 var sign=Node3D.new();sign.name="TradeEmblem";sign.position=at;root.add_child(sign)
 box(sign,Vector3(2.3,1.6,0.16),Vector3.ZERO,tone)
 var cream=TycoonStyle.CREAM
 match kind:
  "sawmill","station":
   var blade=Models.cylinder(sign,0.53,0.09,Vector3(0,0,0.16),cream);blade.rotation.x=PI/2
   for i in 8:
    var a=i*TAU/8
    var tooth=Models.box(sign,Vector3(0.22,0.2,0.1),Vector3(cos(a)*0.56,sin(a)*0.56,0.16),cream)
    tooth.rotation.z=a
  "furniture","design":
   box(sign,Vector3(1.1,0.16,0.12),Vector3(0,-0.03,0.17),cream)
   for x in [-0.45,0.45]: box(sign,Vector3(0.15,1.02,0.12),Vector3(x,-0.08,0.17),cream)
   box(sign,Vector3(1.1,0.46,0.12),Vector3(0,0.4,0.17),cream)
  "kiln":
   for x in [-0.55,0,0.55]: box(sign,Vector3(0.18,0.95,0.12),Vector3(x,0,0.17),cream)
  "townhall":
   var face=Models.cylinder(sign,0.5,0.10,Vector3(0,0.1,0.16),TycoonStyle.TIMBER);face.rotation.x=PI/2
   for x in [-0.36,0.36]:
    var ear=Models.cylinder(sign,0.19,0.11,Vector3(x,0.49,0.16),TycoonStyle.TIMBER);ear.rotation.x=PI/2
   for x in [-0.12,0.12]: box(sign,Vector3(0.17,0.28,0.12),Vector3(x,-0.27,0.24),cream)
  _:
   for x in [-0.5,0,0.5]: box(sign,Vector3(0.36,0.9,0.15),Vector3(x,0,0.17),cream)
 Models.bake(sign)

static func workshop(root: Node3D,kind: String,level: int) -> void:
 if root.has_node("TycoonHall"): return
 var n=clampi(level,1,10)
 var hall=Node3D.new();hall.name="TycoonHall";root.add_child(hall)
 hall.set_meta("design_version",TycoonStyle.VERSION)
 var tone=TycoonStyle.family(kind)
 var storage=kind in ["station","warehouse"]
 if not Catalog.RECIPES.has(kind) and not storage:
  var utility_floors=mini(1+int((n-1)/4.0),4) if kind=="cabin" else 1
  emblem(hall,kind,Vector3(0,3.6*utility_floors+1.7,5.95),tone)
  root.set_meta("design_version",TycoonStyle.VERSION)
  return
 var width=5.6 if n==1 else 7.2 if n<=3 else 9.6
 var depth=3.0 if n==1 else 4.2 if n<=3 else 6.2
 var z=-6.6 if storage else -5.5
 var eave=4.6 if n<=2 else 5.9 if n<=5 else 7.0
 var centre_y=eave+width*0.12
 # Roofs cover the rear machine stations, leaving saw/product action visible
 # from the isometric front and never spanning the perimeter transport aisle.
 var bays=3 if n>=7 and kind=="sawmill" else 2 if n>=4 else 1
 hall.set_meta("roof_bays",bays)
 for bay in bays:
  var roof=Node3D.new();roof.position=Vector3((bay-(bays-1)*0.5)*width/bays,0,z);hall.add_child(roof)
  Models.roof(roof,width/bays-0.15,depth,centre_y,tone)
  Models.bake(roof)
 for x in [-width/2+0.25,width/2-0.25]:
  # The machine corridor and stock accesses are x <= 3.6 and |x| >= 5.5.
  var px=clampf(absf(x),3.9,4.55)*signf(x) if n>=4 else x
  for end in [-1,1]:
   var p=Vector3(px,0.6+(eave-0.6)/2,z+end*(depth/2-0.3))
   box(hall,Vector3(0.28,eave-0.6,0.28),p,TycoonStyle.TIMBER,"timber")
   box(hall,Vector3(0.5,0.5,0.5),Vector3(px,0.82,p.z),TycoonStyle.DARK)
 # A rear knee-wall is inside the forklift perimeter, not a wall across it.
 if n>=3:
  box(hall,Vector3(width-0.6,1.7,0.22),Vector3(0,1.45,z-depth/2+0.35),TycoonStyle.CREAM)
  for x in [-width*0.32,0,width*0.32]: box(hall,Vector3(0.16,1.8,0.26),Vector3(x,1.5,z-depth/2+0.35),TycoonStyle.TIMBER,"timber")
 if n>=5:
  for x in [-width*0.29,width*0.29]:
   box(hall,Vector3(width*0.38,0.15,0.22),Vector3(x,eave-0.25,z+depth/2-0.3),TycoonStyle.TIMBER,"timber")
 if n>=6:
  box(hall,Vector3(1.8,0.8,0.8),Vector3(0,eave+0.2,z-depth/2+0.7),TycoonStyle.STEEL)
 if n>=9:
  for x in [-1.2,1.2]:
   var pipe=Models.cylinder(hall,0.16,1.3,Vector3(x,eave+1.3,z-depth/2+0.7),TycoonStyle.STEEL)
 if n==10:
  box(hall,Vector3(2.6,0.35,0.45),Vector3(0,eave+1,z+depth/2-0.4),TycoonStyle.GOLD)
 emblem(hall,kind,Vector3(0,eave-0.8,z+depth/2+0.12),tone)
 bake_static(hall)
 for mesh in hall.find_children("*","MeshInstance3D",true,false): mesh.visibility_range_end=320
 root.set_meta("design_version",TycoonStyle.VERSION)
 root.set_meta("height",maxf(float(root.get_meta("height",8.6)),eave+width*0.24+0.6))

static func depot(root: Node3D,kind: String,level: int) -> void:
 var facade=Node3D.new();facade.name="TycoonHall";root.add_child(facade)
 var width=29.0 if kind=="central_depot" else 17.0
 var bays=3 if kind=="central_depot" else 2
 var tone=TycoonStyle.family(kind)
 # Cantilever loading canopy attaches to the existing hall frame. No new
 # ground posts obstruct the real loading bays or either animated forklift.
 for bay in bays:
  var x=(bay-(bays-1)*0.5)*width/bays
  var canopy=Node3D.new();canopy.position=Vector3(x,0,-3.5);facade.add_child(canopy)
  Models.roof(canopy,width/bays-0.2,1.2,6.8,tone);Models.bake(canopy)
  # Cream piers and dark dock frames give each loading opening a readable
  # building facade. The central freight approach stays completely open.
  for side in [-1,1]:
   box(facade,Vector3(0.42,4.8,0.36),Vector3(x+side*(width/bays/2-0.3),2.95,-4.35),TycoonStyle.CREAM)
   box(facade,Vector3(0.16,4.1,0.15),Vector3(x+side*(width/bays/2-0.62),2.6,-4.12),TycoonStyle.DARK)
  box(facade,Vector3(width/bays-0.4,0.75,0.35),Vector3(x,4.98,-4.35),TycoonStyle.CREAM)
  box(facade,Vector3(width/bays-0.6,0.28,0.3),Vector3(x,5.45,-4),TycoonStyle.TIMBER,"timber")
  for side in [-1,1]: box(facade,Vector3(0.22,1.0,0.18),Vector3(x+side*(width/bays/2-0.6),4.9,-4),TycoonStyle.GOLD)
 emblem(facade,"warehouse",Vector3(-width*0.33,5.3,-3.78),tone)
 bake_static(facade)
 root.set_meta("design_version",TycoonStyle.VERSION)

static func townhall(root: Node3D,n: int,skin: String="Rustikal") -> float:
 var tone=TycoonStyle.COPPER.lerp(TycoonStyle.TEAL,0.55) if skin=="Modern" else TycoonStyle.COPPER
 var h=4.6 if n>=7 else 3.3
 var facade=Node3D.new();facade.name="CivicArchitecture";root.add_child(facade)
 box(facade,Vector3(8.8,0.55,7.8),Vector3(0,0.85,-2.5),TycoonStyle.STEEL)
 box(facade,Vector3(8.2,h,7.2),Vector3(0,1.1+h/2,-2.5),TycoonStyle.TIMBER if n<=2 else TycoonStyle.CREAM,"timber" if n<=2 else "plaster")
 for x in [-3.95,3.95]: box(facade,Vector3(0.24,h+0.12,7.3),Vector3(x,1.1+h/2,-2.5),TycoonStyle.TIMBER,"timber")
 var roof=Node3D.new();roof.position=Vector3(0,0,-2.5);facade.add_child(roof)
 Models.roof(roof,8.8,7.6,h+1.7,tone);Models.bake(roof)
 for x in [-2.7,2.7]:
  box(facade,Vector3(1.5,1.6,0.22),Vector3(x,2.9,1.22),TycoonStyle.TIMBER_DARK)
  Models.crafted_box(facade,Vector3(1.2,1.3,0.24),Vector3(x,2.9,1.26),Color("86c2c6"),"glass",0.05)
  box(facade,Vector3(0.09,1.35,0.28),Vector3(x,2.9,1.3),TycoonStyle.CREAM)
 box(facade,Vector3(2.1,2.7,0.25),Vector3(0,2.45,1.26),TycoonStyle.TIMBER_DARK)
 box(facade,Vector3(1.85,2.4,0.28),Vector3(0,2.4,1.3),Color("39795f"))
 for x in [-0.16,0.16]: box(facade,Vector3(0.08,0.32,0.15),Vector3(x,2.35,1.48),TycoonStyle.GOLD)
 for step in 3: box(facade,Vector3(4.2+step*0.55,0.16,1.0),Vector3(0,0.95-step*0.16,1.9+step*0.8),TycoonStyle.CREAM)
 if n>=2:
  box(facade,Vector3(3.6,0.2,1.9),Vector3(0,4.15,2.0),tone)
  for x in [-1.6,1.6]: box(facade,Vector3(0.18,2.9,0.18),Vector3(x,2.55,2.6),TycoonStyle.TIMBER,"timber")
 if n>=3: emblem(facade,"townhall",Vector3(0,4.8 if n>=7 else 3.5,1.45),tone)
 for side in [-1,1]:
  if (side<0 and n<4) or (side>0 and n<6): continue
  var x=side*5.8
  box(facade,Vector3(3.2,3.2,6.4),Vector3(x,2.5,-2.5),TycoonStyle.CREAM)
  var wing=Node3D.new();wing.position=Vector3(x,0,-2.5);facade.add_child(wing)
  Models.roof(wing,3.5,6.7,4.5,tone);Models.bake(wing)
  Models.crafted_box(facade,Vector3(2.2,1.3,0.2),Vector3(x,2.8,0.76),Color("86c2c6"),"glass",0.05)
 if n>=5:
  for x in [-4.5,4.5]:
   box(facade,Vector3(1.0,0.45,1.0),Vector3(x,0.93,5.1),TycoonStyle.TIMBER)
   Models.cylinder(facade,0.52,0.8,Vector3(x,1.55,5.1),TycoonStyle.GRASS,0.3)
 if n>=7:
  for x in [-2.7,2.7]: Models.crafted_box(facade,Vector3(1.2,0.9,0.2),Vector3(x,4.55,1.25),Color("86c2c6"),"glass",0.05)
 var top=h+3.0
 if n>=8:
  var tower_h=7.3+(n-8)*1.0
  box(facade,Vector3(2.6,tower_h,3.0),Vector3(0,1.1+tower_h/2,-3.3),TycoonStyle.CREAM)
  var cap=Node3D.new();cap.position=Vector3(0,0,-3.3);facade.add_child(cap)
  Models.roof(cap,3.2,3.6,tower_h+1.7,tone);Models.bake(cap)
  var clock=Models.cylinder(facade,0.78,0.16,Vector3(0,tower_h-0.1,-1.7),TycoonStyle.TIMBER_DARK);clock.rotation.x=PI/2
  var face=Models.cylinder(facade,0.65,0.18,Vector3(0,tower_h-0.1,-1.66),TycoonStyle.CREAM);face.rotation.x=PI/2
  box(facade,Vector3(0.09,0.53,0.13),Vector3(0,tower_h+0.12,-1.52),TycoonStyle.DARK)
  box(facade,Vector3(0.47,0.09,0.13),Vector3(0.19,tower_h-0.1,-1.51),TycoonStyle.DARK)
  top=tower_h+3.0
 if n>=9:
  for x in [-5.8,5.8]: box(facade,Vector3(0.25,1.7,0.25),Vector3(x,5.1,0.5),TycoonStyle.GOLD)
 if n==10:
  box(facade,Vector3(5.0,0.24,1.1),Vector3(0,5.3,2.2),TycoonStyle.GOLD)
  for x in [-5,5]: load("res://Buildings/CozyProps.gd").bench(facade,Vector3(x,0,7.8))
 bake_static(facade)
 root.set_meta("design_version",TycoonStyle.VERSION)
 return top
