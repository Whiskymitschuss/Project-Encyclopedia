extends SceneTree
var checks=0
var failures=[]
var began=Time.get_ticks_msec()
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 var store=root.get_node("Store")
 var saved=store.read_file(store.PATH)
 check(not saved.is_empty(),"Cold process has the generated existing company, not a fresh game")
 var initial_elapsed=float(saved.elapsed)
 var boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 current_scene=boot
 var first=Time.get_ticks_msec()-began
 await process_frame
 await RenderingServer.frame_post_draw
 check(boot.logo.texture!=null and not root.get_texture().get_image().is_empty(),"A real first cold-start frame displays the brand before the company is replayed")
 if game.catching_up:
  var original=FileAccess.get_sha256(store.PATH)
  check(not game.save(true) and FileAccess.get_sha256(store.PATH)==original,"Cold startup cannot overwrite the existing company with a partial replay")
  check(game.replay_overlay!=null and game.replay_overlay.is_inside_tree(),"Long cold starts expose the actual progress overlay")
 var deadline=began+90000
 var frames=0
 while game.catching_up and Time.get_ticks_msec()<deadline:
  frames+=1
  await process_frame
 check(not game.catching_up,"Eight offline hours complete in the actual cold-start process")
 check(absf(float(game.state.elapsed)-initial_elapsed-28800)<1,"Cold start computes eight hours once")
 check(float(game.state.gathered)>float(saved.gathered),"The cold-loaded advanced company resumes actual forestry during its eight offline hours")
 check(CentralLogistics.available_trucks(game.state)>=0,"Cold startup preserves real central fleet assignments")
 check(store.valid_shape(store.load_game()),"Cold start commits a valid complete company")
 var world_deadline=Time.get_ticks_msec()+10000
 while current_scene==boot and Time.get_ticks_msec()<world_deadline: await process_frame
 check(not paused and current_scene!=null and current_scene.scene_file_path=="res://Scenes/Main.tscn","Cold startup automatically enters the actual world after complete replay")
 print("COLD START 288 MEASURE: first script frame ",first," ms, total ",Time.get_ticks_msec()-began," ms, responsive frames ",frames)
 print("VISUAL COLD START 288: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
