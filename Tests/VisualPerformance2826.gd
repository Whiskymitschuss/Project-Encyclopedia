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
 game.restore(JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/forestry288-company.json")))
 var s=game.state
 s.tutorial=5;s.onboarding.active=false;s.construction_intro=true;s.companion_enabled=false;s.city_services.enabled=false;s.ux.adaptive_detail=false
 game.simulate(180);game.changed.emit()
 root.size=Vector2i(591,1280);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.life.set_process(false)
 scene.focus=Vector3(0,0,20);scene.zoom=110;scene.set_camera();scene.chunks.update_view(true)
 scene._process(0.6);scene.delivery_world._process(0)
 var trips=scene.delivery_world.visuals.duplicate()
 check(not trips.is_empty(),"The actual generated company has visible transport instances")
 var all_drivers=true
 for truck in trips.values():
  if truck.find_children("Driver","Node3D",true,false).is_empty():all_drivers=false
 check(all_drivers,"Actual loaded and returning transport vehicles retain their beaver drivers")
 var company=s.duplicate(true)
 scene.rebuild();scene.delivery_world._process(0)
 check(trips==scene.delivery_world.visuals,"An unchanged world refresh keeps active vehicle instances and cargo handoffs")
 scene.hud.open_menu("settings");await settle()
 var profiles=scene.hud.contents.find_children("*","Button",true,false).filter(func(button):return button.text.ends_with(" FPS"))
 check(profiles.size()==4 and profiles.all(func(button):return button.custom_minimum_size.y>=44),"The actual scrollable settings menu exposes four touch-sized graphics choices")
 for id in 4:
  scene.hud.open_menu("settings")
  var title=GraphicsProfiles.profile(id).name
  var buttons=scene.hud.contents.find_children("*","Button",true,false)
  var target=buttons.filter(func(button):return button.text.contains(title+" ·"))
  if target.is_empty():check(false,"Missing profile button: "+title);continue
  target[0].pressed.emit();scene._process(0.6);await settle()
  check(int(s.quality)==id and Engine.max_fps==(30 if id<2 else 60),"Choosing %s applies its real frame target" % title)
  check(root.msaa_3d==GraphicsProfiles.profile(id).msaa,"Choosing %s applies the intended actual antialiasing" % title)
 s.quality=company.quality;game.apply_device_profile();scene._process(0.6)
 scene.hud.close_menu();scene.set_camera();scene.chunks.update_view(true);await settle()
 check(s==company,"Graphics changes and vehicle cache reuse leave the complete saved company unchanged")
 check(scene.weather==null and scene.wet_weather==null and not scene.environment_resource.fog_enabled,"All graphics profiles retain permanent daylight with weather disabled")
 var picture=root.get_texture().get_image();var colored=0
 for y in range(150,900,12):
  for x in range(20,570,12):
   var c=picture.get_pixel(x,y)
   if maxf(c.r,maxf(c.g,c.b))>0.05:colored+=1
 check(colored>2000,"The integrated main world and native UI render real colored pixels after every profile switch")
 picture.save_png("/workspace/timber2826-performance.png")
 scene.queue_free()
 for i in 3:await process_frame
 print("VISUAL PERFORMANCE 2826: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
