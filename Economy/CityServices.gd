class_name CityServices
extends RefCounted

const TYPES = ["taxi","police","fire","ambulance"]
const BUILDINGS = {"taxi":"taxi","police":"police","fire":"fire","ambulance":"clinic"}
const NAMES = {"taxi":"Taxifahrt","police":"Nachbarschaftshilfe","fire":"Rauchmelder prüfen","ambulance":"Erste-Hilfe-Einsatz"}

static func initial() -> Dictionary:
 return {"enabled":true,"missions":[],"walkers":[],"next_id":1,"clock":12.0,"walk_clock":4.0,"completed":{},"treasury":0.0,"collected":0.0,"walks":0,"auto_kind":0,"fires":[],"fire_clock":0.0,"next_fire":1,"fires_extinguished":0}

static func location(state: Dictionary, ref: Dictionary) -> Vector3:
 return LogisticsRoutes.home_position(state,int(ref.index)) if ref.type=="home" else LogisticsRoutes.building_position(state,int(ref.index)) if ref.type=="building" else Vector3(-80,0,-164)

static func destinations(state: Dictionary) -> Array:
 var result=[]
 for i in state.homes.size():
  if int(Catalog.HOMES[state.homes[i].kind].people)>0: result.append({"type":"home","index":i})
 if result.is_empty():
  for i in state.buildings.size():
   if state.buildings[i].kind in ["cabin","sawmill","market"]: result.append({"type":"building","index":i})
 return result

static func route(state: Dictionary, a: Vector3, b: Vector3, cache: Dictionary) -> Array:
 var key=hash([a,b,state.town.roads,int(state.town.districts)])
 if not cache.has(key):
  if cache.size()>128: cache.clear()
  cache[key]=LogisticsRoutes.between(state,a,b)
 return cache[key]

static func dispatch(state: Dictionary, kind: String, cache: Dictionary, incident: Dictionary = {}) -> bool:
 if not kind in TYPES: return false
 if state.city_services.missions.size()>=8:
  if not incident.is_empty(): incident.wait_reason="fleet"
  return false
 var data=state.city_services
 var station_ref={"type":"entry","index":-1}
 var capacity=1
 for i in state.homes.size():
  if state.homes[i].kind==BUILDINGS[kind] and int(state.homes[i].level)>0:
   station_ref={"type":"home","index":i}
   capacity=mini(3,1+int(state.homes[i].level)/3)
   break
 var busy=0
 for mission in data.missions:
  if mission.kind==kind: busy+=1
 if busy>=capacity:
  if not incident.is_empty(): incident.wait_reason="fleet"
  return false
 var targets=destinations(state)
 if targets.is_empty(): return false
 var target_ref=incident.target_ref if not incident.is_empty() else targets[posmod(int(data.next_id)-1,targets.size())]
 var a=location(state,station_ref)
 var b=location(state,target_ref)
 var outward=route(state,a,b,cache)
 if outward.size()<2:
  if not incident.is_empty(): incident.wait_reason="route"
  return false
 var back: Array = outward.duplicate(true)
 back.reverse()
 var destination_ref=target_ref
 var second: Array=[]
 if kind=="taxi":
  var places=[]
  for i in state.homes.size():
   if state.homes[i].kind in ["shop","park","school","nightclub","office","hotel"] and {"type":"home","index":i}!=target_ref: places.append({"type":"home","index":i})
  if places.is_empty():
   for i in state.buildings.size():
    if state.buildings[i].kind in ["market","station"] and {"type":"building","index":i}!=target_ref: places.append({"type":"building","index":i})
  if places.is_empty(): return false
  destination_ref=places[posmod(int(data.next_id),places.size())]
  var c=location(state,destination_ref)
  second=route(state,b,c,cache)
  back=route(state,c,a,cache)
  if second.size()<2 or back.size()<2: return false
 var speed=14.0 if kind=="taxi" else 17.0
 var t1=maxf(2,LogisticsRoutes.length(outward)/speed)
 var t2=maxf(2,LogisticsRoutes.length(second)/speed) if kind=="taxi" else 0.0
 var water_ref=FireSafety.water_source(state,int(target_ref.index),cache) if not incident.is_empty() else {}
 var work=(FireSafety.WATER_WORK if not water_ref.is_empty() else FireSafety.BASE_WORK) if not incident.is_empty() else 4.0 if kind=="taxi" else 10.0
 var served=t1+work+t2+(3.0 if kind=="taxi" else 0.0)
 var total=served+maxf(2,LogisticsRoutes.length(back)/speed)
 data.missions.append({"id":data.next_id,"kind":kind,"source_ref":station_ref,"target_ref":target_ref,"destination_ref":destination_ref,"outward":outward.duplicate(true),"second":second.duplicate(true),"back":back.duplicate(true),"drive":t1,"second_drive":t2,"work":work,"served_at":served,"total":total,"age":0.0,"served":false,"reward":maxf(12,LogisticsRoutes.length(second)*0.25) if kind=="taxi" else 20.0,"external":station_ref.type=="entry"})
 if not incident.is_empty():
  data.missions[-1].fire_id=int(incident.id)
  incident.mission_id=int(data.next_id)
  incident.wait_reason=""
  data.missions[-1].water_source_ref=water_ref.duplicate(true)
  data.missions[-1].water_route=route(state,location(state,water_ref),b,cache).duplicate(true) if not water_ref.is_empty() else []
 data.next_id+=1
 return true

static func create_walk(state: Dictionary, cache: Dictionary) -> bool:
 var data=state.city_services
 if data.walkers.size()>=12: return false
 var targets=destinations(state)
 if targets.is_empty(): return false
 var source=targets[posmod(int(data.next_id),targets.size())]
 var destination=source.duplicate()
 if not state.buildings.is_empty(): destination={"type":"building","index":0}
 for i in state.homes.size():
  if state.homes[i].kind in ["park","shop","school","nightclub"] and {"type":"home","index":i}!=source:
   destination={"type":"home","index":i}; break
 if source==destination and targets.size()>1: destination=targets[(posmod(int(data.next_id),targets.size())+1)%targets.size()]
 if source==destination: return false
 var path=route(state,location(state,source),location(state,destination),cache)
 if path.size()<2: return false
 data.walkers.append({"id":data.next_id,"path":path.duplicate(true),"age":0.0,"total":maxf(6,LogisticsRoutes.length(path)/3.2),"source_ref":source,"destination_ref":destination})
 data.next_id+=1
 return true

static func tick(state: Dictionary, delta: float, cache: Dictionary) -> void:
 var data=state.city_services
 tick_fires(state,delta,cache)
 var done=[]
 for mission in data.missions:
  mission.age=float(mission.age)+delta
  if not mission.served and float(mission.age)>=float(mission.served_at):
   mission.served=true
   if mission.has("fire_id"):
    for incident in data.fires.duplicate():
     if int(incident.id)==int(mission.fire_id):
      data.fires.erase(incident)
      data.fires_extinguished=int(data.fires_extinguished)+1
      UXRules.push_event(state,"fire_done:%s" % incident.id,"Brand gelöscht · Gebäude gerettet",location(state,incident.target_ref),"services")
   data.completed[mission.kind]=int(data.completed.get(mission.kind,0))+1
   data.treasury+=float(mission.reward)
  if float(mission.age)>=float(mission.total): done.append(mission)
 for mission in done: data.missions.erase(mission)
 done=[]
 for person in data.walkers:
  person.age=float(person.age)+delta
  if float(person.age)>=float(person.total): done.append(person); data.walks+=1
 for person in done: data.walkers.erase(person)
 if not data.enabled: return
 data.clock+=delta
 data.walk_clock+=delta
 if float(data.clock)>=35.0:
  data.clock=fposmod(float(data.clock),35.0)
  var kind=TYPES[int(data.auto_kind)%4]
  dispatch(state,kind,cache)
  data.auto_kind=int(data.auto_kind)+1
 if float(data.walk_clock)>=12.0:
  data.walk_clock=fposmod(float(data.walk_clock),12.0)
  create_walk(state,cache)

static func sample(mission: Dictionary, extra: float = 0.0) -> Dictionary:
 var age=float(mission.age)+extra
 var a=float(mission.drive)
 var pickup=a+float(mission.work)
 var served=float(mission.served_at)
 var path: Array=mission.outward
 var amount=clampf(age/a,0,1)
 var status="Zum Fahrgast" if mission.kind=="taxi" else "Zum Einsatz"
 var lights=mission.kind!="taxi" and age<served
 if age>=served:
  path=mission.back
  amount=clampf((age-served)/maxf(0.001,float(mission.total)-served),0,1)
  status="Rückfahrt"
 elif age>=pickup and mission.kind=="taxi":
  path=mission.second
  amount=clampf((age-pickup)/float(mission.second_drive),0,1)
  status="Fahrgast an Bord" if age<pickup+float(mission.second_drive) else "Aussteigen"
 elif age>=a:
  amount=1.0
  status="Löscharbeiten" if mission.has("fire_id") else "Einsteigen" if mission.kind=="taxi" else "Hilfe vor Ort"
 var value=LogisticsRoutes.sample(path,amount)
 value.status=status
 value.lights=lights
 value.passenger=mission.kind=="taxi" and age>=pickup and age<served
 value.moving=status in ["Zum Fahrgast","Zum Einsatz","Fahrgast an Bord","Rückfahrt"]
 return value

static func uses_building(state: Dictionary, index: int, city: bool) -> bool:
 var type_value="home" if city else "building"
 for incident in state.city_services.get("fires",[]):
  if incident.target_ref.type==type_value and int(incident.target_ref.index)==index: return true
 for mission in state.city_services.missions:
  for ref in [mission.source_ref,mission.target_ref,mission.destination_ref,mission.get("water_source_ref",{})]:
   if ref.get("type","")==type_value and int(ref.index)==index: return true
 return false

# Incidents share the existing bounded service fleet and saved road missions.
static func ignite(state: Dictionary, target: Dictionary, reported: bool = true) -> bool:
 var data=state.city_services
 if data.fires.size()>=2 or target.get("type","")!="home": return false
 var index=int(target.get("index",-1))
 if index<0 or index>=state.homes.size(): return false
 var home=state.homes[index]
 if int(home.get("level",0))<1 or int(Catalog.HOMES[home.kind].people)<=0: return false
 for incident in data.fires:
  if int(incident.target_ref.index)==index: return false
 var incident={"id":int(data.next_fire),"target_ref":target.duplicate(true),"age":0.0,"mission_id":-1,"progress":0.0,"alarm_after":0.0 if reported or FireSafety.installed(state,index,"detector") else FireSafety.ALARM_DELAY,"wait_reason":""}
 data.next_fire=int(data.next_fire)+1
 data.fires.append(incident)
 UXRules.push_event(state,"fire:%s" % incident.id,("Rauchentwicklung · Alarmierung steht aus" if FireSafety.alarm_left(incident)>0 else "Brand gemeldet · Feuerwehr wird alarmiert"),location(state,target),"services",1)
 return true

static func tick_fires(state: Dictionary, delta: float, cache: Dictionary) -> void:
 var data=state.city_services
 # Legacy saves are initialized without retroactive incidents.
 for key in ["fires","fire_clock","next_fire","fires_extinguished"]:
  if not data.has(key): data[key]=initial()[key]
 for incident in data.fires:
  incident.age=float(incident.age)+delta
  var assigned=false
  for mission in data.missions:
   if int(mission.get("fire_id",-1))!=int(incident.id): continue
   assigned=true
   incident.progress=clampf((float(mission.age)+delta-float(mission.drive))/float(mission.work),0,1)
   break
  if not assigned:
   incident.mission_id=-1
   if FireSafety.alarm_left(incident)<=0: dispatch(state,"fire",cache,incident)
 if not data.enabled: return
 data.fire_clock=float(data.fire_clock)+delta
 if float(data.fire_clock)>=420.0:
  data.fire_clock=fposmod(float(data.fire_clock),420.0)
  var targets=destinations(state)
  if not targets.is_empty():
   for offset in targets.size():
    if ignite(state,targets[posmod(int(data.next_fire)-1+offset,targets.size())],false): break
