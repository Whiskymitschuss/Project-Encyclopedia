extends Node3D
var world: Node3D
var pool=[]
var next_effect=0

func _ready() -> void:
 for i in 4:
  var root=Node3D.new()
  add_child(root)
  var coins=FeedbackFX.emitter("coin",18,true)
  coins.position.y=3
  root.add_child(coins)
  var mist=FeedbackFX.emitter("steam",12,true)
  mist.position.y=5
  root.add_child(mist)
  var ring=MeshInstance3D.new()
  var mesh=TorusMesh.new()
  mesh.inner_radius=2.8
  mesh.outer_radius=3.0
  mesh.rings=16
  mesh.ring_segments=5
  ring.mesh=mesh
  ring.material_override=Models.material(Color("a2dfbd"),true)
  ring.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  ring.position.y=0.85
  root.add_child(ring)
  var label=Models.label(root,"",Vector3(0,13,0),36)
  pool.append({"root":root,"coins":coins,"mist":mist,"ring":ring,"label":label,"left":0.0})
  root.hide()
 Game.sale_completed.connect(on_sale)
 Game.fire_extinguished.connect(on_rescue)
 Game.reward_claimed.connect(func(title,coins): start(world.focus,"%s +%s MÜNZEN" % [title,Catalog.number(coins)],false))
 Game.company_level_unlocked.connect(func(level): start(world.focus,"LEVEL %s · NEUE MÖGLICHKEITEN!" % level,false))

func start(point: Vector3, caption: String, rescue: bool) -> void:
 if not Game.state.ambient_enabled: return
 var e=pool[next_effect]
 next_effect=(next_effect+1)%pool.size()
 e.root.position=point
 e.root.show()
 e.label.text=caption
 e.left=2.8
 e.coins.emitting=false
 e.mist.emitting=false
 e.ring.visible=rescue
 var p=e.mist if rescue else e.coins
 p.amount=(6 if Game.state.quality==0 else 12) if rescue else (8 if Game.state.quality==0 else 18)
 if FeedbackFX.allowed(e.root): p.restart(); p.emitting=true
 if rescue and point.distance_to(world.focus)<world.zoom*1.5: world.audio.play_chime()

func on_sale(_key: String, coins: float, point: Vector3) -> void:
 start(point,"+%s MÜNZEN" % Catalog.number(coins),false)
func on_rescue(point: Vector3) -> void:
 start(point,"GELÖSCHT · GEBÄUDE GESICHERT",true)

func _process(delta: float) -> void:
 for e in pool:
  e.left=maxf(0,float(e.left)-delta)
  var visible_now=e.left>0 and Game.state.ambient_enabled and e.root.position.distance_to(world.focus)<world.zoom*1.6+40
  e.root.visible=visible_now
  var motion=bool(Game.state.ux.motion)
  e.coins.visible=visible_now and motion
  e.mist.visible=visible_now and motion
  if not visible_now or not motion:
   e.coins.emitting=false
   e.mist.emitting=false
  e.label.modulate.a=minf(1,float(e.left)*2)
  e.label.position.y=13+(2.8-float(e.left))*(1.1 if motion else 0)
  e.ring.visible=visible_now and motion and e.label.text.begins_with("GELÖSCHT")
  e.ring.scale=Vector3.ONE*(1+(2.8-float(e.left))*2 if motion else 1)
