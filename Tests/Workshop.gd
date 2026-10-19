extends SceneTree

var checks=0
var failures=[]
func check(ok: bool, detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func _initialize() -> void: call_deferred("run")

func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.flow.clear()
 game.state.tutorial=5
 game.state.workers=6
 var original=game.snapshot()
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 var machine=scene.world_buildings.get_child(1).get_node("Processing")
 machine.set_process(false)
 check(machine.building_index==1,"Placed sawmill is wired to its own economic flow")
 var rotor=machine.get_node("Rotor")
 var stopped=rotor.rotation
 machine._process(0.1)
 check(not machine.active and rotor.rotation==stopped,"Empty factory never rotates its saw")
 game.state.resources.wood=30
 game.step(1)
 machine._process(0.1)
 check(machine.active and rotor.rotation!=stopped,"Actual wood conversion drives the saw")
 check(game.state.resources.boards>0,"Visual production is backed by real output")
 var operator=null
 for worker in scene.actors.get_children():
  if worker.get("role")=="operator": operator=worker; break
 check(operator!=null,"Hired team staffs a factory directly")
 if operator!=null:
  operator.set_process(false)
  operator._process(0.1)
  check(operator.working,"Machine operator works with the factory flow")
 game.state.buildings[1].paused=true
 stopped=rotor.rotation
 var phase=machine.phase
 machine._process(0.25)
 if operator!=null: operator._process(0.25)
 check(not machine.active and rotor.rotation==stopped and machine.phase==phase,"Pause freezes tooling and workpiece even before the next economy tick")
 if operator!=null: check(not operator.working,"Paused production also stops its operator")
 game.state.buildings[1].paused=false
 game.state.resources.wood=0
 game.state.workers=0
 game.step(1)
 machine._process(0.25)
 check(not machine.active and rotor.rotation==stopped,"Material shortage stops the same rendered machine")
 var before=game.state.duplicate(true)
 for kind in Catalog.RECIPES:
  for level in [1,10,100]:
   var model=load("res://Buildings/Models.gd").building(kind,level)
   check(model.get_meta("open_factory",false) and model.has_node("Processing/Feed") and model.has_node("Processing/Product"),"Factory exposes material flow: "+kind)
   model.free()
 check(game.state==before,"Building render models never grant or consume stock")
 for size in [Vector2i(540,960),Vector2i(540,1170),Vector2i(360,640)]:
  root.size=size
  await process_frame
  await process_frame
  var footer=scene.hud.sawdust_button.get_parent().get_parent().get_parent()
  check(footer.get_global_rect().end.y<=scene.hud.size.y,"Footer stays fully on screen at %s" % size)
  check(scene.hud.mission_button.get_global_rect().end.y<footer.global_position.y,"World remains visible between HUD controls at %s" % size)
 game.state.quality=0
 scene._process(0)
 check(not scene.sun.shadow_enabled,"Battery mode disables realtime shadows")
 game.state.quality=1
 scene._process(0)
 check(scene.sun.shadow_enabled,"Standard quality restores realtime shadows")
 game.restore(original)
 scene.queue_free()
 await process_frame
 print("WORKSHOP: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
