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
func shot(name_value: String) -> void:
 await draw()
 root.get_texture().get_image().save_png("/workspace/timber-cityux-"+name_value+".png")
func touch(at: Vector2,pressed: bool,index: int=0) -> void:
 var e=InputEventScreenTouch.new()
 e.index=index
 e.position=root.get_screen_transform()*at
 e.pressed=pressed
 Input.parse_input_event(e)
 await process_frame
func drag(at: Vector2,relative: Vector2,index: int=0) -> void:
 var e=InputEventScreenDrag.new()
 e.index=index
 e.position=root.get_screen_transform()*at
 e.relative=root.get_screen_transform().basis_xform(relative)
 Input.parse_input_event(e)
 await process_frame
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
 game.state.coins=200000
 game.state.company_xp=800
 game.state.region=2
 game.state.workers=8
 game.state.vehicle=6
 game.state.trucks=3
 game.state.time=11
 game.state.weather=0
 for kind in ["furniture","prefab","garage"]:
  var p=game.free_position(Catalog.industry_position(game.state.buildings.size()))
  game.state.buildings.append({"kind":kind,"level":2,"paused":false,"position":[p.x,p.z]})
 var kinds=["apartments","apartments","hotel","fire","clinic","villa","school","police"]
 for i in kinds.size():
  var p=Vector3([-44,-20,20,44][i%4],0,84 if i<4 else 116)
  check(game.placement_reason(p).is_empty(),"Visual city uses a real legal parcel")
  game.state.homes.append({"kind":kinds[i],"level":1 if i==0 else 10,"plot":i,"position":[p.x,p.z],"rent_bank":120.0})
 game.state.resources.wood=100
 game.start_delivery()
 game.simulate(28)
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.focus=Vector3(0,0,85)
 scene.zoom=155
 scene.set_camera()
 await draw()
 var hud=scene.hud
 var ui=hud.ux
 check(scene.world_buildings.get_child_count()>=16,"Evolved city and industry are both present in the rendered world")
 await shot("skyline")
 scene.focus_at(game.home_position(1))
 await draw()
 var upper=scene.camera.unproject_position(game.home_position(1)+Vector3(0,18,3))
 scene.tap_world(upper)
 check(hud.ux.selection.get("kind","")=="home" and int(hud.ux.selection.index)==1,"Upper high-rise floors are selectable through actual camera ray picking")
 ui.select_building(1,true,true)
 await draw()
 check(ui.sheet.visible and not hud.overlay.visible,"A rendered high-rise opens its contextual card without a full-screen menu")
 check(ui.sheet.get_global_rect().end.y<=hud.size.y-190,"Context card remains clear of the fixed bottom navigation")
 check(ui.sheet.get_global_rect().size.x<=hud.size.x-28,"Context card fits the phone width")
 check(not hud.companion.avatar.visible,"Benno stays clear of the selected building card")
 await shot("building")
 var handle=ui.sheet.global_position+Vector2(ui.sheet.size.x/2,10)
 await touch(handle,true)
 await drag(handle-Vector2(0,60),Vector2(0,-60))
 await touch(handle-Vector2(0,60),false)
 await draw()
 check(hud.overlay.visible and hud.current=="plot","A real upward touch on the sheet handle opens building details")
 ui.show_evolution("apartments",10)
 await draw()
 check(hud.current=="evolution","The architecture preview is accessible")
 var preview=null
 for node in hud.contents.find_children("*","SubViewportContainer",true,false): preview=node
 check(preview!=null and preview.viewport.own_world_3d,"Architecture preview renders an actual isolated 3D model")
 check(preview.models.get_child(0).get_meta("evolution_level")==10,"The preview contains actual level-ten architecture")
 await shot("evolution")
 ui.open_palette()
 await draw()
 check(ui.palette.visible and not hud.overlay.visible,"Building palette leaves the upper world visible")
 var rect=ui.carousel.get_global_rect()
 var start=Vector2(rect.end.x-32,rect.get_center().y)
 var coins=game.state.coins
 await touch(start,true)
 for i in range(1,7): await drag(start-Vector2(i*28,0),Vector2(-28,0))
 await touch(start-Vector2(168,0),false)
 await draw()
 check(ui.carousel.scroll_horizontal>70,"Physical horizontal finger gestures scroll actual building cards")
 check(game.state.coins==coins and scene.placement.is_empty(),"Swiping the palette cannot spend coins or place a building")
 await shot("palette")
 ui.palette_category="Stadt"
 ui.open_palette()
 await draw()
 var tile=null
 for child in ui.carousel.get_children():
  if child is HBoxContainer: tile=child.get_child(0)
 var at=tile.get_global_rect().get_center()
 await touch(at,true)
 await touch(at,false)
 await draw()
 check(not scene.placement.is_empty() and scene.placement.get("city",false),"A short tap on a city card begins the real 3D placement preview")
 check(game.state.coins==coins and hud.placement_confirm.visible,"Preview waits for an explicit confirmation before paying")
 scene.placement_action("rotate")
 var angle=scene.placement_rotation
 scene.placement_action("undo")
 check(angle!=scene.placement_rotation,"Preview undo restores the previous real orientation")
 scene.cancel_placement()
 scene.focus=Vector3(92,0,204)
 scene.zoom=110
 scene.set_camera()
 scene.begin_placement({"kind":"asphalt","network":true})
 await draw()
 var a=scene.camera.unproject_position(Vector3(80,0,176))
 var b=scene.camera.unproject_position(Vector3(104,0,176))
 check(a.y>220 and b.y<hud.placement_panel.global_position.y,"Road gesture is exercised in the actual unobstructed world area")
 await touch(a,true)
 for i in range(1,7): await drag(a.lerp(b,i/6.0),(b-a)/6)
 await touch(b,false)
 await draw()
 check(scene.road_anchor==Vector2i(80,176) and scene.road_endpoint==Vector2i(104,176),"A single physical draw gesture sets both road endpoints")
 check(not hud.placement_confirm.disabled,"A valid connected road can be confirmed after drawing")
 var confirm=hud.placement_confirm.get_global_rect().get_center()
 await touch(confirm,true)
 await touch(confirm,false)
 await draw()
 check(game.state.town.roads.size()==1 and game.state.coins<coins,"Touch confirmation constructs and pays for the actual road")
 check(game.undo_road() and game.state.coins==coins,"Road undo returns exactly the paid cost when the road is unused")
 hud.open_menu("overview")
 await draw()
 var map=null
 for child in hud.contents.get_children():
  if child.has_method("map_point"): map=child
 check(map!=null and map.markers.size()>10,"Overview shows actual buildings, free plots, construction and locked districts")
 await shot("map")
 var point=map.global_position+map.map_point(game.home_position(1))
 await touch(point,true)
 await touch(point,false)
 await draw()
 check(ui.sheet.visible and ui.selection.get("kind","")=="home" and int(ui.selection.index)==1,"Map markers remain tappable through the scrollable menu and focus the real home")
 game.create_group(Vector3(-60,0,70),Vector3(64,0,132),"Innenstadt")
 hud.open_menu("districts")
 await draw()
 check(hud.current=="districts" and hud.scroll.get_v_scroll_bar().max_value>hud.scroll.size.y,"Named district management and real upgrade plans remain scrollable")
 await shot("districts")
 var name_input=null
 for field in hud.contents.find_children("*","LineEdit",true,false):
  name_input=field
  break
 var input_point=name_input.get_global_rect().get_center()
 await touch(input_point,true)
 await touch(input_point,false)
 check(name_input.has_focus(),"A district name field receives real touch focus through the scroll menu")
 var key=InputEventKey.new()
 key.pressed=true
 key.keycode=KEY_Z
 key.unicode=90
 Input.parse_input_event(key)
 await process_frame
 check("Z" in name_input.text,"Actual keyboard input edits the touched district name")
 var save_button=null
 for button in hud.contents.find_children("*","Button",true,false):
  if button.text=="NAMEN SPEICHERN": save_button=button; break
 var save_point=save_button.get_global_rect().get_center()
 await touch(save_point,true)
 await touch(save_point,false)
 check("Z" in game.state.ux.groups[0].name,"Saving the touched name changes the real persistent district record")
 hud.close_menu()
 ui.hide_panels(true)
 scene.focus=Vector3(-20,0,112)
 scene.zoom=150
 scene.set_camera()
 scene.begin_placement({"kind":"group","network":true})
 await draw()
 var ga=scene.camera.unproject_position(Vector3(-50,0,72))
 var gb=scene.camera.unproject_position(Vector3(0,0,96))
 await touch(ga,true)
 for i in range(1,7): await drag(ga.lerp(gb,i/6.0),(gb-ga)/6)
 await touch(gb,false)
 await draw()
 check(not hud.placement_confirm.disabled,"A real finger rectangle can select an occupied city district")
 var group_count=game.state.ux.groups.size()
 confirm=hud.placement_confirm.get_global_rect().get_center()
 await touch(confirm,true)
 await touch(confirm,false)
 await draw()
 check(game.state.ux.groups.size()==group_count+1,"Confirming the drawn region creates an actual new saved district")
 hud.close_menu()
 ui.hide_panels(true)
 var trip=game.state.delivery.shipments[0]
 var vehicle=scene.delivery_world.visuals[scene.delivery_world.visual_key(trip)]
 scene.focus_at(vehicle.global_position)
 await draw()
 var truck_point=scene.camera.unproject_position(vehicle.global_position+Vector3(0,2,0))
 await touch(truck_point,true)
 await touch(truck_point,false)
 await draw()
 check(ui.selection.get("kind","")=="truck" and ui.sheet.visible,"A real touch on a street truck selects its actual saved cargo job")
 check(scene.selection_world.route_root.get_child_count()>0,"The selected truck highlights its actual saved road path")
 ui.open_material("boards")
 await draw()
 check(hud.current=="material_help" and hud.modal_title.text.contains("BRETTER"),"Material help renders actual sawmill and warehouse sources")
 await shot("materials")
 var source_button=null
 for button in hud.contents.find_children("*","Button",true,false):
  if "verfügbar" in button.text: source_button=button; break
 var source_point=source_button.get_global_rect().get_center()
 await touch(source_point,true)
 await touch(source_point,false)
 await draw()
 check(ui.selection.get("kind","")=="building" and ui.sheet.visible,"A material source button focuses and selects the actual producer through the touch path")
 for size_value in [Vector2i(540,960),Vector2i(360,640)]:
  root.size=size_value
  game.state.ux.large_text=true
  game.state.ux.high_contrast=true
  hud.open_menu("events")
  ui.apply_accessibility()
  await draw()
  check(hud.overlay.get_global_rect().end.x<=hud.size.x-14,"Large-text events fit the portrait viewport "+str(size_value))
  ui.select_building(1,true)
  await draw()
  if ui.sheet.get_global_rect().end.x>hud.size.x-14 or ui.sheet.get_global_rect().end.y>hud.size.y-190: printerr("CARD BOUNDS ",ui.sheet.get_global_rect()," HUD ",hud.size)
  check(ui.sheet.get_global_rect().end.x<=hud.size.x-14 and ui.sheet.get_global_rect().end.y<=hud.size.y-190,"Accessible building card fits a narrow portrait screen")
 scene.queue_free()
 await process_frame
 print("VISUAL CITY UX: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
