extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func settle() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var worker_script=load("res://NPCs/Worker.gd")
 var game=root.get_node("Game");game.set_process(false)
 root.get_node("RuntimeStats").set_process(false)
 game.state=game.initial_state();var s=game.state
 s.workers=6;s.tutorial=5;s.construction_intro=true;s.city_services.enabled=false;s.companion_enabled=false;s.auto_export=false
 root.size=Vector2i(591,1280);root.content_scale_size=root.size
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene)
 scene.set_process(false);scene.life.set_process(false);scene.hud.ux.set_process(false);scene.forest_world.set_process(false)
 scene.sync_actors()
 var workers=[]
 for actor in scene.actors.get_children():
  actor.set_process(false)
  if actor.get_script()==worker_script and actor.role=="forester": workers.append(actor)
 check(workers.size()>=2,"The main world retains actual hired forest beavers")
 if workers.is_empty(): scene.queue_free();await process_frame;quit(1);return
 var center=Catalog.biome_position(0)
 var forbidden=Rect2(center.x-33,center.z+30,63,2)
 var yard=scene.base_streets.get_node("OpenProductionYard")
 var blocked=false
 for mesh in yard.find_children("*","MeshInstance3D",true,false):
  for surface in mesh.mesh.get_surface_count():
   for vertex in mesh.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]:
    var point=mesh.transform*vertex
    if point.y>1.0 and forbidden.has_point(Vector2(point.x,point.z)): blocked=true
 check(not blocked,"No fence, post or raised barrier remains across the forest working front")
 scene.focus=center+Vector3(0,0,24);scene.zoom=78;scene.set_camera()
 game.step(1)
 var before=s.duplicate(true)
 for worker in workers:
  worker.phase=0;worker.work_left=0;worker._process(0.1)
  for frame in 300:
   if worker.forest_relocation.is_empty(): break
   worker._process(0.1)
  worker._process(0.1)
  check(worker.working and worker.axe.visible and worker.position.distance_to(ForestLayout.point(0,worker.forest_cell))<3.5,"The axe actually swings at a reachable tree inside the main-world forest")
  for phase in [4.0,6.0,8.0,12.0,16.0]:
   worker.phase=phase;worker.work_left=20;worker._process(0.1)
   var point=worker.position
   check(point.x>=center.x-32 and point.x<=center.x+35 and point.z<=center.z+40,"Carrying and empty return stay on the reserved forest aisles and apron")
 check(s==before,"Axe, walking and carried logs cannot create or spend any inventory")
 for worker in workers: worker.phase=0;worker.work_left=20;worker._process(0.1)
 scene.hud.update_stats()
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber2813-working-forest.png")
 # Consuming the current target starts a continuous empty move to the next tree.
 var worker=workers[0]
 var cell=str(worker.forest_cell)
 if not s.forest.stands.has("0"): s.forest.stands["0"]={"cursor":90,"cells":{}}
 s.forest.stands["0"].cells[cell]={"state":"stump","wood":0.0}
 var old=worker.position;worker.phase=18;worker.work_left=0
 game.flow={"harvest":1,"harvest:0":1}
 before=s.duplicate(true);worker._process(0.1)
 check(not worker.forest_relocation.is_empty() and not worker.axe.visible and worker.position.distance_to(old)<=0.61,"A new tree requires a continuous empty walk, not a teleport or chopping at the old stump")
 for frame in 1200:
  if worker.forest_relocation.is_empty(): break
  worker._process(0.1)
 worker._process(0.1)
 check(worker.working and worker.forest_cell!=int(cell),"The beaver reaches the next standing tree and resumes its earned work")
 check(s==before,"Changing the visible work tree never changes the authoritative harvest ledger")
 s.buildings.append({"kind":"central_depot","level":1,"paused":false,"position":[44,20]})
 CentralLogistics.stock(s,0).wood=72;game.flow={"harvest":0}
 for frame in 600:
  for actor in workers: actor._process(0.1)
 scene.forest_world.update_work_status();scene.hud.update_stats();await settle()
 check(scene.forest_world.work_status.text=="Wartet auf Holzabholung","The real forest shows why the actual full collection point is waiting")
 root.get_texture().get_image().save_png("/workspace/timber2813-waiting-forest.png")
 scene.queue_free();await process_frame
 print("VISUAL FOREST ACCESS 2813: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
