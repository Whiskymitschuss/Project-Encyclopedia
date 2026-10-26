extends Node

const PATH = "user://timber_rebuild.json"
const ROLLBACK_COPY="user://recovery/before-028-rollback.json"
var last_error = ""
var load_status="new"
var recovery_required=false

signal save_completed(result: Dictionary)
const FILES=preload("res://SaveSystem/SaveFiles.gd")
const TASK=preload("res://SaveSystem/SaveTask.gd")
var writer_script: Script=FILES
var active: RefCounted
var pending={}
var request_id=0
var pending_id=0
var last_completed={}
var closing=false

func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS

func valid_shape(data: Variant) -> bool:return FILES.new().valid_shape(data)
func read_file(path: String) -> Dictionary:return FILES.new().read_file(path)

func load_game() -> Dictionary:
 recovery_required=false
 var result=read_file(PATH)
 load_status="current"
 if result.is_empty():
  result=read_file(PATH+".bak")
  load_status="backup"
 if result.is_empty():
  recovery_required=FileAccess.file_exists(PATH) or FileAccess.file_exists(PATH+".bak")
  load_status="blocked" if recovery_required else "new"
 return result

func archive_unreadable() -> bool:
 last_error=""
 var directory=ProjectSettings.globalize_path("user://recovery")
 if DirAccess.make_dir_recursive_absolute(directory)!=OK:
  last_error="Die bisherigen Dateien konnten nicht gesichert werden."
  return false
 var stamp=str(Time.get_unix_time_from_system()).replace(".","-")
 for suffix in ["",".bak"]:
  var source=ProjectSettings.globalize_path(PATH+suffix)
  if not FileAccess.file_exists(source): continue
  var target=directory+"/timber-"+stamp+suffix+".json"
  if DirAccess.copy_absolute(source,target)!=OK or FileAccess.get_sha256(source)!=FileAccess.get_sha256(target):
   last_error="Die bisherigen Dateien konnten nicht gesichert werden."
   return false
 recovery_required=false
 load_status="archived"
 return true

func save_game(data: Dictionary) -> bool:
 # Explicit durable writes cannot race an older queued write or be overwritten
 # later by a stale pending snapshot. Existing callers keep synchronous semantics.
 if active!=null:finish_active()
 pending.clear()
 var writer=writer_script.new()
 writer.recovery_required=recovery_required
 var ok=writer.save_game(data)
 last_error=writer.last_error
 return ok

func queue_game(data: Dictionary,seen: float=-1.0) -> bool:
 if closing or recovery_required or not valid_shape(data):
  last_error="Speicherauftrag abgelehnt · Spielstand prüfen."
  return false
 # At most one active immutable snapshot and the newest pending snapshot.
 pending=data.duplicate(true)
 if seen>=0:pending.last_seen=seen
 request_id+=1;pending_id=request_id
 if active==null:return start_pending()
 return true

func start_pending() -> bool:
 if pending.is_empty():return true
 var task=TASK.new()
 var snapshot=pending;var id=pending_id
 pending={}
 var error=task.start(writer_script,snapshot,id)
 if error!=OK:
  last_error="Speicherthread konnte nicht gestartet werden."
  last_completed={"ok":false,"error":last_error,"id":id,"duration_ms":0.0}
  save_completed.emit(last_completed)
  return false
 active=task
 return true

func finish_active() -> void:
 if active==null:return
 last_completed=active.take()
 active=null
 last_error=str(last_completed.error)
 save_completed.emit(last_completed)

func _process(_delta: float) -> void:
 if active!=null and active.finished():finish_active()
 if active==null and not pending.is_empty():start_pending()

func is_saving() -> bool:return active!=null or not pending.is_empty()
func flush_queued() -> bool:
 var ok=true
 while is_saving():
  if active!=null:
   finish_active();ok=bool(last_completed.ok) and ok
  if not pending.is_empty():ok=start_pending() and ok
 return ok

func status_text() -> String:
 if is_saving():return "Speichern läuft im Hintergrund · Spiel und Kamera laufen weiter."
 if last_completed.is_empty():return "Noch keine Hintergrundspeicherung in dieser Sitzung."
 return "Letzter Speicherauftrag: %.1f ms im Hintergrund · %s" % [float(last_completed.duration_ms),"erfolgreich" if last_completed.ok else str(last_completed.error)]

func _exit_tree() -> void:
 closing=true
 flush_queued()
