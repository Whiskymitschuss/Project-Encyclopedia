extends Node3D

var camera: Camera3D
var sun: DirectionalLight3D
var focus = Vector3(0,0,-43)
var zoom = 170.0
var world_buildings: Node3D
var actors: Node3D
var tree_batches: Array = []
var trees: Array = []
var scenery: Node3D
var time = 0.0
var moving_goods: Array = []
var actor_signature = ""
var dragging = false
var drag_distance = 0.0
var last_pointer = Vector2.ZERO
var touches: Dictionary = {}
var pinch_distance = 0.0
var hud: Control
var weather: GPUParticles3D
var audio: Node
var machines: Array = []
var chip_pool: Array = []
var chip_index = 0
var cranes: Array = []

func _ready() -> void:
 RenderingServer.set_default_clear_color(Color("71b6bf"))
 var environment_node = WorldEnvironment.new()
 var env = Environment.new()
 env.background_mode = Environment.BG_COLOR
 env.background_color = Color("71b6bf")
 env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color = Color("c2d9cf")
 env.ambient_light_energy = 0.65
 env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
 environment_node.environment = env
 add_child(environment_node)
 sun = DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-48,-25,0)
 sun.light_color = Color("ffe3b4")
 sun.shadow_enabled = false
 add_child(sun)
 camera = Camera3D.new()
 camera.projection = Camera3D.PROJECTION_ORTHOGONAL
 camera.far = 1000
 add_child(camera)
 set_camera()
 scenery = Node3D.new()
 add_child(scenery)
 build_landscape()
 build_forest()
 world_buildings = Node3D.new()
 add_child(world_buildings)
 actors = Node3D.new()
 add_child(actors)
 rebuild()
 var layer = CanvasLayer.new()
 add_child(layer)
 hud = load("res://UI/HUD.gd").new()
 layer.add_child(hud)
 hud.camera_action.connect(camera_action)
 hud.focus_requested.connect(focus_at)
 Game.rebuild_world.connect(rebuild)
 Game.harvested.connect(on_harvested)
 make_weather()
 make_chip_pool()
 audio = load("res://Audio/Sound.gd").new()
 add_child(audio)
 Game.harvested.connect(func(_b,_a): audio.play_tone(190,0.07))
 Game.loot_found.connect(func(_r): audio.play_tone(780,0.22))

func build_landscape() -> void:
 Models.box(scenery,Vector3(1100,1,1100),Vector3(0,-5,0),Color("65adb8"))
 Models.box(scenery,Vector3(400,5,390),Vector3(0,-2.5,5),Color("b3a06d"))
 Models.box(scenery,Vector3(396,0.7,386),Vector3(0,0,5),Color("a0cb7e"))
 for i in 10:
  var p = Catalog.biome_position(i)
  Models.box(scenery,Vector3(84,0.35,76),p+Vector3(0,0.5,0),Color(Catalog.BIOMES[i].ground))
  Models.label(scenery,Catalog.BIOMES[i].name,p+Vector3(0,2,-32),30)
  var rock = Models.cylinder(scenery,3,4,p+Vector3(25,1.5,24),Color("b4b7a2"),1.3)
  rock.rotation.z = 0.2
 # The entire connected road network stays at least 15 units inside land.
 for x in [-80,0,80]: road(Vector3(x,0.7,4),Vector3(7,0.25,352),true)
 for z in [-160,-60,-28,4,36,68,100,132,164]: road(Vector3(0,0.72,z),Vector3(164,0.25,7),false)
 for project in Catalog.PROJECTS:
  var side = signf(project.position.x)
  road(Vector3(side*132,0.72,project.position.z+13),Vector3(104,0.25,7),false)
 for z in [-160,164]:
  for x in [-80,80]:
   Models.box(scenery,Vector3(1,1,1),Vector3(x,1.2,z),Color("d6d8bc"))
 for i in 12:
  var p = Catalog.home_position(i)
  Models.box(scenery,Vector3(19,0.2,23),p+Vector3(0,0.5,0),Color("b1bd88"))
  Models.label(scenery,"Grundstück %s" % (i+1),p+Vector3(0,1.5,0),22)
 for x in [-76,76]:
  for z in range(-145,165,24):
   Models.cylinder(scenery,0.15,5,Vector3(x,3,z),Color("7c8d80"))
   var lamp = Models.box(scenery,Vector3(1.2,0.4,1.2),Vector3(x,5.6,z),Color("eddda5"))
   lamp.material_override = Models.material(Color("f5d797"),true)

func road(at: Vector3, size: Vector3, vertical: bool) -> void:
 Models.box(scenery,size+Vector3(1.8,-0.05,1.8),at-Vector3(0,0.1,0),Color("c8cfb4"))
 Models.box(scenery,size,at,Color("7e9992"))
 var length = size.z if vertical else size.x
 for i in range(-int(length/2)+3,int(length/2)-2,9):
  Models.box(scenery,Vector3(0.25,0.03,3) if vertical else Vector3(3,0.03,0.25),at+Vector3(0,0.15,i) if vertical else at+Vector3(i,0.15,0),Color("e9dfb3"))

func build_forest() -> void:
 var random = RandomNumberGenerator.new()
 random.seed = 718233
 for biome in 10:
  var center = Catalog.biome_position(biome)
  var records = []
  var batch_nodes = []
  for part in 3:
   var mesh = CylinderMesh.new()
   mesh.radial_segments = 6
   mesh.rings = 1
   mesh.bottom_radius = 0.45 if part == 0 else (2.3 if part == 1 else 1.8)
   mesh.top_radius = 0.32 if part == 0 else 0.1
   mesh.height = 3.0 if part == 0 else 4.5
   var mm = MultiMesh.new()
   mm.transform_format = MultiMesh.TRANSFORM_3D
   mm.use_colors = true
   mm.mesh = mesh
   mm.instance_count = 100
   var node = MultiMeshInstance3D.new()
   node.multimesh = mm
   node.material_override = Models.material(Color("ad8556") if part == 0 else Color(Catalog.BIOMES[biome].tree))
   node.material_override = node.material_override.duplicate()
   node.material_override.vertex_color_use_as_albedo = true
   add_child(node)
   batch_nodes.append(node)
  for i in 100:
   var point = center+Vector3(random.randf_range(-35,35),0,random.randf_range(-29,29))
   # Keep the north road and the center boulevards clear.
   if absf(point.x-80)<8: point.x = 90
   if absf(point.x+80)<8: point.x = -90
   for project in Catalog.PROJECTS:
    if signf(point.x)==signf(project.position.x) and absf(point.x)>80 and absf(point.z-project.position.z-13)<7:
     point.z -= 14
    if point.distance_to(project.position)<18: point.x -= signf(point.x)*16
   var scale_value = random.randf_range(0.75,1.25)
   records.append({"point":point,"scale":scale_value,"regrow":0.0})
   for part in 3:
    var y = [1.8,4.7,7.1][part]*scale_value
    var transform = Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*scale_value),point+Vector3(0,y,0))
    batch_nodes[part].multimesh.set_instance_transform(i,transform)
    batch_nodes[part].multimesh.set_instance_color(i,Color.WHITE.darkened(random.randf_range(0,0.13)))
  trees.append(records)
  tree_batches.append(batch_nodes)
  var boss = Node3D.new()
  boss.position = center+Vector3(0,0,25)
  add_child(boss)
  Models.cylinder(boss,1.5,7,Vector3(0,3.5,0),Color("99714b"))
  Models.cylinder(boss,6,11,Vector3(0,10,0),Color(Catalog.BIOMES[biome].tree).lightened(0.18),0.3)
  Models.label(boss,"BOSS",Vector3(0,17,0),35)

func clear_children(parent: Node) -> void:
 for child in parent.get_children():
  parent.remove_child(child)
  child.queue_free()

func rebuild() -> void:
 if world_buildings == null: return
 clear_children(world_buildings)
 moving_goods.clear()
 machines.clear()
 cranes.clear()
 for i in Game.state.buildings.size():
  var b = Game.state.buildings[i]
  var model = Models.building(b.kind,int(b.level))
  model.position = Catalog.industry_position(int(b.get("slot",i)))
  world_buildings.add_child(model)
  var saw = model.get_node_or_null("Saw")
  if saw != null: machines.append({"node":saw,"kind":b.kind})
  Models.label(model,"%s · %s" % [Catalog.BUILDINGS[b.kind].name,b.level],Vector3(0,10,0),24)
  if Catalog.RECIPES.has(b.kind):
   for j in 3:
    var good = Models.box(world_buildings,Vector3(2.2,0.55,1),model.position+Vector3(5,2.1,6+j*2),Color("e4b77a"))
    moving_goods.append({"mesh":good,"origin":model.position,"phase":j/3.0,"kind":b.kind})
 for h in Game.state.homes:
  var model = Models.building(h.kind,int(h.level),true)
  model.position = Catalog.home_position(int(h.plot))
  world_buildings.add_child(model)
  Models.label(model,"%s · %s" % [Catalog.HOMES[h.kind].name,h.level],Vector3(0,14,0),24)
 for job in Game.state.jobs:
  if job.type in ["building","home","upgrade","home_upgrade","project"]:
   var model = Models.construction(1.0-float(job.left)/float(job.total))
   if job.type in ["home","home_upgrade"]: model.position = Catalog.home_position(int(job.plot))
   elif job.type == "upgrade":
    var b = Game.state.buildings[int(job.index)]
    model.position = Catalog.industry_position(int(b.get("slot",job.index)))
   elif job.type == "project": model.position = Catalog.PROJECTS[int(job.index)].position
   else: model.position = Catalog.industry_position(int(job.slot))
   world_buildings.add_child(model)
   cranes.append(model.get_node("Crane"))
 for i in Catalog.PROJECTS.size():
  var project = Catalog.PROJECTS[i]
  var stage = int(Game.state.projects.get(str(i),0))
  if stage > 0:
   var model = Models.building("hotel" if i < 2 else "office",stage*3,true)
   model.position = project.position
   world_buildings.add_child(model)
   Models.label(model,project.name,Vector3(0,19,0),30)
  else: Models.label(world_buildings,project.name,project.position+Vector3(0,2,0),26)
 actor_signature = ""

func sync_actors() -> void:
 var signature = "%s/%s/%s/%s" % [Game.state.workers,Game.state.trucks,Game.state.biome,Game.state.quality]
 if signature == actor_signature: return
 actor_signature = signature
 clear_children(actors)
 for i in mini(int(Game.state.workers),8 if Game.state.quality == 0 else 16):
  var worker = TimberWorker.new()
  worker.origin_point = Catalog.biome_position(int(Game.state.biome))+Vector3((i%4)*5-10,0,18)
  worker.destination = Vector3(-45+(i%3)*2,0,-34)
  worker.phase = i*1.7
  worker.pace = 0.7+(i%4)*0.1
  actors.add_child(worker)
 for i in mini(int(Game.state.trucks),3 if Game.state.quality == 0 else 8):
  var truck = TimberTruck.new()
  truck.path.assign([Vector3(-78,1,-26),Vector3(2,1,-26),Vector3(2,1,70),Vector3(78,1,70),Vector3(78,1,162),Vector3(-78,1,162)])
  truck.segment = i%truck.path.size()
  truck.speed = 9+int(Game.state.vehicle)
  actors.add_child(truck)
  truck.position = truck.path[truck.segment]
 for i in mini(Game.residents(),6):
  var resident = TimberWorker.new()
  resident.origin_point = Vector3(-60+i*8,0,72)
  resident.destination = Vector3(-60+i*8,0,155)
  resident.phase = i*2.1
  resident.pace = 0.55
  actors.add_child(resident)

func make_weather() -> void:
 weather = GPUParticles3D.new()
 weather.amount = 140
 weather.lifetime = 2.5
 var process_material = ParticleProcessMaterial.new()
 process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
 process_material.emission_box_extents = Vector3(60,1,55)
 process_material.direction = Vector3(0,-1,0.15)
 process_material.gravity = Vector3(0,-4,0)
 process_material.initial_velocity_min = 16
 process_material.initial_velocity_max = 22
 process_material.scale_min = 0.06
 process_material.scale_max = 0.12
 weather.process_material = process_material
 var mesh = BoxMesh.new()
 mesh.size = Vector3(0.25,5,0.25)
 mesh.material = Models.material(Color("b5d8df"))
 weather.draw_pass_1 = mesh
 weather.visibility_aabb = AABB(Vector3(-100,-100,-100),Vector3(200,200,200))
 add_child(weather)

func _process(delta: float) -> void:
 time += delta
 sync_actors()
 var daylight = clampf(sin((float(Game.state.time)-6.0)/24.0*TAU),0.0,1.0)
 sun.light_energy = 0.22+daylight*0.65
 sun.rotation_degrees.x = -25-daylight*40
 weather.position = focus+Vector3(0,36,0)
 weather.emitting = int(Game.state.weather) == 2 and Game.state.quality > 0
 for machine in machines:
  if float(Game.flow.get(machine.kind,0))>0: machine.node.rotate_y(delta*8)
 for crane in cranes: crane.rotation.y = sin(time*0.45)*0.2
 for item in moving_goods:
  if float(Game.flow.get(item.kind,0)) > 0:
   item.phase = fmod(float(item.phase)+delta*0.18,1.0)
  item.mesh.position = item.origin+Vector3(5,2.1,4+item.phase*8)
 for biome in trees.size():
  for index in trees[biome].size():
   var tree = trees[biome][index]
   if tree.regrow > 0:
    tree.regrow -= delta
    if tree.regrow <= 0: set_tree_visible(biome,index,true)

func set_tree_visible(biome: int, index: int, visible_tree: bool) -> void:
 var tree = trees[biome][index]
 for part in 3:
  var size_value = float(tree.scale) if visible_tree else 0.001
  var y = [1.8,4.7,7.1][part]*size_value
  tree_batches[biome][part].multimesh.set_instance_transform(index,Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*size_value),tree.point+Vector3(0,y,0)))

func on_harvested(biome: int, _amount: float) -> void:
 var closest = -1
 var distance = INF
 for i in trees[biome].size():
  var t = trees[biome][i]
  var d = t.point.distance_squared_to(focus)
  if t.regrow <= 0 and d < distance:
   closest = i
   distance = d
 if closest >= 0:
  trees[biome][closest].regrow = 20.0
  set_tree_visible(biome,closest,false)
  var effect = chip_pool[chip_index]
  effect.position = trees[biome][closest].point+Vector3(0,3,0)
  effect.restart()
  effect.emitting = true
  chip_index = (chip_index+1)%chip_pool.size()

func make_chip_pool() -> void:
 for i in 6:
  var effect = CPUParticles3D.new()
  effect.emitting = false
  effect.one_shot = true
  effect.amount = 12
  effect.lifetime = 0.7
  effect.explosiveness = 1
  effect.direction = Vector3.UP
  effect.spread = 80
  effect.initial_velocity_min = 5
  effect.initial_velocity_max = 9
  effect.gravity = Vector3(0,-15,0)
  effect.scale_amount_min = 0.15
  effect.scale_amount_max = 0.35
  var mesh = BoxMesh.new()
  mesh.material = Models.material(Color("e5bd81"))
  effect.mesh = mesh
  add_child(effect)
  chip_pool.append(effect)

func set_camera() -> void:
 focus.x = clampf(focus.x,-175,175)
 focus.z = clampf(focus.z,-160,170)
 camera.size = zoom
 camera.position = focus+Vector3(90,120,130)
 camera.look_at(focus)

func focus_at(point: Vector3) -> void:
 focus = point
 zoom = 86.0
 set_camera()

func camera_action(action: String) -> void:
 match action:
  "+": zoom = maxf(40,zoom*0.82)
  "−": zoom = minf(390,zoom*1.22)
  "home": focus = Vector3(0,0,-43); zoom = 170
  "world": focus = Vector3.ZERO; zoom = 370
 set_camera()

func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventMouseButton:
  if event.button_index == MOUSE_BUTTON_WHEEL_UP: camera_action("+")
  elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: camera_action("−")
  elif event.button_index == MOUSE_BUTTON_LEFT:
   dragging = event.pressed
   if event.pressed:
    drag_distance = 0
    last_pointer = event.position
   elif drag_distance < 12: tap_world(event.position)
 elif event is InputEventMouseMotion and dragging:
  pan(event.relative)
 elif event is InputEventScreenTouch:
  if event.pressed:
   touches[event.index] = event.position
   drag_distance = 0
  else:
   if touches.size() == 1 and drag_distance < 12: tap_world(event.position)
   touches.erase(event.index)
   pinch_distance = 0
 elif event is InputEventScreenDrag:
  touches[event.index] = event.position
  if touches.size() >= 2:
   var values = touches.values()
   var distance = values[0].distance_to(values[1])
   if pinch_distance > 0: zoom = clampf(zoom*pinch_distance/maxf(distance,1),40,390)
   pinch_distance = distance
   drag_distance = 100
   set_camera()
  else: pan(event.relative)

func pan(relative: Vector2) -> void:
 drag_distance += relative.length()
 var ratio = zoom/get_viewport().get_visible_rect().size.y
 focus -= camera.global_basis.x*relative.x*ratio
 var forward = Vector3(camera.global_basis.z.x,0,camera.global_basis.z.z).normalized()
 focus -= forward*relative.y*ratio*1.3
 focus.y = 0
 set_camera()

func tap_world(screen: Vector2) -> void:
 var plane = Plane(Vector3.UP,0)
 var point = plane.intersects_ray(camera.project_ray_origin(screen),camera.project_ray_normal(screen))
 if point == null: return
 for i in Game.state.buildings.size():
  var b = Game.state.buildings[i]
  if point.distance_to(Catalog.industry_position(int(b.get("slot",i)))) < 12:
   hud.show_building(i)
   return
 for i in 10:
  if point.distance_to(Catalog.biome_position(i)) < 46:
   if i < Game.state.unlocked:
    Game.state.biome = i
    Game.chop()
   else: Game.notice.emit("Dieses Biom zuerst im Welt-Menü freischalten")
   return
 for i in 12:
  if point.distance_to(Catalog.home_position(i)) < 12:
   hud.show_plot(i)
   return
