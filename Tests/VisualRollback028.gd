extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func settle() -> void:
 for i in 6: await process_frame
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
  if button.text==title: return button
 return null
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.city_services.enabled=false
 game.state.company_xp=800
 game.state.buildings.append({"kind":"furniture","level":1,"paused":false})
 game.state.homes=[{"kind":"house","level":3,"plot":0,"rent_bank":55,"position":[-40,116]}]
 game.state.resources.wood=12
 game.state.resources.boards=7
 game.state.resources.walls=3
 check(game.start_delivery(),"Real production line is active in the material HUD test")
 game.state.delivery.buffers.station.wood=4
 game.state.delivery.buffers.sawmill.boards=2
 game.state.delivery.recovered={"sawmill":{"boards":3}}
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.set_process(false)
 await settle()
 var hud=scene.hud
 hud.ux.set_process(false)
 var stock_before=game.state.duplicate(true)
 hud.update_stats()
 check(hud.material_bar.counters.wood.text=="16" and hud.material_bar.counters.boards.text=="12","Main HUD includes warehouse, local buffers and recovered cargo exactly once")
 check(hud.supply.text.begins_with("Laden") and hud.material_bar.is_visible_in_tree(),"Order status and actual material counts remain visible together")
 check(game.state==stock_before,"Rendering stocks never changes resources or awards money")
 # Check real logical widths, including large text, rather than scaling a
 # fixed 540-pixel layout and calling that a small-screen test.
 for resolution in [Vector2i(360,640),Vector2i(540,960),Vector2i(591,1280),Vector2i(1280,800)]:
  root.content_scale_size=resolution
  root.size=resolution
  for large in [false,true]:
   game.state.ux.large_text=large
   hud.ux.apply_accessibility()
   await settle()
   check(hud.bottom_panel.get_global_rect().end.y<=hud.size.y+1,"Material HUD stays on screen "+str(resolution)+str(large))
   check(hud.bottom_panel.size.x<=760,"Material HUD preserves readable tablet width")
   for control in hud.material_bar.controls.values():
    check(hud.bottom_panel.get_global_rect().encloses(control.get_global_rect()),"Material control fits its panel "+str(resolution))
    check(control.size.y>=44 and control.size.x>=44,"Material tap targets remain usable "+str(resolution))
   var transform=root.get_screen_transform()
   check(absf(transform.x.length()-transform.y.length())<0.001,"Screen aspect stays uniform")
   if resolution==Vector2i(360,640) and large: root.get_texture().get_image().save_png("/workspace/timber028-materials-small.png")
   if resolution==Vector2i(360,640):
    hud.ux.select_building(0,true)
    await settle()
    var small_move=find_button(hud.ux.sheet_body,"Verschieben")
    hud.ux.sheet_scroll.ensure_control_visible(small_move)
    await settle()
    check(hud.compact_materials and not hud.material_bar.visible,"Short screen reserves room for building details")
    check(hud.ux.sheet_scroll.get_global_rect().encloses(small_move.get_global_rect()),"House relocation is reachable at 360×640, including large text")
    await tap(small_move)
    check(scene.placement.get("city",false),"Physical relocation touch also works on a short phone")
    check(hud.placement_panel.get_global_rect().position.y>=hud.mission_button.get_global_rect().end.y,"Short-screen preview stays below the goal")
    scene.cancel_placement()
    await settle()
    check(hud.material_bar.is_visible_in_tree(),"Returning to main play restores all material counters")
  if resolution==Vector2i(591,1280): root.get_texture().get_image().save_png("/workspace/timber028-materials-main.png")
 root.content_scale_size=Vector2i(540,960)
 root.size=Vector2i(540,960)
 game.state.ux.large_text=false
 hud.ux.apply_accessibility()
 await settle()
 await tap(hud.material_bar.controls.boards)
 check(hud.current=="material_help" and hud.overlay.visible,"Physical stock tap opens sources and deliveries")
 hud.close_menu()
 await tap(find_button(hud,"WAREN"))
 var material_labels=hud.contents.find_children("*","Label",true,false)
 check(hud.current=="stock" and Catalog.RESOURCES.values().all(func(name): return material_labels.any(func(label): return label.text==name)),"Every material, including stone and hardware, is accessible without selling anything")
 hud.close_menu()
 hud.ux.select_building(0,true)
 await settle()
 var move=find_button(hud.ux.sheet_body,"Verschieben")
 check(move!=null,"Completed homes expose a direct move action")
 hud.ux.sheet_scroll.ensure_control_visible(move)
 await settle()
 await tap(move)
 check(scene.placement.get("city",false) and int(scene.placement.get("index",-1))==0,"Physical house move tap opens the actual existing-home preview")
 scene.placement_point=Vector3(-40,0,148)
 scene.update_ghost()
 await settle()
 check(not hud.placement_confirm.disabled,"A legal new home location can be confirmed")
 check(hud.placement_panel.get_global_rect().end.y<hud.bottom_panel.get_global_rect().position.y,"Move confirmation stays above material HUD")
 var coins=game.state.coins
 await tap(hud.placement_confirm)
 check(scene.placement.is_empty() and game.home_position(0)==Vector3(-40,0,148),"Physical confirmation really relocates the house")
 check(game.state.coins==coins and game.state.homes[0].level==3 and game.state.homes[0].rent_bank==55,"Touch relocation preserves upgrades, rent and money")
 check(Engine.max_fps==60,"Desktop presentation has a bounded frame rate")
 game.state.quality=0
 game.apply_device_profile()
 check(Engine.max_fps==30,"Battery mode applies the lower frame budget immediately")
 game.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 check(paused and not RenderingServer.is_render_loop_enabled(),"Minimizing disables actual rendering")
 game.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 check(not paused and RenderingServer.is_render_loop_enabled() and Engine.max_fps==30,"Returning restores the correct rendering budget")
 scene.queue_free()
 await process_frame
 print("VISUAL ROLLBACK 028: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
