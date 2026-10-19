extends SceneTree

func _initialize() -> void: call_deferred("run")

func shot(path: String) -> void:
 for i in 6: await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(path)

func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.companion_enabled=false
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await shot("/workspace/timber-valley-start.png")
 for kind in ["kiln","furniture","prefab","garage","joinery","research","pellet","paper","design"]:
  var p=game.free_position(Catalog.industry_position(game.state.buildings.size()))
  game.state.buildings.append({"kind":kind,"level":3,"paused":false,"position":[p.x,p.z]})
 for i in 8:
  var p=game.free_position(Catalog.home_position(i))
  game.state.homes.append({"kind":Catalog.HOMES.keys()[i],"level":2,"plot":i,"position":[p.x,p.z]})
 game.state.workers=12
 game.state.trucks=3
 game.state.vehicle=3
 game.state.time=11
 game.state.weather=0
 game.state.region=2
 game.state.coins=110000
 for key in game.state.resources: game.state.resources[key]=120
 scene.rebuild()
 scene.camera_action("world")
 scene.hud.update_stats()
 await shot("/workspace/timber-valley-overview.png")
 scene.focus_at(Vector3(0,0,42))
 scene.zoom=182
 scene.set_camera()
 await shot("/workspace/timber-valley-industry.png")
 scene.focus_at(Vector3(-104,0,218))
 scene.zoom=115
 scene.set_camera()
 await shot("/workspace/timber-valley-river.png")
 scene.zoom=590
 scene.focus=Vector3.ZERO
 scene.set_camera()
 game.state.time=19
 game.state.weather=3
 scene.hud.update_stats()
 await shot("/workspace/timber-valley-evening.png")
 scene.queue_free()
 await process_frame
 quit()
