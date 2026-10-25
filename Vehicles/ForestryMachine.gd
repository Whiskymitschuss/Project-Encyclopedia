class_name ForestryMachine
extends Node3D

const STAND_SIZE=Vector2(9,9)

static func clearance(at: Vector3) -> Rect2:
 return Rect2(Vector2(at.x,at.z)-STAND_SIZE/2,STAND_SIZE)

var tier = 10
var origin_point = Vector3.ZERO
var phase = 0.0
var wheels: Array = []
var turret: Node3D
var boom: Node3D
var forearm: Node3D
var saw: Node3D
var cargo: Node3D
var working = false
var work_left=0.0
var station_index=-1
var handling=false

func _ready() -> void:
 set_meta("forestry_tier",tier)
 var giant = tier>=13
 var color = Color("efb93e") if tier<12 else Color("ef8e42") if tier==12 else Color("dcb64d") if tier==13 else Color("6dc9db")
 var length = 4.8 if tier==10 else 6.6 if not giant else 7.4
 Models.soft_box(self,Vector3(3.4,0.9,length),Vector3(0,1.3,0),Color("395568"))
 for x in [-1.85,1.85]:
  if giant:
   Models.soft_box(self,Vector3(0.9,1.1,7.4),Vector3(x,0.9,0),Color("364e59"))
   for z in [-2.8,-1.4,0,1.4,2.8]:
    var roller=Models.cylinder(self,0.55,0.95,Vector3(x,0.9,z),Color("778b8c"))
    roller.rotation.z=PI/2
    roller.set_meta("animated",true)
    wheels.append(roller)
  else:
   for z in [-length*0.32,0,length*0.32]:
    if tier==10 and z==0: continue
    var wheel=Models.cylinder(self,0.95,0.65,Vector3(x,0.95,z),Color("2d4651"))
    wheel.rotation.z=PI/2
    wheel.set_meta("animated",true)
    wheels.append(wheel)
 turret=Node3D.new()
 add_child(turret)
 turret.position.y=1.8
 Models.soft_box(turret,Vector3(3.3,1.3,3.1),Vector3(0,0.6,0),color)
 BeaverModels.cockpit(turret,Vector3(-0.4,1.3,-0.5),Vector3(2.2,2.1,2.0),color,tier,"forester")
 Models.cylinder(turret,0.28,0.4,Vector3(-0.4,3.8,-0.5),Color("ffc94f"))
 boom=Node3D.new()
 turret.add_child(boom)
 boom.position=Vector3(0.9,1.3,1)
 Models.soft_box(boom,Vector3(0.7,4.4,0.8),Vector3(0,2.1,0),color)
 Models.cylinder(boom,0.13,3.7,Vector3(0.5,1.9,0),Color("d0e0df"))
 forearm=Node3D.new()
 boom.add_child(forearm)
 forearm.position.y=4.1
 Models.soft_box(forearm,Vector3(0.65,3.6,0.75),Vector3(0,-1.7,0),color)
 Models.cylinder(forearm,0.13,3,Vector3(0.4,-1.3,0),Color("d4e0dc"))
 var head=Node3D.new()
 forearm.add_child(head)
 head.position.y=-3.4
 Models.soft_box(head,Vector3(2,1.6,1.5),Vector3(0,-0.5,0),Color("3a6473"))
 for x in [-1,1]: Models.soft_box(head,Vector3(0.3,1.8,1.8),Vector3(x,-1,0.4),color)
 saw=Node3D.new()
 head.add_child(saw)
 var blade=Models.cylinder(saw,1.25,0.16,Vector3.ZERO,Color("c6d9d8"))
 for i in 10:
  var angle=i*TAU/10
  var tooth=Models.soft_box(saw,Vector3(0.4,0.2,0.4),Vector3(cos(angle)*1.25,0,sin(angle)*1.25),Color("dee8d9"))
  tooth.rotation.y=-angle
 saw.position=Vector3(0,-1.6,0.6)
 cargo=Node3D.new()
 add_child(cargo)
 cargo.position=Vector3(-0.8,1.6,-2.2)
 Models.log_pile(cargo,Vector3.ZERO,3 if tier==10 else 6)
 scale=Vector3.ONE*(0.62 if tier==10 else 0.68 if tier<13 else 0.72)
 # Keep only animated subtrees separate; combine the static coloured geometry.
 for node in [self,turret,boom,forearm,head,saw,cargo]: Models.bake(node)
 position=origin_point

func _process(delta: float) -> void:
 # Finish the already earned load cycle before parking; never start a cycle
 # just to make an actually blocked forest look productive.
 var rate=float(Game.flow.get("harvest:%s" % station_index,Game.flow.get("harvest",0)))
 if float(Game.flow.get("harvest",0))<=0: rate=0
 if station_index>=0 and Game.state.buildings[station_index].get("paused",false): rate=0
 if rate>0: work_left=maxf(work_left,20.0-fposmod(phase,20.0))
 working=work_left>0
 handling=station_index>=0 and ForestryFlow.loading(Game.state,station_index)
 if not working and not handling:
  cargo.hide()
  return
 if not Game.state.ux.motion: return
 work_left=maxf(0,work_left-delta)
 phase+=delta
 var travel=fmod(phase,20.0)
 var angle=sin(phase*0.14)*0.55
 position=origin_point+Vector3(sin(phase*0.11)*0.8,0,cos(phase*0.13)*0.6)
 rotation.y=angle
 turret.rotation.y=sin(phase*0.32)*0.65
 boom.rotation.x=-0.65+sin(phase*0.9)*0.16
 forearm.rotation.x=1.85+sin(phase*0.9+1)*0.2
 if working: saw.rotation.y+=delta*12
 cargo.visible=handling or (travel>7 and travel<17)
 for wheel in wheels: wheel.rotate_object_local(Vector3.UP,delta*1.4)
