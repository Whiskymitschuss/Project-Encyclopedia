extends SceneTree
var game
var checks = 0
var failures = []

func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func _initialize() -> void: call_deferred("run")
func fresh() -> void:
 game.state = game.initial_state()
 game.state.tutorial = 5
 game.state.construction_intro=true
 game.state.workers = 0
 game.flow.clear()
 game.tick_clock = 0
 game.delivery_route_cache.clear()
func company() -> void:
 fresh()
 game.state.buildings.append({"kind":"furniture","level":1,"paused":false,"position":[-20,-12]})
 check(game.placement_reason(Vector3(-20,0,-12),0,5).is_empty(),"Line factory occupies a legal non-overlapping plot")
 check(game.start_delivery(),"A real four-building line can be assigned")
func wood_units() -> float:
 var data = game.state.delivery
 var result = float(game.state.resources.wood)+float(game.state.resources.boards)*2+float(game.state.resources.furniture)*4+int(data.sold)*4
 result+=SawmillProduction.pending_total(game.state)*2
 for kind in data.buffers:
  var b=data.buffers[kind]
  result += float(b.wood)+float(b.boards)*2+float(b.furniture)*4
 for kind in data.recovered:
  for key in data.recovered[kind]: result+=float(data.recovered[kind][key])*({"wood":1,"boards":2,"furniture":4}[key])
 for s in data.shipments:
  if not s.arrived: result += float(s.amount)*({"wood":1,"boards":2,"furniture":4}[s.key])
 return result

func run() -> void:
 await process_frame
 game = root.get_node("Game")
 game.set_process(false)
 fresh()
 check(not game.start_delivery(),"Missing furniture factory blocks assignment without giving free buildings")
 check(not game.state.delivery.active,"Rejected start does not activate a partial line")
 game.state.coins=10000
 game.state.company_xp=120
 game.state.construction_auto=false
 check(game.order_building("furniture"),"A factory blueprint can start before materials are collected")
 var job = game.state.jobs[0]
 var duration = float(job.left)
 game.simulate(100)
 check(job.left==duration and game.count("furniture")==0,"Unfunded material stage never completes through elapsed time")
 check(job.delivered.is_empty(),"A stopped delivery stage has not consumed phantom materials")
 game.state.resources.wood=5
 check(game.deliver_job(int(job.id))==2,"A manual request loads only the current phase requirement")
 check(job.delivered.get("wood",0)==0 and game.state.resources.wood==3,"Loaded stock is deducted once and waits for its truck to arrive")
 check(game.deliver_job(int(job.id))==0,"Repeated tap cannot duplicate reserved material")
 game.simulate(50)
 check(job.delivered.get("wood",0)==2,"The material is credited only after the construction truck arrives")
 for key in job.materials: game.state.resources[key] = ConstructionRules.remaining(job,key)
 game.state.construction_auto=true
 for i in 500:
  game.step(1)
  if game.count("furniture")==1: break
 check(game.count("furniture")==1 and game.state.jobs.is_empty(),"All actual deliveries and seven construction phases finish the factory exactly once")
 check(game.upgrade(5),"Existing factories have material-based upgrades")
 var upgrade = game.state.jobs[0]
 var before_level=game.level("furniture")
 game.simulate(60)
 check(game.level("furniture")==before_level and upgrade.left==upgrade.total,"Missing upgrade material blocks completion")
 var saved = JSON.parse_string(JSON.stringify(game.snapshot()))
 game.restore(saved)
 check(game.state.jobs[0].materials==upgrade.materials,"Construction requirements survive JSON saving")
 game.state.jobs[0].delivered.test_copy=1
 check(not saved.jobs[0].delivered.has("test_copy"),"Restoring nested building material state uses deep copies")
 fresh()
 var legacy=game.snapshot()
 legacy.erase("delivery")
 legacy.erase("construction_auto")
 legacy.erase("next_job")
 legacy.jobs=[{"type":"upgrade","kind":"sawmill","index":1,"left":1.0,"total":12.0}]
 game.restore(legacy)
 game.step(1)
 check(game.state.buildings[1].level==2,"Already-paid old construction needs no new retroactive material")
 check(not game.state.delivery.active,"Old saves retain their original extended recipe operation")
 game.state.coins=500
 check(not game.buy_hardware("nuts",-1) and not game.buy_hardware("wood",1),"Depot rejects invalid orders")
 check(game.buy_hardware("nuts",1) and game.state.coins==492,"Hardware uses only the advertised coin cost")
 game.state.boosters.money={"left":120,"factor":5}
 game.sell("nuts")
 check(game.state.coins<=500,"Buying and reselling hardware cannot farm money boosts")
 company()
 var old_position=game.building_position(1)
 check(not game.move_building(1,Vector3(-40,0,116)) and game.building_position(1)==old_position,"An active delivery building cannot move underneath saved cargo routes")
 var routes=game.delivery_routes()
 check(routes.get("sawmill",[]).size()>1 and routes.get("furniture",[]).size()>1,"All production truck routes exist")
 check(routes.get("market",[]).size()>2,"Shop truck has a real street route")
 var cells=TownRules.road_cells(game.state.town)
 var road=routes.market
 for i in range(1,road.size()-1):
  check(cells.has(Vector2i(roundi(road[i][0]),roundi(road[i][2]))),"Truck route remains on drivable cells")
 game.state.resources.wood=80
 var total=wood_units()
 game.step(1)
 check(game.state.delivery.buffers.sawmill.wood==0,"Dispatch does not instantly arrive at the sawmill")
 check(game.state.resources.boards==0,"Assigned sawmill cannot also produce into the shared global stock")
 check(not game.state.delivery.shipments.is_empty(),"Wood leaves its source as a saved shipment")
 var shipment=game.state.delivery.shipments[0]
 check(shipment.amount>0 and not shipment.arrived and shipment.travel>=2,"Shipment carries real goods and takes travel time")
 check(absf(wood_units()-total)<0.0001,"Dispatch conserves all wood equivalents including in-transit goods")
 var midpoint=JSON.parse_string(JSON.stringify(game.snapshot()))
 for second in 460:
  game.step(1)
  check(absf(wood_units()-total)<0.0001,"All stages and shop sales conserve material: %s" % second)
  for kind in DeliveryChain.KINDS:
   for key in ["wood","boards","furniture"]:
    var stock=float(game.state.delivery.buffers[kind][key])
    check(stock>=0 and stock+DeliveryChain.reserved(game.state.delivery,kind,key)<=DeliveryChain.capacity(game.state,kind)+0.0001,"Local stock plus incoming reservations stays within capacity")
 check(game.state.delivery.sold>0 and game.state.exported==game.state.delivery.sold,"Only delivered furniture creates shop sales")
 check(game.state.delivery.on_time>0 and game.state.tickets>0,"A running modest line can earn an on-time order bonus")
 game.restore(midpoint)
 for i in 90: game.step(1)
 var online=game.state.duplicate(true)
 game.restore(midpoint)
 game.simulate(90)
 check(game.state==online,"Foreground, saved in-transit and offline logistics are identical")
 game.state.delivery.paused=true
 var frozen=game.state.delivery.duplicate(true)
 game.simulate(90)
 check(game.state.delivery.order==frozen.order and game.state.delivery.progress==frozen.progress,"Production pause freezes processing and the order deadline while already dispatched freight may finish")
 game.state.delivery.paused=false
 var order=game.state.delivery.order
 order.left=1
 order.delivered=0
 game.state.delivery.buffers.market.furniture=0
 game.state.delivery.shipments.clear()
 game.step(1)
 check(order.late and order.left==0,"Expired demand becomes late without debt or game over")
 game.state.delivery.buffers.market.furniture=1
 var coins=game.state.coins
 var tickets=game.state.tickets
 game.step(1)
 check(absf(game.state.coins-coins-65*0.7)<0.0001,"A late physical delivery earns 70 percent of base value")
 check(game.state.tickets==tickets,"Incomplete late deliveries cannot grant bonus tickets")
 var info=DeliveryChain.status(game.state,"sawmill")
 game.state.delivery.buffers.sawmill.wood=1
 info=DeliveryChain.status(game.state,"sawmill")
 check(info.amount==1 and info.need==2 and not info.ready,"Building material counter reads the actual 1/2 input")
 game.state.delivery.buffers.sawmill.wood=2
 info=DeliveryChain.status(game.state,"sawmill")
 check(info.ready and info.amount==2,"Building counter turns ready at 2/2")
 var before=wood_units()
 check(game.stop_delivery(),"Line can return its goods and restore the original recipes")
 check(not game.state.delivery.active,"Dissolving a line removes assignments")
 # Scene interaction: badges, real cargo and construction details are tappable.
 company()
 game.state.resources.wood=80
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 for i in 3: await process_frame
 game.step(1)
 await process_frame
 scene.delivery_world._process(0)
 check(scene.delivery_world.badges.size()==4,"Four material badges are attached to the real assigned buildings")
 check(scene.delivery_world.truck_visual_count>0,"A real economic wood shipment creates a loaded road vehicle")
 var badge=scene.delivery_world.badges[1]
 badge.button.pressed.emit()
 check(scene.hud.current=="building" and scene.hud.current_index==int(game.state.delivery.nodes.sawmill),"Tapping a material badge opens its building details")
 for menu in ["delivery","construction","contracts"]:
  scene.hud.open_menu(menu)
  await process_frame
  check(scene.hud.contents.get_child_count()>0,"Delivery chapter menu renders: "+menu)
 scene.hud.close_menu()
 game.state.delivery.buffers.furniture.furniture=2
 game.step(1)
 await process_frame
 scene.delivery_world._process(0)
 check(scene.delivery_world.truck_visual_count>0,"A saved furniture shipment creates a real cargo vehicle")
 game.state.coins=10000
 game.state.company_xp=120
 game.state.construction_intro=true
 check(game.order_building("garage"),"Scene can start a material-based construction site")
 check(scene.delivery_world.badges.size()==5,"A pending construction site has a tappable material badge")
 scene.delivery_world.badges[-1].button.pressed.emit()
 check(scene.hud.current=="construction","Construction badge opens the material depot and job details")
 scene.queue_free()
 await process_frame
 print("DELIVERY: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
