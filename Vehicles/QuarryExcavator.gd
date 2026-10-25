extends Node3D
var turret: Node3D
var boom: Node3D
var stick: Node3D
var bucket: Node3D
var load_mesh: Node3D
var phase_value=0
var phase_fraction=0.0
var loaded=false
var active=false

func _ready() -> void:
 scale=Vector3.ONE*0.8
 var yellow=Color("f4b638")
 Models.soft_box(self,Vector3(3,0.7,4.4),Vector3(0,0.9,0),Color("435967"))
 for x in [-1.6,1.6]:
  Models.soft_box(self,Vector3(0.8,0.9,4.7),Vector3(x,0.6,0),Color("3b4d56"))
  for z in [-1.6,-0.8,0,0.8,1.6]:
   var roller=Models.cylinder(self,0.34,0.85,Vector3(x,0.65,z),Color("7a8d91"))
   roller.rotation.z=PI/2
 turret=Node3D.new()
 add_child(turret)
 turret.position.y=1.3
 Models.cylinder(turret,1.1,0.4,Vector3.ZERO,Color("6c7b7b"))
 Models.soft_box(turret,Vector3(2.8,1.1,2.6),Vector3(0,0.65,-0.4),yellow)
 BeaverModels.cockpit(turret,Vector3(-0.5,1.2,-0.25),Vector3(1.6,1.5,1.9),yellow,7,"industry")
 boom=Node3D.new()
 turret.add_child(boom)
 boom.position=Vector3(0.8,0.8,0.7)
 Models.soft_box(boom,Vector3(0.6,3.5,0.65),Vector3(0,1.7,0),yellow)
 Models.cylinder(boom,0.1,2.9,Vector3(0.4,1.4,0),Color("cbd8d4"))
 stick=Node3D.new()
 boom.add_child(stick)
 stick.position.y=3.3
 Models.soft_box(stick,Vector3(0.55,2.8,0.6),Vector3(0,-1.3,0),yellow)
 Models.cylinder(stick,0.09,2.4,Vector3(0.35,-1.1,0),Color("d9e0d5"))
 bucket=Node3D.new()
 stick.add_child(bucket)
 bucket.position.y=-2.7
 Models.soft_box(bucket,Vector3(1.7,0.4,1.8),Vector3(0,-0.2,0.5),Color("526e79"))
 for x in [-0.8,0.8]: Models.soft_box(bucket,Vector3(0.18,0.9,1.8),Vector3(x,0.2,0.5),yellow)
 Models.soft_box(bucket,Vector3(1.7,0.9,0.18),Vector3(0,0.2,-0.3),Color("6a8490"))
 for x in [-0.6,0,0.6]: Models.soft_box(bucket,Vector3(0.2,0.2,0.6),Vector3(x,-0.3,1.6),Color("d1d7bf"))
 load_mesh=Node3D.new()
 load_mesh.set_meta("animated",true)
 bucket.add_child(load_mesh)
 for x in [-0.4,0.4]:
  var rock=Models.cylinder(load_mesh,0.4,0.6,Vector3(x,0.25,0.5),Color("aca58c"),0.2)
  rock.rotation.z=0.2
 for node in [bucket,stick,boom,turret,self]: Models.bake(node)

func _process(_delta: float) -> void:
 var f=clampf(phase_fraction,0,1)
 var turn=0.0
 if phase_value==1: turn=lerpf(0,-2.3,f)
 elif phase_value==2: turn=-2.3
 elif phase_value==3: turn=lerpf(-2.3,0,f)
 turret.rotation.y=turn
 var lift=f if phase_value==1 else 1.0 if phase_value==2 else 1-f if phase_value==3 else 0.0
 boom.rotation.x=lerpf(-1.1,-0.59,lift)+(sin(f*PI)*0.1 if phase_value==0 else 0.0)
 stick.rotation.x=lerpf(1.4,1.12,lift)
 bucket.rotation.y=PI
 bucket.rotation.x=-0.3+f*0.9 if phase_value==2 else -0.3
 load_mesh.visible=loaded
