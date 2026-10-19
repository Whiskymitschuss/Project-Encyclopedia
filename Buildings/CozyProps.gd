extends RefCounted

static func bench(root: Node3D, at: Vector3, rotation: float=0) -> void:
 var seat=Node3D.new()
 seat.position=at
 seat.rotation.y=rotation
 root.add_child(seat)
 for x in [-1.1,1.1]: Models.box(seat,Vector3(0.2,0.9,0.9),Vector3(x,0.8,0),Color("476274"))
 for z in [-0.3,0,0.3]: Models.box(seat,Vector3(2.8,0.15,0.24),Vector3(0,1.25,z),Color("d69c58"))
 for y in [1.7,2.1]: Models.box(seat,Vector3(2.8,0.26,0.16),Vector3(0,y,0.48),Color("e3af6a"))
 Models.bake(seat)

static func planter(root: Node3D, at: Vector3) -> void:
 Models.box(root,Vector3(1.4,0.9,1.4),at+Vector3(0,0.7,0),Color("d88c58"))
 Models.box(root,Vector3(1.5,0.18,1.5),at+Vector3(0,1.2,0),Color("f0b16e"))
 for i in 5:
  var point=at+Vector3(sin(i*2.4)*0.45,1.5,cos(i*2.4)*0.45)
  Models.cylinder(root,0.05,0.7,point,Color("3e9f63"))
  Models.cylinder(root,0.25,0.16,point+Vector3(0,0.4,0),Color("ffd263") if i%2==0 else Color("f08b9b"),0.12)

static func rest_area(root: Node3D) -> void:
 bench(root,Vector3(4.2,0,9.7))
 var table=Vector3(4.2,0,8.2)
 Models.cylinder(root,0.14,1.6,table+Vector3(0,1.3,0),Color("536975"))
 Models.cylinder(root,1.25,0.22,table+Vector3(0,2.1,0),Color("e3ae6b"))
 Models.cylinder(root,0.18,0.35,table+Vector3(-0.5,2.4,0),Color("fff2d2"))
 Models.box(root,Vector3(0.7,0.18,0.55),table+Vector3(0.4,2.35,0),Color("dc7154"))
 Models.cylinder(root,0.1,4.7,Vector3(6.8,2.8,8.0),Color("78634a"))
 var canopy=Models.cylinder(root,2.1,0.6,Vector3(6.8,5.15,8),Color("f4c75f"),0.1)
 canopy.mesh.radial_segments=8
 Models.cylinder(root,0.22,0.15,Vector3(6.8,5.5,8),Color("ed8c63"))
 planter(root,Vector3(-7.3,0,8.5))
 Models.box(root,Vector3(0.18,2.7,0.18),Vector3(-7.4,1.8,6.2),Color("536975"))
 var lamp=Models.box(root,Vector3(0.65,0.75,0.65),Vector3(-7.4,3.3,6.2),Color("ffda8a"))
 lamp.material_override=Models.material(Color("ffcf78"),true)
