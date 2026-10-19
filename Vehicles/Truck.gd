class_name TimberTruck
extends Node3D

var path: Array[Vector3] = []
var segment = 0
var speed = 10.0
var wheels: Array = []

func _ready() -> void:
 Models.box(self,Vector3(3.2,1.1,7),Vector3(0,1.2,0),Color("476775"))
 Models.box(self,Vector3(3.5,2.7,2.4),Vector3(0,2.3,2.3),Color("eac170"))
 Models.box(self,Vector3(2.9,1.2,0.15),Vector3(0,2.9,3.55),Color("9ed2d4"))
 for x in [-1.1,1.1]: Models.box(self,Vector3(0.65,0.45,0.2),Vector3(x,1.6,3.6),Color("fff1b2"))
 Models.log_pile(self,Vector3(-0.8,1.6,-1.2),6)
 for x in [-1.8,1.8]:
  for z in [-2,2]:
   var wheel = Models.cylinder(self,0.85,0.4,Vector3(x,0.8,z),Color("34484b"))
   wheel.rotation.z = PI/2
   wheels.append(wheel)
 if not path.is_empty(): position = path[0]

func _process(delta: float) -> void:
 if path.size() < 2: return
 var goal = path[(segment+1)%path.size()]
 var direction = goal-position
 if direction.length() < speed*delta:
  position = goal
  segment = (segment+1)%path.size()
 else:
  position += direction.normalized()*speed*delta
 if direction.length_squared() > 0.01: rotation.y = atan2(direction.x,direction.z)
 for wheel in wheels: wheel.rotation.y += delta*speed
