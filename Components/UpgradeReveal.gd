extends Node3D
var world: Node3D
var pool=[]
var next_effect=0

func _ready() -> void:
 for i in 4:
  var root=Node3D.new()
  add_child(root)
  var scaffold=Node3D.new()
  root.add_child(scaffold)
  for x in [-8.6,8.6]:
   for z in [-10.4,10.4]: Models.box(scaffold,Vector3(0.2,6,0.2),Vector3(x,3,z),Color("c6c3a8"))
   for y in [2,4,6]: Models.box(scaffold,Vector3(0.15,0.16,21),Vector3(x,y,0),Color("e3bb72"))
  for z in [-10.4,10.4]:
   for y in [2,4,6]: Models.box(scaffold,Vector3(17.4,0.16,0.15),Vector3(0,y,z),Color("e3bb72"))
  Models.bake(scaffold)
  var dust=FeedbackFX.emitter("dust",20,true)
  dust.emission_shape=CPUParticles3D.EMISSION_SHAPE_BOX
  dust.emission_box_extents=Vector3(7,0.4,8)
  dust.position.y=1.5
  root.add_child(dust)
  pool.append({"root":root,"scaffold":scaffold,"dust":dust,"model":null,"age":3.0,"height":7.0})
  root.hide()
 Game.construction_finished.connect(reveal)

func restore(e: Dictionary) -> void:
 if is_instance_valid(e.model) and e.model.is_inside_tree(): e.model.scale=Vector3.ONE
 e.model=null

func reveal(point: Vector3,_type: String) -> void:
 if not Game.state.ux.motion or not Game.state.ambient_enabled: return
 var model=null
 for child in world.world_buildings.get_children():
  if child.position.distance_to(point)<0.1 and child.has_meta("quality_tier"): model=child; break
 if model==null: return
 var e=pool[next_effect]
 next_effect=(next_effect+1)%pool.size()
 restore(e)
 e.model=model
 e.age=0.0
 e.height=minf(20,float(model.get_meta("height",7)))
 e.root.position=point
 e.root.rotation=model.rotation
 e.model.scale.y=0.88
 e.dust.amount=8 if Game.state.quality==0 else 20
 e.dust.restart()
 e.dust.emitting=true
 e.root.show()

func _process(delta: float) -> void:
 for e in pool:
  e.age+=delta
  var enabled=Game.state.ux.motion and Game.state.ambient_enabled
  if not enabled or e.age>=1.8:
   restore(e)
   e.root.hide()
   e.dust.emitting=false
   continue
  var t=smoothstep(0,0.85,float(e.age))
  if is_instance_valid(e.model): e.model.scale.y=lerpf(0.88,1,t)
  e.scaffold.visible=e.age<0.85
  e.scaffold.scale.y=maxf(0.001,(1-t)*float(e.height)/6.0)
  e.root.visible=e.root.position.distance_to(world.view_focus)<world.view_zoom*1.6+40

func _exit_tree() -> void:
 for e in pool: restore(e)
