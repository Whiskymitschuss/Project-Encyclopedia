extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func draw() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func touch(at: Vector2,pressed: bool) -> void:
 var e=InputEventScreenTouch.new()
 e.position=root.get_screen_transform()*at
 e.pressed=pressed
 Input.parse_input_event(e)
 await process_frame
func tap(button: Button) -> void:
 await touch(button.get_global_rect().get_center(),true)
 await touch(button.get_global_rect().get_center(),false)
 await draw()
func find_button(hud: Control,caption: String) -> Button:
 for node in hud.contents.find_children("*","Button",true,false):
  if node.text.begins_with(caption): return node
 return null
func shot(name_value: String) -> void:
 await draw()
 root.get_texture().get_image().save_png("/workspace/timber-journey-"+name_value+".png")
func run() -> void:
 await process_frame
 root.size=Vector2i(540,960)
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.city_services.enabled=false
 for i in 5: game.chop()
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await draw()
 var hud=scene.hud
 await tap(hud.mission_button)
 check(hud.current=="journey" and hud.overlay.visible,"Physical goal-bar tap opens the chapter journey")
 var claim=find_button(hud,"BELOHNUNG ABHOLEN")
 check(claim!=null and not claim.disabled,"Ready chapter reward is actionable")
 await shot("chapters")
 var coins=game.state.coins
 await tap(claim)
 check(game.state.coins==coins+40 and Journey.current(game.state).id=="roots:1","Real touch claims exactly one visible reward and advances the goal")
 hud._process(1.1)
 check(not find_button(hud,"BELOHNUNG ABHOLEN").is_queued_for_deletion(),"Live progress updates preserve current touch controls")
 game.deposit()
 game.claim_journey("roots:1")
 game.sell("wood",0.25)
 game.claim_journey("roots:2")
 hud.open_menu("townhall")
 await draw()
 var preview=null
 for node in hud.contents.find_children("*","SubViewportContainer",true,false): preview=node
 check(preview!=null and preview.viewport.own_world_3d,"Town hall preview is actual isolated 3D")
 check(preview.models.get_child(0).get_meta("town_kind")=="townhall","Town hall has its own geometry")
 await shot("townhall")
 var place=find_button(hud,"RATHAUS PLATZIEREN")
 # ScrollContainer must bring an offscreen action into view before touch.
 hud.scroll.ensure_control_visible(place)
 await draw()
 coins=game.state.coins
 await tap(place)
 check(scene.placement.get("kind","")=="townhall" and hud.placement_panel.visible,"Real finger action starts freely placeable hall preview")
 check(int(scene.placement.get("plot",-1))==Journey.HALL_PLOT,"Touch preview uses the dedicated civic plot")
 check(game.state.coins==coins,"Preview never charges before confirmation")
 check(hud.placement_materials.text.contains("Später per LKW"),"Early hall correctly explains actual later material deliveries")
 await tap(hud.placement_confirm)
 check(game.state.jobs.size()==1 and game.state.jobs[0].kind=="townhall","Confirmation creates an actual town hall construction job")
 check(game.state.coins==coins-200,"Placement charges the displayed hall price once")
 for i in 900:
  game.step(1)
  if Journey.townhall_level(game.state)>0: break
 check(Journey.townhall_level(game.state)==1,"Visual fixture completes through real transport and builders")
 game.claim_journey("roots:hall")
 hud.open_menu("trophies")
 await draw()
 check(hud.contents.find_children("ChapterTrophy","Node3D",true,false).size()==1,"Earned chapter has a real 3D trophy")
 check(hud.edition.text=="WALDFREUND","Earned title is visible on the main interface")
 var readable_pager=false
 for node in hud.contents.find_children("*","Label",true,false):
  if node.text=="1 / 10": readable_pager=node.size.y<50 and node.autowrap_mode==TextServer.AUTOWRAP_OFF
 check(readable_pager,"Trophy page number stays on a single readable line")
 await shot("trophy")
 var before=Journey.resume_capture(game.state)
 game.simulate(90)
 game.return_report=Journey.resume_report(game.state,before,90)
 hud.open_menu("return")
 await draw()
 coins=game.state.coins
 hud.render_menu()
 check(game.state.coins==coins,"Opening the return report never awards money a second time")
 await shot("return")
 hud.open_menu("commissions")
 await draw()
 var choose=find_button(hud,"DIESEN AUFTRAG WÄHLEN")
 await tap(choose)
 check(not game.state.journey.active.is_empty(),"Touch selects a genuine optional commission")
 # Replanting uses the actual starter helper too; completion is an economy
 # condition, not a promise of 80 wood in precisely 130 seconds.
 for second in 300:
  if Journey.order_progress(game.state)>=float(game.state.journey.active.target):break
  game.step(1)
 hud._process(1.1)
 var finish=find_button(hud,"AUFTRAG ABSCHLIESSEN")
 check(not finish.disabled,"A completed commission enables its existing control without reopening the menu")
 await tap(finish)
 check(game.state.journey.completed_orders==1,"Physical touch completes and pays the accepted commission")
 await shot("orders")
 for size_value in [Vector2i(540,960),Vector2i(360,640)]:
  root.size=size_value
  game.state.ux.large_text=true
  game.state.ux.high_contrast=true
  for menu in ["journey","townhall","trophies","commissions","return"]:
   hud.open_menu(menu)
   await draw()
   hud._process(1.1)
   check(hud.overlay.get_global_rect().end.x<=hud.size.x-13 and hud.overlay.get_global_rect().position.x>=13,"Accessible chapter menu fits portrait width: %s %s" % [menu,size_value])
   check(hud.scroll.size.y>40,"Menus retain finger-scroll space on small screens: "+menu)
 hud.close_menu()
 scene.queue_free()
 await process_frame
 print("VISUAL JOURNEY: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
