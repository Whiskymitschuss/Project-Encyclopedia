extends Node3D
# Six reusable loops and four short voices; never one player per building/tree.
var world: Node3D
var streams={}
var listener: AudioListener3D
var loops=[]
var voices=[]
var next_voice=0
var pending=[]
var suspended=false

func _ready() -> void:
 listener=AudioListener3D.new()
 add_child(listener)
 listener.position=world.focus+Vector3.UP*10
 listener.make_current()
 for i in 6:
  var player=AudioStreamPlayer3D.new()
  player.unit_size=28
  player.max_distance=160
  player.volume_db=-24
  player.panning_strength=0.65
  add_child(player)
  loops.append(player)
 for i in 4:
  var player=AudioStreamPlayer3D.new()
  player.unit_size=20
  player.max_distance=130
  player.volume_db=-19
  add_child(player)
  voices.append(player)

func sound(kind: String) -> AudioStreamWAV:
 if streams.has(kind): return streams[kind]
 var duration=2.0 if kind=="siren" else 1.0 if kind in ["water","fire"] else 0.65 if kind=="creak" else 0.3
 var samples=int(duration*22050)
 var data=PackedByteArray()
 data.resize(samples*2)
 var random=RandomNumberGenerator.new()
 random.seed=4287
 var filtered=0.0
 for i in samples:
  var t=float(i)/22050
  var noise=random.randf_range(-1,1)
  filtered=filtered*0.82+noise*0.18
  var value=0.0
  match kind:
   "siren": value=sin(TAU*520*t-260*cos(PI*t)*2)*0.22+sin(TAU*1040*t)*0.025
   "water": value=filtered*0.65+noise*0.055
   "fire": value=filtered*0.55+(noise*0.4 if absf(noise)>0.985 else 0.0)
   "creak": value=(sin(TAU*(130*t-45*t*t))+filtered*0.3)*sin(PI*t/duration)*0.25
   "impact": value=(sin(TAU*72*t)*0.6+filtered*1.5)*pow(1-t/duration,3)*0.65
  data.encode_s16(i*2,int(clampf(value,-1,1)*32760))
 var stream=AudioStreamWAV.new()
 stream.mix_rate=22050
 stream.format=AudioStreamWAV.FORMAT_16_BITS
 stream.data=data
 if kind in ["siren","water","fire"]:
  stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
  stream.loop_end=samples
 streams[kind]=stream
 return stream

func enabled() -> bool:
 return not Game.state.muted and not suspended and Game.state.ambient_enabled and DisplayServer.get_name()!="headless"

func loop_at(index: int, kind: String, at: Vector3, gain: float) -> void:
 var player=loops[index]
 var audible=enabled() and gain>0.01 and at.distance_to(listener.global_position)<160
 if not audible: player.stop(); return
 player.position=at
 player.volume_db=-24+linear_to_db(maxf(0.02,gain))
 if player.stream!=sound(kind): player.stream=sound(kind)
 if not player.playing: player.play()

func transient(kind: String, at: Vector3) -> void:
 if not enabled() or at.distance_to(listener.global_position)>150: return
 var player=voices[next_voice]
 next_voice=(next_voice+1)%voices.size()
 player.position=at
 player.stream=sound(kind)
 player.play()

func cut(at: Vector3) -> void:
 if not enabled(): return
 transient("creak",at)
 if pending.size()<4: pending.append({"at":at,"left":1.05})

func _process(delta: float) -> void:
 listener.position=world.view_focus+Vector3.UP*10
 listener.global_basis=world.camera.global_basis
 if not enabled():
  for player in loops+voices: player.stop()
  pending.clear()
  return
 for item in pending: item.left-=delta
 for i in range(pending.size()-1,-1,-1):
  if pending[i].left<=0:
   transient("impact",pending[i].at)
   pending.remove_at(i)
 var engine=0
 for mission in Game.state.city_services.missions:
  if mission.kind!="fire" or mission.served or float(mission.age)>=float(mission.drive): continue
  var sample=CityServices.sample(mission,minf(Game.tick_clock,0.99))
  loop_at(engine,"siren",sample.position,1.0)
  engine+=1
  if engine>=2: break
 for i in range(engine,2): loops[i].stop()
 var count=0
 for incident in Game.state.city_services.fires:
  var at=CityServices.location(Game.state,incident.target_ref)+Vector3.UP*4
  var spraying=false
  for mission in Game.state.city_services.missions:
   if int(mission.get("fire_id",-1))==int(incident.id): spraying=float(mission.age)>=float(mission.drive) and not mission.served
  loop_at(2+count*2,"fire",at,(1-float(incident.progress))*0.7)
  loop_at(3+count*2,"water",at,0.8 if spraying else 0.0)
  count+=1
  if count>=2: break
 for i in range(2+count*2,6): loops[i].stop()

func _notification(what: int) -> void:
 if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT]:
  suspended=true
  for player in loops+voices: player.stop()
 if what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN]: suspended=false
