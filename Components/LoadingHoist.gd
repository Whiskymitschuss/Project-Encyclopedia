extends Node3D
var trolley: Node3D
var active=false
var progress=0.0
func _ready() -> void:
 trolley=Node3D.new()
 add_child(trolley)
 Models.box(trolley,Vector3(3,0.7,2),Vector3(0,5.2,0),Color("3e5868"))
 Models.box(trolley,Vector3(0.1,2.6,0.1),Vector3(0,3.6,0),Color("3e5868"))
 Models.box(trolley,Vector3(0.6,0.25,0.25),Vector3(0,2.2,0),Color("edb44a"))
 Models.bake(trolley)
func _process(_delta: float) -> void:
 active=false
 if not Game.state.ux.motion or not Game.state.ambient_enabled: return
 var camera=get_viewport().get_camera_3d()
 if camera==null or camera.global_position.distance_to(global_position)>260: return
 for trip in FreightFlow.all_trips(Game.state):
  if float(trip.get("depart_in",0))>0: continue
  var stage=CargoTransfer.phase(trip,float(trip.age)+minf(Game.tick_clock,0.99))
  if stage.kind not in ["load","unload"]: continue
  var dock=CargoTransfer.dock(Game,trip,stage.kind=="load")
  if dock.distance_to(get_parent().global_position)>1: continue
  active=true
  progress=float(stage.progress)
  trolley.position=Vector3(lerpf(-4,4,progress),sin(progress*PI)*0.45,0)
  return
