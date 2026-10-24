extends Node3D
var world: Node3D
var clock=0.0
var previous={}
var planters={}
var pool=[]
var initialized=false

func _process(delta: float) -> void:
 clock+=delta
 if clock>=0.5:
  clock=0
  sync_trees(initialized)
  initialized=true
 update_planters(delta)

func sync_trees(falling: bool=false) -> void:
 for biome in world.trees.size():
  var cells=Game.state.forest.stands.get(str(biome),{}).get("cells",{})
  var old=previous.get(str(biome),{})
  var keys=cells.keys()
  for key in old:
   if key not in keys: keys.append(key)
  for id in keys:
   var index=int(id)
   var tree=world.trees[biome][index]
   var state=cells.get(id,{"state":"mature"})
   var stage=str(state.state)
   var before=str(old.get(id,"mature"))
   if falling and stage=="stump" and before=="mature" and not tree.blocked and not world.falling_trees.is_empty():
    world.show_falling_tree(biome,index)
    if world.spatial_audio!=null: world.spatial_audio.cut(tree.point)
   var growth=1.0
   if stage=="stump": growth=0.001
   elif stage=="growing": growth=lerpf(0.12,1,clampf(1-(float(state.ready_at)-float(Game.state.elapsed))/ForestCycle.GROW_SECONDS,0,1))
   tree.regrow=maxf(0.01,float(state.get("ready_at",Game.state.elapsed+1))-float(Game.state.elapsed)) if stage!="mature" else 0.0
   for part in 3:
    var size_value=float(tree.scale)*(0.001 if tree.blocked else growth)
    var y=[1.8,4.7,7.1][part]*size_value
    world.tree_batches[biome][part].multimesh.set_instance_transform(index,Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*size_value),tree.point+Vector3.UP*y))
   var stump_size=float(tree.scale) if stage=="stump" and not tree.blocked else 0.001
   world.stump_batches[biome].multimesh.set_instance_transform(index,Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*stump_size),tree.point+Vector3.UP*0.35*stump_size))
  var remembered={}
  for id in cells: remembered[id]=str(cells[id].state)
  previous[str(biome)]=remembered

func make_planter() -> Node3D:
 var worker=Node3D.new()
 var body=BeaverModels.create(3+planters.size(),"planter")
 body.name="Beaver"; worker.add_child(body)
 var spade=Node3D.new(); spade.name="Spade"; body.get_node("RightArm").add_child(spade)
 Models.box(spade,Vector3(0.09,1.3,0.09),Vector3(0,-0.5,0.25),Color("bd8e50"))
 Models.box(spade,Vector3(0.35,0.45,0.09),Vector3(0,-1.15,0.25),Color("a7bdbe")); Models.bake(spade)
 var tray=Node3D.new(); tray.name="SeedlingTray"; body.get_node("LeftArm").add_child(tray)
 Models.box(tray,Vector3(0.65,0.2,0.5),Vector3(0,-0.5,0.35),Color("996c42"))
 for x in [-0.2,0,0.2]: Models.cylinder(tray,0.13,0.45,Vector3(x,-0.15,0.35),Color("5ca25d"),0.02)
 Models.bake(tray)
 add_child(worker)
 return worker

func update_planters(delta: float) -> void:
 var ids={}
 var tasks=Game.state.forest.tasks.duplicate()
 tasks.sort_custom(func(a,b): return ForestLayout.point(int(a.biome),int(a.cell)).distance_squared_to(world.focus)<ForestLayout.point(int(b.biome),int(b.cell)).distance_squared_to(world.focus))
 var cutters=world.actors.get_children().filter(func(actor): return actor is TimberWorker and actor.role=="forester")
 for actor in cutters: actor.visible=true
 var keep_cutter=1 if int(Game.state.workers)>ForestCycle.busy(Game.state) else 0
 var visible_count=mini(1 if Game.state.quality==0 else 3,maxi(0,cutters.size()-keep_cutter))
 for i in mini(visible_count,tasks.size()): cutters[cutters.size()-1-i].visible=false
 for task in tasks.slice(0,visible_count):
  var id=int(task.id); ids[id]=true
  if not planters.has(id): planters[id]=pool.pop_back() if not pool.is_empty() else make_planter()
  var worker=planters[id]
  var path=ForestLayout.path(int(task.biome),int(task.cell))
  var age=float(task.age)+minf(Game.tick_clock,0.99)
  var walk=float(task.walk)
  var planting=age>=walk and age<walk+4
  var fraction=clampf(age/walk,0,1) if age<walk+4 else 1-clampf((age-walk-4)/walk,0,1)
  var sample=LogisticsRoutes.sample(LogisticsRoutes.encode(PackedVector3Array(path)),fraction)
  worker.position=sample.position+Vector3.UP*0.6
  var direction: Vector3=sample.direction*(1 if age<walk+4 else -1)
  worker.rotation.y=atan2(direction.x,direction.z)
  worker.visible=PresentationBudget.detailed(worker)
  var body=worker.get_node("Beaver")
  var motion=bool(Game.state.ux.motion)
  for entry in [["LeftLeg",0],["RightLeg",1],["LeftArm",0],["RightArm",1]]:
   var limb=body.get_node(entry[0])
   limb.rotation.x=sin(age*5+entry[1]*PI)*0.4 if motion and not planting else -0.8 if planting and entry[0].ends_with("Arm") else 0
  if planting:
   body.get_node("RightArm").rotation.x=-0.8+(sin(age*7)*0.6 if motion else 0)
   body.rotation.x=0.12
  else: body.rotation.x=0
 for id in planters.keys():
  if ids.has(id): continue
  var worker=planters[id]; worker.hide(); pool.append(worker); planters.erase(id)
