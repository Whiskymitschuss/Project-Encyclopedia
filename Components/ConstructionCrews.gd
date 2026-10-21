extends Node3D
# Builder models keep their identity when a site is completed or reassigned.
var workers=[]
var world: Node3D

func _process(delta: float) -> void:
 var wanted=[]
 for job in Game.state.jobs:
  if not job.has("phases"): continue
  for i in mini(int(job.workers),2 if Game.state.quality==0 else 5): wanted.append([int(job.id),i,ConstructionRules.job_position(Game.state,job)])
 var limit=mini(int(Game.state.builders),4 if Game.state.quality==0 else 8)
 while workers.size()<limit:
  var worker=load("res://NPCs/ConstructionWorker.gd").new()
  worker.global_crew=true
  add_child(worker)
  workers.append(worker)
 for i in workers.size():
  var worker=workers[i]
  worker.visible=i<wanted.size() and i<limit
  if not worker.visible: continue
  var slot=wanted[i]
  if worker.job_id!=slot[0] or worker.work_index!=slot[1] or worker.site_origin!=slot[2]:
   var job={}
   for value in Game.state.jobs:
    if int(value.get("id",-1))==slot[0]: job=value; break
   var point=ConstructionRules.job_position(Game.state,job)
   var turn=Basis.from_euler(Vector3(0,deg_to_rad(float(job.get("rotation",0))),0))
   var target=point+turn*Vector3(-5+slot[1]*2,0.6,7)
   worker.transfer=[]
   if worker.job_id>=0:
    # Leave the old lot, use public roads, enter the new delivery bay.
    worker.transfer=LogisticsRoutes.between(Game.state,worker.site_origin,point)
   worker.transfer.append([target.x,target.y,target.z])
   if worker.job_id<0: worker.position=target
   worker.site_origin=point
   worker.site_turn=turn
   worker.job_id=slot[0]
   worker.work_index=slot[1]
  worker.animate_crew(delta)
