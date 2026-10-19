extends SceneTree
var checks=0
var failures=[]
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func _initialize() -> void: call_deferred("run")
func draw() -> void:
 for i in 3: await process_frame
 await RenderingServer.frame_post_draw

func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.companion_enabled=false
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await draw()
 var valley=scene.landscape
 var terrain=valley.get_node("ValleyTerrain")
 check(terrain.mesh.surface_get_material(0).vertex_color_is_srgb,"Terrain vertex colours use the correct colour space")
 # Render a real pooled foliage mesh in isolation to catch black/missing tints.
 var viewport=SubViewport.new()
 viewport.size=Vector2i(160,160)
 viewport.own_world_3d=true
 viewport.transparent_bg=true
 viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
 root.add_child(viewport)
 var env=WorldEnvironment.new()
 env.environment=Environment.new()
 env.environment.background_mode=Environment.BG_COLOR
 env.environment.background_color=Color(0,0,0,0)
 env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 env.environment.ambient_light_color=Color.WHITE
 env.environment.ambient_light_energy=1.0
 viewport.add_child(env)
 var camera=Camera3D.new()
 camera.projection=Camera3D.PROJECTION_ORTHOGONAL
 camera.size=13
 viewport.add_child(camera)
 camera.position=Vector3(10,10,14)
 camera.look_at(Vector3(0,4,0))
 var source=valley.batches.leaf
 var pooled=MultiMesh.new()
 pooled.transform_format=MultiMesh.TRANSFORM_3D
 pooled.use_colors=source.mesh.use_colors
 pooled.use_custom_data=source.mesh.use_custom_data
 pooled.mesh=source.mesh.mesh
 pooled.instance_count=1
 pooled.set_instance_transform(0,Transform3D.IDENTITY)
 if pooled.use_colors: pooled.set_instance_color(0,Color("53a75c"))
 if pooled.use_custom_data: pooled.set_instance_custom_data(0,Color("53a75c"))
 var foliage=MultiMeshInstance3D.new()
 foliage.multimesh=pooled
 foliage.material_override=source.view.material_override
 viewport.add_child(foliage)
 await draw()
 var leaf_image=viewport.get_texture().get_image()
 var green=0
 for y in leaf_image.get_height():
  for x in leaf_image.get_width():
   var pixel=leaf_image.get_pixel(x,y)
   if pixel.a>0.5 and pixel.g>0.16 and pixel.g>pixel.r*1.25 and pixel.g>pixel.b*1.25: green+=1
 check(green>180,"Pooled foliage renders its actual green tint instead of a black silhouette")
 viewport.queue_free()
 var target=null
 var target_kind=""
 var target_index=-1
 for kind in ["flowers","bush"]:
  var batch=valley.batches[kind]
  for i in batch.entries.size():
   var entry=batch.entries[i]
   if entry.blocked or not game.placement_reason(Vector3(entry.point.x,0,entry.point.y)).is_empty(): continue
   target=entry; target_kind=kind; target_index=i; break
  if target!=null: break
 check(target!=null,"Rendered meadow has a usable construction site")
 if target!=null:
  var multi=valley.batches[target_kind].mesh
  check(multi.get_instance_transform(target_index).basis.get_scale().x>0.5,"The selected plant actually exists in the rendered instance buffer")
  check(game.move_building(1,Vector3(target.point.x,0,target.point.y)),"A real building move triggers vegetation clearing")
  await draw()
  check(multi.get_instance_transform(target_index).basis.get_scale().x<0.01,"The rendered plant is removed from the new building footprint")
 scene.focus_at(Vector3(-110,0,valley.river_z(-110)))
 scene.zoom=100
 scene.set_camera()
 await draw()
 var picture=root.get_texture().get_image()
 var water_pixels=0
 for x in [-125,-118,-110,-103,-78,-70]:
  var point=Vector3(x,-1.05,valley.river_z(x))
  var screen=scene.camera.unproject_position(point)
  if screen.x<0 or screen.y<165 or screen.x>=picture.get_width() or screen.y>=picture.get_height()-184: continue
  var pixel=picture.get_pixelv(Vector2i(screen))
  if pixel.g>pixel.r*1.25 and pixel.b>pixel.r*1.25: water_pixels+=1
 check(water_pixels>=3,"Actual rendered water is visible in the river channel")
 for zoom_value in [390,650]:
  scene.zoom=zoom_value
  scene.focus=Vector3.ZERO
  scene.set_camera()
  await draw()
  var lower=Vector2(root.size.x*0.5,root.size.y-190)
  check(Plane(Vector3.UP,0).intersects_ray(scene.camera.project_ray_origin(lower),scene.camera.project_ray_normal(lower))!=null,"Rendered wide view never cuts away the foreground ground")
 scene.queue_free()
 await process_frame
 print("VISUAL VALLEY: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
