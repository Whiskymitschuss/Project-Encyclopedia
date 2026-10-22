class_name TimberTruck
extends Node3D

var road_freight = false
var fleet="general"
var cargo_boards = false
var cargo_stone = false
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
 if road_freight:
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
  var pusher=BeaverModels.create(tier,"logistics")
  pusher.position=Vector3(0,0.1,3.2)
  add_child(pusher)
 elif tier==2:
  Models.box(self,Vector3(2.8,0.9,5.7),Vector3(0,1.25,0),Color("ea8558"))
  hollow_cab(Vector3(0,1.7,0.9),Vector3(2.6,1.8,2.2),Color("e9b95e"),tier)
  make_cargo(Vector3(-0.8,1.7,-1.7),3)
  for x in [-1.5,1.5]:
   for z in [-1.9,1.9]: wheel(Vector3(x,0.8,z),0.75)
 else:
  var industrial=tier>=5
  var length=10.5 if tier==4 else 7.0
  var color=Color("eac170") if tier<5 else Color("e7a839") if tier<8 else Color("68bbce")
  Models.box(self,Vector3(3.2,1.1,length),Vector3(0,1.2,0),Color("476775"))
  hollow_cab(Vector3(0,1.6,length/2-1.2),Vector3(3.2,2.7,2.4),color,tier)
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
 if cargo_stone:
  for i in 6: Models.box(cargo,Vector3(1.1,0.6,1.7),Vector3((i%2-0.5)*1.2,1.8+(i/2)*0.65,-0.6),Color("d7cbb0"))
  Models.bake(cargo)
  return
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
 # All road carriers fit a 3 m lane and the short factory loading bays.
 # Higher tiers retain their own articulated bed and actual cargo identity.
 var color=Color("ffffff") if fleet in ["central","construction"] else Color("35a8d6") if tier>=6 else Color("ffc640")
 var accent=Color("338fd6") if fleet=="central" else Color("303941") if fleet=="construction" else color
 Models.box(self,Vector3(2.0,0.35,6.2),Vector3(0,0.68,0),Color("415b70"))
 Models.crafted_box(self,Vector3(2.05,0.85,1.8),Vector3(0,1.2,2.05),color,"paint",0.18)
 Models.box(self,Vector3(2.1,0.14,1.85),Vector3(0,2.5,2.05),color)
 for x in [-0.95,0.95]:
  for z in [1.25,2.85]: Models.box(self,Vector3(0.13,0.85,0.13),Vector3(x,2.0,z),color)
 for side in [-1,1]: Models.box(self,Vector3(0.04,0.35,1.6),Vector3(side*1.04,1.35,2.05),accent)
 BeaverModels.driver(self,Vector3(0.45,0.88,2.0),0.55,tier)
 # Open glazing exposes the driver without transparent sorting or hidden faces.
 Models.box(self,Vector3(1.8,0.16,0.08),Vector3(0,1.73,2.98),Color("a5e6ef"))
 Models.box(self,Vector3(1.85,0.28,0.12),Vector3(0,0.85,3.02),Color("f2efe0"))
 for x in [-0.7,0.7]: Models.box(self,Vector3(0.35,0.22,0.1),Vector3(x,1.13,3.06),Color("fff8c5"))
 for x in [-1.0,1.0]:
  for z in [-2.1,2.0]: wheel(Vector3(x,0.52,z),0.52)
 var carrier: Node3D=self
 if tier>=4:
  trailer=Node3D.new()
  trailer.name="Lowbed" if tier>=6 else "Trailer"
  add_child(trailer)
  carrier=trailer
 Models.box(carrier,Vector3(2.0,0.24,4.2),Vector3(0,1.05,-0.85),Color("edb848"))
 for x in [-0.97,0.97]:
  for z in [-2.8,0.85]: Models.box(carrier,Vector3(0.12,0.7,0.12),Vector3(x,1.45,z),color)
 cargo=Node3D.new()
 cargo.name="FreightLoad"
 cargo.position=Vector3(0,1.25,-0.9)
 carrier.add_child(cargo)
 if cargo_boards:
  for i in 4: Models.box(cargo,Vector3(1.7,0.17,3.1),Vector3(0,i*0.18,0),Color("edbe78"))
 elif cargo_stone or cargo_boxes:
  for z in [-0.8,0.8]: Models.crafted_box(cargo,Vector3(1.6,0.9,1.3),Vector3(0,0.4,z),Color("d8c7a0"),"plaster",0.08)
 elif cargo_furniture:
  for z in [-0.8,0.8]:
   Models.box(cargo,Vector3(1.3,0.3,1.1),Vector3(0,0.5,z),Color("e7b366"))
   Models.box(cargo,Vector3(1.3,0.9,0.15),Vector3(0,1.0,z-0.5),color)
   for x in [-0.5,0.5]: Models.box(cargo,Vector3(0.17,0.5,0.8),Vector3(x,0.15,z),Color("a87b46"))
 else:
  for x in [-0.48,0.48]:
   var log=Models.cylinder(cargo,0.4,3.2,Vector3(x,0.35,0),Color("946035"))
   log.rotation.x=PI/2
   for z in [-1.61,1.61]:
    var end=Models.cylinder(cargo,0.34,0.03,Vector3(x,0.35,z),Color("f1c985"))
    end.rotation.x=PI/2
 Models.bake(cargo)
 if trailer!=null: Models.bake(trailer)
 Models.bake(self)

func follow_heading(direction: Vector3, delta: float) -> void:
 if direction.length_squared()<0.00001: return
 var heading=atan2(direction.x,direction.z)
 var trailer_heading=trailer.global_rotation.y if trailer!=null else heading
 rotation.y=heading
 if trailer!=null:
  var turn=clampf(wrapf(trailer_heading-heading,-PI,PI),-0.45,0.45)
  trailer.rotation.y=lerp_angle(turn,0,minf(delta*3,1))
 previous_heading=heading

func hollow_cab(at: Vector3,size: Vector3,color: Color,id: int) -> void:
 Models.box(self,Vector3(size.x,0.5,size.z),at,color)
 Models.box(self,Vector3(size.x,0.15,size.z),at+Vector3(0,size.y-0.5,0),color)
 for side in [-1,1]:
  for end in [-1,1]: Models.box(self,Vector3(0.13,size.y-0.5,0.13),at+Vector3(side*(size.x/2-0.08),(size.y-0.5)/2,end*(size.z/2-0.08)),color)
 BeaverModels.driver(self,at+Vector3(0.45,0.2,0),minf(0.67,(size.y-0.6)/2.55),id)
