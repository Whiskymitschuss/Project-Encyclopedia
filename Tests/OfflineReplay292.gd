extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,why: String) -> void:
 checks+=1
 if not ok: failures.append(why); printerr("FAILED: ",why)
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.set_block_signals(true)
 # 0.29.3 intentionally changes junction behaviour. Keep the old hash file as
 # historical evidence; TrafficFlow293 independently asserts liveness and
 # material conservation on an actual gridlock captured from the old APK.
 var reference=JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/offline293-reference.json"))
 for name in ["basic","city"]:
  var fixture=JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/offline292-"+name+".json"))
  game.restore(fixture)
  var index=0
  for second in 3600:
   game.step(1)
   if second+1!=int(reference.seconds[index]): continue
   var sample=game.state.duplicate(true)
   sample.erase("last_seen")
   var canonical=JSON.parse_string(JSON.stringify(sample,"",true,true))
   check(JSON.stringify(canonical,"",true,true).sha256_text()==reference.cases[name][index],"Whole company matches the corrected 0.29.3 traffic baseline at second %s (%s)" % [second+1,name])
   index+=1
   if index>=reference.seconds.size(): break
  check(index==5,"All legacy checkpoints are exercised for "+name)
 # New roads and state restores must invalidate the junction neighborhood cache.
 for changed in [false,true,false]:
  game.restore(game.initial_state())
  if changed:
   game.state.town.roads.append({"kind":"asphalt","cells":TownRules.path(Vector2i(0,20),Vector2i(120,20)).map(func(c): return [c.x,c.y])})
  var all=TrafficRules.junctions(game.state).duplicate()
  for cell in all:
   for offset in [Vector2(11,0),Vector2(-11,0),Vector2(0,11),Vector2(0,-11)]:
    var target=TownRules.point(cell)+Vector3(offset.x,0,offset.y)
    var nearby=TrafficRules.nearby_junctions(target)
    check(cell in nearby,"Spatial query retains the real stop-zone crossing, including negative map tiles and road edits")
  check(not all.is_empty(),"Road network still contains actual junctions")
 print("OFFLINE REPLAY 0.29.2: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
