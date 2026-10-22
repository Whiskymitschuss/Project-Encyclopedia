extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func settle() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func find_button(hud: Control, prefix: String) -> Button:
 for button in hud.contents.find_children("*","Button",true,false):
  if button.text.begins_with(prefix): return button
 return null
func tap(hud: Control, button: Button) -> void:
 if button==null: return
 hud.scroll.ensure_control_visible(button)
 await settle()
 var point=root.get_screen_transform()*button.get_global_rect().get_center()
 for pressed in [true,false]:
  var event=InputEventScreenTouch.new()
  event.index=0
  event.pressed=pressed
  event.position=point
  Input.parse_input_event(event)
  await process_frame
 await settle()
func run() -> void:
 await process_frame
 root.size=Vector2i(540,960)
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 var state=game.state
 state.tutorial=5
 state.construction_intro=true
 state.companion_enabled=false
 state.city_services.enabled=false
 state.coins=10000
 state.homes=[{"kind":"house","level":2,"plot":0,"rent_bank":0,"position":[-52,86]},{"kind":"house","level":2,"plot":1,"rent_bank":0,"position":[-24,86]},{"kind":"fire","level":3,"plot":2,"rent_bank":0,"position":[24,86]}]
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 scene.set_process(false)
 scene.focus=Vector3(-38,0,86)
 scene.zoom=72
 scene.set_camera()
 var hud=scene.hud
 var world=scene.city_traffic.fire_world
 hud.open_menu("fire_protection")
 await settle()
 check(hud.modal_title.text=="BRANDSCHUTZ FÜR DEINE STADT","Protection screen opens as a real menu")
 var detector=find_button(hud,"RAUCHMELDER ·")
 check(detector!=null and detector.text.contains("125"),"Detector shows its actual price before purchase")
 await tap(hud,detector)
 check(FireSafety.installed(state,0,"detector") and state.coins==9875,"Real touch installs and pays for detector")
 var hydrant=find_button(hud,"HYDRANT ·")
 check(hydrant!=null and hydrant.text.contains("350"),"Hydrant shows its actual price before purchase")
 await tap(hud,hydrant)
 check(FireSafety.installed(state,0,"hydrant") and state.coins==9525,"Real touch installs and pays for hydrant")
 check(world.hydrants.size()==1,"Actual installed hydrant appears in the 3D world")
 var installed=find_button(hud,"HYDRANT INSTALLIERT")
 check(installed!=null and installed.disabled,"Installed equipment has an explicit disabled purchase state")
 hud.close_menu()
 CityServices.ignite(state,{"type":"home","index":1},false)
 hud.open_menu("services")
 await settle()
 var alarm=find_button(hud,"JETZT FEUERWEHR ALARMIEREN")
 check(alarm!=null,"Undetected fire exposes a manual alarm action")
 await tap(hud,alarm)
 check(FireSafety.alarm_left(state.city_services.fires[0])==0,"Real touch raises an early alarm")
 CityServices.tick(state,1,{})
 var mission=state.city_services.missions[0]
 check(mission.work==24 and int(mission.water_source_ref.index)==0,"The UI-purchased hydrant supplies the dispatched mission")
 await settle()
 var incident_node=world.scenes.values()[0]
 var hose=incident_node.get_node_or_null("SupplyHose")
 check(hose!=null and not hose.visible,"Saved hose route is prepared but not used before arrival")
 mission.age=float(mission.drive)+6
 CityServices.tick(state,1,{})
 await settle()
 check(hose.visible and hose.get_child_count()>0 and hose.get_child_count()<=4,"On-site work shows a bounded, baked supply hose")
 check(incident_node.get_node("Water").visible,"Hydrant supply accompanies actual extinguishing jets")
 check(FireSafety.fleet(state).busy==1 and FireSafety.fleet(state).capacity==2,"Owned fleet capacity matches the station upgrade")
 hud.close_menu()
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber-protection24-world.png")
 var before=state.duplicate(true)
 world._process(1)
 check(state==before,"Hydrants and hoses render without altering the simulation")
 for resolution in [Vector2i(360,640),Vector2i(540,960),Vector2i(591,1280),Vector2i(1280,800)]:
  root.size=resolution
  await settle()
  hud.open_menu("fire_protection")
  await settle()
  check(hud.overlay.get_global_rect().position.y>=hud.mission_button.get_global_rect().end.y+4 and hud.overlay.size.x<=760,"Protection menu fits below the compact HUD "+str(resolution))
  check(hud.scroll.size.y>100,"Protection list stays scrollable "+str(resolution))
  state.ux.large_text=true
  hud.ux.apply_accessibility()
  await settle()
  check(hud.header_panel.get_global_rect().end.y<=hud.mission_button.get_global_rect().position.y,"Large-font header remains separate "+str(resolution))
  check(hud.bottom_panel.get_global_rect().end.y<=hud.size.y+1,"Large-font navigation fits "+str(resolution))
  state.ux.large_text=false
  hud.ux.apply_accessibility()
  await settle()
  hud.open_menu("services")
  await settle()
  check(hud.overlay.size.x<=760 and not root.get_texture().get_image().is_empty(),"Incident overview actually renders "+str(resolution))
  if resolution==Vector2i(540,960): root.get_texture().get_image().save_png("/workspace/timber-protection24-services.png")
  hud.close_menu()
 CityServices.tick(state,300,{})
 world._process(0)
 check(world.scenes.is_empty() and world.hydrants.size()==1,"Supply equipment remains after extinguishing effects are removed")
 scene.queue_free()
 await process_frame
 print("FIRE PROTECTION OPENGL: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
