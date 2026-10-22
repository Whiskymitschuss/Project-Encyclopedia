extends SubViewport

var actor: Node3D
var clock=0.0
var running=false
func _ready() -> void:
 size=Vector2i(176,224)
 own_world_3d=true
 transparent_bg=true
 render_target_update_mode=UPDATE_ONCE
 msaa_3d=Viewport.MSAA_2X
 var environment=WorldEnvironment.new()
 var env=Environment.new()
 env.background_mode=Environment.BG_CLEAR_COLOR
 env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color=Color.WHITE
 env.ambient_light_energy=0.55
 environment.environment=env
 add_child(environment)
 var light=DirectionalLight3D.new()
 light.rotation_degrees=Vector3(-30,-25,0)
 light.light_energy=1.0
 add_child(light)
 var camera=Camera3D.new()
 camera.projection=Camera3D.PROJECTION_ORTHOGONAL
 camera.size=5.2
 camera.position=Vector3(0,2.3,10)
 add_child(camera)
 camera.look_at(Vector3(0,2.3,0))
 actor=load("res://Components/Beaver.gd").new()
 add_child(actor)

func greet(celebrate: bool=false) -> void:
 actor.wave_left=4.0
 actor.cheerful=celebrate
 render_target_update_mode=UPDATE_ONCE

func _process(delta: float) -> void:
 if not running or not Game.state.ux.motion: return
 actor.animate(delta)
 clock+=delta
 var interval=0.1 if Game.state.quality==0 or actor.wave_left<=0 else 0.04
 if clock>=interval:
  clock=0
  render_target_update_mode=UPDATE_ONCE
