extends SceneTree

func _initialize() -> void:
 call_deferred("run")

func run() -> void:
 await process_frame
 var game = root.get_node("Game")
 game.set_process(false)
 var original = game.state.duplicate(true)
 game.state = game.initial_state()
 game.state.tutorial=5
 var scene = load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 for i in 10: await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/timber-fresh.png")
 for kind in ["kiln","furniture","garage","research","prefab","joinery","paper","design","pellet"]:
  game.state.buildings.append({"kind":kind,"level":5,"paused":false})
 for i in 8: game.state.homes.append({"kind":Catalog.HOMES.keys()[i],"level":2,"plot":i})
 game.state.workers = 12
 game.state.trucks = 5
 scene.rebuild()
 scene.focus_at(Vector3(0,0,54))
 scene.zoom = 180
 scene.set_camera()
 for i in 10: await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/timber-city.png")
 scene.hud.open_menu("industry")
 for i in 4: await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/workspace/timber-ui.png")
 game.restore(original)
 scene.queue_free()
 await process_frame
 quit()
