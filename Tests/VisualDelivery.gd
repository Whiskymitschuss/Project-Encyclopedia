extends SceneTree
var checks = 0
var failures = []
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func _initialize() -> void: call_deferred("run")
func draw() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func screenshot(path: String) -> void:
 await draw()
 root.get_texture().get_image().save_png(path)
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.workers=4
 game.state.tool=2
 game.state.vehicle=3
 game.state.coins=10000
 game.state.resources.wood=150
 game.state.buildings.append({"kind":"furniture","level":1,"paused":false,"position":[-20,-12]})
 check(game.start_delivery(),"Rendered test assigns actual existing buildings")
 game.simulate(65)
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.zoom=130
 scene.focus=Vector3(-25,0,-29)
 scene.set_camera()
 await draw()
 var layer=scene.delivery_world
 check(layer.badges.size()==4,"All four local-stock controls exist in the rendered scene")
 var visible=0
 for b in layer.badges:
  if b.button.visible:
   visible+=1
   var rect=b.button.get_global_rect()
   check(rect.position.y>=170 and rect.end.y<=scene.hud.size.y-190,"World badge stays clear of the fixed mobile HUD")
   check(b.icon.texture!=null and not b.label.text.is_empty(),"World material badge has both a rendered icon and fraction")
 check(visible>=3,"Production view has at least three readable non-overlapping material badges")
 check(layer.truck_visual_count>0,"Rendered wood loads travel on a real street vehicle")
 game.state.trucks=3
 game.state.delivery.buffers.furniture.furniture=2
 game.step(1)
 await draw()
 check(layer.truck_visual_count>0,"A real loaded delivery vehicle appears on the shop route")
 var trucks=0
 for shipment in game.state.delivery.shipments:
  if shipment.mode=="truck" and shipment.key=="furniture":
   var node=layer.visuals[layer.visual_key(shipment)]
   trucks+=1
   check(node.cargo_furniture and node.cargo!=null and node.cargo.visible==not shipment.arrived,"Furniture cargo is visible on loaded trips and absent on empty returns")
 check(trucks>0,"Real delivery truck uses a furniture cargo model")
 game.changed.emit()
 await screenshot("/workspace/timber-delivery-world.png")
 game.state.company_xp=120
 game.state.construction_auto=false
 check(game.order_building("garage"),"Construction preview is an actual paid material job")
 var job=game.state.jobs.back()
 game.state.resources.wood=5
 game.deliver_job(int(job.id))
 for i in 180:
  game.step(1)
  if float(job.delivered.get("wood",0))>0: break
 check(job.delivered.get("wood",0)>0,"Preview construction counter shows actual arrived materials")
 scene.hud.close_menu()
 scene.focus_at(ConstructionRules.job_position(game.state,job))
 scene.zoom=96
 scene.set_camera()
 game.changed.emit()
 await screenshot("/workspace/timber-delivery-construction.png")
 scene.hud.open_menu("construction")
 await screenshot("/workspace/timber-delivery-materials.png")
 check(scene.hud.overlay.visible and scene.hud.modal_title.text=="BAUSTELLEN & MATERIAL","Mobile material menu is rendered")
 scene.hud.open_menu("delivery")
 await screenshot("/workspace/timber-delivery-orders.png")
 check(scene.hud.contents.get_child_count()>=6,"Live order and individual building buffers are accessible")
 scene.hud.close_menu()
 root.size=Vector2i(360,640)
 await draw()
 check(scene.hud.size.x==root.get_visible_rect().size.x,"Delivery controls use the stretched viewport coordinates on a small portrait window")
 for b in layer.badges:
  if b.button.visible: check(b.button.get_global_rect().end.x<=scene.hud.size.x-4,"Visible badges remain inside a narrow portrait screen")
 scene.hud.open_menu("construction")
 await draw()
 check(scene.hud.scroll.size.x>0 and scene.hud.scroll.size.y>0,"Construction material depot stays scrollable on narrow screens")
 scene.queue_free()
 await process_frame
 print("VISUAL DELIVERY: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
