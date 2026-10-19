extends SceneTree

var checks = 0
var failures = []
var Game
var Store

func check(condition: bool, message: String) -> void:
 checks += 1
 if not condition:
  failures.append(message)
  printerr("FAILED: ",message)

func _initialize() -> void:
 call_deferred("run")

func fresh() -> void:
 Game.state = Game.initial_state()
 Game.tick_clock = 0
 Game.save_clock = 0

func close(a: float, b: float) -> bool:
 return absf(a-b) < 0.0001

func run() -> void:
 await process_frame
 Game = root.get_node("Game")
 Store = root.get_node("Store")
 Game.set_process(false)
 fresh()
 check(Catalog.BIOMES.size()==10,"Ten biomes")
 check(Catalog.TOOLS.size()==15,"Fifteen tool tiers")
 check(Catalog.HOMES.size()==10,"Ten city building types")
 check(Game.state.buildings.size()==5,"Fresh company has a working starter industry")
 Game.chop()
 check(Game.state.bag > 0,"Manual wood goes into bag")
 check(Game.state.resources.wood==0,"Manual harvesting does not bypass delivery")
 var carried = Game.state.bag
 Game.deposit()
 check(close(Game.state.resources.wood,carried) and Game.state.bag==0,"Delivery conserves resources")
 for i in 100: Game.chop()
 check(close(Game.state.bag,Game.bag_capacity()),"Bag cannot overfill")
 Game.state.resources.wood = Game.capacity()
 Game.deposit()
 check(Game.state.bag==Game.bag_capacity(),"Full warehouse keeps carried material")
 fresh()
 var initial_coins = float(Game.state.coins)
 check(not Game.order_building("furniture"),"Insufficient funds rejects build")
 check(Game.state.coins==initial_coins and Game.state.jobs.is_empty(),"Failed build is atomic")
 Game.state.coins = 10000
 var price = Game.cost_for("kiln")
 check(Game.order_building("kiln"),"Can order kiln")
 check(Game.level("kiln")==0,"Building cannot produce before completion")
 check(Game.state.coins==10000-price,"Build costs paid once")
 Game.simulate(50)
 check(Game.level("kiln")==1 and Game.state.jobs.is_empty(),"Timed construction completes")
 check(Game.state.coins==10000-price,"Construction does not pay itself or charge twice")
 var old_level = Game.level("sawmill")
 check(Game.upgrade(1),"Building upgrade starts")
 check(not Game.upgrade(1),"Duplicate upgrade rejected")
 check(Game.level("sawmill")==old_level,"Upgrade takes real time")
 Game.simulate(50)
 check(Game.level("sawmill")==old_level+1,"Building upgrade completes")
 fresh()
 Game.state.workers = 0
 Game.state.reserve = false
 Game.state.resources.wood = 20.0
 Game.simulate(1)
 check(close(Game.state.resources.wood,18.2),"Sawmill consumes two wood per cycle")
 check(close(Game.state.resources.boards,0.9),"Sawmill outputs boards")
 check(close(Game.state.resources.sawdust,0.9),"Sawmill recovers sawdust")
 fresh()
 Game.state.workers = 0
 Game.state.resources.wood = 20.0
 Game.state.resources.sawdust = Game.capacity()
 Game.state.auto_sawdust = true
 Game.step(1)
 check(close(Game.state.resources.boards,0.9),"Full sawdust buffer does not stop board production")
 check(close(Game.state.resources.wood,18.2),"Overflow production consumes real wood")
 check(close(Game.state.resources.sawdust,Game.capacity()),"Existing sawdust is preserved within capacity")
 check(close(Game.state.coins,350.45),"Only newly overflowing sawdust is sold")
 Game.state.resources.boards = Game.capacity()
 var stopped_wood = Game.state.resources.wood
 var stopped_coins = Game.state.coins
 Game.step(1)
 check(close(Game.state.resources.wood,stopped_wood) and close(Game.state.coins,stopped_coins),"Full main-product buffer still prevents waste and free overflow income")
 check("Lager voll" in Game.production_status(1),"Blocked main output has a visible explanation")
 fresh()
 Game.state.workers = 0
 Game.state.resources.wood = 20.0
 Game.state.resources.sawdust = Game.capacity()-0.2
 Game.state.auto_sawdust = true
 Game.step(1)
 check(close(Game.state.coins,350.35),"Partially full buffer sells exactly the overflow")
 fresh()
 Game.state.workers = 0
 Game.state.resources.wood = 20.0
 Game.state.resources.sawdust = Game.capacity()
 Game.state.buildings.append({"kind":"pellet","level":1,"paused":false})
 Game.step(1)
 check(close(Game.state.resources.sawdust,Game.capacity()-0.6),"Pellet consumption makes space before overflow is sold")
 check(close(Game.state.coins,350.0),"No overflow sale when downstream processing creates enough space")
 fresh()
 Game.state.coins = 329.0
 Game.state.tool = 5
 Game.state.workers = 8
 Game.state.trucks = 3
 Game.state.buildings[1].level = 6
 Game.state.buildings[2].level = 4
 for kind in ["kiln","furniture"]: Game.state.buildings.append({"kind":kind,"level":2,"paused":false})
 Game.state.resources.wood = Game.capacity()
 Game.state.resources.sawdust = Game.capacity()
 var legacy = JSON.parse_string(JSON.stringify(Game.snapshot()))
 Game.restore(legacy)
 check(Game.state.resources.sawdust==2500,"Legacy full warehouse loads without resetting the player")
 Game.simulate(180)
 check(Game.state.exported>0 and Game.state.coins>329,"Legacy stalled company resumes complete wood-to-export chain")
 check(Game.state.tool==5 and Game.state.workers==8 and Game.state.trucks==3,"Progress and equipment survive the production fix")
 var recovered = Game.snapshot()
 Game.restore(legacy)
 for i in 180: Game.step(1)
 check(Game.state.resources==recovered.resources and close(Game.state.coins,recovered.coins),"Overflow recovery works identically online and offline")
 fresh()
 Game.state.workers = 0
 Game.state.reserve = false
 Game.state.buildings.append({"kind":"kiln","level":1,"paused":false})
 Game.state.buildings.append({"kind":"furniture","level":1,"paused":false})
 Game.state.resources.boards = 50.0
 Game.state.resources.dry = 50.0
 Game.state.auto_export = false
 Game.simulate(1)
 check(close(Game.state.resources.boards,48.96),"Kiln and furniture consume shared boards")
 check(close(Game.state.resources.dry,50.02),"Kiln and furniture conserve dry wood")
 check(close(Game.state.resources.furniture,0.2),"Furniture recipe runs")
 Game.state.auto_export = true
 Game.simulate(1)
 check(Game.state.exported>0 and Game.state.coins>350,"Trucks export real stock")
 fresh()
 Game.state.workers = 0
 Game.state.resources.boards = 10
 Game.state.buildings.append({"kind":"kiln","level":5,"paused":false})
 Game.simulate(5)
 check(Game.state.resources.boards==10,"Construction reserve protects materials")
 fresh()
 Game.state.coins = 1e8
 Game.state.buildings.append({"kind":"prefab","level":1,"paused":false})
 var before = Game.state.duplicate(true)
 check(not Game.order_home("house",0),"House requires actual building materials")
 check(Game.state.coins==before.coins and Game.state.resources==before.resources,"Missing materials leaves all balances unchanged")
 for key in Catalog.HOMES.house.materials: Game.state.resources[key] = Catalog.HOMES.house.materials[key]
 check(Game.order_home("house",0),"Affordable home construction starts")
 check(not Game.order_home("house",0),"Cannot double-book city plot")
 check(Game.residents()==0,"Unfinished home has no residents")
 var coins_after_payment = Game.state.coins
 Game.simulate(60)
 check(Game.state.homes.size()==1 and Game.residents()==4,"Completed home adds residents")
 Game.simulate(10)
 check(Game.state.coins>coins_after_payment,"Completed home earns rent")
 fresh()
 Game.state.coins = 1e7
 check(not Game.research_buy("production"),"Research needs a real center")
 Game.state.buildings.append({"kind":"research","level":1,"paused":false})
 check(Game.research_buy("production"),"Research can be purchased")
 check(Game.research_level("production")==1,"Research level persisted")
 for i in 20: Game.research_buy("production")
 check(Game.research_level("production")==12,"Research has bounded level")
 fresh()
 Game.rng.seed = 12345
 Game.state.tickets = 100
 for i in 100:
  var reward = Game.open_loot()
  check(not reward.is_empty() and reward.rarity>=0 and reward.rarity<=5,"Valid loot reward")
 check(Game.state.tickets==0,"Every loot box consumes one ticket")
 var inventory = Game.state.inventory.duplicate()
 check(Game.open_loot().is_empty() and Game.state.inventory==inventory,"No free boxes without tickets")
 fresh()
 Game.state.diamonds = 0
 check(not Game.buy_booster("money"),"Booster requires currency")
 Game.state.diamonds = 20
 check(Game.buy_booster("money",5),"Fivefold booster can be purchased")
 check(Game.boost("money")==5,"Booster changes multiplier")
 Game.simulate(121)
 check(Game.boost("money")==1,"Boosters expire offline too")
 fresh()
 Game.state.trees = 25
 check(Game.claim_mission("trees"),"Mission reward claim")
 var rewarded = Game.state.coins
 check(not Game.claim_mission("trees") and Game.state.coins==rewarded,"Mission cannot be claimed twice")
 fresh()
 Game.state.resources.boards = 15
 check(Game.fulfill_contract(),"Contract consumes requested resource")
 check(Game.state.resources.boards==0 and Game.state.contracts==1,"Contract has one delivery and increments progression")
 fresh()
 Game.state.buildings.append({"kind":"kiln","level":4,"paused":false})
 Game.state.buildings.append({"kind":"furniture","level":3,"paused":false})
 Game.state.workers = 6
 var start = Game.state.duplicate(true)
 for i in 500: Game.step(1)
 var online = Game.state.duplicate(true)
 Game.restore(start)
 Game.simulate(500)
 check(Game.state==online,"Offline and foreground simulation are identical")
 for key in Game.state.resources:
  check(Game.state.resources[key]>=0 and Game.state.resources[key]<=Game.capacity(),"Resource stays within bounds: "+key)
 fresh()
 check(not Game.prestige(),"Premature prestige rejected")
 Game.state.earned = Game.prestige_requirement()
 Game.state.unlocked = 3
 Game.state.diamonds = 31
 Game.state.inventory = {"Titan-Skin":1}
 check(Game.prestige(),"Eligible company can prestige")
 check(Game.state.prestige==1 and Game.state.diamonds==31 and Game.state.inventory.has("Titan-Skin"),"Prestige keeps permanent rewards")
 check(Game.state.unlocked==1 and Game.state.homes.is_empty(),"Prestige resets local company")
 check(Game.difficulty()>1 and Game.multiplier()>1,"Prestige increases both cost and permanent reward")
 fresh()
 Game.state.coins = 1e7
 Game.state.inventory = {"Werkzeugteile":3,"Fahrzeugteile":4,"Gebäude-Skin: Modern":1}
 check(Game.craft_tool() and Game.state.tool==1 and Game.state.inventory.Werkzeugteile==0,"Tool parts produce a real upgrade")
 check(not Game.craft_tool(),"Crafting cannot spend missing parts")
 check(Game.craft_vehicle() and Game.state.vehicle==1,"Vehicle parts produce a real upgrade")
 check(Game.equip_skin("Gebäude-Skin: Modern") and Game.state.skin=="Modern","Owned building skin can be equipped")
 check(not Game.equip_skin("Titan-Skin"),"Unowned skins cannot be equipped")
 Game.state.tokens = 3
 check(Game.invest_tokens() and Game.state.permanent_loot==1 and Game.state.tokens==0,"Tokens buy a permanent loot improvement")
 fresh()
 Game.state.coins = 1e7
 Game.state.buildings.append({"kind":"prefab","level":1,"paused":false})
 check(not Game.order_home("house",4),"Unopened city region is protected")
 check(not Game.expand_region(),"Region requires residents")
 Game.state.homes.append({"kind":"house","level":1,"plot":0})
 check(Game.expand_region() and Game.state.region==1,"Population and investment unlock more land")
 Game.set_plan("house",1)
 check(not Game.state.plan.is_empty(),"A building goal can be saved")
 check(Game.reserve_for("furniture")==2,"Goal protects exactly its furniture need")
 for key in Catalog.HOMES.house.materials: Game.state.resources[key]=Catalog.HOMES.house.materials[key]
 Game.state.plan.auto = true
 Game.step(1)
 check(Game.state.plan.is_empty() and Game.state.jobs.size()==1,"Optional auto-order buys one affordable target")
 Game.simulate(100)
 check(Game.state.homes.size()==2 and Game.state.jobs.is_empty(),"Auto-order does not buy subsequent stages")
 fresh()
 Game.state.coins = 1e9
 for stage in 3:
  for key in Catalog.PROJECTS[0].materials:
   Game.state.resources[key] = float(Catalog.PROJECTS[0].materials[key])*(stage+1)
  check(Game.order_project(0),"Project stage starts")
  check(not Game.order_project(0),"Duplicate project stage rejected")
  Game.simulate(90)
  check(int(Game.state.projects.get("0",0))==stage+1,"Project advances exactly once")
 var project_coins = Game.state.coins
 Game.step(1)
 check(Game.state.coins>project_coins,"Completed project provides passive revenue")
 check(not Game.order_project(0),"Finished project cannot be bought repeatedly")
 fresh()
 Game.state.workers = 12
 Game.state.reserve = false
 for kind in ["kiln","furniture","prefab","paper","joinery","design"]:
  Game.state.buildings.append({"kind":kind,"level":3,"paused":false})
 Game.simulate(1800)
 check(Game.state.resources.walls>0 and Game.state.resources.roofs>0,"Prefab factory is not permanently starved by furniture")
 check(Game.state.resources.paper>0 and Game.state.resources.design>0,"Scarce input scheduling reaches later production branches")
 fresh()
 Game.state.workers = 0
 Game.state.reserve = false
 for kind in ["kiln","furniture","prefab","joinery","paper"]:
  Game.state.buildings.append({"kind":kind,"level":4,"paused":false})
 for key in Game.state.resources: Game.state.resources[key] = 1.0
 var fair_start = Game.state.duplicate(true)
 Game.step(1)
 var forward = Game.state.resources.duplicate()
 Game.restore(fair_start)
 Game.state.buildings.reverse()
 Game.step(1)
 for key in forward:
  check(close(float(forward[key]),float(Game.state.resources[key])),"Shared allocation is independent of building order: "+key)
 fresh()
 Game.state.coins = 12345.0
 check(Game.save(true),"Save can be written")
 Game.state.coins = 54321.0
 check(Game.save(true),"Save creates previous-state backup")
 check(Store.load_game().coins==54321,"Current save can be loaded")
 var bad = FileAccess.open(Store.PATH,FileAccess.WRITE)
 bad.store_string("invalid interrupted save")
 bad.close()
 check(Store.load_game().coins==12345,"Corrupt current save falls back to backup")
 fresh()
 print("RULES: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
