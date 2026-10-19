extends Node

signal changed
signal notice(message: String)
signal harvested(biome: int, amount: float)
signal rebuild_world
signal loot_found(rarity: int)

var state: Dictionary
var flow: Dictionary = {}
var tick_clock = 0.0
var save_clock = 0.0
var rng = RandomNumberGenerator.new()
var offline_report = ""
var last_save_ok = true

func initial_state() -> Dictionary:
 var resources = {}
 for key in Catalog.RESOURCES: resources[key] = 0.0
 var buildings = []
 for kind in ["station","sawmill","warehouse","cabin","market"]:
  buildings.append({"kind":kind,"level":1,"paused":false})
 return {
  "schema":1, "coins":350.0, "diamonds":5, "tickets":0, "tokens":0, "cash":0,
  "resources":resources, "bag":0.0, "tool":0, "workers":1, "trucks":1, "vehicle":0,
  "biome":0, "unlocked":1, "buildings":buildings, "homes":[], "jobs":[],
  "research":{}, "inventory":{}, "boosters":{}, "projects":{}, "region":0,
  "plan":{}, "skin":"Rustikal", "skin_tool":"Holz", "permanent_loot":0,
  "prestige":0, "prestige_points":0, "trees":0, "gathered":0.0,
  "exported":0.0, "earned":0.0, "missions_claimed":{}, "contracts":0,
  "boss_hp":100.0, "bosses":0, "time":9.0, "elapsed":0.0, "weather":0,
  "quality":1, "reserve":true, "auto_export":true, "auto_sawdust":false, "tutorial":0, "muted":false, "companion_enabled":true,
  "last_seen":Time.get_unix_time_from_system()}

func _ready() -> void:
 rng.randomize()
 state = initial_state()
 var saved = Store.load_game()
 if not saved.is_empty():
  restore(saved)
  var offline = clampf(Time.get_unix_time_from_system() - float(state.last_seen),0.0,28800.0)
  var before = float(state.coins)
  simulate(offline)
  if offline > 60: offline_report = "%s Min. offline · +%s Münzen" % [int(offline/60),Catalog.number(state.coins-before)]
 process_mode = Node.PROCESS_MODE_ALWAYS

func restore(saved: Dictionary) -> void:
 state = initial_state()
 for key in state:
  if saved.has(key):
   state[key] = saved[key].duplicate(true) if saved[key] is Dictionary or saved[key] is Array else saved[key]
 for key in Catalog.RESOURCES:
  if not state.resources.has(key): state.resources[key] = 0.0
 if not saved.has("tutorial"): state.tutorial = 5

func snapshot() -> Dictionary:
 var data = state.duplicate(true)
 data.last_seen = Time.get_unix_time_from_system()
 return data

func save(silent: bool = false) -> bool:
 last_save_ok = Store.save_game(snapshot())
 if not silent: notice.emit("Spielstand gespeichert" if last_save_ok else Store.last_error)
 return last_save_ok

func _notification(what: int) -> void:
 if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
  save(true)

func _process(delta: float) -> void:
 tick_clock += minf(delta,5.0)
 save_clock += delta
 if tick_clock >= 1.0:
  var steps = int(tick_clock)
  tick_clock -= steps
  for i in steps: step(1.0)
  changed.emit()
 if save_clock >= 20.0:
  save_clock = 0.0
  save(true)

func simulate(seconds: float) -> void:
 for i in int(seconds): step(1.0)
 var rest = seconds - floorf(seconds)
 if rest > 0: step(rest)

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
 return 500.0 + level("warehouse") * 500.0

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
 state.resources[key] = clampf(float(state.resources.get(key,0)) + amount,0.0,capacity())

func earn(amount: float) -> void:
 state.coins += amount
 state.earned += amount

func reserve_for(key: String) -> float:
 var planned = float(plan_materials().get(key,0))
 if not state.plan.is_empty(): return maxf(planned,10.0 if key == "boards" else 5.0 if key == "dry" else 0.0)
 if not state.reserve: return 0.0
 return {"boards":10.0,"dry":5.0,"furniture":4.0,"walls":2.0,"roofs":2.0,"parts":2.0,"paper":2.0}.get(key,0.0)

func production_status(index: int) -> String:
 if index < 0 or index >= state.buildings.size(): return ""
 var building = state.buildings[index]
 if not Catalog.RECIPES.has(building.kind): return "Betriebsbereit"
 if building.get("paused",false): return "Pausiert · Produktion fortsetzen"
 var recipe = Catalog.RECIPES[building.kind]
 for key in recipe.out:
  if key not in recipe.get("overflow_sell",[]) and float(state.resources[key]) >= capacity()-0.0001:
   return "%s-Lager voll · verkaufen oder weiterverarbeiten" % Catalog.RESOURCES[key]
 for key in recipe["in"]:
  if float(state.resources[key]) <= reserve_for(key)+0.0001:
   return "Wartet auf %s%s" % [Catalog.RESOURCES[key]," (Baureserve geschützt)" if reserve_for(key)>0 else ""]
 if float(flow.get("building:%s" % index,0))>0: return "Läuft · %.2f Zyklen/s" % float(flow["building:%s" % index])
 return "Bereit · startet mit dem nächsten Produktionstakt"

func step(delta: float) -> void:
 state.elapsed += delta
 state.time = fmod(float(state.time) + delta / 60.0,24.0)
 state.weather = int(float(state.elapsed)/180.0) % 4
 for key in state.boosters:
  state.boosters[key].left = maxf(0,float(state.boosters[key].left)-delta)
 var harvest = (0.65 + int(state.tool)*0.13) * int(state.workers) * (1.0+int(state.biome)*0.3) * (1.0+research_level("forestry")*0.15) * boost("workers") * delta
 harvest = minf(harvest,level("station")*5.0*delta)
 var accepted = minf(harvest,capacity()-float(state.resources.wood))
 add_resource("wood",accepted)
 state.gathered += accepted
 flow = {"harvest":accepted/maxf(delta,0.001)}
 var proposals = []
 var demand = {}
 var output_demand = {}
 for building_index in state.buildings.size():
  var b = state.buildings[building_index]
  if b.get("paused",false) or not Catalog.RECIPES.has(b.kind): continue
  var recipe = Catalog.RECIPES[b.kind]
  var cycles = float(recipe.speed)*int(b.level)*(1+research_level("production")*0.12+minf(public_level("school")*0.04,0.5))*multiplier()*boost("processing")*delta
  proposals.append({"kind":b.kind,"index":building_index,"recipe":recipe,"cycles":cycles})
  for key in recipe["in"]:
   demand[key] = float(demand.get(key,0))+float(recipe["in"][key])*cycles
  for key in recipe.out:
   output_demand[key] = float(output_demand.get(key,0))+float(recipe.out[key])*cycles
 # Allocate scarce shared inputs proportionally from one common snapshot.
 # Apply all consumption before output: no factory depends on array ordering.
 var produced = {}
 var consumed = {}
 for proposal in proposals:
  var recipe = proposal.recipe
  var fraction = 1.0
  for key in recipe["in"]:
   fraction = minf(fraction,maxf(0.0,float(state.resources[key])-reserve_for(key))/maxf(float(demand[key]),0.0001))
  for key in recipe.out:
   if key in recipe.get("overflow_sell",[]): continue
   fraction = minf(fraction,(capacity()-float(state.resources[key]))/maxf(float(output_demand[key]),0.0001))
  var cycles = float(proposal.cycles)*maxf(0,fraction)
  for key in recipe["in"]: consumed[key] = float(consumed.get(key,0))+float(recipe["in"][key])*cycles
  for key in recipe.out: produced[key] = float(produced.get(key,0))+float(recipe.out[key])*cycles
  flow[proposal.kind] = float(flow.get(proposal.kind,0))+cycles/maxf(delta,0.001)
  flow["building:%s" % proposal.index] = cycles/maxf(delta,0.001)
 for key in consumed: state.resources[key] = maxf(0,float(state.resources[key])-float(consumed[key]))
 for key in produced:
  var amount = float(produced[key])
  var excess = maxf(0.0,amount-maxf(0.0,capacity()-float(state.resources[key])))
  add_resource(key,amount)
  # Sawdust is a recoverable by-product, never a reason to stop sawing.
  # Sell only overflow; keep all existing stock for pellets and paper.
  if key == "sawdust" and excess > 0:
   if state.auto_sawdust:
    earn(excess*float(Catalog.PRICES.sawdust)*multiplier()*boost("money"))
    flow["sawdust_sold"] = excess/maxf(delta,0.001)
   else: flow["sawdust_composted"] = excess/maxf(delta,0.001)
 if state.auto_export:
  var export_reserve = reserve_for("furniture")+(4.0 if level("design")>0 else 0.0)
  var exported = minf(maxf(0,float(state.resources.furniture)-export_reserve),int(state.trucks)*level("market")*(1+int(state.vehicle)*0.2)*(1+research_level("logistics")*0.12)*0.25*delta)
  state.resources.furniture -= exported
  state.exported += exported
  flow["export"] = exported/maxf(delta,0.001)
  earn(exported*float(Catalog.PRICES.furniture)*multiplier()*boost("money"))
 var rent = 0.0
 var public_bonus = 1.0
 for h in state.homes:
  if h.kind in ["park","clinic"]: public_bonus += 0.04*int(h.level)
 for h in state.homes:
  rent += float(Catalog.HOMES[h.kind].rent)*int(h.level)*minf(public_bonus,2.0)
 earn(rent*delta*multiplier()*boost("money"))
 for project_index in Catalog.PROJECTS.size():
  if int(state.projects.get(str(project_index),0)) >= 3:
   earn(float(Catalog.PROJECTS[project_index].income)*delta*multiplier()*boost("money"))
 var completed = []
 for j in state.jobs:
  j.left = maxf(0,float(j.left)-delta*(1+research_level("construction")*0.12+minf(public_level("fire")*0.05,0.5)))
  if j.left <= 0: completed.append(j)
 for j in completed:
  state.jobs.erase(j)
  finish_job(j)
 if not state.plan.is_empty() and state.plan.get("auto",false):
  var plan = state.plan.duplicate(true)
  var affordable = state.coins >= float(Catalog.HOMES[plan.kind].cost)*difficulty()
  for key in plan_materials():
   affordable = affordable and float(state.resources[key]) >= float(plan_materials()[key])
  if affordable:
   if order_home(plan.kind,int(plan.plot)): state.plan = {}

func chop() -> void:
 if state.bag >= bag_capacity():
  notice.emit("Rucksack voll · zuerst abliefern")
  return
 var amount = minf(bag_capacity()-float(state.bag),(4.0+int(state.tool)*3.0)*(1+int(state.biome)*0.4))
 state.bag += amount
 state.gathered += amount
 state.trees += 1
 if state.tutorial == 1 and state.trees >= 5: state.tutorial = 2
 harvested.emit(int(state.biome),amount)
 if rng.randf() < 0.12*(1+research_level("loot")*0.08+int(state.permanent_loot)*0.1)*boost("loot")*multiplier():
  state.tickets += 1
  notice.emit("Loot-Ticket im Baum gefunden!")
 changed.emit()

func deposit() -> void:
 var amount = minf(float(state.bag),capacity()-float(state.resources.wood))
 add_resource("wood",amount)
 state.bag -= amount
 if state.tutorial == 2 and amount > 0: state.tutorial = 3
 notice.emit("%s Holz abgeliefert" % Catalog.number(amount))
 changed.emit()

func sell(key: String, fraction: float = 1.0) -> void:
 if not Catalog.PRICES.has(key): return
 var amount = float(state.resources[key])*clampf(fraction,0,1)
 state.resources[key] -= amount
 earn(amount*float(Catalog.PRICES[key])*multiplier()*boost("money"))
 if state.tutorial == 3 and amount > 0: state.tutorial = 4
 if key == "furniture": state.exported += amount
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

func placement_reason(point: Vector3, rotation: int = 0, ignore_building: int = -1, ignore_home: int = -1) -> String:
 var reason = Placement.terrain_reason(point,rotation)
 if not reason.is_empty(): return reason
 var rectangle = Placement.bounds(point,rotation).grow(0.6)
 for i in state.buildings.size():
  if i == ignore_building: continue
  if rectangle.intersects(Placement.bounds(building_position(i),int(state.buildings[i].get("rotation",0)))): return "Abstand zu anderen Gebäuden halten"
 for i in state.homes.size():
  if i == ignore_home: continue
  if rectangle.intersects(Placement.bounds(home_position(i),int(state.homes[i].get("rotation",0)))): return "Dieses Grundstück ist bereits bebaut"
 for job in state.jobs:
  if job.type not in ["building","home"]: continue
  var fallback = Catalog.industry_position(int(job.get("slot",0))) if job.type=="building" else Catalog.home_position(int(job.plot))
  if rectangle.intersects(Placement.bounds(Placement.position_of(job,fallback),int(job.get("rotation",0)))): return "Hier wird bereits gebaut"
 return ""

func free_position(preferred: Vector3, rotation: int = 0, ignore_building: int = -1, ignore_home: int = -1) -> Vector3:
 var point = Placement.snap(preferred)
 if placement_reason(point,rotation,ignore_building,ignore_home).is_empty(): return point
 var best = Vector3(INF,0,INF)
 var distance = INF
 for z in [-144,-112,-80,-44,-12,20,52,84,116,148]:
  for x in [-60,-40,-20,20,40,60]:
   var candidate = Vector3(x,0,z)
   if placement_reason(candidate,rotation,ignore_building,ignore_home).is_empty() and candidate.distance_squared_to(preferred)<distance:
    best = candidate
    distance = candidate.distance_squared_to(preferred)
 return best

func next_city_plot() -> int:
 for plot in 4*(int(state.region)+1):
  var occupied = false
  for home in state.homes:
   if int(home.plot)==plot: occupied = true
  for job in state.jobs:
   if job.type=="home" and int(job.plot)==plot: occupied = true
  if not occupied: return plot
 return -1

func move_building(index: int, point: Vector3, rotation: int = 0, city: bool = false) -> bool:
 var records = state.homes if city else state.buildings
 if index<0 or index>=records.size(): return false
 point = Placement.snap(point)
 var reason = placement_reason(point,rotation,-1 if city else index,index if city else -1)
 if not reason.is_empty(): notice.emit(reason); return false
 records[index].position = [point.x,point.z]
 records[index].rotation = posmod(rotation,360)
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func order_building(kind: String, point: Variant = null, rotation: int = 0) -> bool:
 if not Catalog.BUILDINGS.has(kind) or not available(kind): return false
 var pending = 0
 for j in state.jobs:
  if j.type == "building": pending += 1
 if state.buildings.size()+pending >= 24:
  notice.emit("Industriegebiet voll · vorhandene Betriebe ausbauen")
  return false
 var position_value = free_position(Catalog.industry_position((state.buildings.size()+pending)%16),rotation) if point==null else Placement.snap(point)
 var reason = placement_reason(position_value,rotation)
 if not reason.is_empty(): notice.emit(reason); return false
 if not pay(cost_for(kind)): return false
 var duration = 12.0+state.buildings.size()*2.0
 state.jobs.append({"type":"building","kind":kind,"left":duration,"total":duration,"slot":state.buildings.size()+pending,"position":[position_value.x,position_value.z],"rotation":rotation})
 if state.tutorial == 4: state.tutorial = 5
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func job_for(type: String, index: int) -> bool:
 for j in state.jobs:
  if j.type == type and int(j.get("index",-1)) == index: return true
 return false

func upgrade(index: int) -> bool:
 if index < 0 or index >= state.buildings.size() or job_for("upgrade",index): return false
 var b = state.buildings[index]
 if b.level >= Catalog.BUILDINGS[b.kind].max: return false
 if not pay(cost_for(b.kind,int(b.level)+1)): return false
 state.jobs.append({"type":"upgrade","index":index,"kind":b.kind,"left":10.0+int(b.level)*2.0,"total":10.0+int(b.level)*2.0})
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func order_home(kind: String, plot: int, point: Variant = null, rotation: int = 0) -> bool:
 if not Catalog.HOMES.has(kind) or plot < 0 or plot >= 4*(int(state.region)+1) or level("prefab") < 1: return false
 for h in state.homes:
  if int(h.plot) == plot: return false
 for j in state.jobs:
  if j.type == "home" and int(j.plot) == plot: return false
 var position_value = free_position(Catalog.home_position(plot),rotation) if point==null else Placement.snap(point)
 var reason = placement_reason(position_value,rotation)
 if not reason.is_empty(): notice.emit(reason); return false
 var definition = Catalog.HOMES[kind]
 if not pay(float(definition.cost)*difficulty(),definition.materials): return false
 state.jobs.append({"type":"home","kind":kind,"plot":plot,"left":60.0,"total":60.0,"position":[position_value.x,position_value.z],"rotation":rotation})
 if not state.plan.is_empty() and int(state.plan.plot)==plot: state.plan = {}
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func upgrade_home(index: int) -> bool:
 if index < 0 or index >= state.homes.size() or job_for("home_upgrade",index): return false
 var h = state.homes[index]
 if int(h.level) >= 10: return false
 var definition = Catalog.HOMES[h.kind]
 var materials = {}
 for key in definition.materials: materials[key] = ceilf(float(definition.materials[key])*0.5*int(h.level))
 if not pay(float(definition.cost)*pow(1.4,int(h.level))*difficulty(),materials): return false
 state.jobs.append({"type":"home_upgrade","kind":h.kind,"index":index,"plot":h.plot,"left":45.0,"total":45.0})
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true

func finish_job(job: Dictionary) -> void:
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
 rebuild_world.emit()
 notice.emit("Bau abgeschlossen · %s" % job.kind)

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
 if not Catalog.HOMES.has(kind) or plot < 0 or plot >= 4*(int(state.region)+1): return
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
 {"id":"city","name":"Baue dein erstes Stadthaus","value":state.homes.size(),"target":1,"reward":3500*tier},
 {"id":"biomes","name":"Erschließe fünf Biome","value":state.unlocked,"target":5,"reward":7000*tier}]

func claim_mission(id: String) -> bool:
 if state.missions_claimed.has(id): return false
 for m in mission_definitions():
  if m.id == id and m.value >= m.target:
   state.missions_claimed[id] = true
   earn(m.reward)
   state.diamonds += 5
   state.tickets += 2
   changed.emit()
   return true
 return false

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
 for key in ["diamonds","tokens","cash","inventory","skin","skin_tool","permanent_loot","companion_enabled"]: state[key] = old[key]
 state.prestige = int(old.prestige)+1
 state.prestige_points = int(old.prestige_points)+1
 state.coins = 350.0*(1+int(state.prestige)*0.25)
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true
