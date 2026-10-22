extends Node3D
var world: Node3D
var vehicles: Dictionary={}
var people: Dictionary={}
var pools: Dictionary={}
var moving_vehicles=0
var visible_people=0
var fire_world

func _ready() -> void:
 fire_world=load("res://Components/FireWorld.gd").new()
 fire_world.world=world
 add_child(fire_world)

func recycle(table: Dictionary, present: Dictionary) -> void:
 for id in table.keys():
  if present.has(id): continue
  var node=table[id]
  node.hide()
  var key=str(node.get_meta("pool"))
  if not pools.has(key): pools[key]=[]
  if pools[key].size()<12: pools[key].append(node)
  else: node.queue_free()
  table.erase(id)

func obtain(key: String) -> Node3D:
 if pools.has(key) and not pools[key].is_empty():
  var node=pools[key].pop_back()
  node.show()
  return node
 var node: Node3D
 if key=="person": node=load("res://NPCs/Citizen.gd").new()
 else:
  node=load("res://Vehicles/ServiceVehicle.gd").new()
  node.kind=key
 node.set_meta("pool",key)
 add_child(node)
 return node

func _process(_delta: float) -> void:
 var present={}
 var folk={}
 moving_vehicles=0
 visible_people=0
 var extra=minf(Game.tick_clock,0.99)
 var limit=4 if Game.state.quality==0 else 8
 for mission in Game.state.city_services.missions.slice(0,limit):
  var id=int(mission.id)
  present[id]=true
  if not vehicles.has(id): vehicles[id]=obtain(mission.kind)
  var node: Node3D=vehicles[id]
  var sample=CityServices.sample(mission,extra)
  node.position=sample.position+Vector3(sample.direction.z,0,-sample.direction.x)*1.1
  node.rotation.y=atan2(sample.direction.x,sample.direction.z)
  node.moving=sample.moving
  node.emergency=sample.lights
  node.passenger.visible=sample.passenger
  node.visible=node.position.distance_to(world.view_focus)<world.view_zoom*1.2+25
  if node.moving: moving_vehicles+=1
  if mission.kind=="taxi" and float(mission.age)<float(mission.drive)+float(mission.work):
   var person_id=100000+id
   folk[person_id]=true
   if not people.has(person_id): people[person_id]=obtain("person")
   var person=people[person_id]
   person.route=mission.outward
   person.travel_phase=1
   person.walking=false
   person.visible=true
   visible_people+=1
 var pedestrian_limit=6 if Game.state.quality==0 else 14
 for trip in Game.state.city_services.walkers.slice(0,pedestrian_limit):
  var id=int(trip.id)
  folk[id]=true
  if not people.has(id): people[id]=obtain("person")
  var person=people[id]
  person.route=trip.path
  person.travel_phase=clampf((float(trip.age)+extra)/float(trip.total),0,1)
  person.walking=true
  person.visible=LogisticsRoutes.vector(trip.path[0]).distance_to(world.view_focus)<world.view_zoom*1.5+40
  visible_people+=1
 recycle(vehicles,present)
 recycle(people,folk)
