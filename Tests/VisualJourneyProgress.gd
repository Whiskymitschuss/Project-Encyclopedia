extends SceneTree
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func find_button(hud,caption: String):
 var found=hud.contents.find_children("*","Button",true,false).filter(func(b):return b.text.begins_with(caption))
 return null if found.is_empty() else found[0]
func draw():
 for i in 5:await process_frame
 await RenderingServer.frame_post_draw
func tap(hud,button):
 check(button!=null,"Visible action exists")
 if button==null:return
 hud.scroll.ensure_control_visible(button);await draw()
 var point=root.get_screen_transform()*button.get_global_rect().get_center()
 var down=InputEventScreenTouch.new();down.position=point;down.index=0;down.pressed=true
 Input.parse_input_event(down);await process_frame
 var up=InputEventScreenTouch.new();up.position=point;up.index=0;up.pressed=false
 Input.parse_input_event(up);await draw()
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 root.get_node("RuntimeStats").set_process(false)
 root.get_node("Music").shutdown()
 game.restore(JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/journey-rh10-earned.json")))
 check(Journey.townhall_level(game.state)==10 and Journey.current(game.state).is_empty(),"The unseeded full-run save loads at the real end of all ten chapters")
 check(root.get_node("Store").valid_shape(game.snapshot()),"Earned endgame state passes save validation")
 root.size=Vector2i(540,960);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.life.set_process(false)
 await draw()
 check(scene.is_inside_tree() and scene.hud!=null,"The actual main world displays the earned late-game economy")
 var hud=scene.hud
 hud.open_menu("journey");await draw()
 check(hud.contents.find_children("*","Label",true,false).any(func(l):return l.text.contains("Alle zehn Kapitel geschafft")),"Chapter menu presents its actual completed ending")
 hud.open_menu("stone");await draw()
 var index=-1
 for i in game.state.buildings.size():
  if game.state.buildings[i].kind=="stoneworks":index=i;break
 check(index>=0 and StoneIndustry.auto_recipe(game.state,index),"Earned new stoneworks retains its automatic production preference")
 var inventory=game.state.resources.duplicate(true)
 var before=game.state.stone.delivered
 await tap(hud,find_button(hud,"Bedarfsautomatik: AN"))
 check(not StoneIndustry.auto_recipe(game.state,index),"A finger tap disables automatic recipe switching")
 await tap(hud,find_button(hud,"Bedarfsautomatik: AUS"))
 check(StoneIndustry.auto_recipe(game.state,index),"A finger tap enables automatic switching")
 await tap(hud,find_button(hud,"Bausteine"))
 check(not StoneIndustry.auto_recipe(game.state,index) and StoneIndustry.site(game.state,index).recipe=="blocks","A physical recipe selection enters manual mode")
 check(game.state.resources==inventory and game.state.stone.delivered==before,"UI preferences never fabricate stock or delivery progress")
 await tap(hud,find_button(hud,"Bedarfsautomatik: AUS"))
 hud.close_menu();scene.focus=Vector3(0,0,20);scene.zoom=200;scene.set_camera()
 await draw()
 var image_path=OS.get_environment("TIMBER_JOURNEY_IMAGE")
 if not image_path.is_empty():check(root.get_texture().get_image().save_png(image_path)==OK,"Endgame evidence screenshot saved")
 scene.queue_free()
 for i in 3:await process_frame
 root.get_node("Music").shutdown();await create_timer(0.15).timeout
 print("VISUAL JOURNEY PROGRESS: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
