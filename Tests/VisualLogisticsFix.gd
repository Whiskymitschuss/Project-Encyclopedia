extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func draw() -> void:
 for i in 6: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.company_xp=800
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.city_services.enabled=false
 game.state.workers=0
 game.state.trucks=3
 game.state.vehicle=6
 game.state.coins=771800
 game.state.time=11
 game.state.weather=0
 game.state.buildings[0].level=5
 game.state.buildings[1].level=5
 game.state.buildings.append({"kind":"furniture","level":3,"paused":false,"position":[-20,-12]})
 game.state.buildings.append({"kind":"prefab","level":1,"paused":true,"position":[20,-12]})
 check(game.start_delivery(),"The displayed delivery line uses real existing factories")
 game.state.resources.wood=100
 game.state.resources.parts=2
 game.state.delivery.buffers.station.wood=14
 game.state.delivery.buffers.sawmill.boards=6
 check(game.order_home("park",0,Vector3(44,0,-12)),"The displayed park is a paid city construction project")
 var job=game.state.jobs[0]
 var cargo={}
 var wood={}
 for i in 90:
  game.step(1)
  cargo={}
  wood={}
  for s in game.state.construction_shipments:
   if s.key=="boards" and not s.arrived: cargo=s; break
  for s in game.state.delivery.shipments:
   if s.key=="wood": wood=s; break
  if not cargo.is_empty() and not wood.is_empty(): break
 check(not cargo.is_empty() and cargo.source=="sawmill","The actual sawmill output creates a construction truck")
 check(not wood.is_empty(),"Actual log transport is visible alongside the building delivery")
 if cargo.is_empty() or wood.is_empty(): quit(1); return
 # Distinct save domains may share a numeric ID after a long company history.
 wood.id=int(cargo.id)
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.zoom=112
 scene.focus=Vector3(-1,0,-24)
 scene.set_camera()
 await draw()
 var layer=scene.delivery_world
 check(layer.visual_key(wood)!=layer.visual_key(cargo),"Simultaneous wood and construction numeric IDs have distinct render keys")
 check(layer.visuals.has(layer.visual_key(wood)) and layer.visuals.has(layer.visual_key(cargo)),"Both real cargo domains retain their own rendered vehicle")
 var construction=layer.visuals[layer.visual_key(cargo)]
 var supply=layer.visuals[layer.visual_key(wood)]
 check(construction!=supply and construction.cargo_boards and not supply.cargo_boards,"A board delivery cannot turn into a wood truck through model reuse")
 check(construction.cargo.visible and "Bau" in construction.get_node("RouteLabel").text,"A loaded construction truck shows boards and its actual destination")
 for badge in layer.badges:
  if badge.kind not in ["sawmill","furniture"]: continue
  check(badge.output_icon!=null and badge.output_label!=null,"Production buildings have permanently separate input and output rows")
  check(badge.icon.texture.resource_path.ends_with("wood.svg") if badge.kind=="sawmill" else badge.icon.texture.resource_path.ends_with("boards.svg"),"The input icon retains its own material")
  check(badge.output_icon.texture.resource_path.ends_with("boards.svg") if badge.kind=="sawmill" else badge.output_icon.texture.resource_path.ends_with("furniture.svg"),"The output icon retains the finished product")
  check(badge.output_label.text.begins_with("→"),"The output row is visibly marked as outgoing material")
 await draw()
 root.get_texture().get_image().save_png("/workspace/timber-logistics-direct.png")
 scene.hud.open_menu("construction")
 await draw()
 var incoming=false
 var route=false
 for entry in scene.hud.live_labels:
  if not is_instance_valid(entry.label): continue
  if "unterwegs" in entry.label.text: incoming=true
  if "Sägewerk → Baustelle" in entry.label.text: route=true
 check(incoming and route,"The mobile site interface shows reserved incoming quantities and the actual source")
 root.get_texture().get_image().save_png("/workspace/timber-logistics-menu.png")
 scene.hud.close_menu()
 var amount=float(cargo.amount)
 var boards_before=float(job.delivered.get("boards",0))
 ConstructionRules.transport_tick(game.state,float(cargo.travel)-float(cargo.age)+0.1)
 layer._process(0.1)
 check(cargo.arrived and not construction.cargo.visible,"Actual unloading hides board cargo on the return trip")
 check(construction.get_node("RouteLabel").text=="LEER · zurück","The empty return trip explicitly says it is empty")
 check(float(job.delivered.boards)==boards_before+amount,"Rendered return follows exactly one real delivery receipt")
 var receipt=float(job.delivered.boards)
 ConstructionRules.transport_tick(game.state,0.1)
 check(float(job.delivered.boards)==receipt,"A second rendered tick cannot credit boards again")
 var parsed=JSON.parse_string(JSON.stringify(game.state,"",true,true))
 game.restore(parsed)
 layer._process(0.1)
 check(not layer.visuals[layer.visual_key(cargo)].cargo.visible,"JSON restore retains an empty return instead of restoring phantom logs")
 for size_value in [Vector2i(540,960),Vector2i(360,640)]:
  root.size=size_value
  await draw()
  for badge in layer.badges:
   if badge.output_label==null or not badge.button.visible: continue
   check(badge.output_label.get_global_rect().end.y<=badge.button.get_global_rect().end.y+1,"Both stock rows fit their world badge on "+str(size_value))
   check(badge.button.get_global_rect().end.x<=scene.hud.size.x-4,"The double material counter stays within the portrait viewport")
 scene.queue_free()
 await process_frame
 print("VISUAL LOGISTICS FIX: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
