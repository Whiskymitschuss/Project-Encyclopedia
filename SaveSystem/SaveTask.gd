extends RefCounted
var thread=Thread.new()
var snapshot={}
var writer_script: Script
var id=0
var result={}
func start(script: Script,data: Dictionary,sequence: int) -> Error:
 writer_script=script;snapshot=data;id=sequence
 return thread.start(run)
func run() -> void:
 var began=Time.get_ticks_usec()
 var writer=writer_script.new()
 var ok=writer.save_game(snapshot)
 result={"ok":ok,"error":writer.last_error,"id":id,"duration_ms":(Time.get_ticks_usec()-began)/1000.0}
 snapshot={}
func finished() -> bool:return thread.is_started() and not thread.is_alive()
func take() -> Dictionary:
 thread.wait_to_finish()
 return result
