extends Node
var world
var duration=30.0
var elapsed=0.0
var intervals=[]
var previous=0
var origin: Vector3
var original_zoom=0.0
var button: Button
var layer: CanvasLayer
var finished=false
var draw_samples=[]
var setup_samples=[]
func _notification(what: int) -> void:
 if what==NOTIFICATION_APPLICATION_PAUSED and is_instance_valid(world): finish()
func _ready() -> void:
 origin=world.focus
 original_zoom=world.zoom
 RuntimeStats.start_profile()
 previous=Time.get_ticks_usec()
 layer=CanvasLayer.new()
 layer.layer=70
 add_child(layer)
 button=Button.new()
 button.text="KAMERARUNDE STOPPEN"
 button.position=Vector2(14,world.hud.mission_button.get_global_rect().end.y+12)
 button.custom_minimum_size=Vector2(220,44)
 button.pressed.connect(finish)
 layer.add_child(button)
func _process(delta: float) -> void:
 if finished: return
 var now=Time.get_ticks_usec()
 intervals.append(float(now-previous)/1000.0)
 draw_samples.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
 setup_samples.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000.0)
 previous=now
 elapsed+=delta
 var targets=[Vector3(-21,0,-43),Vector3(0,0,100),Vector3(0,0,20)]
 var part=mini(2,floori(elapsed/maxf(0.01,duration/3)))
 world.focus=targets[part]
 world.zoom=240 if part==2 else 110
 world.set_camera()
 button.visible=not world.hud.overlay.visible
 button.position.y=world.hud.mission_button.get_global_rect().end.y+12
 button.text="STOPPEN · NOCH %s s" % ceili(maxf(0,duration-elapsed))
 if elapsed>=duration: finish()
func finish() -> void:
 if finished: return
 finished=true
 var measured=0.0
 for value in intervals: measured+=value
 intervals.sort()
 draw_samples.sort()
 setup_samples.sort()
 var work=RuntimeStats.finish_profile()
 if not intervals.is_empty():
  Game.performance_results={"frames":intervals.size(),"seconds":measured/1000.0,"fps":intervals.size()*1000.0/maxf(1,measured),"p95_ms":intervals[mini(intervals.size()-1,floori(intervals.size()*0.95))],"profile":"Akku" if Game.state.quality==0 else "Standard","version":ProjectSettings.get_setting("application/config/version"),"work":work,"draw_calls":draw_samples[draw_samples.size()/2],"process_p95_ms":setup_samples[mini(setup_samples.size()-1,floori(setup_samples.size()*0.95))]}
 world.focus=origin
 world.zoom=original_zoom
 world.set_camera()
 world.performance_tour=null
 world.hud.open_menu("performance")
 queue_free()

func _exit_tree() -> void:
 if not finished:RuntimeStats.finish_profile()
