extends Node3D

var camera: Camera3D
var sun: DirectionalLight3D
var focus = Vector3(-21,0,-43)
var zoom = 96.0
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
var life: Node3D
var machines: Array = []
var chip_pool: Array = []
var chip_index = 0
var cranes: Array = []
var environment_resource: Environment
var auto_tree_clock = 0.0
var network: ConveyorNetwork
var bins: Array = []
var placement: Dictionary = {}
var ghost: Node3D
var ghost_plate: MeshInstance3D
var placement_point = Vector3.ZERO
var placement_rotation = 0
var right_drag = false
var placement_check_clock = 0.0

func _ready() -> void:
 RenderingServer.set_default_clear_color(Color("53bbd3"))
 var environment_node = WorldEnvironment.new()
 var env = Environment.new()
 environment_resource = env
 env.background_mode = Environment.BG_COLOR
 env.background_color = Color("53bbd3")
 env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color = Color("e5efff")
 env.ambient_light_energy = 0.65
 env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
 environment_node.environment = env
 add_child(environment_node)
 sun = DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-48,-25,0)
 sun.light_color = Color("fff2df")
 sun.shadow_enabled = Game.state.quality>0
 sun.directional_shadow_mode=DirectionalLight3D.SHADOW_ORTHOGONAL
 sun.directional_shadow_max_distance=160
 sun.shadow_bias=0.04
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
 hud.placement_requested.connect(begin_placement)
 hud.placement_action.connect(placement_action)
 Game.rebuild_world.connect(rebuild)
 Game.harvested.connect(on_harvested)
 make_weather()
 make_chip_pool()
 audio = load("res://Audio/Sound.gd").new()
 add_child(audio)
 Game.harvested.connect(func(_b,_a): audio.play_tone(190,0.07))
 Game.loot_found.connect(func(_r): audio.play_tone(780,0.22))
 life=load("res://Components/WorldLife.gd").new()
 life.world=self
 add_child(life)

func build_landscape() -> void:
 Models.box(scenery,Vector3(1100,1,1100),Vector3(0,-5,0),Color("38b4cf"))
 Models.box(scenery,Vector3(400,5,390),Vector3(0,-2.5,5),Color("b3a06d"))
 Models.box(scenery,Vector3(396,0.7,386),Vector3(0,0,5),Color("64d078"))
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
  Models.box(scenery,Vector3(19,0.12,23),p+Vector3(0,0.5,0),Color("8cd784"))
 for x in [-76,76]:
  for z in range(-145,165,24):
   Models.cylinder(scenery,0.15,5,Vector3(x,3,z),Color("7c8d80"))
   var lamp = Models.box(scenery,Vector3(1.2,0.4,1.2),Vector3(x,5.6,z),Color("eddda5"))
   lamp.material_override = Models.material(Color("f5d797"),true)
 Models.bake(scenery)

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
   records.append({"point":point,"scale":scale_value,"regrow":0.0,"blocked":false})
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
 bins.clear()
 for i in Game.state.buildings.size():
  var b = Game.state.buildings[i]
  var model = Models.building(b.kind,int(b.level))
  model.position = Game.building_position(i)
  model.rotation_degrees.y = int(b.get("rotation",0))
  world_buildings.add_child(model)
  var saw = model.get_node_or_null("Saw")
  if saw != null: machines.append({"node":saw,"index":i})
  var processing = model.get_node_or_null("Processing")
  if processing != null: processing.building_index = i
  Models.label(model,"%s · %s" % [Catalog.BUILDINGS[b.kind].name,int(b.level)],Vector3(0,10,0),24)
  add_approach(model.position,int(b.get("rotation",0)))
  var fill = model.get_node_or_null("SawdustFill")
  if fill!=null:
   var label = Models.label(model,"Spänebox",Vector3(7.5,5.2,-3),28)
   bins.append({"fill":fill,"label":label})
  if Catalog.RECIPES.has(b.kind) and not model.get_meta("open_factory",false):
   for j in 3:
    var good = Models.box(world_buildings,Vector3(2.2,0.55,1),model.position+Vector3(5,2.1,6+j*2),Color("e4b77a"))
    moving_goods.append({"mesh":good,"origin":model.position,"rotation":model.rotation,"phase":j/3.0,"index":i})
 for home_index in Game.state.homes.size():
  var h = Game.state.homes[home_index]
  var model = Models.building(h.kind,int(h.level),true)
  model.position = Game.home_position(home_index)
  model.rotation_degrees.y = int(h.get("rotation",0))
  world_buildings.add_child(model)
  Models.label(model,"%s · %s" % [Catalog.HOMES[h.kind].name,int(h.level)],Vector3(0,14,0),24)
  add_approach(model.position,int(h.get("rotation",0)))
 for job in Game.state.jobs:
  if job.type in ["building","home","upgrade","home_upgrade","project"]:
   var model = Models.construction(1.0-float(job.left)/float(job.total))
   if job.type=="home": model.position = Placement.position_of(job,Catalog.home_position(int(job.plot)))
   elif job.type=="home_upgrade": model.position = Game.home_position(int(job.index))
   elif job.type == "upgrade":
    var b = Game.state.buildings[int(job.index)]
    model.position = Game.building_position(int(job.index))
   elif job.type == "project": model.position = Catalog.PROJECTS[int(job.index)].position
   else: model.position = Placement.position_of(job,Catalog.industry_position(int(job.slot)))
   model.rotation_degrees.y = int(job.get("rotation",0))
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
 refresh_forest_clearance()
 if network!=null:
  remove_child(network)
  network.queue_free()
 network = ConveyorNetwork.new()
 add_child(network)
 network.build()

func add_approach(point: Vector3, rotation: int) -> void:
 var path = Placement.approach(point,rotation)
 var length = path[0].distance_to(path[1])
 if length>0.1: Models.box(world_buildings,Vector3(3.0,0.12,length),(path[0]+path[1])/2,Color("efe2ae"))

func refresh_forest_clearance() -> void:
 var rectangles = []
 for i in Game.state.buildings.size(): rectangles.append(Placement.bounds(Game.building_position(i),int(Game.state.buildings[i].get("rotation",0))).grow(3))
 for i in Game.state.homes.size(): rectangles.append(Placement.bounds(Game.home_position(i),int(Game.state.homes[i].get("rotation",0))).grow(3))
 for job in Game.state.jobs:
  if job.type in ["home","building"]:
   var fallback = Catalog.home_position(int(job.plot)) if job.type=="home" else Catalog.industry_position(int(job.slot))
   rectangles.append(Placement.bounds(Placement.position_of(job,fallback),int(job.get("rotation",0))).grow(3))
 for biome in trees.size():
  for i in trees[biome].size():
   var tree = trees[biome][i]
   tree.blocked = false
   for rectangle in rectangles:
    if rectangle.has_point(Vector2(tree.point.x,tree.point.z)): tree.blocked = true; break
   set_tree_visible(biome,i,not tree.blocked and tree.regrow<=0)

func sync_actors() -> void:
 var signature = "%s/%s/%s/%s" % [Game.state.workers,Game.state.trucks,Game.state.biome,Game.state.quality]
 if signature == actor_signature: return
 actor_signature = signature
 clear_children(actors)
 var staff = mini(int(Game.state.workers),8 if Game.state.quality == 0 else 16)
 var factories = []
 for i in Game.state.buildings.size():
  if Catalog.RECIPES.has(Game.state.buildings[i].kind): factories.append(i)
 var operators = mini(mini(staff/3,factories.size()),2 if Game.state.quality==0 else 6)
 var cabin_index=-1
 for i in Game.state.buildings.size():
  if Game.state.buildings[i].kind=="cabin": cabin_index=i; break
 for i in operators:
  var worker = TimberWorker.new()
  worker.role = "operator"
  worker.production_index = factories[i]
  worker.origin_point = Game.building_position(factories[i])+Basis.from_euler(Vector3(0,deg_to_rad(Game.state.buildings[factories[i]].get("rotation",0)),0))*Vector3(-3.5,0,2.7)
  worker.facing = deg_to_rad(Game.state.buildings[factories[i]].get("rotation",0))+PI/2
  actors.add_child(worker)
 for i in staff-operators:
  var worker = TimberWorker.new()
  worker.origin_point = Catalog.biome_position(int(Game.state.biome))+Vector3((i%4)*5-10,0,18)
  worker.destination = Game.building_position(0)+Vector3((i%3)*2,0,9)
  worker.phase = i*1.7
  worker.pace = 0.7+(i%4)*0.1
  if i==staff-operators-1 and staff>=4 and cabin_index>=0:
   worker.role="neighbor"
   var base=Game.building_position(cabin_index)
   var angle=deg_to_rad(Game.state.buildings[cabin_index].get("rotation",0))
   var turn=Basis.from_euler(Vector3(0,angle,0))
   worker.origin_point=base+turn*Vector3(0,0,6.8)
   worker.rest_via=base+turn*Vector3(1.8,0,9.7)
   worker.destination=base+turn*Vector3(4.2,0,9.7)
   worker.facing=angle+PI
   worker.pace=0.85
   worker.phase=0
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
  resident.role = "resident"
  var home_index=i%Game.state.homes.size()
  var turn=Basis.from_euler(Vector3(0,deg_to_rad(Game.state.homes[home_index].get("rotation",0)),0))
  var point=Game.home_position(home_index)
  resident.origin_point = point+turn*Vector3(-4.5,0,9)
  resident.destination = point+turn*Vector3(4.5,0,9)
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
 if not placement.is_empty():
  placement_check_clock+=delta
  if placement_check_clock>=0.5: placement_check_clock=0; update_ghost()
 sync_actors()
 sun.shadow_enabled=Game.state.quality>0
 var daylight = clampf(sin((float(Game.state.time)-6.0)/24.0*TAU),0.0,1.0)
 sun.light_energy = 0.22+daylight*0.55
 environment_resource.ambient_light_energy = 0.22+daylight*0.26
 environment_resource.background_color = Color("294654").lerp(Color("53bbd3"),daylight)
 environment_resource.fog_enabled = int(Game.state.weather)==3 and Game.state.quality>0
 environment_resource.fog_light_color = Color("c6d4c1")
 environment_resource.fog_density = 0.0007
 sun.rotation_degrees.x = -25-daylight*40
 weather.position = focus+Vector3(0,36,0)
 weather.emitting = int(Game.state.weather) == 2 and Game.state.quality > 0
 for machine in machines:
  if float(Game.flow.get("building:%s" % machine.index,0))>0: machine.node.rotate_y(delta*8)
 for crane in cranes: crane.rotation.y = sin(time*0.45)*0.2
 for item in moving_goods:
  if float(Game.flow.get("building:%s" % item.index,0)) > 0:
   item.phase = fmod(float(item.phase)+delta*0.18,1.0)
  item.mesh.position = item.origin+Basis.from_euler(item.rotation)*Vector3(5,2.1,4+item.phase*8)
 for bin in bins:
  var fraction = clampf(float(Game.state.resources.sawdust)/Game.capacity(),0,1)
  bin.fill.scale.y = maxf(fraction,0.03)
  bin.fill.position.y = 0.7+1.35*fraction
  bin.label.text = "SPÄNE · %s %%" % int(fraction*100)
 auto_tree_clock += delta
 if auto_tree_clock>=maxf(0.6,6.0/maxi(1,int(Game.state.workers))) and float(Game.flow.get("harvest",0))>0:
  auto_tree_clock = 0
  on_harvested(int(Game.state.biome),0)
 for biome in trees.size():
  for index in trees[biome].size():
   var tree = trees[biome][index]
   if tree.regrow > 0:
    tree.regrow -= delta
    if tree.regrow <= 0: set_tree_visible(biome,index,not tree.blocked)

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
  if not t.blocked and t.regrow <= 0 and d < distance:
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
  "home": focus = Game.building_position(mini(1,Game.state.buildings.size()-1)); zoom = 96
  "world": focus = Vector3.ZERO; zoom = 370
 set_camera()

func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventMouse and event.device==-1: return
 if event is InputEventMouseButton:
  if event.button_index == MOUSE_BUTTON_WHEEL_UP: camera_action("+")
  elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: camera_action("−")
  elif event.button_index == MOUSE_BUTTON_RIGHT: right_drag=event.pressed
  elif event.button_index == MOUSE_BUTTON_LEFT:
   dragging = event.pressed
   if event.pressed:
    drag_distance = 0
    last_pointer = event.position
   elif drag_distance < 12: tap_world(event.position)
 elif event is InputEventMouseMotion and (dragging or right_drag):
  if not placement.is_empty() and not right_drag: place_at_screen(event.position)
  else: pan(event.relative)
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
   if not placement.is_empty(): pan(event.relative*0.5)
   pinch_distance = distance
   drag_distance = 100
   set_camera()
  else:
   if placement.is_empty(): pan(event.relative)
   else: place_at_screen(event.position)

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
 if not placement.is_empty():
  placement_point = Placement.snap(point)
  update_ghost()
  return
 for i in Game.state.buildings.size():
  var b = Game.state.buildings[i]
  if b.kind=="sawmill":
   var bin_position = Game.building_position(i)+Basis(Vector3.UP,deg_to_rad(int(b.get("rotation",0))))*Vector3(7.5,0,-3)
   if point.distance_to(bin_position)<3.5: hud.open_menu("sawdust"); return
  if Placement.bounds(Game.building_position(i),int(b.get("rotation",0))).has_point(Vector2(point.x,point.z)):
   hud.show_building(i)
   return
 for i in Game.state.homes.size():
  if Placement.bounds(Game.home_position(i),int(Game.state.homes[i].get("rotation",0))).has_point(Vector2(point.x,point.z)):
   hud.show_plot(int(Game.state.homes[i].plot))
   return
 for i in 10:
  if point.distance_to(Catalog.biome_position(i)) < 46:
   if i < Game.state.unlocked:
    Game.state.biome = i
    Game.chop()
   else: Game.notice.emit("Dieses Biom zuerst im Welt-Menü freischalten")
   return
 for i in 12:
  if point.distance_to(Catalog.home_position(i))<12:
   hud.show_plot(i)
   return

func begin_placement(request: Dictionary) -> void:
 cancel_placement()
 placement = request.duplicate(true)
 var city = bool(placement.get("city",false))
 var index = int(placement.get("index",-1))
 if city and index<0 and int(placement.get("plot",-1))<0: placement.plot = Game.next_city_plot()
 if city and index<0 and int(placement.get("plot",-1))<0:
  Game.notice.emit("Keine freien Stadtgrundstücke · Region erweitern")
  placement = {}
  return
 var preferred = focus
 placement_rotation = 0
 if index>=0:
  preferred = Game.home_position(index) if city else Game.building_position(index)
  placement_rotation = int((Game.state.homes if city else Game.state.buildings)[index].get("rotation",0))
 placement_point = Game.free_position(preferred,placement_rotation,-1 if city else index,index if city else -1)
 if not is_finite(placement_point.x): placement_point=Placement.snap(focus)
 ghost = Node3D.new()
 add_child(ghost)
 var model = Models.building(placement.kind,1,city)
 ghost.add_child(model)
 var mat = Models.material(Color(1,1,1,0.45)).duplicate()
 mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 for child in model.get_children():
  if child is MeshInstance3D: child.material_override=mat
 ghost_plate = Models.box(ghost,Vector3(19,0.2,23),Vector3(0,0.9,0),Color("5bfba0"))
 hud.show_placement(placement)
 update_ghost()

func place_at_screen(screen: Vector2) -> void:
 var point = Plane(Vector3.UP,0).intersects_ray(camera.project_ray_origin(screen),camera.project_ray_normal(screen))
 if point!=null:
  placement_point=Placement.snap(point)
  update_ghost()

func update_ghost() -> void:
 if ghost==null: return
 ghost.position=placement_point
 ghost.rotation_degrees.y=placement_rotation
 var city=bool(placement.get("city",false))
 var index=int(placement.get("index",-1))
 var reason=Game.placement_reason(placement_point,placement_rotation,-1 if city else index,index if city else -1)
 if reason.is_empty() and index<0:
  var definition=(Catalog.HOMES if city else Catalog.BUILDINGS)[placement.kind]
  var price=float(definition.cost)*Game.difficulty() if city else Game.cost_for(placement.kind)
  if float(Game.state.coins)<price: reason="Es fehlen %s Münzen" % Catalog.number(price-float(Game.state.coins))
  elif city:
   for key in definition.materials:
    if float(Game.state.resources[key])<float(definition.materials[key]): reason="Es fehlt: %s" % Catalog.RESOURCES[key]; break
 ghost_plate.material_override=Models.material(Color("43e69a") if reason.is_empty() else Color("f16c5d"))
 hud.update_placement(reason)

func placement_action(action: String) -> void:
 if placement.is_empty(): return
 if action=="cancel": cancel_placement(); return
 if action=="rotate": placement_rotation=posmod(placement_rotation+90,360); update_ghost(); return
 if action!="confirm": return
 var city=bool(placement.get("city",false))
 var index=int(placement.get("index",-1))
 var success=false
 if index>=0: success=Game.move_building(index,placement_point,placement_rotation,city)
 elif city: success=Game.order_home(placement.kind,int(placement.plot),placement_point,placement_rotation)
 else: success=Game.order_building(placement.kind,placement_point,placement_rotation)
 if success: cancel_placement()

func cancel_placement() -> void:
 placement={}
 if ghost!=null:
  remove_child(ghost)
  ghost.queue_free()
  ghost=null
 if hud!=null: hud.hide_placement()
