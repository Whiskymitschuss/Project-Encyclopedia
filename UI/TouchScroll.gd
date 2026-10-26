extends ScrollContainer

# Capture the gesture before child buttons consume it. A short touch is still
# delivered as a button tap; a drag never executes a catalogue purchase.
var pointer = -99
var start_point = Vector2.ZERO
var last_point = Vector2.ZERO
var dragged = false
var candidate: BaseButton
var velocity = 0.0
var scroll_position = 0.0
var last_ms = 0
var gestures = 0

func _ready() -> void:
 horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 vertical_scroll_mode=ScrollContainer.SCROLL_MODE_SHOW_NEVER
 scroll_deadzone=10
 mouse_filter=Control.MOUSE_FILTER_STOP

func find_button(node: Node, point: Vector2) -> BaseButton:
 for child in node.get_children():
  if not child is Control or not child.is_visible_in_tree(): continue
  var nested=find_button(child,point)
  if nested!=null: return nested
  if child is BaseButton and not child.disabled and child.get_global_rect().has_point(point): return child
 return null

func begin_gesture(id: int, point: Vector2) -> void:
 pointer=id
 start_point=point
 last_point=point
 dragged=false
 velocity=0
 scroll_position=float(scroll_vertical)
 last_ms=Time.get_ticks_msec()
 candidate=find_button(self,point)
 if is_instance_valid(candidate): candidate.set_pressed_no_signal(true)

func move_gesture(point: Vector2) -> void:
 var now=Time.get_ticks_msec()
 var dt=maxf(float(now-last_ms)/1000,0.016)
 if point.distance_to(start_point)>10: dragged=true
 if dragged:
  if is_instance_valid(candidate): candidate.set_pressed_no_signal(false)
  var amount=last_point.y-point.y
  scroll_position=clampf(scroll_position+amount,0,maxf(0,get_v_scroll_bar().max_value-get_v_scroll_bar().page))
  scroll_vertical=roundi(scroll_position)
  velocity=lerpf(velocity,clampf(amount/dt,-1800,1800),0.55)
 last_point=point
 last_ms=now

func end_gesture(point: Vector2, canceled: bool = false) -> void:
 var pressed=candidate
 if is_instance_valid(pressed): pressed.set_pressed_no_signal(false)
 var tap=not canceled and not dragged and start_point.distance_to(point)<=10
 if dragged: gestures+=1
 pointer=-99
 candidate=null
 if tap and is_instance_valid(pressed) and not pressed.disabled and pressed.get_global_rect().has_point(point):
  velocity=0
  pressed.pressed.emit()

func passes_to_child(node: Node,point: Vector2) -> bool:
 for child in node.get_children():
  if not child is Control or not child.is_visible_in_tree(): continue
  if (child.get_meta("gesture_passthrough",false) or child is LineEdit or child is TextEdit) and (child.get_global_rect().has_point(point) or child.get_meta("gesture_active",false)): return true
  if passes_to_child(child,point): return true
 return false

func _input(event: InputEvent) -> void:
 if pointer==-99 and (event is InputEventScreenTouch or event is InputEventScreenDrag or event is InputEventMouseButton or event is InputEventMouseMotion) and passes_to_child(self,event.position):
  velocity=0
  return
 if not is_visible_in_tree():
  if is_instance_valid(candidate): candidate.set_pressed_no_signal(false)
  pointer=-99
  velocity=0
  return
 if event is InputEventScreenTouch:
  if event.pressed and pointer==-99 and get_global_rect().has_point(event.position):
   begin_gesture(event.index,event.position)
   get_viewport().set_input_as_handled()
  elif event.index==pointer:
   get_viewport().set_input_as_handled()
   if not event.pressed: end_gesture(event.position,event.canceled)
 elif event is InputEventScreenDrag and event.index==pointer:
  move_gesture(event.position)
  get_viewport().set_input_as_handled()
 elif event is InputEventMouseButton or event is InputEventMouseMotion:
  if event.device==InputEvent.DEVICE_ID_EMULATION:
   if pointer!=-99 or get_global_rect().has_point(event.position): get_viewport().set_input_as_handled()
   return
  if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
   if event.pressed and pointer==-99 and get_global_rect().has_point(event.position):
    begin_gesture(-1,event.position)
    get_viewport().set_input_as_handled()
   elif not event.pressed and pointer==-1:
    get_viewport().set_input_as_handled()
    end_gesture(event.position)
  elif event is InputEventMouseMotion and pointer==-1:
   move_gesture(event.position)
   get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
 if pointer!=-99 or not is_visible_in_tree() or absf(velocity)<8: return
 scroll_position=clampf(scroll_position+velocity*minf(delta,0.05),0,maxf(0,get_v_scroll_bar().max_value-get_v_scroll_bar().page))
 scroll_vertical=roundi(scroll_position)
 velocity*=exp(-8*delta)
