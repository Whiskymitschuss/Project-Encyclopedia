extends Node3D

# A bounded visual handler for the actual output of an active workshop.
# It never creates cargo, changes stock or awards money.
var phase=0.0
var active=false
var presentation_enabled=true
var travelled=0.0
var wheels=[]
var forks: Node3D
var payload: Node3D
var chassis: Node3D
var operator: Node3D
var points=[Vector3(6,0.6,5),Vector3(6,0.6,8),Vector3(3.5,0.6,8),Vector3(6,0.6,8),Vector3(6,0.6,5)]

func _ready() -> void:
 position=points[0]
 chassis=Node3D.new()
 add_child(chassis)
 Models.box(chassis,Vector3(1.5,0.9,2),Vector3(0,0.85,0),Color("efad31"))
 Models.box(chassis,Vector3(1.2,0.6,0.6),Vector3(0,1.5,-0.6),Color("363c46"))
 for x in [-0.64,0.64]:
  for z in [-0.65,0.65]:
   var wheel=Node3D.new()
   chassis.add_child(wheel)
   wheel.position=Vector3(x,0.45,z)
   var tire=Models.cylinder(wheel,0.4,0.25,Vector3.ZERO,Color("354047"))
   tire.rotation.z=PI/2
   Models.bake(wheel)
   wheels.append(wheel)
 for x in [-0.6,0.6]:
  Models.box(chassis,Vector3(0.12,2.3,0.12),Vector3(x,2,0),Color("34434a"))
 Models.box(chassis,Vector3(1.5,0.15,1.6),Vector3(0,3.1,0),Color("efad31"))
 operator=Node3D.new()
 chassis.add_child(operator)
 Models.box(operator,Vector3(0.6,0.7,0.5),Vector3(0,1.85,0),Color("57a96b"))
 Models.box(operator,Vector3(0.5,0.5,0.5),Vector3(0,2.4,0.05),Color("f5c797"))
 Models.cylinder(operator,0.36,0.18,Vector3(0,2.7,0.05),Color("ffce43"))
 Models.bake(operator)
 for x in [-0.5,0.5]: Models.box(chassis,Vector3(0.12,2.8,0.12),Vector3(x,1.6,1.05),Color("34434a"))
 forks=Node3D.new()
 chassis.add_child(forks)
 for x in [-0.5,0.5]: Models.box(forks,Vector3(0.16,0.12,1.4),Vector3(x,0.25,1.6),Color("647179"))
 payload=Node3D.new()
 payload.position=Vector3(0,0.42,1.6)
 forks.add_child(payload)
 var key=str(Catalog.RECIPES[get_parent().get_node("Processing").kind].out.keys()[0])
 if key in ["furniture","design"]:
  Models.box(payload,Vector3(1.8,0.3,1.8),Vector3(0,1.0,0),Color("c99459"))
  Models.box(payload,Vector3(1.8,1.5,0.2),Vector3(0,1.8,-0.7),Color("c99459"))
  for x in [-0.65,0.65]:
   for z in [-0.65,0.65]: Models.box(payload,Vector3(0.2,0.9,0.2),Vector3(x,0.45,z),Color("ad7947"))
 elif key in ["paper","pellets"]:
  Models.box(payload,Vector3(2,1.8,2.2),Vector3(0,0.9,0),Color("eddfb6"))
 else:
  for i in 3: Models.box(payload,Vector3(0.65,0.3,3.6),Vector3((i-1)*0.78,0.3,0),Color("c99459"))
 payload.scale=Vector3.ONE*0.45
 Models.bake(payload)
 Models.bake(forks)
 Models.bake(chassis)

func _process(delta: float) -> void:
 var machine=get_parent().get_node_or_null("Processing")
 if machine==null: return
 var camera=get_viewport().get_camera_3d()
 var close=camera!=null and camera.global_position.distance_to(global_position)<260
 visible=close and presentation_enabled
 var index=int(machine.building_index)
 active=visible and index>=0 and float(Game.flow.get("building:%s" % index,0))>0 and not Game.state.buildings[index].get("paused",false) and not (Game.delivery_owns(index) and Game.state.delivery.paused)
 if not active or not Game.state.ux.motion or not Game.state.ambient_enabled: return
 phase=fmod(phase+delta*0.16,4)
 var segment=floori(phase)
 var target: Vector3=points[segment].lerp(points[segment+1],fposmod(phase,1))
 var distance=position.distance_to(target)
 travelled+=distance
 position=target
 var direction: Vector3=points[segment+1]-points[segment]
 rotation.y=atan2(direction.x,direction.z)
 for wheel in wheels: wheel.rotation.x+=distance/0.4
 forks.position.y=0.12+0.25*sin(fposmod(phase,1)*PI)
 payload.visible=segment<2
 operator.rotation.z=sin(travelled*0.8)*0.035
