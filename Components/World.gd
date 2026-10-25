extends Node3D

var camera: Camera3D
var sun: DirectionalLight3D
var focus = Vector3(-58,0,-78)
var zoom = 145.0
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
var bins: Array = []
var placement: Dictionary = {}
var ghost: Node3D
var ghost_plate: MeshInstance3D
var placement_point = Vector3.ZERO
var placement_rotation = 0
var right_drag = false
var placement_check_clock = 0.0
var town_layer: TownWorld
var road_anchor: Variant = null
var road_endpoint: Variant = null
var road_horizontal = true
var landscape: ValleyLandscape
var city_traffic: Node3D
var delivery_world: Node3D
var crew_world: Node3D
var selection_world: Node3D
var preview_history=[]
var pinch_active=false
var base_streets: Node3D
var town_name_labels: Array = []
var biome_labels: Array = []
var boss_labels: Array = []
var street_context: Dictionary={}
var feedback: Node3D
var wind_clock=0.0
var wet_weather: Node3D
var spatial_audio: Node3D
var stump_batches=[]
var fauna: Node3D
var upgrade_reveal: Node3D
var view_focus=Vector3(-58,0,-78)
var view_zoom=145.0
var camera_yaw=0.0
var camera_transition=false
var pan_velocity=Vector3.ZERO
var last_pan_time=0
var photo: CanvasLayer
var trade_world: Node3D
var production_alerts: Node
var falling_trees=[]
var next_fall=0
var next_work_tree=0
var forest_detail_key=Vector4(INF,INF,INF,INF)
var performance_tour: Node
var hold_pointer=-1
var hold_started=0
var hold_point=Vector2.ZERO
var hold_consumed=false
var industry_name_labels=[]
var yard_handlers=[]
var handler_clock=0.0
var forest_world: Node3D
var access_preview: Node3D

func _ready() -> void:
 Game.live_world=true
 RenderingServer.set_default_clear_color(Color("53bbd3"))
 var environment_node = WorldEnvironment.new()
 var env = Environment.new()
 environment_resource = env
 env.background_mode = Environment.BG_COLOR
 env.background_color = Color("53bbd3")
 env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color = Color("e5efff")
 var first_daylight=clampf(sin((float(Game.state.time)-6.0)/24.0*TAU),0.0,1.0)
 env.ambient_light_energy = 0.38+first_daylight*0.06
 env.tonemap_mode = Environment.TONE_MAPPER_REINHARDT
 env.tonemap_white=2.0
 environment_node.environment = env
 add_child(environment_node)
 sun = DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-48,-25,0)
 sun.light_color = Color("fff2df")
 sun.light_energy=0.24+first_daylight*0.45
 sun.shadow_opacity=0.45
 sun.shadow_enabled = Game.state.quality>0
 sun.directional_shadow_mode=DirectionalLight3D.SHADOW_ORTHOGONAL
 sun.directional_shadow_max_distance=160
 sun.shadow_bias=0.04
 sun.light_angular_distance=2.2
 add_child(sun)
 camera = Camera3D.new()
 camera.projection = Camera3D.PROJECTION_ORTHOGONAL
 camera.near = 5.0
 camera.far = 1800
 add_child(camera)
 set_camera()
 scenery = Node3D.new()
 add_child(scenery)
 build_landscape()
 build_forest()
 forest_detail_key=Vector4(INF,INF,INF,INF)
 update_forest_detail()
 world_buildings = Node3D.new()
 add_child(world_buildings)
 town_layer = TownWorld.new()
 town_layer.world = self
 add_child(town_layer)
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
 delivery_world=load("res://Components/DeliveryWorld.gd").new()
 delivery_world.world=self
 add_child(delivery_world)
 crew_world=load("res://Components/CrewWorld.gd").new()
 crew_world.world=self
 add_child(crew_world)
 city_traffic=load("res://Components/CityTraffic.gd").new()
 city_traffic.world=self
 add_child(city_traffic)
 selection_world=load("res://Components/SelectionWorld.gd").new()
 selection_world.world=self
 add_child(selection_world)
 Game.rebuild_world.connect(rebuild)
 Game.harvested.connect(on_harvested)
 make_weather()
 make_chip_pool()
 audio = load("res://Audio/Sound.gd").new()
 add_child(audio)
 spatial_audio=load("res://Audio/WorldAudio.gd").new()
 spatial_audio.world=self
 add_child(spatial_audio)
 Game.loot_found.connect(func(_r): audio.play_tone(780,0.22))
 life=load("res://Components/WorldLife.gd").new()
 life.world=self
 add_child(life)
 feedback=load("res://Components/WorldFeedback.gd").new()
 feedback.world=self
 add_child(feedback)
 wet_weather=load("res://Components/WetWeather.gd").new()
 wet_weather.world=self
 add_child(wet_weather)
 fauna=load("res://Components/ForestFauna.gd").new()
 fauna.world=self
 add_child(fauna)
 upgrade_reveal=load("res://Components/UpgradeReveal.gd").new()
 upgrade_reveal.world=self
 add_child(upgrade_reveal)
 photo=load("res://UI/PhotoMode.gd").new()
 photo.world=self
 add_child(photo)
 production_alerts=load("res://UI/ProductionAlerts.gd").new()
 production_alerts.world=self
 add_child(production_alerts)
 trade_world=load("res://Components/TradeWorld.gd").new()
 trade_world.world=self
 add_child(trade_world)
 forest_world=load("res://Components/ForestWorld.gd").new()
 forest_world.world=self
 add_child(forest_world)
 forest_world.sync_trees(false)
 call_deferred("mark_first_world_frame")

func mark_first_world_frame() -> void:
 if DisplayServer.get_name()!="headless": await RenderingServer.frame_post_draw
 RuntimeStats.mark_world_ready()

func build_landscape() -> void:
 landscape=ValleyLandscape.new()
 landscape.world=self
 scenery.add_child(landscape)
 landscape.build()
 for i in 10:
  var p=Catalog.biome_position(i)
  var label=Models.label(scenery,Catalog.BIOMES[i].name,p+Vector3(0,2,-32),30)
  biome_labels.append(label)
 for x in [-76,76]:
  for z in range(-145,165,24):
   Models.cylinder(scenery,0.15,5,Vector3(x,3,z),Color("7c8d80"))
   var lamp=Models.box(scenery,Vector3(1.2,0.4,1.2),Vector3(x,5.6,z),Color("eddda5"))
   lamp.material_override=Models.material(Color("f5d797"),true)
 Models.bake(scenery)
 StaticPaintBatch.reduce(scenery)
 base_streets=Node3D.new()
 add_child(base_streets)

func rebuild_streets() -> void:
 clear_children(base_streets)
 street_context=StreetScape.context(Game.state)
 ProductionCampus.build(base_streets,street_context)
 StreetSurface.build(base_streets,Game.state,street_context)
 # Small planted verges and benches soften the working street grid.
 for x in [-73,73]:
  for z in [-136,-104,-72,-40,-8,24,56,88,120,152]:
   var point=Vector2(x,z)
   var clear=true
   for i in Game.state.buildings.size():
    if Placement.bounds(Game.building_position(i),int(Game.state.buildings[i].get("rotation",0)),Game.state.buildings[i].kind).grow(2.5).has_point(point): clear=false
   for i in Game.state.homes.size():
    if Placement.bounds(Game.home_position(i),int(Game.state.homes[i].get("rotation",0))).grow(2.5).has_point(point): clear=false
   for job in Game.state.jobs:
    if job.type not in ["building","home"]: continue
    var fallback=Catalog.home_position(int(job.plot)) if job.type=="home" else Catalog.industry_position(int(job.get("slot",0)))
    if Placement.bounds(Placement.position_of(job,fallback),int(job.get("rotation",0)),str(job.get("kind",""))).grow(2.5).has_point(point): clear=false
   for record in Game.state.town.roads:
    for c in record.cells:
     if Vector2(TownRules.cell(c)).distance_to(point)<6: clear=false
   for stop in Game.state.town.stops:
    if Vector2(TownRules.cell(stop.cell)).distance_to(point)<9: clear=false
   if not clear: continue
   Models.box(base_streets,Vector3(2.3,0.25,3.5),Vector3(x,0.55,z),Color("c5c9a2"))
   Models.cylinder(base_streets,0.18,2.5,Vector3(x,1.9,z),Color("a48152"))
   var crown=Models.cylinder(base_streets,1.35,3.2,Vector3(x,4,z),Color("78aa5a"),0.45)
   crown.mesh.radial_segments=8
 Models.bake(base_streets)

func road(at: Vector3, size: Vector3, vertical: bool, paved: bool = true) -> void:
 StreetScape.strip(base_streets,at,size,paved,street_context)

func build_forest() -> void:
 var random = RandomNumberGenerator.new()
 random.seed = 718233
 for biome in 10:
  var center = Catalog.biome_position(biome)
  var records = []
  var batch_nodes = []
  for part in 3:
   var mesh: Mesh
   if part>0 and biome in [1,4,6,8]:
    var crown=SphereMesh.new()
    crown.radial_segments=10
    crown.rings=5
    crown.radius=2.7 if part==1 else 2.0
    crown.height=4.6
    mesh=crown
   else:
    if part==0:
     var trunk=CylinderMesh.new()
     trunk.radial_segments=8
     trunk.bottom_radius=0.45
     trunk.top_radius=0.32
     trunk.height=3.0
     mesh=trunk
    else: mesh=CraftedGeometry.pine_crown(2.5 if part==1 else 1.9,4.5)
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
   if part>0:
    var wind=ShaderMaterial.new()
    wind.shader=preload("res://Shaders/ForestWind.gdshader")
    wind.set_shader_parameter("canopy_tone",Color(Catalog.BIOMES[biome].tree))
    node.material_override=wind
   node.set_meta("near_mesh",mesh)
   var far_mesh: Mesh=mesh
   if part>0:
    if biome in [1,4,6,8]:
     var low=SphereMesh.new()
     low.radial_segments=7; low.rings=3; low.radius=2.7 if part==1 else 2.0; low.height=4.6
     far_mesh=low
    else:
     var low=CylinderMesh.new()
     low.bottom_radius=2.5 if part==1 else 1.9; low.top_radius=0.12; low.height=4.5; low.radial_segments=7
     far_mesh=low
   node.set_meta("far_mesh",far_mesh)
   add_child(node)
   batch_nodes.append(node)
  for i in 100:
   var source=ForestLayout.records()[biome][i]
   var point=source.point
   var scale_value=float(source.scale)
   records.append({"point":point,"scale":scale_value,"regrow":0.0,"blocked":false})
   for part in 3:
    var y = [1.8,4.7,7.1][part]*scale_value
    var transform = Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*scale_value),point+Vector3(0,y,0))
    batch_nodes[part].multimesh.set_instance_transform(i,transform)
    batch_nodes[part].multimesh.set_instance_color(i,Color.WHITE.darkened(float(source.tones[part])))
  var stumps=MultiMeshInstance3D.new()
  var stump_mesh=CylinderMesh.new()
  stump_mesh.top_radius=0.43
  stump_mesh.bottom_radius=0.49
  stump_mesh.height=0.7
  stump_mesh.radial_segments=8
  var stump_mm=MultiMesh.new()
  stump_mm.transform_format=MultiMesh.TRANSFORM_3D
  stump_mm.mesh=stump_mesh
  stump_mm.instance_count=100
  for i in 100: stump_mm.set_instance_transform(i,Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*0.001),records[i].point))
  stumps.multimesh=stump_mm
  stumps.material_override=Models.material(Color("cfab78"))
  add_child(stumps)
  stump_batches.append(stumps)
  trees.append(records)
  tree_batches.append(batch_nodes)
  var boss = Node3D.new()
  boss.position = center+Vector3(0,0,25)
  add_child(boss)
  Models.cylinder(boss,1.5,7,Vector3(0,3.5,0),Color("99714b"))
  Models.cylinder(boss,6,11,Vector3(0,10,0),Color(Catalog.BIOMES[biome].tree).lightened(0.18),0.3)
  boss_labels.append(Models.label(boss,"BOSS",Vector3(0,17,0),35))

func clear_children(parent: Node) -> void:
 for child in parent.get_children():
  parent.remove_child(child)
  child.queue_free()

func rebuild() -> void:
 if world_buildings == null: return
 rebuild_streets()
 clear_children(world_buildings)
 moving_goods.clear()
 machines.clear()
 cranes.clear()
 bins.clear()
 town_name_labels.clear()
 industry_name_labels.clear()
 yard_handlers.clear()
 for i in Game.state.buildings.size():
  var b = Game.state.buildings[i]
  var model = Models.building(b.kind,int(b.level))
  model.position = Game.building_position(i)
  model.rotation_degrees.y = int(b.get("rotation",0))
  world_buildings.add_child(model)
  var floor_mesh=model.get_node_or_null("FactoryFloor")
  if floor_mesh!=null: floor_mesh.visible=true
  var depot_stock=model.get_node_or_null("DepotStock")
  if depot_stock!=null: depot_stock.building_index=i
  var saw = model.get_node_or_null("Saw")
  if saw != null: machines.append({"node":saw,"index":i})
  var mineral = model.get_node_or_null("StonePlant")
  if mineral!=null: mineral.building_index=i
  var processing = model.get_node_or_null("Processing")
  if processing != null: processing.building_index = i
  var beacon=model.get_node_or_null("ProductionBeacon")
  if beacon!=null: beacon.building_index=i
  var handler=model.get_node_or_null("YardHandling")
  if handler!=null:
   handler.building_index=i
   yard_handlers.append(handler)
  for extra in model.get_children():
   if extra.name.begins_with("DepotHandler"):
    extra.building_index=i
    yard_handlers.append(extra)
  if not Game.delivery_owns(i):
   var label=Models.label(model,"%s · %s" % [Catalog.BUILDINGS[b.kind].name,int(b.level)],Vector3(0,float(model.get_meta("height",8.6))+1.4,0),24)
   label.set_meta("building_index",i)
   industry_name_labels.append(label)
  add_approach(model.position,int(b.get("rotation",0)))
  var fill = model.get_node_or_null("SawdustFill")
  if fill!=null:
   var label = Models.label(model,"Spänebox",fill.get_meta("label_point",Vector3(7.5,5.2,-3)),28)
   label.set_meta("building_index",i)
   if b.kind=="sawmill": label.hide()
   else: industry_name_labels.append(label)
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
  var name_label=Models.label(model,"%s · %s" % [TownEvolution.title(h.kind,int(h.level)),int(h.level)],Vector3(0,float(model.get_meta("height",10))+1,0),24)
  name_label.set_meta("home_index",home_index)
  town_name_labels.append(name_label)
  add_approach(model.position,int(h.get("rotation",0)))
 for job in Game.state.jobs:
  if job.type in ["building","home","upgrade","home_upgrade","project"]:
   var model = load("res://Buildings/ConstructionSite.gd").new() if job.has("phases") else Models.construction(1.0-float(job.left)/float(job.total))
   if job.has("phases"): model.job_id=int(job.id)
   if job.type=="home": model.position = Placement.position_of(job,Catalog.home_position(int(job.plot)))
   elif job.type=="home_upgrade": model.position = Game.home_position(int(job.index))
   elif job.type == "upgrade":
    var b = Game.state.buildings[int(job.index)]
    model.position = Game.building_position(int(job.index))
   elif job.type == "project": model.position = Catalog.PROJECTS[int(job.index)].position
   else: model.position = Placement.position_of(job,Catalog.industry_position(int(job.slot)))
   model.rotation_degrees.y = int(job.get("rotation",0))
   world_buildings.add_child(model)
   cranes.append({"node":model.get_node("Crane"),"job":job})
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
 if town_layer!=null: town_layer.rebuild()
 refresh_forest_clearance()
 if landscape!=null: landscape.refresh()
 if delivery_world!=null: delivery_world.rebuild()
 StaticPaintBatch.reduce(world_buildings)
 StaticPaintBatch.reduce(base_streets)
 if town_layer!=null:StaticPaintBatch.reduce(town_layer)
 update_yard_handlers()

func add_approach(point: Vector3, rotation: int) -> void:
 var path = Placement.approach(point,rotation,Game.state.town)
 if path.size()<2: return
 var length = path[0].distance_to(path[1])
 if length>0.1:
  var strip=Models.box(world_buildings,Vector3(2.4,0.06,length),Vector3((path[0].x+path[1].x)/2,0.60,(path[0].z+path[1].z)/2),Color("d9cba7"))
  strip.rotation.y=atan2(path[1].x-path[0].x,path[1].z-path[0].z)

func refresh_forest_clearance() -> void:
 var rectangles = [WorldAccess.HIGHWAY_SITE.grow(3),Rect2(316,70,30,142)]
 for i in Game.state.buildings.size(): rectangles.append(Placement.bounds(Game.building_position(i),int(Game.state.buildings[i].get("rotation",0)),Game.state.buildings[i].kind).grow(3))
 for i in Game.state.homes.size(): rectangles.append(Placement.bounds(Game.home_position(i),int(Game.state.homes[i].get("rotation",0))).grow(3))
 for job in Game.state.jobs:
  if job.type in ["home","building"]:
   var fallback = Catalog.home_position(int(job.plot)) if job.type=="home" else Catalog.industry_position(int(job.slot))
   rectangles.append(Placement.bounds(Placement.position_of(job,fallback),int(job.get("rotation",0)),str(job.get("kind",""))).grow(3))
 for road_record in Game.state.town.roads:
  var radius=float(TownRules.TYPES[road_record.kind].width)/2+2
  for c in road_record.cells:
   var p=Vector2(TownRules.cell(c))
   rectangles.append(Rect2(p-Vector2.ONE*radius,Vector2.ONE*radius*2))
 if actors!=null:
  for actor in actors.get_children():
   if actor.has_meta("forestry_tier"):
    rectangles.append(ForestryMachine.clearance(actor.origin_point))
 for biome in trees.size():
  for i in trees[biome].size():
   var tree = trees[biome][i]
   tree.blocked = false
   for rectangle in rectangles:
    if rectangle.has_point(Vector2(tree.point.x,tree.point.z)): tree.blocked = true; break
   set_tree_visible(biome,i,not tree.blocked and tree.regrow<=0)

 if forest_world!=null:
  forest_world.rendered.clear()
  forest_world.sync_trees(false)

func sync_actors() -> void:
 var stations=[]
 var station_policy=[]
 for index in Game.state.buildings.size():
  if Game.state.buildings[index].kind!="station": continue
  var paused=bool(Game.state.buildings[index].get("paused",false))
  station_policy.append([index,paused])
  if not paused: stations.append(index)
 if stations.is_empty():
  for entry in station_policy: stations.append(entry[0])
 var signature = "%s/%s/%s/%s/%s/%s" % [Game.state.workers,Game.state.biome,Game.state.quality,Game.state.tool,Game.state.delivery.active,station_policy]
 if signature == actor_signature: return
 actor_signature = signature
 clear_children(actors)
 var staff = mini(int(Game.state.workers),8 if Game.state.quality == 0 else 16)
 var factories = []
 for i in Game.state.buildings.size():
  if (Catalog.RECIPES.has(Game.state.buildings[i].kind) and Game.state.buildings[i].kind!="sawmill") or Game.state.buildings[i].kind=="stoneworks": factories.append(i)
 var operators = mini(mini(staff/3,factories.size()),2 if Game.state.quality==0 else 6)
 var cabin_index=-1
 for i in Game.state.buildings.size():
  if Game.state.buildings[i].kind=="cabin": cabin_index=i; break
 var forestry_slots=staff-operators-(1 if staff>=4 and cabin_index>=0 else 0)
 var forestry_machines=mini(2 if Game.state.quality==0 else 4,forestry_slots/3) if int(Game.state.tool)>=10 else 0
 for i in operators:
  var worker = TimberWorker.new()
  worker.role = "operator"
  worker.variant_id=i
  worker.production_index = factories[i]
  worker.origin_point = Game.building_position(factories[i])+Basis.from_euler(Vector3(0,deg_to_rad(Game.state.buildings[factories[i]].get("rotation",0)),0))*Vector3(-3.5,0,2.7)
  worker.facing = deg_to_rad(Game.state.buildings[factories[i]].get("rotation",0))+PI/2
  actors.add_child(worker)
 for i in staff-operators:
  var neighbor = i==staff-operators-1 and staff>=4 and cabin_index>=0
  if i<forestry_machines and not neighbor:
   var machine=ForestryMachine.new()
   machine.tier=int(Game.state.tool)
   machine.station_index=stations[i%stations.size()] if not stations.is_empty() else -1
   machine.origin_point=Catalog.biome_position(int(Game.state.biome))+Vector3([-26,-10,10,26][i%4],0,-5)
   machine.phase=i*4.5
   actors.add_child(machine)
   continue
  var worker = TimberWorker.new()
  worker.production_index=stations[i%stations.size()] if not stations.is_empty() else -1
  var forester=i-forestry_machines
  var forester_count=maxi(1,forestry_slots-forestry_machines)
  if not neighbor: worker.configure_forest(forester,forester_count)
  worker.variant_id=i+operators
  worker.phase = i*1.7
  worker.pace = 0.7+(i%4)*0.1
  if neighbor:
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
 var inhabited=[]
 for i in Game.state.homes.size():
  if int(Catalog.HOMES[Game.state.homes[i].kind].people)>0: inhabited.append(i)
 for i in mini(Game.residents(),6):
  var resident = TimberWorker.new()
  resident.role = "resident"
  resident.variant_id=i+staff
  var home_index=inhabited[i%inhabited.size()]
  var turn=Basis.from_euler(Vector3(0,deg_to_rad(Game.state.homes[home_index].get("rotation",0)),0))
  var point=Game.home_position(home_index)
  resident.origin_point = point+turn*Vector3(-4.5,0,10.4)
  resident.destination = point+turn*Vector3(4.5,0,10.4)
  resident.phase = i*2.1
  resident.pace = 0.55
  actors.add_child(resident)
 refresh_forest_clearance()
 if landscape!=null: landscape.refresh()

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
 var measured=RuntimeStats.begin_work()
 _process_measured(delta)
 RuntimeStats.end_work("Welt",measured)

func _process_measured(delta: float) -> void:
 if hold_pointer>=0 and not hold_consumed and touches.size()==1 and not pinch_active and drag_distance<8 and placement.is_empty() and Time.get_ticks_msec()-hold_started>=550:
  hold_consumed=pick_tall_home(hold_point,0,true)
 update_camera(delta)
 handler_clock+=delta
 if handler_clock>=0.5:
  handler_clock=0
  update_yard_handlers()
  var render_scale=RuntimeStats.resolution_scale(get_window().size,int(Game.state.quality),bool(Game.state.ux.get("adaptive_detail",true)),OS.has_feature("mobile"),photo!=null and photo.active)
  get_viewport().scaling_3d_scale=render_scale
 time += delta
 var animate=bool(Game.state.ux.motion) and bool(Game.state.ambient_enabled)
 if animate: wind_clock+=delta
 for batch in tree_batches:
  for part in [1,2]:
   var wind=Atmosphere.wind(Game.state).normalized()
   batch[part].material_override.set_shader_parameter("wind_direction",Vector2(wind.x,wind.z))
   batch[part].material_override.set_shader_parameter("wind_clock",wind_clock)
   batch[part].material_override.set_shader_parameter("wind_strength",1.0 if animate and Game.state.quality>0 else 0.0)
 for fall in falling_trees:
  if fall.left<=0: continue
  fall.left=maxf(0,float(fall.left)-delta)
  fall.node.visible=fall.left>0 and animate and fall.node.position.distance_to(focus)<zoom*1.6+40
  var t=clampf((1.8-float(fall.left))/1.1,0,1)
  var tipped=Vector3.UP.lerp(fall.direction,t*t).normalized()
  fall.node.quaternion=Quaternion(Vector3.UP,tipped)
  fall.node.scale=Vector3.ONE*float(fall.size)*minf(1,float(fall.left)*2)
 if not placement.is_empty():
  placement_check_clock+=delta
  if placement_check_clock>=0.5: placement_check_clock=0; update_ghost()
 sync_actors()
 sun.shadow_enabled=Game.state.quality>0 and not (Game.state.ux.get("adaptive_detail",true) and RuntimeStats.low_detail) and zoom<300
 update_forest_detail()
 sun.directional_shadow_max_distance=clampf(zoom*1.2,160,260)
 var daylight = clampf(sin((float(Game.state.time)-6.0)/24.0*TAU),0.0,1.0)
 sun.light_energy = 0.24+daylight*0.45
 sun.light_color=Color("b6cce6").lerp(Color("fff0d5"),daylight)
 environment_resource.ambient_light_energy = 0.38+daylight*0.06
 SurfaceLibrary.daylight(daylight)
 var burning_homes={}
 for incident in Game.state.city_services.fires: burning_homes[int(incident.target_ref.index)]=true
 for label in town_name_labels:
  var selected=hud.ux.selection.get("kind","")=="home" and int(hud.ux.selection.get("index",-1))==int(label.get_meta("home_index",-1))
  label.visible=(zoom<70 or selected) and not burning_homes.has(label.get_meta("home_index",-1))
 for label in industry_name_labels:
  label.visible=zoom<70 or (hud.ux.selection.get("kind","")=="building" and int(hud.ux.selection.get("index",-1))==int(label.get_meta("building_index",-1)))
 for label in biome_labels: label.visible=zoom<300
 for label in boss_labels: label.visible=zoom<180
 environment_resource.background_color = Color("294654").lerp(Color("53bbd3"),daylight)
 environment_resource.fog_enabled = int(Game.state.weather)==3 and Game.state.quality>0
 environment_resource.fog_light_color = Color("9ebdb5")
 environment_resource.fog_density = 0.0002
 sun.rotation_degrees.x = -25-daylight*40
 weather.position = focus+Vector3(0,36,0)
 weather.emitting = int(Game.state.weather) == 2 and Game.state.quality > 0 and animate
 for machine in machines:
  if animate and float(Game.flow.get("building:%s" % machine.index,0))>0: machine.node.rotate_y(delta*8)
 for crane in cranes:
  var job=crane.job
  if animate and (not job.has("phases") or (not job.paused and CrewTransport.working(Game.state,job)>0 and ConstructionRules.phase_ready(job))):
   crane.node.rotation.y = sin(time*0.45)*0.2
 for item in moving_goods:
  if float(Game.flow.get("building:%s" % item.index,0)) > 0:
   item.phase = fmod(float(item.phase)+delta*0.18,1.0)
  item.mesh.position = item.origin+Basis.from_euler(item.rotation)*Vector3(5,2.1,4+item.phase*8)
 for bin in bins:
  var fraction = clampf(float(Game.state.resources.sawdust)/Game.capacity(),0,1)
  bin.fill.scale.y = maxf(fraction,0.03)
  bin.fill.position.y = 0.7+1.35*fraction
  bin.label.text = "SPÄNE · %s %%" % int(fraction*100)

func set_tree_visible(biome: int, index: int, visible_tree: bool) -> void:
 var tree = trees[biome][index]
 for part in 3:
  var size_value = float(tree.scale) if visible_tree else 0.001
  var y = [1.8,4.7,7.1][part]*size_value
  tree_batches[biome][part].multimesh.set_instance_transform(index,Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*size_value),tree.point+Vector3(0,y,0)))

 var stump_size=float(tree.scale) if not visible_tree and not tree.blocked and tree.regrow>0 else 0.001
 stump_batches[biome].multimesh.set_instance_transform(index,Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*stump_size),tree.point+Vector3.UP*0.35*stump_size))

func on_harvested(_biome: int, _amount: float) -> void:
 if forest_world!=null: forest_world.sync_trees(true)

func show_falling_tree(biome: int, index: int) -> void:
 if not Game.state.ux.motion or not Game.state.ambient_enabled: return
 var tree=trees[biome][index]
 if tree.point.distance_to(focus)>zoom*1.6+40: return
 var fall=falling_trees[next_fall]
 next_fall=(next_fall+1)%falling_trees.size()
 fall.node.position=tree.point
 fall.node.quaternion=Quaternion.IDENTITY
 fall.direction=(tree.point-focus+Vector3(0.1,0,0.1)).normalized()
 fall.direction.y=0.08
 fall.size=tree.scale
 fall.left=1.8
 fall.node.show()
 for part in 3:
  var piece=fall.node.get_child(part)
  piece.mesh=tree_batches[biome][part].get_meta("near_mesh")
  piece.material_override=Models.material(Color("ad8556") if part==0 else Color(Catalog.BIOMES[biome].tree))

func make_chip_pool() -> void:
 for i in 4:
  var tree=Node3D.new()
  add_child(tree)
  Models.cylinder(tree,0.42,3,Vector3(0,1.8,0),Color("ad8556"))
  Models.cylinder(tree,2.5,4.5,Vector3(0,4.7,0),Color("50975b"),0.1)
  Models.cylinder(tree,1.9,4.5,Vector3(0,7.1,0),Color("50975b"),0.1)
  tree.hide()
  falling_trees.append({"node":tree,"left":0.0,"size":1.0,"direction":Vector3.RIGHT})
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

func update_yard_handlers() -> void:
 yard_handlers.sort_custom(func(a,b): return a.global_position.distance_squared_to(view_focus)<b.global_position.distance_squared_to(view_focus))
 for i in yard_handlers.size(): yard_handlers[i].presentation_enabled=i<(2 if Game.state.quality==0 or RuntimeStats.low_detail else 6)

func clamp_camera() -> void:
 focus.x=clampf(focus.x,-350,350)
 focus.z=clampf(focus.z,-245,245)
 focus.y=0
 zoom=clampf(zoom,40,650)

func apply_camera() -> void:
 camera.size=view_zoom
 var offset=Basis(Vector3.UP,camera_yaw)*Vector3(90,120,130).normalized()
 camera.position=view_focus+offset*maxf(198.5,view_zoom*1.4)
 camera.look_at(view_focus)
 if landscape!=null: landscape.update_view()
 update_forest_detail()

# Explicit placement/setup calls snap; navigation commands use ease_camera().
func set_camera() -> void:
 clamp_camera()
 view_focus=focus
 view_zoom=zoom
 camera_transition=false
 pan_velocity=Vector3.ZERO
 apply_camera()

func ease_camera() -> void:
 clamp_camera()
 pan_velocity=Vector3.ZERO
 camera_transition=bool(Game.state.ux.motion)
 if not camera_transition: set_camera()

func update_camera(delta: float) -> void:
 var blocked=hud!=null and (hud.overlay.visible or hud.ux.panels_visible())
 if blocked or not placement.is_empty() or not Game.state.ux.motion: pan_velocity=Vector3.ZERO
 if camera_transition and not Game.state.ux.motion: set_camera()
 if camera_transition:
  var weight=1-exp(-12*delta)
  view_focus=view_focus.lerp(focus,weight)
  view_zoom=lerpf(view_zoom,zoom,weight)
  if view_focus.distance_to(focus)<0.02 and absf(view_zoom-zoom)<0.02:
   view_focus=focus
   view_zoom=zoom
   camera_transition=false
  apply_camera()
 elif not dragging and not right_drag and touches.is_empty() and pan_velocity.length()>0.1:
  focus+=pan_velocity*minf(delta,0.05)
  clamp_camera()
  pan_velocity*=exp(-9*delta)
  view_focus=focus
  view_zoom=zoom
  apply_camera()

func update_forest_detail() -> void:
 var reduced=RuntimeStats.low_detail and not (photo!=null and photo.active)
 var key=Vector4(snappedf(view_focus.x,16),snappedf(view_focus.z,16),snappedf(view_zoom,12),float(Game.state.quality)+(10 if reduced else 0))
 if key==forest_detail_key: return
 forest_detail_key=key
 for i in tree_batches.size():
  var distance=Catalog.biome_position(i).distance_to(view_focus)
  var near=not reduced and view_zoom<180 and Game.state.quality>0 and distance<view_zoom*0.8+65
  stump_batches[i].visible=distance<view_zoom*1.3+60
  for node in tree_batches[i]:
   node.multimesh.mesh=node.get_meta("near_mesh" if near else "far_mesh")
   node.visible=distance<view_zoom*1.3+60

func focus_at(point: Vector3) -> void:
 focus = point
 zoom = 86.0
 ease_camera()

func camera_action(action: String) -> void:
 if action=="benchmark":
  if performance_tour==null:
   performance_tour=load("res://Components/PerformanceTour.gd").new()
   performance_tour.world=self
   add_child(performance_tour)
  return
 if action=="photo":
  if photo!=null: photo.enter()
  return
 match action:
  "+": zoom = maxf(40,zoom*0.82)
  "−": zoom = minf(650,zoom*1.22)
  "home": focus = Game.building_position(mini(1,Game.state.buildings.size()-1)); zoom = 96
  "world": focus = Vector3(0,0,20); zoom = 390
 ease_camera()

# A tap must refer to the same view on press and release. Otherwise a smooth
# focus transition can slide a small truck out from under the finger.
func stop_camera_navigation() -> void:
 focus=view_focus
 zoom=view_zoom
 camera_transition=false
 pan_velocity=Vector3.ZERO

func _unhandled_input(event: InputEvent) -> void:
 if hud!=null and hud.overlay.visible: return
 if photo!=null and photo.active and photo.gallery.visible: return
 if event is InputEventMouse and event.device==-1: return
 if event is InputEventMouseButton:
  if event.button_index == MOUSE_BUTTON_WHEEL_UP: camera_action("+")
  elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: camera_action("−")
  elif event.button_index == MOUSE_BUTTON_RIGHT: right_drag=event.pressed
  elif event.button_index == MOUSE_BUTTON_LEFT:
   dragging = event.pressed
   if event.pressed:
    stop_camera_navigation()
    drag_distance = 0
    last_pointer = event.position
    start_network_drag(event.position)
   elif drag_distance < 12: tap_world(event.position)
 elif event is InputEventMouseMotion and (dragging or right_drag):
  if not placement.is_empty() and not right_drag:
   drag_distance+=event.relative.length()
   place_at_screen(event.position)
  else: pan(event.relative)
 elif event is InputEventScreenTouch:
  if event.pressed:
   stop_camera_navigation()
   hold_pointer=event.index
   hold_started=Time.get_ticks_msec()
   hold_point=event.position
   hold_consumed=false
   touches[event.index] = event.position
   if touches.size()>1: pinch_active=true
   else:
    pinch_active=false
    drag_distance = 0
    start_network_drag(event.position)
  else:
   if event.index==hold_pointer: hold_pointer=-1
   if touches.size() == 1 and drag_distance < 12 and not pinch_active and not event.canceled and not hold_consumed: tap_world(event.position)
   touches.erase(event.index)
   if event.canceled: pan_velocity=Vector3.ZERO
   pinch_distance = 0
   if touches.is_empty(): pinch_active=false
 elif event is InputEventScreenDrag:
  touches[event.index] = event.position
  if touches.size() >= 2:
   var values = touches.values()
   var distance = values[0].distance_to(values[1])
   if pinch_distance > 0: zoom = clampf(zoom*pinch_distance/maxf(distance,1),40,650)
   if not placement.is_empty(): pan(event.relative*0.5)
   pinch_distance = distance
   drag_distance = 100
   set_camera()
  else:
   if placement.is_empty(): pan(event.relative)
   else:
    drag_distance+=event.relative.length()
    place_at_screen(event.position)

func pan(relative: Vector2) -> void:
 if camera_transition:
  focus=view_focus
  zoom=view_zoom
  camera_transition=false
 var previous=focus
 drag_distance += relative.length()
 var ratio = zoom/get_viewport().get_visible_rect().size.y
 focus -= camera.global_basis.x*relative.x*ratio
 var forward = Vector3(camera.global_basis.z.x,0,camera.global_basis.z.z).normalized()
 focus -= forward*relative.y*ratio*1.3
 focus.y = 0
 clamp_camera()
 var now=Time.get_ticks_msec()
 var seconds=clampf(float(now-last_pan_time)/1000.0,0.016,0.06)
 var velocity=(focus-previous)/seconds
 if velocity.length()>180: velocity=velocity.normalized()*180
 pan_velocity=pan_velocity.lerp(velocity,0.5) if Game.state.ux.motion else Vector3.ZERO
 last_pan_time=now
 view_focus=focus
 view_zoom=zoom
 apply_camera()

func tap_world(screen: Vector2) -> void:
 if photo!=null and photo.active: return
 var plane = Plane(Vector3.UP,0)
 var point = plane.intersects_ray(camera.project_ray_origin(screen),camera.project_ray_normal(screen))
 if point == null: return
 if not placement.is_empty():
  if placement.get("network",false):
   network_at(point,true)
   return
  var next=Placement.snap(point)
  if next!=placement_point:
   preview_history.append({"point":placement_point,"rotation":placement_rotation})
   while preview_history.size()>24: preview_history.pop_front()
  placement_point = next
  update_ghost()
  return
 if selection_world!=null:
  var truck=selection_world.pick_truck(screen)
  if not truck.is_empty(): hud.ux.select_truck(truck); return
 if town_layer!=null and town_layer.tap_rent(screen): return
 if pick_tall_home(screen): return
 for stop in Game.state.town.stops:
  if point.distance_to(TownRules.point(TownRules.cell(stop.cell)))<8:
   hud.open_menu("transit")
   return
 for i in Game.state.buildings.size():
  var b = Game.state.buildings[i]
  if b.kind=="sawmill":
   var bin_position = Game.building_position(i)+Basis(Vector3.UP,deg_to_rad(int(b.get("rotation",0))))*Vector3(7.5,0,-3)
   if point.distance_to(bin_position)<3.5: hud.open_menu("sawdust"); return
  if Placement.bounds(Game.building_position(i),int(b.get("rotation",0)),b.kind).has_point(Vector2(point.x,point.z)):
   hud.ux.select_building(i)
   return
 for job in Game.state.jobs:
  if Placement.bounds(job_position(job),int(job.get("rotation",0)),str(job.get("kind",""))).has_point(Vector2(point.x,point.z)):
   if job.has("id"): hud.ux.select_job(int(job.id))
   else: hud.open_menu("construction")
   return
 for i in Game.state.homes.size():
  if Placement.bounds(Game.home_position(i),int(Game.state.homes[i].get("rotation",0))).has_point(Vector2(point.x,point.z)):
   hud.ux.select_building(i,true)
   return
 if WorldAccess.HIGHWAY_SITE.has_point(Vector2(point.x,point.z)):
  hud.open_menu("export")
  return
 for i in 10:
  if point.distance_to(Catalog.biome_position(i)) < 46:
   if i < Game.state.unlocked:
    Game.state.biome = i
    Game.chop()
   else: Game.notice.emit("Dieses Biom zuerst im Welt-Menü freischalten")
   return
 for i in Game.city_plot_count():
  if point.distance_to(Catalog.home_position(i))<12:
   hud.show_plot(i)
   return

func begin_placement(request: Dictionary) -> void:
 if hud.get("ux")!=null: hud.ux.hide_panels(true)
 cancel_placement()
 preview_history.clear()
 placement = request.duplicate(true)
 if placement.get("network",false):
  if placement.has("overview"):
   focus=Vector3(float(placement.overview[0]),0,float(placement.overview[1]))
   zoom=float(placement.get("zoom",zoom))
   set_camera()
  road_anchor=null
  road_endpoint=null
  road_horizontal=true
  placement_point=focus
  ghost=Node3D.new()
  add_child(ghost)
  hud.show_placement(placement)
  update_network_ghost()
  return
 var city = bool(placement.get("city",false))
 var index = int(placement.get("index",-1))
 if city and index<0 and placement.kind=="townhall": placement.plot=Journey.HALL_PLOT
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
 placement_point = Game.free_position(preferred,placement_rotation,-1 if city else index,index if city else -1,str(placement.kind) if not city else "")
 if not is_finite(placement_point.x): placement_point=Placement.snap(focus)
 ghost = Node3D.new()
 add_child(ghost)
 var preview_level=int((Game.state.homes if city else Game.state.buildings)[index].level) if index>=0 else 1
 var model = Models.building(placement.kind,preview_level,city)
 if placement.kind=="sawmill" and index>=0 and not city:
  for i in 3: model.get_node("Processing/Line%s" % i).visible=i<SawmillProduction.line_count(Game.state,index)
 ghost.add_child(model)
 var mat = Models.material(Color(1,1,1,0.45)).duplicate()
 mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 tint_preview(model,mat)
 var footprint=Placement.size_for(0,str(placement.kind) if not city else "")
 ghost_plate = Models.box(ghost,Vector3(footprint.x,0.2,footprint.y),Vector3(0,0.9,0),Color("5bfba0"))
 hud.show_placement(placement)
 update_ghost()

func place_at_screen(screen: Vector2) -> void:
 var point = Plane(Vector3.UP,0).intersects_ray(camera.project_ray_origin(screen),camera.project_ray_normal(screen))
 if point!=null:
  if placement.get("network",false):
   network_at(point,false)
   return
  var next=Placement.snap(point)
  if next!=placement_point:
   preview_history.append({"point":placement_point,"rotation":placement_rotation})
   while preview_history.size()>24: preview_history.pop_front()
  placement_point=next
  update_ghost()

func update_ghost() -> void:
 if ghost==null: return
 if placement.get("network",false): update_network_ghost(); return
 ghost.position=placement_point
 ghost.rotation_degrees.y=placement_rotation
 var city=bool(placement.get("city",false))
 var index=int(placement.get("index",-1))
 var reason=Game.placement_reason(placement_point,placement_rotation,-1 if city else index,index if city else -1,str(placement.kind) if not city else "")
 if reason.is_empty() and index>=0: reason=Game.move_reason(index,city)
 if reason.is_empty() and index<0:
  var definition=(Catalog.HOMES if city else Catalog.BUILDINGS)[placement.kind]
  var price=float(definition.cost)*Game.difficulty() if city else Game.cost_for(placement.kind)
  if float(Game.state.coins)<price: reason="Es fehlen %s Münzen" % Catalog.number(price-float(Game.state.coins))
  elif city and Game.company_level()<4 and placement.kind!="townhall":
   for key in definition.materials:
    if float(Game.state.resources[key])<float(definition.materials[key]): reason="Es fehlt: %s" % Catalog.RESOURCES[key]; break
 update_access_preview(reason)
 ghost_plate.material_override=Models.material(Color("43e69a") if reason.is_empty() else Color("f16c5d"))
 hud.update_placement(reason)
 hud.placement_undo.disabled=preview_history.is_empty()
 if reason.is_empty():
  var access=PlacementAccess.describe(Game.state,placement_point,placement_rotation,str(placement.kind) if not city else "")
  if not access.connected: ghost_plate.material_override=Models.material(Color("e7ad43"))
  var extent=Placement.size_for(placement_rotation,str(placement.kind) if not city else "")
  hud.placement_hint.text="✓ Baufläche %s × %s m · %s" % [roundi(extent.x),roundi(extent.y),access.text]

func update_access_preview(reason: String) -> void:
 if access_preview==null:
  access_preview=Node3D.new()
  access_preview.name="PlacementAccess"
  add_child(access_preview)
 clear_children(access_preview)
 var access=PlacementAccess.describe(Game.state,placement_point,placement_rotation,str(placement.kind))
 if access.path.size()<2: return
 var a: Vector3=access.path[0]
 var b: Vector3=access.path[1]
 var length=a.distance_to(b)
 var color=Color("3bafbe") if access.connected and reason.is_empty() else Color("df634b")
 for i in maxi(1,ceili(length/2)):
  var at=a.lerp(b,(i+0.5)/maxf(1,ceili(length/2)))+Vector3.UP*0.75
  var marker=Models.box(access_preview,Vector3(0.6,0.08,1.1),at,color)
  marker.rotation.y=atan2(b.x-a.x,b.z-a.z)
 Models.bake(access_preview)

func placement_action(action: String) -> void:
 if placement.is_empty(): return
 if action=="cancel": cancel_placement(); return
 if action=="undo":
  if placement.get("network",false):
   if road_endpoint!=null: road_endpoint=null
   else: road_anchor=null
   update_network_ghost()
  elif not preview_history.is_empty():
   var old=preview_history.pop_back()
   placement_point=old.point
   placement_rotation=int(old.rotation)
   update_ghost()
  return
 if placement.get("network",false): network_action(action); return
 if action=="rotate":
  preview_history.append({"point":placement_point,"rotation":placement_rotation})
  placement_rotation=posmod(placement_rotation+90,360)
  update_ghost()
  return
 if action!="confirm": return
 var city=bool(placement.get("city",false))
 var index=int(placement.get("index",-1))
 var success=false
 if index>=0: success=Game.move_building(index,placement_point,placement_rotation,city)
 elif city: success=Game.order_home(placement.kind,int(placement.plot),placement_point,placement_rotation)
 else: success=Game.order_building(placement.kind,placement_point,placement_rotation)
 if success:
  hud.ux.feedback("build")
  cancel_placement()

func cancel_placement() -> void:
 if access_preview!=null:
  access_preview.queue_free()
  access_preview=null
 placement={}
 road_anchor=null
 road_endpoint=null
 if ghost!=null:
  remove_child(ghost)
  ghost.queue_free()
  ghost=null
 if hud!=null: hud.hide_placement()


func tint_preview(root: Node, mat: Material) -> void:
 for child in root.get_children():
  if child is MeshInstance3D: child.material_override=mat
  tint_preview(child,mat)

func network_at(point: Vector3, tapped: bool) -> void:
 if not tapped and road_endpoint==TownRules.snap(point): return
 placement_point=TownRules.point(TownRules.snap(point))
 if placement.kind!="bus_stop":
  if road_anchor==null:
   if tapped: road_anchor=TownRules.snap(point)
  else: road_endpoint=TownRules.snap(point)
 update_network_ghost()

func update_network_ghost() -> void:
 if ghost==null: return
 hud.placement_undo.disabled=road_anchor==null
 clear_children(ghost)
 var reason=""
 var price=0.0
 if placement.kind=="group":
  if road_anchor==null: reason="Einen Bereich mit Gebäuden aufziehen"
  elif road_endpoint==null: reason="Bis zur anderen Ecke ziehen"
  else:
   var a=TownRules.point(road_anchor)
   var b=TownRules.point(road_endpoint)
   var extent=Vector2(absf(a.x-b.x),absf(a.z-b.z))
   if extent.x<4 or extent.y<4: reason="Einen größeren Bereich markieren"
   var rectangle={"bounds":[minf(a.x,b.x),minf(a.z,b.z),extent.x,extent.y]}
   if UXRules.group_members(Game.state,rectangle).is_empty(): reason="Mindestens ein Gebäude markieren"
   Models.box(ghost,Vector3(maxf(1,extent.x),0.1,maxf(1,extent.y)),(a+b)/2+Vector3(0,0.9,0),Color("68e3ad"))
  hud.placement_title.text="VIERTEL MARKIEREN · KOSTENLOS"
  hud.update_placement(reason)
  return
 if placement.kind=="bus_stop":
  reason=Game.stop_reason(placement_point)
  var c=TownRules.nearest(placement_point,TownRules.road_cells(Game.state.town))
  var model=TownWorld.stop_model()
  ghost.add_child(model)
  model.position=placement_point if c==null else TownRules.point(c)
  if c!=null and TownRules.road_cells(Game.state.town).has(c+Vector2i(0,4)): model.rotation.y=PI/2
  price=300*Game.difficulty()
 else:
  if road_anchor==null: reason="Zuerst den Startpunkt auf der Karte antippen"
  elif road_endpoint==null or road_endpoint==road_anchor: reason="Jetzt das Ziel antippen oder den Weg ziehen"
  else:
   var cells=TownRules.path(road_anchor,road_endpoint,road_horizontal)
   reason=Game.road_reason(placement.kind,cells)
   price=Game.road_cost(placement.kind,cells)
   var corner=Vector2i(road_endpoint.x,road_anchor.y) if road_horizontal else Vector2i(road_anchor.x,road_endpoint.y)
   TownWorld.draw_segment(ghost,TownRules.point(road_anchor),TownRules.point(corner),placement.kind)
   TownWorld.draw_segment(ghost,TownRules.point(corner),TownRules.point(road_endpoint),placement.kind)
  if road_anchor!=null: Models.cylinder(ghost,1,0.25,TownRules.point(road_anchor)+Vector3(0,1,0),Color("ffffff"))
 if reason.is_empty() and price>float(Game.state.coins): reason="Es fehlen %s Münzen" % Catalog.number(price-float(Game.state.coins))
 var mat=Models.material(Color("69ebad") if reason.is_empty() else Color("ee8972"))
 tint_preview(ghost,mat)
 hud.placement_title.text="%s · %s Münzen" % ["Haltestelle" if placement.kind=="bus_stop" else TownRules.TYPES[placement.kind].name,Catalog.number(price)]
 hud.update_placement(reason)
 if reason.is_empty(): hud.placement_hint.text="Straßenrand frei · bestätigen" if placement.kind=="bus_stop" else "Strecke frei · Kurve wechseln oder bestätigen"

func network_action(action: String) -> void:
 if action=="rotate": road_horizontal=not road_horizontal; update_network_ghost(); return
 if action!="confirm": return
 var success=false
 if placement.kind=="group":
  if road_anchor!=null and road_endpoint!=null: success=Game.create_group(TownRules.point(road_anchor),TownRules.point(road_endpoint),"Viertel %s" % int(Game.state.ux.next_group))>=0
 elif placement.kind=="bus_stop": success=Game.build_stop(placement_point)
 elif road_anchor!=null and road_endpoint!=null: success=Game.build_road(placement.kind,TownRules.path(road_anchor,road_endpoint,road_horizontal))
 if success:
  var grouping=placement.kind=="group"
  hud.ux.feedback("build")
  cancel_placement()
  hud.open_menu("districts" if grouping else "networks")


func job_position(job: Dictionary) -> Vector3:
 if job.type=="home": return Placement.position_of(job,Catalog.home_position(int(job.plot)))
 if job.type=="home_upgrade": return Game.home_position(int(job.index))
 if job.type=="upgrade": return Game.building_position(int(job.index))
 if job.type=="project": return Catalog.PROJECTS[int(job.index)].position
 return Placement.position_of(job,Catalog.industry_position(int(job.get("slot",0))))


func start_network_drag(screen: Vector2) -> void:
 if placement.is_empty() or not placement.get("network",false) or placement.kind=="bus_stop" or road_anchor!=null: return
 var point=Plane(Vector3.UP,0).intersects_ray(camera.project_ray_origin(screen),camera.project_ray_normal(screen))
 if point!=null:
  road_anchor=TownRules.snap(point)
  update_network_ghost()

func pick_tall_home(screen: Vector2, minimum_height: float=12,move: bool=false) -> bool:
 var best=-1
 var closest=INF
 var origin=camera.project_ray_origin(screen)
 var direction=camera.project_ray_normal(screen)
 # Compare all solid building volumes, so a tower is not selected through a
 # nearer factory and its upper floors remain tappable above the ground plot.
 for model in world_buildings.get_children():
  var is_home=model.has_meta("town_kind")
  var index=-1
  if is_home:
   for i in Game.state.homes.size():
    if model.position.distance_to(Game.home_position(i))<0.1: index=i; break
  var extent=Placement.size_for(roundi(model.rotation_degrees.y),str(model.get_meta("kind","")))
  var top=float(model.get_meta("height",9.0))
  var volume=AABB(model.position-Vector3(extent.x/2,0,extent.y/2),Vector3(extent.x,top,extent.y))
  var hit=volume.intersects_ray(origin,direction)
  if hit==null: continue
  var distance=origin.distance_squared_to(hit)
  if distance>=closest: continue
  closest=distance
  best=index if is_home and top>=minimum_height else -1
 if best<0: return false
 if move:
  hud.request_placement({"kind":Game.state.homes[best].kind,"city":true,"index":best})
 else: hud.ux.select_building(best,true)
 return true
