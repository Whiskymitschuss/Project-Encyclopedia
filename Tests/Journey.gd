extends SceneTree
var checks=0
var failures=[]
var game
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func fresh() -> void:
 game.state=game.initial_state()
 game.state.city_services.enabled=false
 game.return_report={}
 game.town_route_cache.clear()
 game.delivery_route_cache.clear()
 game.city_route_cache.clear()
 game.stone_route_cache.clear()
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 fresh()
 check(Journey.CHAPTERS.size()==10,"Ten complete chapters exist")
 check(Journey.current(game.state).id=="roots:0","Fresh game starts at a small actionable goal")
 check(not game.claim_journey("roots:0") and not game.home_available("townhall"),"No unearned reward or early town-hall bypass")
 for i in 5: game.chop()
 check(game.claim_journey("roots:0"),"Five real trees earn the first reward")
 var coins=game.state.coins
 check(not game.claim_journey("roots:0") and game.state.coins==coins,"A repeated reward tap cannot duplicate coins")
 game.deposit()
 check(game.claim_journey("roots:1"),"A real backpack deposit counts")
 game.sell("wood",0.25)
 check(game.claim_journey("roots:2"),"A real sale completes the third task")
 check(game.home_available("townhall") and Journey.current(game.state).id=="roots:hall","First hall unlocks after the actual tasks")
 var hall_started=game.order_home("townhall",0)
 check(hall_started,"The early town hall needs no unavailable prefab industry")
 check(Journey.townhall_level(game.state)==0 and game.state.jobs[0].has("phases"),"Town hall is a real material construction site")
 check(int(game.state.jobs[0].plot)==Journey.HALL_PLOT and game.next_city_plot()==0,"Civic construction leaves every residential plot available")
 check(not game.order_home("townhall",1),"Only one town hall including in-progress orders is allowed")
 check(not game.claim_journey("roots:hall"),"A construction order never counts as a finished town hall")
 var first_finished=-1
 for t in 1800:
  game.step(1)
  if Journey.townhall_level(game.state)==1: first_finished=t; break
 check(first_finished>=0,"First chapter finishes with actual starter income, production, workers and truck")
 print("JOURNEY PROGRESSION: first town hall in ",first_finished," simulated seconds without grants")
 check(float(game.state.journey.stats.get("shipments",0))>0,"Actual site arrivals count")
 check(game.claim_journey("roots:hall") and game.state.journey.trophies==["roots"],"Only finished hall awards the first permanent trophy")
 check(not game.upgrade_home(0),"Second hall is gated by second-chapter tasks")
 check(UXRules.upgrade_bill(game.state,true,0).is_empty(),"Group or context quote cannot bypass a locked chapter")
 var saved=JSON.parse_string(JSON.stringify(game.snapshot(),"",true,true))
 var material_before=game.state.resources.duplicate(true)
 game.restore(saved)
 check(game.state.journey.claimed.has("roots:hall") and game.state.journey.selected=="roots","JSON reload retains rewards and selected title")
 for key in material_before: check(is_equal_approx(float(game.state.resources[key]),float(material_before[key])),"Reload leaves real stock intact: "+key)
 check(not game.claim_journey("roots:hall"),"Reload cannot re-award a chapter")
 check(game.claim_journey("sawmill:0"),"Starter sawmill genuinely produced the next chapter's boards")
 if game.state.coins<game.cost_for("sawmill",2): game.sell("boards",0.5)
 check(game.upgrade(1),"Early progression can fund its sawmill upgrade")
 for i in 2:
  if game.state.coins<game.hire_cost(): game.sell("boards",0.5)
  if game.state.coins<game.hire_cost(): game.sell("wood",0.5)
  check(game.hire(),"Early progression can afford its workers through real sales")
 game.simulate(30)
 check(game.claim_journey("sawmill:1") and game.claim_journey("sawmill:2"),"Actual upgrade and hires satisfy chapter two")
 if game.state.coins<Journey.hall_cost(2): game.sell("boards",0.5)
 if game.state.coins<Journey.hall_cost(2): game.sell("wood",0.5)
 check(game.upgrade_home(0),"Second town hall stage is affordable without grants")
 for t in 1200:
  game.step(1)
  if Journey.townhall_level(game.state)==2: break
 check(game.claim_journey("sawmill:hall"),"Second chapter finishes using actual starter economy")
 print("JOURNEY PROGRESSION: second town hall at ",int(game.state.elapsed)," seconds, no grants")

 # Production is counted on output creation, never by buying or moving stock.
 fresh()
 check(game.accept_commission("boards"),"An achievable production commission is selectable")
 check(not game.accept_commission("wood"),"Only one optional commission can be active")
 game.state.resources.boards=40
 check(Journey.order_progress(game.state)==0,"Existing warehouse stock is not new production")
 game.simulate(120)
 check(Journey.order_progress(game.state)==30,"Actual shared-recipe production advances the accepted order")
 coins=game.state.coins
 check(game.claim_commission() and game.state.coins==coins+140,"Only completed commission pays its displayed reward")
 check(not game.claim_commission(),"Commission reward pays once")
 check(game.accept_commission("wood"),"Next chosen commission is available")
 check(Journey.order_progress(game.state)==0,"The next commission starts with a fresh saved baseline")
 game.simulate(10)
 var progress=Journey.order_progress(game.state)
 game.restore(JSON.parse_string(JSON.stringify(game.snapshot(),"",true,true)))
 check(is_equal_approx(Journey.order_progress(game.state),progress),"Accepted order and baseline survive JSON")
 game.cancel_commission()
 check(game.state.journey.active.is_empty(),"Cancel is free and grants no reward")
 check(game.accept_commission("boards"),"Canceled choices remain available without a paid reroll")
 var baseline=Journey.order_progress(game.state)
 game.state.resources.boards=game.capacity()
 game.simulate(10)
 check(Journey.order_progress(game.state)==baseline,"Full output stops production and commission progress")
 fresh()
 for i in 3: game.state.journey.claimed[Journey.goal_id(0,i)]=true
 for i in 4: game.state.homes.append({"kind":"park","level":1,"plot":i})
 check(game.next_city_plot()<0 and game.home_available("townhall"),"Even a full existing zero-population town can start its civic project")
 check(game.order_home("townhall",-1),"Dedicated civic slot prevents a blocked region/population dependency")

 # The physically transported line reports newly created output too.
 fresh()
 game.state.buildings.append({"kind":"furniture","level":1,"paused":false,"position":[-44,-12]})
 check(game.start_delivery(),"Physical chain starts for commission validation")
 check(game.accept_commission("boards"),"Physical sawmill can take production order")
 game.simulate(180)
 check(float(game.state.journey.stats.get("boards",0))>0,"Physical production contributes actual newly produced boards")
 var ship_count=float(game.state.journey.stats.get("shipments",0))
 game.state.delivery.paused=true
 game.simulate(10)
 check(game.state.journey.stats.get("shipments",0)==ship_count,"Paused deliveries and empty returns create no fake arrivals")

 # Migration has no made-up production or payouts.
 fresh()
 var legacy=game.snapshot()
 legacy.erase("journey")
 legacy.trees=27
 legacy.gathered=900
 legacy.exported=15
 var old_coins=legacy.coins
 game.restore(legacy)
 check(Journey.value(game.state,"trees")==27 and Journey.value(game.state,"boards")==0,"Legacy migration reuses only documented historical counters")
 check(game.state.coins==old_coins and game.state.journey.claimed.is_empty(),"Migration does not silently award coins or trophies")

 # Saved offline work and same-process background resume are never paid twice.
 fresh()
 var before=Journey.resume_capture(game.state)
 game.simulate(90)
 var report=Journey.resume_report(game.state,before,90)
 check(report.boards>0 and report.completed==0 and report.coins==game.state.coins-before.coins,"Return report reflects actual simulation results")
 coins=game.state.coins
 var stock=game.state.resources.duplicate(true)
 var second_report=Journey.resume_report(game.state,before,90)
 check(game.state.coins==coins and game.state.resources==stock and report==second_report,"Reading return report cannot pay twice")
 game.paused_at=1000
 game.pause_capture=Journey.resume_capture(game.state)
 game.simulate(10)
 var elapsed=game.state.elapsed
 game.resume_company(1090)
 check(is_equal_approx(float(game.state.elapsed),float(elapsed)+80),"Resume subtracts the ten seconds already simulated in background")
 elapsed=game.state.elapsed
 game.resume_company(1090)
 check(game.state.elapsed==elapsed and game.paused_at==0,"Repeated resume cannot simulate the same absence twice")
 game._process(5)
 check(game.state.elapsed==elapsed,"First resumed frame cannot count its stale background delta again")
 game._process(1)
 check(game.state.elapsed==elapsed+1,"Normal live simulation continues on the next frame")
 fresh()
 game.state.homes=[{"kind":"house","level":1,"plot":0,"rent_bank":0.0},{"kind":"townhall","level":2,"plot":1}]
 game.simulate(10)
 check(is_equal_approx(float(game.state.homes[0].rent_bank),20.8),"Completed town hall adds its actual four-percent city administration rent bonus")

 # A high-progress fixture validates every gate, real construction and quote.
 fresh()
 game.state.coins=1000000
 game.state.company_xp=3000
 game.state.workers=3
 game.state.trucks=3
 game.state.vehicle=4
 game.state.unlocked=5
 game.state.town.districts=1
 game.state.region=2
 game.state.auto_export=false
 for kind in ["kiln","furniture","prefab","quarry","stoneworks","sawmill","sawmill"]:
  var p=game.free_position(Catalog.industry_position(game.state.buildings.size()))
  game.state.buildings.append({"kind":kind,"level":1,"paused":false,"position":[p.x,p.z]})
 game.state.buildings[1].level=2
 game.state.homes.append({"kind":"apartments","level":10,"plot":1,"position":[-20,84]})
 check(game.start_delivery(),"Advanced chapter fixture connects its real wood line")
 for b in game.state.buildings: b.paused=true
 for key in ["trees","deposited","sales","boards","exported","shipments","shop_orders","rent","stone_delivered","services"]: Journey.add(game.state,key,2500)
 game.state.town.roads.append({"kind":"path","cells":[[120,160],[124,160]]})
 Journey.refresh(game.state)
 for c in Journey.CHAPTERS.size():
  check(Journey.current(game.state).id==Journey.goal_id(c,0),"Chapter order is sequential: "+str(c+1))
  check(not Journey.hall_unlocked(game.state,c+1),"Chapter cannot be skipped before all task claims")
  for i in Journey.CHAPTERS[c].goals.size(): check(game.claim_journey(Journey.goal_id(c,i)),"Real fixture fulfills chapter task: %s/%s" % [c+1,i+1])
  check(Journey.hall_unlocked(game.state,c+1),"All three real tasks unlock this hall level")
  for key in Catalog.RESOURCES: game.state.resources[key]=500
  var bill=UXRules.upgrade_bill(game.state,true,Journey.townhall_index(game.state)) if c>0 else {}
  check(c==0 or (not bill.is_empty() and bill.materials==Journey.hall_materials(c+1)),"Group and individual upgrade material quotes agree")
  var paid=game.state.coins
  var started=game.order_home("townhall",0) if c==0 else game.upgrade_home(Journey.townhall_index(game.state))
  check(started and is_equal_approx(paid-float(game.state.coins),Journey.hall_cost(c+1)),"Correct hall price charged once for stage: "+str(c+1))
  check(not game.claim_journey(Journey.hall_id(c)),"Unfinished upgrade cannot complete this chapter")
  if c==4:
   var snapshot=JSON.parse_string(JSON.stringify(game.snapshot(),"",true,true))
   game.restore(snapshot)
  for t in 1500:
   game.step(1)
   if t==1000 and not game.state.jobs.is_empty(): print("HALL WAIT ",c+1," ",ConstructionRules.status(game.state.jobs[0])," ",game.state.jobs[0].delivered," cargo ",game.state.construction_shipments.size())
   if Journey.townhall_level(game.state)>=c+1: break
  check(Journey.townhall_level(game.state)==c+1,"Real truck materials and construction finish hall stage: "+str(c+1))
  print("HALL STAGE ",c+1," · elapsed ",int(game.state.elapsed)," · remaining jobs ",game.state.jobs.size())
  check(game.claim_journey(Journey.hall_id(c)),"Finished hall completes chapter: "+str(c+1))
  check(game.state.journey.trophies.size()==c+1,"Permanent chapter trophy added exactly once")
 check(Journey.current(game.state).is_empty(),"Ten chapters have a real ending")
 check(not game.upgrade_home(Journey.townhall_index(game.state)),"Hall has no invented eleventh level")
 check(Journey.value(game.state,"homes")==1,"Town hall never masquerades as an inhabited house")
 game.state.homes[0].level=1
 check(Journey.value(game.state,"home_level")==1,"Town-hall level never fulfills residential skyline goals")
 check(game.select_trophy("empire") and not game.select_trophy("unearned"),"Only genuinely earned titles can be selected")
 game.state.earned=game.prestige_requirement()
 check(game.prestige(),"Fixture can prestige")
 check(game.state.journey.trophies.size()==10 and game.state.journey.selected=="empire","Prestige preserves all earned trophies and selected title")
 check(Journey.current(game.state).is_empty() and game.state.journey.active.is_empty(),"Prestige never farms old chapter rewards or leaves a stale commission")
 for key in Catalog.RESOURCES: check(game.state.resources[key]>=0,"No negative stock after chapter reset: "+key)
 print("JOURNEY: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
