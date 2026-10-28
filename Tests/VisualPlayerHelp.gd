extends SceneTree
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func buttons(hud):return hud.contents.find_children("*","Button",true,false)
func press(hud,title: String):
 var found=buttons(hud).filter(func(b):return b.text==title)
 check(found.size()==1,"Unique reachable help action: "+title)
 if not found.is_empty():found[0].pressed.emit()
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 var stats=root.get_node("RuntimeStats");stats.set_process(false)
 root.get_node("Music").shutdown()
 game.restore(game.initial_state());game.state.tutorial=5;game.state.onboarding.active=false;game.state.construction_intro=true;game.state.companion_enabled=false
 root.size=Vector2i(360,800);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.life.set_process(false)
 var hud=scene.hud
 for i in 5:await process_frame
 var before=game.state.duplicate(true)
 hud.open_menu("settings")
 press(hud,"HILFE · PRODUKTION & TRANSPORTE")
 check(hud.current=="guide_help" and hud.modal_title.text=="HILFE & WARENFLUSS","Settings opens actual new help page")
 press(hud,"WERKE & NACHSCHUB PRÜFEN")
 check(hud.current=="logistics" and hud.logistics_tab=="factories","Factory help opens actual logistics factory tab")
 hud.open_menu("guide_help");press(hud,"BAUSTELLEN PRÜFEN")
 check(hud.current=="logistics" and hud.logistics_tab=="sites","Construction help opens real site tab")
 hud.open_menu("guide_help");press(hud,"FAHRTEN ANSEHEN")
 check(hud.current=="logistics" and hud.logistics_tab=="trips","Truck help opens actual trip tab")
 hud.open_menu("privacy")
 var labels=hud.contents.find_children("*","Label",true,false)
 check(labels.any(func(l):return l.text.contains("Deinstallation")),"Help explains local save loss before uninstall")
 check(labels.any(func(l):return l.text.contains("Zwischenablage")),"Report copy/sharing is explained")
 press(hud,"ZUR SPIELHILFE")
 game.state.ux.large_text=true;game.state.ux.high_contrast=true
 hud.render_menu()
 for i in 5:await process_frame
 for b in buttons(hud):check(b.custom_minimum_size.y>=44 and b.get_global_rect().end.x<=hud.scroll.get_global_rect().end.x+2,"Help button fits narrow phone with accessibility settings: "+b.text)
 hud.open_menu("alpha")
 var editor=hud.alpha_desk.report
 editor.text="Meine eigenen Angaben bleiben erhalten."
 stats.long_stalls=[{"ms":6000.0,"area":"Kontrollierter Testbereich","script_ms":5900.0}]
 press(hud,"AKTUELLE MESSWERTE ANHÄNGEN")
 check(editor.text.begins_with("Meine eigenen Angaben bleiben erhalten.") and editor.text.contains("Kontrollierter Testbereich"),"Fresh stall evidence is appended without erasing the player's draft")
 check(editor.text.contains("Speichern:") and editor.text.contains("Weltaufbau:"),"Current report includes save and startup evidence")
 check(not FileAccess.file_exists("user://Alpha-Testbericht.txt"),"Viewing help and appending measurements does not silently save a report")
 game.state.ux.large_text=false;game.state.ux.high_contrast=false
 # UX preferences changed explicitly above; gameplay data must remain identical.
 var after=game.state
 check(after==before,"Help/report navigation leaves production, currency and save-state contents unchanged")
 hud.open_menu("more")
 var search=hud.contents.find_children("*","LineEdit",true,false)[0]
 search.text="Datenschutz"
 search.text_changed.emit(search.text)
 for i in 3:await process_frame
 var visible=buttons(hud).filter(func(b):return b.text.contains("Datenschutz") and b.is_visible_in_tree())
 check(visible.size()==1,"Menu search exposes privacy help")
 if not visible.is_empty():visible[0].pressed.emit()
 check(hud.current=="privacy","Menu directory reaches privacy page")
 scene.queue_free()
 for i in 3:await process_frame
 root.get_node("Music").shutdown()
 await create_timer(0.15).timeout
 print("VISUAL PLAYER HELP: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
