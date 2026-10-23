extends Node3D
var job_id = -1
var pieces: Array = []
var stock: Node3D
var sign_label: Label3D
var clock = 0.0
var visual_phase = -1
var dust: CPUParticles3D

func _ready() -> void:
 var job = current_job()
 dust=FeedbackFX.emitter("dust",10)
 dust.position=Vector3(0,1.5,1)
 dust.emission_shape=CPUParticles3D.EMISSION_SHAPE_BOX
 dust.emission_box_extents=Vector3(4,0.3,4)
 add_child(dust)
 # Permanent delivery bay and perimeter remain inside the reserved footprint.
 Models.box(self,Vector3(18,0.1,4),Vector3(0,0.75,8.5),Color("d4bf83"))
 for x in [-8.5,8.5]:
  for z in [-10,-5,0,5,10]:
   Models.cylinder(self,0.1,1.6,Vector3(x,1.4,z),Color("f1c54f"))
  Models.box(self,Vector3(0.12,0.35,21),Vector3(x,1.8,0),Color("ec9857"))
 Models.box(self,Vector3(6,2.2,0.3),Vector3(-4,3,10.5),Color("287b8a"))
 sign_label=Models.label(self,"BAUSTELLE",Vector3(-4,4.7,10.5),23)
 stock=Node3D.new()
 stock.name="MaterialStock"
 add_child(stock)
 Models.log_pile(stock,Vector3(3,0.8,7.5),4)
 for i in 7:
  var group=Node3D.new()
  group.name="Phase%s" % i
  add_child(group)
  pieces.append(group)
  match i:
   0: Models.box(group,Vector3(15,0.14,15),Vector3(0,0.55,-1),Color("b69262"))
   1: Models.box(group,Vector3(14,0.6,13),Vector3(0,0.9,-1),Color("b3c1b8"))
   2:
    for x in [-6,6]:
     for z in [-6,4]: Models.box(group,Vector3(0.55,6,0.55),Vector3(x,4,z),Color("d5ad73"))
    for z in [-6,4]: Models.box(group,Vector3(13,0.4,0.45),Vector3(0,7,z),Color("d5ad73"))
   3:
    for x in [-6,6]: Models.box(group,Vector3(0.3,4.6,10),Vector3(x,3.5,-1),Color("83b6aa"))
    Models.box(group,Vector3(12,4.6,0.3),Vector3(0,3.5,-6),Color("73a49d"))
   4:
    for x in [-1,1]:
     var roof=Models.box(group,Vector3(7.3,0.45,12),Vector3(x*3.3,7.4,-1),Color("efae62"))
     roof.rotation.z=x*-0.2
   5:
    Models.box(group,Vector3(4,2,3),Vector3(0,2.1,1),Color("439bae"))
    Models.box(group,Vector3(4,0.4,3),Vector3(0,3.3,1),Color("f8ce7c"))
   6: pass
  Models.bake(group)
 Models.box(self,Vector3(0.5,12,0.5),Vector3(8,6,-7),Color("e5bb4e"))
 var crane=Node3D.new()
 crane.name="Crane"
 crane.position=Vector3(8,12,-7)
 add_child(crane)
 Models.box(crane,Vector3(12,0.45,0.6),Vector3(-4,0,0),Color("f3c55d"))
 Models.box(crane,Vector3(0.1,5,0.1),Vector3(-8,-2.5,0),Color("47636d"))
 BeaverModels.cockpit(crane,Vector3(-0.8,-1.8,0.7),Vector3(1.7,1.6,1.8),Color("f3c55d"),job_id,"industry")
 Models.bake(crane)
 for i in mini(maxi(int(job.get("workers",0)),CrewTransport.onsite(Game.state,job)),2 if Game.state.quality==0 else 5):
  var worker=load("res://NPCs/ConstructionWorker.gd").new()
  worker.job_id=job_id
  worker.work_index=i
  add_child(worker)
 refresh()

func current_job() -> Dictionary:
 for job in Game.state.jobs:
  if int(job.get("id",-1))==job_id: return job
 return {}

func refresh() -> void:
 var job=current_job()
 if job.is_empty(): return
 visual_phase=int(job.phase)
 for i in pieces.size():
  pieces[i].visible=i<visual_phase or i==0 or (i==visual_phase and ConstructionRules.phase_ready(job) and float(job.phase_left)<float(job.total)/7.0)
  pieces[i].scale.y=1.0
  if i==visual_phase and i in [1,2,3]: pieces[i].scale.y=clampf(1-float(job.phase_left)/(float(job.total)/7.0),0.1,1.0)
 var delivered = 0.0
 for key in job.delivered:
  var used=0.0
  for i in mini(7,int(job.phase)): used+=float(job.phases[i].materials.get(key,0))
  delivered+=maxf(0,float(job.delivered[key])-used)
 stock.visible=delivered>0
 stock.scale.y=0.5+minf(1,delivered/10)*0.5
 sign_label.text="%s · %s %%" % [ConstructionRules.PHASES[mini(6,visual_phase)],int((1-float(job.left)/float(job.total))*100)]

func _process(delta: float) -> void:
 var job=current_job()
 var working=not job.is_empty() and not job.get("paused",false) and CrewTransport.working(Game.state,job)>0 and ConstructionRules.phase_ready(job)
 dust.emitting=working and FeedbackFX.allowed(self)
 dust.visible=dust.emitting
 var count=4 if Game.state.quality==0 else 10
 if dust.amount!=count: dust.amount=count
 clock+=delta
 if clock>=0.25: clock=0; refresh()
