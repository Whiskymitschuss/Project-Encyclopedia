extends SceneTree
var checks=0
var failures=[]
var game
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func settle() -> void:
 for i in 5: await process_frame
func finish() -> void:
 while game.catching_up: game.process_catchup(1000000,120)
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 game.restore(game.initial_state())
 game.state.workers=4
 game.state.resources.wood=80.0
 Journey.refresh(game.state)
 var saved=game.state.duplicate(true)
 game.rng.seed=291
 game.simulate(600.25)
 var expected=game.state.duplicate(true)
 game.restore(saved)
 game.rng.seed=291
 check(game.save(true),"A healthy pre-start profile is saved in the isolated test directory")
 var store=root.get_node("Store")
 var original=FileAccess.get_sha256(store.PATH)
 var boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 current_scene=boot
 await process_frame
 game.queue_catchup(600.25,Journey.resume_capture(game.state),600.25)
 check(game.catching_up and not game.catchup_running and game.state==saved,"Queueing a long offline interval returns before any simulation")
 boot.start_game()
 check(not boot.starting,"Play cannot launch the world during incomplete offline recovery")
 check(not game.save(true) and FileAccess.get_sha256(store.PATH)==original,"A partial catch-up cannot overwrite the original profile")
 await settle()
 check(game.catchup_running and is_instance_valid(game.catchup_curtain),"Deferred recovery creates a real loading curtain before processing")
 check(boot.process_mode==Node.PROCESS_MODE_DISABLED,"Scene animation and input processing wait while the company is updated")
 game.process_catchup(1000000,3)
 check(is_equal_approx(game.catchup_left,597.25) and is_equal_approx(game.state.elapsed,3),"A bounded batch processes only its three requested seconds")
 game.notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
 check(FileAccess.get_sha256(store.PATH)==original,"Closing halfway leaves the original save bytes intact")
 game.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 var before_pause=game.catchup_left
 game._process(100)
 check(game.catchup_left==before_pause,"A paused Android app does not advance the catch-up")
 game.catchup_paused_at=Time.get_unix_time_from_system()
 game.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 # Ignore the tiny wall-clock notification gap in this deterministic replay.
 game.catchup_left=597.25
 game.catchup_total=600.25
 game.catchup_report_seconds=600.25
 finish()
 check(game.state==expected,"Chunked recovery exactly matches normal simulation, including fractional seconds and production")
 check(not game.catching_up and not game.is_blocking_signals() and boot.process_mode==Node.PROCESS_MODE_INHERIT,"Completion restores scene processing and gameplay signals")
 check(game.return_report.seconds==600.25,"The return report covers the recovered interval")
 check(FileAccess.get_sha256(store.PATH)!=original and not store.load_game().is_empty(),"Only the completed recovery writes a valid updated profile")
 var after=game.state.duplicate(true)
 game.process_catchup()
 check(game.state==after,"Calling an already completed batch cannot pay offline production twice")
 game.live_world=true
 game.tick_clock=0
 game._process(1000)
 check(game.state==after,"The first foreground delta cannot replay the Android background interval")
 game.restore(saved)
 game.paused_at=1000
 game.pause_capture=Journey.resume_capture(game.state)
 game.step(5)
 game.resume_company(1100,true)
 check(game.catching_up and game.catchup_left==95 and game.paused_at==0,"Real Android resume queues only the seconds not already simulated in the background")
 await settle()
 finish()
 check(is_equal_approx(game.state.elapsed,100),"Deferred background resume accounts for the gap exactly once")
 after=game.state.duplicate(true)
 game.resume_company(1100,true)
 check(game.state==after and not game.catching_up,"Duplicate resume notifications cannot duplicate progress")
 game.queue_catchup(60000,Journey.resume_capture(game.state),60000)
 check(game.catchup_total==28800 and game.catchup_report_seconds==28800,"Both recovery and report preserve the existing eight-hour limit")
 await settle()
 game.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 game.catchup_paused_at=Time.get_unix_time_from_system()-300
 game.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 check(game.catchup_total==28800,"Suspending during a capped recovery cannot extend its eight-hour allowance")
 game.restore(saved)
 await settle()
 check(not game.catching_up and game.state==saved and boot.process_mode==Node.PROCESS_MODE_INHERIT,"Restoring cancels pending coroutines, curtain and processing lock without modifying the restored company")
 game.queue_catchup(10,Journey.resume_capture(game.state),10)
 game.queue_catchup(20,Journey.resume_capture(game.state),20)
 await settle()
 check(game.catchup_curtain!=null and game.get_children().filter(func(n): return n is CanvasLayer).size()==1,"Replacing a deferred request creates exactly one active curtain")
 finish()
 check(game.state.elapsed==20,"Replacing a request does not also simulate the canceled interval")
 check(ProjectSettings.get_setting("application/boot_splash/show_image") and ResourceLoader.exists(ProjectSettings.get_setting("application/boot_splash/image")),"The native startup splash has a real packaged logo before scripts load")
 boot.queue_free()
 await settle()
 print("STARTUP RECOVERY 0.29.1: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
