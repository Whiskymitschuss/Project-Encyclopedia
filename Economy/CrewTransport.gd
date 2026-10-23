class_name CrewTransport
extends RefCounted

const SEATS=4

static func initial() -> Dictionary:
 return {"assignments":{},"missions":[],"next_id":2000000,"cursor":0}

static func enabled(state: Dictionary) -> bool:
 return LogisticsDispatch.enabled(state)

static func fleet_size(state: Dictionary) -> int:
 return mini(2,maxi(0,int(state.builders))) if enabled(state) else 0

static func find_job(state: Dictionary,id: int) -> Dictionary:
 for job in state.jobs:
  if int(job.get("id",-1))==id: return job
 return {}

static func assignment(state: Dictionary,id: int,at: Vector3=Vector3.ZERO) -> Dictionary:
 var key=str(id)
 if not state.crew.assignments.has(key): state.crew.assignments[key]={"job":id,"onsite":0,"point":[at.x,at.y,at.z]}
 return state.crew.assignments[key]

static func onsite(state: Dictionary,job: Dictionary) -> int:
 if not enabled(state): return int(job.get("workers",0))
 return int(state.crew.assignments.get(str(int(job.id)),{}).get("onsite",0))

static func working(state: Dictionary,job: Dictionary) -> int:
 return mini(int(job.get("workers",0)),onsite(state,job))

static func booked(state: Dictionary,id: int,kind: String) -> int:
 var count=0
 for mission in state.crew.missions:
  if int(mission.job)==id and mission.kind==kind and not mission.arrived: count+=int(mission.workers)
 return count

static func people(state: Dictionary) -> Dictionary:
 var result={}
 for id in state.crew.assignments: result[id]=int(state.crew.assignments[id].onsite)
 for mission in state.crew.missions:
  if (mission.kind=="dropoff" and not mission.arrived) or (mission.kind=="pickup" and mission.arrived):
   var id=str(int(mission.job))
   result[id]=int(result.get(id,0))+int(mission.workers)
 return result

static func reserved(state: Dictionary) -> int:
 var counts=people(state)
 for job in state.jobs:
  if job.has("phases"): counts[str(int(job.id))]=maxi(int(counts.get(str(int(job.id)),0)),int(job.get("workers",0)))
 var total=0
 for value in counts.values(): total+=int(value)
 return total

static func base(state: Dictionary,at: Vector3) -> Dictionary:
 var best={}
 var distance=INF
 for i in state.buildings.size():
  if state.buildings[i].kind!="cabin" or state.buildings[i].get("paused",false): continue
  var route=LogisticsRoutes.road_to_point(state,i,at)
  if route.size()<2: continue
  var length=LogisticsRoutes.length(route)
  if length<distance:
   distance=length
   best={"index":i,"path":route}
 return best

static func tick(state: Dictionary,delta: float) -> void:
 if not enabled(state): return
 if state.jobs.is_empty() and state.crew.missions.is_empty() and state.crew.assignments.is_empty(): return
 var completed=[]
 for mission in state.crew.missions:
  FreightFlow.advance(mission,delta)
  if not mission.arrived and float(mission.age)>=float(mission.travel):
   var team=assignment(state,int(mission.job),LogisticsRoutes.vector(mission.point))
   if mission.kind=="dropoff": team.onsite=int(team.onsite)+int(mission.workers)
   else:
    mission.workers=mini(int(mission.workers),int(team.onsite))
    team.onsite=int(team.onsite)-int(mission.workers)
   mission.arrived=true
  if mission.arrived and float(mission.age)>=float(mission.total): completed.append(mission)
 for mission in completed: state.crew.missions.erase(mission)
 for job in state.jobs:
  if job.has("phases"): job.crew_present=working(state,job)
 for id in state.crew.assignments.keys():
  if not find_job(state,int(id)).is_empty() or int(state.crew.assignments[id].onsite)>0: continue
  if state.crew.missions.any(func(mission): return int(mission.job)==int(id)): continue
  state.crew.assignments.erase(id)

static func launch(state: Dictionary,id: int,at: Vector3,workers: int,kind: String) -> bool:
 var origin=base(state,at)
 if origin.is_empty() or workers<=0: return false
 assignment(state,id,at)
 var drive=maxf(2,LogisticsRoutes.length(origin.path)/(11+int(state.vehicle)))
 var mission={"id":state.crew.next_id,"job":id,"kind":kind,"workers":workers,"origin":int(origin.index),"point":[at.x,at.y,at.z],"path":origin.path,"age":0.0,"load":2.0,"drive":drive,"unload":3.0,"travel":drive+5,"total":drive*2+7,"arrived":false,"target":"crew","fleet":"crew"}
 FreightFlow.enqueue(state,state.crew.missions,mission)
 state.crew.next_id+=1
 return true

static func dispatch(state: Dictionary) -> void:
 if not enabled(state): return
 if state.jobs.is_empty() and state.crew.assignments.is_empty(): return
 var free=maxi(0,fleet_size(state)-state.crew.missions.size())
 if free<=0: return
 # Real people at completed/paused/reassigned sites must be driven home before
 # they can appear on a different site. The empty van returns after drop-off.
 var ids=state.crew.assignments.keys()
 ids.sort_custom(func(a,b): return int(a)<int(b))
 for id in ids:
  var team=state.crew.assignments[id]
  var job=find_job(state,int(id))
  var wanted=0 if job.is_empty() or job.get("paused",false) else int(job.get("workers",0))
  var excess=int(team.onsite)-wanted-booked(state,int(id),"pickup")
  if excess<=0 or free<=0: continue
  if launch(state,int(id),LogisticsRoutes.vector(team.point),mini(SEATS,excess),"pickup"): free-=1
 var jobs=state.jobs.filter(func(job): return job.has("phases") and not job.get("paused",false) and int(job.get("workers",0))>0)
 jobs.sort_custom(func(a,b): return int(a.id)<int(b.id))
 if jobs.is_empty(): return
 var cursor=int(state.crew.cursor)%jobs.size()
 var committed=0
 for count in people(state).values(): committed+=int(count)
 for offset in jobs.size():
  if free<=0: break
  var slot=(cursor+offset)%jobs.size()
  var job=jobs[slot]
  var needed=int(job.workers)-onsite(state,job)-booked(state,int(job.id),"dropoff")
  var count=mini(SEATS,mini(needed,maxi(0,int(state.builders)-committed)))
  if count<=0: continue
  if launch(state,int(job.id),ConstructionRules.job_position(state,job),count,"dropoff"):
   free-=1
   committed+=count
   state.crew.cursor=(slot+1)%jobs.size()

static func status(state: Dictionary,job: Dictionary) -> String:
 if not enabled(state): return "%s Bauarbeiter zugewiesen" % int(job.get("workers",0))
 var present=working(state,job)
 var text="Bauteam: %s/%s vor Ort" % [present,int(job.get("workers",0))]
 for mission in state.crew.missions:
  if int(mission.job)!=int(job.id): continue
  var stage="Rückfahrt zur Arbeiterhütte" if mission.arrived else "Holt das Bauteam ab" if mission.kind=="pickup" else "Bauteam reist im Sprinter an"
  return text+" · "+stage+(" · Abfahrt in %s s" % ceili(mission.depart_in) if float(mission.get("depart_in",0))>0 else "")
 if present<int(job.get("workers",0)):
  if base(state,ConstructionRules.job_position(state,job)).is_empty(): return text+" · Arbeiterhütte oder Straßenanschluss fehlt"
  return text+" · wartet auf freien Sprinter"
 return text+" · "+("wartet auf Material" if not ConstructionRules.phase_ready(job) else "arbeitet" if not job.get("paused",false) else "pausiert")
