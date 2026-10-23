extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func settle() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 var s=game.state
 s.tutorial=5
 s.construction_intro=true
 s.workers=17
 s.tool=10
 s.trucks=0
 s.vehicle=3
 s.city_services.enabled=false
 s.companion_enabled=false
 s.auto_export=false
 s.reserve=false
 s.time=10
 s.buildings[0].level=7
 s.buildings[1].level=7
 s.buildings.append({"kind":"furniture","level":1,"paused":false,"position":[-20,-12]})
 s.buildings.append({"kind":"central_depot","level":1,"paused":false,"position":[44,20]})
 DeliveryChain.start(s)
 var source=CentralLogistics.stock(s,0)
 source.wood=120
 s.resources.wood=game.capacity()-54
 for i in 3: CentralLogistics.launch(s,0,6,"wood",18,"central",source)
 s.resources.wood=game.capacity()
 source.wood=120
 for tick in 300: CentralLogistics.tick(s,1)
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.size=Vector2i(591,1280)
 root.content_scale_size=root.size
 root.add_child(scene)
 scene.set_process(false)
 scene.hud.ux.set_process(false)
 scene.sync_actors()
 scene.focus=game.building_position(6)
 scene.zoom=110
 scene.set_camera()
 await settle()
 check(s.hub.receiving.wood==54 and s.hub.shipments.is_empty(),"Main-world receiving state contains the real unloaded cargo, with all trucks returned")
 scene.hud.ux.select_building(0)
 await settle()
 check(scene.hud.ux.sheet_body.find_children("*","Label",true,false).any(func(label): return label.text.contains("Zentrallager voll")),"The real collection-station card explains a full store instead of silently showing idle workers")
 scene.hud.ux.open_material("wood")
 await settle()
 check(scene.hud.contents.find_children("*","Label",true,false).any(func(label): return label.text.contains("Warenannahme: 54")),"Material help explicitly identifies the staged wood")
 scene.hud.close_menu()
 scene.hud.ux.hide_panels(true)
 var machines=[]
 for actor in scene.actors.get_children():
  if actor.has_meta("forestry_tier"): machines.append(actor); actor.set_process(false)
 check(not machines.is_empty(),"Advanced hired workers are represented by the actual beaver-driven forestry machines")
 if machines.is_empty():
  scene.queue_free()
  await process_frame
  quit(1)
  return
 var machine=machines[0]
 game.flow.harvest=0
 machine.work_left=0
 machine._process(1)
 var initial_phase=float(machine.phase)
 check(not machine.working,"Without any accepted harvest a forestry machine cannot invent a work cycle")
 var gathered=float(s.gathered)
 for tick in 1800:
  game.step(1)
  if float(game.flow.harvest)>0: break
 check(float(s.gathered)>gathered and float(game.flow.harvest)>0,"The repaired central logistics restores actual wood harvesting in this main-world company")
 machine._process(0.5)
 check(machine.working and machine.phase>initial_phase,"A real harvested load restarts the visible machine instead of leaving it parked")
 game.state.ux.motion=false
 var phase=float(machine.phase)
 var count=float(s.gathered)
 machine._process(0.5)
 check(machine.phase==phase and s.gathered==count,"Reduced motion stops presentation without changing harvest ownership")
 game.state.ux.motion=true
 game.flow.harvest=0
 for second in 22: machine._process(1)
 check(not machine.working and machine.work_left==0,"An earned load finishes its current cycle, then the machine parks if no new harvest is accepted")
 # Falling targets must be near actual work, independent of a city camera.
 game.flow.harvest=1
 machine._process(0.1)
 scene.focus=Vector3(200,0,140)
 var before=s.duplicate(true)
 scene.on_harvested(0,0)
 var cut=-1
 for i in scene.trees[0].size():
  if scene.trees[0][i].regrow>0: cut=i; break
 var nearest=INF
 if cut>=0:
  for actor in machines: nearest=minf(nearest,scene.trees[0][cut].point.distance_to(actor.origin_point))
 check(cut>=0 and nearest<9,"Automatic felling occurs within nine metres of the operating machine instead of at the distant camera")
 var clear=true
 for actor in machines:
  for tree in scene.trees[0]:
   if not tree.blocked and machine.get_script().clearance(actor.origin_point).has_point(Vector2(tree.point.x,tree.point.z)): clear=false
 check(clear,"Compact harvest stands leave real trees nearby while keeping the machine chassis clear")
 check(s==before,"Tree fall, particles and machine motion do not create or spend any wood")
 # Ordinary axemen also animate only earned cycles.
 var worker=load("res://NPCs/Worker.gd").new()
 scene.actors.add_child(worker)
 worker.set_process(false)
 game.flow.harvest=0
 worker._process(0.1)
 check(not worker.working and not worker.pack.visible,"An ordinary forester starts idle if the real output is blocked")
 game.flow.harvest=1
 worker._process(0.2)
 check(worker.working and worker.axe.visible,"Accepted harvest starts the ordinary beaver's actual axe animation")
 game.flow.harvest=0
 for second in 20: worker._process(1)
 check(not worker.working and not worker.pack.visible,"The ordinary forester also finishes one earned load and stops without creating phantom logs")
 scene.focus=Catalog.biome_position(0)
 scene.zoom=72
 scene.set_camera()
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber287-forest.png")
 scene.hud.ux.select_building(0)
 for resolution in [Vector2i(360,640),Vector2i(540,960)]:
  root.size=resolution
  root.content_scale_size=resolution
  game.state.ux.large_text=true
  scene.hud.ux.apply_accessibility()
  await settle()
  check(scene.hud.ux.sheet.get_global_rect().end.x<=resolution.x and scene.hud.ux.sheet_scroll.size.y>0,"Live harvest explanations remain scrollable on "+str(resolution))
 scene.queue_free()
 await process_frame
 await process_frame
 print("VISUAL FORESTRY 287: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
