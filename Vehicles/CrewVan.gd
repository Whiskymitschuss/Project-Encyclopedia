extends Node3D

var wheels=[]
var passengers=[]
var door: Node3D
var door_open=0.0
var people=0
var moving=false

func _ready() -> void:
 scale=Vector3.ONE*0.84
 Models.soft_box(self,Vector3(2.8,0.7,6.8),Vector3(0,1.0,0),Color("f6f0dc"))
 Models.soft_box(self,Vector3(2.65,1.8,3.6),Vector3(0,2.0,-1.35),Color("f6f0dc"))
 Models.soft_box(self,Vector3(2.6,0.18,6.6),Vector3(0,1.2,0),Color("3d5863"))
 Models.soft_box(self,Vector3(2.5,0.3,2.7),Vector3(0,1.5,2.1),Color("fff5df"))
 BeaverModels.cockpit(self,Vector3(-0.58,1.45,1.35),Vector3(2.5,1.55,2.1),Color("f6f0dc"),2,"industry")
 get_node("Driver").scale=Vector3.ONE*0.43
 get_node("Driver").position.x=-0.6
 for i in SEAT_POSITIONS.size():
  var beaver=BeaverModels.create(i+3,"industry",true)
  beaver.position=SEAT_POSITIONS[i]
  beaver.scale=Vector3.ONE*0.43
  beaver.hide()
  add_child(beaver)
  passengers.append(beaver)
 for x in [-1.36,1.36]:
  Models.soft_box(self,Vector3(0.07,0.7,2.7),Vector3(x,2.25,-1.25),Color("78aeb2"))
  for z in [-2.25,2.25]:
   var wheel=Models.cylinder(self,0.61,0.35,Vector3(x,0.65,z),Color("324653"))
   wheel.rotation.z=PI/2
   wheel.set_meta("animated",true)
   wheels.append(wheel)
 for x in [-0.9,0.9]:
  Models.soft_box(self,Vector3(0.5,0.3,0.12),Vector3(x,1.1,3.45),Color("fff0ad"))
  Models.soft_box(self,Vector3(0.22,0.5,0.12),Vector3(x,1.4,-3.45),Color("e36e4a"))
 for z in [-2.1,0.2]: Models.soft_box(self,Vector3(2.9,0.14,0.18),Vector3(0,3.0,z),Color("466273"))
 var ladder=WorkTools.ladder(self,4.7)
 ladder.rotation.x=PI/2
 ladder.position=Vector3(-0.55,3.13,-2.5)
 var tools=WorkTools.toolbox(self)
 tools.position=Vector3(0.7,3.35,-1.7)
 door=Node3D.new()
 door.name="SlidingDoor"
 add_child(door)
 door.position=Vector3(1.43,1.95,-0.7)
 Models.soft_box(door,Vector3(0.1,1.7,1.9),Vector3.ZERO,Color("f5efdb"))
 Models.soft_box(door,Vector3(0.12,0.65,1.6),Vector3(0,0.28,0),Color("78aeb2"))
 Models.soft_box(door,Vector3(0.13,0.13,0.35),Vector3(0.1,-0.3,0.5),Color("3d5863"))
 Models.bake(door)
 Models.bake(self)

const SEAT_POSITIONS=[Vector3(0.6,1.45,1.35),Vector3(-0.58,1.45,-0.55),Vector3(0.58,1.45,-0.55),Vector3(0,1.45,-2)]

func _process(delta: float) -> void:
 for i in passengers.size(): passengers[i].visible=i<people
 if not Game.state.ux.motion: return
 door.position.z=lerpf(door.position.z,-0.7-door_open*1.7,minf(1,delta*8))
 if moving:
  for wheel in wheels: wheel.rotate_object_local(Vector3.UP,delta*7)
