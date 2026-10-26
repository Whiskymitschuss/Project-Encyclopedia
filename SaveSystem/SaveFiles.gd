extends RefCounted
# File-only transaction. A worker owns its snapshot and this instance; no nodes,
# signals, scene-tree operations or mutable live economy are accessed here.
const PATH="user://timber_rebuild.json"
const ROLLBACK_COPY="user://recovery/before-028-rollback.json"
var last_error=""
var recovery_required=false

func valid_shape(data: Variant) -> bool:
 if not data is Dictionary or not data.get("schema") is float and not data.get("schema") is int: return false
 if int(data.schema)!=1: return false
 for key in ["resources","ux","onboarding","journey","town","trade","stone","city_services","research","boosters","delivery","inventory","projects","plan","missions_claimed","forest","sawmills"]:
  if data.has(key) and not data[key] is Dictionary: return false
 for key in ["buildings","homes","jobs","construction_shipments"]:
  if data.has(key) and not data[key] is Array: return false
 for key in ["coins","diamonds","tickets","tokens","cash","bag","workers","trucks","vehicle","tool","biome","unlocked","tutorial","elapsed","last_seen"]:
  if data.has(key) and (not data[key] is float and not data[key] is int or not is_finite(float(data[key])) or float(data[key])<0): return false
 for key in data.get("resources",{}):
  var amount=data.resources[key]
  if not amount is float and not amount is int or not is_finite(float(amount)) or float(amount)<0: return false
 for group in ["buildings","homes"]:
  var definitions=Catalog.BUILDINGS if group=="buildings" else Catalog.HOMES
  for record in data.get(group,[]):
   if not record is Dictionary or not record.get("kind") is String: return false
   if not definitions.has(record.kind): return false
   if not record.get("level",1) is float and not record.get("level",1) is int: return false
   if not is_finite(float(record.get("level",1))) or float(record.get("level",1))<1: return false
   if record.has("position"):
    if not record.position is Array or record.position.size()!=2: return false
    for coordinate in record.position:
     if not coordinate is float and not coordinate is int or not is_finite(float(coordinate)): return false
 for pair in [["town","roads"],["town","stops"],["town","lines"],["trade","shipments"],["stone","shipments"],["delivery","shipments"],["city_services","missions"],["city_services","walkers"],["city_services","fires"]]:
  if data.get(pair[0],{}).has(pair[1]) and not data[pair[0]][pair[1]] is Array: return false
 return true

func read_file(path: String) -> Dictionary:
 if not FileAccess.file_exists(path): return {}
 var file = FileAccess.open(path, FileAccess.READ)
 if file == null or file.get_length()>16*1024*1024: return {}
 var parser = JSON.new()
 if parser.parse(file.get_as_text()) != OK: return {}
 return parser.data if valid_shape(parser.data) else {}

func save_game(data: Dictionary) -> bool:
 last_error = ""
 if recovery_required:
  last_error="Beschädigter Spielstand · bitte zuerst die Wiederherstellung öffnen."
  return false
 if not valid_shape(data):
  last_error="Spielstand enthält ungültige Werte und wurde nicht übernommen."
  return false
 # Keep the original 0.29 bytes beyond the normal rotating .bak. Never
 # overwrite that copy on later autosaves or replace the source if copying fails.
 var current_data=read_file(PATH)
 var current_valid=not current_data.is_empty()
 var source=PATH if current_valid else PATH+".bak"
 var previous=current_data if current_valid else read_file(source)
 if (previous.has("traffic") or previous.has("foreman")) and not FileAccess.file_exists(ROLLBACK_COPY):
  var archive_tmp=ROLLBACK_COPY+".tmp"
  if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://recovery"))!=OK or DirAccess.copy_absolute(ProjectSettings.globalize_path(source),ProjectSettings.globalize_path(archive_tmp))!=OK:
   last_error="Sicherung vor der Rückkehr auf 0.28 fehlgeschlagen · bisherige Datei bleibt erhalten."
   return false
  if FileAccess.get_sha256(source)!=FileAccess.get_sha256(archive_tmp) or DirAccess.rename_absolute(ProjectSettings.globalize_path(archive_tmp),ProjectSettings.globalize_path(ROLLBACK_COPY))!=OK:
   last_error="Rollback-Sicherung konnte nicht geprüft werden · bisherige Datei bleibt erhalten."
   return false
 var tmp = PATH + ".tmp"
 var file = FileAccess.open(tmp, FileAccess.WRITE)
 if file == null:
  last_error = "Spielstand konnte nicht geschrieben werden."
  return false
 file.store_string(JSON.stringify(data,"",true,true))
 file.flush()
 file.close()
 if read_file(tmp).is_empty():
  last_error = "Spielstandprüfung fehlgeschlagen."
  return false
 var current = ProjectSettings.globalize_path(PATH)
 if current_valid:
  var copy_error = DirAccess.copy_absolute(current,current + ".bak")
  if copy_error != OK:
   last_error = "Spielstand-Backup fehlgeschlagen."
   return false
 var error = DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), current)
 if error != OK: last_error = "Spielstand konnte nicht übernommen werden."
 return error == OK
