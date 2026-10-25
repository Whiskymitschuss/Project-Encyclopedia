extends SceneTree
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func settle():
 for frame in 5:await process_frame
 await RenderingServer.frame_post_draw
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 game.state=game.initial_state();var s=game.state
 s.tutorial=5;s.city_services.enabled=false;s.companion_enabled=false
 s.buildings.append({"kind":"central_depot","level":1,"position":[44,20]})
 s.buildings.append({"kind":"express","level":1,"position":[-44,116]})
 LogisticsDispatch.synchronize(s)
 s.resources.wood=CentralLogistics.capacity(s)
 s.resources.boards=2490
 CentralLogistics.stock(s,0).wood=CentralLogistics.output_capacity(s,0)
 var source=CentralLogistics.stock(s,1);source.boards=10
 CentralLogistics.launch(s,1,5,"boards",10,"central",source)
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.life.set_process(false);scene.hud.ux.set_process(false)
 var bar=scene.hud.material_bar
 var stable=s.duplicate(true)
 for size_value in [Vector2i(360,640),Vector2i(591,1280)]:
  root.size=size_value;root.content_scale_size=root.size
  for large in [false,true]:
   s.ux.large_text=large;scene.hud.ux.apply_accessibility()
   scene.hud.close_menu();scene.hud.update_stats();await settle()
   check(bar.warehouse_counts.wood.text=="L 2.5k/2.5k" and bar.captions.wood.text.contains("!"),"Actual HUD shows stock with its maximum and marks a full central shelf")
   check(bar.controls.boards.tooltip_text.contains("10") and bar.controls.boards.tooltip_text.contains("gebucht"),"Booked road capacity appears in actual HUD detail")
   var fits=true
   for key in bar.counters:
    for label in [bar.counters[key],bar.warehouse_counts[key]]:
     var font=label.get_theme_font("font");var font_size=label.get_theme_font_size("font_size")
     if font.get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>label.size.x+1:
      fits=false;printerr("LABEL WIDTH: ",size_value," large=",large," text=",label.text," width=",label.size.x," required=",font.get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x)
   check(fits,"All six material capacity labels fit small/large-text mobile widths")
   scene.hud.open_menu("stock");await settle()
   check(scene.hud.contents.size.x<=scene.hud.scroll.size.x+1,"Actual storage menu fits the mobile scroll width")
   var labels=scene.hud.contents.find_children("*","Label",true,false)
   check(labels.any(func(label):return label.text.contains("2.5 Tsd") and label.text.contains("VOLL")),"Stock menu shows the real central maximum and full state")
   scene.hud.ux.open_material("boards");await settle()
   check(scene.hud.contents.find_children("*","Label",true,false).any(func(label):return label.text.contains("gebucht") and label.text.contains("VOLL")),"Material detail explains the shelf reserved by a real incoming truck")
   check(scene.hud.contents.find_children("*","Button",true,false).any(func(button):return button.text.contains("LAGER AUSBAUEN")),"The actual material detail links directly to warehouse expansion")
   if size_value.x==591 and not large:root.get_texture().get_image().save_png("/workspace/timber2820-storage-details.png")
 root.size=Vector2i(360,640);root.content_scale_size=root.size
 s.ux.large_text=true;scene.hud.ux.apply_accessibility()
 for levels in [[50,20],[1,5]]:
  s.buildings[2].level=levels[0];s.buildings[5].level=levels[1]
  s.resources.wood=CentralLogistics.capacity(s);s.resources.boards=s.resources.wood-1
  scene.hud.close_menu();scene.hud.update_stats();await settle()
  var fits=true
  for key in bar.counters:
   for label in [bar.counters[key],bar.warehouse_counts[key]]:
    if label.get_theme_font("font").get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,label.get_theme_font_size("font_size")).x>label.size.x+1:fits=false
  check(fits,"Maximum-level and near-ten-thousand storage labels fit the smallest large-text phone")
 s.buildings[2].level=stable.buildings[2].level;s.buildings[5].level=stable.buildings[5].level
 s.resources.wood=stable.resources.wood;s.resources.boards=stable.resources.boards
 s.ux.large_text=stable.ux.large_text
 check(s==stable,"HUD and capacity menus never change inventories, reservations or economy")
 root.size=Vector2i(591,1280);root.content_scale_size=root.size
 scene.hud.ux.apply_accessibility();scene.hud.close_menu();scene.hud.update_stats();await settle()
 root.get_texture().get_image().save_png("/workspace/timber2820-storage-hud.png")
 scene.hud.open_menu("logistics");await settle()
 check(scene.hud.contents.find_children("*","Label",true,false).any(func(label):return label.text.contains("maximal") and label.text.contains("Warenart")),"Logistics overview explains the finite per-material shelf policy")
 print("VISUAL STORAGE 2820: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
