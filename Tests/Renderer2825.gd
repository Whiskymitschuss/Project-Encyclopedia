extends SceneTree
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 var stats=root.get_node("RuntimeStats");stats.set_process(false)
 var expected=OS.get_environment("TIMBER_EXPECT_ANDROID_RENDERER")
 if expected.is_empty():expected="mobile"
 check(ProjectSettings.get_setting("rendering/renderer/rendering_method.mobile")==expected,"The actual project carries the declared Android renderer")
 check(ProjectSettings.get_setting("rendering/rendering_device/fallback_to_opengl3"),"The engine retains its OpenGL fallback when Vulkan initialization fails")
 check(ProjectSettings.get_setting("rendering/rendering_device/driver.android")=="vulkan","The Mobile build explicitly selects Android Vulkan")
 var before=game.state.duplicate(true)
 stats.start_render_probe()
 stats.render_probe_samples=[Vector2(2,5),Vector2(3,7),Vector2(4,9)]
 stats.sample_render_probe(11)
 check(stats.render_probe_result.cpu_ms==3 and stats.render_probe_result.gpu_ms==7,"Bounded render probes report separate render-CPU and GPU medians")
 check(stats.render_probe_left==0,"A probe disables timing again after its ten-second budget")
 stats.start_render_probe();stats.sample_render_probe(11)
 check(stats.render_probe_result.is_empty() and stats.render_probe_summary().contains("nicht verfügbar"),"Unsupported render timers never masquerade as zero-cost GPU results")
 stats.start_render_probe();stats._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 check(stats.render_probe_left==0 and stats.render_probe_result.is_empty(),"Backgrounding cancels optional GPU queries instead of reporting stale frames")
 stats.append_work(stats.passive_work,"Seltene Spitze",450)
 for i in 250:stats.append_work(stats.passive_work,"Seltene Spitze",1)
 var recent=stats.summarize_work(stats.passive_work)["Seltene Spitze"]
 check(recent.mean_ms==1 and recent.max_ms==450,"A rare long stall stays visible after it leaves the rolling frame window")
 check(game.state==before,"Backend diagnostics cannot edit progress, stock or saved settings")
 print("RENDERER 2825: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
