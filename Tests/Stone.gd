extends SceneTree
var game
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func equivalent(a: Variant,b: Variant) -> bool:
 if (a is int or a is float) and (b is int or b is float): return absf(float(a)-float(b))<0.00000001
 if a is Dictionary and b is Dictionary:
  if a.size()!=b.size(): return false
  for k in a:
   if not b.has(k) or not equivalent(a[k],b[k]): return false
  return true
 if a is Array and b is Array:
  if a.size()!=b.size(): return false
  for i in a.size():
   if not equivalent(a[i],b[i]): return false
  return true
 return a==b
func fresh() -> void:
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.city_services.enabled=false
 game.state.workers=0
 game.state.reserve=false
 game.tick_clock=0
 game.flow.clear()
 game.stone_route_cache.clear()
func company(fleet: int = 2) -> void:
 fresh()
 game.state.company_xp=220
 game.state.coins=100000
 game.state.trucks=fleet
 game.state.buildings.append({"kind":"quarry","level":1,"paused":false,"position":[-20,-12]})
 game.state.buildings.append({"kind":"stoneworks","level":1,"paused":false,"position":[20,-12]})
 StoneIndustry.synchronize(game.state)
 for i in [5,6]: check(game.placement_reason(game.building_position(i),0,i).is_empty(),"Test mining fixtures occupy genuinely legal distinct plots")
func equivalent_rock() -> float:
 var total=float(game.state.resources.rock)+float(game.state.resources.stone)*0.6+float(game.state.resources.gravel)*0.75
 for data in game.state.stone.sites.values():
  total+=float(data.reserve)+float(data.bucket)+float(data.stock.rock)+float(data.stock.stone)*0.6+float(data.stock.gravel)*0.75
  if not data.batch.is_empty(): total+=float(data.batch.input.get("rock",0))
 for s in game.state.stone.shipments:
  if not s.arrived: total+=float(s.amount)*{"rock":1.0,"stone":0.6,"gravel":0.75}[s.key]
 return total
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 fresh()
 for key in StoneIndustry.definitions.materials:
  var material=StoneIndustry.definitions.materials[key]
  check(Catalog.RESOURCES[key]==material.name and Catalog.PRICES[key]==material.value,"Configured material metadata agrees with the shared economy: "+key)
  check(material.weight>0 and ResourceLoader.exists("res://Assets/Resources/"+material.icon+".svg"),"Every material has a usable transport weight and real icon: "+key)
 for id in StoneIndustry.definitions.recipes:
  var recipe=StoneIndustry.definitions.recipes[id]
  check(recipe.seconds>0 and recipe["in"].rock>0 and not recipe.out.is_empty(),"Factory recipes have real positive production costs and duration: "+id)
 game.state.coins=100000
 check(not game.available("quarry") and not game.order_building("quarry"),"Steinindustrie is genuinely locked before company level five")
 check(game.state.coins==100000 and game.state.jobs.is_empty(),"A locked mining purchase is atomic")
 game.state.company_xp=220
 check(game.available("quarry") and game.available("stoneworks"),"Both bootstrap factories unlock together at level five")
 check(not game.build_materials("quarry").has("stone") and not game.build_materials("stoneworks").has("gravel"),"Bootstrap construction never requires its own unavailable output")
 check(game.build_materials("sawmill",6).stone==12,"Later wood factory upgrades use useful mineral foundations")
 check(game.order_building("quarry"),"A real quarry creates a paid material construction site")
 check(game.state.jobs[0].has("phases") and game.state.stone.sites.is_empty(),"A quarry under construction cannot extract material")
 var saved=game.snapshot()
 saved.erase("stone")
 for key in StoneIndustry.KEYS: saved.resources.erase(key)
 game.restore(saved)
 check(game.state.resources.stone==0 and game.state.stone.shipments.is_empty() and not game.state.jobs.is_empty(),"Legacy saves gain zero mineral stock while preserving their paid construction")
 var bootstrap=game.state.jobs[0]
 var store=root.get_node("Store")
 check(store.save_game(game.snapshot()),"A real atomic save can retain a paid quarry blueprint")
 game.restore(store.load_game())
 check(equivalent(game.state.jobs[0].materials,bootstrap.materials),"Loading never retroactively changes an already paid material bill")
 game.state.resources.wood=10
 game.state.resources.boards=4
 game.deliver_job(int(game.state.jobs[0].id))
 game.simulate(300)
 check(game.count("quarry")==1 and game.state.jobs.is_empty(),"A first quarry can be fully built from bootstrap wood deliveries")
 check(game.upgrade(5),"A built quarry starts its real level-two material upgrade")
 var upgrade=game.state.jobs[0]
 game.state.resources.wood=12
 game.state.resources.boards=5
 game.buy_job_hardware(int(upgrade.id))
 game.buy_stone_material("stone",4)
 game.buy_stone_material("gravel",1)
 game.deliver_job(int(upgrade.id))
 game.simulate(300)
 check(game.state.buildings[5].level==1 and not game.state.jobs.is_empty(),"A quarry upgrade cannot finish while even one required foundation material is missing")
 game.buy_stone_material("gravel",1)
 game.deliver_job(int(upgrade.id))
 game.simulate(300)
 check(game.state.buildings[5].level==2 and game.state.jobs.is_empty(),"A delivered final unit completes the paid upgrade through the existing builder system")
 company(0)
 var quarry=StoneIndustry.site(game.state,5)
 var factory=StoneIndustry.site(game.state,6)
 var total=equivalent_rock()
 game.simulate(2)
 check(quarry.bucket==0 and quarry.stock.rock==0 and quarry.reserve==600,"Gestein is not created before the digging phase completes")
 game.step(1)
 check(quarry.bucket==2 and quarry.reserve==598 and quarry.stock.rock==0,"Digging transfers exactly two units from the deposit into the real bucket")
 game.simulate(3)
 check(quarry.bucket==0 and quarry.stock.rock==2,"Dumping credits the pickup pile only after the shovel unloads")
 game.simulate(160)
 check(quarry.stock.rock<=StoneIndustry.capacity(game.state,5) and game.state.stone.shipments.is_empty(),"A full pickup pile and no purchased truck halt extraction without overflow")
 check(absf(equivalent_rock()-total)<0.00001,"Deposit, bucket and pickup pile conserve all mineral mass")
 quarry.reserve=0
 quarry.bucket=0
 quarry.phase=0
 quarry.phase_work=0
 quarry.stock.rock=0
 var coins=game.state.coins
 check(game.explore_vein(5) and quarry.reserve==600 and game.state.coins==coins-200,"An exhausted deposit can be replaced with a genuinely paid fresh vein")
 coins=game.state.coins
 check(not game.explore_vein(5) and game.state.coins==coins,"An unexhausted vein cannot be purchased or overwritten")
 factory.stock.rock=2
 game.simulate(3)
 check(factory.batch.is_empty() and factory.stock.stone==0,"Factory cannot run with insufficient local input")
 factory.stock.rock=3
 game.step(1)
 check(factory.stock.rock==0 and factory.batch.input.rock==3 and factory.stock.stone==0,"Active batch owns consumed input in saved escrow before any finished output exists")
 var left=float(factory.batch.left)
 game.state.buildings[6].paused=true
 game.simulate(5)
 check(factory.batch.left==left and factory.stock.stone==0,"Factory pause freezes the actual in-progress work")
 game.state.buildings[6].paused=false
 game.simulate(5)
 check(factory.batch.is_empty() and factory.stock.stone==5,"Completed six-second recipe yields exactly five building stones")
 check(game.set_stone_recipe(6,"gravel"),"Player can select a real alternative gravel recipe")
 factory.stock.rock=3
 game.step(1)
 check(factory.batch.recipe=="gravel","The selected next recipe starts with actual material")
 game.set_stone_recipe(6,"blocks")
 game.simulate(4)
 check(factory.stock.gravel==4 and factory.stock.stone==5,"Switching the next recipe cannot change or duplicate an active batch")
 factory.stock.stone=StoneIndustry.capacity(game.state,6)
 factory.stock.rock=3
 game.simulate(10)
 check(factory.stock.rock==3 and factory.batch.is_empty(),"Output capacity is checked before consuming any input")
 company(2)
 total=equivalent_rock()
 var saw_full=false
 var returning=false
 for second in 600:
  game.step(1)
  check(StoneIndustry.busy(game.state)<=int(game.state.trucks),"Mineral shipments never create free fleet capacity")
  check(absf(equivalent_rock()-total)<0.00001,"Every extraction, batch, partial load and unloading tick conserves material")
  for data in game.state.stone.sites.values():
   for key in StoneIndustry.KEYS: check(float(data.stock[key])>=0 and float(data.stock[key])<=12,"Every local stock respects its capacity")
  for shipment in game.state.stone.shipments:
   if not shipment.arrived: saw_full=true
   else: returning=true
 check(saw_full and returning and game.state.resources.stone>0,"Real trucks deliver processed stones to the warehouse and return empty")
 check(game.state.resources.rock==0,"Raw rock is not simultaneously in a local pile and the shared warehouse")
 check(StoneIndustry.definitions.materials.rock.weight==2,"Heavy rock reduces transport units using configured material metadata")
 company(2)
 game.simulate(18)
 saved=JSON.parse_string(JSON.stringify(game.snapshot(),"",true,true))
 game.simulate(300)
 var online=game.state.duplicate(true)
 game.restore(saved)
 game.simulate(300)
 game.state.last_seen=online.last_seen
 check(equivalent(game.state,online),"JSON save during mining and road freight resumes identically to foreground progress")
 company(3)
 game.state.buildings[5].position=[310,220]
 game.simulate(200)
 check(game.state.stone.shipments.is_empty() and game.state.resources.stone==0,"An unreachable quarry cannot teleport raw stock to a factory")
 company(3)
 game.state.resources.stone=game.capacity()
 factory=StoneIndustry.site(game.state,6)
 factory.stock.stone=5
 StoneIndustry.dispatch(game.state,game.stone_route_cache)
 check(game.state.stone.shipments.is_empty() and factory.stock.stone==5,"A full warehouse does not dispatch or delete finished output")
 game.state.resources.stone=game.capacity()-5
 StoneIndustry.dispatch(game.state,game.stone_route_cache)
 check(game.state.stone.shipments.size()==2 and game.state.stone.shipments[0].amount==4 and game.state.stone.shipments[1].amount==1,"A four-unit full load and a one-unit partial load use two actual vehicles without over-reservation")
 var load=game.state.stone.shipments[0]
 check(not game.move_building(6,Vector3(20,0,52)),"An active mineral source remains fixed until its truck returns")
 game.state.resources.stone=game.capacity()
 game.simulate(float(load.travel)+1)
 check(not load.arrived and load.age==load.travel,"A warehouse filled during transit makes the loaded truck wait safely")
 game.state.resources.stone-=4
 game.step(1)
 check(load.arrived and game.state.resources.stone==game.capacity(),"Making room unloads the retained cargo exactly once")
 var bought=game.state.coins
 game.state.boosters.money={"factor":5,"left":600}
 var price=game.stone_trader_price("stone")
 game.state.resources.stone=0
 check(game.buy_stone_material("stone",1) and game.state.coins==bought-price,"Material trader charges the displayed real price")
 game.sell("stone")
 check(game.state.coins<bought,"Boosters cannot turn emergency material purchases into a money exploit")
 company(3)
 game.state.buildings.append({"kind":"quarry","level":1,"paused":false,"position":[44,-12]})
 game.state.buildings.append({"kind":"stoneworks","level":1,"paused":false,"position":[-44,20]})
 StoneIndustry.synchronize(game.state)
 game.set_stone_recipe(8,"gravel")
 game.simulate(1200)
 check(game.state.resources.stone>0 and game.state.resources.gravel>0,"Several independently configured factories receive useful freight without permanently starving the second site")
 company(1)
 game.state.buildings.append({"kind":"furniture","level":1,"paused":false,"position":[-20,20]})
 game.state.resources.wood=120
 game.start_delivery()
 game.simulate(1600)
 check(game.state.delivery.sold>0 and game.state.resources.stone>0,"One bought truck alternates wood and mineral work without starving either business")
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 for i in 3: await process_frame
 var quarry_model=null
 for node in scene.world_buildings.get_children():
  if node.get_meta("kind","")=="quarry": quarry_model=node; break
 check(quarry_model!=null and quarry_model.get_node_or_null("Excavator")!=null,"A completed quarry has its own articulated mining excavator")
 check(scene.delivery_world.badges.size()==6,"The two mineral stock counters join the four wood counters")
 scene.hud.open_menu("stone")
 check(scene.hud.modal_title.text=="STEINBRUCH & BAUSTOFFE","The mining chapter has an accessible working mobile menu")
 scene.begin_placement({"kind":"stoneworks","city":false,"index":-1})
 check("Später per LKW" in scene.hud.placement_materials.text,"New construction shows its actual material needs before payment")
 check(game.state.jobs.is_empty(),"A material preview creates neither a purchase nor a construction job")
 scene.cancel_placement()
 scene.queue_free()
 await process_frame
 print("STONE INDUSTRY: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
