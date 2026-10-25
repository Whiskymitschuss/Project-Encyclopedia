class_name Atmosphere
extends RefCounted

# Weather is disabled. Production steam may rise, without weather-driven drift.
static func wind(_state: Dictionary) -> Vector3:
 return Vector3.ZERO

static func drift(p: CPUParticles3D, state: Dictionary) -> void:
 var inverse=p.global_basis.inverse()
 p.direction=inverse*(Vector3.UP+wind(state)*0.45).normalized()
 p.gravity=inverse*(Vector3.UP*0.3+wind(state)*0.35)
