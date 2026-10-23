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
 var before=game.snapshot()
 var models=load("res://Buildings/Models.gd")
 for kind in ["central_depot","express","quarry","stoneworks"]:
  var fingerprints={}
  for level in range(1,11):
   var model=models.building(kind,level)
   var architecture=model.get_node("Architecture")
   check(architecture.get_child_count()==level and model.get_meta("evolution_level")==level,"Every completed upgrade selects its architecture: %s/%s" % [kind,level])
   var within=true
   var signature=[]
   for mesh in architecture.find_children("*","MeshInstance3D",true,false):
    var transform=mesh.transform
    var parent=mesh.get_parent()
    while parent!=model:
     transform=parent.transform*transform
     parent=parent.get_parent()
    var bounds=transform*mesh.get_aabb()
    var half=15.5 if kind=="central_depot" else 9.5
    within=within and bounds.position.x>= -half-0.01 and bounds.end.x<=half+0.01 and bounds.position.z>= -11.51 and bounds.end.z<=11.51
    if mesh.mesh is ArrayMesh:
     for surface in mesh.mesh.get_surface_count(): signature.append(hash(mesh.mesh.surface_get_arrays(surface)))
   check(within,"Infrastructure additions retain the saved plot and neighbouring road clearance: %s/%s" % [kind,level])
   var fingerprint=hash(signature)
   check(not fingerprints.has(fingerprint),"A completed level adds actual geometry beyond a recolour or uniform scale: %s/%s" % [kind,level])
   fingerprints[fingerprint]=true
   check(model.has_node("Connections/VehicleEntry") and model.has_node("Connections/Loading") and model.has_node("Connections/Unloading") and model.has_node("Connections/Worker"),"Infrastructure exposes reusable work and logistics anchors: %s/%s" % [kind,level])
   model.free()
 before.last_seen=0
 var after=game.snapshot()
 after.last_seen=0
 check(before==after,"All infrastructure stages render without changing progress, inventories or freight")
 print("INFRASTRUCTURE 286: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
