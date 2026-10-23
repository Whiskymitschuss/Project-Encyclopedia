extends "res://NPCs/Worker.gd"

var job_id = -1
var work_index = 0
var work_state = "idle"
var board: Node3D
var hammer: Node3D
var tools: Node3D
var carried_ladder: Node3D
var placed_ladder: Node3D

func _ready() -> void:
 role = "construction"
 variant_id=posmod(job_id+work_index,10)
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
 tools=WorkTools.toolbox(limbs[2])
 tools.position=Vector3(0,-0.8,0.2)
 carried_ladder=WorkTools.ladder(body,2.8)
 carried_ladder.position=Vector3(1.1,0.5,0.6)
 carried_ladder.rotation.z=-0.25
 placed_ladder=WorkTools.ladder(self,5.4)
 placed_ladder.rotation.x=-0.15

func _process(_delta: float) -> void:
 var job = {}
 for value in Game.state.jobs:
  if int(value.get("id",-1))==job_id: job=value; break
 if job.is_empty(): hide(); return
 if work_index>=CrewTransport.onsite(Game.state,job): work_state="commuting"; hide(); return
 show()
 var active = ConstructionRules.phase_ready(job) and not job.paused and work_index<CrewTransport.working(Game.state,job)
 var t = float(Game.state.elapsed)+work_index*2.0
 var cycle = fposmod(t,10.0)
 var a = Vector3(-5+work_index*2,0.6,7)
 var b = Vector3(-5+work_index*2,0.6,2)
 for limb in limbs: limb.rotation=Vector3.ZERO
 board.hide()
 hammer.hide()
 pack.hide()
 mug.hide()
 tools.hide()
 carried_ladder.hide()
 placed_ladder.hide()
 if not active:
  position=a
  work_state="waiting_material" if not ConstructionRules.phase_ready(job) else "paused"
  body.rotation.y=PI
  return
 var elevated=int(job.phase) in [3,4]
 var boards=float(job.delivered.get("boards",0))>0
 if not Game.state.ux.motion:
  position=b
  work_state="assembling"
  hammer.show()
  limbs[3].rotation.x=-1.6
  return
 if cycle<2.5:
  work_state="carrying" if boards else "carrying_tools"
  position=a.lerp(b,cycle/2.5)
  board.visible=boards and not elevated
  tools.show()
  carried_ladder.visible=elevated
  for i in [2,3]: limbs[i].rotation.x=-1.2
 elif cycle<7.5:
  position=b
  if elevated:
   placed_ladder.show()
   # Keep the reusable ladder on the ground while the beaver climbs it.
   position.y+=sin((cycle-2.5)/5.0*PI)*3.6
   placed_ladder.position=Vector3(0,-position.y+0.6,0.5)
   work_state="climbing"
   limbs[2].rotation.x=-2.1+sin(t*6)*0.35
   limbs[3].rotation.x=-2.1-sin(t*6)*0.35
   for i in [0,1]: limbs[i].rotation.x=sin(t*6+i*PI)*0.55
   if cycle>4 and cycle<6:
    work_state="hammering"
    hammer.show()
    limbs[3].rotation.x=-1.6+sin(t*10)*0.8
  else:
   work_state="hammering" if int(job.phase)==2 else "assembling"
   hammer.show()
   limbs[3].rotation.x=-1.6+sin(t*10)*0.8
   limbs[2].rotation.x=-0.9
 else:
  work_state="walking"
  position=b.lerp(a,(cycle-7.5)/2.5)
  for i in limbs.size(): limbs[i].rotation.x=sin(t*6+(i%2)*PI)*0.5
 body.rotation.y=PI if cycle>=7.5 else 0
