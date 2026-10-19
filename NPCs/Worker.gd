class_name TimberWorker
extends Node3D

var origin_point = Vector3.ZERO
var destination = Vector3.ZERO
var phase = 0.0
var pace = 1.0
var role = "forester"
var production_index = -1
var facing = 0.0
var working = false
var body: Node3D
var pack: Node3D
var limbs: Array = []

func _ready() -> void:
 body=Node3D.new()
 add_child(body)
 var shirt=Color("209ec7") if role!="resident" else Color("af79ba")
 Models.box(body,Vector3(0.88,1.2,0.65),Vector3(0,1.65,0),shirt)
 for x in [-0.27,0.27]: Models.box(body,Vector3(0.13,1.1,0.07),Vector3(x,1.7,0.36),Color("efdc59"))
 Models.box(body,Vector3(0.9,0.15,0.1),Vector3(0,1.3,0.36),Color("efdc59"))
 Models.box(body,Vector3(0.66,0.7,0.64),Vector3(0,2.58,0),Color("f3cd9e"))
 if role!="resident":
  Models.cylinder(body,0.52,0.22,Vector3(0,3,0),Color("ffc43e"))
  Models.cylinder(body,0.43,0.3,Vector3(0,3.17,0),Color("ffd45b"),0.28)
 else: Models.box(body,Vector3(0.73,0.22,0.73),Vector3(0,2.98,0),Color("62493c"))
 for x in [-0.17,0.17]: Models.box(body,Vector3(0.08,0.1,0.04),Vector3(x,2.65,0.34),Color("344f5b"))
 for i in 4:
  var limb=Node3D.new()
  body.add_child(limb)
  var arm=i>=2
  limb.position=Vector3((-1 if i%2==0 else 1)*(0.59 if arm else 0.24),2.1 if arm else 1.1,0)
  Models.box(limb,Vector3(0.3,0.65 if arm else 0.85,0.4),Vector3(0,-0.35,0),shirt if arm else Color("355d78"))
  Models.box(limb,Vector3(0.31,0.28,0.43 if arm else 0.58),Vector3(0,-0.78,0.03),Color("f3cd9e") if arm else Color("334449"))
  Models.bake(limb)
  limbs.append(limb)
 pack=Node3D.new()
 body.add_child(pack)
 if role=="forester":
  Models.log_pile(pack,Vector3(-0.6,1,-0.8),2)
  pack.scale=Vector3.ONE*0.45
 Models.bake(body)

func _process(delta: float) -> void:
 if role=="operator":
  working=production_index>=0 and production_index<Game.state.buildings.size() and not Game.state.buildings[production_index].get("paused",false) and float(Game.flow.get("building:%s" % production_index,0))>0
  if working: phase+=delta*pace*3
  position=origin_point+Vector3(0,0.6,0)
  body.rotation.y=facing
  for i in [2,3]: limbs[i].rotation.x=-0.8+sin(phase+(i%2)*PI)*0.35 if working else -0.1
  return
 phase+=delta*pace*Game.boost("workers")
 var travel=fmod(phase,18.0)/18.0
 var amount=travel*2.0 if travel<0.5 else (1.0-travel)*2.0
 position=origin_point.lerp(destination,smoothstep(0,1,amount))
 position.y=0.6+absf(sin(phase*5))*0.09
 body.rotation.y=atan2(destination.x-origin_point.x,destination.z-origin_point.z)+(PI if travel>0.5 else 0)
 for i in limbs.size(): limbs[i].rotation.x=sin(phase*5+(i%2)*PI)*0.45
 pack.visible=role=="forester" and travel>0.5
