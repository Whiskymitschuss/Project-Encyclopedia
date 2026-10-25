extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func settle() -> void:
 for frame in 5: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 var s=game.state
 s.tutorial=5
 s.construction_intro=true
 s.city_services.enabled=false
 s.companion_enabled=false
 s.workers=8
 s.trucks=2
 s.vehicle=3
 s.time=10
 s.company_xp=800
 s.resources.wood=300
 s.resources.boards=200
 s.buildings.append({"kind":"furniture","level":3,"paused":false,"position":[-20,-12]})
 s.buildings.append({"kind":"central_depot","level":6,"paused":false,"position":[44,20]})
 var center=s.buildings.size()-1
 for kind in ["express","quarry","stoneworks"]:
  var point=game.free_position(Catalog.industry_position(s.buildings.size()))
  s.buildings.append({"kind":kind,"level":6,"paused":false,"position":[point.x,point.z]})
 DeliveryChain.start(s)
 var job={"id":41,"type":"home","kind":"apartments","plot":1,"position":[-44,84],"materials":{"furniture":6.0},"delivered":{},"total":70.0,"left":10.0}
 ConstructionRules.attach(job)
 job.phase=5
 s.jobs=[job]
 game.simulate(100)
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.size=Vector2i(591,1280)
 root.content_scale_size=root.size
 root.add_child(scene)
 scene.set_process(false)
 scene.hud.ux.set_process(false)
 scene.focus=Vector3(12,0,-6)
 scene.zoom=125
 scene.set_camera()
 await settle()
 var actual: Node3D
 for model in scene.world_buildings.get_children():
  if model.get_meta("kind","")=="central_depot": actual=model; break
 check(actual.has_node("Architecture/Stage6") and actual.has_node("Connections/Unloading"),"The real main-world depot uses its completed architecture and logistics anchors")
 check(actual.has_node("DepotStock") and actual.has_node("DepotHandler0") and actual.has_node("DepotHandler1"),"Architecture keeps real stock displays and both animated forklift controllers")
 scene.delivery_world._process(0.2)
 check(scene.delivery_world.visuals.size()>0,"Recovered economic dispatch is represented by actual road freight in the main world")
 var before=s.duplicate(true)
 var valid=true
 for mesh in actual.find_children("*","MeshInstance3D",true,false): valid=valid and mesh.mesh!=null
 check(valid,"Integrated depot meshes have valid resources")
 scene.hud.update_stats()
 await settle()
 var bar=scene.hud.material_bar
 check(bar.counters.boards.text==bar.compact_number(UXRules.material_stock(s,"boards").stored),"The main counter retains the complete actual stored quantity")
 check(bar.warehouse_counts.boards.text=="L %s/%s" % [bar.compact_limit(s.resources.boards),bar.compact_limit(game.capacity())],"The main material card separately identifies the amount actually in the warehouse")
 check(s==before,"Drawing material locations and upgraded logistics never mutates the company")
 root.get_texture().get_image().save_png("/workspace/timber286-supply.png")
 for resolution in [Vector2i(360,640),Vector2i(540,960)]:
  root.size=resolution
  root.content_scale_size=resolution
  await settle()
  var readable=true
  for key in bar.controls:
   var control=bar.controls[key]
   var footer=bar.warehouse_counts[key]
   readable=readable and control.size.x>=44 and control.size.y>=54 and control.get_global_rect().encloses(footer.get_global_rect())
  check(readable,"Warehouse subtitles and touch targets fit the phone viewport: %s" % resolution)
  for large in [false,true]:
   s.ux.large_text=large
   scene.hud.ux.apply_accessibility()
   await settle()
   scene.delivery_world._process(0.1)
   var clear=true
   for badge in scene.delivery_world.badges:
    if badge.button.visible and badge.button.get_global_rect().intersects(scene.hud.bottom_panel.get_global_rect()): clear=false
   check(clear,"World material badges never intercept HUD touches after resize or large text: %s/%s" % [resolution,large])
 s.ux.large_text=false
 scene.hud.ux.apply_accessibility()
 await settle()
 # QA comparisons use the same production models, in addition to the real
 # main-world integration above, never as an alternative demonstration scene.
 root.size=Vector2i(1280,1050)
 root.content_scale_size=root.size
 scene.hud.hide()
 scene.world_buildings.hide()
 scene.actors.hide()
 scene.base_streets.hide()
 var samples=Node3D.new()
 var models=load("res://Buildings/Models.gd")
 samples.position.y=20
 scene.add_child(samples)
 for row in 4:
  var kind=["central_depot","express","quarry","stoneworks"][row]
  for column in 3:
   var level=[1,5,10][column]
   var model=models.building(kind,level)
   for mesh in model.find_children("*","MeshInstance3D",true,false): mesh.visibility_range_end=0
   model.position=Vector3((column-1)*37,0,(row-1.5)*31)
   samples.add_child(model)
   models.label(model,"%s · %s" % [Catalog.BUILDINGS[kind].name,level],Vector3(0,15,0),22)
 scene.camera.position=Vector3(95,165,150)
 scene.camera.look_at(Vector3(0,23,0))
 scene.camera.size=160
 scene.camera.near=0.1
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber286-infrastructure.png")
 scene.queue_free()
 await process_frame
 print("VISUAL SUPPLY 286: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
