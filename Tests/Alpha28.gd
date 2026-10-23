extends SceneTree
var checks=0
var failures=[]
var game
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func write_raw(path: String,value: String) -> void:
 var file=FileAccess.open(path,FileAccess.WRITE)
 file.store_string(value)
 file.close()
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 var store=root.get_node("Store")
 game.state=game.initial_state()
 var boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 await process_frame
 check(boot.find_children("*","Label",true,false).any(func(label): return label.text.contains(str(ProjectSettings.get_setting("application/config/version")))),"The title displays the actual installed app version")
 var state=game.snapshot()
 game._process(10)
 check(game.state.elapsed==state.elapsed and game.state.resources==state.resources,"Title screen cannot simulate the company before the world opens")
 boot.queue_free()
 await process_frame
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 check(game.live_world,"The real world resumes live simulation after the title")
 game.begin_tutorial()
 check(TutorialRules.phase(game.state)=="chop" and game.state.onboarding.active,"Welcome starts a real saved tutorial")
 for i in 2: game.chop()
 game.pause_tutorial()
 check(TutorialRules.phase(game.state).is_empty() and game.state.tutorial==1,"Later pauses the coach without erasing the current lesson")
 game.restore(JSON.parse_string(JSON.stringify(game.snapshot())))
 game.begin_tutorial()
 check(TutorialRules.phase(game.state)=="chop" and game.state.trees==2,"A paused tutorial can resume after a save and keeps actual progress")
 for i in 3: game.chop()
 check(TutorialRules.phase(game.state)=="deposit" and game.state.bag==20,"Five actual cuts complete the first step")
 game.deposit()
 check(game.state.bag==0 and game.state.resources.wood==20,"Tutorial delivery uses real backpack stock")
 check(TutorialRules.phase(game.state)=="boards","Tutorial waits for actual boards rather than awarding them")
 game.step(2)
 check(TutorialRules.phase(game.state)=="sell" and game.state.resources.boards>=1,"Normal sawmill production advances the guided flow")
 var coins=float(game.state.coins)
 var boards=float(game.state.resources.boards)
 game.sell("boards",0.25)
 check(TutorialRules.phase(game.state)=="build" and game.state.coins==coins+boards*0.25*6,"Only an actual sale opens the build step and pays the correct coins")
 check(scene.hud.mission_button.text.contains("4/5"),"The fourth tutorial step remains visible until a building is placed")
 var point=game.free_position(Catalog.industry_position(5))
 check(game.order_building("cabin",point),"First guided hut is affordable without free resources")
 check(TutorialRules.phase(game.state)=="construction","Paid placement waits for construction completion")
 var paid=float(game.state.coins)
 var saved=JSON.parse_string(JSON.stringify(game.snapshot()))
 game.restore(saved)
 check(TutorialRules.phase(game.state)=="construction" and is_equal_approx(float(game.state.coins),paid),"A partially completed tutorial and its paid building survive reload")
 game.simulate(40)
 check(TutorialRules.phase(game.state)=="done" and game.state.buildings.size()==6,"Only the actual completed building finishes the hands-on lesson")
 game.end_tutorial(true)
 check(TutorialRules.phase(game.state).is_empty() and game.state.onboarding.finished and game.state.tutorial==5,"Finishing hands over to the permanent chapter goals")
 var legacy=game.snapshot()
 legacy.erase("onboarding")
 game.restore(legacy)
 check(not game.state.onboarding.active and game.state.tutorial==5 and game.state.buildings.size()==6,"Existing players are not forced back into onboarding")
 scene.hud.open_menu("alpha")
 check(scene.hud.alpha_desk.report.text.contains("TESTBERICHT"),"Test feedback produces a local editable report")
 scene.hud.alpha_desk.report.text+="\nMein Entwurf bleibt erhalten."
 scene.hud.open_menu("settings")
 check(scene.hud.contents.find_children("*","Label",true,false).any(func(label): return label.text.begins_with("Alpha 1 · "+str(ProjectSettings.get_setting("application/config/version")))),"Settings show the same actual version as the generated feedback report")
 scene.hud.open_menu("alpha")
 check(scene.hud.alpha_desk.report.text.ends_with("Mein Entwurf bleibt erhalten."),"Changing menus preserves an unfinished feedback draft")
 check(scene.hud.contents.find_children("*","Label",true,false).any(func(label): return label.text=="Installiert: "+str(ProjectSettings.get_setting("application/config/version"))),"The current version remains visible independently of an older saved feedback draft")
 var private_state=game.snapshot()
 private_state.unexpected_secret="DO_NOT_INCLUDE"
 private_state.username="DO_NOT_INCLUDE"
 var report=AlphaReport.build(private_state,{"os":"TestOS","model":"Testgerät","unique_id":"DO_NOT_INCLUDE","save_path":"DO_NOT_INCLUDE"},"current")
 check(not report.contains("DO_NOT_INCLUDE") and not report.contains("last_seen") and not report.contains("resources"),"Diagnostic allowlist cannot attach raw save, personal fields or unique identifiers")
 scene.hud.back()
 check(scene.hud.overlay.visible,"Back returns through nested menus before closing the overlay")
 for i in 13:
  if not scene.hud.overlay.visible: break
  scene.hud.back()
 check(not scene.hud.overlay.visible,"Repeated Back closes the complete menu history")
 game.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
 check(scene.hud.current=="game_menu" and scene.hud.overlay.visible,"Android back opens the game menu instead of terminating")
 scene.hud.close_menu()
 scene.begin_placement({"kind":"station","city":false,"index":-1})
 game.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
 check(scene.placement.is_empty(),"Android back cancels an unconfirmed placement without payment")
 check(TownRules.path(Vector2i.ZERO,Vector2i(3,0)).is_empty(),"Off-grid road endpoints cannot enter an infinite construction loop")
 check(TownRules.path(Vector2i.ZERO,Vector2i(100000,0)).is_empty(),"Absurd road lengths are rejected before large allocations")
 scene.queue_free()
 await process_frame
 game.state=game.initial_state()
 check(game.save(true),"A healthy alpha save writes normally")
 game.state.coins=12345
 check(game.save(true),"Healthy save rotates the previous state")
 var healthy=FileAccess.get_file_as_string(store.PATH)
 write_raw(store.PATH,'{"schema":1,"resources":null,"buildings":"bad"}')
 var restored=store.load_game()
 check(not restored.is_empty() and store.load_status=="backup" and not store.recovery_required,"Syntactically valid but structurally broken data restores a healthy backup")
 check(not store.valid_shape({"schema":1,"coins":-1}),"Negative economy values cannot silently become a save")
 check(not store.valid_shape({"schema":1,"buildings":[{"kind":"unknown","level":1}]}),"An unknown producer cannot crash the catalogue after load")
 write_raw(store.PATH,"interrupted")
 write_raw(store.PATH+".bak","also interrupted")
 var original=FileAccess.get_sha256(store.PATH)
 check(store.load_game().is_empty() and store.recovery_required,"Two unreadable files enter explicit recovery mode")
 check(not game.save(true) and FileAccess.get_sha256(store.PATH)==original,"Autosave cannot overwrite unreadable player data with a fresh company")
 check(store.archive_unreadable() and not store.recovery_required,"Explicit recovery preserves original bytes before allowing a new company")
 var directory=DirAccess.open("user://recovery")
 var found=false
 for file in directory.get_files():
  if FileAccess.get_sha256("user://recovery/"+file)==original: found=true
 check(found,"Recovery archive contains an exact copy of the original damaged file")
 write_raw(store.PATH,healthy)
 store.load_game()
 game.restore(store.load_game())
 var old=game.snapshot()
 old.onboarding=TutorialRules.initial()
 old.onboarding.active=true
 old.onboarding.job=123
 old.tutorial=5
 game.restore(old)
 check(TutorialRules.phase(game.state)=="build","A canceled or missing tutorial job cannot claim a fabricated construction success")
 print("ALPHA 1: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
