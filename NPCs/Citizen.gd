extends "res://NPCs/Worker.gd"
var route: Array=[]
var travel_phase=0.0
var walking=true
func _ready() -> void:
 role="resident"
 super._ready()
func _process(delta: float) -> void:
 if route.size()<2: return
 var sample=LogisticsRoutes.sample(route,travel_phase)
 var direction=sample.direction
 position=sample.position+Vector3(direction.z,0,-direction.x)*3.6
 position.y=0.65
 body.rotation.y=atan2(direction.x,direction.z)
 phase+=delta if walking else 0
 for i in limbs.size(): limbs[i].rotation.x=sin(phase*6+(i%2)*PI)*0.45 if walking else 0.0
 mug.hide()
 pack.hide()
