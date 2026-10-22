extends SceneTree
var checks=0
var failures=[]
var frames=0
func check(ok: bool,why: String) -> void:
 checks+=1
 if not ok: failures.append(why); printerr("FAILED: ",why)
func _initialize() -> void:
 check(change_scene_to_file("res://Scenes/Boot.tscn")==OK,"Actual packaged boot scene opens")
 call_deferred("run")
func run() -> void:
 var game=root.get_node("Game")
 check(game.catching_up and game.state.elapsed==1234,"Cold autoload returns before the eight-hour fixture is simulated")
 var store=root.get_node("Store")
 var old_hash=FileAccess.get_sha256(store.PATH)
 for i in 4: await process_frame
 check(game.catching_up and game.catchup_curtain!=null,"Loading curtain is present during actual cold startup")
 check(current_scene!=null and current_scene.scene_file_path=="res://Scenes/Boot.tscn","The actual title scene is loaded behind the curtain")
 check(game.catchup_scene==current_scene and current_scene.process_mode==Node.PROCESS_MODE_DISABLED,"Cold-start scene processing is paused correctly")
 check(FileAccess.get_sha256(store.PATH)==old_hash,"Cold-start partial processing leaves old bytes untouched")
 var max_frame_usec=0
 var previous=Time.get_ticks_usec()
 while game.catching_up and frames<6000:
  await process_frame
  var now=Time.get_ticks_usec()
  max_frame_usec=maxi(max_frame_usec,now-previous)
  previous=now
  frames+=1
 check(not game.catching_up and is_equal_approx(game.state.elapsed,30034),"All eight offline hours complete once, without live title simulation")
 check(current_scene.process_mode==Node.PROCESS_MODE_INHERIT and game.catchup_curtain==null,"The title becomes available after completion")
 check(not store.load_game().is_empty() and FileAccess.get_sha256(store.PATH)!=old_hash,"The completed company is saved as a valid profile")
 check(game.return_report.seconds==28800,"The capped offline report covers eight hours")
 check(game.state.tutorial==5 and game.state.coins>=12345,"Existing tutorial and company funds survive the cold update")
 print("COLD START TIMING: ",frames," responsive frames; max host frame ",max_frame_usec," usec")
 print("COLD START 0.29.1: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
