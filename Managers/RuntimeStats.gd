extends Node

# Session diagnostics only. Neither sampling nor adaptive presentation owns
# company state, production time, inventories or vehicle reservations.
const SAMPLE_LIMIT=180
const DETAIL_SCALES=[1.0,0.85,0.65,0.5]
var samples=PackedFloat64Array()
var cursor=0
var first_frame_ms=0
var world_requested_us=0
var world_ready_ms=0
var replay_started_us=0
var replay_ms=0
var replay_seconds=0.0
var low_detail=false
var detail_level=0
var severe_seconds=0.0
var hitch_count=0
var longest_hitch_ms=0.0
var passive_enabled=OS.has_feature("mobile")
var passive_work={}
var slow_seconds=0.0
var stable_seconds=0.0
var since_change=45.0
var warmup=0.0
var previous_us=0
var profiling=false
var work={}

func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 previous_us=Time.get_ticks_usec()

func _process(_delta: float) -> void:
 var now=Time.get_ticks_usec()
 var seconds=float(now-previous_us)/1000000.0
 previous_us=now
 if first_frame_ms==0: first_frame_ms=Time.get_ticks_msec()
 if Game.state.is_empty() or not Game.live_world or Game.catching_up or Game.application_suspended or Game.skip_resume_delta or get_tree().paused:
  warmup=0
  return
 if seconds>2:
  if warmup>=2:record_frame(seconds*1000,seconds,bool(Game.state.ux.get("adaptive_detail",true)))
  warmup=0
  return
 warmup+=seconds
 if warmup<2 or seconds<=0: return
 record_frame(seconds*1000,seconds,bool(Game.state.ux.get("adaptive_detail",true)))

func record_frame(milliseconds: float,seconds: float,adaptive: bool=true) -> void:
 if samples.size()<SAMPLE_LIMIT: samples.append(milliseconds)
 else: samples[cursor]=milliseconds; cursor=(cursor+1)%SAMPLE_LIMIT
 if milliseconds>100:
  hitch_count+=1
  longest_hitch_ms=maxf(longest_hitch_ms,milliseconds)
 since_change+=seconds
 if not adaptive:
  low_detail=false;detail_level=0;severe_seconds=0;slow_seconds=0;stable_seconds=0
  return
 # A single bad frame cannot push quality straight to the minimum. Sustained
 # severe load escalates one step every six seconds; recovery is deliberately slow.
 detail_level=maxi(detail_level,1 if low_detail else 0)
 var budget=1000.0/mini(30,maxi(1,Engine.max_fps if Engine.max_fps>0 else 30))
 slow_seconds=slow_seconds+seconds if milliseconds>budget*1.35 else maxf(0,slow_seconds-seconds)
 severe_seconds=severe_seconds+seconds if milliseconds>budget*1.8 else maxf(0,severe_seconds-seconds*2)
 stable_seconds=stable_seconds+seconds if milliseconds<budget*1.08 else 0.0
 if detail_level==0 and slow_seconds>=3:
  detail_level=1;since_change=0;stable_seconds=0;severe_seconds=0
 elif detail_level>0 and detail_level<3 and severe_seconds>=6 and since_change>=6:
  detail_level+=1;since_change=0;stable_seconds=0;severe_seconds=0
 elif detail_level>0 and stable_seconds>=20 and since_change>=45:
  detail_level-=1;since_change=0;slow_seconds=0;severe_seconds=0;stable_seconds=0
 low_detail=detail_level>0

func request_world() -> void:
 world_requested_us=Time.get_ticks_usec()

func mark_world_ready() -> void:
 if world_requested_us>0: world_ready_ms=roundi(float(Time.get_ticks_usec()-world_requested_us)/1000)
 warmup=0
 samples.clear()
 cursor=0
 hitch_count=0
 longest_hitch_ms=0
 passive_work.clear()

func begin_replay(seconds: float) -> void:
 replay_started_us=Time.get_ticks_usec()
 replay_seconds=seconds

func end_replay(seconds: float) -> void:
 if replay_started_us>0: replay_ms=roundi(float(Time.get_ticks_usec()-replay_started_us)/1000)
 replay_seconds=seconds

func resolution_scale(pixels: Vector2i,quality: int,adaptive: bool,mobile: bool,photo: bool=false) -> float:
 if photo: return 1.0
 # High-DPI Android panels should not render millions of extra world pixels
 # just because they can sustain 30 FPS. Canvas/UI stays at native resolution.
 var base=clampf(sqrt(2000000.0/maxf(1,float(pixels.x)*pixels.y)),0.25,1.0) if mobile and adaptive else 1.0
 var adaptive_scale=float(DETAIL_SCALES[clampi(maxi(detail_level,1 if low_detail else 0),0,3)]) if adaptive else 1.0
 # Preserve the existing first-stage battery profile. Severe load can now
 # reduce either selected profile further without resizing the Canvas/HUD.
 return base*((0.75*adaptive_scale if detail_level>=2 and adaptive else 0.75) if quality==0 else adaptive_scale)

func snapshot() -> Dictionary:
 var sorted=samples.duplicate()
 sorted.sort()
 var elapsed=0.0
 for value in sorted: elapsed+=value
 return {"frames":sorted.size(),"fps":sorted.size()*1000.0/maxf(1,elapsed),"p95_ms":sorted[mini(sorted.size()-1,floori(sorted.size()*0.95))] if not sorted.is_empty() else 0.0,"first_frame_ms":first_frame_ms,"world_ready_ms":world_ready_ms,"replay_ms":replay_ms,"replay_seconds":replay_seconds,"detail_reduced":low_detail,"detail_level":detail_level,"hitches":hitch_count,"longest_hitch_ms":longest_hitch_ms,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"render_scale":get_viewport().scaling_3d_scale}

func summary() -> String:
 var s=snapshot()
 var live="%.1f FPS · P95 %.1f ms" % [s.fps,s.p95_ms] if s.frames>0 else "FPS-Messung startet nach zwei Sekunden in der Welt"
 return "%s\nErster Script-Frame: %s ms seit Engine-Start\nWeltaufbau: %s ms\nLetzte Offline-Berechnung: %.1f s für %.1f Min.\n3D-Auflösung: %s %% · Menü in voller Auflösung\nDarstellung: %s" % [live,s.first_frame_ms,s.world_ready_ms,s.replay_ms/1000.0,s.replay_seconds/60.0,roundi(s.render_scale*100),"Entlastungsstufe %s/3" % detail_level if low_detail else "gewähltes Qualitätsprofil"]+"\nHänger über 100 ms: %s · längster %.0f ms\nZeichenaufrufe: %s · %s/%s" % [s.hitches,s.longest_hitch_ms,int(s.draw_calls),RenderingServer.get_current_rendering_method(),RenderingServer.get_current_rendering_driver_name()]

# Explicit camera-tour measurements. Bounded CPU samples distinguish script work
# from rendering pressure without claiming a GPU profiler or collecting data.
func begin_work() -> int:
 return Time.get_ticks_usec() if profiling or passive_enabled else 0

func end_work(section: String,started: int) -> void:
 if started<=0:return
 var milliseconds=(Time.get_ticks_usec()-started)/1000.0
 if profiling:append_work(work,section,milliseconds)
 if passive_enabled:append_work(passive_work,section,milliseconds)

func append_work(table: Dictionary,section: String,milliseconds: float) -> void:
 if not table.has(section):table[section]={"samples":PackedFloat64Array(),"cursor":0}
 var data=table[section]
 if data.samples.size()<SAMPLE_LIMIT:data.samples.append(milliseconds)
 else:
  data.samples[data.cursor]=milliseconds
  data.cursor=(int(data.cursor)+1)%SAMPLE_LIMIT

func start_profile() -> void:
 work.clear()
 profiling=true

func finish_profile() -> Dictionary:
 profiling=false
 return summarize_work(work)

func summarize_work(table: Dictionary) -> Dictionary:
 var result={}
 for section in table:
  var values=table[section].samples.duplicate();values.sort()
  var total=0.0
  for value in values:total+=value
  result[section]={"mean_ms":total/maxi(1,values.size()),"p95_ms":values[mini(values.size()-1,floori(values.size()*0.95))] if not values.is_empty() else 0.0,"samples":values.size()}
 return result

func profile_summary(results: Dictionary) -> String:
 var rows=[]
 for section in results:
  var value=results[section]
  rows.append("%s: Ø %.2f · P95 %.2f ms" % [section,value.mean_ms,value.p95_ms])
 return "\n".join(rows)

func passive_summary() -> String:
 var values=summarize_work(passive_work)
 if values.is_empty():return "Messung läuft beim Spielen auf Android automatisch an."
 return "Letzte bis zu 180 Aufrufe je Bereich. CPU-Zeiten; Unterbereiche überschneiden sich.\n"+profile_summary(values)
