class_name ForestryFlow
extends RefCounted
const WORK_EDGE=34.0
const LANDING_EDGE=39.0

static func work_position(state: Dictionary) -> Vector3:
 return Catalog.biome_position(int(state.biome))+Vector3(0,0,WORK_EDGE)

# The simulation owns forest output. Animation reads the accepted quantity;
# an invisible or reduced-motion worker must never change the company's yield.
static func harvest(state: Dictionary,potential: float,delta: float) -> Dictionary:
 var stations=[]
 var room=0.0
 var centralized=CentralLogistics.active(state)
 for index in state.buildings.size():
  var b=state.buildings[index]
  if b.kind!="station" or b.get("paused",false): continue
  var available=float(b.level)*5*maxf(0,delta)
  if centralized: available=minf(available,CentralLogistics.output_room(state,index,"wood"))
  stations.append({"index":index,"room":available})
  room+=available
 var amount=minf(maxf(0,potential),room)
 if not centralized: amount=minf(amount,maxf(0,CentralLogistics.capacity(state)-float(state.resources.wood)))
 amount=ForestCycle.take(state,int(state.biome),amount)
 var sources={}
 for station in stations:
  var share=amount*float(station.room)/maxf(room,0.000001)
  if centralized and share>0:
   var output=CentralLogistics.stock(state,int(station.index))
   output.wood=float(output.get("wood",0))+share
  sources[str(station.index)]=share
 if not centralized: state.resources.wood+=amount
 return {"amount":amount,"sources":sources}

static func describe(state: Dictionary,index: int,flow: Dictionary={}) -> Dictionary:
 if state.buildings[index].get("paused",false): return {"kind":"paused","text":"Sammelstation pausiert","key":"wood"}
 if int(state.workers)<=0: return {"kind":"missing","text":"Keine Holzfäller eingestellt · Team öffnen","key":"wood"}
 var rate=float(flow.get("harvest:%s" % index,0))
 if not CentralLogistics.active(state):
  if float(state.resources.wood)>=CentralLogistics.capacity(state)-0.00001: return {"kind":"full","text":"Holzlager voll · Holz verarbeiten oder verkaufen","key":"wood"}
  return {"kind":"running","text":"Baumpflanzer arbeiten · Holzfäller kehren zurück" if rate<=0 and ForestCycle.busy(state)>0 else "Holzfäller arbeiten · %.2f Holz/s" % rate,"key":""}
 var amount=float(state.hub.outputs.get(str(index),{}).get("wood",0))
 var maximum=64+int(state.buildings[index].level)*8
 var stock="Abholvorrat %s/%s Holz" % [Catalog.number(amount),maximum]
 if amount<maximum-0.00001: return {"kind":"running","text":("Baumpflanzer arbeiten · "+stock) if rate<=0 and ForestCycle.busy(state)>0 else "Holzfäller arbeiten · %.2f Holz/s · %s" % [rate,stock],"key":""}
 var center=CentralLogistics.depot(state)
 var reason="Wartet auf freien Lager-LKW"
 if LogisticsDispatch.enabled(state):
  for trip in state.hub.shipments:
   if int(trip.origin)==index and trip.key=="wood" and trip.target in ["central","express"]: return {"kind":"full","text":"%s · Abholung disponiert · %s" % [stock,FreightFlow.status(trip)],"key":"wood"}
  var destination=DepotNetwork.pickup(state,index,"wood")
  if not destination.is_empty(): reason+=" → "+UXRules.factory_name(state,int(destination.index))
  else:
   var depots=DepotNetwork.depots(state)
   var connected=false
   for depot in depots:
    if LogisticsRoutes.road_route(state,index,int(depot)).size()>=2: connected=true; break
   reason="Erreichbare Lager voll · Holz verarbeiten oder verkaufen" if connected else "Straßenverbindung zum Lager fehlt" if not depots.is_empty() else "Alle Lager pausiert · Betrieb fortsetzen"
  return {"kind":"full","text":"%s · %s" % [stock,reason],"key":"wood"}
 if state.buildings[center].get("paused",false): reason="Zentrallager pausiert · fortsetzen"
 elif LogisticsRoutes.road_route(state,index,center).size()<2: reason="Straßenverbindung zum Zentrallager fehlt"
 elif CentralLogistics.storage_room(state,"wood")<=0: reason="Zentrallager voll/reserviert · Holz weiterverarbeiten"
 else:
  for trip in state.hub.shipments:
   if int(trip.origin)==index and trip.key=="wood": reason="Abholung disponiert · "+FreightFlow.status(trip); break
 return {"kind":"full","text":"%s · %s" % [stock,reason],"key":"wood"}

static func loading(state: Dictionary,index: int) -> bool:
 for trip in state.hub.shipments:
  if int(trip.origin)==index and trip.target=="central" and trip.key=="wood" and not trip.arrived and float(trip.age)<float(trip.get("load",0)):
   return true
 return false

static func team_status(state: Dictionary,flow: Dictionary) -> String:
 var amount=float(state.journey.stats.get("automatic_wood",0))
 var rows=["Automatisch gewonnen seit Update: %s Holz" % Catalog.number(amount)]
 if int(state.workers)<=0: rows.append("Keine Holzfäller eingestellt")
 else:
  rows.append("Automatische Ernte: %.1f Holz/s" % float(flow.get("harvest",0)))
  for index in state.buildings.size():
   if state.buildings[index].kind=="station": rows.append(describe(state,index,flow).text)
 if not state.ux.motion: rows.append("Arbeitsanimationen sind ausgeschaltet")
 return "\n".join(rows)
