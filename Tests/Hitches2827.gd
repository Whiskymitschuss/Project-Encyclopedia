extends SceneTree
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func drain(store: Node,timeout_ms: int=5000) -> int:
 var deadline=Time.get_ticks_msec()+timeout_ms
 var frames=0
 while store.is_saving() and Time.get_ticks_msec()<deadline:
  store._process(0)
  frames+=1
  await create_timer(0.01).timeout
 return frames
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 var stats=root.get_node("RuntimeStats");stats.set_process(false)
 var store=root.get_node("Store");store.set_process(false)
 var real_writer=store.writer_script
 var before=game.state.duplicate(true)
 var initial=game.snapshot();initial.coins=10
 check(store.save_game(initial),"The original durable save API still writes a valid baseline")
 var slow=GDScript.new()
 slow.source_code='extends "res://SaveSystem/SaveFiles.gd"\nfunc save_game(data: Dictionary) -> bool:\n OS.delay_msec(350)\n return super.save_game(data)\n'
 check(slow.reload()==OK,"A controlled slow filesystem transaction compiles for the worker test")
 store.writer_script=slow
 var first=initial.duplicate(true);first.coins=20
 var began=Time.get_ticks_usec()
 check(store.queue_game(first),"A slow transaction is accepted as an asynchronous job")
 var enqueue_ms=(Time.get_ticks_usec()-began)/1000.0
 check(enqueue_ms<100,"Enqueuing a 350-ms file transaction does not wait for its disk work")
 var middle=initial.duplicate(true);middle.coins=30;store.queue_game(middle)
 var latest=initial.duplicate(true);latest.coins=40;latest.resources.wood=5
 check(store.queue_game(latest) and not store.pending.is_empty(),"Several requests retain a single newest pending snapshot")
 latest.coins=999;latest.resources.wood=999
 var frames=await drain(store)
 var loaded=store.load_game()
 check(not store.is_saving() and frames>=10,"Scene-tree timers/frames continue while both slow saves execute")
 check(loaded.coins==40 and loaded.resources.wood==5,"The newest immutable snapshot wins; caller mutations cannot leak into disk writes")
 check(store.last_completed.id==store.request_id and store.last_completed.ok,"Completion reports the actual committed sequence")
 check(store.read_file(store.PATH+".bak").coins==20,"The rotating backup retains the previous complete successful transaction")
 print("HITCH SAVE BENCH: enqueue %.3f ms, %s responsive frames, simulated file delay 350 ms per transaction" % [enqueue_ms,frames])
 var old=initial.duplicate(true);old.coins=60;store.queue_game(old)
 old.coins=70;store.queue_game(old)
 var urgent=initial.duplicate(true);urgent.coins=80
 check(store.save_game(urgent),"An explicit durable save safely waits for the active writer")
 store._process(0)
 check(not store.is_saving() and store.load_game().coins==80,"A pending older snapshot cannot overwrite a newer durable save")
 var original_hash=FileAccess.get_sha256(store.PATH)
 var broken=GDScript.new()
 broken.source_code='extends "res://SaveSystem/SaveFiles.gd"\nfunc save_game(_data: Dictionary) -> bool:\n last_error="Injected write failure"\n return false\n'
 check(broken.reload()==OK,"The failure-injection writer compiles")
 store.writer_script=broken
 check(store.queue_game(initial),"A background transaction can report a real eventual failure")
 await drain(store)
 check(not store.last_completed.ok and store.last_error.contains("Injected"),"Failed worker writes are surfaced as failures, not successful saves")
 check(FileAccess.get_sha256(store.PATH)==original_hash,"A rejected worker transaction leaves the previous durable file untouched")
 store.writer_script=real_writer
 var recovery=initial.duplicate(true);recovery.coins=90
 store.queue_game(recovery)
 check(store.flush_queued() and store.load_game().coins==90,"Shutdown draining retains the final valid snapshot after a failed request")
 original_hash=FileAccess.get_sha256(store.PATH)
 check(not store.queue_game({"schema":"invalid"}) and FileAccess.get_sha256(store.PATH)==original_hash,"Invalid snapshots cannot enter the worker queue")
 store.recovery_required=true
 check(not store.queue_game(initial),"Unreadable player files keep their existing recovery gate")
 store.recovery_required=false
 stats.passive_enabled=true;stats.slow_work.clear();stats.long_stalls.clear()
 var measured_start=Time.get_ticks_usec()
 OS.delay_msec(60)
 stats.end_work("Measured test section",measured_start)
 stats.record_frame(5000,5,false)
 check(stats.long_stalls[0].area=="Measured test section" and stats.long_stalls[0].script_ms>=50,"A five-second gap retains a measured slow script section from the same interval")
 stats.slow_work.clear();stats.record_frame(10000,10,false)
 check(stats.long_stalls[0].script_ms==0 and stats.stalls_summary().contains("nicht zugeordnet"),"An untraced engine/render gap is reported as unknown instead of blamed on saving")
 for i in 30:stats.record_frame(2000,2,false)
 check(stats.long_stalls.size()==12,"Long-stall history remains bounded in memory without writing logs per frame")
 check(game.state==before,"All asynchronous saves and diagnostics preserve the live company's state")
 stats.passive_enabled=false;store.set_process(true)
 print("HITCHES 2827: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
