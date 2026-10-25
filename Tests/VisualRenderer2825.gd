extends SceneTree
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func settle():
 for i in 5:await process_frame
 await RenderingServer.frame_post_draw
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 var stats=root.get_node("RuntimeStats");stats.set_process(false)
 var expected=OS.get_environment("TIMBER_EXPECT_RENDERER")
 if expected.is_empty():expected="gl_compatibility"
 check(RenderingServer.get_current_rendering_method()==expected,"The requested backend really initializes, without silently using another renderer")
 game.restore(game.initial_state());var s=game.state
 s.tutorial=5;s.onboarding.active=false;s.construction_intro=true;s.companion_enabled=false;s.city_services.enabled=false;s.ux.adaptive_detail=false
 s.buildings.append({"kind":"central_depot","level":2,"position":[44,20]})
 root.size=Vector2i(591,1280);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene._process(0);scene.set_process(false);scene.life.set_process(false);scene.hud.ux.set_process(false)
 var before=s.duplicate(true)
 for point in [Catalog.biome_position(0),Vector3(0,0,-20)]:
  scene.focus=point;scene.zoom=100;scene.set_camera();await settle()
  var picture=root.get_texture().get_image();var colored=0
  for y in range(150,900,12):
   for x in range(20,570,12):
    var c=picture.get_pixel(x,y)
    if maxf(c.r,maxf(c.g,c.b))>0.05:colored+=1
  check(colored>2000,"The real forest/industry and HUD render actual colored pixels")
  var output=OS.get_environment("TIMBER_RENDER_IMAGE_PREFIX")
  if not output.is_empty():picture.save_png(output+("forest" if point.x<0 else "factory")+".png")
 check(scene.weather==null and scene.wet_weather==null and not scene.environment_resource.fog_enabled,"Permanent daylight and the absence of weather survive the backend change")
 check(scene.world_buildings.get_child(1).has_node("Processing") and scene.world_buildings.get_child(1).has_node("YardHandling"),"The same main world retains its actual machines and loading animations")
 stats.start_render_probe()
 for i in 8:
  await process_frame
  stats.sample_render_probe(0.1)
 stats.sample_render_probe(11)
 if expected=="mobile":check(not stats.render_probe_result.is_empty() and stats.render_probe_result.gpu_ms>0,"Vulkan reports actual GPU render timestamps on the test driver")
 else:check(stats.render_probe_left==0,"The OpenGL probe terminates even if timer queries are unavailable")
 check(s==before,"Rendering and GPU-time queries never change the company")
 scene.hud.open_menu("performance");await settle()
 var labels=scene.hud.contents.find_children("*","Label",true,false)
 check(labels.any(func(label):return label.text.contains("Grafikzeit messen")),"The actual performance menu exposes the optional bounded GPU probe")
 print("GPU PROBE 2825: ",JSON.stringify(stats.render_probe_result))
 scene.queue_free();await process_frame
 print("VISUAL RENDERER 2825: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
