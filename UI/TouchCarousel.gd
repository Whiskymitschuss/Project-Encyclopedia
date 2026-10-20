extends "res://UI/TouchScroll.gd"
func _ready() -> void:
 horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_SHOW_NEVER
 vertical_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 scroll_deadzone=10
 mouse_filter=Control.MOUSE_FILTER_STOP
func begin_gesture(id: int,point: Vector2) -> void:
 super.begin_gesture(id,point)
 scroll_position=float(scroll_horizontal)
func move_gesture(point: Vector2) -> void:
 var now=Time.get_ticks_msec()
 var dt=maxf(float(now-last_ms)/1000,0.016)
 if point.distance_to(start_point)>10: dragged=true
 if dragged:
  if is_instance_valid(candidate): candidate.set_pressed_no_signal(false)
  var amount=last_point.x-point.x
  scroll_position=clampf(scroll_position+amount,0,maxf(0,get_h_scroll_bar().max_value-get_h_scroll_bar().page))
  scroll_horizontal=roundi(scroll_position)
  velocity=lerpf(velocity,clampf(amount/dt,-1800,1800),0.55)
 last_point=point
 last_ms=now
func _process(delta: float) -> void:
 if pointer!=-99 or not is_visible_in_tree() or absf(velocity)<8: return
 scroll_position=clampf(scroll_position+velocity*minf(delta,0.05),0,maxf(0,get_h_scroll_bar().max_value-get_h_scroll_bar().page))
 scroll_horizontal=roundi(scroll_position)
 velocity*=exp(-8*delta)
