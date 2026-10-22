class_name TrafficRules
extends RefCounted

# One deterministic clock for saved freight and service vehicles. The renderer
# only reads these positions; a red light delays the actual cargo receipt.
const LANE=1.5
const STEP=0.2
static var network_signature=0
static var junction_cache=[]
# A query tile covers all centres that can intersect its 12-metre stop zone.
# Build lazily per road network, preserving the original junction order.
static var junction_tiles={}
static var path_cache={}
static var bus_cache={}

static func initial() -> Dictionary:
 return {"enabled":true,"clock":0.0,"fault_clock":0.0,"faults":[],"next_fault":1,"repaired":0}

static func junctions(state: Dictionary) -> Array:
 var signature=hash([state.town.roads,state.town.districts])
 if signature==network_signature and not junction_cache.is_empty(): return junction_cache
 network_signature=signature
 junction_cache=[]
 junction_tiles.clear()
 var cells=TownRules.road_cells(state.town)
 for c in cells:
  var degree=0
  for d in [Vector2i(4,0),Vector2i(-4,0),Vector2i(0,4),Vector2i(0,-4)]:
   if cells.has(c+d): degree+=1
  if degree>=3:
   var separate=true
   for prior in junction_cache:
    if Vector2(prior).distance_to(Vector2(c))<20: separate=false; break
   if separate: junction_cache.append(Vector2i(c))
 junction_cache.sort_custom(func(a,b): return a.x<b.x if a.x!=b.x else a.y<b.y)
 return junction_cache

static func nearby_junctions(position: Vector3) -> Array:
 var tile=Vector2i(floori(position.x/32.0),floori(position.z/32.0))
 if not junction_tiles.has(tile):
  var candidates=[]
  for cell in junction_cache:
   if cell.x>=tile.x*32-12 and cell.x<=(tile.x+1)*32+12 and cell.y>=tile.y*32-12 and cell.y<=(tile.y+1)*32+12:
    candidates.append(cell)
  if junction_tiles.size()>=512: junction_tiles.clear()
  junction_tiles[tile]=candidates
 return junction_tiles[tile]

static func fault_at(state: Dictionary, cell: Vector2i) -> Dictionary:
 for fault in state.traffic.faults:
  if TownRules.cell(fault.cell)==cell: return fault
 return {}

static func signal_phase(state: Dictionary, cell: Vector2i, clock: float = -1) -> String:
 if not fault_at(state,cell).is_empty(): return "fault"
 if clock<0: clock=float(state.traffic.clock)
 var phase=fposmod(clock+posmod(cell.x+cell.y,16),32)
 return "x" if phase<12 else "z" if phase>=16 and phase<28 else "red"

static func break_signal(state: Dictionary, cell: Vector2i) -> bool:
 if not cell in junctions(state) or not fault_at(state,cell).is_empty(): return false
 # A single maintenance call at a time keeps the small city's workload bounded.
 if not state.traffic.faults.is_empty(): return false
 state.traffic.faults.append({"id":int(state.traffic.next_fault),"cell":[cell.x,cell.y],"age":0.0,"mission":-1})
 state.traffic.next_fault=int(state.traffic.next_fault)+1
 UXRules.push_event(state,"signal:%s" % state.traffic.next_fault,"Ampel ausgefallen · Techniker wird gerufen",TownRules.point(cell),"traffic",1)
 return true

static func advance(trip: Dictionary, delta: float) -> float:
 var amount=float(trip.get("traffic_delta",delta))
 trip.erase("traffic_delta")
 return amount

static func compiled(points: Array) -> Dictionary:
 var key=hash(points)
 if not path_cache.has(key):
  var line=LogisticsRoutes.driving_path(points)
  var positions=[]
  var lengths=[0.0]
  for p in line:
   if not positions.is_empty(): lengths.append(float(lengths[-1])+positions[-1].distance_to(LogisticsRoutes.vector(p)))
   positions.append(LogisticsRoutes.vector(p))
  if path_cache.size()>=256: path_cache.clear()
  var directions=[]
  for i in range(1,positions.size()): directions.append((positions[i]-positions[i-1]).normalized())
  path_cache[key]={"points":positions,"lengths":lengths,"directions":directions}
 return path_cache[key]

static func point(points: Array, amount: float) -> Dictionary:
 return point_on(compiled(points),amount)

static func point_on(data: Dictionary, amount: float) -> Dictionary:
 if data.points.size()<2: return {"position":Vector3.ZERO,"direction":Vector3.BACK}
 var distance=float(data.lengths[-1])*clampf(amount,0,1)
 var lo=1
 var hi=data.points.size()-1
 while lo<hi:
  var mid=(lo+hi)/2
  if float(data.lengths[mid])<distance: lo=mid+1
  else: hi=mid
 var a: Vector3=data.points[lo-1]
 var b: Vector3=data.points[lo]
 return {"position":a.lerp(b,clampf((distance-float(data.lengths[lo-1]))/maxf(0.00001,float(data.lengths[lo])-float(data.lengths[lo-1])),0,1)),"direction":data.directions[lo-1]}

static func sample(trip: Dictionary, age: float, service: bool = false, prepared: Dictionary = {}) -> Dictionary:
 var path: Array=trip.outward if service else trip.path
 var line_key="outward" if service else "path"
 var direction_sign=1.0
 var moving=true
 var amount=0.0
 if service:
  var drive=float(trip.drive)
  var pickup=drive+float(trip.work)
  if age>=float(trip.served_at):
   path=trip.back
   line_key="back"
   amount=(age-float(trip.served_at))/maxf(0.001,float(trip.total)-float(trip.served_at))
  elif age>=pickup and trip.kind=="taxi":
   path=trip.second
   line_key="second"
   amount=(age-pickup)/maxf(0.001,float(trip.second_drive))
   moving=amount<1
  elif age>=drive: amount=1; moving=false
  else: amount=age/drive
 else:
  var load=float(trip.get("load",0))
  var drive=float(trip.drive)
  if age>=float(trip.travel):
   amount=1-(age-float(trip.travel))/drive
   direction_sign=-1
   moving=amount>0
  else:
   amount=(age-load)/drive
   moving=amount>0 and amount<1
 var line=prepared[line_key] if prepared.has(line_key) else compiled(path)
 var value=point_on(line,amount)
 # Pull into the delivery bay rather than parking across the road lane. This
 # derived line also fixes existing Alpha 1 trips without rewriting their saved
 # checkpoints, cargo reservations or road protection.
 var length_value=float(line.lengths[-1])
 var along=clampf(amount,0,1)*length_value
 var start_dir: Vector3=line.directions[0]
 var end_dir: Vector3=line.directions[-1]
 value.position-=start_dir*3.5*(1-smoothstep(0,7,along))
 value.position+=end_dir*3.5*(1-smoothstep(0,7,length_value-along))
 if not service:
  # Separate goods-in and goods-out bays prevent a long trailer arriving at
  # the sawmill from blocking the truck already loading its board output.
  value.position-=Vector3(start_dir.z,0,-start_dir.x)*3.5*(1-smoothstep(0,12,along))
  value.position-=Vector3(end_dir.z,0,-end_dir.x)*3.5*(1-smoothstep(0,12,length_value-along))
 if service:
  var start_ref=trip.source_ref
  var end_ref=trip.target_ref
  if age>=float(trip.served_at): start_ref=trip.destination_ref; end_ref=trip.source_ref
  elif trip.kind=="taxi" and age>=float(trip.drive)+float(trip.work): start_ref=trip.target_ref; end_ref=trip.destination_ref
  # Public service cars use a separate side bay, leaving the freight dock free.
  if start_ref.type in ["building","home"]: value.position-=Vector3(start_dir.z,0,-start_dir.x)*5*(1-smoothstep(0,9,along))
  if end_ref.type in ["building","home"]: value.position+=Vector3(end_dir.z,0,-end_dir.x)*5*(1-smoothstep(0,9,length_value-along))
 value.direction*=direction_sign
 # Keep docking manoeuvres within their own bay. On the road both directions
 # have a full lane, rather than the former overlapping one-metre offset.
 var lane=LANE*smoothstep(0,0.03,clampf(amount,0,1))*smoothstep(0,0.03,1-clampf(amount,0,1))
 value.position+=Vector3(value.direction.z,0,-value.direction.x)*lane
 value.moving=moving
 return value

static func prepare(state: Dictionary, delta: float) -> void:
 if not state.has("traffic"): state.traffic=initial()
 var traffic=state.traffic
 var entries=[]
 var line_active=state.delivery.active and not state.delivery.paused
 if line_active:
  for i in state.delivery.nodes.values():
   if state.buildings[int(i)].get("paused",false): line_active=false
 var groups=[state.construction_shipments,state.stone.shipments,state.trade.shipments,state.delivery.shipments]
 for domain in groups.size():
  for trip in groups[domain]:
   if trip.get("mode","")!="truck" or not trip.has("drive"): continue
   entries.append({"trip":trip,"service":false,"age":float(trip.age),"start":float(trip.age),"key":"%s:%010d" % [domain,int(trip.id)],"length":14.0 if int(state.vehicle)>=4 else 8.0,"priority":1,"readonly":domain==3 and not line_active})
 for trip in state.city_services.missions:
  entries.append({"trip":trip,"service":true,"age":float(trip.age),"start":float(trip.age),"key":"s:%010d" % int(trip.id),"length":6.5,"priority":0 if trip.has("fire_id") else 1})
 for line in state.town.lines:
  var plan=bus_plan(state,line)
  if plan.is_empty(): continue
  entries.append({"trip":line,"bus":true,"plan":plan,"service":false,"age":float(line.phase),"start":float(line.phase),"key":"b:%010d" % int(line.id),"length":8.3,"priority":1})
 entries.sort_custom(func(a,b): return a.priority<b.priority if a.priority!=b.priority else a.key<b.key)
 for entry in entries:
  if not entry.get("bus",false):
   entry.routes={}
   for key in (["outward","second","back"] if entry.service else ["path"]):
    if entry.trip[key].size()>1: entry.routes[key]=compiled(entry.trip[key])
  if entry.get("readonly",false): continue
  entry.trip.traffic_wait=""
  entry.trip.traffic_hidden=false
 var remaining=delta
 var elapsed=0.0
 var crossings=junctions(state)
 # Empty cities skip all collision work. Clocks still persist across saves.
 if entries.is_empty(): remaining=0
 for entry in entries:
  entry.sample=bus_sample(entry.plan,entry.age) if entry.get("bus",false) else sample(entry.trip,entry.age,entry.service,entry.routes)
 while remaining>0.00001:
  var active=false
  for entry in entries:
   if not entry.get("readonly",false) and entry.age<float(entry.trip.get("total",INF)): active=true; break
  if not active: break
  var dt=minf(STEP,remaining)
  for index in entries.size():
   var entry=entries[index]
   if entry.get("readonly",false) or entry.age>=float(entry.trip.get("total",INF)): continue
   var now=entry.sample
   var next_age=float(entry.age)+dt
   if not entry.has("next_age") or entry.next_age!=next_age:
    entry.next_age=next_age
    entry.next_sample=bus_sample(entry.plan,next_age) if entry.get("bus",false) else sample(entry.trip,next_age,entry.service,entry.routes)
   var next=entry.next_sample
   var reason=""
   var old: Vector3=now.position
   var target: Vector3=next.position
   var direction: Vector3=next.direction
   # Before entering the conflict area, wait for green AND a cleared junction.
   for cell in nearby_junctions(target):
    var center=TownRules.point(cell)
    center.y=old.y
    var before=Vector2(old.x-center.x,old.z-center.z).length()
    var after=Vector2(target.x-center.x,target.z-center.z).length()
    if before>=12 and after<12:
     var phase=signal_phase(state,cell,float(traffic.clock)+elapsed)
     var axis="x" if absf(direction.x)>absf(direction.z) else "z"
     if phase=="fault":
      # A failed signal has a slow alternating stop-and-go fallback. A fault
      # cannot freeze the city indefinitely while the technician is travelling.
      var fallback=fposmod(float(traffic.clock)+elapsed,40)
      phase="x" if fallback<14 else "z" if fallback>=20 and fallback<34 else "red"
     if phase!=axis: reason="Ampel · Rot" if fault_at(state,cell).is_empty() else "Ampelstörung · Wechselverkehr"; break
     for other_index in entries.size():
      if other_index==index: continue
      var other=entries[other_index]
      if other.age>=float(other.trip.get("total",INF)): continue
      var at: Vector3=other.sample.position
      if Vector2(at.x-center.x,at.z-center.z).length()<12:
       reason="Kreuzung räumt"; break
     if not reason.is_empty(): break
   if reason.is_empty() and (next.moving or entry.age<=0.001):
    for j in entries.size():
     if j==index: continue
     var other=entries[j]
     if other.age>=float(other.trip.get("total",INF)): continue
     var offset: Vector3=other.sample.position-target
     var ahead=offset.dot(direction)
     var lateral=absf(offset.dot(Vector3(direction.z,0,-direction.x)))
     var same=direction.dot(other.sample.direction)>0.6
     var gap=(float(entry.length)+float(other.length))*0.5+1.5
     if same and lateral<3.3 and (other.sample.position-old).dot(direction)>=-0.01 and ahead<gap:
      # Old saves may contain coincident trucks. The leading stable ID exits
      # first, and queued vehicles remain hidden in their loading depot.
      if ahead<0.5 and j>index: continue
      reason="Abstand halten"; break
     if j<index and not same and direction.dot(other.sample.direction)>-0.6 and offset.length()<gap*0.65 and (other.sample.position-old).dot(direction)>0:
      reason="Vorfahrt gewähren"; break
   if reason.is_empty():
    entry.age+=dt
    entry.sample=next
   else:
    entry.trip.traffic_wait=reason
    if entry.age<=0.001: entry.trip.traffic_hidden=true
  elapsed+=dt
  remaining-=dt
 for entry in entries:
  if entry.get("readonly",false): continue
  entry.trip.traffic_previous_age=entry.start
  entry.trip.traffic_delta=maxf(0,entry.age-entry.start)
  # Interpolation only follows a movement proven clear by this tick; waiting
  # vehicles do not drift through red lights during the render frames.
  entry.trip.traffic_speed=(entry.age-entry.start)/maxf(0.001,delta)
 traffic.clock=float(traffic.clock)+delta
 for fault in traffic.faults: fault.age=float(fault.age)+delta
 if traffic.enabled and state.city_services.enabled:
  traffic.fault_clock=float(traffic.fault_clock)+delta
  if float(traffic.fault_clock)>=900 and traffic.faults.is_empty():
   traffic.fault_clock=fposmod(float(traffic.fault_clock),900)
   if not crossings.is_empty(): break_signal(state,crossings[posmod(int(traffic.next_fault)-1,crossings.size())])

static func dispatch_repair(state: Dictionary, cache: Dictionary) -> bool:
 for fault in state.traffic.faults:
  if int(fault.mission)>=0: continue
  if state.city_services.missions.size()>=8: return false
  var candidates=[]
  for i in state.buildings.size():
   if state.buildings[i].kind=="garage" and not state.buildings[i].get("paused",false): candidates.append({"type":"building","index":i})
  candidates.append({"type":"entry","index":-1})
  var target={"type":"road","index":-1,"cell":fault.cell.duplicate()}
  var source={}
  var outward=[]
  for candidate in candidates:
   outward=CityServices.route(state,CityServices.location(state,candidate),CityServices.location(state,target),cache)
   if outward.size()>1: source=candidate; break
  if outward.size()<2: continue
  var repair_point=TownRules.point(TownRules.cell(fault.cell))+Vector3(-6,0.95,4.4)
  outward.append([repair_point.x,repair_point.y,repair_point.z])
  var back=outward.duplicate(true)
  back.reverse()
  var drive=maxf(2,LogisticsRoutes.length(outward)/12.0)
  var id=int(state.city_services.next_id)
  state.city_services.next_id=id+1
  state.city_services.missions.append({"id":id,"kind":"technician","source_ref":source,"target_ref":target,"destination_ref":target,"outward":outward,"second":[],"back":back,"drive":drive,"second_drive":0.0,"work":12.0,"served_at":drive+12,"total":drive*2+12,"age":0.0,"served":false,"reward":0.0,"external":source.type=="entry","repair_id":int(fault.id)})
  fault.mission=id
  return true
 return false

static func finish_repair(state: Dictionary, id: int) -> void:
 for fault in state.traffic.faults.duplicate():
  if int(fault.id)!=id: continue
  state.traffic.faults.erase(fault)
  state.traffic.repaired=int(state.traffic.repaired)+1
  UXRules.push_event(state,"repaired:%s" % id,"Techniker · Ampel repariert",TownRules.point(TownRules.cell(fault.cell)),"traffic")

static func bus_plan(state: Dictionary, line: Dictionary) -> Dictionary:
 var key=hash([state.town.roads,state.town.districts,state.town.stops,line.stops])
 if not bus_cache.has(key):
  if bus_cache.size()>32: bus_cache.clear()
  var plan=TownRules.route(state.town,line.stops)
  if not plan.is_empty():
   for leg in plan.legs:
    var encoded=[]
    for p in leg.points: encoded.append([p.x,0.95,p.y])
    leg.path=encoded
    leg.compiled=compiled(encoded)
  bus_cache[key]=plan
 return bus_cache[key]

static func bus_sample(plan: Dictionary, age: float) -> Dictionary:
 var phase=fposmod(age,float(plan.duration))
 for leg in plan.legs:
  var local=phase-float(leg.start)
  if local<0 or local>=4+float(leg.travel): continue
  var value=point_on(leg.compiled,maxf(0,local-4)/maxf(0.001,float(leg.travel)))
  value.position+=Vector3(value.direction.z,0,-value.direction.x)*LANE
  value.moving=local>=4
  return value
 return {"position":Vector3.ZERO,"direction":Vector3.BACK,"moving":false}

static func visual_age(trip: Dictionary, fraction: float, phase: bool = false, period: float = 0.0) -> float:
 var current=float(trip.phase if phase else trip.age)
 if not trip.has("traffic_previous_age"): return current
 var previous=float(trip.traffic_previous_age)
 if period>0 and previous>current: previous-=period
 # Tests and a restored older save can explicitly change the trip phase.
 if previous>current or current-previous>1.001: return current
 return lerpf(previous,current,clampf(fraction,0,1))
