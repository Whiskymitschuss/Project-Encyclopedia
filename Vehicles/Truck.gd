class_name TimberTruck
extends Node3D

var road_freight = false
var cargo_boards = false
var trailer: Node3D
var previous_heading = 0.0
var cargo_boxes = false
var cargo_furniture = false
var cargo: Node3D
var path: Array[Vector3] = []
var segment = 0
var speed = 10.0
var tier = 3
var wheels: Array = []
var lift: Node3D
var clock = 0.0

func wheel(at: Vector3, radius: float = 0.85) -> void:
 var node=Models.cylinder(self,radius,0.4,at,Color("34484b"))
 node.rotation.z=PI/2
 node.set_meta("animated",true)
 wheels.append(node)

func _ready() -> void:
 set_meta("transport_tier",tier)
 if road_freight and tier>=4:
  build_rig()
  return
 if tier<2:
  Models.box(self,Vector3(1.8,0.3,2.6),Vector3(0,1.1,0),Color("a5794c"))
  for x in [-0.9,0.9]: Models.box(self,Vector3(0.16,0.8,2.7),Vector3(x,1.6,0),Color("d1a967"))
  Models.log_pile(self,Vector3(-0.5,1.25,0),3)
  if tier==0:
   for x in [-1.1,1.1]: wheel(Vector3(x,0.7,0),0.7)
  else: wheel(Vector3(0,0.65,1.1),0.65)
  for x in [-0.7,0.7]: Models.box(self,Vector3(0.1,0.1,2),Vector3(x,1.4,2),Color("b28b54"))
  Models.box(self,Vector3(0.8,1.2,0.65),Vector3(0,1.9,3.2),Color("2e9cba"))
  Models.box(self,Vector3(0.65,0.7,0.6),Vector3(0,2.8,3.2),Color("f2c99e"))
  Models.cylinder(self,0.48,0.35,Vector3(0,3.2,3.2),Color("ffcf54"),0.32)
  for x in [-0.25,0.25]: Models.box(self,Vector3(0.3,0.8,0.4),Vector3(x,0.95,3.2),Color("3d5c70"))
 elif tier==2:
  Models.box(self,Vector3(2.8,0.9,5.7),Vector3(0,1.25,0),Color("ea8558"))
  Models.box(self,Vector3(2.6,1.8,2.2),Vector3(0,2.3,0.9),Color("e9b95e"))
  Models.box(self,Vector3(2.4,1,0.14),Vector3(0,2.7,2.05),Color("8bd2d7"))
  make_cargo(Vector3(-0.8,1.7,-1.7),3)
  for x in [-1.5,1.5]:
   for z in [-1.9,1.9]: wheel(Vector3(x,0.8,z),0.75)
 else:
  var industrial=tier>=5
  var length=10.5 if tier==4 else 7.0
  var color=Color("eac170") if tier<5 else Color("e7a839") if tier<8 else Color("68bbce")
  Models.box(self,Vector3(3.2,1.1,length),Vector3(0,1.2,0),Color("476775"))
  Models.box(self,Vector3(3.2,2.7,2.4),Vector3(0,2.3,length/2-1.2),color)
  Models.box(self,Vector3(2.9,1.2,0.15),Vector3(0,2.9,length/2+0.05),Color("9ed2d4"))
  for x in [-1.1,1.1]: Models.box(self,Vector3(0.65,0.45,0.2),Vector3(x,1.6,length/2+0.1),Color("fff1b2"))
  make_cargo(Vector3(-0.8,1.6,-1.2),9 if tier==4 else 6)
  for x in [-1.8,1.8]:
   for z in [-length*0.34,0,length*0.34]:
    if z==0 and tier==3: continue
    wheel(Vector3(x,0.8,z))
  if industrial:
   lift=Node3D.new()
   add_child(lift)
   lift.position=Vector3(0,2.5,-1.5)
   Models.cylinder(lift,0.6,0.6,Vector3.ZERO,Color("477386"))
   Models.box(lift,Vector3(0.7,4.6,0.8),Vector3(0,2.1,0),color)
   var arm=Models.box(lift,Vector3(0.6,0.6,4),Vector3(0,4.1,1.8),color)
   arm.rotation.x=0.3
   Models.box(lift,Vector3(0.5,2.2,0.5),Vector3(0,2.8,3.5),color)
   for x in [-0.65,0.65]: Models.box(lift,Vector3(0.35,1.3,1.2),Vector3(x,1.5,3.5),Color("386275"))
   Models.cylinder(lift,0.12,3.8,Vector3(0.5,2.2,0),Color("d2ded5"))
   if tier>=7:
    Models.box(lift,Vector3(3.1,1.3,1.8),Vector3(0,1,-1),color)
    Models.box(lift,Vector3(1.6,0.2,1.8),Vector3(0,1.8,-1),Color("7dcad4"))
   if tier==9:
    Models.box(lift,Vector3(3.0,0.7,1.8),Vector3(0,1.1,3.4),Color("6d9ba9"))
    for x in [-1,0,1]: Models.box(lift,Vector3(0.4,0.4,0.9),Vector3(x,0.7,4.4),Color("dce8da"))
   Models.bake(lift)
 Models.bake(self)
 if not path.is_empty(): position=path[0]

func _process(delta: float) -> void:
 if path.size()<2: return
 clock+=delta
 var goal=path[(segment+1)%path.size()]
 var direction=goal-position
 if direction.length()<speed*delta:
  position=goal
  segment=(segment+1)%path.size()
 else: position+=direction.normalized()*speed*delta
 if direction.length_squared()>0.01: rotation.y=atan2(direction.x,direction.z)
 for node in wheels: node.rotate_object_local(Vector3.UP,delta*speed)
 if lift!=null: lift.rotation.y=sin(clock*0.4)*0.1


func make_cargo(at: Vector3, count_value: int) -> void:
 cargo = Node3D.new()
 cargo.set_meta("animated",true)
 var parent: Node3D = trailer if trailer!=null else self
 parent.add_child(cargo)
 if trailer!=null: cargo.position=Vector3(0,-0.25,-4)
 if cargo_boards:
  for i in 5: Models.box(cargo,Vector3(2.3,0.19,4.2),Vector3(0,1.8+i*0.2,-0.6),Color("ebc17d"))
  Models.bake(cargo)
  return
 if cargo_boxes:
  for z in [-1,0]: Models.box(cargo,Vector3(2,1.4,1.3),Vector3(0,2,z),Color("b7a16e"))
  Models.bake(cargo)
  return
 if not cargo_furniture: Models.log_pile(cargo,at,count_value); return
 for z in [-1,0]:
  Models.box(cargo,Vector3(1.8,1.5,1.1),Vector3(0,2.2,z),Color("e8bf79"))
  Models.box(cargo,Vector3(1.6,1.2,0.2),Vector3(0,3,z+0.5),Color("5fb4bd"))
 Models.bake(cargo)


func build_rig() -> void:
 var lowbed=tier>=6
 Models.box(self,Vector3(3.1,0.65,5.4),Vector3(0,1.1,1.7),Color("435f72"))
 Models.box(self,Vector3(3,2.6,2.5),Vector3(0,2.4,3),Color("5aa9b6") if lowbed else Color("efb954"))
 Models.box(self,Vector3(2.75,1.1,0.13),Vector3(0,2.9,4.3),Color("a4dde2"))
 for x in [-1.1,1.1]: Models.box(self,Vector3(0.55,0.35,0.2),Vector3(x,1.7,4.4),Color("fff1b5"))
 for x in [-1.65,1.65]:
  for z in [0.3,3.2]: wheel(Vector3(x,0.8,z),0.8)
 Models.cylinder(self,0.65,0.35,Vector3(0,1.6,-0.7),Color("486674"))
 trailer=Node3D.new()
 trailer.name="Lowbed" if lowbed else "Trailer"
 add_child(trailer)
 trailer.position=Vector3(0,0,-0.6)
 var deck_y=1.25 if lowbed else 1.7
 Models.box(trailer,Vector3(3.5,0.4,8.8),Vector3(0,deck_y,-4.2),Color("d9a84e") if lowbed else Color("628f97"))
 for x in [-1.75,1.75]:
  for z in [-5.8,-7.3]:
   var node=Models.cylinder(trailer,0.75,0.4,Vector3(x,0.8,z),Color("34484b"))
   node.rotation.z=PI/2
   node.set_meta("animated",true)
   wheels.append(node)
  if lowbed:
   var ramp=Models.box(trailer,Vector3(0.6,2,0.2),Vector3(x*0.7,2,-8.6),Color("f1c55d"))
   ramp.rotation.x=0.15
  else: Models.box(trailer,Vector3(0.14,0.8,8.5),Vector3(x,deck_y+0.5,-4.2),Color("e1c180"))
 make_cargo(Vector3(-0.8,1.7,-0.5),8)
 Models.bake(trailer)
 Models.bake(self)

func follow_heading(direction: Vector3, delta: float) -> void:
 var heading=atan2(direction.x,direction.z)
 if trailer!=null:
  var turn=clampf(wrapf(previous_heading-heading,-PI,PI),-0.55,0.55)
  trailer.rotation.y=lerp_angle(trailer.rotation.y,turn,minf(delta*5,1))
 rotation.y=heading
 previous_heading=heading
