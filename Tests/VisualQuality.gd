extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func settle() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.companion_enabled=false
 game.state.construction_intro=true
 game.state.city_services.enabled=false
 game.state.time=11
 game.flow.clear()
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await settle()
 scene.set_process(false)
 var hud=scene.hud
 for resolution in [Vector2i(360,640),Vector2i(540,960),Vector2i(1280,800)]:
  root.size=resolution
  for large in [false,true]:
   game.state.ux.large_text=large
   hud.ux.apply_accessibility()
   await settle()
   var bar=hud.quest_progress.get_global_rect()
   check(bar.size.y<=5 and hud.mission_button.get_global_rect().encloses(bar),"Quest progress stays a thin inset track at %s large=%s" % [resolution,large])
   check(hud.ux.event_button.get_global_rect().end.x<scene.hud.camera_controls.get_global_rect().position.x,"Notification inbox leaves room for camera controls")
   check(hud.money.get_global_rect().end.x<=hud.diamonds.get_global_rect().position.x,"Currency cards never overlap")
   hud.show_income(125)
   hud._process(0)
   await settle()
   check(hud.income_label.get_global_rect().end.y<=hud.header_panel.get_global_rect().end.y+2,"Income feedback stays in the wallet header")
 root.size=Vector2i(540,960)
 game.state.ux.large_text=false
 hud.ux.apply_accessibility()
 hud._process(3)
 scene.focus=Catalog.biome_position(0)
 scene.zoom=75
 scene.set_camera()
 # Freeze scene scripts so image differences isolate the vertex wind animation.
 for node in scene.find_children("*","Node",true,false): node.set_process(false)
 scene._process(0)
 await settle()
 var still=root.get_texture().get_image()
 var saved=game.state.duplicate(true)
 scene._process(0.8)
 await settle()
 var breeze=root.get_texture().get_image()
 check(still.get_data()!=breeze.get_data(),"Batched wind changes the actual OpenGL frame")
 check(game.state==saved,"Rendered wind never mutates saved resources or progress")
 breeze.save_png("/workspace/timber-quality-forest25.png")
 game.state.buildings=[{"kind":"sawmill","level":1,"slot":0,"paused":false,"position":[0,0]}]
 game.state.homes=[]
 scene.focus=Vector3.ZERO
 scene.zoom=60
 scene.set_camera()
 var first: Image
 for level in [1,2,3,4,5]:
  game.state.buildings[0].level=level
  scene.rebuild()
  await settle()
  var shot=root.get_texture().get_image()
  if level==1: first=shot
  check(not shot.is_empty(),"Building level %s renders actual geometry" % level)
  if level==5:
   check(first.get_data()!=shot.get_data(),"Premium architecture visibly changes the rendered silhouette")
   shot.save_png("/workspace/timber-quality-premium25.png")
 game.state.homes=[{"kind":"house","level":3,"plot":0,"rent_bank":0,"position":[-24,86]}]
 CityServices.ignite(game.state,{"type":"home","index":0})
 game.step(1)
 var incident=game.state.city_services.fires[0]
 var mission=game.state.city_services.missions[0]
 mission.age=float(mission.drive)+18
 incident.progress=0.5
 scene.rebuild()
 scene.focus=Vector3(-24,0,86)
 scene.zoom=68
 scene.set_camera()
 var fw=scene.city_traffic.fire_world
 scene._process(0)
 scene.town_layer.refresh_rents()
 hud.update_stats()
 fw._process(0.1)
 await settle()
 var fire=fw.scenes.values()[0]
 check(is_equal_approx(fire.get_node("Meters/Intensity").scale.x,0.5) and is_equal_approx(fire.get_node("Meters/Extinguishing").scale.x,0.5),"World fire meters use actual rescue progress")
 check(not scene.town_name_labels[0].visible and not scene.town_layer.rent_labels[0].label.visible,"Incident status replaces competing home and rent captions")
 check(fire.get_node("Status").visible and fire.get_node("Meters").visible,"Fire progress remains visible below the HUD when focused")
 check(fire.get_node("WaterMist").emitting and fire.get_node("Sparks").emitting,"Actual on-site rescue enables water mist and sparks")
 check(fire.get_node("FireGlow").visible and not fire.get_node("FireGlow").shadow_enabled,"Normal-quality fire has bounded shadowless warm light")
 root.get_texture().get_image().save_png("/workspace/timber-quality-fire25.png")
 game.state.quality=0
 game.state.ux.motion=false
 fw._process(1)
 check(not fire.get_node("FireGlow").visible and not fire.get_node("WaterMist").emitting and not fire.get_node("Sparks").emitting,"Battery and reduced-motion settings suppress costly fire extras immediately")
 game.state.ux.motion=true
 var before=game.state.duplicate(true)
 for i in 20: scene.feedback.on_rescue(Vector3(-24,0,86))
 scene.feedback._process(0.1)
 check(scene.feedback.get_child_count()==4,"Repeated success reuses four effects instead of growing the scene")
 check(game.state==before,"Success visuals never pay currency or advance quests")
 scene.feedback._process(4)
 var remaining=0
 for item in scene.feedback.pool:
  if item.root.visible: remaining+=1
 check(remaining==0,"All temporary success feedback expires")
 scene.queue_free()
 await process_frame
 print("VISUAL QUALITY: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
