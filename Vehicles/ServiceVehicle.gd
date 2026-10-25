extends Node3D
var kind="police"
var lights: Array=[]
var wheels: Array=[]
var passenger: Node3D
var flash=0.0
var moving=true
var emergency=true

func _ready() -> void:
 scale=Vector3.ONE*0.84
 var fire=kind=="fire"
 var medical=kind=="ambulance"
 var length=6.2 if fire else 5.6 if medical else 4.6
 var color=Color("ef6050") if fire else Color("fff1d4") if medical else Color("f8c657") if kind=="taxi" else Color("428fae")
 Models.soft_box(self,Vector3(2.5,0.75,length),Vector3(0,1.05,0),color)
 BeaverModels.cockpit(self,Vector3(0,1.4,0.15),Vector3(2.3,1.3,2.1),color,3 if fire else 8,"industry" if fire else "logistics")
 if medical: Models.soft_box(self,Vector3(2.3,1.6,2.0),Vector3(0,1.9,-1.6),color)
 for x in [-1.28,1.28]:
  for z in [-length*0.31,length*0.31]:
   var wheel=Models.cylinder(self,0.58,0.3,Vector3(x,0.7,z),Color("34505b"))
   wheel.rotation.z=PI/2
   wheel.set_meta("animated",true)
   wheels.append(wheel)
 for x in [-0.8,0.8]: Models.soft_box(self,Vector3(0.42,0.3,0.13),Vector3(x,1.2,length/2+0.05),Color("fff1bc"))
 if kind=="taxi":
  Models.soft_box(self,Vector3(1.2,0.45,0.6),Vector3(0,2.95,0),Color("ffe08b"))
  for x in [-1.27,1.27]:
   for z in [-1,-0.5,0,0.5,1]: Models.soft_box(self,Vector3(0.04,0.25,0.25),Vector3(x,1.45,z),Color("3a5963"))
 else:
  for x in [-0.65,0.65]:
   var beacon=Models.soft_box(self,Vector3(0.5,0.3,0.5),Vector3(x,2.9,0),Color("62c9fa"))
   beacon.set_meta("animated",true)
   lights.append(beacon)
 if fire:
  Models.soft_box(self,Vector3(1.7,0.2,3.9),Vector3(0,2.9,-0.9),Color("dfdcc4"))
  for z in [-2.4,-1.8,-1.2,-0.6,0,0.6]: Models.soft_box(self,Vector3(2.1,0.12,0.12),Vector3(0,3.05,z),Color("b5d0cc"))
 if medical:
  for x in [-1.29,1.29]:
   Models.soft_box(self,Vector3(0.07,0.35,1.1),Vector3(x,2,-0.9),Color("ed7563"))
   Models.soft_box(self,Vector3(0.07,1.1,0.35),Vector3(x,2,-0.9),Color("ed7563"))
 passenger=BeaverModels.create(5,"civilian",true)
 passenger.name="Passenger"
 passenger.position=Vector3(0.62,1.46,0)
 passenger.scale=Vector3.ONE*0.43
 add_child(passenger)
 # Move the driver into the other seat so taxi passengers never intersect it.
 get_node("Driver").position.x=-0.58
 get_node("Driver").scale=Vector3.ONE*0.43
 passenger.hide()
 Models.bake(self)

func _process(delta: float) -> void:
 if Game.state.ux.motion: flash+=delta
 for i in lights.size():
  var on=emergency and (int(flash*5)+i)%2==0
  lights[i].material_override=Models.material(Color("71d6ff") if on else Color("38788f"),on)
 if moving and Game.state.ux.motion:
  for wheel in wheels: wheel.rotate_object_local(Vector3.UP,delta*8)
