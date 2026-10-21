extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func settle() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.company_xp=550
 game.state.workers=17
 game.state.tool=10
 game.state.trucks=4
 game.state.vehicle=3
 game.state.time=14
 game.state.city_services.enabled=false
 var center=Catalog.biome_position(0)
 var homes=[center+Vector3(0,0,25),Vector3(-24,0,86),Vector3(24,0,86)]
 for i in homes.size():
  game.state.homes.append({"kind":"shop" if i==1 else "fire" if i==2 else "house","level":1,"plot":i,"position":[homes[i].x,homes[i].z]})
 CityServices.ignite(game.state,{"type":"home","index":1})
 CityServices.tick(game.state,1,{})
 var mission=game.state.city_services.missions[0]
 mission.age=float(mission.drive)+12
 game.state.city_services.fires[0].age=50
 game.state.city_services.fires[0].progress=1.0/3
 var cell=Vector2i(0,68)
 TrafficRules.break_signal(game.state,cell)
 TrafficRules.dispatch_repair(game.state,{})
 var tech=game.state.city_services.missions[-1]
 tech.age=float(tech.drive)+4
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.focus=Vector3(-24,0,86)
 scene.zoom=65
 scene.set_camera()
 await settle()
 var fw=scene.city_traffic.fire_world
 var incident=fw.scenes.values()[0]
 var snapshot=game.state.duplicate(true)
 fw._process(1)
 check(game.state==snapshot,"Fire and smoke rendering cannot advance actual rescue or warehouse stock")
 check(incident.get_node("Flames").get_child(0).mesh is QuadMesh,"Fire uses irregular animated silhouettes instead of orange traffic cones")
 check(incident.get_node("Smoke").get_child(0).mesh is QuadMesh,"Smoke has soft translucent boundaries instead of a chain of opaque spheres")
 check(incident.get_node("Water").visible,"Water jets follow an actual on-site firefighting mission")
 var badge=incident.get_meta("badge")
 for resolution in [Vector2i(360,640),Vector2i(591,1280),Vector2i(1280,800)]:
  root.size=resolution
  await settle()
  fw._process(0)
  check(badge.size.x<=240 and badge.position.x>=0 and badge.get_global_rect().end.x<=scene.hud.size.x,"Compact fire status stays within phone edges at "+str(resolution))
  check(badge.get_global_rect().position.y>=scene.hud.mission_button.get_global_rect().end.y,"Fire status leaves the actual header unobstructed")
  root.get_texture().get_image().save_png("/workspace/timber-alpha29-fire-%sx%s.png" % [resolution.x,resolution.y])
 check(not scene.boss_trees[0].visible or ForestSites.clear_at(scene.boss_trees[0].position,ForestSites.obstacles(game.state),6),"Special boss tree relocates away from the newly occupied home")
 var machines=0
 for actor in scene.actors.get_children():
  if actor.has_meta("forestry_tier"):
   machines+=1
   check(ForestSites.clear_at(actor.origin_point,scene.forest_obstacles,7),"Forestry machine uses clear ground rather than the old camp inside town")
 check(machines>0,"Displaced forestry machinery remains visible in available forest")
 var signals=scene.city_traffic.get_child(0)
 signals._process(0.2)
 check(signals.signals.size()>0 and signals.signals.size()<=14,"Only a bounded number of nearby traffic signals is rendered")
 check(signals.repairer!=null and signals.repairer.visible,"A repair worker appears only when the technician van is actually on site")
 for menu in ["traffic","construction"]:
  scene.hud.open_menu(menu)
  await settle()
  check(scene.hud.contents.get_child_count()>0 and not badge.visible,"Traffic and foreman menus open without competing fire overlays")
 scene.hud.close_menu()
 game.state.quality=0
 game.state.ux.motion=false
 fw._process(1)
 var shader_clock=incident.get_node("Flames").get_child(0).material_override.get_shader_parameter("clock")
 fw._process(2)
 check(incident.get_node("Flames").get_child(0).material_override.get_shader_parameter("clock")==shader_clock,"Reduced-motion preference freezes the new flame shader")
 check(not incident.get_node("Sparks").emitting and not incident.get_node("WaterMist").emitting,"Battery settings keep optional particles off")
 signals._process(0.2)
 check(signals.signals.size()<=6,"Battery mode reduces the signal drawing budget")
 game.state.quality=1
 game.state.ux.motion=true
 game.state.builders=1
 var a={"id":1,"type":"home_upgrade","index":0,"kind":"house","left":14.0,"total":14.0,"materials":{},"delivered":{}}
 var b={"id":2,"type":"home_upgrade","index":1,"kind":"shop","left":14.0,"total":14.0,"materials":{},"delivered":{}}
 ConstructionRules.attach(a,1)
 ConstructionRules.attach(b,0)
 game.state.jobs=[a,b]
 var crews=scene.get_node("ConstructionCrews")
 crews._process(0)
 var worker=crews.workers[0]
 var before=worker.position
 a.workers=0
 b.workers=1
 crews._process(0.1)
 check(crews.workers[0]==worker and worker.job_id==2 and not worker.transfer.is_empty(),"Same builder visibly moves to the new site rather than leaving a duplicate behind")
 check(worker.position.distance_to(before)<1,"Crew relocation walks instead of teleporting across the town")
 scene.queue_free()
 await process_frame
 print("VISUAL ALPHA 29: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
