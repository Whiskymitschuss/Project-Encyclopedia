extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.city_services.enabled=false
 game.state.companion_enabled=false
 game.flow.clear()
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene.set_process(false)
 for node in [scene.fauna,scene.spatial_audio,scene.wet_weather,scene.upgrade_reveal,scene.production_alerts]: node.set_process(false)
 var atmosphere=load("res://Components/Atmosphere.gd")
 var wind=atmosphere.wind(game.state)
 check(wind.y==0 and wind.length()>0.9,"A real horizontal wind exists without changing the weather schedule")
 var chimney=scene.world_buildings.get_child(3).get_node("ChimneySmoke")
 chimney.get_parent().rotation_degrees.y=90
 chimney._process(0)
 var actual=chimney.smoke.global_basis*chimney.smoke.gravity
 check(Vector3(actual.x,0,actual.z).normalized().dot(wind.normalized())>0.99,"A rotated chimney still emits down the common world wind")
 for cut_action in 6: game.chop() # Consume one entire real 24-wood tree.
 var before=game.state.duplicate(true)
 scene.focus=Catalog.biome_position(0)
 scene.set_camera()
 scene.on_harvested(0,1)
 var cut=-1
 for i in scene.trees[0].size():
  if scene.trees[0][i].regrow>0: cut=i; break
 check(cut>=0,"The forest view mirrors a genuinely completed cut")
 scene.forest_world.sync_trees(false)
 check(game.state==before,"Tree presentation and stumps never add wood or alter the save")
 var sound=scene.spatial_audio.sound("creak")
 check(sound.data.size()>10000 and sound==scene.spatial_audio.sound("creak"),"Wood feedback contains cached PCM audio")
 check(scene.spatial_audio.sound("siren").loop_mode==AudioStreamWAV.LOOP_FORWARD,"The siren is a continuous reusable sound")
 check(scene.spatial_audio.loops.size()==6 and scene.spatial_audio.voices.size()==4,"Positional audio has ten fixed voices rather than unbounded players")
 scene.spatial_audio._process(0)
 check(scene.spatial_audio.listener.position.distance_to(scene.view_focus)<11,"The sound listener is near the viewed ground despite the high isometric camera")
 var surfaces=load("res://Buildings/SurfaceLibrary.gd")
 surfaces.weather(0)
 var asphalt=surfaces.material(Color("596f75"),"asphalt")
 var dry=asphalt.albedo_color
 game.state.weather=2
 before=game.state.duplicate(true)
 scene.wet_weather._process(5)
 check(asphalt.roughness<0.3 and asphalt.albedo_color.v<dry.v,"Actual rain darkens roads and lowers their roughness")
 check(scene.wet_weather.puddles.visible and scene.wet_weather.puddles.multimesh.visible_instance_count==28,"Rain exposes a bounded puddle batch")
 check(surfaces.material(Color("84979a"),"roof").roughness<0.3,"Roofs built during rain inherit wet weather immediately")
 check(game.state==before,"Wet surfaces do not modify resources, weather timing or save state")
 game.state.weather=0
 scene.wet_weather._process(30)
 check(asphalt.albedo_color==dry and asphalt.roughness>0.8,"Roads fully dry again instead of permanently changing shared materials")
 var fauna=scene.fauna
 check(fauna.animals.size()==9,"Wildlife uses nine fixed models")
 fauna.on_cut(0,1)
 fauna._process(0.2)
 var birds=0
 var rabbits=0
 for a in fauna.animals:
  if a.valid and a.bird: birds+=1
  if a.valid and not a.bird: rabbits+=1
 check(birds==6 and rabbits==3,"The real forest has both birds and rabbits")
 var rabbit=fauna.animals[6]
 check(rabbit.flee>0,"Nearby harvesting provokes wildlife movement")
 game.state.ux.motion=false
 var still=rabbit.node.position
 fauna._process(2)
 check(still==rabbit.node.position,"Reduced motion immediately freezes wildlife")
 game.state.ux.motion=true
 game.state.quality=0
 fauna._process(0)
 var visible=0
 for a in fauna.animals:
  if a.node.visible: visible+=1
 check(visible<=4 and rabbit.node.visible,"Battery mode retains at most three birds and one rabbit")
 game.state.quality=1
 var initial=scene.view_focus
 before=game.state.duplicate(true)
 scene.focus_at(Vector3(44,0,80))
 check(scene.view_focus==initial and scene.focus==Vector3(44,0,80),"Focus navigation starts from the current view rather than snapping")
 scene.update_camera(0.1)
 check(scene.view_focus!=initial and scene.view_focus.distance_to(scene.focus)>1,"Camera moves towards the chosen focus over time")
 for i in 100: scene.update_camera(0.016)
 check(scene.view_focus.distance_to(scene.focus)<0.1 and absf(scene.view_zoom-86)<0.1,"Smooth navigation reliably reaches the intended building")
 scene.pan(Vector2(-18,4))
 var release=scene.focus
 scene.update_camera(0.04)
 check(scene.focus!=release and scene.pan_velocity.length()>0,"Releasing a drag coasts briefly")
 var speed=scene.pan_velocity.length()
 scene.update_camera(0.04)
 check(scene.pan_velocity.length()<speed,"Camera momentum decays rather than drifting forever")
 check(game.state==before,"Camera motion never changes gameplay")
 game.state.ux.motion=false
 scene.focus_at(Vector3(20,0,20))
 check(scene.view_focus==scene.focus and not scene.camera_transition,"Reduced motion makes navigation immediate")
 game.state.ux.motion=true
 var photo=scene.photo
 var camera_before=scene.view_focus
 var zoom_before=scene.view_zoom
 var mask_before=scene.camera.cull_mask
 before=game.state.duplicate(true)
 photo.enter()
 check(photo.active and not scene.hud.visible,"Photo mode hides the whole HUD")
 check(scene.camera.cull_mask & load("res://Buildings/Models.gd").WORLD_LABEL_LAYER==0,"World captions are excluded from the photo camera")
 scene.tap_world(Vector2(270,400))
 check(game.state==before,"Photo taps cannot chop, collect rent or spend money")
 scene.camera_yaw=0.5
 scene.zoom=140
 scene.set_camera()
 photo.leave()
 check(scene.hud.visible and scene.view_focus==camera_before and scene.view_zoom==zoom_before and scene.camera_yaw==0,"Leaving photo mode restores the actual previous view")
 check(scene.camera.cull_mask==mask_before,"Leaving photo mode restores world captions")
 var presentation=load("res://Components/ProductionPresentation.gd")
 game.state.reserve=false
 game.state.resources.wood=30
 game.state.resources.boards=0
 check(presentation.describe(game,1).kind=="running","An available sawmill has no false stoppage warning")
 game.state.buildings[1].paused=true
 check(presentation.describe(game,1).kind=="paused","Pause produces the correct production warning")
 game.state.buildings[1].paused=false
 game.state.resources.wood=0
 check(presentation.describe(game,1).kind=="missing","Empty real stock produces a missing-material warning")
 game.state.resources.wood=30
 game.state.resources.boards=game.capacity()
 check(presentation.describe(game,1).kind=="full","Actual full output produces a storage warning")
 scene.production_alerts.refresh()
 check(scene.production_alerts.pool.size()==3,"Production warnings share three overlays")
 # Follow a real dispatched load through its saved loading/drive/unloading times.
 game.state.coins=10000
 game.state.resources.wood=50
 game.state.resources.boards=0
 game.state.buildings.append({"kind":"furniture","level":1,"paused":false,"position":[-44,-12]})
 game.rebuild_world.emit()
 check(game.start_delivery(),"Cargo animation uses the real active production line")
 game.step(1)
 check(not game.state.delivery.shipments.is_empty(),"An actual stock dispatch creates the animated load")
 if game.state.delivery.shipments.is_empty():
  scene.queue_free(); await process_frame; quit(1); return
 var trip=game.state.delivery.shipments[0]
 var transfer=load("res://Components/CargoTransfer.gd")
 scene.delivery_world._process(0)
 var truck=scene.delivery_world.visuals[scene.delivery_world.visual_key(trip)]
 var base=truck.cargo.get_meta("rest_position")
 trip.age=0.5
 before=game.state.duplicate(true)
 scene.delivery_world._process(0)
 check(truck.cargo.position!=base and transfer.phase(trip,trip.age).kind=="load","Actual loading moves stock towards the vehicle")
 check(game.state==before,"Loading choreography cannot advance or duplicate the real shipment")
 trip.age=float(trip.load)+float(trip.drive)*0.5
 scene.delivery_world._process(0)
 check(truck.cargo.position==base,"Loaded cargo stays fixed on the truck while driving")
 trip.age=float(trip.load)+float(trip.drive)+1
 scene.delivery_world._process(0)
 check(truck.cargo.position!=base and transfer.phase(trip,trip.age).kind=="unload","Actual unloading moves the cargo towards its real destination")
 game.step(1.1)
 scene.delivery_world._process(0)
 check(trip.arrived and not truck.cargo.visible,"Cargo disappears only after the simulation delivers the load")
 # Real paid construction drives the reveal, not a fabricated model upgrade.
 game.state.coins=10000
 game.state.resources.boards=0
 var point=game.free_position(Vector3(20,0,20))
 check(game.order_building("kiln",point),"The new drying plant is ordered through the paid build flow")
 game.simulate(100)
 var active=[]
 for e in scene.upgrade_reveal.pool:
  if e.age<1.8: active.append(e)
 check(active.size()==1 and game.level("kiln")==1,"Only the actual completed building starts a reveal")
 if active.size()==1:
  var model=active[0].model
  check(model.scale.y<1,"The completed model enters its reveal")
  before=game.state.duplicate(true)
  scene.upgrade_reveal._process(2)
  check(model.scale==Vector3.ONE and game.state==before,"Reveal ends at exact building size without changing the economy")
 scene.queue_free()
 await process_frame
 print("PRESENTATION 26: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
