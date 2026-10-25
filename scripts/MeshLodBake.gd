extends RefCounted
var meshes={}
var lod_surfaces=0
var sources=[]
func apply(node: Node) -> void:
 if node is MeshInstance3D and node.mesh is ArrayMesh and not node.mesh.resource_path.begins_with("res://Assets/Baked/"):
  var original=node.mesh
  var id=original.get_instance_id()
  if not meshes.has(id):
   sources.append(original)
   var imported=ImporterMesh.new()
   for surface in original.get_surface_count():
    imported.add_surface(original.surface_get_primitive_type(surface),original.surface_get_arrays(surface),[],{},original.surface_get_material(surface))
   imported.generate_lods(60.0,25.0,[])
   for surface in imported.get_surface_count():lod_surfaces+=imported.get_surface_lod_count(surface)
   meshes[id]=imported.get_mesh()
  node.mesh=meshes[id]
 for child in node.get_children():apply(child)
