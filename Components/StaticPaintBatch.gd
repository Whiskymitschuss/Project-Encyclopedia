class_name StaticPaintBatch
extends RefCounted

# Only geometry emitted by Models.bake is eligible. Named machine parts,
# moving parents, inventory holders, collision bodies and textured/wet/glowing
# materials keep their own nodes and shading. No simulation state is consulted.
static var palettes={}
static var merged_surfaces=0
static var output_batches=0

static func eligible(material: Material) -> bool:
 return material is StandardMaterial3D and material.get_meta("static_paint",false) and not material.vertex_color_use_as_albedo and material.albedo_texture==null and not material.emission_enabled and material.transparency==BaseMaterial3D.TRANSPARENCY_DISABLED and material.albedo_color.a>=0.999

static func reduce(root: Node3D) -> void:
 for child in root.get_children():
  if child is Node3D and not child is MeshInstance3D: reduce(child)
 var groups={}
 for child in root.get_children():
  if not child is MeshInstance3D or not child.get_meta("static_paint_batch",false): continue
  if child.mesh==null or child.mesh.get_surface_count()!=1: continue
  var material=child.material_override if child.material_override!=null else child.mesh.surface_get_material(0)
  if not eligible(material): continue
  var key=[material.roughness,material.metallic,material.shading_mode,material.cull_mode,child.layers,child.cast_shadow,child.visible,child.visibility_range_begin,child.visibility_range_end]
  if not groups.has(key): groups[key]=[]
  groups[key].append({"node":child,"material":material})
 for key in groups:
  var entries=groups[key]
  if entries.size()<2: continue
  var source=entries[0].material
  var paint_key=[source.roughness,source.metallic,source.shading_mode,source.cull_mode]
  if not palettes.has(paint_key):
   var paint=source.duplicate()
   paint.albedo_color=Color.WHITE
   paint.vertex_color_use_as_albedo=true
   paint.vertex_color_is_srgb=true
   palettes[paint_key]=paint
  var builder=SurfaceTool.new()
  builder.begin(Mesh.PRIMITIVE_TRIANGLES)
  builder.set_material(palettes[paint_key])
  for entry in entries:
   var node=entry.node
   var arrays=node.mesh.surface_get_arrays(0)
   var colors=PackedColorArray()
   colors.resize(arrays[Mesh.ARRAY_VERTEX].size())
   colors.fill(entry.material.albedo_color)
   arrays[Mesh.ARRAY_COLOR]=colors
   var colored=ArrayMesh.new()
   colored.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
   builder.append_from(colored,0,node.transform)
  var mesh=MeshInstance3D.new()
  mesh.mesh=builder.commit()
  mesh.set_meta("static_paint_optimized",true)
  mesh.layers=entries[0].node.layers
  mesh.cast_shadow=entries[0].node.cast_shadow
  mesh.visible=entries[0].node.visible
  mesh.visibility_range_begin=entries[0].node.visibility_range_begin
  mesh.visibility_range_end=entries[0].node.visibility_range_end
  root.add_child(mesh)
  for entry in entries:
   root.remove_child(entry.node)
   entry.node.free()
  merged_surfaces+=entries.size()
  output_batches+=1
