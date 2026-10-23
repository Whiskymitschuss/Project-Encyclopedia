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
 for down in [true,false]:
  var event=InputEventScreenTouch.new()
  event.position=root.get_screen_transform()*button.get_global_rect().get_center()
  event.pressed=down
  Input.parse_input_event(event)
  await process_frame
 await settle()
func request_button(ui) -> Button:
 for button in ui.sheet_body.find_children("*","Button",true,false):
  if button.text.begins_with("WARE ANFORDERN"): return button
 return null
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 var s=game.state
 s.tutorial=5
 s.construction_intro=true
 s.company_xp=800
 s.companion_enabled=false
 s.city_services.enabled=false
 s.workers=0
 s.trucks=0
 s.auto_export=false
 for b in s.buildings: b.paused=true
 s.buildings.append({"kind":"furniture","level":2,"paused":false,"position":[-20,-12]})
 s.buildings.append({"kind":"central_depot","level":1,"paused":false,"position":[44,20]})
 s.resources.boards=40
 s.resources.dry=40
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.size=Vector2i(591,1280)
 root.content_scale_size=root.size
 root.add_child(scene)
 scene.set_process(false)
 scene.hud.ux.set_process(false)
 scene.focus=Vector3(12,0,-6)
 scene.zoom=125
 scene.set_camera()
 await settle()
 var ui=scene.hud.ux
 ui.select_building(5)
 await settle()
 var button=request_button(ui)
 check(button!=null,"Actual workshop selection contains the requested supply action")
 if button!=null:
  ui.sheet_scroll.ensure_control_visible(button)
  await settle()
  check(ui.sheet_scroll.get_global_rect().encloses(button.get_global_rect()),"Request action can be reached in the bounded scrollable workshop card")
  await tap(button)
  check(s.hub.shipments.size()==1 and s.hub.shipments[0].target=="factory","Actual screen touch starts a real central-to-workshop truck")
  scene.delivery_world._process(0.1)
  var trip=s.hub.shipments[0]
  var id=scene.delivery_world.visual_key(trip)
  check(id.begins_with("central:") and scene.delivery_world.visuals.has(id),"Manually requested factory shipment has a central-fleet truck in the main world")
  check(scene.selection_world.trip_domain(trip)=="central","Requested truck can be selected through the normal route inspector")
  var truck=scene.delivery_world.visuals[id]
  check(truck.fleet=="central" and truck.cargo!=null,"Requested truck uses central livery and physically visible cargo")
  ui.select_truck({"kind":"truck","id":int(trip.id),"domain":"central"})
  await settle()
  check(ui.selection.kind=="truck" and ui.sheet_title.text.length()>0,"New factory cargo opens the ordinary truck details without invalid building references")
  ui.select_building(5)
  await settle()
  root.get_texture().get_image().save_png("/workspace/timber286-request.png")
 for size in [Vector2i(360,640),Vector2i(540,960)]:
  root.size=size
  root.content_scale_size=size
  s.ux.large_text=true
  ui.apply_accessibility()
  ui.select_building(5)
  await settle()
  button=request_button(ui)
  ui.sheet_scroll.ensure_control_visible(button)
  await settle()
  check(ui.sheet_scroll.get_global_rect().encloses(button.get_global_rect()),"Supply action remains reachable with large text on "+str(size))
  var before=s.duplicate(true)
  scene.delivery_world._process(0.1)
  await settle()
  check(s==before,"New input stock visuals remain read-only on "+str(size))
 scene.queue_free()
 await process_frame
 await process_frame
 print("VISUAL FACTORY SUPPLY 286: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
