class_name TimberWorker
extends Node3D

var origin_point = Vector3.ZERO
var destination = Vector3.ZERO
var phase = 0.0
var pace = 1.0
var body: Node3D
var pack: Node3D

func _ready() -> void:
 body = Node3D.new()
 add_child(body)
 Models.cylinder(body,0.45,1.4,Vector3(0,1.6,0),Color("da9d62"))
 Models.cylinder(body,0.35,0.65,Vector3(0,2.55,0),Color("f2cd9d"))
 Models.cylinder(body,0.49,0.25,Vector3(0,2.95,0),Color("f4d475"))
 for x in [-0.23,0.23]: Models.box(body,Vector3(0.3,0.9,0.4),Vector3(x,0.55,0),Color("3e667b"))
 var axe = Models.box(body,Vector3(0.15,1.5,0.15),Vector3(0.7,1.5,0),Color("ab8153"))
 axe.rotation.z = -0.6
 Models.box(body,Vector3(0.7,0.45,0.2),Vector3(1.05,2,0),Color("c4d9d3"))
 pack = Node3D.new()
 body.add_child(pack)
 Models.log_pile(pack,Vector3(-0.6,1,-0.8),2)
 pack.scale = Vector3.ONE*0.45

func _process(delta: float) -> void:
 phase += delta*pace*Game.boost("workers")
 var travel = fmod(phase,18.0)/18.0
 var amount = travel*2.0 if travel < 0.5 else (1.0-travel)*2.0
 position = origin_point.lerp(destination,smoothstep(0.0,1.0,amount))
 position.y = 0.6+absf(sin(phase*5))*0.12
 body.rotation.y = atan2(destination.x-origin_point.x,destination.z-origin_point.z)+(PI if travel > 0.5 else 0)
 body.rotation.z = sin(phase*5)*0.06
 pack.visible = travel > 0.5
