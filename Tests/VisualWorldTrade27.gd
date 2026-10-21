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
  var touch=InputEventScreenTouch.new()
  touch.position=at
  touch.pressed=pressed
  Input.parse_input_event(touch)
  await process_frame
 await settle()
func button_in(node: Node,title: String) -> Button:
 for button in node.find_children("*","Button",true,false):
  if button.text.begins_with(title): return button
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
 game.state.workers=0
 game.state.coins=10000
 game.state.time=11
 game.state.resources.furniture=12
 root.size=Vector2i(540,960)
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await settle()
 scene.set_process(false)
 var hud=scene.hud
 check(scene.trade_world!=null and scene.trade_world.borders.get_child_count()>0,"Motorway and locked biome boundaries are actually instantiated")
 check(scene.biome_labels[1].text.begins_with("ZU"),"The forest label identifies a protected biome")
 hud.open_menu("export")
 await settle()
 var connection=button_in(hud.contents,"ANSCHLUSS ANSEHEN")
 check(connection!=null,"The export panel offers a discoverable gateway focus action")
 await tap(connection)
 check(not hud.overlay.visible and scene.focus.x==288,"A real touch focuses the actual highway without spending coins")
 scene.zoom=95
 scene.set_camera()
 scene.trade_world._process(1)
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber-world27-highway.png")
 var before=float(game.state.coins)
 hud.open_menu("export")
 await settle()
 await tap(button_in(hud.contents,"STRASSE ZUM ANSCHLUSS"))
 check(scene.placement.get("network",false) and scene.placement.kind=="asphalt","The public export action starts the real paid road tool")
 check(scene.focus.x==220 and scene.focus.z==245 and scene.zoom==420,"The highway road tool frames both endpoints on the phone")
 check(game.state.coins==before and game.state.town.roads.is_empty(),"Opening the road preview never gifts a connection")
 var a=scene.camera.unproject_position(Vector3(80,0,176))
 var b=scene.camera.unproject_position(TownRules.point(ExportTrade.GATE))
 root.get_texture().get_image().save_png("/workspace/timber-world27-road-preview.png")
 check(a.y>230 and b.y<hud.placement_panel.global_position.y and a.x>0 and b.x<hud.size.x,"Both ends of the complete highway road fit in the unobstructed touch area")
 var start=InputEventScreenTouch.new()
 start.position=root.get_screen_transform()*a
 start.pressed=true
 Input.parse_input_event(start)
 await process_frame
 for i in range(1,9):
  var drag=InputEventScreenDrag.new()
  drag.position=root.get_screen_transform()*a.lerp(b,i/8.0)
  drag.relative=root.get_screen_transform().basis_xform((b-a)/8.0)
  Input.parse_input_event(drag)
  await process_frame
 var end=InputEventScreenTouch.new()
 end.position=root.get_screen_transform()*b
 end.pressed=false
 Input.parse_input_event(end)
 await settle()
 check(scene.road_anchor==Vector2i(80,176) and scene.road_endpoint==ExportTrade.GATE,"A physical finger stroke draws the entire highway connection")
 await settle()
 check(not hud.placement_confirm.disabled,"The road preview accepts the complete legal highway approach")
 await tap(hud.placement_confirm)
 check(game.state.town.roads.size()==1 and game.state.coins==before-1540,"Touch confirmation pays exactly for 220m of new road")
 game.step(1)
 scene.delivery_world._process(0)
 await settle()
 check(game.state.trade.shipments.size()==1 and scene.delivery_world.visuals.has("export:1"),"Real saved export cargo creates its own visible truck")
 if game.state.trade.shipments.is_empty():
  scene.queue_free()
  await process_frame
  print("VISUAL WORLD & TRADE 27: ",checks," checks, ",failures.size()," failures")
  quit(1)
  return
 var trip=game.state.trade.shipments[0]
 trip.age=float(trip.load)+float(trip.drive)*0.96
 scene.delivery_world._process(0)
 var node=scene.delivery_world.visuals["export:1"]
 check(node.cargo.visible and node.get_node("RouteLabel").text.contains("Autobahn"),"Outbound truck displays its actual cargo and destination")
 scene.focus=node.position
 scene.zoom=78
 scene.set_camera()
 hud.ux.select_truck({"kind":"truck","domain":"export","id":1},true)
 await settle()
 check(Vector2(scene.focus.x,scene.focus.z).distance_to(Vector2(node.position.x,node.position.z))<2,"Selecting freight from the export menu focuses its actual position")
 check(hud.ux.sheet.visible and hud.ux.find_trip()==trip,"Export truck opens a correct contextual card")
 check(scene.selection_world.route_root.get_child_count()>0,"The highlighted export route follows the saved road and ramp")
 root.get_texture().get_image().save_png("/workspace/timber-world27-freight.png")
 trip.age=float(trip.travel)-1
 game.state.auto_export=false
 game.step(1)
 scene.delivery_world._process(0)
 check(trip.arrived and not node.cargo.visible,"Arrival removes delivered cargo from the return model")
 hud.ux.hide_panels(true)
 scene.begin_placement({"kind":"station","city":false,"index":-1})
 scene.placement_point=Vector3(248,0,-80)
 scene.update_ghost()
 check(not hud.placement_confirm.disabled,"A new building preview works outside the former construction district")
 scene.placement_point=Vector3(-46,0,-116)
 scene.update_ghost()
 check(hud.placement_confirm.disabled,"The actual build confirmation protects locked forest land")
 game.state.coins=10000
 check(game.unlock_biome(),"The preview can respond to a paid biome unlock")
 scene.update_ghost()
 check(not hud.placement_confirm.disabled and not scene.biome_labels[1].text.begins_with("ZU"),"The same preview becomes legal and the boundary disappears after unlocking")
 scene.placement_action("cancel")
 for dimensions in [Vector2i(360,640),Vector2i(540,960),Vector2i(800,1280),Vector2i(1100,700)]:
  root.content_scale_size=dimensions
  root.size=dimensions
  for large in [false,true]:
   game.state.ux.large_text=large
   hud.open_menu("export")
   await settle()
   check(absf(hud.size.x-dimensions.x)<1,"The logical HUD uses the actual %s viewport width" % dimensions)
   check(hud.overlay.get_global_rect().end.x<=hud.size.x+1 and hud.overlay.get_global_rect().end.y<=hud.size.y+1,"Export interface fits %s, large text %s" % [dimensions,large])
   var action=button_in(hud.contents,"ANSCHLUSS ANSEHEN")
   check(action.size.x<=hud.contents.size.x and action.size.y>=44,"Export action remains readable and touchable at %s" % dimensions)
   if dimensions==Vector2i(360,640) and large: root.get_texture().get_image().save_png("/workspace/timber-world27-menu.png")
 scene.queue_free()
 await process_frame
 print("VISUAL WORLD & TRADE 27: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
