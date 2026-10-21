extends "res://NPCs/Worker.gd"

var job_id = -1
var work_index = 0
var work_state = "idle"
var board: Node3D
var hammer: Node3D
var global_crew=false
var site_origin=Vector3.ZERO
var site_turn=Basis.IDENTITY
var transfer=[]

func _ready() -> void:
 role = "construction"
 super._ready()
 board=Node3D.new()
 body.add_child(board)
 Models.box(board,Vector3(2.6,0.2,0.45),Vector3(0,1.7,0.8),Color("edbe78"))
 Models.bake(board)
 hammer=Node3D.new()
 limbs[3].add_child(hammer)
 Models.box(hammer,Vector3(0.12,0.8,0.12),Vector3(0,-0.9,0.2),Color("9a7044"))
 Models.box(hammer,Vector3(0.55,0.22,0.28),Vector3(0,-1.28,0.2),Color("93bac2"))
 Models.bake(hammer)

func _process(delta: float) -> void:
 if global_crew: return
 animate_crew(delta)

func animate_crew(delta: float) -> void:
 if not visible: return
 if not transfer.is_empty():
  var target=LogisticsRoutes.vector(transfer[0])
  target.y=0.6
  var direction=target-position
  position=position.move_toward(target,delta*5.0)
  body.rotation.y=atan2(direction.x,direction.z)
  for i in limbs.size(): limbs[i].rotation.x=sin(Time.get_ticks_msec()*0.006+(i%2)*PI)*0.45 if Game.state.ux.motion else 0.0
  board.hide()
  hammer.hide()
  work_state="relocating"
  if position.distance_to(target)<0.05: transfer.pop_front()
  return
 var job = {}
 for value in Game.state.jobs:
  if int(value.get("id",-1))==job_id: job=value; break
 if job.is_empty(): hide(); return
 show()
 var active = ConstructionRules.phase_ready(job) and not job.paused and int(job.workers)>0
 var t = float(Game.state.elapsed)+work_index*2.0
 var cycle = fposmod(t,10.0)
 var a = Vector3(-5+work_index*2,0.6,7)
 var b = Vector3(-5+work_index*2,0.6,2)
 if global_crew:
  a=site_origin+site_turn*a
  b=site_origin+site_turn*b
 for limb in limbs: limb.rotation=Vector3.ZERO
 board.hide()
 hammer.hide()
 pack.hide()
 mug.hide()
 if not active:
  position=a
  work_state="waiting_material" if not ConstructionRules.phase_ready(job) else "paused"
  body.rotation.y=PI
  return
 if cycle<2.5:
  work_state="carrying"
  position=a.lerp(b,cycle/2.5)
  board.show()
  for i in [2,3]: limbs[i].rotation.x=-1.2
 elif cycle<7.5:
  position=b
  work_state="hammering" if int(job.phase) in [2,3,4] else "assembling"
  hammer.show()
  limbs[3].rotation.x=-1.6+sin(t*10)*0.8
  limbs[2].rotation.x=-0.9
 else:
  work_state="walking"
  position=b.lerp(a,(cycle-7.5)/2.5)
  for i in limbs.size(): limbs[i].rotation.x=sin(t*6+(i%2)*PI)*0.5
 body.rotation.y=(PI if cycle>=7.5 else 0)+(site_turn.get_euler().y if global_crew else 0.0)
