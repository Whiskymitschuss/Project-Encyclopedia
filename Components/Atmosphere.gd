class_name Atmosphere
extends RefCounted

# A single deterministic visual wind; no new saved weather or simulation values.
static func wind(state: Dictionary) -> Vector3:
 var angle=-0.45+sin(float(state.elapsed)/180.0)*0.3
 var strength=1.8 if int(state.weather)==2 else 1.0
 return Vector3(cos(angle),0,sin(angle))*strength

static func drift(p: CPUParticles3D, state: Dictionary) -> void:
 var inverse=p.global_basis.inverse()
 p.direction=inverse*(Vector3.UP+wind(state)*0.45).normalized()
 p.gravity=inverse*(Vector3.UP*0.3+wind(state)*0.35)
