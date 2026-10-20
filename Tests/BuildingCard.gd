extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func settle() -> void:
 for i in 4: await process_frame
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.city_services.enabled=false
 game.state.buildings.append({"kind":"furniture","level":1,"paused":false,"position":[-44,-12]})
 game.start_delivery()
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.hide()
 scene.set_process(false)
 var hud=scene.hud
 var ui=hud.ux
 ui.set_process(false)
 await settle()
 check(hud.is_visible_in_tree(),"The actual HUD stays visible while background geometry is excluded from layout stress")
 for resolution in [Vector2i(540,960),Vector2i(591,1280),Vector2i(360,640)]:
  root.size=resolution
  await settle()
  for large in [false,true]:
   game.state.ux.large_text=large
   ui.apply_accessibility()
   for i in 24:
    ui.select_building(1 if i%2==0 else 0)
    await settle()
    ui.refresh()
    await settle()
    var rect=ui.sheet.get_global_rect()
    check(rect.position.y>=168,"Repeated selection keeps the card below the top HUD: %s large=%s cycle=%s rect=%s" % [resolution,large,i,rect])
    check(rect.end.y<=hud.size.y-190,"Repeated selection keeps bottom navigation accessible")
    check(rect.size.y<=minf(380,hud.size.y-168-190),"Live updates never accumulate blank card height")
   print("CARD BOUNDS ",resolution," large=",large," rect=",ui.sheet.get_global_rect())
 # A wrapping label can temporarily advertise a tall minimum while its
 # container is being sized. The card must cap it and recover after it shrinks.
 ui.select_building(1)
 await settle()
 var transient=Label.new()
 transient.text="Temporärer Layoutbedarf"
 transient.custom_minimum_size.y=1100
 ui.sheet_body.add_child(transient)
 await settle()
 check(ui.sheet.size.y<=380,"Temporarily tall content cannot expand the sheet across the world")
 check(ui.sheet.get_global_rect().position.y>=168,"Transient layout cannot push the close control above the screen")
 transient.queue_free()
 await settle()
 ui.refresh()
 await settle()
 check(ui.sheet.size.y<=380,"Removing transient content recovers the normal card height")
 check(ui.sheet.get_global_rect().position.y>=168,"Reopening after a tall layout keeps the full card onscreen")
 ui.hide_panels(true)
 scene.queue_free()
 await process_frame
 print("BUILDING CARD: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
