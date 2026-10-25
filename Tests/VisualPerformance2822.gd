extends SceneTree
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func settle():
 for i in 5:await process_frame
 await RenderingServer.frame_post_draw
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 var stats=root.get_node("RuntimeStats");stats.set_process(false)
 game.state=game.initial_state();var s=game.state
 s.tutorial=5;s.onboarding.active=false;s.construction_intro=true;s.companion_enabled=false;s.city_services.enabled=false;s.workers=0
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.life.set_process(false);scene.hud.ux.set_process(false)
 root.size=Vector2i(591,1280);root.content_scale_size=root.size
 await settle()
 var forest=scene.forest_world;forest.set_process(false)
 var index=50;var tree=scene.trees[0][index]
 ForestCycle.stand(s,0).cells[str(index)]={"state":"stump","wood":0.0}
 forest.sync_trees(false)
 check(scene.tree_batches[0][1].multimesh.get_instance_transform(index).basis.get_scale().y<0.01,"A harvested tree is actually absent from the GPU canopy buffer")
 var cell=s.forest.stands["0"].cells[str(index)]
 cell.state="growing";cell.ready_at=float(s.elapsed)+45;cell.grow_seconds=45.0
 forest.sync_trees(false)
 var first=scene.tree_batches[0][1].multimesh.get_instance_transform(index)
 s.elapsed+=15;forest.sync_trees(false)
 check(scene.tree_batches[0][1].multimesh.get_instance_transform(index).basis.get_scale().y>first.basis.get_scale().y,"The optimized GPU buffer still increases the real seedling size")
 scene.refresh_forest_clearance()
 check(scene.tree_batches[0][1].multimesh.get_instance_transform(index).basis.get_scale().y>first.basis.get_scale().y,"Rebuilding clearance retains actual growth, rather than hiding a cached seedling")
 var before=s.duplicate(true);var origin=scene.focus;var zoom=scene.zoom
 scene.camera_action("benchmark")
 var tour=scene.performance_tour;tour.set_process(false)
 check(stats.profiling,"Starting the real HUD camera tour enables CPU-section profiling")
 scene.camera_action("benchmark")
 check(scene.performance_tour==tour,"Repeated taps cannot start two concurrent camera profilers")
 for i in 6:
  scene._process(0.033);scene.delivery_world._process(0.033);scene.forest_world._process(0.033);scene.city_traffic._process(0.033);scene.production_alerts._process(0.033)
  await process_frame
  tour._process(0.033)
 check(tour.button.position.y>=scene.hud.mission_button.get_global_rect().end.y+10,"The stop button stays below the quest bar")
 scene.hud.open_menu("performance");tour._process(0.033)
 check(not tour.button.visible,"Opening a menu hides the floating stop button instead of overlapping the performance text")
 tour.finish();await settle()
 var result=game.performance_results
 check(not stats.profiling and result.has("work") and result.work.has("Welt") and result.work.has("Transportdarstellung"),"Finishing records actual bounded per-section CPU timings")
 check(result.version==ProjectSettings.get_setting("application/config/version") and result.draw_calls>0,"The measurement identifies the actual installed version and real renderer draw calls")
 check(scene.focus==origin and scene.zoom==zoom and scene.performance_tour==null,"The tour restores camera position/zoom and releases itself")
 check(s==before,"The real rendered tour and its CPU measurements never alter stock, progress or workers")
 var labels=scene.hud.contents.find_children("*","Label",true,false)
 check(labels.any(func(label):return label.text.contains("Zeichenaufrufe")),"The measured draw calls are actually shown in the existing performance menu")
 for size_value in [Vector2i(360,640),Vector2i(591,1280)]:
  root.size=size_value;root.content_scale_size=size_value;s.ux.large_text=true
  scene.hud.open_menu("performance");await settle()
  check(scene.hud.scroll.size.y>0 and scene.hud.overlay.get_global_rect().end.x<=size_value.x+1,"Detailed results remain scrollable with large text at "+str(size_value))
 root.get_texture().get_image().save_png("/workspace/timber2822-performance.png")
 scene.queue_free();await process_frame
 print("VISUAL PERFORMANCE 2822: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
