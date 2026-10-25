extends Control

const WORLD="res://Scenes/Main.tscn"
var ready_to_play=false
var starting=false
var returning=false
var enter_requested=false
var scene_ready: PackedScene
var artwork: Control
var logo: TextureRect
var chapter: Label
var subtitle: Label
var play: Button
var column: VBoxContainer
var recovery_box: VBoxContainer
var load_failed=false

func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 Game.live_world=false
 Game.back_requested.connect(back)
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 enter_requested=not Game.title_requested
 Game.title_requested=false
 returning=int(Game.state.tutorial)>0 or float(Game.state.elapsed)>0 or int(Game.state.trees)>0
 artwork=load("res://UI/LoadingArtwork.gd").new()
 add_child(artwork)
 logo=artwork.background
 chapter=artwork.chapter
 subtitle=artwork.subtitle
 play=artwork.play
 column=artwork.column
 play.pressed.connect(start_game)
 recovery_box=VBoxContainer.new()
 recovery_box.hide()
 column.add_child(recovery_box)
 if Store.recovery_required:
  enter_requested=false
  play.hide()
  artwork.progress(0,"SPIELSTAND PRÜFEN","Dein Spielstand kann nicht gelesen werden. Deine Dateien bleiben erhalten.")
  var recovery=Button.new()
  recovery.text="WIEDERHERSTELLUNG ANSEHEN"
  recovery.custom_minimum_size.y=48
  recovery.pressed.connect(show_recovery)
  recovery_box.add_child(recovery)
  recovery_box.show()
 begin_loading()

func begin_loading() -> void:
 load_failed=false
 var error=ResourceLoader.load_threaded_request(WORLD,"PackedScene")
 if error!=OK: loading_error()

func loading_error() -> void:
 load_failed=true
 starting=false
 artwork.progress(0,"WELT KONNTE NICHT GELADEN WERDEN","Bitte versuche es erneut. Dein Spielstand bleibt erhalten.")
 play.text="ERNEUT VERSUCHEN"
 play.disabled=false
 play.show()

func start_game() -> void:
 if starting or Store.recovery_required: return
 enter_requested=true
 if load_failed: begin_loading()
 _process(0)

func _process(_delta: float) -> void:
 if starting or load_failed: return
 var progress=[]
 if scene_ready==null:
  var status=ResourceLoader.load_threaded_get_status(WORLD,progress)
  if status==ResourceLoader.THREAD_LOAD_FAILED or status==ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
   loading_error(); return
  if status==ResourceLoader.THREAD_LOAD_LOADED:
   scene_ready=ResourceLoader.load_threaded_get(WORLD)
 if Store.recovery_required: artwork.layout(); return
 if Game.catching_up:
  artwork.progress(Game.replay_progress()*90,"DEINE FIRMA WIRD AKTUALISIERT","Fortschritt seit deiner letzten Sitzung wird berechnet.")
  return
 if scene_ready==null:
  artwork.progress((float(progress[0]) if not progress.is_empty() else 0.0)*90,"DEIN WALD WIRD GELADEN","Gebäude, Biber und Transportwege werden vorbereitet.")
  return
 ready_to_play=true
 if not enter_requested:
  artwork.progress(100,"DEIN WALD WARTET AUF DICH","Deine Firma ist bereit.")
  play.show()
  return
 if Game.application_suspended: return
 starting=true
 RuntimeStats.request_world()
 play.disabled=true
 play.hide()
 artwork.progress(95,"DEIN WALD WIRD AUFGEBAUT","Gleich geht’s los.")
 call_deferred("open_after_frame")

func open_after_frame() -> void:
 await get_tree().process_frame
 await get_tree().process_frame
 if Game.catching_up or Game.application_suspended:
  starting=false
  return
 Game.staged_world_requested=true
 var error=get_tree().change_scene_to_packed(scene_ready)
 if error!=OK:
  Game.staged_world_requested=false
  loading_error()

func show_recovery() -> void:
 for child in recovery_box.get_children(): recovery_box.remove_child(child); child.queue_free()
 artwork.text(recovery_box,"Beide Speicherdateien sind beschädigt. Du kannst eine neue Firma beginnen. Die bisherigen Dateien bleiben als separate Sicherung erhalten.",14)
 var confirm=Button.new()
 confirm.text="DATEIEN BEWAHREN & NEU BEGINNEN"
 confirm.custom_minimum_size.y=52
 confirm.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 recovery_box.add_child(confirm)
 confirm.pressed.connect(func():
  if not Store.archive_unreadable(): subtitle.text=Store.last_error; return
  Game.state=Game.initial_state()
  if not Game.save(true): subtitle.text=Store.last_error; return
  recovery_box.hide()
  enter_requested=true
  _process(0))
 artwork.layout()

func back() -> void:
 if starting: return
 if not Store.recovery_required and not Game.catching_up: Game.save(true)
 get_tree().quit()

func _unhandled_key_input(event: InputEvent) -> void:
 if event.is_action_pressed("ui_accept"):
  start_game()
  get_viewport().set_input_as_handled()
 elif event.is_action_pressed("ui_cancel"):
  back()
  get_viewport().set_input_as_handled()
