extends Node3D

var head: Node3D
var arm: Node3D
var eyes: Array=[]
var elapsed=0.0
var wave_left=0.0
var cheerful=false

func ball(parent: Node3D, at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
 var mesh=MeshInstance3D.new()
 var sphere=SphereMesh.new()
 sphere.radius=1.0
 sphere.height=2.0
 sphere.radial_segments=16
 sphere.rings=8
 mesh.mesh=sphere
 mesh.material_override=Models.material(color)
 mesh.position=at
 mesh.scale=size
 parent.add_child(mesh)
 return mesh

func _ready() -> void:
 var fur=Color("c88239")
 var muzzle=Color("ffe0a0")
 ball(self,Vector3(0,1.25,0),Vector3(1.15,1.3,0.8),Color("dd5540"))
 for side in [-1,1]:
  Models.box(self,Vector3(0.16,1.4,0.14),Vector3(side*0.38,1.3,0.7),Color("6b4631"))
  Models.box(self,Vector3(0.26,0.24,0.15),Vector3(side*0.38,1.6,0.8),Color("f0be54"))
 for y in [0.95,1.35,1.75]: Models.box(self,Vector3(1.8,0.1,0.1),Vector3(0,y,0.64),Color("af392e"))
 ball(self,Vector3(0.65,0.6,-0.7),Vector3(0.8,0.4,1.2),Color("825432"))
 head=Node3D.new()
 head.position=Vector3(0,2.65,0)
 add_child(head)
 ball(head,Vector3.ZERO,Vector3(1.25,1.1,0.95),fur)
 for side in [-1,1]:
  ball(head,Vector3(side*1.04,0.45,0),Vector3(0.42,0.5,0.32),fur)
  ball(head,Vector3(side*1.08,0.45,0.19),Vector3(0.24,0.29,0.13),Color("e8a574"))
  var eye=Node3D.new()
  head.add_child(eye)
  eye.position=Vector3(side*0.43,0.18,0.78)
  ball(eye,Vector3.ZERO,Vector3(0.38,0.47,0.18),Color("fff7e3"))
  ball(eye,Vector3(0.03,-0.02,0.15),Vector3(0.20,0.28,0.10),Color("523226"))
  ball(eye,Vector3(0.08,0.07,0.22),Vector3(0.075,0.09,0.05),Color.WHITE)
  eyes.append(eye)
  var brow=ball(head,Vector3(side*0.44,0.64,0.76),Vector3(0.37,0.12,0.13),Color("73432c"))
  brow.rotation.z=side*-0.15
 ball(head,Vector3(0,-0.47,0.81),Vector3(0.62,0.46,0.25),Color("643728"))
 for side in [-1,1]:
  ball(head,Vector3(side*0.35,-0.23,0.94),Vector3(0.57,0.36,0.28),muzzle)
  Models.box(head,Vector3(0.27,0.44,0.14),Vector3(side*0.16,-0.54,1.05),Color("fff4d3"))
 ball(head,Vector3(0,-0.04,1.19),Vector3(0.35,0.23,0.20),Color("56372b"))
 Models.cylinder(head,1.3,0.18,Vector3(0,0.95,0),Color("ffcb34"))
 ball(head,Vector3(0,1.1,0),Vector3(1.12,0.67,0.95),Color("ffc434"))
 Models.box(head,Vector3(0.2,0.62,1.7),Vector3(0,1.3,0),Color("ffe58c"))
 Models.box(head,Vector3(0.36,0.38,0.1),Vector3(0,1.22,0.91),Color("78502a"))
 ball(self,Vector3(-1.0,1.4,0.22),Vector3(0.44,0.72,0.48),fur)
 arm=Node3D.new()
 arm.position=Vector3(0.95,1.65,0.15)
 add_child(arm)
 ball(arm,Vector3(0,0.35,0),Vector3(0.38,0.67,0.40),fur)
 ball(arm,Vector3(0,0.95,0),Vector3(0.45,0.47,0.35),fur)
 for x in [-0.23,0,0.23]: ball(arm,Vector3(x,1.2,0.05),Vector3(0.14,0.27,0.16),Color("df9d53"))
 Models.bake(self)
 Models.bake(head)

func animate(delta: float) -> void:
 elapsed+=delta
 wave_left=maxf(0,wave_left-delta)
 head.rotation.z=sin(elapsed*1.4)*0.035
 head.position.y=2.65+sin(elapsed*1.8)*0.035
 arm.rotation.z=-0.45+sin(elapsed*8)*0.45 if wave_left>0 else -0.8
 var blink=fmod(elapsed,5.2)>5.03
 for eye in eyes: eye.scale.y=0.12 if blink else 1.0
 if cheerful: rotation.z=sin(elapsed*5)*0.035
 else: rotation.z=0
