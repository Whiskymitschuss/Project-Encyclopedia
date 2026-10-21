extends Node3D
var smoke: CPUParticles3D
func _ready() -> void:
 smoke=FeedbackFX.emitter("smoke",7)
 smoke.name="ChimneyPuffs"
 add_child(smoke)
func _process(_delta: float) -> void:
 var count=3 if Game.state.quality==0 else 7
 if smoke.amount!=count: smoke.amount=count
 smoke.emitting=FeedbackFX.allowed(self)
 smoke.visible=smoke.emitting
