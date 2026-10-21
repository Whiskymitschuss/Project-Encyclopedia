extends Node3D
var world: Node3D
var animals=[]
var clock=0.0
var scan_clock=0.0

func _ready() -> void:
 for i in 9:
  var node=Node3D.new()
  var bird=i<6
  add_child(node)
  if bird:
   Models.cylinder(node,0.22,0.7,Vector3.ZERO,Color("d9caa5"),0.12).rotation.x=PI/2
   for side in [-1,1]:
    var wing=Models.box(node,Vector3(0.9,0.09,0.36),Vector3(side*0.52,0,0),Color("647f80"))
    wing.set_meta("animated",true)
    wing.name="WingLeft" if side<0 else "WingRight"
  else:
   Models.box(node,Vector3(0.65,0.5,1.05),Vector3(0,0.5,0),Color("d5b998"))
   Models.box(node,Vector3(0.5,0.5,0.5),Vector3(0,0.8,0.5),Color("ddcbb1"))
   for side in [-1,1]: Models.box(node,Vector3(0.13,0.7,0.17),Vector3(side*0.15,1.3,0.5),Color("d5b998"))
   Models.box(node,Vector3(0.3,0.3,0.3),Vector3(0,0.55,-0.55),Color("eee1cd"))
  Models.bake(node)
  animals.append({"node":node,"bird":bird,"anchor":Vector3.ZERO,"biome":0,"flee":0.0,"phase":i*1.7,"direction":Vector3.RIGHT,"valid":false})
 relocate()
 Game.rebuild_world.connect(relocate)
 Game.harvested.connect(on_cut)

func safe(at: Vector3) -> bool:
 for plot in world.street_context.get("plots",[]):
  if plot.grow(2).has_point(Vector2(at.x,at.z)): return false
 return not world.street_context.get("cells",{}).has(Vector2i(roundi(at.x/4)*4,roundi(at.z/4)*4))

func relocate() -> void:
 for i in animals.size():
  var animal=animals[i]
  var biome=mini(int(Game.state.biome),world.trees.size()-1)
  animal.valid=false
  var records=world.trees[biome]
  for j in records.size():
   var record=records[(i*13+j*7)%records.size()]
   var at=record.point+Vector3(2,0,2)
   if record.blocked or not safe(at) or not safe(at+Vector3(3,0,3)) or not safe(at-Vector3(3,0,3)): continue
   animal.valid=true
   animal.anchor=at
   animal.biome=biome
   break
  animal.node.position=animal.anchor+Vector3.UP*(19 if animal.bird else 0)

func on_cut(biome: int,_amount: float) -> void:
 for animal in animals:
  if animal.biome==biome: animal.flee=3.0

func _process(delta: float) -> void:
 var motion=bool(Game.state.ux.motion)
 var enabled=bool(Game.state.ambient_enabled)
 if motion and enabled: clock+=delta
 scan_clock+=delta
 if scan_clock>=0.4:
  scan_clock=0
  for animal in animals:
   if animal.biome!=int(Game.state.biome): relocate(); break
  if enabled:
   for animal in animals:
    for worker in world.actors.get_children():
     if worker.get("role")=="forester" and worker.position.distance_to(animal.anchor)<12:
      animal.flee=2.5
      var away=animal.anchor-worker.position
      if away.length_squared()>0.01: animal.direction=away.normalized()
      break
 for i in animals.size():
  var a=animals[i]
  var allowed=Game.state.quality!=0 or i<3 or i==6
  a.node.visible=enabled and a.valid and allowed and a.anchor.distance_to(world.view_focus)<world.view_zoom*1.3+35
  if not enabled or not motion: continue
  a.flee=maxf(0,float(a.flee)-delta)
  var phase=clock+float(a.phase)
  if a.bird:
   a.node.position=a.anchor+Vector3(cos(phase*0.4)*5,19+sin(phase*0.6)*1.3+(3-a.flee if a.flee>0 else 0),sin(phase*0.4)*4)
   a.node.rotation.y=-phase*0.4
   a.node.get_node("WingLeft").rotation.z=sin(phase*(16 if a.flee>0 else 8))*0.5
   a.node.get_node("WingRight").rotation.z=-sin(phase*(16 if a.flee>0 else 8))*0.5
  else:
   var speed=2.7 if a.flee>0 else 0.55
   var offset=Vector3(sin(phase*speed)*2,0,cos(phase*speed)*2)
   if not safe(a.anchor+offset): offset=Vector3.ZERO
   a.node.position=a.anchor+offset+Vector3.UP*absf(sin(phase*speed*3))*0.35
   a.node.rotation.y=atan2(cos(phase*speed),-sin(phase*speed))
