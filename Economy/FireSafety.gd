class_name FireSafety
extends RefCounted

const COSTS={"detector":125,"hydrant":350}
const RADIUS=44.0
const ALARM_DELAY=12.0
const BASE_WORK=36.0
const WATER_WORK=24.0

static func eligible(state: Dictionary, index: int) -> bool:
 return index>=0 and index<state.homes.size() and int(state.homes[index].get("level",0))>0 and int(Catalog.HOMES[state.homes[index].kind].people)>0

static func installed(state: Dictionary, index: int, kind: String) -> bool:
 return index>=0 and index<state.homes.size() and bool(state.homes[index].get("fire_safety",{}).get(kind,false))

static func hydrant_position(state: Dictionary, index: int, cells: Dictionary = {}) -> Vector3:
 var home=state.homes[index]
 var center=LogisticsRoutes.home_position(state,index)
 var saved=home.get("fire_safety",{}).get("hydrant_offset",[])
 if saved is Array and saved.size()==3:
  return center+LogisticsRoutes.vector(saved).rotated(Vector3.UP,deg_to_rad(float(home.get("rotation",0))))
 if cells.is_empty(): cells=TownRules.road_cells(state.town)
 var road=TownRules.nearest(center,cells,32.0)
 if road!=null:
  var direction=(TownRules.point(road)-center).normalized()
  if direction.length()>0.01:
   return center+direction*11+Vector3(direction.z,0,-direction.x)*5+Vector3(0,0.6,0)
 return center+Vector3(8,0.6,9).rotated(Vector3.UP,deg_to_rad(float(home.get("rotation",0))))

static func water_source(state: Dictionary, index: int, cache: Dictionary) -> Dictionary:
 if not eligible(state,index): return {}
 var target=LogisticsRoutes.home_position(state,index)
 var distance=RADIUS+0.001
 var selected={}
 var cells=TownRules.road_cells(state.town)
 for i in state.homes.size():
  if not installed(state,i,"hydrant"): continue
  var source=hydrant_position(state,i,cells)
  var next_distance=Vector2(source.x-target.x,source.z-target.z).length()
  if next_distance>RADIUS or next_distance>=distance: continue
  if CityServices.route(state,LogisticsRoutes.home_position(state,i),target,cache).size()<2: continue
  distance=next_distance
  selected={"type":"home","index":i}
 return selected

static func fleet(state: Dictionary) -> Dictionary:
 var capacity=1
 var external=true
 for home in state.homes:
  if home.kind=="fire" and int(home.level)>0:
   capacity=mini(3,1+int(home.level)/3)
   external=false
   break
 var busy=0
 for mission in state.city_services.missions:
  if mission.kind=="fire": busy+=1
 return {"capacity":capacity,"busy":busy,"free":maxi(0,capacity-busy),"external":external}

static func alarm_left(incident: Dictionary) -> float:
 return maxf(0,float(incident.get("alarm_after",0))-float(incident.age))

static func status(state: Dictionary, incident: Dictionary) -> String:
 if alarm_left(incident)>0: return "Erkennung in %s s · Jetzt selbst alarmieren möglich" % ceili(alarm_left(incident))
 for mission in state.city_services.missions:
  if int(mission.get("fire_id",-1))!=int(incident.id): continue
  if float(mission.age)<float(mission.drive): return "Anfahrt · Ankunft in %s s" % ceili(float(mission.drive)-float(mission.age))
  return "Löschen %s %% · noch %s s · %s" % [int(float(incident.progress)*100),maxi(0,ceili(float(mission.served_at)-float(mission.age))),"Hydrant" if not mission.get("water_source_ref",{}).is_empty() else "Fahrzeugversorgung"]
 return "Kein Straßenanschluss · Wege prüfen" if incident.get("wait_reason","")=="route" else "Wartet auf freies Löschfahrzeug" if incident.get("wait_reason","")=="fleet" else "Alarmiert · Disposition läuft"

static func raise_alarm(state: Dictionary, id: int) -> bool:
 for incident in state.city_services.fires:
  if int(incident.id)!=id or alarm_left(incident)<=0: continue
  incident.alarm_after=float(incident.age)
  UXRules.push_event(state,"fire_alarm:%s" % id,"Feuerwehr alarmiert",CityServices.location(state,incident.target_ref),"services",1)
  return true
 return false
