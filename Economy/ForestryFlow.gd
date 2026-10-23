class_name ForestryFlow
extends RefCounted

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
  return {"kind":"running","text":"Holzfäller arbeiten · %.2f Holz/s" % rate,"key":""}
 var amount=float(state.hub.outputs.get(str(index),{}).get("wood",0))
 var maximum=64+int(state.buildings[index].level)*8
 var stock="Abholvorrat %s/%s Holz" % [Catalog.number(amount),maximum]
 if amount<maximum-0.00001: return {"kind":"running","text":"Holzfäller arbeiten · %.2f Holz/s · %s" % [rate,stock],"key":""}
 var center=CentralLogistics.depot(state)
 var reason="Wartet auf freien Lager-LKW"
 if state.buildings[center].get("paused",false): reason="Zentrallager pausiert · fortsetzen"
 elif LogisticsRoutes.road_route(state,index,center).size()<2: reason="Straßenverbindung zum Zentrallager fehlt"
 elif CentralLogistics.storage_room(state,"wood")<=0: reason="Zentrallager voll/reserviert · Holz weiterverarbeiten"
 else:
  for trip in state.hub.shipments:
   if int(trip.origin)==index and trip.key=="wood": reason="Abholung disponiert · "+FreightFlow.status(trip); break
 return {"kind":"full","text":"%s · %s" % [stock,reason],"key":"wood"}
