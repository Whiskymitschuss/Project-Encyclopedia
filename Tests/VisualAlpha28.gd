extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func settle() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func tap(button: Button) -> void:
 var at=root.get_screen_transform()*button.get_global_rect().get_center()
 for pressed in [true,false]:
  var event=InputEventScreenTouch.new()
  event.position=at
  event.pressed=pressed
  Input.parse_input_event(event)
  await process_frame
 await settle()
func find_button(node: Node,title: String) -> Button:
 for button in node.find_children("*","Button",true,false):
  if button.text.begins_with(title): return button
 return null
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 var orphan_baseline=int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
 game.state=game.initial_state()
 game.state.city_services.enabled=false
 root.content_scale_size=Vector2i(540,960)
 root.size=Vector2i(540,960)
 var boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 current_scene=boot
 boot.set_process(false)
 boot._process(3.3)
 await settle()
 check(boot.find_children("*","Label",true,false).any(func(label): return label.text.contains(str(ProjectSettings.get_setting("application/config/version")))),"Rendered title version matches the real installed project version")
 check(boot.diorama.viewport.own_world_3d and boot.diorama.town.visible and boot.diorama.workshop.visible,"The alpha intro presents actual isolated workshop and city geometry")
 check(absf(float(boot.diorama.viewport.size.x)/boot.diorama.viewport.size.y-boot.diorama.size.x/boot.diorama.size.y)<0.02,"Intro viewport renders at its real aspect ratio")
 root.get_texture().get_image().save_png("/workspace/timber-alpha28-intro.png")
 await tap(boot.play)
 for i in 10: await process_frame
 var scene=current_scene
 check(scene!=null and scene.scene_file_path=="res://Scenes/Main.tscn","Alpha title Play opens the actual playable world by touch")
 if scene==null or scene.get("hud")==null: quit(1); return
 scene.set_process(false)
 var hud=scene.hud
 var start=find_button(hud.contents,"LOS GEHT’S")
 check(start!=null and start.get_global_rect().end.y<hud.scroll.get_global_rect().end.y,"The first tutorial action is visible without scrolling")
 await tap(start)
 check(game.state.onboarding.active and hud.coach.panel.visible,"Real welcome touch opens the contextual tutorial")
 check(not hud.companion.avatar.visible,"The regular companion bubble leaves room for the introductory coach")
 check(hud.coach.marker.get_global_rect().intersects(hud.chop_button.get_global_rect()),"The tutorial highlights the actual chop action")
 check(hud.coach.panel.get_global_rect().end.y<hud.bottom_panel.get_global_rect().position.y,"Tutorial cannot grow across action buttons or intercept the first chop")
 root.get_texture().get_image().save_png("/workspace/timber-alpha28-tutorial.png")
 for i in 5: await tap(hud.chop_button)
 check(TutorialRules.phase(game.state)=="deposit" and game.state.bag==20,"Five physical chop touches collect the real tutorial cargo")
 await tap(hud.deposit_button)
 check(TutorialRules.phase(game.state)=="boards" and game.state.bag==0,"Physical deposit touch advances after a real unloading")
 game.step(2)
 game.changed.emit()
 await settle()
 check(TutorialRules.phase(game.state)=="sell","Automatic production makes actual boards available")
 await tap(hud.coach.action)
 check(hud.current=="market" and hud.overlay.visible,"Guided selling opens the actual market")
 var boards=null
 for label in hud.contents.find_children("*","Label",true,false):
  if label.text=="Bretter": boards=label.get_parent(); break
 check(boards!=null,"The first boards are discoverable among owned stock")
 if boards==null: quit(1); return
 var sale=find_button(boards,"25 %")
 hud.scroll.ensure_control_visible(sale)
 await settle()
 var coins=float(game.state.coins)
 await tap(sale)
 check(TutorialRules.phase(game.state)=="build" and game.state.coins>coins,"A physical sale pays real coins and opens the building lesson")
 await settle()
 if hud.overlay.visible: hud.close_menu(); await settle()
 await tap(hud.coach.action)
 check(not scene.placement.is_empty() and scene.placement.kind=="cabin","Tutorial action starts a paid hut placement rather than gifting a building")
 check(not hud.placement_confirm.disabled,"The proposed first hut site is genuinely legal")
 var count=game.state.buildings.size()
 coins=float(game.state.coins)
 await tap(hud.placement_confirm)
 check(game.state.jobs.size()==1 and game.state.coins<coins and game.state.buildings.size()==count,"Physical confirmation creates one paid construction job")
 check(TutorialRules.phase(game.state)=="construction" and not hud.coach.marker.visible,"The coach follows actual construction and removes obsolete highlights")
 game.simulate(40)
 game.changed.emit()
 await settle()
 check(TutorialRules.phase(game.state)=="done" and game.state.buildings.size()==count+1,"Real construction completion unlocks the tutorial ending")
 root.get_texture().get_image().save_png("/workspace/timber-alpha28-success.png")
 await tap(hud.coach.action)
 check(not game.state.onboarding.active and hud.current=="journey","The last tutorial action hands control to the chapter goals")
 hud.open_menu("settings")
 await settle()
 check(hud.contents.find_children("*","Label",true,false).any(func(label): return label.text.begins_with("Alpha 1 · "+str(ProjectSettings.get_setting("application/config/version")))),"Rendered settings do not show a hardcoded historical app version")
 hud.open_menu("alpha")
 await settle()
 check(hud.alpha_desk.report.editable,"Tester report accepts an observation directly in the app")
 check(hud.contents.find_children("*","Label",true,false).any(func(label): return label.text=="Installiert: "+str(ProjectSettings.get_setting("application/config/version"))),"Feedback shows the current installed version outside the editable historic report")
 hud.scroll.ensure_control_visible(hud.alpha_desk.report)
 await settle()
 var edit=hud.alpha_desk.report
 var at=root.get_screen_transform()*(edit.get_global_rect().position+Vector2(40,30))
 for pressed in [true,false]:
  var event=InputEventScreenTouch.new()
  event.position=at
  event.pressed=pressed
  Input.parse_input_event(event)
  await process_frame
 check(hud.scroll.pointer==-99,"Parent scrolling passes report touches through to text editing")
 check(edit.has_focus(),"A physical report touch focuses the real text editor")
 var key=InputEventKey.new()
 key.unicode=937
 key.pressed=true
 Input.parse_input_event(key)
 await process_frame
 check(edit.text.contains(String.chr(937)),"The focused tester report accepts actual Unicode keyboard input")
 hud.alpha_desk.report.text+="\nTouch-Test erfolgreich."
 hud.alpha_desk.capture_draft()
 var copy=find_button(hud.contents,"Text kopieren")
 hud.scroll.ensure_control_visible(copy)
 await settle()
 await tap(copy)
 await tap(find_button(hud.contents,"Sichern"))
 check(FileAccess.get_file_as_string("user://Alpha-Testbericht.txt")==hud.alpha_desk.report.text,"The actual save action keeps the complete edited report locally")
 if DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD): check(DisplayServer.clipboard_get().ends_with("Touch-Test erfolgreich."),"The actual copy action transfers only the tester's prepared report")
 hud.close_menu()
 game.back_requested.emit()
 await settle()
 check(hud.current=="game_menu","Android-style back opens navigation rather than terminating the alpha")
 await tap(find_button(hud.contents,"SPEICHERN & ZUM START"))
 for i in 10: await process_frame
 check(current_scene.scene_file_path=="res://Scenes/Boot.tscn" and not game.live_world,"Returning to the title saves and stops foreground economic simulation")
 boot=current_scene
 check(boot.ready_to_play and boot.play.text.begins_with("WEITERSPIELEN"),"A returning tester can continue immediately without a forced repeat")
 for dimensions in [Vector2i(360,640),Vector2i(540,960),Vector2i(1100,700)]:
  root.content_scale_size=dimensions
  root.size=dimensions
  await settle()
  check(boot.column.get_global_rect().end.y<=dimensions.y-20,"Alpha title fits an actual logical viewport of "+str(dimensions))
  check(boot.play.get_global_rect().end.x<=dimensions.x,"Alpha Play remains inside the screen at "+str(dimensions))
 await tap(boot.play)
 for i in 10: await process_frame
 scene=current_scene
 scene.set_process(false)
 hud=scene.hud
 for dimensions in [Vector2i(360,640),Vector2i(540,960),Vector2i(1100,700)]:
  root.content_scale_size=dimensions
  root.size=dimensions
  for large in [false,true]:
   game.state.ux.large_text=large
   hud.open_menu("alpha")
   await settle()
   check(hud.overlay.get_global_rect().end.x<=hud.size.x+1 and hud.overlay.get_global_rect().end.y<=hud.size.y+1,"Tester interface stays inside %s, large text %s" % [dimensions,large])
   check(hud.alpha_desk.report.size.y<=hud.scroll.size.y,"Report editor leaves room for page gestures on small phones")
   check(hud.scroll.size.y>=140,"The small-screen report keeps a usable vertical reading area")
   check(hud.alpha_desk.report.size.x<=hud.contents.size.x,"Editable report never forces horizontal page overflow")
   if dimensions==Vector2i(360,640) and large: root.get_texture().get_image().save_png("/workspace/timber-alpha28-report.png")
 scene.queue_free()
 for i in 6: await process_frame
 check(int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))<=orphan_baseline,"Repeated world/title transitions release their nodes without accumulating orphans")
 print("VISUAL ALPHA 1: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
