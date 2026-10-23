class_name ExportTrade
extends RefCounted

const GATE = Vector2i(300,176)
const GOODS = ["wood","boards","dry","furniture","design","stone","gravel"]
const PREMIUM = 1.15
const GATEWAYS={"highway":{"name":"Autobahn","active":true},"harbor":{"name":"Seehafen","active":false},"airport":{"name":"Flughafen","active":false}}
static var route_cache: Dictionary={}

static func initial() -> Dictionary:
 return {"gateway":"highway","material":"furniture","shipments":[],"next_id":1,"sold":0.0,"revenue":0.0,"intro":false,"ledgers":{"highway":{"sold":0.0,"revenue":0.0},"harbor":{"sold":0.0,"revenue":0.0},"airport":{"sold":0.0,"revenue":0.0}}}

static func busy(state: Dictionary) -> int:
 return state.get("trade",{}).get("shipments",[]).size()

static func available_trucks(state: Dictionary) -> int:
 return maxi(0,int(state.trucks)-DeliveryChain.general_busy(state)-(0 if CentralLogistics.active(state) else state.construction_shipments.size())-state.stone.shipments.size()-busy(state))

static func route(state: Dictionary) -> Dictionary:
 if str(state.trade.gateway)!="highway": return {}
 var markets=[]
 for i in state.buildings.size():
  var b=state.buildings[i]
  if b.kind=="market" and not b.get("paused",false): markets.append([i,LogisticsRoutes.building_position(state,i)])
 var signature=hash([state.town.districts,state.town.roads,markets,state.trade.gateway])
 if route_cache.has(signature): return route_cache[signature]
 var result={}
 var cells=TownRules.road_cells(state.town)
 if cells.has(GATE) and not markets.is_empty():
  var network=TownRules.graph(cells)
  for market in markets:
   var a: Vector3=market[1]
   var start=TownRules.nearest(a,cells,18.0)
   if start==null: continue
   var raw=network.get_point_path(network.get_closest_point(Vector2(start)),network.get_closest_point(Vector2(GATE)))
   if raw.is_empty(): continue
   var direction=(TownRules.point(start)-a).normalized()
   var half=Placement.size_for(int(state.buildings[int(market[0])].get("rotation",0)))/2
   var edge=minf(half.x/maxf(absf(direction.x),0.001),half.y/maxf(absf(direction.z),0.001))+1.0
   var dock=a+direction*edge
   var path=[[dock.x,0.95,dock.z]]
   var public_cells=[]
   for c in raw:
    path.append([c.x,0.95,c.y])
    public_cells.append([int(c.x),int(c.y)])
   # The private ramp is never part of the player's public street graph.
   path.append_array([[304,0.95,176],[312,2.4,176],[324,4.1,176],[324,4.1,196]])
   var distance=LogisticsRoutes.length(path)
   if result.is_empty() or distance<float(result.distance):
    result={"origin":market[0],"path":path,"road_cells":public_cells,"distance":distance}
 if route_cache.size()>=64: route_cache.clear()
 route_cache[signature]=result
 return result

static func status(state: Dictionary) -> String:
 if str(state.trade.gateway)!="highway": return "Dieser Frachtweg ist noch in Planung"
 if not TownRules.road_cells(state.town).has(GATE): return "Straße fehlt · Anschluss bei 300 / 176 anbinden"
 if route(state).is_empty(): return "Keine Verbindung · aktiven Markt über Straßen mit der Auffahrt verbinden"
 if not state.auto_export: return "Neue Fahrten pausiert · laufende Lieferungen fahren zu Ende"
 if available_trucks(state)<=0: return "Verbunden · alle LKW unterwegs"
 return "Verbunden · wartet auf freie Exportware"

static func dispatch(state: Dictionary, reserve: float, unit_price: float) -> bool:
 if not state.auto_export or busy(state)>=8 or available_trucks(state)<=0: return false
 var key=str(state.trade.material)
 if key not in GOODS: return false
 var stock=floorf(maxf(0,float(state.resources[key])-reserve))
 if stock<1: return false
 var connection=route(state)
 if connection.is_empty(): return false
 var base_capacity=4+int(state.vehicle)*2+maxi(0,int(state.buildings[int(connection.origin)].level)-1)
 var capacity=ceili(base_capacity*(1+int(state.research.get("logistics",0))*0.12))
 var amount=minf(stock,capacity)
 var drive=maxf(1.0,float(connection.distance)/(12.0+int(state.vehicle)*1.5))
 var travel=2+drive+2
 state.resources[key]-=amount
 FreightFlow.enqueue(state,state.trade.shipments,{"id":state.trade.next_id,"source":"market","origin":connection.origin,"target":"export","gateway":"highway","key":key,"amount":amount,"mode":"truck","path":connection.path.duplicate(true),"road_cells":connection.road_cells.duplicate(true),"age":0.0,"load":2.0,"drive":drive,"unload":2.0,"travel":travel,"total":travel+drive+2,"arrived":false,"unit_price":unit_price})
 state.trade.next_id+=1
 return true

static func tick(state: Dictionary, delta: float) -> Dictionary:
 var report={"coins":0.0,"amount":0.0,"receipts":[]}
 var done=[]
 for trip in state.trade.shipments:
  FreightFlow.advance(trip,delta)
  if not trip.arrived and float(trip.age)>=float(trip.travel):
   trip.arrived=true
   var coins=float(trip.amount)*float(trip.unit_price)
   report.coins+=coins
   report.amount+=float(trip.amount)
   report.receipts.append({"key":trip.key,"coins":coins,"point":trip.path.back()})
   state.trade.sold+=float(trip.amount)
   state.trade.revenue+=coins
   var gateway=str(trip.gateway)
   if not state.trade.ledgers.has(gateway): state.trade.ledgers[gateway]={"sold":0.0,"revenue":0.0}
   state.trade.ledgers[gateway].sold+=float(trip.amount)
   state.trade.ledgers[gateway].revenue+=coins
  if float(trip.age)>=float(trip.total): done.append(trip)
 for trip in done: state.trade.shipments.erase(trip)
 return report
