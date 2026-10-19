extends SceneTree

var failures=[]
var checks=0
func check(ok: bool, detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 var before=game.state.duplicate(true)
 game.state=game.initial_state()
 game.state.tutorial=5
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 for i in 8: await process_frame
 await RenderingServer.frame_post_draw
 var icons=scene.hud.spatial_icons
 check(icons.find_world_3d()!=scene.get_world_3d(),"Icon lighting is isolated from the game world")
 var atlas=icons.get_texture().get_image()
 check(atlas!=null and atlas.get_size()==Vector2i(896,128),"3D icon atlas is actually rendered")
 if atlas!=null:
  for tile in 7:
   var occupied=0
   var colors={}
   for y in range(0,128,2):
    for x in range(tile*128,(tile+1)*128,2):
     var color=atlas.get_pixel(x,y)
     if color.a>0.5:
      occupied+=1
      colors[color.to_html(false)]=true
   check(occupied>100 and occupied<3600,"3D icon %s has a visible silhouette with transparent padding" % tile)
   check(colors.size()>8,"3D icon %s retains lit color and surface detail" % tile)
 var surface=load("res://UI/SculptedSurface.gd")
 var raised=surface.create(Color("197b87"))
 var pressed=surface.create(Color("197b87"),18,true)
 check(raised.texture.get_image().get_data()!=pressed.texture.get_image().get_data(),"Pressed button visibly changes its surface")
 check(raised.content_margin_top<pressed.content_margin_top,"Pressed controls move their content into the face")
 icons.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 check(icons.render_target_update_mode==SubViewport.UPDATE_ONCE,"3D symbols redraw after application resumes")
 scene.queue_free()
 game.state=before
 await process_frame
 print("VISUAL UI: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
