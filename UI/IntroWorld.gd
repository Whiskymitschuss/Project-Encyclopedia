extends SubViewportContainer
# An isolated presentation scene: no workers, recipes, rewards or saved world.
var viewport: SubViewport
var camera: Camera3D
var workshop: Node3D
var town: Node3D
var clock=0.0
var draw_clock=0.0
var trees=[]
var animated=true
var low=false

func _ready() -> void:
 stretch=true
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 viewport=SubViewport.new()
 viewport.size=Vector2i(520,190)
 viewport.own_world_3d=true
 viewport.transparent_bg=true
 viewport.render_target_update_mode=SubViewport.UPDATE_ONCE
 add_child(viewport)
 if not animated: viewport.process_mode=Node.PROCESS_MODE_DISABLED
 var env=WorldEnvironment.new()
 var resource=Environment.new()
 resource.background_mode=Environment.BG_CLEAR_COLOR
 resource.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 resource.ambient_light_color=Color("dbf4ed")
 resource.ambient_light_energy=0.75
 env.environment=resource
 viewport.add_child(env)
 var sun=DirectionalLight3D.new()
 sun.rotation_degrees=Vector3(-48,-28,0)
 sun.light_color=Color("fff0c3")
 sun.light_energy=1.15
 viewport.add_child(sun)
 camera=Camera3D.new()
 camera.projection=Camera3D.PROJECTION_ORTHOGONAL
 viewport.add_child(camera)
 var island=Node3D.new()
 viewport.add_child(island)
 Models.paving_box(island,Vector3(98,3,48),Vector3(0,-2,0),Color("83b87b"),"plaster",6)
 Models.box(island,Vector3(88,4,40),Vector3(0,-5,0),Color("577e70"))
 Models.paving_box(island,Vector3(94,0.12,5),Vector3(0,0.1,12),Color("d9c3a1"),"paving",2)
 for i in 11:
  var tree=Node3D.new()
  tree.position=Vector3(-39+(i%4)*9,0,-14+(i/4)*12)
  island.add_child(tree)
  Models.cylinder(tree,0.75,5,Vector3(0,2.5,0),Color("9f7653"))
  Models.cylinder(tree,4.8,11,Vector3(0,8,0),Color("34876b").lightened((i%3)*0.04),0.2)
  Models.bake(tree)
  trees.append(tree)
 workshop=Node3D.new()
 viewport.add_child(workshop)
 var mill=Models.building("sawmill",1)
 mill.position=Vector3(-4,0,-5)
 workshop.add_child(mill)
 var hut=Models.building("cabin",1)
 hut.position=Vector3(20,0,-3)
 workshop.add_child(hut)
 town=Node3D.new()
 viewport.add_child(town)
 var home=Models.building("house",2,true)
 home.position=Vector3(38,0,-3)
 town.add_child(home)
 resized.connect(frame)
 frame()
 present(0,true)

func frame() -> void:
 if viewport==null: return
 # Native aspect and an orthographic camera adapt together; no stretched 3D.
 var aspect=maxf(0.1,maxf(1,size.x)/maxf(1,size.y))
 camera.size=maxf(48,110/aspect)
 camera.position=Vector3(76,98,135)
 camera.look_at(Vector3(0,0,0))
 viewport.render_target_update_mode=SubViewport.UPDATE_ONCE

func present(phase: int, static_view: bool) -> void:
 if workshop==null: return
 if workshop.visible==(phase>=1 or static_view) and town.visible==(phase>=2 or static_view): return
 workshop.visible=phase>=1 or static_view
 town.visible=phase>=2 or static_view
 viewport.render_target_update_mode=SubViewport.UPDATE_ONCE

func _process(delta: float) -> void:
 if not animated: return
 clock+=delta
 draw_clock+=delta
 if draw_clock<1.0/24.0: return
 draw_clock=0
 for i in trees.size(): trees[i].rotation.z=sin(clock*0.8+i)*0.016
 # Bounded render rate also keeps the title inexpensive on older phones.
 viewport.render_target_update_mode=SubViewport.UPDATE_ONCE
