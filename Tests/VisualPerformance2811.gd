extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func settle() -> void:
 for i in 6: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 var stats=root.get_node("RuntimeStats")
 game.set_process(false)
 stats.set_process(false)
 game.state=game.initial_state()
 var s=game.state
 s.tutorial=5; s.construction_intro=true; s.city_services.enabled=false; s.companion_enabled=false
 s.workers=0; s.auto_export=false
 s.buildings.append({"kind":"central_depot","level":2,"paused":false,"position":[44,20]})
 LogisticsDispatch.synchronize(s)
 s.hub.inputs["1"]={"wood":30.0}
 s.hub.outputs["1"]={"boards":12.0}
 game.flow["building:1"]=0.7
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.size=Vector2i(591,1280); root.content_scale_size=root.size
 root.add_child(scene)
 scene.set_process(false); scene.life.set_process(false); scene.hud.ux.set_process(false)
 scene.focus=game.building_position(1); scene.zoom=75; scene.set_camera()
 await settle()
 var mill=null
 for child in scene.world_buildings.get_children():
  var process=child.get_node_or_null("Processing")
  if process!=null and process.building_index==1: mill=child; break
 check(mill!=null and mill.has_node("WoodYard") and mill.has_node("ProductionBeacon"),"The real main-world sawmill contains its finished timber bays and production beacon")
 var machine=mill.get_node("Processing")
 machine.set_process(false)
 machine._process(0.6)
 check(machine.detail_visible and machine.detail_updates>0,"The visible sawmill animates from its actual production rate")
 check(mill.get_node("InputStock").visible and mill.get_node("OutputStock").visible,"The yard shows the actual local log input and collected board output separately")
 var before=s.duplicate(true)
 var phase=machine.phase
 var count=machine.detail_updates
 scene.focus=Vector3(300,0,200); scene.zoom=75; scene.set_camera()
 machine._process(0.3)
 for i in 120: machine._process(1.0/60)
 check(not machine.detail_visible and machine.detail_updates==count and machine.phase==phase,"Offscreen sawmill skips every detailed animation update")
 check(machine.skipped_updates>=120 and not machine.particles.emitting,"Offscreen detail and particles stop while the actual economy remains authoritative")
 check(s==before,"Culling animation never changes inputs, outputs or transport reservations")
 scene.focus=game.building_position(1); scene.set_camera()
 machine._process(0.6)
 check(machine.detail_visible and machine.detail_updates>count,"Returning the camera resumes the actual factory presentation")
 game.flow["building:1"]=0
 machine.phase=0.8
 machine._process(0.5)
 check(not machine.get_node("Product").visible,"Stopped production cannot leave a phantom product moving along the belt")
 var beacon=mill.get_node("ProductionBeacon")
 beacon.set_process(false)
 s.hub.inputs["1"].wood=0
 beacon._process(0.6)
 check(beacon.status=="missing","The real warning lamp identifies missing input")
 s.hub.inputs["1"].wood=30
 s.hub.outputs["1"].boards=72
 beacon._process(0.6)
 check(beacon.status=="full","The real warning lamp identifies a full output rack")
 s.buildings[1].paused=true
 beacon._process(0.6)
 check(beacon.status=="paused","A paused machine does not advertise active production")
 s.buildings[1].paused=false; s.hub.outputs["1"].boards=12
 var handler=mill.get_node("YardHandling")
 handler.set_process(false)
 scene.focus=Vector3(300,0,200); scene.set_camera()
 handler._process(0.1)
 check(not handler.visible and not handler.cycle_running and not handler.payload.visible,"An offscreen forklift performs no cargo scan or stale pallet cycle")
 scene.focus=game.building_position(1); scene.set_camera()
 stats.low_detail=true
 before=s.duplicate(true)
 scene._process(0.6)
 check(absf(root.scaling_3d_scale-0.85)<0.01,"Sustained load reduces only 3D resolution, leaving the HUD at native size")
 check(s==before,"Adaptive rendering does not advance the economy or change inventories")
 stats.low_detail=false
 scene._process(0.6)
 check(root.scaling_3d_scale==1.0,"Full detail restores native 3D resolution")
 s.quality=0; scene._process(0.6)
 check(absf(root.scaling_3d_scale-0.75)<0.01 and not scene.sun.shadow_enabled,"Battery mode has an explicit bounded render scale and disables shadows")
 scene.photo.enter()
 check(root.scaling_3d_scale==1.0,"Entering photo mode immediately requests full 3D resolution before capture")
 scene.photo.leave()
 check(absf(root.scaling_3d_scale-0.75)<0.01,"Leaving photo mode restores the chosen render scale")
 s.quality=1; scene._process(0.6)
 scene.hud.open_menu("performance")
 await settle()
 check(scene.hud.modal_title.text=="LEISTUNGSVERGLEICH" and not scene.hud.contents.find_children("*","Label",true,false).filter(func(label): return label.text.contains("Engine-Start")).is_empty(),"The actual performance menu displays session startup timing with its proper scope")
 scene.hud.open_menu("timberline")
 await settle()
 check(scene.hud.modal_title.text=="DEINE HOLZKETTE","The real logistics menu connects to an understandable warehouse-mediated timber chain")
 root.get_texture().get_image().save_png("/workspace/timber2811-timberline.png")
 for size_value in [Vector2i(360,640),Vector2i(540,960)]:
  root.size=size_value; root.content_scale_size=size_value; s.ux.large_text=true
  scene.hud.open_menu("performance"); await settle()
  check(scene.hud.scroll.size.y>0 and scene.hud.overlay.get_global_rect().end.x<=size_value.x+1,"Performance controls remain reachable at small size and large text: "+str(size_value))
 root.size=Vector2i(591,1280); root.content_scale_size=root.size; s.ux.large_text=false
 scene.hud.close_menu()
 scene.begin_placement({"kind":"sawmill","city":false,"index":1})
 scene.placement_point=game.building_position(1); scene.update_ghost()
 await settle()
 check(scene.access_preview!=null and scene.access_preview.get_child_count()>0 and scene.hud.placement_hint.text.contains("LKW-Anschluss"),"The actual move preview marks the reachable truck access and footprint dimensions")
 root.get_texture().get_image().save_png("/workspace/timber2811-placement.png")
 scene.cancel_placement()
 check(scene.access_preview==null,"Cancel removes the visual access preview without altering roads")
 scene.focus=game.building_position(1); scene.zoom=58; scene.set_camera()
 game.flow["building:1"]=0.7
 machine._process(0.5)
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber2811-sawmill.png")
 scene.queue_free(); await process_frame
 before=s.duplicate(true)
 var boot=load("res://Scenes/Boot.tscn").instantiate()
 root.add_child(boot)
 await settle()
 check(boot.returning and not boot.diorama.animated and boot.diorama.viewport.process_mode==Node.PROCESS_MODE_DISABLED,"A returning company draws a static intro without running its decorative 3D controllers")
 check(s==before,"The static returning intro cannot modify the real company")
 boot.queue_free(); await process_frame
 print("VISUAL PERFORMANCE 2811: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
