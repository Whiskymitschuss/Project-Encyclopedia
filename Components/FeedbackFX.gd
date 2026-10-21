class_name FeedbackFX
extends RefCounted
# Small, fixed CPU emitters work with the Android GL compatibility renderer.
static func emitter(kind: String, amount: int=12, once: bool=false) -> CPUParticles3D:
 var p=CPUParticles3D.new()
 p.emitting=false
 p.amount=amount
 p.one_shot=once
 p.explosiveness=0.85 if once else 0.0
 p.lifetime=2.8 if kind in ["smoke","steam"] else 1.1
 p.direction=Vector3.UP
 p.spread=24 if kind in ["smoke","steam"] else 65
 p.initial_velocity_min=1.3 if kind in ["smoke","steam"] else 2.8
 p.initial_velocity_max=2.7 if kind in ["smoke","steam"] else 5.0
 p.gravity=Vector3(0,0.3,0) if kind in ["smoke","steam","spark"] else Vector3(0,-7,0)
 p.scale_amount_min=0.25
 p.scale_amount_max=0.65 if kind in ["smoke","steam"] else 0.4
 p.angular_velocity_min=-65
 p.angular_velocity_max=65
 var tone={"smoke":Color("aebbb8"),"steam":Color("e6f1ec"),"dust":Color("d6bd93"),"chips":Color("e7bc7a"),"spark":Color("ffc75e"),"coin":Color("f5c263"),"water":Color("c2eaf3")}.get(kind,Color.WHITE)
 var gradient=Gradient.new()
 gradient.set_color(0,Color(tone.r,tone.g,tone.b,0.65 if kind in ["smoke","steam","dust"] else 1))
 gradient.set_color(1,Color(tone.r,tone.g,tone.b,0))
 p.color_ramp=gradient
 var material=StandardMaterial3D.new()
 material.vertex_color_use_as_albedo=true
 material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 material.roughness=0.8
 if kind=="spark":
  material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 if kind in ["smoke","steam","water","dust"]:
  var mesh=SphereMesh.new()
  mesh.radial_segments=6
  mesh.rings=3
  mesh.radius=1.0 if kind in ["smoke","steam"] else 0.4
  mesh.height=mesh.radius*2
  p.mesh=mesh
 elif kind=="coin":
  var mesh=CylinderMesh.new()
  mesh.top_radius=0.65
  mesh.bottom_radius=0.65
  mesh.height=0.16
  mesh.radial_segments=8
  p.mesh=mesh
 else:
  var mesh=BoxMesh.new()
  mesh.size=Vector3(0.35,0.2,0.5)
  p.mesh=mesh
 p.material_override=material
 p.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 return p

static func allowed(node: Node3D) -> bool:
 if not Game.state.ambient_enabled or not Game.state.ux.motion: return false
 var camera=node.get_viewport().get_camera_3d()
 return camera==null or (not camera.is_position_behind(node.global_position) and camera.global_position.distance_to(node.global_position)<240)
