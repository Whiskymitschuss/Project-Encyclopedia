extends Node3D
var world: Node3D
var signals={}
var clock=0.0
var repairer: Node3D

func make_signal(cell: Vector2i) -> Node3D:
 var node=Node3D.new()
 node.position=TownRules.point(cell)
 add_child(node)
 var bulbs=[]
 for axis in 2:
  var pole=Node3D.new()
  node.add_child(pole)
  pole.position=Vector3(-6,0,4.4) if axis==0 else Vector3(-4.4,0,-6)
  pole.rotation.y=PI/2 if axis==0 else 0.0
  Models.cylinder(pole,0.13,4.3,Vector3(0,2.6,0),Color("65766d"))
  Models.box(pole,Vector3(0.85,2.2,0.5),Vector3(0,4.0,0),Color("253c40"))
  for i in 3:
   var lens=Models.cylinder(pole,0.25,0.08,Vector3(0,4.7-i*0.65,0.3),Color("34494a"))
   lens.rotation.x=PI/2
   lens.material_override=Models.material(Color("34494a"),true).duplicate()
   lens.set_meta("animated",true)
   bulbs.append(lens)
  Models.bake(pole)
 node.set_meta("bulbs",bulbs)
 return node

func _process(delta: float) -> void:
 clock+=delta
 if clock<0.1: return
 clock=0
 var junctions=TrafficRules.junctions(Game.state).duplicate()
 junctions.sort_custom(func(a,b): return TownRules.point(a).distance_squared_to(world.view_focus)<TownRules.point(b).distance_squared_to(world.view_focus))
 var shown={}
 for cell in junctions.slice(0,6 if Game.state.quality==0 else 14):
  if TownRules.point(cell).distance_to(world.view_focus)>world.view_zoom*1.3+30: continue
  shown[cell]=true
  if not signals.has(cell): signals[cell]=make_signal(cell)
  var node=signals[cell]
  node.show()
  var phase=TrafficRules.signal_phase(Game.state,cell)
  var bulbs=node.get_meta("bulbs")
  for i in bulbs.size():
   var axis="x" if i<3 else "z"
   var lens=i%3
   var on=(lens==2 if phase==axis else lens==0) if phase!="fault" else lens==1 and int(float(Game.state.traffic.clock)*2)%2==0
   bulbs[i].material_override.albedo_color=([Color("ed6751"),Color("ffc961"),Color("85d9ad")][lens] if on else Color("35484a"))
 for cell in signals.keys():
  if not shown.has(cell):
   signals[cell].queue_free()
   signals.erase(cell)
 # One repair crew works only after the saved maintenance van has arrived.
 var work={}
 for mission in Game.state.city_services.missions:
  if mission.kind=="technician" and float(mission.age)>=float(mission.drive) and not mission.served: work=mission; break
 if not work.is_empty() and repairer==null:
  repairer=TimberWorker.new()
  repairer.role="operator"
  add_child(repairer)
  repairer.set_process(false)
  Models.box(repairer.limbs[3],Vector3(0.12,0.75,0.14),Vector3(0,-0.95,0.2),Color("c5d5cf"))
  Models.box(repairer.limbs[3],Vector3(0.42,0.15,0.16),Vector3(0,-1.3,0.2),Color("c5d5cf"))
 if repairer!=null:
  repairer.visible=not work.is_empty()
  if repairer.visible:
   var cell=TownRules.cell(work.target_ref.cell)
   repairer.origin_point=TownRules.point(cell)+Vector3(-6,0,4.8)
   repairer.facing=PI
   repairer.position=repairer.origin_point+Vector3(0,0.6,0)
   repairer.body.rotation.y=PI
   for i in [2,3]: repairer.limbs[i].rotation.x=-1.8+sin(float(Game.state.traffic.clock)*6+i)*0.2 if Game.state.ux.motion else -1.8
