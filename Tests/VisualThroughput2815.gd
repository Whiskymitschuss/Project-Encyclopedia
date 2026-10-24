extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func settle() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func find(parent: Node,prefix: String) -> Button:
 for button in parent.find_children("*","Button",true,false):
  if button.text.begins_with(prefix): return button
 return null
func tap(hud: Control,button: Button) -> void:
 if button==null: check(false,"Expected transport action exists"); return
 hud.scroll.ensure_control_visible(button)
 await settle()
 var at=root.get_screen_transform()*button.get_global_rect().get_center()
 for down in [true,false]:
  var event=InputEventScreenTouch.new();event.position=at;event.pressed=down
  Input.parse_input_event(event)
  await process_frame
 await settle()
func material(s: Dictionary) -> Dictionary:
 var result={}
 for key in Catalog.RESOURCES:
  var stock=UXRules.material_stock(s,key)
  result[key]=float(stock.stored)+float(stock.transit)+float(stock.processing)
 return result
func run() -> void:
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 game.state=game.initial_state()
 var s=game.state
 s.workers=6;s.vehicle=1;s.coins=20000;s.tutorial=5;s.construction_intro=true
 s.companion_enabled=false;s.city_services.enabled=false;s.auto_export=false;s.reserve=false
 s.buildings[1].level=2;s.buildings[2].level=8
 s.buildings.append({"kind":"central_depot","level":1,"paused":false,"position":[44,20]})
 s.buildings.append({"kind":"furniture","level":2,"paused":false,"position":[21,-12]})
 s.resources.wood=4000;s.resources.boards=40
 DeliveryChain.start(s)
 for second in 120: game.step(1)
 root.size=Vector2i(591,1280);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false)
 var hud=scene.hud
 hud.open_menu("garage")
 await settle()
 var coins=float(s.coins);var fleet=CentralLogistics.fleet_size(s)
 var cost=TransportCapacity.fleet_cost(s);var goods=material(s)
 await tap(hud,find(hud.contents,"LAGER-LKW KAUFEN"))
 check(CentralLogistics.fleet_size(s)==fleet+1 and s.coins==coins-cost,"Real Garage touch buys exactly one paid warehouse truck")
 check(material(s)==goods,"Buying a truck changes neither stock nor cargo")
 root.get_texture().get_image().save_png("/workspace/timber2815-fleet.png")
 hud.show_building(1)
 await settle()
 var buffer=FactorySupply.capacity(s,1)
 var payload=CentralLogistics.pickup_capacity(s,"wood",5,1)
 coins=s.coins;cost=TransportCapacity.upgrade_cost(s,1);goods=material(s)
 await tap(hud,find(hud.contents,"TRANSPORT AUSBAUEN"))
 check(FactorySupply.capacity(s,1)==buffer+32 and CentralLogistics.pickup_capacity(s,"wood",5,1)>payload and s.coins==coins-cost,"Actual workshop touch pays for larger buffers and loading volume")
 check(material(s)==goods,"Workshop transport action grants no free inventory")
 check(hud.contents.find_children("*","Label",true,false).any(func(label): return label.text.contains("Transportausbau 1/4") and label.text.contains("160")),"Workshop inspector shows its actual purchased transport level and stock space")
 root.get_texture().get_image().save_png("/workspace/timber2815-workshop.png")
 for resolution in [Vector2i(360,640),Vector2i(540,960),Vector2i(591,1280)]:
  root.size=resolution;root.content_scale_size=resolution
  for large in [false,true]:
   s.ux.large_text=large
   for menu in ["building","garage","logistics"]:
    if menu=="building": hud.show_building(1)
    else: hud.open_menu(menu)
    hud.ux.apply_accessibility()
    await settle()
    check(hud.contents.size.x<=hud.scroll.size.x+1 and hud.scroll.size.y>=120,"Transport controls fit the actual scrolling menu at %s / large=%s / %s" % [resolution,large,menu])
 s.ux.large_text=false
 hud.close_menu();root.size=Vector2i(591,1280);root.content_scale_size=root.size
 scene.focus=Vector3(12,0,-14);scene.zoom=140;scene.set_camera()
 game.step(1)
 scene.delivery_world._process(0.1)
 await settle()
 var before=s.duplicate(true)
 scene.delivery_world._process(0.2)
 check(s==before,"Rendering the larger finite freight fleet does not move or duplicate goods in the ledger")
 check(scene.delivery_world.visuals.size()>0,"Larger loads use the actual main-world truck renderer")
 root.get_texture().get_image().save_png("/workspace/timber2815-world.png")
 print("VISUAL THROUGHPUT 2815: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
