extends SceneTree

var checks = 0
var failures = []
var Game

func check(condition: bool, message: String) -> void:
 checks += 1
 if not condition: failures.append(message); printerr("FAILED: ",message)

func _initialize() -> void:
 call_deferred("run")

func run() -> void:
 await process_frame
 Game = root.get_node("Game")
 Game.set_process(false)
 Game.state = Game.initial_state()
 var scene = load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 check(scene.trees.size()==10,"All ten forest regions exist")
 var count = 0
 for group in scene.trees: count += group.size()
 check(count==1000,"One thousand instanced harvestable trees")
 for group in scene.trees:
  for tree in group:
   var point = tree.point
   check(absf(point.x)<194 and point.z>-185 and point.z<194,"Tree remains on land")
   check(absf(point.x-80)>=8 and absf(point.x+80)>=8,"Forest leaves main roads clear")
   for project in Catalog.PROJECTS:
    if signf(point.x)==signf(project.position.x) and absf(point.x)>80:
     check(absf(point.z-project.position.z-13)>=7,"Forest leaves project approach clear")
 check(scene.world_buildings.get_child_count()>5,"Visible starter buildings and conveyor goods")
 var hud = scene.hud
 for menu in ["industry","catalog","team","garage","city","contracts","world","more","missions","loot","research","boosters","prestige","market","settings","confirm_prestige","empire","planner"]:
  hud.open_menu(menu)
  await process_frame
  check(hud.overlay.visible and hud.contents.get_child_count()>0,"Menu renders: "+menu)
  check(not hud.modal_title.text.is_empty(),"Menu has title: "+menu)
 Game.set_plan("house",0)
 hud.open_menu("planner")
 await process_frame
 check(hud.contents.get_child_count()>0,"Material planner displays a real target")
 Game.state.plan = {}
 hud.show_building(1)
 await process_frame
 check(hud.current=="building","Building can be selected")
 hud.show_plot(0)
 await process_frame
 check(hud.current=="plot","City plot can be selected")
 Game.state.buildings.append({"kind":"prefab","level":2,"paused":false})
 hud.show_plot(1)
 await process_frame
 check(hud.contents.get_child_count()==11,"All ten city types are accessible")
 Game.state.coins = 10000
 Game.order_building("kiln")
 check(scene.cranes.size()>0,"Paid construction shows a crane immediately")
 hud.open_menu("industry")
 await process_frame
 Game.simulate(60)
 await process_frame
 check(scene.cranes.is_empty(),"Completed construction removes its scaffold")
 hud.close_menu()
 check(not hud.overlay.visible,"Close returns to world")
 Game.chop()
 var cut = 0
 for tree in scene.trees[0]:
  if tree.regrow>0: cut += 1
 check(cut==1,"Manual harvesting hides a real world tree")
 scene.camera_action("world")
 check(scene.zoom>300,"World overview camera")
 scene.camera_action("home")
 check(scene.zoom==170,"Camera returns to industry")
 root.size = Vector2i(360,640)
 hud.open_menu("industry")
 await process_frame
 check(hud.overlay.size.x>0 and hud.overlay.size.y>0,"Small viewport has a usable overlay")
 scene.queue_free()
 await process_frame
 print("SCENE: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
