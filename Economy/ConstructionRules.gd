class_name ConstructionRules
extends RefCounted

const HARDWARE = {"nuts":8.0,"screws":6.0}

static func materials(kind: String, level: int = 1) -> Dictionary:
 var size = 1+floori((level-1)/5.0)
 var result = {"wood":float(8+level*2),"boards":float(3+level)}
 if kind in ["furniture","garage","research","prefab","joinery","paper","design"] or level>1:
  result.nuts = float(size)
  result.screws = float(size+1)
 return result

static func remaining(job: Dictionary, key: String) -> float:
 return maxf(0,float(job.get("materials",{}).get(key,0))-float(job.get("delivered",{}).get(key,0)))

static func ready(job: Dictionary) -> bool:
 for key in job.get("materials",{}):
  if remaining(job,key)>0.00001: return false
 return true

static func deliver(state: Dictionary, job: Dictionary, limit: float) -> float:
 var total = 0.0
 if not job.has("delivered"): job.delivered = {}
 for key in job.get("materials",{}):
  var amount = minf(remaining(job,key),minf(maxf(0,float(state.resources.get(key,0))),maxf(0,limit-total)))
  state.resources[key] = maxf(0,float(state.resources.get(key,0))-amount)
  job.delivered[key] = float(job.delivered.get(key,0))+amount
  total += amount
 return total

static func status(job: Dictionary) -> String:
 if job.has("phases"):
  var phase_title = PHASES[mini(6,int(job.phase))]
  if job.get("paused",false): return "%s · Baustelle pausiert" % phase_title
  if int(job.workers)<=0: return "%s · wartet auf Bauarbeiter" % phase_title
  return "%s · %s %% · %s" % [phase_title,int((1-float(job.left)/float(job.total))*100),"Bau läuft" if phase_ready(job) else "wartet auf Materiallieferung"]
 if ready(job): return "Bau läuft · %s s" % ceili(job.left)
 var parts: Array[String] = []
 for key in job.materials:
  parts.append("%s %s/%s" % [Catalog.RESOURCES[key],Catalog.number(float(job.get("delivered",{}).get(key,0))),Catalog.number(float(job.materials[key]))])
 return "Material anliefern · "+" · ".join(parts)

const PHASES = ["Vorbereitung","Fundament","Tragwerk","Wände","Dach","Einrichtung","Abnahme"]

static func attach(job: Dictionary, workers: int = 1) -> void:
 job.phase = 0
 job.phase_left = float(job.total)/7.0
 job.workers = workers
 job.paused = false
 job.priority = false
 job.requested = false
 job.phases = []
 for title in PHASES: job.phases.append({"name":title,"materials":{}})
 for key in job.materials:
  var weights = {"wood":[0.2,0,0.4,0,0.4,0,0],"boards":[0,0.25,0.25,0.25,0.25,0,0],"nuts":[0,0,0.5,0,0,0.5,0],"screws":[0,0,0,0.5,0,0.5,0],"walls":[0,0.25,0.25,0.5,0,0,0],"roofs":[0,0,0,0,1.0,0,0],"parts":[0,0,1.0,0,0,0,0]}.get(key,[0,0,0,0,0,1.0,0])
  var left = int(job.materials[key])
  for i in 7:
   if float(weights[i])<=0: continue
   var last = true
   for j in range(i+1,7):
    if float(weights[j])>0: last=false
   var amount = left if last else mini(left,roundi(float(job.materials[key])*float(weights[i])))
   if amount>0: job.phases[i].materials[key]=amount
   left -= amount

static func phase_need(job: Dictionary, key: String) -> float:
 if not job.has("phases"): return remaining(job,key)
 var total = 0.0
 for i in range(0,mini(6,int(job.phase))+1): total += float(job.phases[i].materials.get(key,0))
 return maxf(0,total-float(job.delivered.get(key,0)))

static func phase_ready(job: Dictionary) -> bool:
 for key in job.get("materials",{}):
  if phase_need(job,key)>0.00001: return false
 return true

static func job_position(state: Dictionary, job: Dictionary) -> Vector3:
 if job.type=="upgrade": return LogisticsRoutes.building_position(state,int(job.index))
 if job.type=="home_upgrade": return LogisticsRoutes.home_position(state,int(job.index))
 if job.type=="project": return Catalog.PROJECTS[int(job.index)].position
 var fallback = Catalog.home_position(int(job.plot)) if job.type=="home" else Catalog.industry_position(int(job.get("slot",0)))
 return Placement.position_of(job,fallback)

static func incoming(state: Dictionary, id: int, key: String) -> float:
 var result = 0.0
 for s in state.construction_shipments:
  if int(s.job)==id and s.key==key and not s.arrived: result += float(s.amount)
 return result

static func transport_tick(state: Dictionary, delta: float) -> void:
 var done = []
 for s in state.construction_shipments:
  s.age = float(s.age)+delta
  if not s.arrived and float(s.age)>=float(s.travel):
   var found = false
   for job in state.jobs:
    if int(job.get("id",-1))==int(s.job):
     job.delivered[s.key] = float(job.delivered.get(s.key,0))+float(s.amount)
     found=true
     break
   if not found:
    var cap = 500.0
    for b in state.buildings:
     if b.kind=="warehouse": cap+=int(b.level)*500
    if float(state.resources.get(s.key,0))+float(s.amount)>cap:
     s.age=float(s.travel)
     continue
    state.resources[s.key] = float(state.resources.get(s.key,0))+float(s.amount)
   s.arrived = true
  if s.arrived and float(s.age)>=float(s.total): done.append(s)
 for s in done: state.construction_shipments.erase(s)

static func dispatch(state: Dictionary, only_job: int = -1) -> float:
 var busy = state.construction_shipments.size()
 for s in state.delivery.shipments:
  if s.mode=="truck": busy+=1
 var free = maxi(0,int(state.trucks)-busy)
 if free<=0: return 0
 var jobs = state.jobs.duplicate()
 jobs.sort_custom(func(a,b): return int(a.get("priority",false))>int(b.get("priority",false)))
 var result = 0.0
 for job in jobs:
  var id = int(job.get("id",-1))
  if not job.has("phases") or job.get("paused",false) or (only_job>=0 and id!=only_job): continue
  if not state.construction_auto and not job.get("requested",false): continue
  var source = -1
  for i in state.buildings.size():
   if state.buildings[i].kind=="warehouse" and not (job.type=="upgrade" and int(job.index)==i): source=i; break
  if source<0: source=0
  var route = LogisticsRoutes.road_to_point(state,source,job_position(state,job))
  if route.size()<2: continue
  var material_keys = job.materials.keys()
  material_keys.sort()
  for key in material_keys:
   var missing = maxf(0,phase_need(job,key)-incoming(state,id,key))
   var amount = minf(missing,minf(float(state.resources[key]),float(4+int(state.vehicle)*2)))
   if amount<=0 or free<=0: continue
   state.resources[key] -= amount
   var drive = maxf(2,LogisticsRoutes.length(route)/(9+int(state.vehicle)))
   var travel = drive+4.0
   state.construction_shipments.append({"id":state.next_shipment,"job":id,"source":"warehouse","target":"construction","mode":"truck","key":key,"amount":amount,"path":route,"age":0.0,"load":2.0,"drive":drive,"unload":2.0,"travel":travel,"total":travel+drive+2,"arrived":false})
   state.next_shipment += 1
   free-=1
   result+=amount
 return result

static func advance(job: Dictionary, work: float) -> bool:
 if job.get("paused",false) or int(job.get("workers",0))<=0 or not phase_ready(job): return false
 var amount = minf(work,float(job.phase_left))
 job.phase_left = maxf(0,float(job.phase_left)-amount)
 job.left = maxf(0,float(job.left)-amount)
 if float(job.phase_left)<=0.00001:
  job.phase += 1
  job.phase_left = minf(float(job.total)/7.0,float(job.left))
 return int(job.phase)>=7 or float(job.left)<=0.00001
