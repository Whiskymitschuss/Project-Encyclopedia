extends Node3D

# A bounded visual handler for the actual output of an active workshop.
# It never creates cargo, changes stock or awards money.
var building_index=-1
var depot_handler=true
var handler_lane=0
var handler_lanes=1
var cycle_trip={}
var cycle_route=[]
var cycle_legs=[]
var payload_variants={}
var cycle_loading=false
var cycle_key="boards"
var cycle_running=false
var phase=0.0
var active=false
var presentation_enabled=true
var travelled=0.0
var wheels=[]
var forks: Node3D
var payload: Node3D
var chassis: Node3D
var operator: Node3D
var points=[Vector3(8,0.6,8),Vector3(6,0.6,5),Vector3(3.5,0.6,8),Vector3(8,0.6,8),Vector3(8,0.6,8)]

func _ready() -> void:
 position=points[0]
 chassis=Node3D.new()
 chassis.scale=Vector3.ONE*0.75
 add_child(chassis)
 Models.box(chassis,Vector3(1.5,0.9,2),Vector3(0,0.85,0),Color("efad31"))
 Models.box(chassis,Vector3(1.2,0.6,0.6),Vector3(0,1.5,-0.6),Color("363c46"))
 for x in [-0.64,0.64]:
  for z in [-0.65,0.65]:
   var wheel=Node3D.new()
   chassis.add_child(wheel)
   wheel.position=Vector3(x,0.45,z)
   var tire=Models.cylinder(wheel,0.4,0.25,Vector3.ZERO,Color("354047"))
   tire.rotation.z=PI/2
   Models.bake(wheel)
   wheels.append(wheel)
 for x in [-0.6,0.6]:
  Models.box(chassis,Vector3(0.12,2.3,0.12),Vector3(x,2,0),Color("34434a"))
 Models.box(chassis,Vector3(1.5,0.15,1.6),Vector3(0,3.1,0),Color("efad31"))
 operator=BeaverModels.driver(chassis,Vector3(0,1.28,-0.12),0.59,posmod(hash(str(get_parent().get_meta("kind","sawmill")))+handler_lane,10))
 for x in [-0.5,0.5]: Models.box(chassis,Vector3(0.12,2.8,0.12),Vector3(x,1.6,1.05),Color("34434a"))
 forks=Node3D.new()
 chassis.add_child(forks)
 for x in [-0.5,0.5]: Models.box(forks,Vector3(0.16,0.12,1.4),Vector3(x,0.25,1.6),Color("647179"))
 payload=Node3D.new()
 payload.position=Vector3(0,0.42,1.6)
 forks.add_child(payload)
 var key="boards" if depot_handler else str(Catalog.RECIPES[get_parent().get_node("Processing").kind].out.keys()[0])
 if key in ["furniture","design"]:
  Models.box(payload,Vector3(1.8,0.3,1.8),Vector3(0,1.0,0),Color("c99459"))
  Models.box(payload,Vector3(1.8,1.5,0.2),Vector3(0,1.8,-0.7),Color("c99459"))
  for x in [-0.65,0.65]:
   for z in [-0.65,0.65]: Models.box(payload,Vector3(0.2,0.9,0.2),Vector3(x,0.45,z),Color("ad7947"))
 elif key in ["paper","pellets"]:
  Models.box(payload,Vector3(2,1.8,2.2),Vector3(0,0.9,0),Color("eddfb6"))
 else:
  for i in 3: Models.box(payload,Vector3(0.65,0.3,3.6),Vector3((i-1)*0.78,0.3,0),Color("c99459"))
 payload.scale=Vector3.ONE*0.45
 Models.bake(payload)
 if depot_handler:
  var boards=Node3D.new()
  payload.add_child(boards)
  for child in payload.get_children():
   if child!=boards: payload.remove_child(child); boards.add_child(child)
  payload_variants.boards=boards
  for key_name in ["wood","furniture","crates"]:
   var variant=Node3D.new()
   payload.add_child(variant)
   if key_name=="wood":
    for side in [-0.5,0.5]:
     var log=Models.cylinder(variant,0.4,3.2,Vector3(side,0.4,0),Color("976439"))
     log.rotation.x=PI/2
   elif key_name=="furniture":
    Models.box(variant,Vector3(1.8,0.3,1.8),Vector3(0,1,0),Color("dba85e"))
    Models.box(variant,Vector3(1.8,1.4,0.2),Vector3(0,1.7,-0.7),Color("dba85e"))
    for side in [-0.6,0.6]: Models.box(variant,Vector3(0.2,1,1.6),Vector3(side,0.5,0),Color("a27644"))
   else: Models.box(variant,Vector3(2,1.4,2),Vector3(0,0.7,0),Color("d0b27c"))
   Models.bake(variant)
   variant.hide()
   payload_variants[key_name]=variant
  var stone=CargoModels.create(payload,"stone")
  stone.hide()
  payload_variants.stone=stone
 Models.bake(forks)
 Models.bake(chassis)
 payload.hide()

func _process(delta: float) -> void:
 var machine=get_parent().get_node_or_null("Processing")
 if machine==null and not depot_handler: return
 var camera=get_viewport().get_camera_3d()
 var close=camera!=null and camera.global_position.distance_to(global_position)<260
 visible=close and presentation_enabled
 var index=building_index if depot_handler else int(machine.building_index)
 active=visible and index>=0 and float(Game.flow.get("building:%s" % index,0))>0 and not Game.state.buildings[index].get("paused",false) and not (Game.delivery_owns(index) and Game.state.delivery.paused)
 if depot_handler:
  active=false
  for trip in FreightFlow.all_trips(Game.state):
   if float(trip.get("depart_in",0))>0: continue
   if posmod(int(trip.id),handler_lanes)!=handler_lane: continue
   if cycle_running and int(cycle_trip.get("id",-1))!=int(trip.id): continue
   var stage=CargoTransfer.phase(trip,float(trip.age)+minf(Game.tick_clock,0.99))
   if not CargoTransfer.has_forklift(Game.state,trip,stage.kind=="load"): continue
   if stage.kind in ["load","unload"] and CargoTransfer.dock(Game,trip,stage.kind=="load").distance_to(get_parent().global_position)<1:
    active=visible
    if not cycle_running:
     cycle_trip=trip
     phase=0
     cycle_loading=stage.kind=="load"
     var sample=LogisticsRoutes.sample(trip.path,0 if cycle_loading else 1)
     var at=get_parent().to_local(sample.position)
     var extent=Placement.size_for(0,str(get_parent().get_meta("kind","")))/2-Vector2.ONE*1.4
     var bay=Vector3(clampf(at.x,-extent.x,extent.x),0.6,clampf(at.z,-extent.y,extent.y))
     var rack=points[1]
     if get_parent().has_node("Processing"):
      rack=Vector3(6.3,0.6,5.5) if cycle_loading else Vector3(-6.3,0.6,-4.5)
     elif str(get_parent().get_meta("kind",""))=="stoneworks": rack=Vector3(6.6,0.6,7) if cycle_loading else Vector3(-6,0.6,-6)
     cycle_route=[points[0],rack if cycle_loading else bay,bay if cycle_loading else rack,points[0],points[0]]
     cycle_legs=[]
     if get_parent().has_node("Processing"):
      for leg in 4: cycle_legs.append(YardRoutes.route(cycle_route[leg],cycle_route[leg+1]))
     cycle_key=str(trip.key)
     if cycle_key not in ["wood","boards","furniture","stone"]: cycle_key="crates"
    break
 if active: cycle_running=true
 if not cycle_running: return
 var transferred=false
 if depot_handler and not cycle_trip.is_empty():
  transferred=bool(cycle_trip.get("arrived",false)) if not cycle_loading else float(cycle_trip.age)>=float(cycle_trip.get("load",0))
  var present=false
  for trip in FreightFlow.all_trips(Game.state):
   if int(trip.id)==int(cycle_trip.id): present=true; break
  transferred=transferred or not present
 if not Game.state.ux.motion or not Game.state.ambient_enabled:
  # Freeze movement, but never retain a phantom pallet after its real handoff.
  if transferred: payload.hide()
  return
 if not depot_handler and index>=0 and Game.state.buildings[index].get("paused",false): return
 if not depot_handler and Game.delivery_owns(index) and Game.state.delivery.paused: return
 if depot_handler and not cycle_trip.is_empty():
  # The load remains on the forks until the authoritative transfer completes.
  # Full storage holds it here; hidden/reduced-motion views never book goods.
  if transferred:
   phase=maxf(phase,2.05)+delta*0.6
  else:
   var progress=CargoTransfer.phase(cycle_trip,float(cycle_trip.age)+minf(Game.tick_clock,0.99))
   var fraction=float(progress.progress)
   if not cycle_loading and float(cycle_trip.age)>=float(cycle_trip.travel): fraction=1.0
   phase=minf(2.04,fraction*2.05)
 else: phase+=delta*0.6
 if phase>=4:
  phase=0
  cycle_running=false
  cycle_trip={}
  position=points[0]
  payload.hide()
  return
 var segment=floori(phase)
 var route=cycle_route if depot_handler and not cycle_route.is_empty() else points
 var sample=YardRoutes.sample(cycle_legs[segment],fposmod(phase,1)) if not cycle_legs.is_empty() else {"position":route[segment].lerp(route[segment+1],fposmod(phase,1)),"direction":route[segment+1]-route[segment]}
 var target: Vector3=sample.position
 var distance=position.distance_to(target)
 travelled+=distance
 position=target
 var direction: Vector3=sample.direction
 rotation.y=atan2(direction.x,direction.z)
 for wheel in wheels: wheel.rotation.x+=distance/0.4
 forks.position.y=0.12+0.25*sin(fposmod(phase,1)*PI)
 if depot_handler:
  for key_name in payload_variants: payload_variants[key_name].visible=key_name==cycle_key
  # Loading: rack → bay; unloading: bay → rack. Return is always empty.
  # Both cycles start and finish at the same parking bay.
 payload.visible=phase>=1.0 and phase<2.05
 operator.rotation.z=sin(travelled*0.8)*0.035
