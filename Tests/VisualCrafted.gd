extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func draw() -> void:
 for i in 4: await process_frame
 await RenderingServer.frame_post_draw
func shot(name_value: String) -> void:
 await draw()
 root.get_texture().get_image().save_png("/workspace/timber-crafted-"+name_value+".png")
 print("CRAFTED RENDER ",name_value," · draws ",RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)," · triangles ",RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME))
func run() -> void:
 await process_frame
 root.size=Vector2i(540,960)
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.companion_enabled=false
 game.state.city_services.enabled=false
 game.state.time=11.0
 var saved=game.state.duplicate(true)
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await draw()
 scene.set_process(false)
 scene._process(0)
 check(game.state==saved,"Rendering the new start quarter does not grant buildings or alter progress")
 check(scene.world_buildings.get_child_count()>=5,"The real starter economy still renders")
 check(scene.world_buildings.get_child(1).get_meta("crafted_version")==2,"The live sawmill uses the new architecture")
 var visible_decor=0
 for data in scene.landscape.batches.values(): visible_decor+=data.mesh.visible_instance_count
 check(visible_decor<scene.landscape.records.size(),"Close view sends only nearby decoration instances to the renderer")
 await shot("start")
 # This second scene is explicitly a staged art/interaction test profile.
 for i in 6:
  var kinds=["landhouse","apartments","shop","townhall","fire","clinic"]
  var position=Vector3([-45,-21,21][i%3],0,86+int(i/3.0)*32)
  game.state.homes.append({"kind":kinds[i],"level":[2,4,2,2,3,3][i],"plot":100 if i==3 else i,"position":[position.x,position.z],"rent_bank":0})
 scene.rebuild()
 scene.focus=Vector3(-14,0,101)
 scene.zoom=87
 scene.set_camera()
 await shot("town")
 var before=game.state.duplicate(true)
 scene.hud.ux.select_building(1,true)
 await draw()
 check(scene.hud.ux.sheet.visible and scene.hud.ux.sheet.get_global_rect().position.y>=scene.hud.mission_button.get_global_rect().end.y+4,"New houses retain the bounded building card below the compact HUD")
 check(game.state==before,"Selecting the detailed building does not change rent or construction")
 scene.hud.ux.hide_panels(true)
 game.state.time=23
 scene._process(0)
 await shot("night")
 check(SurfaceLibrary.last_night>=0.95,"Actual night state lights the new house windows")
 game.state.time=11
 scene._process(0)
 scene.focus=Vector3(-21,0,86)
 scene.zoom=38
 scene.set_camera()
 await shot("house")
 var model=null
 for item in scene.world_buildings.get_children():
  if item.has_meta("town_kind") and item.get_meta("town_kind")=="apartments": model=item
 check(model!=null and model.has_node("FrontageDetails"),"Close view renders real facade and frontage geometry")
 var image=root.get_texture().get_image()
 var colored=0
 for y in range(180,740,4):
  for x in range(20,520,4):
   var p=image.get_pixel(x,y)
   if maxf(p.r,maxf(p.g,p.b))-minf(p.r,minf(p.g,p.b))>0.12 and p.v>0.15: colored+=1
 check(colored>1500,"Actual rendered world contains colored geometry rather than a blank preview")
 scene.focus=Vector3(-43,0,-110)
 scene.zoom=94
 scene.set_camera()
 await shot("forest")
 check(scene.trees[1].size()==100,"Rounded trees remain part of the real working forest")
 var state_before_view=game.state.duplicate(true)
 scene.zoom=390
 scene.set_camera()
 for kind in ["pine","leaf"]:
  var data=scene.landscape.batches[kind]
  check(data.mesh.mesh==data.far and data.far.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()<data.near.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size(),"Overview selects genuinely simpler foliage geometry: "+kind)
 check(game.state==state_before_view,"Changing visual detail never changes the saved economy or active jobs")
 game.state.quality=0
 scene.landscape._process(0)
 check(scene.landscape.batches.pine.mesh.visible_instance_count<scene.landscape.batches.pine.mesh.instance_count,"Battery mode still reduces the new forest instances")
 scene.queue_free()
 await process_frame
 print("VISUAL CRAFTED WORLD: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
