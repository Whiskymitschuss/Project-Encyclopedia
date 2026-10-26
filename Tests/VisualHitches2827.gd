extends SceneTree
var checks=0
var failures=[]
var notices=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 var stats=root.get_node("RuntimeStats");stats.set_process(false);stats.passive_enabled=true
 var store=root.get_node("Store")
 game.restore(JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/forestry288-company.json")))
 var s=game.state
 s.tutorial=5;s.onboarding.active=false;s.construction_intro=true;s.companion_enabled=false;s.city_services.enabled=false;s.ux.adaptive_detail=false
 root.size=Vector2i(591,1280);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.life.set_process(false)
 scene.focus=Vector3(0,0,20);scene.zoom=110;scene.set_camera();scene.chunks.update_view(true)
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 var slow=GDScript.new()
 slow.source_code='extends "res://SaveSystem/SaveFiles.gd"\nfunc save_game(data: Dictionary) -> bool:\n OS.delay_msec(1000)\n return super.save_game(data)\n'
 check(slow.reload()==OK,"The controlled slow writer compiles in the graphical runtime")
 var real_writer=store.writer_script;store.writer_script=slow
 game.notice.connect(func(message):notices.append(message))
 var before=s.duplicate(true);var began=Time.get_ticks_usec()
 check(game.queue_save(true),"The real Game save action starts a background transaction")
 var enqueue_ms=(Time.get_ticks_usec()-began)/1000.0
 check(enqueue_ms<100,"A real company snapshot queues without waiting for the injected one-second disk delay")
 check(not notices.has("Spielstand gespeichert") and store.is_saving(),"The UI cannot report success before the actual file commit")
 var frames=0;var positions=[];var deadline=Time.get_ticks_msec()+10000
 while store.is_saving() and Time.get_ticks_msec()<deadline:
  scene.focus.x+=0.2;scene.set_camera()
  await process_frame
  await RenderingServer.frame_post_draw
  frames+=1;positions.append(scene.camera.global_position)
 check(not store.is_saving() and frames>=3,"The actual main world keeps drawing and moving the camera during slow disk work")
 check(positions.size()>1 and positions[0]!=positions[-1],"Camera transforms really change while the writer is active")
 check(notices.has("Spielstand gespeichert") and game.last_save_ok,"The main-thread completion reports eventual durable success")
 check(store.load_game().resources==before.resources,"The complete factory and warehouse inventories survive the background transaction")
 check(s==before,"Queuing and rendering during a save do not mutate the live company or last_seen")
 scene.hud.open_menu("settings")
 var buttons=scene.hud.contents.find_children("*","Button",true,false)
 var save_buttons=buttons.filter(func(b):return b.text=="JETZT SPEICHERN")
 check(save_buttons.size()==1,"Settings retains its existing manual save action")
 if not save_buttons.is_empty():save_buttons[0].pressed.emit()
 check(store.is_saving(),"The actual settings button uses the background queue")
 var manual=Time.get_ticks_msec()+10000
 while store.is_saving() and Time.get_ticks_msec()<manual:await process_frame
 check(not store.is_saving() and store.last_completed.ok,"The settings request reaches a verified durable file")
 # A routine autosave uses the same queue, not the durable main-thread API.
 store.writer_script=real_writer
 game.live_world=true;game.save_clock=20.0
 game._process_measured(0)
 check(store.is_saving() and game.save_clock==0,"The twenty-second autosave starts the queue in graphical gameplay")
 check(store.flush_queued(),"The final autosave drains before leaving the test")
 check(stats.passive_work.has("Speicherauftrag"),"Main-thread snapshot/enqueue time remains measurable separately from background IO")
 print("VISUAL SAVE BENCH: real company enqueue %.3f ms, %s rendered camera frames during one-second injected IO" % [enqueue_ms,frames])
 scene.queue_free()
 for i in 3:await process_frame
 stats.passive_enabled=false
 print("VISUAL HITCHES 2827: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
