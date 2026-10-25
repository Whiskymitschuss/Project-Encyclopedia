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
 s.tutorial=5;s.onboarding.active=false;s.construction_intro=true;s.city_services.enabled=false;s.companion_enabled=false
 root.size=Vector2i(591,1280);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.life.set_process(false);scene.hud.ux.set_process(false)
 scene.focus=Catalog.biome_position(0);scene.zoom=100;scene.set_camera();await settle()
 scene.focus+=Vector3(12,0,0);scene.ease_camera();scene._process(0.033)
 var held=scene.camera.global_transform
 var press=InputEventScreenTouch.new();press.position=Vector2(290,360);press.pressed=true
 scene._unhandled_input(press);scene._process(0.2)
 check(not scene.camera_transition and scene.camera.global_transform==held,"Touching during a smooth camera transition freezes the actual view under the finger")
 press.pressed=false;press.canceled=true;scene._unhandled_input(press)
 check(scene.touches.is_empty(),"Canceled inspection input clears the held pointer without harvesting")
 scene.focus=Catalog.biome_position(0);scene.set_camera()
 var source=scene.tree_batches[0][1]
 check(source.multimesh.mesh==source.get_meta("near_mesh"),"A healthy scene renders the existing detailed forest geometry")
 var before=s.duplicate(true);var camera=scene.camera.global_transform;var hud_rect=scene.hud.header_panel.get_global_rect();var count=scene.landscape.records.size()
 stats.detail_level=3;stats.low_detail=true
 scene._process(0.6);scene.landscape._process(0);await settle()
 check(absf(root.scaling_3d_scale-0.5)<0.001,"The existing main world applies severe resolution relief")
 check(source.multimesh.mesh==source.get_meta("far_mesh"),"A stationary camera switches actual GPU forest geometry to the existing low-detail mesh")
 check(scene.landscape.batches.values().all(func(data):return data.mesh.mesh==data.far),"Scenery really selects its lower-detail meshes, rather than just changing the displayed setting")
 check(scene.landscape.records.size()==count and scene.trees[0].size()==100,"No harvestable trees or decorative records are deleted for the performance change")
 check(scene.camera.global_transform==camera and scene.hud.header_panel.get_global_rect()==hud_rect,"Adaptive relief leaves the camera and native Canvas layout unchanged")
 scene.photo.enter();scene.landscape._process(0);await settle()
 check(root.scaling_3d_scale==1 and source.multimesh.mesh==source.get_meta("near_mesh"),"Photo mode restores full resolution and detailed forest geometry immediately")
 scene.photo.leave();scene.landscape._process(0);await settle()
 check(absf(root.scaling_3d_scale-0.5)<0.001 and source.multimesh.mesh==source.get_meta("far_mesh"),"Leaving photo mode restores the actual live relief tier")
 stats.record_frame(33,0.033,false);scene._process(0.6);scene.landscape._process(0);await settle()
 check(root.scaling_3d_scale==1 and source.multimesh.mesh==source.get_meta("near_mesh"),"Stable/native presentation can regain all original detail")
 stats.passive_enabled=true
 scene._process(0.04);scene.hud.open_menu("performance");await settle()
 var labels=scene.hud.contents.find_children("*","Label",true,false)
 check(labels.any(func(label):return label.text.contains("Automatische Messdetails")) and labels.any(func(label):return label.text.contains("Welt:")),"The real performance menu shows CPU timings without starting any tour")
 check(s==before,"Adaptive GPU rendering and automatic measurement preserve every company field")
 for size in [Vector2i(360,640),Vector2i(591,1280)]:
  root.size=size;root.content_scale_size=size;s.ux.large_text=true;scene.hud.open_menu("performance");await settle()
  check(scene.hud.scroll.size.y>0 and scene.hud.overlay.get_global_rect().end.x<=size.x+1,"Automatic measurements remain scrollable with large text at "+str(size))
 root.get_texture().get_image().save_png("/workspace/timber2823-performance.png")
 scene.queue_free();await process_frame
 print("VISUAL PERFORMANCE 2823: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
