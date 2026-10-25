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
func same_picture(a: Image,b: Image) -> bool:
 if RenderingServer.get_current_rendering_method()=="gl_compatibility":return a.get_data()==b.get_data()
 # Vulkan's postprocessing/shadow sampling can dither a stationary frame.
 # Bound the sampled RGB error while separately asserting fixed light state
 # and complete absence of weather nodes; a day/night transition exceeds this.
 var error=0.0;var count=0
 for y in range(0,a.get_height(),5):
  for x in range(0,a.get_width(),5):
   var delta=a.get_pixel(x,y)-b.get_pixel(x,y)
   error+=absf(delta.r)+absf(delta.g)+absf(delta.b);count+=3
 var mean=error/maxi(1,count)
 print("DAYLIGHT RGB ERROR: ",mean)
 return mean<0.0001

func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 root.get_node("RuntimeStats").set_process(false)
 game.restore(game.initial_state());var s=game.state
 s.tutorial=5;s.onboarding.active=false;s.construction_intro=true;s.companion_enabled=false;s.city_services.enabled=false;s.ux.adaptive_detail=false
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.focus=Catalog.biome_position(0);scene.zoom=100;scene.set_camera()
 scene._process(0)
 for n in [scene]+scene.find_children("*","Node",true,false):
  n.set_process(false)
  if n is CPUParticles3D or n is GPUParticles3D:n.hide()
 await settle();var first=root.get_texture().get_image()
 var base=s.duplicate(true);var correct=true
 for weather in [0,1,2,3]:
  s.time=23;s.weather=weather;scene._process(0);await settle()
  if not same_picture(first,root.get_texture().get_image()):correct=false
 check(correct,"Rendered forest stays stable across all legacy weather/night values (exact GL pixels; bounded Vulkan dither)")
 check(scene.weather==null and scene.wet_weather==null,"No hidden weather GPU nodes are left allocated")
 check(not scene.environment_resource.fog_enabled and scene.environment_resource.fog_density==0,"The real rendered environment contains no fog")
 var state=s.duplicate(true);scene._process(0.8);await settle()
 check(same_picture(first,root.get_texture().get_image()),"A later frame has no animated canopy wind or lighting transition")
 check(s==state,"Fixed-daylight rendering leaves the complete saved company untouched")
 scene.hud.open_menu("performance");await settle()
 var labels=scene.hud.contents.find_children("*","Label",true,false)
 check(labels.any(func(label):return label.text.contains("Dauerhaftes Tageslicht")),"The shipped performance page identifies fixed daylight")
 root.get_texture().get_image().save_png("/workspace/timber2824-daylight.png")
 scene.queue_free();await process_frame
 print("VISUAL DAYLIGHT 2824: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
