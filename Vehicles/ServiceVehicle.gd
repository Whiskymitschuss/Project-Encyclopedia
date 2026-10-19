extends Node3D
var kind="police"
var lights: Array=[]
var wheels: Array=[]
var passenger: Node3D
var flash=0.0
var moving=true
var emergency=true

func _ready() -> void:
 var fire=kind=="fire"
 var medical=kind=="ambulance"
 var length=6.2 if fire else 5.6 if medical else 4.6
 var color=Color("ef6050") if fire else Color("fff1d4") if medical else Color("f8c657") if kind=="taxi" else Color("428fae")
 Models.box(self,Vector3(2.5,0.75,length),Vector3(0,1.05,0),color)
 Models.box(self,Vector3(2.3,1.6,2.3 if not medical else 3.8),Vector3(0,1.9,-0.3),color)
 Models.box(self,Vector3(2.15,0.9,0.12),Vector3(0,2.15,1.1 if not medical else 1.65),Color("8fd8df"))
 for x in [-1.28,1.28]:
  Models.box(self,Vector3(0.12,0.7,1.6),Vector3(x,2.1,0),Color("91ced9"))
  for z in [-length*0.31,length*0.31]:
   var wheel=Models.cylinder(self,0.58,0.3,Vector3(x,0.7,z),Color("34505b"))
   wheel.rotation.z=PI/2
   wheel.set_meta("animated",true)
   wheels.append(wheel)
 for x in [-0.8,0.8]: Models.box(self,Vector3(0.42,0.3,0.13),Vector3(x,1.2,length/2+0.05),Color("fff1bc"))
 if kind=="taxi":
  Models.box(self,Vector3(1.2,0.45,0.6),Vector3(0,2.95,0),Color("ffe08b"))
  for x in [-1.27,1.27]:
   for z in [-1,-0.5,0,0.5,1]: Models.box(self,Vector3(0.04,0.25,0.25),Vector3(x,1.45,z),Color("3a5963"))
 else:
  for x in [-0.65,0.65]:
   var beacon=Models.box(self,Vector3(0.5,0.3,0.5),Vector3(x,2.9,0),Color("62c9fa"))
   beacon.set_meta("animated",true)
   lights.append(beacon)
 if fire:
  Models.box(self,Vector3(1.7,0.2,3.9),Vector3(0,2.9,-0.9),Color("dfdcc4"))
  for z in [-2.4,-1.8,-1.2,-0.6,0,0.6]: Models.box(self,Vector3(2.1,0.12,0.12),Vector3(0,3.05,z),Color("b5d0cc"))
 if medical:
  for x in [-1.29,1.29]:
   Models.box(self,Vector3(0.07,0.35,1.1),Vector3(x,2,-0.9),Color("ed7563"))
   Models.box(self,Vector3(0.07,1.1,0.35),Vector3(x,2,-0.9),Color("ed7563"))
 passenger=Node3D.new()
 passenger.set_meta("animated",true)
 add_child(passenger)
 Models.box(passenger,Vector3(0.45,0.7,0.5),Vector3(0.65,1.9,0),Color("ae8cc8"))
 Models.box(passenger,Vector3(0.4,0.4,0.4),Vector3(0.65,2.45,0),Color("f0cda4"))
 Models.bake(passenger)
 passenger.hide()
 Models.bake(self)

func _process(delta: float) -> void:
 flash+=delta
 for i in lights.size():
  var on=emergency and (int(flash*5)+i)%2==0
  lights[i].material_override=Models.material(Color("71d6ff") if on else Color("38788f"),on)
 if moving:
  for wheel in wheels: wheel.rotate_object_local(Vector3.UP,delta*8)
