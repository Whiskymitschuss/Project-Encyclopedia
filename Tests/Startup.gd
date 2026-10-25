extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func loaded(boot: Control) -> void:
 var deadline=Time.get_ticks_msec()+10000
 while boot.scene_ready==null and not boot.load_failed and Time.get_ticks_msec()<deadline:
  boot._process(0)
  await process_frame
 boot._process(0)
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 var store=root.get_node("Store")
 game.set_process(false)
 game.state=game.initial_state()
 game.title_requested=true
 var before=game.state.duplicate(true)
 var boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 current_scene=boot
 boot.set_process(false)
 await loaded(boot)
 check(boot.logo.texture!=null and boot.logo.texture.resource_path.ends_with("timber-loading.png"),"The real cover loads the new full-screen beaver art")
 check(boot.find_children("*","SubViewport",true,false).is_empty(),"Cold cover does not create a decorative 3D world")
 check(boot.ready_to_play and boot.play.visible and not boot.starting,"An explicit menu return holds a ready cover with Continue")
 check(game.state==before,"Loading cover leaves company resources and saved progress untouched")
 check(boot.artwork.meter.value==100,"Manual return is ready only after the actual scene resource has loaded")
 boot.queue_free()
 await process_frame
 store.recovery_required=true
 boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 current_scene=boot
 await process_frame
 boot.start_game()
 check(not boot.starting and boot.recovery_box.visible and not boot.play.visible,"Unreadable saves block automatic and keyboard entry until explicit recovery")
 check(game.state==before,"Recovery cover never creates a new company by itself")
 boot.queue_free()
 await process_frame
 store.recovery_required=false
 game.state.ux.motion=false
 game.title_requested=false
 boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 current_scene=boot
 boot.set_process(false)
 await loaded(boot)
 check(boot.starting and not boot.play.visible,"An ordinary launch automatically enters without an intro timer or Play tap")
 boot.start_game()
 check(boot.starting and boot.play.disabled,"Repeated entry cannot enqueue a second world transition")
 var opening_deadline=Time.get_ticks_msec()+15000
 while Time.get_ticks_msec()<opening_deadline:
  if current_scene!=null and current_scene.scene_file_path=="res://Scenes/Main.tscn" and current_scene.is_processing():break
  await process_frame
 check(current_scene!=null and current_scene.scene_file_path=="res://Scenes/Main.tscn","Automatic entry opens the real playable main scene")
 check(current_scene.get("hud")!=null,"Automatic entry retains the actual HUD and onboarding")
 print("STARTUP: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
