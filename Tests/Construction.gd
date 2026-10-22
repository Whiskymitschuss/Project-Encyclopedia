extends SceneTree
var game
var checks=0
var failures=[]
func equivalent(a: Variant, b: Variant) -> bool:
 if (a is float or a is int) and (b is float or b is int): return absf(float(a)-float(b))<0.00000001
 if a is Dictionary and b is Dictionary:
  if a.size()!=b.size(): return false
  for key in a:
   if not b.has(key) or not equivalent(a[key],b[key]): return false
  return true
 if a is Array and b is Array:
  if a.size()!=b.size(): return false
  for i in a.size():
   if not equivalent(a[i],b[i]): return false
  return true
 return a==b
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func fresh(level4: bool = true) -> void:
 game.state=game.initial_state()
 game.state.company_xp=120 if level4 else 0
 game.state.construction_intro=true
 game.state.construction_auto=false
 game.state.workers=0
 game.state.coins=100000
 game.state.tutorial=5
 game.flow.clear()
func receipts(job: Dictionary) -> float:
 var result=0.0
 for key in job.delivered: result+=float(job.delivered[key])
 return result
func construction_stock(key: String) -> float:
 var result=float(game.state.resources[key])
 for job in game.state.jobs: result+=float(job.delivered.get(key,0))
 for s in game.state.construction_shipments:
  if not s.arrived and s.key==key: result+=float(s.amount)
 return result
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 fresh(false)
 check(game.company_level()==1,"Fresh companies begin at level one")
 check(game.upgrade(1),"Early coin-only upgrade remains available")
 check(game.state.jobs[0].materials.is_empty() and not game.state.jobs[0].has("phases"),"Levels one to three avoid mandatory construction materials")
 game.simulate(20)
 check(game.state.buildings[1].level==2,"Early upgrade completes with coins only")
 var legacy=game.snapshot()
 legacy.erase("company_xp")
 legacy.buildings.append({"kind":"furniture","level":1,"paused":false})
 game.restore(legacy)
 check(game.company_level()>=4,"Existing furniture companies migrate into the unlocked construction chapter")
 fresh()
 check(game.upgrade(1),"Level-four sawmill upgrade opens an actual staged site")
 var job=game.state.jobs[0]
 check(job.phases.size()==7 and job.phase==0 and job.workers==1,"Construction starts at preparation with an assigned real crew")
 var all={}
 for phase in job.phases:
  for key in phase.materials: all[key]=float(all.get(key,0))+float(phase.materials[key])
 check(all==job.materials,"The seven material phase bills sum exactly to the advertised total")
 game.simulate(20)
 check(job.phase==0 and job.left==job.total,"Time alone cannot complete a material phase")
 game.state.resources.wood=40
 game.state.resources.boards=40
 var wood_total=construction_stock("wood")
 var loaded=game.deliver_job(int(job.id))
 check(loaded>0 and receipts(job)==0,"Manual delivery loads a truck without crediting the site")
 check(game.state.construction_shipments.size()==1,"One available owned truck runs one construction delivery")
 check(absf(construction_stock("wood")-wood_total)<0.0001,"Wood is conserved when a construction truck loads")
 var cargo=game.state.construction_shipments[0]
 var cells=TownRules.road_cells(game.state.town)
 for i in range(1,cargo.path.size()-1):
  check(cells.has(Vector2i(cargo.path[i][0],cargo.path[i][2])),"Construction cargo follows an actual drivable street")
 game.step(1)
 check(receipts(job)==0,"Construction cargo cannot arrive instantly")
 var store=root.get_node("Store")
 check(store.save_game(game.state),"Construction save is written through the real atomic save system")
 var saved=store.load_game()
 game.simulate(60)
 var online=game.state.duplicate(true)
 game.restore(saved)
 game.simulate(60)
 if not equivalent(game.state,online):
  for key in online:
   if not equivalent(game.state[key],online[key]): printerr("DIFF ",key,": ",game.state[key]," expected ",online[key])
 check(equivalent(game.state,online),"In-flight construction loads and material phases survive exact offline restoration")
 job=game.state.jobs[0]
 check(int(job.phase)>0 and int(job.phase)<7,"Actual arrival permits work but missing later hardware stops later phases")
 check(game.state.buildings[1].level==1,"Waiting staged upgrade cannot alter the completed factory level")
 var cost=game.job_hardware_cost(int(job.id))
 var coins=game.state.coins
 check(cost>0 and game.buy_job_hardware(int(job.id)),"Depot supplies the exact missing construction hardware")
 check(absf(coins-game.state.coins-cost)<0.0001,"Combined hardware purchase costs exactly the advertised coins")
 coins=game.state.coins
 check(not game.buy_job_hardware(int(job.id)) and game.state.coins==coins,"Repeated purchase does not buy or charge unneeded hardware")
 job.paused=true
 var work=float(job.left)
 game.simulate(20)
 check(job.left==work,"Pausing the site freezes construction work")
 job.paused=false
 check(game.assign_builders(int(job.id),2) and game.free_builders()==0,"A second assigned builder consumes a real crew slot")
 check(not game.assign_builders(int(job.id),3),"Sites cannot assign workers beyond the hired crew")
 check(game.hire_builder() and game.state.builders==3,"Additional construction workers are bought with game coins")
 for i in 500:
  game.step(1)
  if game.state.jobs.is_empty(): break
 check(game.state.jobs.is_empty() and game.state.buildings[1].level==2,"Delivered hardware, physical haulage and working crew complete the sawmill upgrade")
 check(game.free_builders()==3,"Finished construction returns assigned builders to the shared crew")
 fresh()
 check(game.order_building("garage"),"A new staged garage reserves a real valid construction plot")
 job=game.state.jobs[0]
 game.state.resources.wood=10
 check(game.deliver_job(int(job.id))>0,"A cancel test starts with a real loaded shipment")
 var wood=construction_stock("wood")
 check(game.cancel_construction(int(job.id)),"Cancelling a site safely refunds its receipts and in-flight cargo")
 check(game.state.jobs.is_empty() and game.state.construction_shipments.is_empty(),"Cancelled jobs leave no orphan cargo or reserved construction space")
 check(absf(float(game.state.resources.wood)-wood)<0.0001,"Cancellation conserves loaded and delivered wood")
 game.simulate(100)
 check(game.count("garage")==0,"A cancelled site never completes later")
 fresh()
 game.order_building("garage")
 job=game.state.jobs[0]
 game.state.resources.wood=10
 game.deliver_job(int(job.id))
 game.state.resources.wood=game.capacity()
 check(not game.cancel_construction(int(job.id)),"Full warehouse refuses cancellation before losing any returned cargo")
 check(not game.state.jobs.is_empty() and not game.state.construction_shipments.is_empty(),"Rejected cancellation leaves job and shipment intact")
 fresh()
 game.state.construction_auto=true
 game.state.trucks=2
 game.state.resources.wood=100
 game.state.resources.boards=100
 game.order_building("garage")
 game.order_building("research")
 var a=game.state.jobs[0]
 var b=game.state.jobs[1]
 b.priority=true
 ConstructionRules.dispatch(game.state)
 check(game.state.construction_shipments.size()==2,"Two owned vehicles can serve simultaneous projects")
 check(int(game.state.construction_shipments[0].job)==int(b.id),"Priority changes actual dispatch ordering")
 check(game.free_builders()==0,"Parallel sites reserve distinct builder slots")
 fresh()
 game.order_building("garage",Vector3(-40,0,148))
 job=game.state.jobs[0]
 # Reconstruct a corrupted/unreachable destination, without making a new valid
 # placement button accept it. There must be no off-road teleport fallback.
 job.position=[310.0,220.0]
 game.state.resources.wood=20
 check(game.deliver_job(int(job.id))==0 and game.state.construction_shipments.is_empty(),"An unreachable saved job cannot consume or teleport resources")
 check(game.state.resources.wood==20,"No route leaves the original stock untouched")
 fresh()
 game.upgrade(1)
 job=game.state.jobs[0]
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 for i in 3: await process_frame
 var site=null
 for child in scene.world_buildings.get_children():
  if child.get("job_id")==int(job.id): site=child; break
 check(site!=null and site.pieces.size()==7,"Material construction has seven distinct visible geometry stages")
 var worker=null
 for child in site.get_children():
  if child.get("role")=="construction": worker=child; break
 check(worker!=null,"A hired and assigned construction worker exists at the actual site")
 worker._process(0)
 check(worker.work_state=="waiting_material" and not worker.board.visible,"Worker waits without carrying phantom material")
 for key in job.materials: job.delivered[key]=float(job.materials[key])
 game.state.elapsed=1
 worker._process(0)
 check(worker.work_state=="carrying" and worker.board.visible,"Arrived construction materials activate the worker carrying state")
 game.state.elapsed=5
 worker._process(0)
 check(worker.hammer.visible,"Working crew visibly switches to its construction tool")
 job.phase=3
 job.phase_left=0.5
 site.refresh()
 check(site.pieces[3].visible and not site.pieces[4].visible,"Visible walls appear only at the real walls phase; the roof waits")
 scene.queue_free()
 await process_frame
 print("CONSTRUCTION: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
