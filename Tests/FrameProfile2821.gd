extends SceneTree
var game
func _initialize():call_deferred("run")
func measure(node: Node,frames: int=240) -> float:
 var t=Time.get_ticks_usec()
 for frame in frames:node._process(1.0/30)
 return float(Time.get_ticks_usec()-t)/frames
func run():
 await process_frame
 game=root.get_node("Game");game.set_process(false);root.get_node("RuntimeStats").set_process(false)
 game.restore(JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("TIMBER_PROFILE_FIXTURE"))))
 game.state.tutorial=5;game.state.onboarding.active=false;game.state.companion_enabled=false;game.state.city_services.enabled=false;game.state.ux.adaptive_detail=false
 game.simulate(180)
 root.size=Vector2i(540,960);root.content_scale_size=root.size
 var before=game.state.duplicate(true);before.erase("last_seen")
 var began=Time.get_ticks_usec()
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 var built=Time.get_ticks_usec()-began
 scene.set_process(false);scene.life.set_process(false);scene.hud.ux.set_process(false)
 Engine.max_fps=0;DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var report={"built_us":built,"nodes":get_node_count(),"meshes":scene.find_children("*","MeshInstance3D",true,false).size(),"cases":[],"cpu_us":{}}
 var index=0
 for point in [Vector3(-45,0,-115),Vector3(0,0,20),Vector3(0,0,100),Vector3(0,0,20)]:
  scene.focus=point;scene.zoom=320 if index==3 else 100;scene.set_camera()
  for i in 12:await process_frame
  var frames=[];var draws=[];var objects=[];var process=[]
  var last=Time.get_ticks_usec()
  for i in 40:
   scene.focus.x=point.x-30+i*1.5;scene.set_camera()
   await process_frame
   var now=Time.get_ticks_usec();frames.append(float(now-last)/1000);last=now
   draws.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME));objects.append(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME));process.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000)
  frames.sort();draws.sort();objects.sort();process.sort()
  report.cases.append({"case":index,"frame_median_ms":frames[20],"frame_p95_ms":frames[38],"draw_calls":draws[20],"objects":objects[20],"process_median_ms":process[20]});index+=1
 scene.focus=Vector3(0,0,20);scene.zoom=100;scene.set_camera()
 for i in 4:await process_frame
 for entry in [["world",scene],["deliveries",scene.delivery_world],["planters",scene.forest_world],["alerts",scene.production_alerts],["hud",scene.hud],["city_traffic",scene.city_traffic]]:
  report.cpu_us[entry[0]]=measure(entry[1])
 var camera_samples=[]
 for trial in 3:
  var movement=Time.get_ticks_usec()
  for i in 120:
   scene.focus.x=float((i%12)*16-80);scene.set_camera()
  camera_samples.append(float(Time.get_ticks_usec()-movement)/120)
 camera_samples.sort()
 report.cpu_us["camera_grid_crossing"]=camera_samples[1]
 report.camera_trials_us=camera_samples
 var after=game.state.duplicate(true);after.erase("last_seen")
 report.company_unchanged=before==after
 report.company_sha256=JSON.stringify(after,"",true,true).sha256_text()
 if before!=after:printerr("FAILED: Profiling altered company state");quit(1);return
 print("FRAME 2821: ",JSON.stringify(report))
 var out=OS.get_environment("TIMBER_BENCH_OUTPUT")
 if not out.is_empty():FileAccess.open(out,FileAccess.WRITE).store_string(JSON.stringify(report," "))
 quit()
