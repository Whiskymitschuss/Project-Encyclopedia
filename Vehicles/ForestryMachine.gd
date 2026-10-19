class_name ForestryMachine
extends Node3D

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

func _ready() -> void:
 set_meta("forestry_tier",tier)
 var giant = tier>=13
 var color = Color("efb93e") if tier<12 else Color("ef8e42") if tier==12 else Color("dcb64d") if tier==13 else Color("6dc9db")
 var length = 4.8 if tier==10 else 6.6 if not giant else 7.4
 Models.box(self,Vector3(3.4,0.9,length),Vector3(0,1.3,0),Color("395568"))
 for x in [-1.85,1.85]:
  if giant:
   Models.box(self,Vector3(0.9,1.1,7.4),Vector3(x,0.9,0),Color("364e59"))
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
 Models.box(turret,Vector3(3.3,1.3,3.1),Vector3(0,0.6,0),color)
 Models.box(turret,Vector3(2.2,2.5,2.0),Vector3(-0.4,2,-0.5),color)
 Models.box(turret,Vector3(2.05,1.7,0.12),Vector3(-0.4,2.3,0.55),Color("74c7dc"))
 for x in [-1.2,0.45]: Models.box(turret,Vector3(0.13,1.9,2.1),Vector3(x,2.3,-0.5),Color("345563"))
 Models.box(turret,Vector3(2.5,0.25,2.3),Vector3(-0.4,3.4,-0.5),color.lightened(0.18))
 Models.cylinder(turret,0.28,0.4,Vector3(-0.4,3.8,-0.5),Color("ffc94f"))
 boom=Node3D.new()
 turret.add_child(boom)
 boom.position=Vector3(0.9,1.3,1)
 Models.box(boom,Vector3(0.7,4.4,0.8),Vector3(0,2.1,0),color)
 Models.cylinder(boom,0.13,3.7,Vector3(0.5,1.9,0),Color("d0e0df"))
 forearm=Node3D.new()
 boom.add_child(forearm)
 forearm.position.y=4.1
 Models.box(forearm,Vector3(0.65,3.6,0.75),Vector3(0,-1.7,0),color)
 Models.cylinder(forearm,0.13,3,Vector3(0.4,-1.3,0),Color("d4e0dc"))
 var head=Node3D.new()
 forearm.add_child(head)
 head.position.y=-3.4
 Models.box(head,Vector3(2,1.6,1.5),Vector3(0,-0.5,0),Color("3a6473"))
 for x in [-1,1]: Models.box(head,Vector3(0.3,1.8,1.8),Vector3(x,-1,0.4),color)
 saw=Node3D.new()
 head.add_child(saw)
 var blade=Models.cylinder(saw,1.25,0.16,Vector3.ZERO,Color("c6d9d8"))
 for i in 10:
  var angle=i*TAU/10
  var tooth=Models.box(saw,Vector3(0.4,0.2,0.4),Vector3(cos(angle)*1.25,0,sin(angle)*1.25),Color("dee8d9"))
  tooth.rotation.y=-angle
 saw.position=Vector3(0,-1.6,0.6)
 cargo=Node3D.new()
 add_child(cargo)
 cargo.position=Vector3(-0.8,1.6,-2.2)
 Models.log_pile(cargo,Vector3.ZERO,3 if tier==10 else 6)
 scale=Vector3.ONE*(0.8 if tier==10 else 1.0 if tier<13 else 1.25)
 # Keep only animated subtrees separate; combine the static coloured geometry.
 for node in [self,turret,boom,forearm,head,saw,cargo]: Models.bake(node)
 position=origin_point

func _process(delta: float) -> void:
 working=float(Game.flow.get("harvest",0))>0
 if not working: return
 phase+=delta
 var travel=fmod(phase,20.0)
 var angle=sin(phase*0.14)*0.55
 position=origin_point+Vector3(sin(phase*0.11)*2.5,0,cos(phase*0.13)*1.4)
 rotation.y=angle
 turret.rotation.y=sin(phase*0.32)*0.65
 boom.rotation.x=-0.65+sin(phase*0.9)*0.16
 forearm.rotation.x=1.85+sin(phase*0.9+1)*0.2
 saw.rotation.y+=delta*12
 cargo.visible=travel>7 and travel<17
 for wheel in wheels: wheel.rotate_object_local(Vector3.UP,delta*1.4)
