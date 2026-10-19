extends Node

const PATH = "user://timber_rebuild.json"
var last_error = ""

func read_file(path: String) -> Dictionary:
 if not FileAccess.file_exists(path): return {}
 var file = FileAccess.open(path, FileAccess.READ)
 if file == null: return {}
 var parsed = JSON.parse_string(file.get_as_text())
 if parsed is Dictionary and int(parsed.get("schema",0)) == 1:
  return parsed
 return {}

func load_game() -> Dictionary:
 var result = read_file(PATH)
 if result.is_empty(): result = read_file(PATH + ".bak")
 return result

func save_game(data: Dictionary) -> bool:
 last_error = ""
 var tmp = PATH + ".tmp"
 var file = FileAccess.open(tmp, FileAccess.WRITE)
 if file == null:
  last_error = "Spielstand konnte nicht geschrieben werden."
  return false
 file.store_string(JSON.stringify(data))
 file.flush()
 file.close()
 if read_file(tmp).is_empty():
  last_error = "Spielstandprüfung fehlgeschlagen."
  return false
 var current = ProjectSettings.globalize_path(PATH)
 if not read_file(PATH).is_empty():
  var copy_error = DirAccess.copy_absolute(current,current + ".bak")
  if copy_error != OK:
   last_error = "Spielstand-Backup fehlgeschlagen."
   return false
 var error = DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), current)
 if error != OK: last_error = "Spielstand konnte nicht übernommen werden."
 return error == OK
