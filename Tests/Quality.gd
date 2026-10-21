extends SceneTree
var checks=0
var failures=[]
var sales=[]
var rescues=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.city_services.enabled=false
 game.flow.clear()
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene.set_process(false)
 var feedback=scene.feedback
 feedback.set_process(false)
 check(feedback.pool.size()==4 and scene.falling_trees.size()==4,"World feedback has a fixed allocation budget")
 var caption_count=0
 for effect in feedback.pool:
  if effect.root.visible: caption_count+=1
 check(caption_count==0,"Loading a save does not fabricate success or income")
 var before=game.state.duplicate(true)
 scene._process(0.25)
 check(game.state==before,"Wind, shadows and world animation never change simulation values")
 var wind=scene.tree_batches[0][1].material_override
 check(wind is ShaderMaterial and wind.get_shader_parameter("wind_strength")==1.0,"Normal quality enables batched tree wind")
 var clock=scene.wind_clock
 game.state.ux.motion=false
 scene._process(0.5)
 check(scene.wind_clock==clock and wind.get_shader_parameter("wind_strength")==0.0,"Reduced motion stops both wind displacement and its clock")
 game.state.ux.motion=true
 game.state.quality=0
 scene._process(0.1)
 check(wind.get_shader_parameter("wind_strength")==0.0,"Battery mode eliminates canopy displacement")
 game.state.quality=1
 var machine=scene.world_buildings.get_child(1).get_node("Processing")
 machine.set_process(false)
 game.state.resources.wood=40
 game.step(1)
 machine._process(0.1)
 check(machine.active and machine.particles.emitting,"Real conversion activates production chips")
 game.state.buildings[1].paused=true
 machine._process(0.1)
 check(not machine.particles.emitting and not machine.particles.visible,"Pausing immediately suppresses visible production feedback")
 game.state.buildings[1].paused=false
 game.state.ux.motion=false
 machine._process(0.1)
 check(not machine.particles.emitting,"Reduced motion suppresses production particles")
 game.sale_completed.connect(func(key,coins,point): sales.append([key,coins,point]))
 var coins_before=float(game.state.coins)
 game.state.resources.boards=10
 game.sell("boards")
 check(sales.size()==1 and is_equal_approx(sales[0][1],float(game.state.coins)-coins_before),"Sales feedback matches exactly the real paid revenue")
 check(sales[0][2]==game.building_position(4),"Sale effect appears at the real market")
 game.sell("boards")
 check(sales.size()==1,"Empty sale cannot trigger a coin reward")
 feedback._process(0)
 var effect=feedback.pool[0]
 check(not effect.coins.emitting and effect.label.visible,"Reduced motion keeps success text and suppresses coins")
 game.state.ambient_enabled=false
 feedback._process(0)
 check(not effect.root.visible,"Disabling ambience immediately hides existing effects")
 game.state.ambient_enabled=true
 game.state.ux.motion=true
 var hud=scene.hud
 hud.notice_history.clear()
 hud.notice_queue.clear()
 hud.toast_left=0
 hud.show_notice("Erste Meldung")
 hud.show_notice("Zweite Meldung")
 hud.show_notice("Zweite Meldung")
 check(hud.toast.text=="Erste Meldung" and hud.notice_queue.size()==1,"Notices queue instead of overwriting and deduplicate")
 hud.toast_left=0
 hud.next_notice()
 check(hud.toast.text=="Zweite Meldung","Queued notification becomes readable next")
 for i in 30: hud.show_notice("Meldung %s" % i)
 check(hud.notice_history.size()==12 and hud.notice_queue.size()==4,"Notification memory and display queue stay bounded")
 hud.update_goal_progress({"id":"test","value":75,"target":100})
 check(hud.quest_progress.value==75,"Quest meter uses actual goal values")
 for city in [false,true]:
  for level in range(1,6):
   var model=load("res://Buildings/Models.gd").building("house" if city else "sawmill",level,city)
   check(model.get_meta("quality_tier")==level,"Every first-five building level has a distinct presentation tier")
   model.free()
 game.state.homes=[{"kind":"house","level":1,"plot":0,"rent_bank":0,"position":[-24,86]}]
 game.fire_extinguished.connect(func(point): rescues.append(point))
 check(CityServices.ignite(game.state,{"type":"home","index":0}),"Real incident starts for success feedback test")
 game.step(1)
 check(rescues.is_empty(),"No rescue feedback before an incident is extinguished")
 game.step(600)
 check(rescues.size()==1 and rescues[0]==Vector3(-24,0,86),"Exactly one real extinction emits success at the real address")
 game.step(600)
 check(rescues.size()==1,"Subsequent ticks never replay rescue success")
 scene.queue_free()
 await process_frame
 print("QUALITY FEEDBACK: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
