extends Node
# One app-wide compressed stream, shared by title/loading/game scenes.
# Loading is asynchronous; playback/mixing belongs to the audio server.
const TRACK="res://Assets/Audio/whimsical-forest-adventure.mp3"
var player: AudioStreamPlayer
var loading=false
var failed=false
var app_paused=false
var focus_lost=false

func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 player=AudioStreamPlayer.new()
 player.name="BackgroundMusic"
 player.process_mode=Node.PROCESS_MODE_ALWAYS
 add_child(player)
 Game.changed.connect(apply_settings)
 set_process(false)
 if DisplayServer.get_name()!="headless":begin_loading()

func begin_loading() -> void:
 if loading or failed or player.stream!=null:return
 var error=ResourceLoader.load_threaded_request(TRACK,"AudioStreamMP3")
 if error!=OK:
  failed=true
  push_warning("Hintergrundmusik konnte nicht geladen werden.")
  return
 loading=true
 set_process(true)

func _process(_delta: float) -> void:
 if not loading:return
 var status=ResourceLoader.load_threaded_get_status(TRACK)
 if status==ResourceLoader.THREAD_LOAD_IN_PROGRESS:return
 loading=false
 set_process(false)
 if status!=ResourceLoader.THREAD_LOAD_LOADED:
  failed=true
  push_warning("Hintergrundmusik konnte nicht geladen werden.")
  return
 var source=ResourceLoader.load_threaded_get(TRACK) as AudioStreamMP3
 if source==null:
  failed=true
  return
 var stream=source.duplicate() as AudioStreamMP3
 stream.loop=true
 stream.loop_offset=0.0
 player.stream=stream
 apply_settings()

func apply_settings() -> void:
 if not is_instance_valid(player) or Game.state.is_empty():return
 var gain=clampf(float(Game.state.get("music_volume",0.35)),0.0,1.0)
 player.volume_db=-6.0+linear_to_db(maxf(0.0001,gain))
 var allowed=not bool(Game.state.muted) and bool(Game.state.get("music_enabled",true)) and gain>0 and not app_paused and not focus_lost and not Game.application_suspended
 if DisplayServer.get_name()=="headless":allowed=false
 if not allowed:
  player.stream_paused=true
 elif player.stream!=null:
  player.stream_paused=false
  if not player.playing:player.play()

func _notification(what: int) -> void:
 match what:
  NOTIFICATION_APPLICATION_PAUSED:app_paused=true
  NOTIFICATION_APPLICATION_RESUMED:app_paused=false
  NOTIFICATION_APPLICATION_FOCUS_OUT:focus_lost=true
  NOTIFICATION_APPLICATION_FOCUS_IN:focus_lost=false
  _:return
 apply_settings()

func shutdown() -> void:
 if is_instance_valid(player):
  player.stop()
  player.stream=null

func _exit_tree() -> void:shutdown()
