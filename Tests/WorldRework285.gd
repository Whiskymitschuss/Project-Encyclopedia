extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 var models=load("res://Buildings/Models.gd")
 var paths=load("res://logistics/YardRoutes.gd")
 var before=game.state.duplicate(true)
 for kind in Catalog.BUILDINGS:
  var supported=kind not in ["quarry","stoneworks","central_depot","express"]
  for level in range(1,11):
   var model=models.building(kind,level)
   check(model!=null,"Existing building loads at level %s: %s" % [level,kind])
   if supported:
    var architecture=model.get_node_or_null("Architecture")
    check(architecture!=null and architecture.get_child_count()==level,"Each completed stage adds an architectural module: %s/%s" % [kind,level])
    check(model.get_meta("evolution_level")==level and model.has_node("Connections/Loading") and model.has_node("Connections/Worker"),"Completed levels and connection markers are present: %s/%s" % [kind,level])
    var extent=9.5
    var bounded=true
    for mesh in architecture.find_children("*","MeshInstance3D",true,false):
     var bounds=mesh.get_aabb()
     var t=mesh.transform
     var parent=mesh.get_parent()
     while parent!=model:
      t=parent.transform*t
      parent=parent.get_parent()
     bounds=t*bounds
     bounded=bounded and bounds.position.x>= -extent-0.01 and bounds.end.x<=extent+0.01 and bounds.position.z>= -11.5 and bounds.end.z<=11.5
    check(bounded,"Upgraded architecture stays inside the saved reserved plot: %s/%s" % [kind,level])
   model.free()
 for pair in [[Vector3(8,0.6,8),Vector3(-6.3,0.6,-4.5)],[Vector3(-6.3,0.6,-4.5),Vector3(6.3,0.6,5.5)],[Vector3(0,0.6,-10),Vector3(8,0.6,8)]]:
  var path=paths.route(pair[0],pair[1])
  check(path[0]==pair[0] and path[-1]==pair[1],"Aisle routing keeps actual stock and parking endpoints")
  for step in 101:
   var sample=paths.sample(path,step/100.0)
   var p=sample.position
   check(not Rect2(-3.6,-6.8,7.2,15.5).has_point(Vector2(p.x,p.z)),"Forklift route avoids the entire central production line")
 check(game.state==before,"Generating every existing stage and dock path never changes saves or inventory")
 print("WORLD REWORK 285: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
