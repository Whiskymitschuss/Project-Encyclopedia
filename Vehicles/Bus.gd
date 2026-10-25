class_name TimberBus
extends Node3D

var line_index = 0
var wheels: Array = []
var doors: Array = []
var moving = false
var waiting = true

func _ready() -> void:
 scale=Vector3.ONE*0.64
 var colors=[Color("ffd05b"),Color("ef8b77"),Color("83cbb5")]
 var tone=colors[line_index%3]
 Models.soft_box(self,Vector3(3.5,1.1,8.2),Vector3(0,1.4,0),tone)
 Models.soft_box(self,Vector3(3.5,1.6,5.9),Vector3(0,2.75,-1.15),tone)
 BeaverModels.cockpit(self,Vector3(0,1.95,2.85),Vector3(3.3,1.55,2.2),tone,line_index)
 Models.soft_box(self,Vector3(3.3,0.35,7.8),Vector3(0,3.75,0),Color("f7e9c7"))
 Models.soft_box(self,Vector3(3.1,0.16,0.15),Vector3(0,2.15,4.15),Color("5cbed4"))
 Models.soft_box(self,Vector3(2.7,0.55,0.2),Vector3(0,3.5,4.2),Color("285365"))
 for side in [-1,1]:
  for z in [-2.7,-0.8,1.2]: Models.soft_box(self,Vector3(0.15,1.5,1.55),Vector3(side*1.8,2.8,z),Color("5cbed4"))
  for z in [-2.6,2.6]:
   var wheel=Models.cylinder(self,0.8,0.4,Vector3(side*1.9,0.8,z),Color("2d4854"))
   wheel.rotation.z=PI/2
   wheel.set_meta("animated",true)
   wheels.append(wheel)
 for z in [1.9,2.7]:
  var door=Models.soft_box(self,Vector3(0.16,2.3,0.7),Vector3(1.84,2.2,z),Color("396374"))
  door.set_meta("animated",true)
  doors.append(door)
 for x in [-1.1,1.1]: Models.soft_box(self,Vector3(0.65,0.4,0.2),Vector3(x,1.7,4.2),Color("fff4bd"))
 Models.bake(self)
 Models.label(self,"%s" % (line_index+1),Vector3(0,4.6,0),25)

func _process(delta: float) -> void:
 if line_index>=Game.state.town.lines.size(): return
 var line=Game.state.town.lines[line_index]
 var plan=Game.transit_plan(line.stops)
 if plan.is_empty(): visible=false; return
 visible=true
 var sample=TownRules.bus_sample(plan,float(line.phase)+Game.tick_clock)
 var direction: Vector3=sample.direction.normalized()
 position=sample.position+Vector3(direction.z,0,-direction.x)*1.35
 position.y=StreetSurface.ROAD_Y+0.02
 rotation.y=atan2(direction.x,direction.z)
 waiting=sample.waiting
 moving=not waiting
 for wheel in wheels:
  if moving: wheel.rotate_object_local(Vector3.UP,delta*12)
 for i in doors.size(): doors[i].position.z=lerpf(doors[i].position.z,1.9+i*0.8+(0.35 if i==1 else -0.35)*(1.0 if waiting else 0.0),minf(1,delta*8))
