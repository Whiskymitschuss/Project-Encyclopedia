extends SceneTree
func _initialize():call_deferred("run")
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 var stats=root.get_node("RuntimeStats");stats.set_process(false)
 game.restore(JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("TIMBER_PROFILE_FIXTURE"))))
 game.state.tutorial=5;game.state.onboarding.active=false;game.state.construction_intro=true;game.state.companion_enabled=false;game.state.city_services.enabled=false;game.state.ux.adaptive_detail=false
 game.simulate(780)
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene._process(0.6)
 var nodes=[scene]+scene.find_children("*","Node",true,false)
 for node in nodes:node.set_process(false);node.set_physics_process(false)
 var before=game.state.duplicate(true);before.erase("last_seen")
 var sections={}
 for frame in 180:
  for node in nodes:
   if not is_instance_valid(node) or not node.has_method("_process"):continue
   var script=node.get_script()
   if script==null:continue
   var key=script.resource_path
   if not sections.has(key):sections[key]={"total_ms":0.0,"max_ms":0.0,"calls":0}
   var began=Time.get_ticks_usec();node._process(1.0/30)
   var took=(Time.get_ticks_usec()-began)/1000.0
   sections[key].total_ms+=took;sections[key].max_ms=maxf(took,sections[key].max_ms);sections[key].calls+=1
 for value in sections.values():value.per_frame_ms=value.total_ms/180.0
 var after=game.state.duplicate(true);after.erase("last_seen")
 var report={"scripts":sections,"frames":180,"delta":1.0/30,"company_unchanged":before==after,"company_sha256":JSON.stringify(after,"",true,true).sha256_text(),"engine_memory_bytes":OS.get_static_memory_usage(),"desktop_cpu_only":true}
 FileAccess.open(OS.get_environment("TIMBER_BENCH_OUTPUT"),FileAccess.WRITE).store_string(JSON.stringify(report," "))
 print("SCRIPT PROFILE 2826: ",JSON.stringify(report))
 scene.queue_free()
 for i in 3:await process_frame
 quit(0 if before==after else 1)
