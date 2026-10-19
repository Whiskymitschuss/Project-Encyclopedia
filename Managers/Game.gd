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
 return {"schema":1,"coins":350.0,"diamonds":5,"tickets":0,"tokens":0,"cash":0,"resources":resources,"bag":0.0,"tool":0,"workers":1,"trucks":1,"vehicle":0,"biome":0,"unlocked":1,"buildings":buildings,"homes":[],"jobs":[],"research":{},"inventory":{},"boosters":{},"prestige":0,"prestige_points":0,"trees":0,"gathered":0.0,"exported":0.0,"earned":0.0,"missions_claimed":{},"contracts":0,"boss_hp":100.0,"bosses":0,"time":9.0,"elapsed":0.0,"weather":0,"quality":1,"reserve":true,"auto_export":true,"muted":false,"last_seen":Time.get_unix_time_from_system()}

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
  if saved.has(key): state[key] = saved[key]
 for key in Catalog.RESOURCES:
  if not state.resources.has(key): state.resources[key] = 0.0

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
 if not state.reserve: return 0.0
 return {"boards":10.0,"dry":5.0,"furniture":4.0,"walls":2.0,"roofs":2.0,"parts":2.0,"paper":2.0}.get(key,0.0)

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
 flow = {}
 for b in state.buildings:
  if b.get("paused",false) or not Catalog.RECIPES.has(b.kind): continue
  var recipe = Catalog.RECIPES[b.kind]
  var cycles = float(recipe.speed)*int(b.level)*(1+research_level("production")*0.12)*multiplier()*boost("processing")*delta
  for key in recipe["in"]:
   cycles = minf(cycles,maxf(0.0,float(state.resources[key])-reserve_for(key))/float(recipe["in"][key]))
  for key in recipe.out:
   cycles = minf(cycles,(capacity()-float(state.resources[key]))/float(recipe.out[key]))
  cycles = maxf(0,cycles)
  for key in recipe["in"]: state.resources[key] -= float(recipe["in"][key])*cycles
  for key in recipe.out: add_resource(key,float(recipe.out[key])*cycles)
  flow[b.kind] = float(flow.get(b.kind,0)) + cycles/maxf(delta,0.001)
 if state.auto_export:
  var exported = minf(maxf(0,float(state.resources.furniture)-reserve_for("furniture")),int(state.trucks)*level("market")*(1+int(state.vehicle)*0.2)*(1+research_level("logistics")*0.12)*0.25*delta)
  state.resources.furniture -= exported
  state.exported += exported
  earn(exported*float(Catalog.PRICES.furniture)*multiplier()*boost("money"))
 var rent = 0.0
 var public_bonus = 1.0
 for h in state.homes:
  if h.kind in ["park","clinic"]: public_bonus += 0.04*int(h.level)
 for h in state.homes:
  rent += float(Catalog.HOMES[h.kind].rent)*int(h.level)*minf(public_bonus,2.0)
 earn(rent*delta*multiplier()*boost("money"))
 var completed = []
 for j in state.jobs:
  j.left = maxf(0,float(j.left)-delta*(1+research_level("construction")*0.12))
  if j.left <= 0: completed.append(j)
 for j in completed:
  finish_job(j)
  state.jobs.erase(j)

func chop() -> void:
 if state.bag >= bag_capacity():
  notice.emit("Rucksack voll · zuerst abliefern")
  return
 var amount = minf(bag_capacity()-float(state.bag),(4.0+int(state.tool)*3.0)*(1+int(state.biome)*0.4))
 state.bag += amount
 state.gathered += amount
 state.trees += 1
 harvested.emit(int(state.biome),amount)
 if rng.randf() < 0.12*(1+research_level("loot")*0.08)*boost("loot"):
  state.tickets += 1
  notice.emit("Loot-Ticket im Baum gefunden!")
 changed.emit()

func deposit() -> void:
 var amount = minf(float(state.bag),capacity()-float(state.resources.wood))
 add_resource("wood",amount)
 state.bag -= amount
 notice.emit("%s Holz abgeliefert" % Catalog.number(amount))
 changed.emit()

func sell(key: String, fraction: float = 1.0) -> void:
 if not Catalog.PRICES.has(key): return
 var amount = float(state.resources[key])*clampf(fraction,0,1)
 state.resources[key] -= amount
 earn(amount*float(Catalog.PRICES[key])*multiplier()*boost("money"))
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

func order_building(kind: String) -> bool:
 if not Catalog.BUILDINGS.has(kind) or not available(kind): return false
 var pending = 0
 for j in state.jobs:
  if j.type == "building": pending += 1
 if state.buildings.size()+pending >= 16:
  notice.emit("Industriegebiet voll · vorhandene Betriebe ausbauen")
  return false
 if not pay(cost_for(kind)): return false
 var duration = 12.0+state.buildings.size()*2.0
 state.jobs.append({"type":"building","kind":kind,"left":duration,"total":duration,"slot":state.buildings.size()+pending})
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
 changed.emit()
 save(true)
 return true

func order_home(kind: String, plot: int) -> bool:
 if not Catalog.HOMES.has(kind) or plot < 0 or plot >= 12 or level("prefab") < 1: return false
 for h in state.homes:
  if int(h.plot) == plot: return false
 for j in state.jobs:
  if j.type == "home" and int(j.plot) == plot: return false
 var definition = Catalog.HOMES[kind]
 if not pay(float(definition.cost)*difficulty(),definition.materials): return false
 state.jobs.append({"type":"home","kind":kind,"plot":plot,"left":60.0,"total":60.0})
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
 changed.emit()
 save(true)
 return true

func finish_job(job: Dictionary) -> void:
 match job.type:
  "building": state.buildings.append({"kind":job.kind,"level":1,"paused":false,"slot":job.slot})
  "upgrade": state.buildings[int(job.index)].level += 1
  "home": state.homes.append({"kind":job.kind,"level":1,"plot":job.plot})
  "home_upgrade": state.homes[int(job.index)].level += 1
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
 for key in ["diamonds","tokens","cash","inventory"]: state[key] = old[key]
 state.prestige = int(old.prestige)+1
 state.prestige_points = int(old.prestige_points)+1
 state.coins = 350.0*(1+int(state.prestige)*0.25)
 rebuild_world.emit()
 changed.emit()
 save(true)
 return true
