extends Node3D

var world: Node3D
var pair_clock=0.0
var greetings=0
var celebrations=0
var effects: Array=[]
var next_effect=0

func _ready() -> void:
 for i in 2:
  var effect=Node3D.new()
  add_child(effect)
  var confetti=CPUParticles3D.new()
  confetti.amount=32
  confetti.lifetime=2.4
  confetti.one_shot=true
  confetti.explosiveness=0.85
  confetti.direction=Vector3.UP
  confetti.spread=75
  confetti.gravity=Vector3(0,-5,0)
  confetti.initial_velocity_min=4
  confetti.initial_velocity_max=8
  confetti.angular_velocity_min=-180
  confetti.angular_velocity_max=180
  var gradient=Gradient.new()
  gradient.set_color(0,Color("ed6586"))
  gradient.set_color(1,Color(0.22,0.74,0.7,0))
  gradient.add_point(0.3,Color("f48283"))
  gradient.add_point(0.65,Color("79c8ed"))
  confetti.color_ramp=gradient
  var mesh=QuadMesh.new()
  mesh.size=Vector2(0.36,0.24)
  confetti.mesh=mesh
  var material=StandardMaterial3D.new()
  material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
  material.vertex_color_use_as_albedo=true
  material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
  material.cull_mode=BaseMaterial3D.CULL_DISABLED
  confetti.material_override=material
  confetti.emitting=false
  effect.add_child(confetti)
  var label=Models.label(effect,"",Vector3(0,14,0),40)
  label.hide()
  effects.append({"root":effect,"particles":confetti,"label":label,"left":0.0})
 Game.construction_finished.connect(on_completed)

func people() -> Array:
 var result=[]
 for child in world.actors.get_children():
  if child is TimberWorker: result.append(child)
 return result

func greet_neighbors() -> void:
 var workers=people()
 var pairs=0
 for i in workers.size():
  var a=workers[i]
  if a.role=="operator" or a.social_cooldown>0 or a.social_left>0 or a.resting: continue
  for j in range(i+1,workers.size()):
   var b=workers[j]
   if b.role=="operator" or b.social_cooldown>0 or b.social_left>0 or b.resting: continue
   var distance=a.position.distance_to(b.position)
   if distance>1 and distance<8:
    a.begin_social("wave",b.position)
    b.begin_social("wave",a.position)
    greetings+=1
    pairs+=1
    break
  if pairs>=(1 if Game.state.quality==0 else 2): break

func on_completed(point: Vector3, job_type: String) -> void:
 if not Game.state.get("ambient_enabled",true): return
 world.sync_actors()
 celebrations+=1
 world.audio.play_chime()
 var effect=effects[next_effect]
 next_effect=(next_effect+1)%effects.size()
 effect.root.position=point
 effect.left=4.5
 effect.label.text="ERÖFFNET!" if job_type in ["home","building"] else "BAUABSCHNITT GESCHAFFT!" if job_type=="project" else "AUSBAU GESCHAFFT!"
 effect.label.modulate.a=1
 effect.label.show()
 effect.particles.amount=12 if Game.state.quality==0 else 32
 effect.particles.position=Vector3(0,4,8)
 if Game.state.ux.motion: effect.particles.restart()
 effect.particles.emitting=bool(Game.state.ux.motion)
 var crowd=people()
 crowd.sort_custom(func(a,b): return a.position.distance_squared_to(point)<b.position.distance_squared_to(point))
 var cheered=0
 for worker in crowd:
  if worker.position.distance_to(point)>65: continue
  worker.begin_social("cheer",point)
  cheered+=1
  if cheered>=(2 if Game.state.quality==0 else 5): break

func _process(delta: float) -> void:
 var enabled=Game.state.get("ambient_enabled",true)
 for effect in effects:
  effect.particles.visible=enabled
  if not enabled:
   effect.left=0
   effect.particles.emitting=false
  if effect.left>0:
   effect.left=maxf(0,effect.left-delta)
   effect.label.position.y=14+(4.5-effect.left)*0.45
   effect.label.modulate.a=minf(1,effect.left)
  effect.label.visible=effect.left>0
 if not enabled: return
 pair_clock+=delta
 if pair_clock>= (3.0 if Game.state.quality==0 else 1.5):
  pair_clock=0
  greet_neighbors()
