extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func settle() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func tap(button: Button) -> void:
 var at=root.get_screen_transform()*button.get_global_rect().get_center()
 var touch=InputEventScreenTouch.new()
 touch.position=at
 touch.pressed=true
 Input.parse_input_event(touch)
 await process_frame
 touch=InputEventScreenTouch.new()
 touch.position=at
 touch.pressed=false
 Input.parse_input_event(touch)
 await settle()
func find_button(node: Node,title: String) -> Button:
 for button in node.find_children("*","Button",true,false):
  if button.text.begins_with(title): return button
 return null
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.city_services.enabled=false
 game.state.time=11
 game.flow.clear()
 root.size=Vector2i(540,960)
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await settle()
 scene.set_process(false)
 scene.wet_weather.set_process(false)
 scene.fauna.set_process(false)
 var hud=scene.hud
 var before=game.state.duplicate(true)
 scene.focus=Catalog.biome_position(0)
 scene.zoom=65
 scene.set_camera()
 scene.on_harvested(0,1)
 await settle()
 var cut=-1
 for i in scene.trees[0].size():
  if scene.trees[0][i].regrow>0: cut=i; break
 check(cut>=0,"A real forest cut is staged for render checks")
 var transform=scene.stump_batches[0].multimesh.get_instance_transform(cut)
 check(transform.basis.get_scale().x>0.5 and transform.origin.distance_to(scene.trees[0][cut].point)<1,"The visible stump occupies the cut tree's actual position")
 scene.trees[0][cut].regrow=0
 scene.set_tree_visible(0,cut,true)
 await settle()
 check(scene.stump_batches[0].multimesh.get_instance_transform(cut).basis.get_scale().x<0.01,"Actual rendered regrowth removes its stump")
 check(game.state==before,"Rendering a cut or regrowth never grants free wood")
 scene.fauna.on_cut(0,1)
 scene.fauna._process(0.2)
 var bird=scene.fauna.animals[0]
 var wing=bird.node.get_node("WingLeft").rotation.z
 scene.fauna._process(0.15)
 check(wing!=bird.node.get_node("WingLeft").rotation.z,"Visible birds flap during their harvest reaction")
 root.get_texture().get_image().save_png("/workspace/timber-detail26-forest.png")
 scene.focus=game.building_position(1)
 scene.zoom=100
 scene.set_camera()
 scene.wet_weather._process(30)
 await settle()
 var dry=root.get_texture().get_image()
 game.state.weather=2
 before=game.state.duplicate(true)
 scene.wet_weather._process(5)
 await settle()
 var rain=root.get_texture().get_image()
 check(rain.get_data()!=dry.get_data(),"Rain changes the actual rendered surfaces")
 check(scene.wet_weather.puddles.multimesh.get_instance_transform(0).origin.y>0.9,"Rendered puddles sit above the road")
 check(game.state==before,"Wet rendering never changes real production or weather state")
 rain.save_png("/workspace/timber-detail26-rain.png")
 # Touch the public menu entry, then exercise every photo control on phone/tablet.
 hud.open_menu("more")
 await settle()
 await tap(find_button(hud.contents,"Hilfe"))
 var entry=find_button(hud.contents,"Fotomodus")
 check(entry!=null,"The photo mode has a discoverable public menu entry")
 if entry==null: scene.queue_free(); await process_frame; quit(1); return
 # Scroll the actual touch container to the entry before tapping.
 hud.scroll.scroll_vertical=int(entry.position.y+entry.get_parent().position.y)
 await settle()
 entry.grab_focus()
 hud.scroll.ensure_control_visible(entry)
 await settle()
 await tap(entry)
 check(scene.photo.active and not hud.visible,"A real finger tap enters photo mode")
 var photo=scene.photo
 var expected_mask=scene.camera.cull_mask
 for resolution in [Vector2i(360,640),Vector2i(540,960),Vector2i(1280,800)]:
  root.size=resolution
  await settle()
  var rect=photo.toolbar.get_global_rect()
  check(rect.position.x>=0 and rect.end.x<=photo.root_control.size.x+1 and rect.end.y<=photo.root_control.size.y,"Photo controls remain on screen at %s" % resolution)
  var transform_scale=root.get_screen_transform()
  check(absf(transform_scale.x.length()-transform_scale.y.length())<0.001,"Photo view keeps its aspect ratio at %s" % resolution)
 var old_scale=root.content_scale_size
 root.content_scale_size=Vector2i.ZERO
 root.size=Vector2i(360,640)
 game.state.ux.large_text=true
 hud.ux.apply_fonts(photo.root_control)
 photo.layout()
 await settle()
 check(photo.toolbar.get_global_rect().end.x<=360 and photo.toolbar.get_global_rect().position.x>=0,"Photo toolbar fits a truly 360-pixel logical viewport with large text")
 for button in photo.toolbar.find_children("*","Button",true,false):
  check(button.get_global_rect().end.x<=360 and button.get_global_rect().position.x>=0,"Every photo action remains reachable with large text")
 game.state.ux.large_text=false
 hud.ux.apply_fonts(photo.root_control)
 root.content_scale_size=old_scale
 root.size=Vector2i(540,960)
 await settle()
 var right=find_button(photo.toolbar,"Rechts")
 await tap(right)
 for i in 40: scene.update_camera(0.016)
 check(scene.camera_yaw>0.5 and scene.camera.cull_mask==expected_mask,"A real camera-angle tap changes the view without restoring labels")
 before=game.state.duplicate(true)
 var capture=find_button(photo.toolbar,"Aufnehmen")
 await tap(capture)
 for i in 60:
  if not photo.busy: break
  await process_frame
 check(not photo.last_path.is_empty() and FileAccess.file_exists(photo.last_path),"A real shutter tap writes a PNG into the temporary profile")
 if photo.last_path.is_empty(): scene.queue_free(); await process_frame; quit(1); return
 var saved_image=Image.load_from_file(photo.last_path)
 check(saved_image!=null and saved_image.get_size()==root.get_texture().get_image().get_size(),"Saved photo contains the actual full-resolution viewport")
 check(saved_image.get_pixel(270,900).v>0.25,"Photo readback excludes its dark shutter toolbar")
 check(game.state==before,"Capturing photos does not spend currency, chop trees or change the save")
 photo.open_gallery()
 await settle()
 check(photo.paths.has(photo.last_path) and photo.image_view.texture!=null,"The in-game gallery actually loads the saved PNG")
 root.get_texture().get_image().save_png("/workspace/timber-detail26-gallery.png")
 await tap(find_button(photo.gallery,"Zurück"))
 await tap(find_button(photo.toolbar,"Fertig"))
 check(not photo.active and hud.visible,"A real finish tap restores normal game controls")
 # Start a real incident, listen from the viewed ground and stop all loops on mute.
 game.state.homes=[{"kind":"house","level":1,"plot":0,"position":[-24,86],"rent_bank":0}]
 CityServices.ignite(game.state,{"type":"home","index":0})
 game.step(1)
 var mission=game.state.city_services.missions[0]
 scene.focus=LogisticsRoutes.vector(mission.outward[0])
 scene.zoom=75
 scene.set_camera()
 scene.spatial_audio._process(0)
 check(scene.spatial_audio.loops[0].playing,"Approaching real fire engine starts a positional siren")
 check(scene.spatial_audio.listener.position.distance_to(scene.view_focus)<11,"High camera elevation does not silence nearby audio")
 mission.age=float(mission.drive)+1
 scene.spatial_audio._process(0)
 check(not scene.spatial_audio.loops[0].playing,"The siren stops once the actual engine arrives")
 scene.focus=Vector3(-24,0,86)
 scene.set_camera()
 scene.spatial_audio._process(0)
 check(scene.spatial_audio.loops[2].playing and scene.spatial_audio.loops[3].playing,"A real on-site operation plays fire and water loops")
 game.state.muted=true
 scene.spatial_audio._process(0)
 var playing=0
 for player in scene.spatial_audio.loops+scene.spatial_audio.voices:
  if player.playing: playing+=1
 check(playing==0,"Mute immediately stops all world audio voices")
 scene.queue_free()
 await process_frame
 print("VISUAL PRESENTATION 26: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
