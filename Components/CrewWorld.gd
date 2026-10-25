extends Node3D

var world: Node3D
var vans={}
var waiting={}
var pool=[]

func _process(delta: float) -> void:
 var present={}
 for mission in Game.state.crew.missions:
  var id=int(mission.id)
  present[id]=true
  if not vans.has(id):
   var van=pool.pop_back() if not pool.is_empty() else VehicleBlueprints.crew_van()
   if van.get_parent()==null: add_child(van)
   vans[id]=van
  var van=vans[id]
  var running=float(mission.get("depart_in",0))<=0
  van.visible=running
  var age=float(mission.age)+minf(Game.tick_clock,0.99) if running else float(mission.age)
  if not mission.arrived: age=minf(age,float(mission.travel)-0.000001)
  var returning=mission.arrived
  var fraction=clampf((age-float(mission.load))/float(mission.drive),0,1)
  if returning: fraction=1-clampf((age-float(mission.travel))/float(mission.drive),0,1)
  var sample=LogisticsRoutes.presentation_sample(mission.path,fraction)
  var direction: Vector3=-sample.direction if returning else sample.direction
  van.position=sample.position+Vector3(direction.z,0,-direction.x)*1.5
  van.position.y=StreetSurface.ROAD_Y+0.02
  if direction.length_squared()>0.001: van.rotation.y=lerp_angle(van.rotation.y,atan2(direction.x,direction.z),minf(1,delta*9))
  van.moving=running and fraction>0 and fraction<1
  van.people=int(mission.workers) if (mission.kind=="dropoff" and not returning) or (mission.kind=="pickup" and returning) else 0
  van.door_open=1.0 if age<float(mission.load) or (age>=float(mission.load)+float(mission.drive) and not returning) else 0.0
 for id in vans.keys():
  if present.has(id): continue
  var van=vans[id]
  van.hide()
  van.people=0
  van.moving=false
  if pool.size()<2: pool.append(van)
  else: van.queue_free()
  vans.erase(id)
 # Finished sites keep their actual returning team in view until pickup.
 var teams={}
 for id in Game.state.crew.assignments:
  var team=Game.state.crew.assignments[id]
  if int(team.onsite)<=0 or not CrewTransport.find_job(Game.state,int(id)).is_empty(): continue
  teams[id]=true
  if not waiting.has(id):
   var group=Node3D.new()
   add_child(group)
   waiting[id]=group
   for i in mini(int(team.onsite),2 if Game.state.quality==0 else 5):
    var beaver=BeaverModels.create(posmod(i+int(id),10),"industry")
    group.add_child(beaver)
    beaver.position=Vector3(-4+i*1.5,0.6,9)
    var box=WorkTools.toolbox(beaver)
    box.position=Vector3(0.8,0.7,0.5)
  waiting[id].position=LogisticsRoutes.vector(team.point)
  for i in waiting[id].get_child_count(): waiting[id].get_child(i).visible=i<int(team.onsite)
 for id in waiting.keys():
  if not teams.has(id): waiting[id].queue_free(); waiting.erase(id)
