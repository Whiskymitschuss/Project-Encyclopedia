extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func settle() -> void:
 for i in 6: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.city_services.enabled=false
 game.state.companion_enabled=false
 game.state.unlocked=6
 game.state.company_xp=3000
 game.state.workers=14
 game.state.trucks=8
 game.state.vehicle=6
 game.state.buildings[1].level=10
 game.state.time=10
 for key in game.state.resources: game.state.resources[key]=3000
 for kind in ["kiln","sawmill","furniture","sawmill","warehouse","kiln","furniture","sawmill","prefab","joinery","sawmill"]:
  var point=game.free_position(Catalog.industry_position(game.state.buildings.size()))
  game.state.buildings.append({"kind":kind,"level":clampi(game.state.buildings.size()-3,1,10),"paused":false,"position":[point.x,point.z]})
 for kind in ["fire","police","taxi","house"]:
  var preferred=Vector3(-44+game.state.homes.size()*24,0,-76)
  var point=game.free_position(preferred)
  game.state.homes.append({"kind":kind,"level":2,"plot":game.state.homes.size(),"position":[point.x,point.z]})
 var duplicate=[]
 for x in range(-80,81,4): duplicate.append([x,-60])
 game.state.town.roads.append({"kind":"asphalt","cells":duplicate})
 game.state.town.roads.append({"kind":"asphalt","cells":duplicate.duplicate(true)})
 var state=game.state.duplicate(true)
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.size=Vector2i(591,1280)
 root.content_scale_size=root.size
 root.add_child(scene)
 scene.set_process(false)
 scene.hud.ux.set_process(false)
 await settle()
 var surface=load("res://Components/StreetSurface.gd")
 var plan=surface.plan(game.state,scene.street_context.plots)
 check(game.state==state,"Road and plot repairs leave a populated saved company entirely unchanged")
 check(scene.base_streets.has_node("StreetNetwork/Asphalt") and scene.base_streets.has_node("StreetNetwork/Sidewalks"),"Actual map builds a single canonical road and sidewalk network")
 var overlap=false
 for i in plan.roads.size():
  for j in range(i+1,plan.roads.size()):
   if plan.roads[i].intersects(plan.roads[j]): overlap=true
 check(not overlap,"Road rectangles have no coplanar overlap, even with duplicate saved street records")
 overlap=false
 for walk in plan.walks:
  for road in plan.roads:
   if walk.intersects(road): overlap=true
 check(not overlap,"Sidewalks never cover a driving lane or an intersection")
 var on_plot=false
 for walk in plan.walks:
  for plot in scene.street_context.plots:
   if walk.intersects(plot): on_plot=true
 check(not on_plot,"Sidewalks leave every real factory and house footprint clear")
 var missed=0
 for cell in TownRules.road_cells(game.state.town):
  if not surface.contains(plan.roads,Vector2(cell)): missed+=1
 check(missed==0,"Every authoritative road cell, including north roads and junctions, has asphalt")
 var original=game.state.duplicate(true)
 original.town.roads=[]
 var base=surface.plan(original,scene.street_context.plots)
 check(base.roads==plan.roads,"Drawing the same street twice cannot create another road layer")
 var yard=scene.base_streets.get_node("OpenProductionYard")
 check(not yard.get_meta("shared_slab",true),"The former blanket industrial slab is absent")
 var floors=0
 for model in scene.world_buildings.get_children():
  var floor_mesh=model.get_node_or_null("FactoryFloor")
  if floor_mesh!=null:
   floors+=1
   check(floor_mesh.visible,"An actual factory retains its own bounded floor")
 check(scene.base_streets.has_node("StreetNetwork/Curbs"),"Canonical sidewalks have visible continuous kerb faces")
 check(floors>=10,"A populated company renders independent production plots")
 check(scene.camera.far-scene.camera.near<=1800,"The camera no longer wastes mobile depth precision on an oversized far range")
 for kind in ["Asphalt","Sidewalks","RoadMarkings"]:
  var node=scene.base_streets.get_node("StreetNetwork/"+kind)
  check(node.material_override.transparency==BaseMaterial3D.TRANSPARENCY_DISABLED,"Opaque depth-tested road finish: "+kind)
  check(node.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"Flat road paint cannot cast acne shadows: "+kind)
 scene.focus=Vector3(0,0,-45)
 scene.zoom=115
 scene.set_camera()
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber2842-populated.png")
 scene.zoom=245
 scene.focus=Vector3(0,0,-10)
 scene.set_camera()
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber2842-map.png")
 scene.zoom=60
 scene.focus=Vector3(-65,0,-60)
 scene.set_camera()
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber2842-junction.png")
 scene.focus=game.building_position(1)
 scene.zoom=58
 scene.set_camera()
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber285-stages.png")
 scene.queue_free()
 await process_frame
 print("VISUAL MAP 2842: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
