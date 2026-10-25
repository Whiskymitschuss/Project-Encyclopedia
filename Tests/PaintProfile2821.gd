extends SceneTree
func _initialize():call_deferred("run")
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false);root.get_node("RuntimeStats").set_process(false);game.state=game.initial_state()
 root.size=Vector2i(591,850);root.content_scale_size=root.size
 var stage=Node3D.new();root.add_child(stage)
 var en=WorldEnvironment.new();var env=Environment.new();env.background_mode=Environment.BG_COLOR;env.background_color=Color("53bbd3");env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_energy=0.43;en.environment=env;stage.add_child(en)
 var light=DirectionalLight3D.new();light.rotation_degrees=Vector3(-48,-25,0);light.light_energy=0.68;light.shadow_enabled=true;stage.add_child(light)
 var camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=92;camera.position=Vector3(90,120,130);stage.add_child(camera);camera.look_at(Vector3.ZERO)
 var models=load("res://Buildings/Models.gd")
 var entries=[["sawmill",6,false],["warehouse",7,false],["townhall",7,true],["furniture",5,false]]
 for i in entries.size():
  var e=entries[i];var model=models.building(e[0],e[1],e[2]);model.position=Vector3(-14+28*(i%2),0,-17+34*(i/2));stage.add_child(model)
 if ResourceLoader.exists("res://Components/StaticPaintBatch.gd"):load("res://Components/StaticPaintBatch.gd").reduce(stage)
 for node in stage.find_children("*","Node",true,false):node.set_process(false)
 for frame in 12:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_environment("TIMBER_BENCH_OUTPUT"))
 print("GALLERY READY")
 quit()
