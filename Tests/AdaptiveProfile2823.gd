extends SceneTree
func _initialize():call_deferred("run")
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 var stats=root.get_node("RuntimeStats");stats.set_process(false)
 game.restore(JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("TIMBER_PROFILE_FIXTURE"))))
 game.state.tutorial=5;game.state.onboarding.active=false;game.state.construction_intro=true;game.state.companion_enabled=false;game.state.city_services.enabled=false;game.state.ux.adaptive_detail=true
 game.simulate(180)
 root.size=Vector2i(1080,2340);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.life.set_process(false);scene.hud.ux.set_process(false)
 scene.focus=Catalog.biome_position(0);scene.zoom=110;scene.set_camera()
 stats.record_frame(33,0.033,false)
 for i in 80:stats.record_frame(200,0.2)
 scene._process(0.6);scene.landscape._process(0)
 root.scaling_3d_scale=stats.resolution_scale(root.size,1,true,true)
 var before=game.state.duplicate(true);before.erase("last_seen")
 Engine.max_fps=0;DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 for i in 12:await process_frame
 var frames=[];var draws=[];var triangles=[]
 var t=Time.get_ticks_usec()
 for i in 30:
  await process_frame
  var now=Time.get_ticks_usec();frames.append((now-t)/1000.0);t=now
  draws.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
  triangles.append(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
 frames.sort();draws.sort();triangles.sort()
 var after=game.state.duplicate(true);after.erase("last_seen")
 var report={"pixel_size":[root.size.x,root.size.y],"requested_render_scale":root.scaling_3d_scale,"frame_median_ms":frames[15],"frame_p95_ms":frames[28],"draw_calls":draws[15],"triangles":triangles[15],"company_unchanged":before==after,"company_sha256":JSON.stringify(after,"",true,true).sha256_text(),"desktop_only":true,"synthetic_pressure_seconds":16}
 var out=OS.get_environment("TIMBER_BENCH_OUTPUT");FileAccess.open(out,FileAccess.WRITE).store_string(JSON.stringify(report," "))
 if before!=after:printerr("FAILED: Adaptive benchmark changed company state");quit(1);return
 print("ADAPTIVE 2823: ",JSON.stringify(report));quit()
