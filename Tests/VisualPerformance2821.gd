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
 var game=root.get_node("Game");game.set_process(false);game.state=game.initial_state()
 var models=load("res://Buildings/Models.gd");var optimizer=load("res://Components/StaticPaintBatch.gd")
 var viewport=SubViewport.new();viewport.size=Vector2i(256,192);viewport.own_world_3d=true;viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(viewport)
 var light=DirectionalLight3D.new();light.rotation_degrees=Vector3(-48,-25,0);viewport.add_child(light)
 var camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=8;camera.position=Vector3(8,9,12);viewport.add_child(camera);camera.look_at(Vector3.ZERO)
 var fixture=Node3D.new();viewport.add_child(fixture)
 for entry in [[Color("278f98"),-1.3],[Color("d97843"),1.3]]:models.box(fixture,Vector3(2,3,2),Vector3(entry[1],0,0),entry[0])
 models.bake(fixture)
 await settle()
 var first=viewport.get_texture().get_image()
 optimizer.reduce(fixture)
 await settle()
 var second=viewport.get_texture().get_image()
 var error=0.0;var colored=0
 for y in first.get_height():
  for x in first.get_width():
   var a=first.get_pixel(x,y);var b=second.get_pixel(x,y)
   error+=absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b)
   if a.g>0.05 or a.r>0.05:colored+=1
 var mean_error=error/(first.get_width()*first.get_height()*3)
 check(colored>500,"The color comparison renders actual illuminated geometry")
 check(mean_error<0.001,"Static batching preserves actual rendered colors, lighting and silhouette (mean RGB error below 0.1%)")
 check(fixture.get_child_count()==1,"The rendered multi-color fixture uses one actual draw mesh")
 viewport.queue_free();await process_frame
 var s=game.state
 s.tutorial=5;s.onboarding.active=false;s.city_services.enabled=false;s.companion_enabled=false
 s.buildings.append({"kind":"central_depot","level":1,"position":[44,20]})
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.life.set_process(false);scene.hud.ux.set_process(false)
 var before=s.duplicate(true);var valley=scene.landscape
 for quality in [1,0]:
  s.quality=quality;valley._process(0)
  for point in [Vector3(0,0,20),Vector3(16,0,20),Vector3(32,0,20),Vector3(-45,0,-115)]:
   scene.focus=point;scene.zoom=100;scene.set_camera();await settle()
   var correct=true
   for kind in valley.batches:
    var data=valley.batches[kind]
    for index in data.entries.size():
     var actual=data.mesh.get_instance_transform(index)
     var cached=data.entries[index].render_transform
     if actual.origin.distance_to(cached.origin)>0.001 or actual.basis.get_scale().distance_to(cached.basis.get_scale())>0.001:correct=false
     var color=data.mesh.get_instance_color(index)
     var expected=Color.WHITE if kind=="trunk" else data.entries[index].color
     if absf(color.r-expected.r)+absf(color.g-expected.g)+absf(color.b-expected.b)>0.02:correct=false
   check(correct,"Actual GPU instance slots match their cached positions, blocked scales and colors after camera movement")
 s.quality=before.quality;valley._process(0)
 scene.focus=Vector3(0,0,20);scene.zoom=135;scene.set_camera();await settle()
 check(not scene.world_buildings.find_children("*","MeshInstance3D",true,false).filter(func(node):return node.get_meta("static_paint_optimized",false)).is_empty(),"The existing main world actually uses the new paint batching")
 var mill=scene.world_buildings.get_children().filter(func(node):return node.get_meta("kind","")=="sawmill")[0]
 check(mill.has_node("Processing") and mill.has_node("YardHandling") and mill.has_node("InputStock") and mill.has_node("OutputStock"),"Real machine, forklift and inventory attachment nodes survive batching")
 check(s==before,"Rendered movement and batching do not change the saved company or warehouse stock")
 root.get_texture().get_image().save_png("/workspace/timber2821-performance.png")
 print("VISUAL PERFORMANCE 2821: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
