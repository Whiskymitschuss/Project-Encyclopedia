extends "res://Vehicles/Truck.gd"
var bed: Node3D
var tipping=0.0
func _ready() -> void:
 set_meta("transport_tier",tier)
 if road_freight: scale=Vector3.ONE*0.62
 Models.soft_box(self,Vector3(3.2,0.7,7.2),Vector3(0,1.1,0),Color("496477"))
 hollow_cab(Vector3(0,1.6,2.3),Vector3(3,2.6,2.2),Color("ffffff") if fleet in ["central","construction"] else Color("f6be4a"),tier)
 for side in [-1,1]: Models.soft_box(self,Vector3(0.04,0.55,1.8),Vector3(side*1.52,2,2.3),Color("338fd6") if fleet=="central" else Color("303941"))

 for x in [-1.7,1.7]:
  for z in [-2.4,-0.7,2.4]: wheel(Vector3(x,0.85,z),0.82)
 bed=Node3D.new()
 bed.set_meta("animated",true)
 add_child(bed)
 bed.position=Vector3(0,1.35,-3)
 Models.soft_box(bed,Vector3(3.4,0.3,4.5),Vector3(0,0.2,2),Color("d99f3e"))
 for x in [-1.7,1.7]: Models.soft_box(bed,Vector3(0.2,1.6,4.5),Vector3(x,1,2),Color("f0b34d"))
 for z in [-0.2,4.2]: Models.soft_box(bed,Vector3(3.4,1.6,0.2),Vector3(0,1,z),Color("e9a348"))
 cargo=Node3D.new()
 cargo.set_meta("animated",true)
 bed.add_child(cargo)
 for i in 7: Models.cylinder(cargo,0.7,0.7,Vector3((i%2-0.5)*1.25,1+(i%3)*0.1,0.3+(i/2)*0.9),Color("beb090"),0.35)
 for node in [cargo,bed,self]: Models.bake(node)
func _process(delta: float) -> void:
 bed.rotation.x=lerpf(bed.rotation.x,tipping,minf(1,delta*4))
