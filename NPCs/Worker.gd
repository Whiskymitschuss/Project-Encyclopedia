class_name TimberWorker
extends Node3D

var walk_route=[]
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
var social_left=0.0
var social_kind=""
var social_facing=0.0
var social_cooldown=0.0
var resting=false
var rest_via=Vector3.ZERO
var mug: Node3D

func _ready() -> void:
 position=origin_point+Vector3(0,0.6,0)
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
 mug=Node3D.new()
 limbs[2].add_child(mug)
 Models.cylinder(mug,0.16,0.28,Vector3(0,-0.77,0.2),Color("fff0ce"))
 Models.cylinder(mug,0.12,0.02,Vector3(0,-0.62,0.2),Color("6c4938"))
 Models.box(mug,Vector3(0.1,0.14,0.2),Vector3(0.18,-0.76,0.2),Color("fff0ce"))
 mug.hide()
 pack=Node3D.new()
 body.add_child(pack)
 if role=="forester":
  Models.log_pile(pack,Vector3(-0.6,1,-0.8),2)
  pack.scale=Vector3.ONE*0.45
 Models.bake(body)

func _process(delta: float) -> void:
 social_cooldown=maxf(0,social_cooldown-delta)
 body.position=Vector3.ZERO
 body.rotation.z=0
 mug.hide()
 resting=false
 for limb in limbs: limb.rotation=Vector3.ZERO
 if not Game.state.get("ambient_enabled",true): social_left=0
 if social_left>0:
  social_left=maxf(0,social_left-delta)
  body.rotation.y=social_facing
  if social_kind=="cheer": pack.hide()
  if social_kind=="cheer":
   body.position.y=absf(sin(social_left*6))*0.2
   for i in [2,3]: limbs[i].rotation.x=-2.5+sin(social_left*8+i)*0.3
  else:
   limbs[3].rotation.x=-2.3
   limbs[3].rotation.z=sin(social_left*10)*0.35
  return
 if role=="neighbor":
  neighbor_step(delta)
  return
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
 if role=="forester" and walk_route.size()>1:
  var sample=LogisticsRoutes.sample(walk_route,amount)
  position=sample.position
  body.rotation.y=atan2(sample.direction.x,sample.direction.z)+(PI if travel>0.5 else 0)
 else: position=origin_point.lerp(destination,smoothstep(0,1,amount))
 position.y=0.6+absf(sin(phase*5))*0.09
 if walk_route.is_empty(): body.rotation.y=atan2(destination.x-origin_point.x,destination.z-origin_point.z)+(PI if travel>0.5 else 0)
 for i in limbs.size(): limbs[i].rotation.x=sin(phase*5+(i%2)*PI)*0.45
 pack.visible=role=="forester" and travel>0.5

func begin_social(kind: String, towards: Vector3) -> void:
 social_kind=kind
 social_left=3.5 if kind=="cheer" else 1.4
 social_cooldown=25
 social_facing=atan2(towards.x-position.x,towards.z-position.z)

func neighbor_step(delta: float) -> void:
 phase+=delta*pace
 var cycle=fmod(phase,28.0)
 pack.hide()
 if cycle<9:
  position=rest_route(cycle/9.0)+Vector3(0,0.6,0)
  body.rotation.y=atan2(destination.x-origin_point.x,destination.z-origin_point.z)
 elif cycle<16:
  position=destination+Vector3(0,0.6,0)
  body.rotation.y=facing
  if Game.state.get("ambient_enabled",true):
   resting=true
   body.position.y=-0.55
   for i in [0,1]: limbs[i].rotation.x=-1.4
   limbs[2].rotation.x=-1.75-0.3*sin(cycle*1.6)
   mug.show()
 elif cycle<25:
  position=rest_route(1-(cycle-16)/9.0)+Vector3(0,0.6,0)
  body.rotation.y=atan2(origin_point.x-destination.x,origin_point.z-destination.z)
 else:
  position=origin_point+Vector3(0,0.6,0)
  body.rotation.y=facing
 if not resting and (cycle<9 or cycle>=16 and cycle<25):
  for i in limbs.size(): limbs[i].rotation.x=sin(phase*5+(i%2)*PI)*0.4

func rest_route(amount: float) -> Vector3:
 if amount<0.55: return origin_point.lerp(rest_via,smoothstep(0,1,amount/0.55))
 return rest_via.lerp(destination,smoothstep(0,1,(amount-0.55)/0.45))
