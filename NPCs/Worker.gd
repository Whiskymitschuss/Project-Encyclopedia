class_name TimberWorker
extends Node3D

var origin_point = Vector3.ZERO
var destination = Vector3.ZERO
var phase = 0.0
var pace = 1.0
var role = "forester"
var variant_id = -1
var production_index = -1
var facing = 0.0
var working = false
var body: Node3D
var pack: Node3D
var limbs: Array = []
var social_left=0.0
var social_kind=""
var social_facing=0.0
var social_cooldown=0.0
var resting=false
var rest_via=Vector3.ZERO
var mug: Node3D
var axe: Node3D
var work_left=0.0
var handling=false
var forest_route=[]
var forest_cell=-1
var forest_slot=0
var forest_count=1
var forest_configured=false
var forest_round=-1
var forest_relocation=[]
var forest_relocation_at=0.0


func _ready() -> void:
 position=origin_point+Vector3(0,0.6,0)
 if variant_id<0: variant_id=posmod(roundi(origin_point.x*3+origin_point.z)+production_index,10)
 var profession="forester" if role=="forester" else "industry" if role in ["operator","construction"] else "civilian"
 body=BeaverModels.create(variant_id,profession)
 add_child(body)
 for part_name in ["LeftLeg","RightLeg","LeftArm","RightArm"]: limbs.append(body.get_node(part_name))
 mug=Node3D.new()
 limbs[2].add_child(mug)
 Models.cylinder(mug,0.16,0.28,Vector3(0,-0.77,0.2),Color("fff0ce"))
 Models.cylinder(mug,0.12,0.02,Vector3(0,-0.62,0.2),Color("6c4938"))
 Models.box(mug,Vector3(0.1,0.14,0.2),Vector3(0.18,-0.76,0.2),Color("fff0ce"))
 mug.hide()
 pack=Node3D.new()
 body.add_child(pack)
 if role=="forester":
  Models.log_pile(pack,Vector3(-0.6,1,-0.8),2)
  pack.scale=Vector3.ONE*0.45
  pack.position=Vector3(0,1.05,-0.2)
 if role=="forester":
  axe=Node3D.new()
  limbs[3].add_child(axe)
  Models.box(axe,Vector3(0.12,1.1,0.12),Vector3(0,-0.6,0.35),Color("a97542"))
  Models.box(axe,Vector3(0.6,0.36,0.12),Vector3(0.2,-0.1,0.35),Color("b6c4ca"))
  Models.bake(axe)
 Models.bake(body)
 if role=="forester":
  # The bounded hired crew must not disappear just because an orthographic
  # camera moves backwards while zooming out. Frustum culling still applies.
  for mesh in body.find_children("*","MeshInstance3D",true,false): mesh.visibility_range_end=0

func _process(delta: float) -> void:
 if not Game.state.ux.motion: return
 handling=false
 if axe!=null: axe.hide()
 social_cooldown=maxf(0,social_cooldown-delta)
 body.position=Vector3.ZERO
 body.rotation.z=0
 mug.hide()
 resting=false
 for limb in limbs: limb.rotation=Vector3.ZERO
 if not Game.state.get("ambient_enabled",true): social_left=0
 if social_left>0:
  social_left=maxf(0,social_left-delta)
  body.rotation.y=social_facing
  if social_kind=="cheer": pack.hide()
  if social_kind=="cheer":
   body.position.y=absf(sin(social_left*6))*0.2
   for i in [2,3]: limbs[i].rotation.x=-2.5+sin(social_left*8+i)*0.3
  else:
   limbs[3].rotation.x=-2.3
   limbs[3].rotation.z=sin(social_left*10)*0.35
  return
 if role=="neighbor":
  neighbor_step(delta)
  return
 if role=="operator":
  working=production_index>=0 and production_index<Game.state.buildings.size() and not Game.state.buildings[production_index].get("paused",false) and float(Game.flow.get("building:%s" % production_index,0))>0
  if working: phase+=delta*pace*3
  position=origin_point+Vector3(0,0.6,0)
  body.rotation.y=facing
  for i in [2,3]: limbs[i].rotation.x=-0.8+sin(phase+(i%2)*PI)*0.35 if working else -0.1
  return
 if role=="forester":
  var rate=float(Game.flow.get("harvest:%s" % production_index,Game.flow.get("harvest",0)))
  if float(Game.flow.get("harvest",0))<=0: rate=0
  if production_index>=0 and Game.state.buildings[production_index].get("paused",false): rate=0
  if forest_configured:
   var round_value=floori(phase/18.0)
   if rate>0 and (round_value!=forest_round or forest_route.is_empty()):
    forest_round=round_value
    var cell=Game.state.forest.stands.get(str(int(Game.state.biome)),{}).get("cells",{}).get(str(forest_cell),{"state":"mature"})
    if forest_cell<0 or cell.state!="mature": relocate_forest()
   if not forest_relocation.is_empty():
    forest_relocation_at=minf(1,forest_relocation_at+delta*6/maxf(1,LogisticsRoutes.length(forest_relocation)))
    var step=LogisticsRoutes.sample(forest_relocation,forest_relocation_at)
    position=step.position+Vector3.UP*0.6
    body.rotation.y=atan2(step.direction.x,step.direction.z)
    for i in limbs.size(): limbs[i].rotation.x=sin(forest_relocation_at*LogisticsRoutes.length(forest_relocation)+(i%2)*PI)*0.4
    working=false; pack.hide()
    if forest_relocation_at>=1: forest_relocation=[]
    return
   if forest_route.is_empty():
    working=false; work_left=0; pack.hide(); return
  if rate>0: work_left=maxf(work_left,18.0-fposmod(phase,18.0))
  if work_left<=0:
   working=false
   handling=production_index>=0 and ForestryFlow.loading(Game.state,production_index)
   if handling:
    phase+=delta*pace
    var hauling=fposmod(phase,12.0)
    var progress=hauling/6 if hauling<6 else (12-hauling)/6
    position=forest_position(smoothstep(0,1,progress))+Vector3.UP*0.6
    var direction=forest_direction(progress)
    body.rotation.y=atan2(direction.x,direction.z)+(PI if hauling>=6 else 0)
    for i in limbs.size(): limbs[i].rotation.x=sin(phase*5+(i%2)*PI)*0.4
    pack.visible=hauling<6
   else: pack.hide()
   return
  work_left=maxf(0,work_left-delta*pace*Game.boost("workers"))
 phase+=delta*pace*Game.boost("workers")
 var cycle=fmod(phase,18.0)
 var travel=clampf((cycle-3)/6,0,1) if cycle<11 else 1-clampf((cycle-11)/7,0,1)
 position=forest_position(smoothstep(0,1,travel)) if role=="forester" else origin_point.lerp(destination,smoothstep(0,1,travel))
 position.y=0.6+absf(sin(phase*5))*0.09 if cycle>=3 else 0.6
 var direction=forest_direction(travel) if role=="forester" else destination-origin_point
 body.rotation.y=atan2(direction.x,direction.z)+(PI if cycle>=11 else 0)
 if role=="forester" and cycle<3: body.rotation.y=facing
 for i in limbs.size(): limbs[i].rotation.x=sin(phase*5+(i%2)*PI)*0.45 if cycle>=3 else 0
 if role=="forester":
  working=cycle<3
  axe.visible=working
  pack.visible=cycle>=3 and cycle<10
  if working:
   limbs[3].rotation.x=-1.2+sin(phase*8)*0.75
   body.rotation.z=sin(phase*8)*0.06
 else: pack.hide()

func begin_social(kind: String, towards: Vector3) -> void:
 social_kind=kind
 social_left=3.5 if kind=="cheer" else 1.4
 social_cooldown=25
 social_facing=atan2(towards.x-position.x,towards.z-position.z)

func neighbor_step(delta: float) -> void:
 phase+=delta*pace
 var cycle=fmod(phase,28.0)
 pack.hide()
 if cycle<9:
  position=rest_route(cycle/9.0)+Vector3(0,0.6,0)
  body.rotation.y=atan2(destination.x-origin_point.x,destination.z-origin_point.z)
 elif cycle<16:
  position=destination+Vector3(0,0.6,0)
  body.rotation.y=facing
  if Game.state.get("ambient_enabled",true):
   resting=true
   body.position.y=-0.55
   for i in [0,1]: limbs[i].rotation.x=-1.4
   limbs[2].rotation.x=-1.75-0.3*sin(cycle*1.6)
   mug.show()
 elif cycle<25:
  position=rest_route(1-(cycle-16)/9.0)+Vector3(0,0.6,0)
  body.rotation.y=atan2(origin_point.x-destination.x,origin_point.z-destination.z)
 else:
  position=origin_point+Vector3(0,0.6,0)
  body.rotation.y=facing
 if not resting and (cycle<9 or cycle>=16 and cycle<25):
  for i in limbs.size(): limbs[i].rotation.x=sin(phase*5+(i%2)*PI)*0.4

func rest_route(amount: float) -> Vector3:
 if amount<0.55: return origin_point.lerp(rest_via,smoothstep(0,1,amount/0.55))
 return rest_via.lerp(destination,smoothstep(0,1,(amount-0.55)/0.45))

func configure_forest(slot: int,count: int) -> void:
 forest_configured=true; forest_slot=slot; forest_count=count
 var site=ForestLayout.worksite(Game.state,slot,count)
 if site.is_empty():
  forest_cell=-1; forest_route=[]
  origin_point=ForestryFlow.work_position(Game.state); destination=origin_point
 else:
  forest_cell=int(site.cell); forest_route=site.route
  origin_point=site.origin; destination=site.landing
 if forest_cell>=0:
  var direction=ForestLayout.point(int(Game.state.biome),forest_cell)-origin_point
  facing=atan2(direction.x,direction.z)
 else: facing=PI

func forest_position(progress: float) -> Vector3:
 if forest_route.is_empty(): return origin_point.lerp(destination,progress)
 return LogisticsRoutes.sample(forest_route,progress).position

func relocate_forest() -> void:
 var previous=forest_route.duplicate(true)
 var start=position-Vector3.UP*0.6
 configure_forest(forest_slot,forest_count)
 if forest_route.is_empty(): return
 var points=[start]
 # Adjacent trees in the same cleared row share their narrow work aisle.
 if previous.size()>=4 and absf(start.z-origin_point.z)<1.5 and signf(start.x-Catalog.biome_position(int(Game.state.biome)).x)==signf(origin_point.x-Catalog.biome_position(int(Game.state.biome)).x):
  points.append(origin_point)
  forest_relocation=LogisticsRoutes.encode(PackedVector3Array(points)); forest_relocation_at=0
  return
 if previous.size()>=4:
  var nearest=0; var distance=INF
  for i in previous.size():
   var candidate=start.distance_squared_to(LogisticsRoutes.vector(previous[i]))
   if candidate<distance: distance=candidate; nearest=i
  if nearest<=3:
   for i in range(nearest,4): points.append(LogisticsRoutes.vector(previous[i]))
  else:
   for i in range(nearest,2,-1): points.append(LogisticsRoutes.vector(previous[i]))
 else: points.append(LogisticsRoutes.vector(forest_route[3]))
 var arrival=forest_route.slice(0,4); arrival.reverse()
 for raw in arrival: points.append(LogisticsRoutes.vector(raw))
 forest_relocation=LogisticsRoutes.encode(PackedVector3Array(points)); forest_relocation_at=0

func forest_direction(progress: float) -> Vector3:
 return LogisticsRoutes.sample(forest_route,progress).direction if not forest_route.is_empty() else (destination-origin_point).normalized()
