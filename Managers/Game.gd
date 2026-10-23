extends Node

signal sale_completed(material: String, coins: float, point: Vector3)
signal reward_claimed(title: String, coins: float)
signal fire_extinguished(point: Vector3)
signal back_requested
signal changed
signal shipment_delivered(point: Vector3, material: String, amount: float)
signal notice(message: String)
signal harvested(biome: int, amount: float)
signal rebuild_world
signal loot_found(rarity: int)
signal construction_phase_completed(job_id: int, phase: int)
signal company_level_unlocked(level: int)
signal construction_finished(point: Vector3, job_type: String)

var live_world=true
var state: Dictionary
var flow: Dictionary = {}
var tick_clock = 0.0
var save_clock = 0.0
var rng = RandomNumberGenerator.new()
var offline_report = ""
var return_report: Dictionary = {}
var paused_at = 0.0
var pause_capture: Dictionary = {}
var skip_resume_delta = false
var last_save_ok = true
var town_route_cache: Dictionary = {}
var city_route_cache: Dictionary = {}
var stone_route_cache: Dictionary = {}
var delivery_route_cache: Dictionary = {}
var delivery_route_signature = 0
var application_suspended=false
var pause_tree_was_paused=false
var simulation_only=false
var catching_up=false
var replay_worker: RefCounted
var replay_before={}
var replay_seconds=0.0
var replay_extension=0.0
var replay_paused_at=0.0
var replay_tree_was_paused=false
var replay_overlay: CanvasLayer
var stock_history=[]
var performance_results={}

func initial_state() -> Dictionary:
 var resources = {}
 for key in Catalog.RESOURCES: resources[key] = 0.0
 var buildings = []
 for kind in ["station","sawmill","warehouse","cabin","market"]:
  buildings.append({"kind":kind,"level":1,"paused":false})
 return {
  "schema":1, "onboarding":TutorialRules.initial(), "ux":UXRules.initial(), "journey":Journey.initial(), "coins":350.0, "diamonds":5, "tickets":0, "tokens":0, "cash":0,
  "resources":resources, "bag":0.0, "tool":0, "workers":1, "trucks":1, "vehicle":0,
  "biome":0, "unlocked":1, "buildings":buildings, "homes":[], "jobs":[],
  "research":{}, "inventory":{}, "boosters":{}, "projects":{}, "region":0,
  "hub":CentralLogistics.initial(), "crew":CrewTransport.initial(), "trade":ExportTrade.initial(), "stone":StoneIndustry.initial(), "city_services":CityServices.initial(), "company_xp":0, "builders":2, "construction_intro":false, "construction_shipments":[], "next_shipment":100000,
  "delivery":DeliveryChain.initial(), "construction_auto":false, "construction_logistics_version":1, "next_job":1,
  "town":TownRules.initial(), "plan":{}, "skin":"Rustikal", "skin_tool":"Holz", "permanent_loot":0,
  "prestige":0, "prestige_points":0, "trees":0, "gathered":0.0,
  "exported":0.0, "earned":0.0, "missions_claimed":{}, "contracts":0,
  "boss_hp":100.0, "bosses":0, "time":9.0, "elapsed":0.0, "weather":0,
  "quality":1, "reserve":true, "auto_export":true, "auto_sawdust":false, "tutorial":0, "muted":false, "companion_enabled":true, "ambient_enabled":true,
  "last_seen":Time.get_unix_time_from_system()}

func _ready() -> void:
 rng.randomize()
 changed.connect(func(): Journey.refresh(state))
 state = initial_state()
 apply_device_profile()
 var saved = Store.load_game()
 if not saved.is_empty():
  restore(saved)
  var offline = clampf(Time.get_unix_time_from_system() - float(state.last_seen),0.0,28800.0)
  var before = Journey.resume_capture(state)
  if offline>2 and DisplayServer.get_name()!="headless":
   start_replay(offline,before)
  else: simulate(offline)
  if offline > 60 and not catching_up:
   return_report=Journey.resume_report(state,before,offline)
   offline_report = "%s Min. offline · +%s Münzen" % [int(offline/60),Catalog.number(state.coins-float(before.coins))]
 get_tree().quit_on_go_back=false
 process_mode = Node.PROCESS_MODE_ALWAYS

func restore(saved: Dictionary) -> void:
 stock_history.clear()
 state = initial_state()
 for key in state:
  if saved.has(key):
   state[key] = saved[key].duplicate(true) if saved[key] is Dictionary or saved[key] is Array else saved[key]
 for key in CentralLogistics.initial():
  if not state.hub.has(key): state.hub[key]=CentralLogistics.initial()[key]
 for key in CrewTransport.initial():
  if not state.crew.has(key): state.crew[key]=CrewTransport.initial()[key]
 for key in TutorialRules.initial():
  if not state.onboarding.has(key): state.onboarding[key]=TutorialRules.initial()[key]
 for key in UXRules.initial():
  if not state.ux.has(key): state.ux[key]=UXRules.initial()[key]
 for key in Catalog.RESOURCES:
  if not state.resources.has(key): state.resources[key] = 0.0
 if not saved.has("tutorial"): state.tutorial = 5
 if not saved.has("company_xp"):
  state.company_xp = int(state.trees)*2+maxi(0,state.buildings.size()-5)*15+state.homes.size()*25
  for b in state.buildings: state.company_xp += maxi(0,int(b.level)-1)*8
  if count("furniture")>0: state.company_xp = maxi(120,int(state.company_xp))
 var town_defaults = TownRules.initial()
 for key in town_defaults:
  if not state.town.has(key): state.town[key] = town_defaults[key]
 if not saved.has("town"):
  state.town.rent_auto = true
  state.town.rent_manager = true
 town_route_cache.clear()
 delivery_route_cache.clear()
 delivery_route_signature = 0
 for key in DeliveryChain.initial():
  if not state.delivery.has(key): state.delivery[key] = DeliveryChain.initial()[key]
 DeliveryChain.migrate_belts(state)
 if int(saved.get("construction_logistics_version",0))<1:
  for job in state.jobs:
   if job.has("phases"): job.requested=true
 for job in state.jobs:
  # Explicit manual assignments already write auto_crew=false. Old individual
  # orders without a policy must not remain unstaffed forever after a handoff.
  if job.has("phases") and not job.has("auto_crew"): job.auto_crew=true
 for key in CityServices.initial():
  if not state.city_services.has(key): state.city_services[key]=CityServices.initial()[key]
 # Ampelwartung belongs to 0.29. Its zero-cargo technician missions have no
 # counterpart in 0.28; ordinary services, incidents and freight remain intact.
 state.city_services.missions=state.city_services.missions.filter(func(mission): return mission.kind!="technician")
 city_route_cache.clear()
 stone_route_cache.clear()
 for key in StoneIndustry.initial():
  if not state.stone.has(key): state.stone[key]=StoneIndustry.initial()[key]
 for key in ExportTrade.initial():
  if not state.trade.has(key): state.trade[key]=ExportTrade.initial()[key]
 ExportTrade.route_cache.clear()
 StoneIndustry.synchronize(state)
 Journey.migrate(state,saved)
 Journey.refresh(state)
 apply_device_profile()

func apply_device_profile() -> void:
 # Do not drive high-refresh Android screens at 90/120 FPS. Headless tests
 # deliberately remain uncapped; simulation still uses elapsed seconds.
 if not simulation_only and DisplayServer.get_name()!="headless":
  Engine.max_fps=30 if OS.has_feature("mobile") or int(state.quality)==0 else 60

func suspend_presentation() -> void:
 if application_suspended: return
 application_suspended=true
 pause_tree_was_paused=get_tree().paused
 get_tree().paused=true
 if DisplayServer.get_name()!="headless":
  Engine.max_fps=5
  RenderingServer.set_render_loop_enabled(false)

func resume_presentation() -> void:
 if not application_suspended: return
 application_suspended=false
 get_tree().paused=pause_tree_was_paused
 RenderingServer.set_render_loop_enabled(true)
 apply_device_profile()

func snapshot() -> Dictionary:
 var data = state.duplicate(true)
 data.last_seen = Time.get_unix_time_from_system()
 return data

func save(silent: bool = false) -> bool:
 if simulation_only: return true
 if catching_up: return false
 var previously_ok=last_save_ok
 last_save_ok = Store.save_game(snapshot())
 if silent and previously_ok and not last_save_ok: notice.emit("Speichern fehlgeschlagen · "+Store.last_error)
 if not silent: notice.emit("Spielstand gespeichert" if last_save_ok else Store.last_error)
 return last_save_ok

func _notification(what: int) -> void:
 if catching_up:
  if what==NOTIFICATION_APPLICATION_PAUSED:
   replay_paused_at=Time.get_unix_time_from_system()
   suspend_presentation()
  if what==NOTIFICATION_APPLICATION_RESUMED:
   resume_presentation()
   if replay_paused_at>0:
    replay_extension+=clampf(Time.get_unix_time_from_system()-replay_paused_at,0,maxf(0,28800-replay_seconds-replay_extension))
    replay_paused_at=0
  if what==NOTIFICATION_WM_GO_BACK_REQUEST: get_tree().quit()
  return
 if what==NOTIFICATION_WM_GO_BACK_REQUEST: back_requested.emit()
 if what == NOTIFICATION_APPLICATION_PAUSED:
  paused_at=Time.get_unix_time_from_system()
  pause_capture=Journey.resume_capture(state)
  suspend_presentation()
 if what == NOTIFICATION_APPLICATION_RESUMED: resume_presentation()
 if what == NOTIFICATION_APPLICATION_RESUMED and paused_at>0:
  resume_company(Time.get_unix_time_from_system(),DisplayServer.get_name()!="headless")
 if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
  save(true)

func resume_company(now: float, asynchronous: bool=false) -> void:
 if paused_at<=0 or pause_capture.is_empty(): return
 var gap=maxf(0,now-paused_at)
 # Some platforms continue processing briefly in the background. Subtract
 # those already simulated seconds instead of paying them a second time.
 var remaining=clampf(gap-(float(state.elapsed)-float(pause_capture.elapsed)),0,28800)
 if asynchronous and remaining>2:
  var before=pause_capture.duplicate(true)
  paused_at=0
  pause_capture={}
  start_replay(remaining,before)
  return
 simulate(remaining)
 if gap>60:
  return_report=Journey.resume_report(state,pause_capture,minf(gap,28800))
  offline_report="%s Min. offline · +%s Münzen" % [int(gap/60),Catalog.number(return_report.coins)]
 paused_at=0.0
 pause_capture={}
 skip_resume_delta=true
 changed.emit()
 save(true)

func _process(delta: float) -> void:
 if catching_up:
  poll_replay()
  return
 if application_suspended: return
 if not live_world: return
 if skip_resume_delta:
  # The OS may report the whole background interval as this frame's delta.
  # resume_company has already simulated it from the saved wall-clock gap.
  skip_resume_delta=false
  delta=0.0
 tick_clock += minf(delta,5.0)
 save_clock += delta
 if tick_clock >= 1.0:
  var steps = int(tick_clock)
  tick_clock -= steps
  for i in steps: step(1.0)
  track_materials()
  changed.emit()
 if save_clock >= 20.0:
  save_clock = 0.0
  save(true)

func simulate(seconds: float) -> void:
 for i in int(seconds): step(1.0)
 var rest = seconds - floorf(seconds)
 if rest > 0: step(rest)

func start_replay(seconds: float,before: Dictionary) -> void:
 if catching_up: return
 replay_before=before.duplicate(true)
 replay_seconds=seconds
 replay_extension=0
 replay_tree_was_paused=get_tree().paused
 catching_up=true
 get_tree().paused=true
 replay_worker=load("res://Managers/CompanyReplay.gd").new()
 if replay_worker.start(get_script(),state,seconds)!=OK:
  replay_worker.cancel()
  replay_worker=null
  catching_up=false
  get_tree().paused=replay_tree_was_paused
  simulate(seconds)
  return
 replay_overlay=load("res://UI/ReplayStatus.gd").new()
 add_child(replay_overlay)

func replay_progress() -> float:
 return replay_worker.progress() if replay_worker!=null else 1.0

func poll_replay() -> void:
 if not catching_up or application_suspended or not replay_worker.finished(): return
 var result=replay_worker.take()
 replay_worker=null
 if replay_extension>0.001:
  var extra=replay_extension
  replay_extension=0
  replay_seconds+=extra
  replay_worker=load("res://Managers/CompanyReplay.gd").new()
  if replay_worker.start(get_script(),result,extra)==OK: return
  replay_worker.cancel()
  replay_worker=null
  state=result
  simulate(extra)
 else: state=result
 catching_up=false
 get_tree().paused=replay_tree_was_paused
 replay_overlay.queue_free()
 replay_overlay=null
 stock_history.clear()
 if replay_seconds>60:
  return_report=Journey.resume_report(state,replay_before,replay_seconds)
  offline_report="%s Min. offline · +%s Münzen" % [int(replay_seconds/60),Catalog.number(return_report.coins)]
 skip_resume_delta=true
 changed.emit()
 rebuild_world.emit()
 save(true)

func _exit_tree() -> void:
 if replay_worker!=null: replay_worker.cancel()

func track_materials() -> void:
 if not stock_history.is_empty() and float(state.elapsed)-float(stock_history.back().at)<5: return
 var stock={}
 for key in Catalog.RESOURCES:
  var amount=UXRules.material_stock(state,key)
  stock[key]=amount.stored+amount.transit
 stock_history.append({"at":float(state.elapsed),"stock":stock})
 while stock_history.size()>13: stock_history.pop_front()

func material_trend(key: String) -> Dictionary:
 if stock_history.size()<2: return {"ready":false,"rate":0.0,"arrow":""}
 var first=stock_history.front()
 var last=stock_history.back()
 var seconds=float(last.at)-float(first.at)
 var rate=(float(last.stock.get(key,0))-float(first.stock.get(key,0)))*60/maxf(seconds,1)
 return {"ready":seconds>=5,"rate":rate,"arrow":"↗" if rate>0.5 else "↘" if rate< -0.5 else "→"}

func level(kind: String) -> int:
 var total = 0
 for b in state.buildings:
  if b.kind == kind: total += int(b.level)
 return total

func count(kind: String) -> int:
 var total = 0
 for b in state.buildings:
  if b.kind == kind: total += 1
 return total

func research_level(key: String) -> int:
 return int(state.research.get(key,0))

func capacity() -> float:
 return CentralLogistics.capacity(state)

func bag_capacity() -> float:
 return 40.0 + int(state.tool) * 25.0 + int(state.vehicle) * 80.0

func worker_capacity() -> int:
 return 3 + level("cabin") * 5 + int(residents()/4.0)

func residents() -> int:
 var total = 0
 for h in state.homes: total += int(Catalog.HOMES[h.kind].people) * int(h.level)
 return total

func public_level(kind: String) -> int:
 var total = 0
 for h in state.homes:
  if h.kind == kind: total += int(h.level)
 return total

func multiplier() -> float:
 return 1.0 + int(state.prestige) * 0.25

func difficulty() -> float:
 return pow(1.6,int(state.prestige))

func boost(key: String) -> float:
 var item = state.boosters.get(key,{})
 return float(item.get("factor",1.0)) if float(item.get("left",0.0)) > 0 else 1.0

func add_resource(key: String, amount: float) -> void:
 var current=float(state.resources.get(key,0))
 # An old surplus belongs to the player; a zero/positive award cannot erase it.
 state.resources[key]=maxf(0,current+amount) if amount<0 else current+minf(amount,maxf(0,capacity()-current))

func earn(amount: float) -> void:
 state.coins += amount
 state.earned += amount

func reserve_for(key: String,building_need: float=-1) -> float:
 if building_need<0: building_need=ConstructionRules.reserved_materials(state,key)
 if building_need>0: return maxf(building_need,float(plan_materials().get(key,0)))
 var planned = float(plan_materials().get(key,0))
 if not state.plan.is_empty(): return maxf(planned,10.0 if key == "boards" else 5.0 if key == "dry" else 0.0)
 if not state.reserve: return 0.0
 return {"boards":10.0,"dry":5.0,"furniture":4.0,"walls":2.0,"roofs":2.0,"parts":2.0,"paper":2.0}.get(key,0.0)

func processing_reserve_for(key: String) -> float:
 var needed=ConstructionRules.reserved_materials(state,key)
 return ConstructionRules.processing_reserve(state,key,-1,needed) if needed>0 else reserve_for(key,needed)

func production_status(index: int) -> String:
 if index < 0 or index >= state.buildings.size(): return ""
 var building = state.buildings[index]
 if building.kind=="station": return ForestryFlow.describe(state,index,flow).text
 if building.kind in ["central_depot","express"]: return "Warenannahme: %s · Lagerflotte: %s/%s frei · Baustellenflotte: %s/%s frei" % [Catalog.number(state.hub.receiving.values().reduce(func(total,value): return total+float(value),0.0)),CentralLogistics.available_trucks(state),CentralLogistics.fleet_size(state),maxi(0,CentralLogistics.fleet_size(state)-state.construction_shipments.size()),CentralLogistics.fleet_size(state)]
 if building.kind in StoneIndustry.KINDS: return StoneIndustry.status(state,index)
 if delivery_owns(index):
  if state.delivery.paused or building.get("paused",false): return "Pausiert · Produktion fortsetzen"
  var info = DeliveryChain.status(state,building.kind)
  if info.has("output_key"):
   return "Eingang: %s %s/%s · Ausgang: %s %s/%s · %s" % [Catalog.RESOURCES[info.key],Catalog.number(info.amount),info.need,Catalog.RESOURCES[info.output_key],Catalog.number(info.output_amount),info.output_capacity,info.text]
  return "Lieferbetrieb · %s %s/%s · %s" % [Catalog.RESOURCES[info.key],Catalog.number(info.amount),info.need,info.text]
 if not Catalog.RECIPES.has(building.kind): return "Betriebsbereit"
 if building.get("paused",false): return "Pausiert · Produktion fortsetzen"
 var recipe = Catalog.RECIPES[building.kind]
 for key in recipe.out:
  if key not in recipe.get("overflow_sell",[]) and (CentralLogistics.output_room(state,index,key)<=0.0001 if CentralLogistics.active(state) else float(state.resources[key]) >= capacity()-0.0001):
   return "%s-Ausgang voll · wartet auf Abholung" % Catalog.RESOURCES[key] if CentralLogistics.active(state) else "%s-Lager voll · verkaufen oder weiterverarbeiten" % Catalog.RESOURCES[key]
 for key in recipe["in"]:
  var local_inputs=FactorySupply.managed(state,index)
  var available=float(FactorySupply.stock(state,index).get(key,0)) if local_inputs else float(state.resources[key])-processing_reserve_for(key)
  if available<=0.0001:
   return "Wartet auf %s%s" % [Catalog.RESOURCES[key]," · automatischer Nachschub" if local_inputs and LogisticsDispatch.enabled(state) else " · Ware anfordern" if local_inputs else " (Baureserve geschützt)" if processing_reserve_for(key)>0 else ""]
 if float(flow.get("building:%s" % index,0))>0: return "Läuft · %.2f Zyklen/s" % float(flow["building:%s" % index])
 return "Bereit · startet mit dem nächsten Produktionstakt"

func step(delta: float) -> void:
 LogisticsDispatch.synchronize(state)
 CrewTransport.tick(state,delta)
 var stone_before=float(state.stone.delivered)
 var services_before=0
 for total in state.city_services.completed.values(): services_before+=int(total)
 var awaiting=[]
 for shipment in FreightFlow.all_trips(state):
  if not shipment.arrived: awaiting.append(shipment)
 var burning={}
 for incident in state.city_services.fires:
  burning[int(incident.id)]=CityServices.location(state,incident.target_ref)
 CityServices.tick(state,delta,city_route_cache)
 for incident in state.city_services.fires: burning.erase(int(incident.id))
 for point in burning.values(): fire_extinguished.emit(point)
 CentralLogistics.tick(state,delta)
 ConstructionRules.transport_tick(state,delta)
 state.elapsed += delta
 state.time = fmod(float(state.time) + delta / 60.0,24.0)
 state.weather = int(float(state.elapsed)/180.0) % 4
 for key in state.boosters:
  state.boosters[key].left = maxf(0,float(state.boosters[key].left)-delta)
 var harvest = (0.65 + int(state.tool)*0.13) * int(state.workers) * (1.0+int(state.biome)*0.3) * (1.0+research_level("forestry")*0.15) * boost("workers") * delta
 var forest=ForestryFlow.harvest(state,harvest,delta)
 var accepted=float(forest.amount)
 state.gathered += accepted
 Journey.add(state,"gathered",accepted)
 Journey.add(state,"automatic_wood",accepted)
 flow = {"harvest":accepted/maxf(delta,0.001)}
 for station in forest.sources: flow["harvest:%s" % station]=float(forest.sources[station])/maxf(delta,0.001)
 flow.merge(StoneIndustry.tick(state,delta,(1+research_level("production")*0.12)*multiplier()*boost("processing")),true)
 state.stone.ready=not StoneIndustry.requests(state,stone_route_cache).is_empty()
 # Load the current real phase before factories compete for a small fresh
 # harvest. Otherwise fractional processing can consume every new log forever.
 ConstructionRules.dispatch(state)
 var proposals = []
 var demand = {}
 var output_demand = {}
 var centralized=CentralLogistics.active(state)
 var production_capacity=capacity()
 var production_bonus=1+research_level("production")*0.12+minf(public_level("school")*0.04,0.5)
 for building_index in state.buildings.size():
  var b = state.buildings[building_index]
  if b.get("paused",false) or delivery_owns(building_index) or not Catalog.RECIPES.has(b.kind): continue
  var recipe = Catalog.RECIPES[b.kind]
  var cycles = float(recipe.speed)*int(b.level)*production_bonus*multiplier()*boost("processing")*delta
  var local_inputs=FactorySupply.managed(state,building_index)
  proposals.append({"kind":b.kind,"index":building_index,"recipe":recipe,"cycles":cycles,"local_inputs":local_inputs})
  for key in recipe["in"]:
   if not local_inputs: demand[key] = float(demand.get(key,0))+float(recipe["in"][key])*cycles
  for key in recipe.out:
   output_demand[key] = float(output_demand.get(key,0))+float(recipe.out[key])*cycles
 # Allocate scarce shared inputs proportionally from one common snapshot.
 # Apply all consumption before output: no factory depends on array ordering.
 var produced = {}
 var consumed = {}
 var processing_reserves={}
 for key in demand: processing_reserves[key]=processing_reserve_for(key) if float(state.resources[key])>0 else 0.0
 for proposal in proposals:
  var recipe = proposal.recipe
  var fraction = 1.0
  for key in recipe["in"]:
   if proposal.local_inputs: fraction=minf(fraction,float(FactorySupply.stock(state,int(proposal.index)).get(key,0))/maxf(float(recipe["in"][key])*float(proposal.cycles),0.0001))
   else: fraction = minf(fraction,maxf(0.0,float(state.resources[key])-float(processing_reserves[key]))/maxf(float(demand[key]),0.0001))
  for key in recipe.out:
   if fraction<=0: break
   if key in recipe.get("overflow_sell",[]): continue
   var room=CentralLogistics.output_room(state,int(proposal.index),key) if centralized else production_capacity-float(state.resources[key])
   var requested=float(recipe.out[key])*float(proposal.cycles) if centralized else float(output_demand[key])
   fraction = minf(fraction,room/maxf(requested,0.0001))
  var cycles = float(proposal.cycles)*maxf(0,fraction)
  for key in recipe["in"]:
   if proposal.local_inputs:
    var local_stock=FactorySupply.stock(state,int(proposal.index))
    local_stock[key]=maxf(0,float(local_stock.get(key,0))-float(recipe["in"][key])*cycles)
   else: consumed[key] = float(consumed.get(key,0))+float(recipe["in"][key])*cycles
  for key in recipe.out:
   var amount=float(recipe.out[key])*cycles
   if centralized and key!="sawdust":
    var output=CentralLogistics.stock(state,int(proposal.index))
    output[key]=float(output.get(key,0))+amount
    Journey.add(state,key,amount)
   else: produced[key] = float(produced.get(key,0))+amount
  flow[proposal.kind] = float(flow.get(proposal.kind,0))+cycles/maxf(delta,0.001)
  flow["building:%s" % proposal.index] = cycles/maxf(delta,0.001)
 for key in consumed: state.resources[key] = maxf(0,float(state.resources[key])-float(consumed[key]))
 for key in produced:
  var amount = float(produced[key])
  var excess = maxf(0.0,amount-maxf(0.0,capacity()-float(state.resources[key])))
  add_resource(key,amount)
  Journey.add(state,key,amount-excess)
  # Sawdust is a recoverable by-product, never a reason to stop sawing.
  # Sell only overflow; keep all existing stock for pellets and paper.
  if key == "sawdust" and excess > 0:
   if state.auto_sawdust:
    earn(excess*float(Catalog.PRICES.sawdust)*multiplier()*boost("money"))
    flow["sawdust_sold"] = excess/maxf(delta,0.001)
   else: flow["sawdust_composted"] = excess/maxf(delta,0.001)
 var export_report=ExportTrade.tick(state,delta)
 earn(float(export_report.coins))
 state.exported+=float(export_report.amount)
 Journey.add(state,"exported",float(export_report.amount))
 flow["export"]=float(export_report.amount)/maxf(delta,0.001)
 for receipt in export_report.receipts:
  sale_completed.emit(str(receipt.key),float(receipt.coins),LogisticsRoutes.vector(receipt.point))
 FactorySupply.maintain(state)
 FactorySupply.dispatch(state)
 var old_dispatch=int(state.delivery.next_id)
 step_delivery(delta)
 if int(state.delivery.next_id)>old_dispatch: state.stone.turn="stone"
 CentralLogistics.dispatch(state)
 ConstructionRules.dispatch(state)
 StoneIndustry.dispatch(state,stone_route_cache)
 if not state.trade.intro and float(state.resources.furniture)>=4:
  state.trade.intro=true
  UXRules.push_event(state,"highway:intro","Fernhandel bereit · Autobahn mit dem Markt verbinden",TownRules.point(ExportTrade.GATE),"export")
  notice.emit("Möbel bereit · lokal verkaufen oder Autobahn für Fernhandel anbinden")
 var export_key=str(state.trade.material)
 if export_key in ExportTrade.GOODS:
  var protected=reserve_for(export_key)+(4.0 if export_key=="furniture" and level("design")>0 else 0.0)
  ExportTrade.dispatch(state,protected,float(Catalog.PRICES[export_key])*ExportTrade.PREMIUM*multiplier()*boost("money"))
 var public_bonus = 1.0+Journey.townhall_level(state)*0.02
 for h in state.homes:
  if h.kind in ["park","clinic"]: public_bonus += 0.04*int(h.level)
 for h in state.homes:
  var rent = float(Catalog.HOMES[h.kind].rent)*int(h.level)*minf(public_bonus,2.0)*delta*multiplier()*boost("money")
  if state.town.rent_auto:
   earn(rent)
   Journey.add(state,"rent",rent)
  else: h.rent_bank = float(h.get("rent_bank",0.0))+rent
 step_transit(delta)
 for project_index in Catalog.PROJECTS.size():
  if int(state.projects.get(str(project_index),0)) >= 3:
   earn(float(Catalog.PROJECTS[project_index].income)*delta*multiplier()*boost("money"))
 var completed = []
 for j in state.jobs:
  if j.has("phases"):
   var old_phase = int(j.phase)
   var work = delta*(1+research_level("construction")*0.12+minf(public_level("fire")*0.05,0.5))*boost("workers")*maxi(0,CrewTransport.working(state,j))
   if ConstructionRules.advance(j,work): completed.append(j)
   if int(j.phase)!=old_phase: construction_phase_completed.emit(int(j.id),int(j.phase))
   continue
  if not ConstructionRules.ready(j):
   if state.construction_auto: ConstructionRules.deliver(state,j,4.0*delta)
   if not ConstructionRules.ready(j): continue
  j.left = maxf(0,float(j.left)-delta*(1+research_level("construction")*0.12+minf(public_level("fire")*0.05,0.5)))
  if j.left <= 0: completed.append(j)
 for j in completed:
  state.jobs.erase(j)
  finish_job(j)
 if allocate_group_crews(): rebuild_world.emit()
 CrewTransport.dispatch(state)
 if not state.plan.is_empty() and state.plan.get("auto",false):
  var plan = state.plan.duplicate(true)
  var affordable = state.coins >= float(Catalog.HOMES[plan.kind].cost)*difficulty()
  for key in plan_materials():
   affordable = affordable and float(state.resources[key]) >= float(plan_materials()[key])
  if affordable:
   if order_home(plan.kind,int(plan.plot)): state.plan = {}

 for shipment in awaiting:
  if shipment.arrived and not shipment.path.is_empty():
   Journey.add(state,"shipments")
   shipment_delivered.emit(LogisticsRoutes.vector(shipment.path.back()),str(shipment.key),float(shipment.amount))
 Journey.add(state,"stone_delivered",float(state.stone.delivered)-stone_before)
 var services_after=0
 for total in state.city_services.completed.values(): services_after+=int(total)
 Journey.add(state,"services",services_after-services_before)
 Journey.refresh(state)

func chop() -> void:
 if state.bag >= bag_capacity():
  notice.emit("Rucksack voll · zuerst abliefern")
  return
 var amount = minf(bag_capacity()-float(state.bag),(4.0+int(state.tool)*3.0)*(1+int(state.biome)*0.4))
 state.bag += amount
 state.gathered += amount
 state.trees += 1
 Journey.add(state,"trees")
 Journey.add(state,"gathered",amount)
 add_company_xp(2)
 if state.tutorial == 1 and int(state.trees)-int(state.onboarding.start_trees)>=5: state.tutorial = 2
 harvested.emit(int(state.biome),amount)
 if rng.randf() < 0.12*(1+research_level("loot")*0.08+int(state.permanent_loot)*0.1)*boost("loot")*multiplier():
  state.tickets += 1
  notice.emit("Loot-Ticket im Baum gefunden!")
 changed.emit()

func deposit() -> void:
 var room=CentralLogistics.storage_room(state,"wood") if CentralLogistics.active(state) else maxf(0,capacity()-float(state.resources.wood))
 var amount = minf(float(state.bag),room)
 if amount>0: add_resource("wood",amount)
 state.bag -= amount
 Journey.add(state,"deposited",amount)
 if state.tutorial == 2 and amount > 0: state.tutorial = 3
 notice.emit("%s Holz abgeliefert" % Catalog.number(amount))
 changed.emit()

func sell(key: String, fraction: float = 1.0) -> void:
 if not Catalog.PRICES.has(key): return
 var amount = float(state.resources[key])*clampf(fraction,0,1)
 state.resources[key] -= amount
 if amount>0: Journey.add(state,"sales")
 var revenue=amount*float(Catalog.PRICES[key])*0.5 if ConstructionRules.HARDWARE.has(key) else amount*float(Catalog.PRICES[key])*multiplier()*boost("money")
 earn(revenue)
 if amount>0:
  var point=Vector3.ZERO
  for i in state.buildings.size():
   if state.buildings[i].kind=="market": point=building_position(i); break
  sale_completed.emit(key,revenue,point)
 if state.tutorial == 3 and amount > 0: state.tutorial = 4
 if key == "furniture":
  state.exported += amount
  Journey.add(state,"exported",amount)
 notice.emit("%s %s verkauft" % [Catalog.number(amount),Catalog.RESOURCES[key]])
 changed.emit()

func cost_for(kind: String, next_level: int = 1) -> float:
 return ceilf(float(Catalog.BUILDINGS[kind].cost)*pow(1.24,next_level-1)*(1+count(kind)*0.4)*difficulty())

func pay(cost: float, materials: Dictionary = {}) -> bool:
 if state.coins + 0.0001 < cost:
  notice.emit("Es fehlen %s Münzen" % Catalog.number(cost-float(state.coins)))
  return false
 for key in materials:
  if float(state.resources.get(key,0))+0.0001 < float(materials[key]):
   notice.emit("Es fehlt: %s" % Catalog.RESOURCES.get(key,key))
   return false
 state.coins -= cost
 for key in materials: state.resources[key] -= float(materials[key])
 return true

func available(kind: String) -> bool:
 if kind=="central_depot":
  if count(kind)>0: return false
  for job in state.jobs:
   if job.type=="building" and job.kind==kind: return false
 if kind=="express": return count("central_depot")>0
 if kind in StoneIndustry.KINDS: return company_level()>=5
 if kind in ["prefab","joinery","pellet"]: return level("furniture") > 0
 if kind == "paper": return count("prefab") > 0
 if kind == "design": return count("paper") > 0 and count("joinery") > 0
 return true

func building_position(index: int) -> Vector3:
 var b = state.buildings[index]
 return Placement.position_of(b,Catalog.industry_position(int(b.get("slot",index))))

func home_position(index: int) -> Vector3:
 var h = state.homes[index]
 return Placement.position_of(h,Catalog.home_position(int(h.plot)))

func placement_reason(point: Vector3, rotation: int = 0, ignore_building: int = -1, ignore_home: int = -1,kind: String="") -> String:
 if kind.is_empty() and ignore_building>=0: kind=state.buildings[ignore_building].kind
 var reason=WorldAccess.building_reason(point,rotation,int(state.unlocked),kind)
 if not reason.is_empty(): return reason
 reason = Placement.terrain_reason(point,rotation,int(state.town.districts),kind)
 if not reason.is_empty(): return reason
 var rectangle = Placement.bounds(point,rotation,kind).grow(0.6)
 for project in Catalog.PROJECTS:
  if rectangle.intersects(Placement.bounds(project.position,0)): return "Projektstandort freihalten"
 for road in state.town.roads:
  var width = float(TownRules.TYPES[road.kind].width)/2.0+0.5
  for p in road.cells:
   if rectangle.grow(width).has_point(Vector2(TownRules.cell(p))): return "Eigene Straßen und Wege freihalten"
 for stop in state.town.stops:
  if rectangle.grow(7).has_point(Vector2(TownRules.cell(stop.cell))): return "Abstand zur Haltestelle halten"
 for i in state.buildings.size():
  if i == ignore_building: continue
  if rectangle.intersects(Placement.bounds(building_position(i),int(state.buildings[i].get("rotation",0)),state.buildings[i].kind)): return "Abstand zu anderen Gebäuden halten"
 for i in state.homes.size():
  if i == ignore_home: continue
  if rectangle.intersects(Placement.bounds(home_position(i),int(state.homes[i].get("rotation",0)))): return "Dieses Grundstück ist bereits bebaut"
 for job in state.jobs:
  if job.type not in ["building","home"]: continue
  var fallback = Catalog.industry_position(int(job.get("slot",0))) if job.type=="building" else Catalog.home_position(int(job.plot))
  if rectangle.intersects(Placement.bounds(Placement.position_of(job,fallback),int(job.get("rotation",0)),str(job.get("kind","")))): return "Hier wird bereits gebaut"
 return ""

func free_position(preferred: Vector3, rotation: int = 0, ignore_building: int = -1, ignore_home: int = -1,kind: String="") -> Vector3:
 var point = Placement.snap(preferred)
 if placement_reason(point,rotation,ignore_building,ignore_home,kind).is_empty(): return point
 var best = Vector3(INF,0,INF)
 var candidates=[]
 # Search nearby first, then every usable part of the mainland. Candidates use
 # the same validation as manual placement and never silently unlock a biome.
 for z in range(-164,169,8):
  for x in range(-296,297,8): candidates.append(Vector3(x,0,z))
 candidates.sort_custom(func(a,b): return a.distance_squared_to(preferred)<b.distance_squared_to(preferred))
 for candidate in candidates:
  if placement_reason(candidate,rotation,ignore_building,ignore_home,kind).is_empty():
   best=candidate
   break
 return best

func next_city_plot() -> int:
 var occupied={Journey.HALL_PLOT:true}
 for home in state.homes: occupied[int(home.plot)]=true
 for job in state.jobs:
  if job.type=="home": occupied[int(job.plot)]=true
 var plot=0
 while occupied.has(plot): plot+=1
 return plot

func move_reason(index: int, city: bool = false) -> String:
 var records=state.homes if city else state.buildings
 if index<0 or index>=records.size(): return "Gebäude nicht gefunden"
 if city and job_for("home_upgrade",index): return "Laufenden Hausausbau zuerst abschließen"
 if not city and (delivery_owns(index) or job_for("upgrade",index)):
  return "Vor dem Verschieben die Lieferlinie auflösen oder den laufenden Ausbau abschließen"
 if not city:
  for mission in state.crew.missions:
   if int(mission.origin)==index: return "Sprinter zuerst zur Arbeiterhütte zurückkehren lassen"
  for trip in state.hub.shipments:
   if int(trip.origin)==index or int(trip.destination)==index: return "Lager-LKW zuerst entladen und zurückkehren lassen"
  for trip in state.trade.shipments:
   if int(trip.origin)==index:
    return "Export-LKW zuerst zum Markt zurückkehren lassen"
 if not city and StoneIndustry.uses_building(state,index):
  return "Laufende Steinlieferung zuerst beenden lassen"
 # An unrelated construction delivery must not lock the entire city layout.
 if not city:
  for trip in state.construction_shipments:
   if int(trip.get("origin",-1))==index: return "Baustoff-LKW zuerst zu diesem Depot zurückkehren lassen"
 if CityServices.uses_building(state,index,city):
  return "Einsatz oder Stadtfahrt an diesem Gebäude zuerst beenden lassen"
 return ""

func move_building(index: int, point: Vector3, rotation: int = 0, city: bool = false, remember: bool=true) -> bool:
 var blocked=move_reason(index,city)
 if not blocked.is_empty(): notice.emit(blocked); return false
 var records = state.homes if city else state.buildings
 if index<0 or index>=records.size(): return false
 point = Placement.snap(point)
 var reason = placement_reason(point,rotation,-1 if city else index,index if city else -1)
 if not reason.is_empty(): notice.emit(reason); return false
 # A resident can choose another walk after their home is moved. This cancels
 # only the pedestrian trip, never a vehicle assignment or any economic cargo.
 var ref_type="home" if city else "building"
 state.city_services.walkers=state.city_services.walkers.filter(func(person):
  for ref in [person.source_ref,person.destination_ref]:
   if ref.type==ref_type and int(ref.index)==index: return false
  return true)
 var original=home_position(index) if city else building_position(index)
 var old_rotation=int(records[index].get("rotation",0))
 state.ux.move_undo={"index":index,"city":city,"kind":records[index].kind,"from":[original.x,original.z],"rotation":old_rotation,"to":[point.x,point.z],"new_rotation":posmod(rotation,360)} if remember else {}
 records[index].position = [point.x,point.z]
 records[index].rotation = posmod(rotation,360)
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func undo_building_move() -> bool:
 var last=state.ux.get("move_undo",{}).duplicate(true)
 if last.is_empty(): return false
 var records=state.homes if last.city else state.buildings
 var index=int(last.index)
 if index>=records.size() or records[index].kind!=last.kind: return false
 var current=home_position(index) if last.city else building_position(index)
 if current!=Vector3(float(last.to[0]),0,float(last.to[1])) or int(records[index].get("rotation",0))!=int(last.new_rotation): return false
 return move_building(index,Vector3(float(last.from[0]),0,float(last.from[1])),int(last.rotation),bool(last.city),false)

func order_building(kind: String, point: Variant = null, rotation: int = 0) -> bool:
 if not Catalog.BUILDINGS.has(kind) or not available(kind): return false
 var pending = 0
 for j in state.jobs:
  if j.type == "building": pending += 1
 var position_value = free_position(Catalog.industry_position((state.buildings.size()+pending)%16),rotation,-1,-1,kind) if point==null else Placement.snap(point)
 var reason = placement_reason(position_value,rotation,-1,-1,kind)
 if not reason.is_empty(): notice.emit(reason); return false
 if not pay(cost_for(kind)): return false
 var duration = 12.0+state.buildings.size()*2.0
 state.jobs.append({"id":state.next_job,"type":"building","kind":kind,"left":duration,"total":duration,"slot":state.buildings.size()+pending,"position":[position_value.x,position_value.z],"rotation":rotation,"materials":build_materials(kind) if company_level()>=4 else {},"delivered":{}})
 if company_level()>=4: ConstructionRules.attach(state.jobs.back(),1 if free_builders()>0 else 0)
 state.next_job += 1
 if state.tutorial == 4 or TutorialRules.phase(state)=="build":
  if state.onboarding.active: state.onboarding.job=int(state.jobs.back().id)
  state.tutorial = 5
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func job_for(type: String, index: int) -> bool:
 for j in state.jobs:
  if j.type == type and int(j.get("index",-1)) == index: return true
 return false

func upgrade(index: int, batch: bool = false) -> bool:
 if index < 0 or index >= state.buildings.size() or job_for("upgrade",index): return false
 var b = state.buildings[index]
 if b.level >= Catalog.BUILDINGS[b.kind].max: return false
 if not pay(cost_for(b.kind,int(b.level)+1)): return false
 state.jobs.append({"id":state.next_job,"type":"upgrade","index":index,"kind":b.kind,"left":10.0+int(b.level)*2.0,"total":10.0+int(b.level)*2.0,"materials":build_materials(b.kind,int(b.level)+1) if company_level()>=4 else {},"delivered":{}})
 if company_level()>=4: ConstructionRules.attach(state.jobs.back(),1 if free_builders()>0 else 0)
 state.next_job += 1
 if not batch:
  rebuild_world.emit()
  changed.emit()
  save(true)
 return true

func home_available(kind: String) -> bool:
 if not Catalog.HOMES.has(kind): return false
 if kind!="townhall": return level("prefab")>0
 if Journey.townhall_index(state)>=0 or not Journey.hall_unlocked(state,1): return false
 for job in state.jobs:
  if job.type=="home" and job.kind=="townhall": return false
 return true

func order_home(kind: String, plot: int, point: Variant = null, rotation: int = 0) -> bool:
 if not home_available(kind): return false
 if kind=="townhall": plot=Journey.HALL_PLOT
 elif plot < 0 or plot==Journey.HALL_PLOT: return false
 for h in state.homes:
  if int(h.plot) == plot: return false
 for j in state.jobs:
  if j.type == "home" and int(j.plot) == plot: return false
 var position_value = free_position(Catalog.home_position(0 if kind=="townhall" else plot),rotation) if point==null else Placement.snap(point)
 var reason = placement_reason(position_value,rotation)
 if not reason.is_empty(): notice.emit(reason); return false
 var definition = Catalog.HOMES[kind]
 var phased=company_level()>=4 or kind=="townhall"
 if not pay(float(definition.cost)*difficulty(),{} if phased else definition.materials): return false
 state.jobs.append({"type":"home","kind":kind,"plot":plot,"left":60.0,"total":60.0,"position":[position_value.x,position_value.z],"rotation":rotation})
 if phased:
  state.jobs.back().merge({"id":state.next_job,"materials":definition.materials.duplicate(true),"delivered":{}})
  ConstructionRules.attach(state.jobs.back(),1 if free_builders()>0 else 0)
  state.next_job+=1
 if state.tutorial==4: state.tutorial=5
 if not state.plan.is_empty() and (int(state.plan.plot)==plot or (kind=="townhall" and state.plan.kind==kind)): state.plan = {}
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func upgrade_home(index: int, batch: bool = false) -> bool:
 if index < 0 or index >= state.homes.size() or job_for("home_upgrade",index): return false
 var h = state.homes[index]
 if int(h.level) >= 10: return false
 if h.kind=="townhall" and not Journey.hall_unlocked(state,int(h.level)+1):
  notice.emit("Zuerst die Aufgaben im passenden Kapitel abschließen und abholen")
  return false
 var definition = Catalog.HOMES[h.kind]
 var materials = {}
 for key in definition.materials: materials[key] = ceilf(float(definition.materials[key])*0.5*int(h.level))
 var coins=float(definition.cost)*pow(1.4,int(h.level))*difficulty()
 if h.kind=="townhall":
  materials=Journey.hall_materials(int(h.level)+1)
  coins=Journey.hall_cost(int(h.level)+1)*difficulty()
 var phased=company_level()>=4 or h.kind=="townhall"
 if not pay(coins,{} if phased else materials): return false
 state.jobs.append({"type":"home_upgrade","kind":h.kind,"index":index,"plot":h.plot,"left":45.0,"total":45.0})
 if phased:
  state.jobs.back().merge({"id":state.next_job,"materials":materials.duplicate(true),"delivered":{}})
  ConstructionRules.attach(state.jobs.back(),1 if free_builders()>0 else 0)
  state.next_job+=1
 if not batch:
  rebuild_world.emit()
  changed.emit()
  save(true)
 return true

func finish_job(job: Dictionary) -> void:
 if int(job.get("id",-2))==int(state.onboarding.job): state.onboarding.finished=true
 Journey.add(state,"completed")
 add_company_xp(25 if job.type=="home" else 15 if job.type=="building" else 8)
 match job.type:
  "building": state.buildings.append({"kind":job.kind,"level":1,"paused":false,"slot":job.slot})
  "upgrade": state.buildings[int(job.index)].level += 1
  "home": state.homes.append({"kind":job.kind,"level":1,"plot":job.plot})
  "home_upgrade": state.homes[int(job.index)].level += 1
  "project": state.projects[str(int(job.index))] = int(state.projects.get(str(int(job.index)),0))+1
 if job.type in ["building","home"]:
  var record = state.buildings.back() if job.type=="building" else state.homes.back()
  if job.has("position"): record.position = job.position.duplicate()
  record.rotation = int(job.get("rotation",0))
 allocate_group_crews()
 StoneIndustry.synchronize(state)
 rebuild_world.emit()
 notice.emit("Bau abgeschlossen · %s" % job.kind)
 var point=Vector3.ZERO
 match job.type:
  "building": point=building_position(state.buildings.size()-1)
  "home": point=home_position(state.homes.size()-1)
  "upgrade": point=building_position(int(job.index))
  "home_upgrade": point=home_position(int(job.index))
  "project": point=Catalog.PROJECTS[int(job.index)].position
 var finished_name="Bauabschnitt"
 if job.type=="home": finished_name=UXRules.title(state,true,state.homes.size()-1)
 elif job.type=="home_upgrade": finished_name=UXRules.title(state,true,int(job.index))
 elif job.type=="building": finished_name=UXRules.title(state,false,state.buildings.size()-1)
 elif job.type=="upgrade": finished_name=UXRules.title(state,false,int(job.index))
 if job.type=="building" and job.kind=="central_depot":
  UXRules.push_event(state,"central:ready","Zentrallager bereit · weiß-blau holt am Betrieb ab, schwarz-weiß beliefert Baustellen. Abhol-Express für entfernte Bauplätze jetzt verfügbar.",point,"catalog")
 UXRules.push_event(state,"finished:%s:%s:%s" % [int(state.elapsed),job.type,int(job.get("id",job.get("index",-1)))],finished_name+" · fertiggestellt",point)
 construction_finished.emit(point,str(job.type))

func hire_cost() -> float:
 return ceilf(90.0*pow(1.33,int(state.workers))*difficulty())

func hire() -> bool:
 if state.workers >= worker_capacity():
  notice.emit("Mehr Wohnraum benötigt · Hütte oder Stadt ausbauen")
  return false
 if not pay(hire_cost()): return false
 state.workers += 1
 changed.emit()
 return true

func truck_cost() -> float:
 return ceilf(350.0*pow(1.7,int(state.trucks))*difficulty())

func buy_truck() -> bool:
 if int(state.trucks) >= 2+level("garage")*2:
  notice.emit("Garage ausbauen, um weitere Fahrzeuge zu kaufen")
  return false
 if not pay(truck_cost()): return false
 state.trucks += 1
 changed.emit()
 return true

func tool_cost() -> float:
 return ceilf(120.0*pow(2.15,int(state.tool))*difficulty())

func upgrade_tool() -> bool:
 if int(state.tool) >= Catalog.TOOLS.size()-1 or not pay(tool_cost()): return false
 state.tool += 1
 changed.emit()
 return true

func craft_tool() -> bool:
 var needed = 3+int(state.tool)*2
 if state.tool >= 14 or int(state.inventory.get("Werkzeugteile",0)) < needed:
  notice.emit("Nicht genug Werkzeugteile")
  return false
 state.inventory.Werkzeugteile -= needed
 state.tool += 1
 changed.emit()
 return true

func craft_vehicle() -> bool:
 var needed = 4+int(state.vehicle)*3
 if state.vehicle >= 9 or int(state.inventory.get("Fahrzeugteile",0)) < needed:
  notice.emit("Nicht genug Fahrzeugteile")
  return false
 state.inventory.Fahrzeugteile -= needed
 state.vehicle += 1
 changed.emit()
 return true

func plan_materials() -> Dictionary:
 if state.plan.is_empty(): return {}
 return Catalog.HOMES[state.plan.kind].materials

func set_plan(kind: String, plot: int) -> void:
 if not Catalog.HOMES.has(kind) or plot < 0 or plot==Journey.HALL_PLOT: return
 for home in state.homes:
  if int(home.plot)==plot: return
 state.plan = {"kind":kind,"plot":plot,"auto":false}
 changed.emit()
 notice.emit("Bauziel vorgemerkt · benötigte Vorräte bleiben geschützt")

func expand_region() -> bool:
 if state.region >= 2: return false
 var required_population = 4 if int(state.region)==0 else 20
 if residents() < required_population:
  notice.emit("Mindestens %s Bewohner für die nächste Region benötigt" % required_population)
  return false
 if not pay(6000.0*pow(5.0,int(state.region))*difficulty()): return false
 state.region += 1
 state.cash += 3
 changed.emit()
 return true

func order_project(index: int) -> bool:
 if index < 0 or index >= Catalog.PROJECTS.size() or job_for("project",index): return false
 var stage = int(state.projects.get(str(index),0))
 if stage >= 3: return false
 var definition = Catalog.PROJECTS[index]
 var materials = {}
 for key in definition.materials: materials[key] = float(definition.materials[key])*(stage+1)
 if not pay(float(definition.cost)*(stage+1)*difficulty(),materials): return false
 state.jobs.append({"type":"project","kind":"project","index":index,"left":90.0,"total":90.0})
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func equip_skin(item: String) -> bool:
 if int(state.inventory.get(item,0)) <= 0: return false
 match item:
  "Gebäude-Skin: Modern": state.skin = "Modern"
  "Gold-Axt-Skin": state.skin_tool = "Gold"
  "Titan-Skin": state.skin_tool = "Titan"
  _: return false
 rebuild_world.emit()
 changed.emit()
 return true

func invest_tokens() -> bool:
 if state.tokens < 3: return false
 state.tokens -= 3
 state.permanent_loot += 1
 changed.emit()
 return true

func vehicle_cost() -> float:
 return ceilf(500.0*pow(2.6,int(state.vehicle))*difficulty())

func upgrade_vehicle() -> bool:
 if state.vehicle >= 9 or not pay(vehicle_cost()): return false
 state.vehicle += 1
 changed.emit()
 return true

func unlock_biome() -> bool:
 var index = int(state.unlocked)
 if index >= Catalog.BIOMES.size(): return false
 if index == 9 and state.prestige == 0:
  notice.emit("Der Prestige-Hain benötigt eine neue Unternehmensära")
  return false
 if not pay(float(Catalog.BIOMES[index].cost)*difficulty()): return false
 state.unlocked += 1
 state.biome = index
 state.boss_hp = 100.0*pow(2.0,index)
 changed.emit()
 rebuild_world.emit()
 return true

func attack_boss() -> void:
 state.boss_hp -= pow(2.0,int(state.tool))*10.0
 if state.boss_hp <= 0:
  state.bosses += 1
  state.tickets += 3+int(state.biome)
  state.diamonds += 5
  earn(100.0*(int(state.biome)+1)*multiplier())
  state.boss_hp = 100.0*pow(2.0,int(state.biome))*pow(1.2,int(state.bosses))
  notice.emit("Bossbaum gefällt · Loot und Diamanten erhalten!")
 changed.emit()

func research_cost(key: String) -> float:
 return ceilf(400.0*pow(1.85,research_level(key))*difficulty())

func research_buy(key: String) -> bool:
 if not Catalog.RESEARCH.has(key) or level("research") < 1 or research_level(key) >= 12: return false
 if not pay(research_cost(key)): return false
 state.research[key] = research_level(key)+1
 changed.emit()
 return true

func open_loot() -> Dictionary:
 if state.tickets < 1:
  notice.emit("Keine Loot-Tickets · Bäume fällen oder Missionen abschließen")
  return {}
 state.tickets -= 1
 var roll = rng.randf()
 var rarity = 0
 for threshold in [0.50,0.78,0.93,0.985,0.999]:
  if roll >= threshold: rarity += 1
 var reward = int(5*pow(2.0,rarity))
 state.diamonds += rarity+1
 earn(reward*multiplier())
 var item = ["Werkzeugteile","Fahrzeugteile","Gold-Axt-Skin","Gebäude-Skin: Modern","Bauplan: Hightech","Titan-Skin"][rarity]
 state.inventory[item] = int(state.inventory.get(item,0))+1
 if rarity >= 3: state.tokens += 1
 notice.emit("%s · %s · +%s Münzen" % [Catalog.RARITIES[rarity],item,reward])
 loot_found.emit(rarity)
 changed.emit()
 save(true)
 return {"rarity":rarity,"item":item,"coins":reward}

func buy_booster(key: String, factor: float = 2.0) -> bool:
 if not key in ["money","loot","workers","processing"]: return false
 var cost = 5 if factor == 2.0 else 15
 if state.diamonds < cost:
  notice.emit("Nicht genug Diamanten")
  return false
 state.diamonds -= cost
 var existing = state.boosters.get(key,{"left":0.0,"factor":factor})
 state.boosters[key] = {"left":float(existing.left)+120.0,"factor":maxf(float(existing.factor),factor)}
 changed.emit()
 return true

func mission_definitions() -> Array:
 var tier = int(state.prestige)+1
 return [{"id":"trees","name":"Fälle %s Bäume" % (25*tier),"value":state.trees,"target":25*tier,"reward":300*tier},
 {"id":"gathered","name":"Sammle %s Holz" % (500*tier),"value":state.gathered,"target":500*tier,"reward":500*tier},
 {"id":"team","name":"Stelle fünf Arbeiter ein","value":state.workers,"target":5,"reward":700*tier},
 {"id":"mill","name":"Erreiche Sägewerk-Stufe 10","value":level("sawmill"),"target":10,"reward":1800*tier},
 {"id":"export","name":"Exportiere %s Möbel" % (100*tier),"value":state.exported,"target":100*tier,"reward":2500*tier},
 {"id":"city","name":"Baue dein erstes Stadthaus","value":Journey.value(state,"homes"),"target":1,"reward":3500*tier},
 {"id":"roads","name":"Baue deine erste eigene Straße oder einen Weg","value":state.town.roads.size(),"target":1,"reward":600*tier},
 {"id":"rent","name":"Hole 100 Münzen Miete ab","value":state.town.rent_collected,"target":100,"reward":700*tier},
 {"id":"bus","name":"Beende drei Bus-Rundfahrten","value":state.town.trips_total,"target":3,"reward":1200*tier},
 {"id":"district","name":"Erschließe ein neues Stadtviertel","value":state.town.districts,"target":1,"reward":10000*tier},
 {"id":"stone_delivery","name":"Liefere 50 Bausteine oder Kies ins Lager","value":state.stone.delivered,"target":50,"reward":2000*tier},
 {"id":"biomes","name":"Erschließe fünf Biome","value":state.unlocked,"target":5,"reward":7000*tier}]

func claim_mission(id: String) -> bool:
 if state.missions_claimed.has(id): return false
 for m in mission_definitions():
  if m.id == id and m.value >= m.target:
   state.missions_claimed[id] = true
   earn(m.reward)
   reward_claimed.emit("MISSION GESCHAFFT!",float(m.reward))
   state.diamonds += 5
   state.tickets += 2
   changed.emit()
   return true
 return false

func claim_journey(id: String) -> bool:
 Journey.refresh(state)
 var goal=Journey.current(state)
 if goal.is_empty() or goal.id!=id or not goal.ready: return false
 # Mark before signals/save so repeated taps or reopening never pay twice.
 state.journey.claimed[id]=true
 earn(float(goal.coins))
 var completed=int(goal.index)==-1
 if completed:
  var chapter=Journey.CHAPTERS[int(goal.chapter)]
  if chapter.id not in state.journey.trophies: state.journey.trophies.append(chapter.id)
  state.journey.selected=chapter.id
  state.diamonds+=3
  state.tickets+=1
  UXRules.push_event(state,"journey:"+chapter.id,"Kapitel geschafft · "+chapter.name,Vector3.ZERO,"journey")
 reward_claimed.emit("KAPITEL GESCHAFFT!" if completed else "ZIEL GESCHAFFT!",float(goal.coins))
 notice.emit("%s · +%s Münzen%s" % ["Kapitel geschafft!" if completed else "Ziel geschafft!",goal.coins," · neue Auszeichnung" if completed else ""])
 changed.emit()
 save(true)
 return true

func accept_commission(key: String) -> bool:
 if not state.journey.active.is_empty() or key not in Journey.choices(state): return false
 var order=Journey.COMMISSIONS[key].duplicate(true)
 order.key=key
 order.baseline=float(state.journey.stats.get(order.metric,0))
 state.journey.active=order
 changed.emit()
 save(true)
 return true

func claim_commission() -> bool:
 var order=state.journey.active
 if order.is_empty() or Journey.order_progress(state)+0.00001<float(order.target): return false
 state.journey.active={}
 state.journey.completed_orders=int(state.journey.completed_orders)+1
 earn(float(order.reward))
 # One deterministic ticket per three jobs; the payout is shown beforehand.
 if int(state.journey.completed_orders)%3==0: state.tickets+=1
 reward_claimed.emit("AUFTRAG ERFÜLLT!",float(order.reward))
 notice.emit("Auftrag erfüllt · +%s Münzen" % order.reward)
 changed.emit()
 save(true)
 return true

func cancel_commission() -> void:
 state.journey.active={}
 changed.emit()
 save(true)

func select_trophy(id: String) -> bool:
 if id!="" and id not in state.journey.trophies: return false
 state.journey.selected=id
 changed.emit()
 save(true)
 return true

func contract() -> Dictionary:
 var tier = int(state.contracts)
 var key = ["boards","dry","furniture","walls","paper","design"][mini(int(tier/3.0),5)]
 var amount = 15+int(tier)*4
 return {"key":key,"amount":amount,"reward":amount*float(Catalog.PRICES[key])*2.0}

func fulfill_contract() -> bool:
 var c = contract()
 if float(state.resources[c.key]) < c.amount:
  notice.emit("Für diesen Auftrag fehlen Materialien")
  return false
 state.resources[c.key] -= c.amount
 earn(float(c.reward)*multiplier())
 state.contracts += 1
 state.tickets += 1
 state.cash += 1
 changed.emit()
 return true

func prestige_requirement() -> float:
 return 250000.0*pow(2.5,int(state.prestige))

func prestige() -> bool:
 if float(state.earned) < prestige_requirement() or state.unlocked < 3:
  notice.emit("Prestige benötigt mehr Gesamteinnahmen und mindestens drei Biome")
  return false
 var old = state.duplicate(true)
 state = initial_state()
 town_route_cache.clear()
 delivery_route_cache.clear()
 delivery_route_signature = 0
 for key in ["diamonds","tokens","cash","inventory","skin","skin_tool","permanent_loot","companion_enabled","ambient_enabled","muted","quality","journey"]: state[key] = old[key]
 state.journey.active={}
 for preference in ["vibration","large_text","high_contrast","motion"]: state.ux[preference]=old.ux[preference]
 stone_route_cache.clear()
 state.city_services.enabled=bool(old.city_services.enabled)
 state.prestige = int(old.prestige)+1
 state.prestige_points = int(old.prestige_points)+1
 state.coins = 350.0*(1+int(state.prestige)*0.25)
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

# City expansion, rent and transit share the same saved economy as the factories.
func city_plot_count() -> int:
 return 4*(int(state.region)+1)+12*int(state.town.districts)

func district_cost() -> float:
 return 35000.0*pow(4.0,int(state.town.districts))*difficulty()

func expand_district() -> bool:
 if int(state.town.districts)>=2: return false
 if int(state.region)<2 or residents()<20:
  notice.emit("Zuerst drei Regionen und 20 Bewohner erreichen")
  return false
 if not pay(district_cost()): return false
 state.town.districts += 1
 town_route_cache.clear()
 delivery_route_cache.clear()
 delivery_route_signature = 0
 rebuild_world.emit()
 changed.emit()
 save(true)
 notice.emit("Viertelzufahrt erschlossen · vorhandenes Straßennetz erweitert")
 return true

func rent_total() -> float:
 var total = 0.0
 for h in state.homes: total += float(h.get("rent_bank",0.0))
 return total

func collect_rent(index: int = -1) -> float:
 if index < -1 or index>=state.homes.size(): return 0.0
 var amount = 0.0
 for i in state.homes.size():
  if index>=0 and i!=index: continue
  amount += float(state.homes[i].get("rent_bank",0.0))
  state.homes[i].rent_bank = 0.0
 if amount>0:
  state.town.rent_collected=float(state.town.rent_collected)+amount
  Journey.add(state,"rent",amount)
  earn(amount)
  changed.emit()
  save(true)
  notice.emit("%s Münzen Miete abgeholt" % Catalog.number(amount))
 return amount

func set_rent_auto(enabled: bool) -> bool:
 if enabled and not state.town.rent_manager:
  if not pay(2500.0*difficulty()): return false
  state.town.rent_manager = true
 collect_rent()
 state.town.rent_auto = enabled
 changed.emit()
 save(true)
 return true

func road_cost(kind: String, cells: Array) -> float:
 if not TownRules.TYPES.has(kind): return INF
 var existing = TownRules.road_cells(state.town)
 if kind=="path":
  for road in state.town.roads:
   for p in road.cells: existing[TownRules.cell(p)] = true
 var count_new = 0
 for c in cells:
  if not existing.has(c): count_new+=1; existing[c]=true
 return count_new*4.0*float(TownRules.TYPES[kind].price)*difficulty()

func road_reason(kind: String, cells: Array) -> String:
 if not TownRules.TYPES.has(kind) or cells.size()<2: return "Start und Ziel auf dem Land wählen"
 if state.town.roads.size()>=48: return "Maximal 48 Strecken · bestehende Wege verwalten"
 if cells.size()>61: return "Kürzere Abschnitte bauen · höchstens 240 Meter"
 var width = float(TownRules.TYPES[kind].width)/2.0+0.7
 var occupied = []
 for i in state.buildings.size(): occupied.append(Placement.bounds(building_position(i),int(state.buildings[i].get("rotation",0)),state.buildings[i].kind).grow(width))
 for i in state.homes.size(): occupied.append(Placement.bounds(home_position(i),int(state.homes[i].get("rotation",0))).grow(width))
 for job in state.jobs:
  if job.type in ["home","building"]:
   var fallback = Catalog.home_position(int(job.plot)) if job.type=="home" else Catalog.industry_position(int(job.slot))
   occupied.append(Placement.bounds(Placement.position_of(job,fallback),int(job.get("rotation",0)),str(job.get("kind",""))).grow(width))
 for project in Catalog.PROJECTS: occupied.append(Placement.bounds(project.position,0).grow(width))
 for i in cells.size():
  var c: Vector2i = cells[i]
  if c.x%4!=0 or c.y%4!=0: return "Am Straßenraster ausrichten"
  if i>0 and (absi(c.x-cells[i-1].x)+absi(c.y-cells[i-1].y))!=4: return "Nur zusammenhängende Strecken bauen"
  if not WorldAccess.LAND.encloses(Rect2(Vector2(c)-Vector2.ONE*width,Vector2.ONE*width*2)): return "Straßen müssen vollständig auf dem Land bleiben"
  for rectangle in occupied:
   if rectangle.has_point(Vector2(c)): return "Gebäude und Baustellen umfahren"
 var permanent=TownRules.road_cells(state.town)
 for c in cells:
  if permanent.has(c): continue
  if WorldAccess.HIGHWAY_SITE.grow(width).has_point(Vector2(c)) and (c.y!=176 or c.x>ExportTrade.GATE.x): return "Autobahnzufahrt freihalten · Anschluss bei 300 / 176"
  var land_reason=WorldAccess.land_reason(Rect2(Vector2(c)-Vector2.ONE*width,Vector2.ONE*width*2),int(state.unlocked))
  if not land_reason.is_empty(): return land_reason
  for stop in state.town.stops:
   if TownRules.point(c).distance_to(TownRules.point(TownRules.cell(stop.cell)))<8: return "Haltestellenunterstand freihalten"
 if road_cost(kind,cells)<=0: return "Hier liegt bereits ein Weg"
 if kind=="asphalt":
  var connected = false
  var existing = TownRules.road_cells(state.town)
  for c in cells:
   if existing.has(c): connected = true; break
  if not connected: return "Straße am bestehenden Straßennetz beginnen oder enden lassen"
 return ""

func build_road(kind: String, cells: Array) -> bool:
 var reason = road_reason(kind,cells)
 if not reason.is_empty(): notice.emit(reason); return false
 if not pay(road_cost(kind,cells)): return false
 var saved_cells = []
 for c in cells: saved_cells.append([c.x,c.y])
 var road_id=int(state.ux.get("next_road",1))
 state.ux.next_road=road_id+1
 var paid=road_cost(kind,cells)
 state.town.roads.append({"kind":kind,"cells":saved_cells,"id":road_id})
 state.ux.road_undo.append({"id":road_id,"paid":paid})
 while state.ux.road_undo.size()>10: state.ux.road_undo.pop_front()
 town_route_cache.clear()
 delivery_route_cache.clear()
 delivery_route_signature = 0
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func remove_road(index: int) -> bool:
 if index<0 or index>=state.town.roads.size(): return false
 var remaining = TownRules.road_cells(state.town,index)
 # Keep saved active trips valid. Docks are outside the road graph, so only
 # interior waypoints protect a road until its last vehicle has returned.
 for trip in state.trade.shipments:
  for c in trip.road_cells:
   if not remaining.has(TownRules.cell(c)):
    notice.emit("Export-LKW sind auf dieser Strecke unterwegs")
    return false
 var paths=[]
 for shipment in FreightFlow.traffic_trips(state): paths.append(shipment.path)
 for mission in state.city_services.missions:
  paths.append_array([mission.outward,mission.second,mission.back])
  if not mission.get("water_route",[]).is_empty(): paths.append(mission.water_route)
 for walker in state.city_services.walkers: paths.append(walker.path)
 for path in paths:
  for point in path.slice(1,-1):
   if not remaining.has(Vector2i(roundi(point[0]),roundi(point[2]))):
    notice.emit("Auf dieser Straße sind noch Fahrzeuge oder Bewohner unterwegs")
    return false
 for stop in state.town.stops:
  if not remaining.has(TownRules.cell(stop.cell)):
   notice.emit("Zuerst die Haltestelle an dieser Straße entfernen")
   return false
 for line in state.town.lines:
  if TownRules.route(state.town,line.stops,index).is_empty():
   notice.emit("Diese Straße wird von einer Buslinie benötigt")
   return false
 state.town.roads.remove_at(index)
 town_route_cache.clear()
 delivery_route_cache.clear()
 delivery_route_signature = 0
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func stop_reason(point: Vector3) -> String:
 if state.town.stops.size()>=8: return "Maximal acht Haltestellen"
 var c = TownRules.nearest(point,TownRules.road_cells(state.town))
 if c==null: return "Haltestelle direkt an einer verbundenen Straße platzieren"
 if WorldAccess.HIGHWAY_SITE.grow(7).has_point(Vector2(c)): return "Autobahnzufahrt freihalten"
 var land_reason=WorldAccess.land_reason(Rect2(Vector2(c)-Vector2(7,7),Vector2(14,14)),int(state.unlocked))
 if not land_reason.is_empty(): return land_reason
 for stop in state.town.stops:
  if TownRules.point(TownRules.cell(stop.cell)).distance_to(TownRules.point(c))<16: return "Mehr Abstand zur nächsten Haltestelle"
 for i in state.buildings.size():
  if Placement.bounds(building_position(i),int(state.buildings[i].get("rotation",0)),state.buildings[i].kind).grow(7).has_point(Vector2(c)): return "Haltestelle vor einem freien Straßenrand platzieren"
 for i in state.homes.size():
  if Placement.bounds(home_position(i),int(state.homes[i].get("rotation",0))).grow(7).has_point(Vector2(c)): return "Haltestelle vor einem freien Straßenrand platzieren"
 for project in Catalog.PROJECTS:
  if Placement.bounds(project.position,0).grow(7).has_point(Vector2(c)): return "Projektzufahrt freihalten"
 for job in state.jobs:
  if job.type in ["home","building"]:
   var fallback = Catalog.home_position(int(job.plot)) if job.type=="home" else Catalog.industry_position(int(job.slot))
   if Placement.bounds(Placement.position_of(job,fallback),int(job.get("rotation",0)),str(job.get("kind",""))).grow(7).has_point(Vector2(c)): return "Baustelle freihalten"
 return ""

func build_stop(point: Vector3) -> bool:
 var reason = stop_reason(point)
 if not reason.is_empty(): notice.emit(reason); return false
 if not pay(300.0*difficulty()): return false
 var c = TownRules.nearest(point,TownRules.road_cells(state.town))
 var id = int(state.town.next_stop)
 state.town.stops.append({"id":id,"name":"Haltestelle %s" % id,"cell":[c.x,c.y]})
 state.town.next_stop = id+1
 town_route_cache.clear()
 delivery_route_cache.clear()
 delivery_route_signature = 0
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func remove_stop(id: int) -> bool:
 for line in state.town.lines:
  if id in line.stops: notice.emit("Zuerst die zugehörige Buslinie einstellen"); return false
 for i in state.town.stops.size():
  if int(state.town.stops[i].id)!=id: continue
  state.town.stops.remove_at(i)
  town_route_cache.clear()
  delivery_route_cache.clear()
  delivery_route_signature = 0
  rebuild_world.emit()
  changed.emit()
  save(true)
  return true
 return false

func transit_plan(stops: Array) -> Dictionary:
 var key = "%s/%s/%s/%s" % [state.town.roads.hash(),state.town.stops.hash(),state.town.districts,stops]
 if not town_route_cache.has(key): town_route_cache[key] = TownRules.route(state.town,stops)
 return town_route_cache[key]

func create_bus_line(stops: Array) -> bool:
 if state.town.lines.size()>=3 or stops.size()<2: return false
 var unique = []
 for id in stops:
  if int(id) in unique: notice.emit("Jede Haltestelle nur einmal auswählen"); return false
  unique.append(int(id))
 var plan = transit_plan(unique)
 if plan.is_empty(): notice.emit("Mindestens zwei Haltestellen über Straßen verbinden"); return false
 if residents()<4: notice.emit("Vier Bewohner für die erste Buslinie benötigt"); return false
 if not pay(1800.0*difficulty()): return false
 var id = int(state.town.next_line)
 state.town.lines.append({"id":id,"stops":unique,"phase":0.0,"trips":0,"income":0.0})
 state.town.next_line = id+1
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func remove_bus_line(index: int) -> bool:
 if index<0 or index>=state.town.lines.size(): return false
 state.town.lines.remove_at(index)
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func bus_profit(line: Dictionary, plan: Dictionary) -> float:
 if plan.is_empty() or residents()<=0: return 0.0
 var passengers = minf(12.0,residents()*0.5)
 return maxf(0,passengers*3.0*line.stops.size()-float(plan.duration)*0.08)*multiplier()*boost("money")

func step_transit(delta: float) -> void:
 for line in state.town.lines:
  var plan = transit_plan(line.stops)
  if plan.is_empty(): continue
  var phase = float(line.phase)+delta
  var trips = floori(phase/float(plan.duration))
  line.phase = fposmod(phase,float(plan.duration))
  if trips>0:
   var income = bus_profit(line,plan)*trips
   earn(income)
   line.income = float(line.income)+income
   line.trips = int(line.trips)+trips
   state.town.trips_total=int(state.town.trips_total)+trips


func plot_position(plot: int) -> Vector3:
 for i in state.homes.size():
  if int(state.homes[i].plot)==plot: return home_position(i)
 return Catalog.home_position(plot)


func delivery_owns(index: int) -> bool:
 return DeliveryChain.owns(state,index)

func delivery_routes() -> Dictionary:
 if not state.delivery.active: return {}
 var points=[]
 for kind in DeliveryChain.KINDS: points.append(building_position(int(state.delivery.nodes[kind])))
 var signature = hash([points,state.town.roads,state.town.districts,state.delivery.nodes])
 if signature==delivery_route_signature and not delivery_route_cache.is_empty(): return delivery_route_cache
 delivery_route_signature = signature
 delivery_route_cache = {}
 for link in DeliveryChain.LINKS:
  delivery_route_cache[link[1]] = LogisticsRoutes.road_route(state,int(state.delivery.nodes[link[0]]),int(state.delivery.nodes[link[1]]))
 return delivery_route_cache

func start_delivery() -> bool:
 var nodes=DeliveryChain.choose_nodes(state)
 if not nodes.is_empty() and FactorySupply.busy_inputs(state,nodes.values()):
  notice.emit("Angeforderte Werkslieferungen zuerst entladen und zurückkehren lassen")
  return false
 if not DeliveryChain.start(state):
  notice.emit("Benötigt: Sammelstation, Sägewerk, Möbelfabrik und Verkaufsstelle ohne Pause")
  return false
 delivery_route_cache.clear()
 notice.emit("Lieferbetrieb eröffnet · Holz → Bretter → Möbel → Laden")
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func request_material(index: int) -> String:
 var result=FactorySupply.request(state,index)
 notice.emit(result)
 changed.emit()
 save(true)
 return result

func step_delivery(delta: float) -> void:
 if not state.delivery.active: return
 var report = DeliveryChain.tick(state,delta,delivery_routes(),(1+research_level("production")*0.12)*multiplier()*boost("processing"))
 var revenue=float(report.coins)*multiplier()*boost("money")
 earn(revenue)
 if revenue>0: sale_completed.emit("furniture",revenue,building_position(int(state.delivery.nodes.market)))
 state.exported += int(report.sold)
 Journey.add(state,"exported",int(report.sold))
 Journey.add(state,"shop_orders",int(report.orders))
 for key in report.produced: Journey.add(state,key,float(report.produced[key]))
 state.tickets += int(report.tickets)
 if float(report.sawdust)>0:
  var excess = maxf(0,float(report.sawdust)-(capacity()-float(state.resources.sawdust)))
  add_resource("sawdust",float(report.sawdust))
  if excess>0 and state.auto_sawdust: earn(excess*float(Catalog.PRICES.sawdust)*multiplier()*boost("money"))
 flow.merge(report.flow,true)

func unload_delivery(kind: String) -> float:
 if CentralLogistics.active(state):
  CentralLogistics.dispatch(state)
  notice.emit("Abholung am Betrieb disponiert · Gutschrift nach Entladen im Zentrallager")
  changed.emit()
  return 0
 if not state.delivery.active or not state.delivery.buffers.has(kind): return 0.0
 var total = 0.0
 for key in state.delivery.buffers[kind]:
  var amount = minf(float(state.delivery.buffers[kind][key]),capacity()-float(state.resources[key]))
  state.delivery.buffers[kind][key] -= amount
  state.resources[key] += amount
  total += amount
 changed.emit()
 return total

func buy_hardware(key: String, amount: int) -> bool:
 if not ConstructionRules.HARDWARE.has(key) or amount<=0 or amount>1000: return false
 if float(state.resources[key])+amount>capacity(): return false
 if not pay(float(ConstructionRules.HARDWARE[key])*amount*difficulty()): return false
 state.resources[key] += amount
 changed.emit()
 return true

func deliver_job(id: int) -> float:
 for job in state.jobs:
  if int(job.get("id",-1))==id:
   if job.has("phases"):
    job.requested = true
    var amount = ConstructionRules.dispatch(state,id)
    changed.emit()
    return amount
   var amount = ConstructionRules.deliver(state,job,INF)
   changed.emit()
   return amount
 return 0.0


func stop_delivery() -> bool:
 if not state.delivery.active: return false
 var returned = {}
 for kind in state.delivery.buffers:
  for key in state.delivery.buffers[kind]: returned[key] = float(returned.get(key,0))+float(state.delivery.buffers[kind][key])
 for kind in state.delivery.recovered:
  for key in state.delivery.recovered[kind]: returned[key] = float(returned.get(key,0))+float(state.delivery.recovered[kind][key])
 for shipment in state.delivery.shipments:
  if not shipment.arrived: returned[shipment.key] = float(returned.get(shipment.key,0))+float(shipment.amount)
 for key in returned:
  if float(state.resources[key])+float(returned[key])>capacity():
   notice.emit("Im Lager Platz schaffen, bevor die Linie aufgelöst wird")
   return false
 for key in returned: state.resources[key] += float(returned[key])
 state.hub.requests=state.hub.requests.filter(func(order): return not delivery_owns(int(order.index)))
 state.delivery = DeliveryChain.initial()
 delivery_route_cache.clear()
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true


func job_hardware_cost(id: int) -> float:
 for job in state.jobs:
  if int(job.get("id",-1))!=id: continue
  var cost = 0.0
  for key in ConstructionRules.HARDWARE:
   var missing = ceili(maxf(0,ConstructionRules.remaining(job,key)-float(state.resources[key])))
   cost += missing*float(ConstructionRules.HARDWARE[key])*difficulty()
  return cost
 return 0.0

func buy_job_hardware(id: int) -> bool:
 for job in state.jobs:
  if int(job.get("id",-1))!=id: continue
  var needed = {}
  for key in ConstructionRules.HARDWARE:
   needed[key] = ceili(maxf(0,ConstructionRules.remaining(job,key)-float(state.resources[key])))
   if float(state.resources[key])+int(needed[key])>capacity(): return false
  var cost = job_hardware_cost(id)
  if cost<=0 or not pay(cost): return false
  for key in needed: state.resources[key] += int(needed[key])
  changed.emit()
  return true
 return false


func company_level() -> int:
 var xp = int(state.company_xp)
 var thresholds = [0,20,60,120,220,360,550,800,1150,1600,2200,3000,4000,5200,6700,8500,10600,13000,15800,19000]
 var result = 1
 for i in thresholds.size():
  if xp>=thresholds[i]: result=i+1
 return result

func add_company_xp(amount: int) -> void:
 var before = company_level()
 state.company_xp += maxi(0,amount)
 if company_level()>before:
  company_level_unlocked.emit(company_level())
  notice.emit("Unternehmenslevel %s%s" % [company_level()," · Steinbruch & Baustoffe freigeschaltet" if before<5 and company_level()>=5 else " · Materialbaustellen freigeschaltet" if before<4 and company_level()>=4 else ""])

func free_builders() -> int:
 if CrewTransport.enabled(state): return maxi(0,int(state.builders)-CrewTransport.reserved(state))
 var assigned = 0
 for job in state.jobs: assigned += int(job.get("workers",0))
 return maxi(0,int(state.builders)-assigned)

func assign_builders(id: int, amount: int) -> bool:
 for job in state.jobs:
  if int(job.get("id",-1))!=id or not job.has("phases"): continue
  var wanted = clampi(amount,0,5)
  var owned=maxi(int(job.workers),int(CrewTransport.people(state).get(str(id),0))) if CrewTransport.enabled(state) else int(job.workers)
  if wanted>owned+free_builders(): return false
  job.workers=wanted
  job.auto_crew=false
  rebuild_world.emit()
  changed.emit()
  return true
 return false

func hire_builder() -> bool:
 if company_level()<4 or int(state.builders)>=8 or not pay(150*pow(1.6,int(state.builders)-2)*difficulty()): return false
 state.builders += 1
 changed.emit()
 return true

func cancel_construction(id: int) -> bool:
 for job in state.jobs:
  if int(job.get("id",-1))!=id or not job.has("phases"): continue
  # Cancellation requires room for ALL receipts and loads. Nothing is discarded.
  var returned = job.delivered.duplicate(true)
  for s in state.construction_shipments:
   if int(s.job)==id and not s.arrived: returned[s.key]=float(returned.get(s.key,0))+float(s.amount)
  for key in returned:
   if float(state.resources[key])+float(returned[key])>capacity(): notice.emit("Zuerst Platz im Lager schaffen"); return false
  for key in returned: state.resources[key]+=float(returned[key])
  state.construction_shipments=state.construction_shipments.filter(func(s): return int(s.job)!=id)
  state.jobs.erase(job)
  rebuild_world.emit()
  changed.emit()
  return true
 return false


func collect_city_income() -> float:
 var amount=float(state.city_services.treasury)
 state.city_services.treasury=0.0
 state.city_services.collected+=amount
 earn(amount*multiplier())
 changed.emit()
 return amount

func request_city_service(kind: String) -> bool:
 var result=CityServices.dispatch(state,kind,city_route_cache)
 if not result: notice.emit("Alle Fahrzeuge dieses Dienstes unterwegs oder Ziel nicht erreichbar")
 changed.emit()
 return result


func build_materials(kind: String, target_level: int = 1) -> Dictionary:
 return ConstructionRules.materials(kind,target_level,company_level()>=5)

func set_stone_recipe(index: int, recipe: String) -> bool:
 if index<0 or index>=state.buildings.size() or state.buildings[index].kind!="stoneworks" or not StoneIndustry.definitions.recipes.has(recipe): return false
 StoneIndustry.synchronize(state)
 StoneIndustry.site(state,index).recipe=recipe
 changed.emit()
 return true

func vein_cost(index: int) -> float:
 var data=StoneIndustry.site(state,index)
 return ceilf(200*(1+maxi(0,int(data.get("veins",1))-1)*0.3)*difficulty())

func explore_vein(index: int) -> bool:
 if index<0 or index>=state.buildings.size() or state.buildings[index].kind!="quarry": return false
 var data=StoneIndustry.site(state,index)
 if data.is_empty() or float(data.reserve)>0 or float(data.bucket)>0 or not pay(vein_cost(index)): return false
 var size=float(StoneIndustry.definitions.extraction.deposit)+(int(state.buildings[index].level)-1)*float(StoneIndustry.definitions.extraction.deposit_per_level)
 data.reserve=size
 data.vein_size=size
 data.veins=int(data.veins)+1
 changed.emit()
 return true

func stone_trader_price(key: String) -> float:
 if not StoneIndustry.definitions.trader.has(key): return INF
 return ceilf(maxf(float(StoneIndustry.definitions.trader[key])*difficulty(),float(Catalog.PRICES[key])*multiplier()*boost("money")*2))

func buy_stone_material(key: String, amount: int) -> bool:
 if company_level()<5 or not StoneIndustry.definitions.trader.has(key) or amount<=0 or amount>1000: return false
 if float(state.resources[key])+amount>capacity() or not pay(stone_trader_price(key)*amount): return false
 state.resources[key]+=amount
 changed.emit()
 return true


func create_group(a: Vector3,b: Vector3,name_value: String = "Neues Viertel") -> int:
 var start=Vector2(minf(a.x,b.x),minf(a.z,b.z))
 var extent=Vector2(absf(a.x-b.x),absf(a.z-b.z))
 if extent.x<4 or extent.y<4 or state.ux.groups.size()>=12: return -1
 var group={"id":state.ux.next_group,"name":name_value.strip_edges().left(32),"bounds":[start.x,start.y,extent.x,extent.y]}
 if UXRules.group_members(state,group).is_empty(): notice.emit("Mindestens ein Gebäude markieren"); return -1
 state.ux.next_group=int(state.ux.next_group)+1
 state.ux.groups.append(group)
 changed.emit()
 save(true)
 return int(group.id)

func rename_group(id: int,name_value: String) -> bool:
 var clean=name_value.strip_edges().left(32)
 if clean.is_empty(): return false
 for group in state.ux.groups:
  if int(group.id)==id:
   group.name=clean
   changed.emit()
   save(true)
   return true
 return false

func upgrade_group(id: int,quoted_price: float=-1) -> bool:
 for group in state.ux.groups:
  if int(group.id)!=id: continue
  var bill=UXRules.group_bill(state,group)
  if quoted_price>=0 and absf(float(bill.coins)-quoted_price)>0.0001: notice.emit("Ausbauplan hat sich geändert · neuen Gesamtpreis prüfen"); return false
  if bill.targets.is_empty(): notice.emit("Alle Gebäude sind ausgebaut oder haben bereits einen Bauauftrag"); return false
  if state.coins<float(bill.coins): notice.emit("Für den ganzen Auftrag fehlen Münzen"); return false
  if company_level()<4:
   var upfront={}
   for target in bill.targets:
    if target.city and state.homes[int(target.index)].kind=="townhall": continue
    for key in target.materials: upfront[key]=float(upfront.get(key,0))+float(target.materials[key])
   for key in upfront:
    if float(state.resources[key])<float(upfront[key]): notice.emit("Für den ganzen Auftrag fehlt %s" % Catalog.RESOURCES[key]); return false
  for target in bill.targets:
   if target.city: upgrade_home(int(target.index),true)
   else: upgrade(int(target.index),true)
   if state.jobs.back().has("phases"):
    state.jobs.back().auto_crew=true
    state.jobs.back().district_group=id
  rebuild_world.emit()
  changed.emit()
  save(true)
  return true
 return false

func undo_road() -> bool:
 while not state.ux.road_undo.is_empty():
  var last=state.ux.road_undo.back()
  var index=-1
  for i in state.town.roads.size():
   if int(state.town.roads[i].get("id",-1))==int(last.id): index=i; break
  if index<0: state.ux.road_undo.pop_back(); continue
  if not remove_road(index): return false
  state.coins+=float(last.paid)
  state.ux.road_undo.pop_back()
  changed.emit()
  save(true)
  notice.emit("Letzte unbenutzte Strecke zurückgenommen · Baukosten erstattet")
  return true
 return false


func allocate_group_crews() -> bool:
 var assigned=false
 var free=free_builders()
 if free<=0: return false
 for queued in state.jobs:
  if queued.has("phases") and queued.get("auto_crew",false) and not queued.get("paused",false) and int(queued.workers)==0 and free>0:
   queued.workers=1
   free-=1
   assigned=true
 return assigned

func fire_protection_cost(kind: String) -> int:
 return ceili(float(FireSafety.COSTS.get(kind,0))*difficulty())

func buy_fire_protection(index: int, kind: String) -> bool:
 if not FireSafety.COSTS.has(kind) or not FireSafety.eligible(state,index) or FireSafety.installed(state,index,kind): return false
 var cost=fire_protection_cost(kind)
 if float(state.coins)<cost:
  notice.emit("Nicht genug Münzen für diesen Brandschutz")
  return false
 var protection=state.homes[index].get("fire_safety",{}).duplicate()
 if kind=="hydrant":
  var offset=FireSafety.hydrant_position(state,index)-LogisticsRoutes.home_position(state,index)
  offset=offset.rotated(Vector3.UP,-deg_to_rad(float(state.homes[index].get("rotation",0))))
  protection.hydrant_offset=[offset.x,offset.y,offset.z]
 protection[kind]=true
 state.coins-=cost
 state.homes[index].fire_safety=protection
 changed.emit()
 return true

func report_fire(id: int) -> bool:
 var result=FireSafety.raise_alarm(state,id)
 if result: changed.emit()
 return result

func begin_tutorial() -> void:
 if not TutorialRules.can_resume(state): return
 state.onboarding.active=true
 state.onboarding.paused=false
 if int(state.tutorial)==0:
  state.onboarding.start_trees=int(state.trees)
  state.tutorial=1
 changed.emit()
 save(true)

func pause_tutorial() -> void:
 state.onboarding.active=false
 state.onboarding.paused=true
 changed.emit()
 save(true)

func end_tutorial(completed: bool=false) -> void:
 state.onboarding.active=false
 state.onboarding.paused=false
 state.onboarding.finished=completed
 state.tutorial=5
 changed.emit()
 save(true)
