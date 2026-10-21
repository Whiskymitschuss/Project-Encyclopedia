extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 var before=game.state.duplicate(true)
 var boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 boot.set_process(false)
 await process_frame
 check(boot.logo.texture!=null,"New brand image loads")
 check(boot.logo.stretch_mode==TextureRect.STRETCH_KEEP_ASPECT_CENTERED,"Brand image keeps its aspect ratio")
 boot._process(1.7)
 check(boot.chapter.text==boot.STEPS[1],"Intro advances to its second story phase")
 boot._process(1.6)
 check(boot.chapter.text==boot.STEPS[2],"Intro reaches the city phase")
 boot._process(2)
 check(boot.ready_to_play and not boot.skip.visible,"Intro naturally ends without an unskippable wait")
 check(game.state==before,"Intro does not spend currency, reset progress or modify saves")
 boot.queue_free()
 await process_frame
 game.state.ux.motion=false
 boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 boot.set_process(false)
 await process_frame
 check(boot.ready_to_play and boot.logo.modulate.a==1,"Reduced motion immediately shows a readable title screen")
 check(boot.play.disabled==false,"Reduced motion preserves the Play action")
 boot.queue_free()
 await process_frame
 game.state.ux.motion=true
 boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 current_scene=boot
 boot.set_process(false)
 await process_frame
 boot.skip.pressed.emit()
 check(boot.ready_to_play and not boot.starting,"Skip completes the intro without creating a world")
 boot.play.pressed.emit()
 boot.start_game()
 check(boot.starting and boot.play.disabled,"Repeated Play cannot trigger duplicate launches")
 for i in 8: await process_frame
 check(current_scene!=null and current_scene.scene_file_path=="res://Scenes/Main.tscn","Play opens the actual game scene")
 check(current_scene.get("hud")!=null,"The playable world has its real HUD")
 print("STARTUP: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
