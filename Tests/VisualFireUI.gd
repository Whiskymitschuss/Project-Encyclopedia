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
 game.state.city_services.enabled=false
 game.state.homes=[{"kind":"house","level":2,"plot":0,"rent_bank":0,"position":[-24,86]},{"kind":"fire","level":3,"plot":1,"rent_bank":0,"position":[24,86]}]
 CityServices.ignite(game.state,{"type":"home","index":0})
 CityServices.tick(game.state,1,{})
 var mission=game.state.city_services.missions[0]
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.set_process(false)
 scene.focus=Vector3(-24,0,86)
 scene.zoom=65
 scene.set_camera()
 var fire_world=scene.city_traffic.fire_world
 await settle()
 var visual=fire_world.scenes.values()[0]
 check(visual.get_node("Smoke").get_child_count()==5,"Smoke exists at the actual incident")
 check(not visual.get_node("Water").visible,"No water before fire engine arrives")
 var snapshot=game.state.duplicate(true)
 fire_world._process(2)
 check(game.state==snapshot,"Visual animation cannot alter rescue progress or economy")
 var smoke_y=visual.get_node("Smoke").get_child(0).position.y
 fire_world._process(1)
 check(visual.get_node("Smoke").get_child(0).position.y!=smoke_y,"Smoke actually rises")
 mission.age=float(mission.drive)+12
 game.state.city_services.fires[0].progress=1.0/3.0
 await settle()
 check(visual.get_node("Water").visible and visual.get_node("Crew").visible,"Actual on-site phase activates water and firefighters")
 check(visual.get_node("Water").get_child_count()==16,"Two bounded segmented water jets")
 check(scene.hud.emergency_button.visible,"Active alarm has direct HUD access")
 for resolution in [Vector2i(360,640),Vector2i(540,960),Vector2i(591,1280),Vector2i(1280,800)]:
  root.size=resolution
  await settle()
  var transform=root.get_screen_transform()
  check(absf(transform.x.length()-transform.y.length())<0.001,"Uniform display scale at "+str(resolution))
  var hud=scene.hud
  check(hud.header_panel.get_global_rect().position.x>=0 and hud.header_panel.get_global_rect().end.x<=hud.size.x+1,"Header fits "+str(resolution))
  check(hud.bottom_panel.get_global_rect().end.x<=hud.size.x+1,"Bottom navigation fits "+str(resolution))
  hud.open_menu("services")
  await settle()
  check(hud.overlay.size.x<=760 and hud.overlay.get_global_rect().position.y>=168,"Readable bounded incident panel "+str(resolution))
  check(hud.scroll.size.y>100,"Incident list scrolls inside panel "+str(resolution))
  for large in [true,false]:
   game.state.ux.large_text=large
   hud.ux.apply_accessibility()
   await settle()
   check(hud.header_panel.get_global_rect().end.y<=hud.mission_button.get_global_rect().position.y,"Header and goal never overlap at large font="+str(large)+str(resolution))
   check(hud.bottom_panel.get_global_rect().end.y<=hud.size.y+1,"Large-font navigation stays onscreen "+str(resolution))
  if resolution==Vector2i(540,960): root.get_texture().get_image().save_png("/workspace/timber-fire-services22.png")
  hud.close_menu()
  await settle()
  var image=root.get_texture().get_image()
  check(not image.is_empty() and image.get_width()>0,"Actual OpenGL frame rendered "+str(resolution))
  image.save_png("/workspace/timber-fire-ui-%sx%s.png" % [resolution.x,resolution.y])
 game.state.quality=0
 game.state.ux.motion=false
 fire_world._process(1)
 var count=0
 for puff in visual.get_node("Smoke").get_children():
  if puff.visible: count+=1
 check(count==2,"Battery mode reduces smoke mesh count")
 smoke_y=visual.get_node("Smoke").get_child(0).position.y
 fire_world._process(2)
 check(visual.get_node("Smoke").get_child(0).position.y==smoke_y,"Reduced motion stops smoke animation")
 CityServices.tick(game.state,100,{})
 fire_world._process(0)
 check(fire_world.scenes.is_empty(),"Completed rescue removes all incident effects")
 scene.queue_free()
 await process_frame
 print("FIRE & RESPONSIVE UI OPENGL: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
