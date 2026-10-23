class_name PresentationBudget
extends RefCounted

static func detailed(node: Node3D) -> bool:
 var camera=node.get_viewport().get_camera_3d()
 if camera==null: return true
 if camera.projection==Camera3D.PROJECTION_ORTHOGONAL and camera.size>280: return false
 var point=node.global_position+Vector3.UP*3
 if camera.is_position_behind(point): return false
 return node.get_viewport().get_visible_rect().grow(100).has_point(camera.unproject_position(point))
