class_name WoodYard
extends RefCounted

const INPUT=Color("3bafbe")
const OUTPUT=Color("e7ad43")
const PALE=Color("fff1ce")
static var meshes={}

static func bay(root: Node3D,at: Vector3,color: Color) -> void:
 for x in [-1.8,1.8]: Models.box(root,Vector3(0.12,0.025,5.5),at+Vector3(x,0.59,0),color)
 for z in [-2.75,2.75]: Models.box(root,Vector3(3.7,0.025,0.12),at+Vector3(0,0.59,z),color)
 # Pallet feet and end stops, clear of the perimeter forklift aisle.
 for x in [-1.5,1.5]: Models.box(root,Vector3(0.18,0.25,0.5),at+Vector3(x,0.72,-2.5),PALE)

static func decorate(root: Node3D,kind: String) -> void:
 var details=Node3D.new()
 details.name="WoodYard"
 root.add_child(details)
 if meshes.has(kind):
  for entry in meshes[kind]:
   var mesh=MeshInstance3D.new()
   mesh.mesh=entry.mesh
   mesh.material_override=entry.material
   details.add_child(mesh)
  return
 if kind=="sawmill":
  bay(details,Vector3(-6.3,0,-4.5),INPUT)
  bay(details,Vector3(6.3,0,5.5),OUTPUT)
  # Overhead saw guard leaves the blade, input and product visible.
  for x in [-2.05,2.05]:
   Models.box(details,Vector3(0.15,1.2,2.3),Vector3(x,3.5,0),PALE)
  Models.box(details,Vector3(4.25,0.16,2.3),Vector3(0,4.12,0),Color("36a8aa"))
  for x in [-0.8,0,0.8]:
   var arrow=Models.box(details,Vector3(0.12,0.025,0.8),Vector3(x,0.61,8.9),OUTPUT)
   arrow.rotation.y=-0.6
 elif kind=="station":
  bay(details,Vector3(-5.5,0,3),OUTPUT)
  for z in [-5.5,-2.5]:
   for x in [-6.7,-4.3]: Models.cylinder(details,0.13,1.4,Vector3(x,1.25,z),Color("667e82"))
 elif kind in ["central_depot","express"]:
  var width=31 if kind=="central_depot" else 19
  bay(details,Vector3(-width/2.0+3,0,5),INPUT)
  bay(details,Vector3(width/2.0-3,0,5),OUTPUT)
 else:
  bay(details,Vector3(-6.3,0,-4.5),INPUT)
  bay(details,Vector3(6.3,0,5.5),OUTPUT)
 Models.bake(details)
 meshes[kind]=[]
 for child in details.get_children(): meshes[kind].append({"mesh":child.mesh,"material":child.material_override})
