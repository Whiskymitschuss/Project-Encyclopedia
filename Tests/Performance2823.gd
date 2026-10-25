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
 var before=game.state.duplicate(true)
 stats.record_frame(33,0.033,false)
 stats.record_frame(400,0.4)
 check(stats.detail_level==0,"An isolated 400ms stall cannot immediately drop graphics quality")
 for i in 80:stats.record_frame(200,0.2)
 check(stats.detail_level==3 and stats.low_detail,"Sustained five-FPS load reaches all three relief stages")
 var reduced=stats.resolution_scale(Vector2i(1080,2340),1,true,true)
 check(absf(reduced-sqrt(2000000.0/(1080*2340))*0.5)<0.001,"Severe mobile load lowers the world linear resolution to half its normal pixel budget")
 check(reduced<0.5 and reduced>0.4,"The screenshot-shaped phone can now go below its previous fixed 76% scale")
 check(stats.resolution_scale(Vector2i(1080,2340),0,true,true)<reduced,"Severe relief also supports the battery profile")
 check(stats.resolution_scale(Vector2i(1080,2340),1,true,true,true)==1.0,"Photo capture still bypasses adaptive resolution entirely")
 check(stats.resolution_scale(Vector2i(1080,2340),1,false,true)==1.0,"The player can still request native rendering")
 for i in 300:stats.record_frame(33,0.033)
 check(stats.detail_level==3,"A brief stable period cannot oscillate directly to full detail")
 for i in 1100:stats.record_frame(33,0.033)
 check(stats.detail_level==2,"Forty-five stable seconds restore only one quality stage")
 for i in 2800:stats.record_frame(33,0.033)
 check(stats.detail_level==0 and not stats.low_detail,"Long stability eventually restores full detail")
 check(stats.samples.size()==180 and stats.hitch_count>0 and stats.longest_hitch_ms==400,"Frame history stays bounded and retains actual stutter counts and maximum duration")
 stats.passive_enabled=true
 for i in 250:
  var t=stats.begin_work();stats.end_work("Testbereich",t)
 check(not stats.profiling and stats.passive_work.Testbereich.samples.size()==180,"Android-style passive CPU measurements run without a camera tour and remain bounded")
 stats.start_profile();var t=stats.begin_work();stats.end_work("Beide",t)
 var tour=stats.finish_profile()
 check(tour.Beide.samples==1 and stats.passive_work.has("Beide"),"Manual and passive measurements coexist without losing either result")
 check(stats.passive_summary().contains("Testbereich") and stats.summary().contains("Zeichenaufrufe"),"The real diagnostic text exposes passive timings and render counters")
 stats.passive_enabled=false;t=stats.begin_work()
 check(t==0,"Desktop normal play keeps passive CPU timing disabled")
 stats.record_frame(300,0.3,false)
 check(stats.detail_level==0 and not stats.low_detail,"Disabling adaptation resets every relief stage")
 check(game.state==before,"Every overload, recovery, photo, diagnostics and opt-out check preserves the full saved company")
 print("PERFORMANCE 2823: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
