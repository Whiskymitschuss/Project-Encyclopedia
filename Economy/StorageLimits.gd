class_name StorageLimits
extends RefCounted

# Each material owns a shelf. Cargo and the recovery receiving area book that
# shelf before any new purchase, deposit or production may use it.
static func central_reserved(state: Dictionary,key: String) -> float:
 var amount=float(state.hub.get("receiving",{}).get(key,0))
 for trip in state.hub.shipments:
  if trip.target=="central" and trip.key==key and not trip.arrived: amount+=float(trip.amount)
 for trip in state.stone.shipments:
  if int(trip.destination)<0 and trip.key==key and not trip.arrived: amount+=float(trip.amount)
 for trip in state.construction_shipments:
  if trip.key==key and not trip.arrived and not state.jobs.any(func(job): return int(job.get("id",-1))==int(trip.job)):
   amount+=float(trip.amount)
 return amount

static func network_capacity(state: Dictionary,key: String) -> float:
 var amount=CentralLogistics.capacity(state)
 for index in state.buildings.size():
  var kind=str(state.buildings[index].kind)
  if kind=="express": amount+=DepotNetwork.capacity(state,index)
  elif DeliveryChain.owns(state,index):
   if FactorySupply.requirements(state,index).has(key) or key in LogisticsDispatch.outputs(state,index): amount+=DeliveryChain.capacity(state,kind)
   if state.hub.outputs.get(str(index),{}).has(key): amount+=CentralLogistics.output_capacity(state,index)
  elif kind in StoneIndustry.KINDS:
   if key in (["rock"] if kind=="quarry" else ["rock","stone","gravel"]): amount+=StoneIndustry.capacity(state,index)
  else:
   if FactorySupply.managed(state,index) and FactorySupply.requirements(state,index).has(key): amount+=FactorySupply.capacity(state,index)
   if CentralLogistics.active(state) and (key in LogisticsDispatch.outputs(state,index) or state.hub.outputs.get(str(index),{}).has(key)):
    amount+=CentralLogistics.output_capacity(state,index)
 return amount

static func central_status(state: Dictionary,key: String) -> String:
 var current=float(state.resources.get(key,0))
 var maximum=CentralLogistics.capacity(state)
 var booked=central_reserved(state,key)
 var room=CentralLogistics.storage_room(state,key)
 var status="Überbestand · erst verbrauchen oder verkaufen" if current>maximum+0.00001 else "VOLL · wartet auf Verbrauch oder Verkauf" if room<=0.00001 else "%s Plätze frei" % Catalog.number(room)
 return "Zentrale %s / %s · %s\n%s für Anlieferungen/Warenannahme gebucht" % [Catalog.number(current),Catalog.number(maximum),status,Catalog.number(booked)]

static func depot_status(state: Dictionary,index: int) -> String:
 var maximum=DepotNetwork.capacity(state,index)
 if state.buildings[index].kind=="central_depot":
  return "Lagergrenze: %s je Warenart · getrennte Lagerplätze\nAusbauen schafft Platz; volle Warenfächer stoppen neue Abholungen." % Catalog.number(maximum)
 var occupied=[]
 var stock=state.hub.express.get(str(index),{})
 for key in Catalog.RESOURCES:
  var quantity=float(stock.get(key,0))
  var incoming=CentralLogistics.incoming(state,index,key)
  if quantity>0 or incoming>0:
   occupied.append("%s %s/%s · %s unterwegs" % [Catalog.RESOURCES[key],Catalog.number(quantity),Catalog.number(maximum),Catalog.number(incoming)])
 return "Lagergrenze: %s je Warenart\n%s" % [Catalog.number(maximum),"\n".join(occupied) if not occupied.is_empty() else "Lager leer · wartet auf Abholung"]
