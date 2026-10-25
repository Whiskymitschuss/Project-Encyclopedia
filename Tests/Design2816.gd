extends SceneTree
var checks=0
var failures=[]
var models
var architecture
var style
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message);printerr("FAILED: ",message)
func bound(mesh: MeshInstance3D,root: Node3D) -> AABB:
 var transform=mesh.transform
 var parent=mesh.get_parent()
 while parent!=root:
  transform=parent.transform*transform
  parent=parent.get_parent()
 return transform*mesh.get_aabb()
func run() -> void:
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 models=load("res://Buildings/Models.gd")
 architecture=load("res://Buildings/TycoonArchitecture.gd")
 style=load("res://art/TycoonStyle.gd")
 game.state=game.initial_state()
 var before=game.state.duplicate(true)
 # Batched materials must survive another batch, including every surface.
 var fixture=Node3D.new()
 var nested=Node3D.new();fixture.add_child(nested)
 models.box(nested,Vector3.ONE,Vector3.ZERO,style.TEAL)
 models.box(nested,Vector3.ONE,Vector3(2,0,0),style.COPPER)
 models.bake(nested)
 architecture.bake_static(fixture)
 var colors=[]
 for mesh in fixture.find_children("*","MeshInstance3D",true,false):
  for surface in mesh.mesh.get_surface_count():
   var material=mesh.mesh.surface_get_material(surface)
   if material!=null: colors.append(material.albedo_color)
 check(style.TEAL in colors and style.COPPER in colors,"Flattening and batching preserve both actual painted surfaces instead of grey unbound meshes")
 fixture.free()
 for kind in Catalog.BUILDINGS:
  for level in [1,5,10]:
   var model=models.building(kind,level)
   check(model.get_meta("design_version",0)==2816,"Current shared art direction reaches %s/%s" % [kind,level])
   var shell=model.get_node_or_null("TycoonHall")
   if shell!=null:
    var fits=true
    var painted=true
    var width=15.5 if kind=="central_depot" else 9.5
    for mesh in shell.find_children("*","MeshInstance3D",true,false):
     var bounds=bound(mesh,model)
     fits=fits and bounds.position.x>=-width-0.01 and bounds.end.x<=width+0.01 and bounds.position.z>=-11.51 and bounds.end.z<=11.51
     for index in mesh.mesh.get_surface_count():
      painted=painted and (mesh.material_override!=null or mesh.mesh.surface_get_material(index)!=null)
    check(fits,"New architectural shell remains inside the existing parcel: %s/%s" % [kind,level])
    check(painted,"All newly batched shell surfaces retain a real material: %s/%s" % [kind,level])
   if Catalog.RECIPES.has(kind):
    check(model.has_node("Processing") and model.has_node("InputStock") and model.has_node("OutputStock") and model.has_node("YardHandling"),"New shells retain the actual processing and logistics nodes: %s/%s" % [kind,level])
   model.free()
 var signatures=[]
 for level in range(1,11):
  var model=models.building("townhall",level,true)
  var shell=model.get_node("CivicArchitecture")
  var signature=[]
  for mesh in shell.find_children("*","MeshInstance3D",true,false):
   for surface in mesh.mesh.get_surface_count(): signature.append(hash(mesh.mesh.surface_get_arrays(surface)))
  var fingerprint=hash(signature)
  check(fingerprint not in signatures,"Town hall stage %s has its own actual architecture" % level)
  signatures.append(fingerprint);model.free()
 var body=Node3D.new()
 check(models.soft_box(body,Vector3(2,1,4),Vector3.ZERO,style.BLUE).mesh is ArrayMesh,"Vehicle body helper uses cached beveled geometry")
 body.free()
 # Free the standalone body and its temporary owner explicitly.
 # The material/mesh tests above never touch authoritative company state.
 check(game.state==before,"Design generation cannot alter company state, stock, currency or saved progress")
 print("DESIGN 2816: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
