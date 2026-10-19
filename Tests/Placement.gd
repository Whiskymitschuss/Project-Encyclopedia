extends SceneTree

var Game
var checks=0
var failures=[]

func check(condition: bool, message: String) -> void:
 checks+=1
 if not condition: failures.append(message); printerr("FAILED: ",message)

func _initialize() -> void: call_deferred("run")

func run() -> void:
 await process_frame
 Game=root.get_node("Game")
 Game.set_process(false)
 Game.state=Game.initial_state()
 check(not Game.state.auto_sawdust,"Spänebox is manually collected by default")
 Game.state.workers=0
 Game.state.resources.wood=20
 Game.state.resources.sawdust=Game.capacity()
 Game.step(1)
 check(Game.state.resources.boards>0 and Game.state.resources.sawdust==Game.capacity(),"Full manual bin never stops boards or deletes stored sawdust")
 check(Game.state.coins==350 and Game.flow.sawdust_composted>0,"Uncollected new overflow is composted without free income")
 Game.sell("sawdust")
 check(Game.state.resources.sawdust==0 and Game.state.coins==850,"Emptying the bin pays for all actually stored material")
 var legacy=Game.snapshot()
 legacy.erase("tutorial")
 legacy.erase("auto_sawdust")
 Game.restore(legacy)
 check(Game.state.tutorial==5 and Game.state.coins==850,"Existing players keep progress and skip forced onboarding")
 check(Game.building_position(1)==Catalog.industry_position(1),"Legacy building locations are preserved")
 var point=Vector3(20,0,-80)
 check(Game.placement_reason(point).is_empty(),"Unoccupied construction land is usable")
 check(not Game.placement_reason(Vector3(0,0,-80)).is_empty(),"Road placement is rejected")
 check(not Game.placement_reason(Vector3(250,0,0)).is_empty(),"Water and outside land are rejected")
 check(not Game.placement_reason(Vector3(INF,0,0)).is_empty(),"Non-finite placement is rejected")
 var original_position=Game.building_position(1)
 var original_level=Game.state.buildings[1].level
 var coins=Game.state.coins
 check(Game.move_building(1,point,90),"Existing production building can be moved and rotated")
 check(Game.building_position(1)==point and Game.state.buildings[1].rotation==90,"New placement coordinates are stored")
 check(Game.state.coins==coins and Game.state.buildings[1].level==original_level,"Moving preserves money and upgrades")
 check(not Game.move_building(1,Game.building_position(0)),"Moving into another building is rejected")
 check(Game.building_position(1)==point,"Rejected move keeps the old location")
 var moved=JSON.parse_string(JSON.stringify(Game.snapshot()))
 Game.restore(moved)
 check(Game.building_position(1)==point and Game.state.buildings[1].rotation==90,"Position and rotation survive a JSON save roundtrip")
 check(Game.move_building(1,Game.free_position(original_position,0,1)),"A building can return to a legal grid point near its legacy position")
 Game.state.coins=10000
 var before=Game.state.coins
 check(not Game.order_building("kiln",Vector3(0,0,-80)),"Invalid construction cannot start")
 check(Game.state.coins==before and Game.state.jobs.is_empty(),"Invalid preview cannot charge money or reserve a job")
 check(Game.order_building("kiln",point,90),"Selected valid location creates a paid construction job")
 var paid=Game.state.coins
 check(not Game.order_building("kiln",point),"Pending construction reserves its footprint")
 check(Game.state.coins==paid,"Duplicate placement never charges again")
 Game.simulate(50)
 check(Game.state.buildings.size()==6 and Game.building_position(5)==point and Game.state.buildings[5].rotation==90,"Completed model uses the selected location and orientation")
 var home_materials=Catalog.HOMES.house.materials
 for key in home_materials: Game.state.resources[key]=home_materials[key]
 Game.state.buildings.append({"kind":"prefab","level":1,"paused":false})
 var home_point=Vector3(-40,0,116)
 check(Game.order_home("house",0,home_point,90),"Housing can be placed independently of its logical plot number")
 Game.simulate(65)
 check(Game.home_position(0)==home_point,"Home position survives construction")
 check(Game.move_building(0,Vector3(-40,0,148),0,true),"Completed housing can be rearranged")
 Game.state=Game.initial_state()
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 for i in 2: await process_frame
 check(scene.hud.current=="welcome" and scene.hud.overlay.visible,"A new game opens the welcome screen")
 Game.state.tutorial=1
 scene.hud.close_menu()
 for i in 5: Game.chop()
 check(Game.state.tutorial==2,"Guide advances after actual tree cutting")
 Game.deposit()
 check(Game.state.tutorial==3,"Guide advances after actual delivery")
 Game.sell("wood")
 check(Game.state.tutorial==4,"Guide advances after a real sale")
 scene.begin_placement({"kind":"station","city":false,"index":-1})
 var untouched=Game.state.coins
 check(scene.ghost!=null and scene.hud.placement_panel.visible,"Build mode displays a world preview and confirmation bar")
 scene.placement_action("cancel")
 check(scene.ghost==null and Game.state.coins==untouched and Game.state.jobs.is_empty(),"Cancelling the preview is free")
 scene.begin_placement({"kind":"station","city":false,"index":-1})
 scene.placement_point=Vector3(0,0,-80)
 scene.update_ghost()
 check(scene.hud.placement_confirm.disabled,"Invalid location disables the build button")
 scene.placement_action("confirm")
 check(Game.state.coins==untouched and not scene.placement.is_empty(),"Invalid confirmation keeps preview and funds")
 scene.placement_point=Vector3(20,0,-80)
 scene.update_ghost()
 scene.placement_action("confirm")
 check(Game.state.tutorial==5 and Game.state.jobs.size()==1,"Actual placed construction completes the tutorial")
 check(scene.ghost==null and not scene.hud.placement_panel.visible,"Successful construction closes the preview")
 check(scene.bins.size()==1,"Sawmill has a visible live sawdust bin")
 check(scene.network.links.size()>0,"Real building positions create conveyor connections")
 for link in scene.network.links:
  check(link.length>0 and link.points.size()>1,"Conveyor route has physical length and endpoints")
  for p in link.points:
   check(absf(p.x)<80 and p.z>=-156 and p.z<=166,"Conveyors remain inside the connected land network")
   if absf(p.x)<=3.5:
    check(p.y>=6,"Road crossings leave truck clearance")
 scene.hud.open_menu("sawdust")
 check(scene.hud.contents.get_child_count()>0,"Bin can be emptied through a direct control")
 for menu in ["catalog","guide","welcome"]:
  scene.hud.open_menu(menu)
  await process_frame
  check(scene.hud.contents.get_child_count()>0,"New direct interface renders: "+menu)
 scene.queue_free()
 await process_frame
 print("PLACEMENT & ONBOARDING: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
