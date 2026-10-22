extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func settle() -> void:
 for i in 4: await process_frame
 await RenderingServer.frame_post_draw
func touch(point: Vector2,pressed: bool,canceled: bool=false) -> void:
 var event=InputEventScreenTouch.new()
 event.position=root.get_screen_transform()*point
 event.pressed=pressed
 event.canceled=canceled
 Input.parse_input_event(event)
 await process_frame
func drag(point: Vector2,relative: Vector2) -> void:
 var event=InputEventScreenDrag.new()
 event.position=root.get_screen_transform()*point
 event.relative=root.get_screen_transform().basis_xform(relative)
 Input.parse_input_event(event)
 await process_frame
func tap(button: Button) -> void:
 var point=button.get_global_rect().get_center()
 await touch(point,true)
 await touch(point,false)
 await settle()
func run() -> void:
 await process_frame
 root.size=Vector2i(591,1280)
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.city_services.enabled=false
 game.state.coins=10000
 game.state.company_xp=800
 game.state.resources.wood=50
 game.state.buildings.append({"kind":"furniture","level":1,"paused":false,"position":[-44,-12]})
 game.start_delivery()
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.hide()
 scene.set_process(false)
 await settle()
 var hud=scene.hud
 var ui=hud.ux
 ui.set_process(false)
 var badge=null
 for item in scene.delivery_world.badges:
  if int(item.index)==1: badge=item.button
 check(badge!=null and badge.visible,"Real sawmill badge is available for repeated touch selection")
 var state_before=game.state.duplicate(true)
 for i in 32:
  await tap(badge)
  ui._process(1.1)
  await settle()
  check(ui.sheet.visible and ui.selection.get("index",-1)==1,"Repeated real touch keeps the same building selected: "+str(i))
  check(ui.sheet.get_global_rect().position.y>=218 and ui.sheet.size.y<=360,"Touch plus timed refresh keeps a bounded card: "+str(i))
 check(game.state==state_before,"Repeated selection cannot charge money, alter production or replace a save")
 scene.show()
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber-card-fixed.png")
 scene.hide()
 for item in scene.delivery_world.badges:
  check(not item.button.visible or not item.button.get_global_rect().intersects(ui.sheet.get_global_rect()),"World resource badge cannot cover a card control")

 # Force a genuinely narrow logical HUD, independently of canvas stretch.
 hud.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
 hud.size=Vector2(360,640)
 game.state.ux.large_text=true
 ui.apply_accessibility()
 ui.select_building(1)
 await settle()
 check(ui.sheet.get_global_rect().position.y>=218 and ui.sheet.size.y<=218,"Short portrait viewport reserves the top HUD and bottom navigation")
 check(ui.sheet.get_global_rect().end.x<=346,"Large-text card stays inside a 360-pixel logical width")
 check(ui.sheet_scroll.get_v_scroll_bar().max_value>ui.sheet_scroll.get_v_scroll_bar().page,"Long content overflows into finger scrolling rather than growing the panel")
 var target=null
 for button in ui.sheet_body.find_children("*","Button",true,false):
  if ui.sheet_scroll.get_global_rect().encloses(button.get_global_rect()): target=button; break
 check(target!=null,"A visible card action exists for the touch-hold test")
 if target==null:
  quit(1)
  return
 var at=target.get_global_rect().get_center()
 await touch(at,true)
 ui.refresh()
 check(is_instance_valid(target) and target.is_inside_tree() and not target.is_queued_for_deletion(),"Live updates never remove a control while its touch is held")
 await touch(at,false,true)
 await settle()
 check(not hud.overlay.visible,"Canceled touch never opens a material menu or purchases an upgrade")
 var start=ui.sheet_scroll.get_global_rect().get_center()+Vector2(0,25)
 var focus_before=scene.focus
 await touch(start,true)
 for i in range(1,7): await drag(start-Vector2(0,i*18),Vector2(0,-18))
 await touch(start-Vector2(0,108),false)
 ui.sheet_scroll.velocity=0
 await settle()
 var scrolled=ui.sheet_scroll.scroll_vertical
 check(scrolled>30,"A real upward finger drag scrolls the bounded card")
 check(scene.focus==focus_before,"Scrolling the card never pans the world behind it")
 ui.refresh()
 await settle()
 check(ui.sheet_scroll.scroll_vertical>0,"Periodic refresh preserves the user's reading position")
 check(ui.sheet_close.get_global_rect().position.y>=218 and ui.sheet_close.get_global_rect().end.y<=436,"Close remains visible independently of the scrolled contents")
 await tap(ui.sheet_close)
 check(not ui.sheet.visible and ui.selection.is_empty(),"The fixed close button works after scrolling to lower actions")
 ui.select_building(1)
 await settle()
 check(ui.sheet_scroll.scroll_vertical==0,"Opening a fresh selection returns its contents to the top")
 var material=null
 for button in ui.sheet_body.find_children("*","Button",true,false):
  if button.text=="Bretter": material=button
 await tap(material)
 check(hud.current=="material_help" and hud.overlay.visible,"Short card taps still open the real material help")
 hud.close_menu()
 var job_started=game.order_building("kiln",Vector3(20,0,20))
 check(job_started,"Construction selection uses a genuine paid job")
 ui.select_job(int(game.state.jobs.back().id))
 await settle()
 check(ui.sheet.visible and ui.sheet.size.y<=218,"Construction cards share the same safe height limit")
 game.simulate(30)
 check(not game.state.delivery.shipments.is_empty(),"Transport selection uses a real active shipment")
 ui.select_truck({"kind":"truck","domain":"wood","id":int(game.state.delivery.shipments[0].id)})
 await settle()
 check(ui.sheet.visible and ui.sheet.size.y<=218,"Truck cards share the same safe height limit")
 scene.queue_free()
 await process_frame
 print("VISUAL BUILDING CARD: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
