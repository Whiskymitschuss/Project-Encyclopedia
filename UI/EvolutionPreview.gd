extends SubViewportContainer
var kind="apartments"
var level=1
var viewport: SubViewport
var models: Node3D
var camera: Camera3D
func _ready() -> void:
 custom_minimum_size=Vector2(0,250)
 stretch=true
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 viewport=SubViewport.new()
 viewport.size=Vector2i(460,250)
 viewport.own_world_3d=true
 viewport.transparent_bg=true
 viewport.render_target_update_mode=SubViewport.UPDATE_ONCE
 add_child(viewport)
 var environment=WorldEnvironment.new()
 var env=Environment.new()
 env.background_mode=Environment.BG_CLEAR_COLOR
 env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color=Color.WHITE
 env.ambient_light_energy=0.8
 environment.environment=env
 viewport.add_child(environment)
 var sun=DirectionalLight3D.new()
 sun.rotation_degrees=Vector3(-40,-35,0)
 sun.light_energy=0.9
 viewport.add_child(sun)
 camera=Camera3D.new()
 camera.projection=Camera3D.PROJECTION_ORTHOGONAL
 camera.size=58
 camera.position=Vector3(38,48,65)
 viewport.add_child(camera)
 camera.look_at(Vector3(0,12,0))
 models=Node3D.new()
 viewport.add_child(models)
 show_level(level)
func show_level(value: int) -> void:
 level=clampi(value,1,10)
 if models==null: return
 for child in models.get_children(): models.remove_child(child); child.queue_free()
 var model=CityEvolution.create(kind,level,Game.state.skin)
 models.add_child(model)
 var top=float(model.get_meta("height",10))
 var target=Vector3(0,top*0.45,0)
 camera.size=maxf(24,top*1.5)
 camera.position=target+Vector3(38,48,65).normalized()*90
 camera.look_at(target)
 viewport.render_target_update_mode=SubViewport.UPDATE_ONCE
