extends Node3D
var world
var selection={}
var show_routes=true
var signature=""
var route_root: Node3D
var pulses=[]
var clock=0.0
func _ready() -> void:
 route_root=Node3D.new()
 add_child(route_root)
 Game.shipment_delivered.connect(delivery_pulse)
func choose(value: Dictionary) -> void:
 selection=value.duplicate(true)
 signature=""
 refresh()
func trip_domain(s: Dictionary) -> String:
 return "central" if s.target in ["central","express"] else "construction" if s.target=="construction" else "stone" if s.target=="mineral" else "export" if s.target=="export" else "wood"
func trips() -> Array:
 return FreightFlow.all_trips(Game.state)
func matches(s: Dictionary) -> bool:
 if selection.is_empty(): return false
 match str(selection.get("kind","")):
  "job": return s.target=="construction" and int(s.job)==int(selection.id)
  "truck": return trip_domain(s)==selection.domain and int(s.id)==int(selection.id)
  "building":
   var index=int(selection.index)
   if int(s.get("origin",-1))==index or int(s.get("dock",-1))==index or int(s.get("destination",-2))==index: return true
   for kind in Game.state.delivery.nodes:
    if int(Game.state.delivery.nodes[kind])==index and (s.source==kind or s.target==kind): return true
 return false
func refresh() -> void:
 if route_root==null: return
 var paths=[]
 var point: Variant=null
 if not selection.is_empty():
  match str(selection.kind):
   "building":
    if int(selection.index)<Game.state.buildings.size(): point=Game.building_position(int(selection.index))
   "home":
    if int(selection.index)<Game.state.homes.size(): point=Game.home_position(int(selection.index))
   "job":
    for job in Game.state.jobs:
     if int(job.get("id",-1))==int(selection.id): point=ConstructionRules.job_position(Game.state,job)
   "group":
    for group in Game.state.ux.groups:
     if int(group.id)==int(selection.id):
      var b=group.bounds
      point=Vector3(float(b[0])+float(b[2])/2,0,float(b[1])+float(b[3])/2)
  if show_routes:
   for s in trips():
    if matches(s): paths.append(s.path)
 var current=str(hash([selection,paths,point,show_routes]))
 if current==signature: return
 signature=current
 for child in route_root.get_children(): route_root.remove_child(child); child.queue_free()
 if point!=null:
  var extent=Vector2(20,24)
  if selection.kind=="building":
   var building=Game.state.buildings[int(selection.index)]
   extent=Placement.size_for(int(building.get("rotation",0)),str(building.kind))+Vector2.ONE
  if selection.kind=="group":
   for group in Game.state.ux.groups:
    if int(group.id)==int(selection.id): extent=Vector2(float(group.bounds[2]),float(group.bounds[3]))
  for sign_value in [-1,1]:
   Models.box(route_root,Vector3(extent.x,0.14,0.35),point+Vector3(0,0.9,sign_value*extent.y/2),Color("ffe18c"))
   Models.box(route_root,Vector3(0.35,0.14,extent.y),point+Vector3(sign_value*extent.x/2,0.9,0),Color("ffe18c"))
 for path in paths:
  for i in range(1,path.size()):
   var a=LogisticsRoutes.vector(path[i-1])+Vector3(0,0.35,0)
   var b=LogisticsRoutes.vector(path[i])+Vector3(0,0.35,0)
   var segment=Models.box(route_root,Vector3(0.35,0.12,maxf(0.01,a.distance_to(b))),(a+b)/2,Color("ffe293"))
   segment.rotation.y=atan2(b.x-a.x,b.z-a.z)
 Models.bake(route_root)
func delivery_pulse(at: Vector3,key: String,amount: float) -> void:
 if not Game.state.ux.motion or world.camera.is_position_behind(at) or world.zoom>200: return
 var node: Node3D
 if pulses.size()>=12:
  var entry=pulses.pop_front()
  node=entry.node
  node.queue_free()
 node=Node3D.new()
 add_child(node)
 node.position=at
 var mark=Models.label(node,"+%s %s" % [Catalog.number(amount),Catalog.RESOURCES[key]],Vector3(0,5,0),32)
 mark.pixel_size=0.065
 mark.modulate=Color("fff2a1")
 pulses.append({"node":node,"age":0.0,"label":mark})
func _process(delta: float) -> void:
 clock+=delta
 if clock>=0.5: clock=0; refresh()
 for entry in pulses.duplicate():
  entry.age+=delta
  entry.node.position.y+=delta*1.5
  entry.label.modulate.a=clampf(1-float(entry.age)/1.8,0,1)
  if float(entry.age)>=1.8: entry.node.queue_free(); pulses.erase(entry)
func pick_truck(screen: Vector2) -> Dictionary:
 if world.delivery_world==null or world.zoom>190: return {}
 var best={}
 var distance=24.0
 for s in trips():
  var key=world.delivery_world.visual_key(s)
  if not world.delivery_world.visuals.has(key): continue
  var node=world.delivery_world.visuals[key]
  if world.camera.is_position_behind(node.global_position): continue
  var d=screen.distance_to(world.camera.unproject_position(node.global_position+Vector3(0,2,0)))
  if d<distance: distance=d; best={"kind":"truck","domain":trip_domain(s),"id":int(s.id)}
 return best
