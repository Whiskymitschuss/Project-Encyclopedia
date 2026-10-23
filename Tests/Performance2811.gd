extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 var stats=root.get_node("RuntimeStats")
 game.set_process(false)
 stats.set_process(false)
 var before=game.state.duplicate(true)
 stats.samples.clear(); stats.low_detail=false; stats.slow_seconds=0; stats.stable_seconds=0; stats.since_change=45
 for i in 61: stats.record_frame(50,0.05)
 check(stats.low_detail,"Sustained poor frame times reduce presentation after three real seconds")
 for i in 100: stats.record_frame(33,0.033)
 check(stats.low_detail,"A short recovery cannot immediately oscillate back to full detail")
 for i in 1400: stats.record_frame(33,0.033)
 check(not stats.low_detail,"Stable frame times eventually recover full detail with cooldown")
 check(stats.samples.size()==180,"Passive metrics use a bounded sample window")
 var report=stats.snapshot()
 check(absf(report.fps-1000.0/33)<0.01 and report.p95_ms==33,"Actual sample durations determine rolling FPS and P95")
 stats.low_detail=true
 stats.record_frame(100,0.1,false)
 check(not stats.low_detail,"The player can disable adaptive detail without changing simulation")
 var scale_value=stats.resolution_scale(Vector2i(1440,3120),1,true,true)
 check(absf(1440*3120*scale_value*scale_value-2000000)<1,"A high-DPI mobile panel uses the explicit two-megapixel world budget")
 check(stats.resolution_scale(Vector2i(720,1280),1,true,true)==1,"Smaller mobile panels retain native world resolution")
 check(stats.resolution_scale(Vector2i(1440,3120),1,false,true)==1,"Disabling adaptive detail permits native resolution on a high-DPI panel")
 check(stats.resolution_scale(Vector2i(1440,3120),1,true,true,true)==1,"Photo mode bypasses the device pixel budget")
 check(stats.resolution_scale(Vector2i(1440,3120),0,true,true)<scale_value,"Battery mode further reduces the mobile world pixel budget")
 check(game.state==before,"Sampling and adaptive detail never change company state or currency")
 stats.request_world()
 stats.mark_world_ready()
 check(stats.samples.is_empty() and stats.world_ready_ms>=0,"World opening starts a separate measurement and resets stale samples")
 stats.begin_replay(120)
 stats.end_replay(180)
 check(stats.replay_seconds==180 and stats.replay_ms>=0,"Replay metrics retain the actual extended offline duration")
 check(stats.summary().contains("Engine-Start") and not stats.summary().contains("Temperatur"),"The metric description avoids inventing OS launch timing or temperature")
 game.state=game.initial_state()
 var s=game.state
 var point=game.building_position(1)
 var access=PlacementAccess.describe(s,point,0,"sawmill")
 check(access.connected and access.path.size()==2,"Placement preview finds the same connected starter road used by logistics")
 access=PlacementAccess.describe(s,Vector3(900,0,900),90,"central_depot")
 check(not access.connected and access.path.is_empty(),"A far-away plot cannot claim a fictional truck connection")
 var snapshot=s.duplicate(true)
 for rotation in [0,90,180,270]: PlacementAccess.describe(s,point,rotation,"sawmill")
 check(s==snapshot,"All access previews are read-only")
 s.ux.erase("adaptive_detail")
 s.coins=1234
 game.restore(s)
 check(game.state.ux.adaptive_detail and game.state.coins==1234,"An old save gets the new presentation preference without changing progress")
 print("PERFORMANCE 2811: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
