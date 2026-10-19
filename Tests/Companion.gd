extends SceneTree

var checks=0
var failures=[]
func check(ok: bool, detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 var original=game.state.duplicate(true)
 game.state=game.initial_state()
 game.flow.clear()
 game.offline_report=""
 var legacy=game.snapshot()
 legacy.erase("companion_enabled")
 game.restore(legacy)
 check(game.state.companion_enabled,"Old profiles gain the companion without losing progress")
 game.state.tutorial=5
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 var buddy=scene.hud.companion
 buddy.set_process(false)
 buddy.greeted=false
 var before=game.state.duplicate(true)
 buddy._process(0.1)
 check(buddy.bubble.visible and buddy.message.text.contains("wieder da"),"Returning player gets a warm greeting")
 check(buddy.portrait.actor.wave_left>0,"Greeting triggers a real wave")
 check(game.state==before,"Greeting never changes currencies or grants fake offline rewards")
 buddy.dismiss()
 check(not buddy.bubble.visible,"Greeting can be dismissed immediately")
 buddy._process(1)
 check(not buddy.bubble.visible,"Dismissed greeting does not reopen each frame")
 game.state.jobs.append({"type":"building","kind":"kiln","slot":5,"left":30,"total":30})
 buddy.observe()
 check(buddy.pending.is_empty(),"Starting construction never claims the building is already complete")
 game.state.jobs.clear()
 game.state.buildings.append({"kind":"kiln","level":1,"paused":false})
 buddy.observe()
 check(not buddy.pending.is_empty() and buddy.pending.text.contains("fertig"),"Completed building queues a real celebration")
 buddy.cooldown=0
 buddy._process(0.1)
 check(buddy.bubble.visible and buddy.portrait.actor.cheerful,"Completion celebrates when unobstructed")
 scene.hud.open_menu("industry")
 buddy._process(0.1)
 check(not buddy.avatar.visible and not buddy.bubble.visible and not buddy.portrait.running,"Menus hide the companion and suspend its rendering")
 scene.hud.close_menu()
 buddy.dismiss()
 buddy.pending={}
 scene.hud.placement_panel.show()
 buddy._process(0.1)
 check(not buddy.avatar.visible,"Placement stays unobstructed")
 scene.hud.placement_panel.hide()
 game.state.resources.sawdust=game.capacity()*0.8
 buddy.chat()
 check(buddy.message.text.contains("Späne") and buddy.target_menu=="sawdust","Tapping the beaver gives advice based on real stock")
 game.state.companion_enabled=false
 buddy._process(0.1)
 buddy.on_loot(5)
 check(not buddy.avatar.visible and buddy.pending.is_empty(),"Disabled companion never queues rare-loot interruptions")
 var saved=game.snapshot()
 game.restore(saved)
 check(not game.state.companion_enabled,"Disabled preference survives save and restore")
 game.state.earned=game.prestige_requirement()
 game.state.unlocked=3
 check(game.prestige() and not game.state.companion_enabled,"Prestige preserves the companion preference")
 game.state.companion_enabled=true
 scene.hud.close_menu()
 scene.hud.placement_panel.hide()
 buddy._process(0.1)
 check(buddy.avatar.visible and buddy.bubble.visible,"Re-enabling the companion greets again")
 buddy.dismiss()
 buddy.pending={}
 buddy.cooldown=0
 buddy.idle=101
 buddy._process(0.1)
 check(buddy.seen_hints.size()==1,"Idle advice is delivered once per hint per session")
 buddy.dismiss()
 buddy.cooldown=0
 buddy.idle=101
 buddy._process(0.1)
 check(not buddy.bubble.visible,"Same idle hint does not keep returning")
 buddy.pending={}
 game.state.trees=25
 buddy.observe()
 check(buddy.pending.is_empty(),"Prestige does not announce a tree mission reward too early")
 game.state.trees=50
 buddy.observe()
 check(buddy.pending.get("text","").contains("50 Bäume"),"Tree celebration follows the actual prestige mission target")
 buddy.fresh=false
 buddy.reported_offline=false
 game.offline_report="12 Min. offline · +80 Münzen"
 check(buddy.greeting().contains("+80 Münzen"),"First return greeting uses the actual offline report")
 check(not buddy.greeting().contains("+80 Münzen"),"A previous offline payout is never announced again after resume")
 buddy.greeted=true
 buddy.last_resume=-300001
 buddy._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 check(not buddy.greeted,"A longer background interval schedules another greeting")
 game.offline_report=""
 scene.queue_free()
 game.state=original
 await process_frame
 print("COMPANION: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
