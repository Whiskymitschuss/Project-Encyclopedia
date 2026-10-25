extends Node3D

# Animation skeleton shared by every occupation, pedestrian and seated driver.
# Economy, routing and job state remain owned by the existing controllers.
@export var seated=false
var clock=0.0
var presentation_delta=0.0
var arms: Array=[]
var head: Node3D
var tail: Node3D
var steering: Node3D
var eyes: Array=[]

func _ready() -> void:
 head=get_node("Head")
 tail=get_node("Tail")
 steering=get_node_or_null("Steering")
 arms=[get_node("LeftArm"),get_node("RightArm")]
 eyes=[head.get_node("EyeLeft"),head.get_node("EyeRight")]
 clock=float(get_meta("variant_id",0))*0.67

func _process(delta: float) -> void:
 if not Game.state.ux.motion or not is_visible_in_tree(): return
 presentation_delta+=delta
 if presentation_delta<PresentationBudget.animation_interval(self):return
 delta=presentation_delta;presentation_delta=0.0
 clock+=delta
 tail.rotation.y=sin(clock*2.2)*0.07
 head.rotation.y=sin(clock*0.85)*0.08
 head.rotation.z=sin(clock*1.7)*0.025
 for eye in eyes: eye.scale.y=0.12 if fposmod(clock,5.3)>5.17 else 1.0
 if seated:
  var turn=sin(clock*0.6)*0.08
  if steering!=null: steering.rotation.z=turn
  arms[0].rotation.z=-turn
  arms[1].rotation.z=-turn
