extends SceneTree
var checks=0
var failures=[]
var game
func _initialize() -> void: call_deferred("run")
func check(ok: bool,why: String) -> void:
 checks+=1
 if not ok: failures.append(why); printerr("FAILED: ",why)
func settle() -> void:
 for i in 5: await process_frame
func finish() -> void:
 for i in 10000:
  if not game.catching_up: return
  game.process_catchup()
  await process_frame
 check(false,"Background simulation completes within the test frame limit")
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 game.use_catchup_worker=true
 game.restore(game.initial_state())
 game.state.city_services.enabled=false
 game.state.workers=4
 game.state.resources.wood=80.0
 Journey.refresh(game.state)
 var saved=game.state.duplicate(true)
 game.simulate(28800)
 var expected=game.state.duplicate(true)
 game.restore(saved)
 check(game.save(true),"A healthy original company is saved before background recovery")
 var store=root.get_node("Store")
 var original=FileAccess.get_sha256(store.PATH)
 var boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 current_scene=boot
 await process_frame
 game.queue_catchup(28800,Journey.resume_capture(game.state),28800)
 check(game.catchup_worker!=null,"Worker starts immediately, even before a deferred loading frame or immediate minimization")
 await settle()
 var work=game.catchup_worker
 check(work!=null and game.catchup_running,"The actual loading flow starts a separate computation thread")
 if work==null: quit(1); return
 check(not work.simulation.is_inside_tree(),"Worker simulation is detached from the scene tree")
 check(game.state==saved,"Active company remains untouched while the worker calculates its own copy")
 var before=float(work.progress().remaining)
 game.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 # No process_frame is emitted here: equivalent to a suspended render loop.
 OS.delay_msec(250)
 var progress=work.progress()
 check(progress.complete or float(progress.remaining)<before,"Calculation advances while the main loop is blocked and the app is marked paused")
 game._process(500)
 check(game.state==saved and FileAccess.get_sha256(store.PATH)==original,"Minimizing cannot adopt or save an incomplete result")
 game.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 await finish()
 check(game.state==expected,"Eight-hour worker result exactly matches the normal simulation")
 check(game.catchup_worker==null and game.catchup_curtain==null and not game.is_blocking_signals(),"Completed worker is joined, freed and its input curtain is removed")
 check(boot.process_mode==Node.PROCESS_MODE_INHERIT and game.return_report.seconds==28800,"Scene and return report resume normally")
 check(FileAccess.get_sha256(store.PATH)!=original and not store.load_game().is_empty(),"Only a completed result updates the valid save")
 game.restore(saved)
 game.queue_catchup(600.25,Journey.resume_capture(game.state),600.25)
 await settle()
 game.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 game.catchup_paused_at=Time.get_unix_time_from_system()-120
 game.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 var extra=game.catchup_total-600.25
 check(extra>=120 and extra<121 and game.catchup_extension==extra,"Returning from background queues only the added wall-clock gap")
 await finish()
 var actual=game.state.duplicate(true)
 game.restore(saved)
 game.simulate(600.25)
 game.simulate(extra)
 check(game.state==actual,"A second worker stage accounts for background time and fractional production exactly once")
 game.restore(saved)
 game.queue_catchup(28800,Journey.resume_capture(game.state),28800)
 await settle()
 work=game.catchup_worker
 game.restore(saved)
 await settle()
 check(game.state==saved and game.catchup_worker==null and not work.thread.is_started(),"Cancel or restore joins the worker before discarding its isolated result")
 game.queue_catchup(28800,Journey.resume_capture(game.state),28800)
 await settle()
 game.queue_catchup(20,Journey.resume_capture(game.state),20)
 await settle()
 await finish()
 check(game.state.elapsed==20 and game.catchup_worker==null,"Replacing an active worker cannot later apply its stale result")
 boot.queue_free()
 await settle()
 print("BACKGROUND RECOVERY 0.29.2: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
