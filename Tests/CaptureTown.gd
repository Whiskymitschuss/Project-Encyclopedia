extends SceneTree

func _initialize() -> void:
 call_deferred("run")

func shot(path: String) -> void:
 for i in 8: await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(path)

func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.companion_enabled=false
 game.state.coins=180000
 game.state.region=2
 game.state.time=11.0
 game.state.weather=0
 game.state.workers=12
 game.state.trucks=3
 game.state.vehicle=3
 for kind in ["kiln","furniture","prefab","garage","joinery"]:
  var p=game.free_position(Catalog.industry_position(game.state.buildings.size()))
  game.state.buildings.append({"kind":kind,"level":3,"paused":false,"position":[p.x,p.z]})
 for i in Catalog.HOMES.size():
  var p=game.free_position(Catalog.home_position(i))
  game.state.homes.append({"kind":Catalog.HOMES.keys()[i],"level":2,"plot":i,"position":[p.x,p.z],"rent_bank":150.0 if float(Catalog.HOMES[Catalog.HOMES.keys()[i]].rent)>0 else 0.0})
 for key in game.state.resources: game.state.resources[key]=120
 game.state.town.stops=[{"id":1,"name":"Waldquartier","cell":[0,68]},{"id":2,"name":"Stadtmitte","cell":[80,132]}]
 game.state.town.lines=[{"id":1,"stops":[1,2],"phase":12.0,"trips":12,"income":620.0}]
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.focus_at(Vector3(10,0,108))
 scene.zoom=145
 scene.set_camera()
 scene.hud.update_stats()
 await shot("/workspace/timber-town.png")
 game.state.town.lines[0].phase=4.4
 scene.focus_at(Vector3(4,0,68))
 scene.zoom=65
 scene.set_camera()
 await shot("/workspace/timber-bus.png")
 game.state.tool=11
 scene.sync_actors()
 game.flow.harvest=8.0
 scene.focus_at(Catalog.biome_position(0)+Vector3(0,0,-5))
 scene.zoom=62
 scene.set_camera()
 scene.hud.update_stats()
 await shot("/workspace/timber-forestry.png")
 game.state.town.districts=1
 game.state.homes.append({"kind":"landhouse","level":3,"plot":12,"position":[216,-112],"rent_bank":70.0})
 game.state.homes.append({"kind":"apartments","level":3,"plot":13,"position":[248,-112],"rent_bank":200.0})
 game.state.town.roads=[{"kind":"asphalt","cells":[]}]
 for c in TownRules.path(Vector2i(200,-96),Vector2i(284,-96)): game.state.town.roads[0].cells.append([c.x,c.y])
 scene.rebuild()
 scene.focus_at(Vector3(242,0,-108))
 scene.zoom=122
 scene.set_camera()
 await shot("/workspace/timber-district.png")
 scene.hud.open_menu("transit")
 await shot("/workspace/timber-transit-ui.png")
 scene.hud.close_menu()
 scene.begin_placement({"network":true,"kind":"asphalt"})
 scene.network_at(Vector3(200,0,-64),true)
 scene.network_at(Vector3(284,0,-32),true)
 scene.focus_at(Vector3(242,0,-56))
 scene.zoom=135
 scene.set_camera()
 await shot("/workspace/timber-road.png")
 scene.cancel_placement()
 scene.queue_free()
 await process_frame
 quit()
