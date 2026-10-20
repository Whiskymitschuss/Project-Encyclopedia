extends SubViewportContainer
var chapter=0
var owned=false
var viewport: SubViewport

func _ready() -> void:
 custom_minimum_size=Vector2(0,180)
 stretch=true
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 viewport=SubViewport.new()
 viewport.size=Vector2i(460,180)
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
 viewport.add_child(sun)
 var camera=Camera3D.new()
 camera.projection=Camera3D.PROJECTION_ORTHOGONAL
 camera.size=10
 camera.position=Vector3(6,6,10)
 viewport.add_child(camera)
 camera.look_at(Vector3(0,2,0))
 var model=Node3D.new()
 model.name="ChapterTrophy"
 model.set_meta("chapter",chapter)
 model.set_meta("earned",owned)
 viewport.add_child(model)
 var gold=Color("ffca50") if owned else Color("9baeb1")
 var tone=Color(Journey.CHAPTERS[chapter].color) if owned else Color("7f9698")
 Models.cylinder(model,2.3,0.4,Vector3(0,0.2,0),Color("2d6670"))
 Models.cylinder(model,1.8,0.5,Vector3(0,0.65,0),tone)
 Models.cylinder(model,0.35,1.1,Vector3(0,1.4,0),gold)
 Models.cylinder(model,0.5,1.0,Vector3(0,2.3,0),gold,1.5)
 for side in [-1,1]:
  var handle=Models.cylinder(model,0.75,0.16,Vector3(side*1.25,2.7,0),gold)
  handle.rotation.x=PI/2
  Models.cylinder(model,0.5,0.18,Vector3(side*1.25,2.7,-0.01),Color("2d6670")).rotation.x=PI/2
 # A growing tree-crown makes each of the nine trophies recognizable.
 for i in range(1+int(chapter/3.0)):
  Models.cylinder(model,1.2-i*0.2,1.0,Vector3(0,3.3+i*0.65,0),tone,0.05)
 for i in chapter+1:
  Models.box(model,Vector3(0.16,0.25,0.12),Vector3((i-chapter*0.5)*0.28,0.7,1.65),gold)
