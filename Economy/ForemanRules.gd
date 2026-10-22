class_name ForemanRules
extends RefCounted

static func initial() -> Dictionary:
 return {"enabled":true,"reassignments":0,"transport_turn":"construction","yard_turns":{}}

static func managed(job: Dictionary) -> bool:
 return job.has("phases") and bool(job.get("auto_crew",true))

static func ordered(state: Dictionary) -> Array:
 var jobs=state.jobs.filter(func(j): return j.has("phases") and not j.get("paused",false))
 jobs.sort_custom(func(a,b):
  if bool(a.get("priority",false))!=bool(b.get("priority",false)): return a.get("priority",false)
  if ConstructionRules.phase_ready(a)!=ConstructionRules.phase_ready(b): return ConstructionRules.phase_ready(a)
  return int(a.id)<int(b.id))
 return jobs

static func tick(state: Dictionary, delta: float) -> bool:
 for job in state.jobs:
  if not job.has("phases"): continue
  if job.get("paused",false): continue
  job.stalled=float(job.get("stalled",0))+delta if int(job.workers)<=0 or not ConstructionRules.phase_ready(job) else 0.0
 if not state.foreman.enabled: return false
 var free=int(state.builders)
 var old={}
 for job in state.jobs:
  if not job.has("phases"): continue
  if managed(job): old[int(job.id)]=int(job.workers); job.workers=0
  else: free-=int(job.workers)
 for job in ordered(state):
  if free<=0: break
  if not managed(job): continue
  job.workers=1
  free-=1
 var changed=false
 for job in state.jobs:
  if managed(job) and old[int(job.id)]!=int(job.workers): changed=true
 if changed: state.foreman.reassignments=int(state.foreman.reassignments)+1
 return changed

static func diagnosis(state: Dictionary, job: Dictionary) -> String:
 if job.get("paused",false): return "Pausiert · Fortsetzen gibt die Baustelle wieder frei."
 if int(job.get("workers",0))<=0:
  return "Kein Bauteam · Bauleitung verteilt freie Teams automatisch." if managed(job) and state.foreman.enabled else "Kein Bauteam · Arbeiter zuweisen oder Bauleitung aktivieren."
 if ConstructionRules.phase_ready(job): return "Team arbeitet · Material für diese Bauphase ist da."
 return ConstructionRules.logistics_status(state,job)

static func order_status(state: Dictionary) -> String:
 if not state.delivery.active: return "Keine Ladenlinie aktiv."
 if state.delivery.paused: return "Lieferlinie pausiert · im Lieferkettenmenü fortsetzen."
 for kind in DeliveryChain.KINDS:
  var i=int(state.delivery.nodes[kind])
  if state.buildings[i].get("paused",false): return "%s pausiert · Betrieb fortsetzen." % Catalog.BUILDINGS[kind].name
 var buffers=state.delivery.buffers
 for link in [["furniture","market","furniture"],["sawmill","furniture","boards"],["station","sawmill","wood"]]:
  if float(buffers[link[0]][link[2]])<1: continue
  if float(buffers[link[1]][link[2]])>=DeliveryChain.capacity(state,link[1]): continue
  for trip in state.delivery.shipments:
   if trip.target==link[1] and not trip.arrived:
    return "Lieferung zum %s · %s" % [Catalog.BUILDINGS[link[1]].name,trip.get("traffic_wait","unterwegs") if not str(trip.get("traffic_wait","")).is_empty() else "unterwegs"]
  if TrafficRules.source_busy(state,int(state.delivery.nodes[link[0]])):
   return "Ladehof %s belegt · laufende Tour kehrt zuerst zurück." % Catalog.BUILDINGS[link[0]].name
  if LogisticsRoutes.road_route(state,int(state.delivery.nodes[link[0]]),int(state.delivery.nodes[link[1]])).size()<2:
   return "Straße zwischen %s und %s fehlt." % [Catalog.BUILDINGS[link[0]].name,Catalog.BUILDINGS[link[1]].name]
  return "Ware bereit · wartet auf einen freien LKW. Baustellen teilen die Flotte."
 if float(buffers.sawmill.wood)>=2: return "Sägewerk verarbeitet Holz · Bretter gehen zuerst an aktive Bauteams."
 if float(buffers.furniture.boards)>=2: return "Möbel werden produziert · danach zum Laden gefahren."
 return "Holz fehlt an der Linie · Sammelstation versorgen. Baustoffe bleiben reserviert."

static func hold_source_for_line(state: Dictionary, index: int) -> bool:
 if not state.foreman.enabled or state.foreman.get("yard_turns",{}).get(str(index),"construction")!="line": return false
 var data=state.delivery
 if not data.active or data.paused: return false
 for kind in DeliveryChain.KINDS:
  if state.buildings[int(data.nodes[kind])].get("paused",false): return false
 for link in DeliveryChain.LINKS:
  if int(data.nodes[link[0]])!=index or float(data.buffers[link[0]][link[2]])<1: continue
  var room=DeliveryChain.capacity(state,link[1])-float(data.buffers[link[1]][link[2]])-DeliveryChain.reserved(data,link[1],link[2])
  if room<1: continue
  return LogisticsRoutes.road_route(state,index,int(data.nodes[link[1]])).size()>1
 return false

static func hold_for_line(state: Dictionary) -> bool:
 if not state.get("foreman",{}).get("enabled",false) or state.foreman.get("transport_turn","")!="line": return false
 var data=state.delivery
 if not data.active or data.paused: return false
 for kind in DeliveryChain.KINDS:
  if state.buildings[int(data.nodes[kind])].get("paused",false): return false
 for link in DeliveryChain.LINKS:
  if TrafficRules.source_busy(state,int(data.nodes[link[0]])): continue
  if float(data.buffers[link[0]][link[2]])<(2 if link[2] in ["wood","boards"] else 1): continue
  var room=DeliveryChain.capacity(state,link[1])-float(data.buffers[link[1]][link[2]])-DeliveryChain.reserved(data,link[1],link[2])
  if room<1: continue
  if LogisticsRoutes.road_route(state,int(data.nodes[link[0]]),int(data.nodes[link[1]])).size()>1: return true
 return false
