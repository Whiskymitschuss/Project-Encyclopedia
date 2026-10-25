extends SceneTree
func _initialize():call_deferred("run")
func run():
 await process_frame
 var game=root.get_node("Game")
 var boot=load("res://Scenes/Boot.tscn").instantiate();root.add_child(boot);current_scene=boot
 var deadline=Time.get_ticks_msec()+20000
 while Time.get_ticks_msec()<deadline:
  if current_scene!=null and current_scene.scene_file_path=="res://Scenes/Main.tscn" and current_scene.is_processing():break
  await process_frame
 var ready=current_scene!=null and current_scene.scene_file_path=="res://Scenes/Main.tscn" and current_scene.is_processing()
 if not ready:printerr("FAILED: Cold startup did not finish the actual world");quit(1);return
 for i in 10:await process_frame
 var scene=current_scene
 var integrated=scene.hud!=null and scene.chunks!=null and scene.tree_batches.size()==10
 var staff=scene.actors.get_child_count()>0
 game.live_world=false;scene.queue_free();current_scene=null
 for i in 4:await process_frame
 var clean=Node.get_orphan_node_ids().is_empty()
 if not integrated or not staff or not clean:printerr("FAILED: Startup integration/staff/cleanup: ",integrated," ",staff," ",clean)
 print("STARTUP SMOKE 2826: 4 checks, %s failures" % int(not integrated or not staff or not clean))
 quit(0 if integrated and staff and clean else 1)
