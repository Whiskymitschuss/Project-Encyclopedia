extends SceneTree
# Manual CPU-only companion to benchmark_frames.py, runnable against source or
# unchanged APK assets. A generated company is used; no player save is loaded.
func _initialize():call_deferred("run")
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false);root.get_node("RuntimeStats").set_process(false)
 var fixture=OS.get_environment("TIMBER_PROFILE_FIXTURE")
 if fixture.is_empty():fixture="res://Tests/Fixtures/forestry288-company.json"
 game.restore(JSON.parse_string(FileAccess.get_file_as_string(fixture)))
 game.simulate(780)
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 var nodes=[scene]+scene.find_children("*","Node",true,false)
 for node in nodes:node.set_process(false);node.set_physics_process(false)
 # Separate first-use mesh/actor construction from the steady-state samples.
 for node in nodes:
  if node.has_method("_process"):node._process(1.0/30)
 var before=game.state.duplicate(true)
 var report={"cpu_us":{},"company_unchanged":false,"desktop_only":true,"samples_per_section":240,"simulation_seconds_before_measurement":780}
 for entry in [["world",scene],["deliveries",scene.delivery_world],["forest",scene.forest_world],["alerts",scene.production_alerts],["city_traffic",scene.city_traffic]]:
  var t=Time.get_ticks_usec()
  for i in 240:entry[1]._process(1.0/30)
  report.cpu_us[entry[0]]=(Time.get_ticks_usec()-t)/240.0
 var route=[]
 for i in 160:route.append([int(i/2.0)*4,0,(int((i+1)/2.0)%2)*4])
 LogisticsRoutes.sample(route,0.5)
 var began=Time.get_ticks_usec()
 for i in 1000:LogisticsRoutes.sample(route,(i%101)/100.0)
 report.cpu_us.long_route_sample=(Time.get_ticks_usec()-began)/1000.0
 report.company_unchanged=before==game.state
 report.company_sha256=JSON.stringify(game.state,"",true,true).sha256_text()
 if not report.company_unchanged:printerr("FAILED: Runtime profile changed company state");quit(1);return
 var out=OS.get_environment("TIMBER_BENCH_OUTPUT")
 if not out.is_empty():FileAccess.open(out,FileAccess.WRITE).store_string(JSON.stringify(report," "))
 print("RUNTIME 2822: ",JSON.stringify(report))
 quit()
