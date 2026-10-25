extends SceneTree
# Manual render attribution. Run sequentially, with the same fixture and driver.
# Desktop software-GPU measurements are never reported as Samsung/Windows FPS.
func _initialize():call_deferred("run")
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 var stats=root.get_node("RuntimeStats");stats.set_process(false)
 game.restore(JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("TIMBER_PROFILE_FIXTURE"))))
 var s=game.state
 s.tutorial=5;s.onboarding.active=false;s.construction_intro=true;s.companion_enabled=false;s.city_services.enabled=false;s.ux.adaptive_detail=true
 game.simulate(180)
 root.size=Vector2i(1080,2340);root.content_scale_size=root.size
 var began=Time.get_ticks_usec()
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 var built=(Time.get_ticks_usec()-began)/1000.0
 stats.record_frame(33,0.033,false)
 for i in 80:stats.record_frame(200,0.2)
 scene.focus=Vector3(0,0,20);scene.zoom=110;scene.set_camera()
 scene._process(0.6);scene.landscape._process(0);scene.delivery_world._process(0)
 var chunks=scene.get("chunks")
 if chunks!=null:chunks.update_view(true)
 for node in [scene]+scene.find_children("*","Node",true,false):node.set_process(false);node.set_physics_process(false)
 root.scaling_3d_scale=stats.resolution_scale(root.size,1,true,true)
 var before=s.duplicate(true);before.erase("last_seen")
 Engine.max_fps=0;DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var rid=root.get_viewport_rid();RenderingServer.viewport_set_measure_render_time(rid,true)
 var report={"renderer":RenderingServer.get_current_rendering_method(),"driver":RenderingServer.get_current_rendering_driver_name(),"adapter":RenderingServer.get_video_adapter_name(),"built_ms":built,"render_scale":root.scaling_3d_scale,"synthetic_pressure_seconds":16,"cases":[],"desktop_only":true,"android_device_tested":false}
 var full_mask=scene.camera.cull_mask
 for kind in ["normal","no_3d","no_hud","overview"]:
  scene.camera.cull_mask=0 if kind=="no_3d" else full_mask
  scene.hud.visible=kind!="no_hud"
  scene.zoom=320 if kind=="overview" else 110;scene.set_camera()
  if chunks!=null:chunks.update_view(true)
  for i in 12:await process_frame
  var frames=[];var cpu=[];var gpu=[];var calls=[];var triangles=[]
  var last=Time.get_ticks_usec()
  for i in 30:
   await process_frame
   var now=Time.get_ticks_usec();frames.append((now-last)/1000.0);last=now
   cpu.append(RenderingServer.viewport_get_measured_render_time_cpu(rid));gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(rid))
   calls.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME));triangles.append(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
  for values in [frames,cpu,gpu,calls,triangles]:values.sort()
  report.cases.append({"case":kind,"median_ms":frames[15],"p95_ms":frames[28],"render_cpu_ms":cpu[15],"render_gpu_ms":gpu[15],"draw_calls":calls[15],"triangles":triangles[15]})
 RenderingServer.viewport_set_measure_render_time(rid,false)
 var after=s.duplicate(true);after.erase("last_seen")
 report.company_unchanged=before==after;report.company_sha256=JSON.stringify(after,"",true,true).sha256_text()
 report.engine_memory_bytes=OS.get_static_memory_usage();report.video_memory_bytes=Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
 report.nodes=scene.find_children("*","Node",true,false).size()
 var file=FileAccess.open(OS.get_environment("TIMBER_BENCH_OUTPUT"),FileAccess.WRITE);file.store_string(JSON.stringify(report," "));file.close()
 print("RENDER PROFILE 2826: ",JSON.stringify(report))
 scene.queue_free()
 for i in 3:await process_frame
 quit(0 if before==after else 1)
