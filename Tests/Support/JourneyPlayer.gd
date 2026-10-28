extends RefCounted
# A player policy: all money, goods, jobs and unlocks go through public Game APIs.
# No counter seeding, fabricated completions, boosts, loot rolls or prestige loops.
var game
var actions=[]
var chapters=[]
var samples=[]
var manual_cuts=0
var last_goal=""
var checks=0
var failures=[]
var seed_value=41
var saved_halls={}
var interval=5
var invariant_samples=0
func _init(company):game=company
func record(kind: String,detail: Variant=""):
 actions.append({"at":int(game.state.elapsed),"action":kind,"detail":detail,"coins":snappedf(float(game.state.coins),0.01)})
func index_of(kind: String,city: bool=false) -> int:
 var records=game.state.homes if city else game.state.buildings
 for i in records.size():
  if records[i].kind==kind:return i
 return -1
func pending(kind: String) -> bool:
 for j in game.state.jobs:
  if j.kind==kind:return true
 return false
func order(kind: String,total: int=1) -> bool:
 if game.count(kind)>=total or pending(kind) or not game.available(kind) or game.state.coins<game.cost_for(kind):return false
 if game.order_building(kind):record("build",kind);return true
 return false
func upgrade_building(kind: String,target: int) -> bool:
 var i=index_of(kind)
 if i<0 or int(game.state.buildings[i].level)>=target or pending(kind):return false
 if game.state.coins<game.cost_for(kind,int(game.state.buildings[i].level)+1):return false
 if game.upgrade(i):record("upgrade",kind+":"+str(game.state.buildings[i].level+1));return true
 return false
func home(kind: String,target: int) -> bool:
 var i=index_of(kind,true)
 if pending(kind):return false
 if i<0:
  var plot=game.next_city_plot()
  if plot<0 or not game.home_available(kind) or game.state.coins<float(Catalog.HOMES[kind].cost):return false
  if game.order_home(kind,plot):record("home",kind);return true
 elif int(game.state.homes[i].level)<target:
  var price=float(Catalog.HOMES[kind].cost)*pow(1.4,int(game.state.homes[i].level))
  if game.state.coins<price:return false
  if game.upgrade_home(i):record("home_upgrade",kind+":"+str(game.state.homes[i].level+1));return true
 return false
func keep(key: String) -> float:
 var needed=ConstructionRules.reserved_materials(game.state,key)
 var goal=Journey.current(game.state)
 var c=int(goal.get("chapter",9))
 var buffer={"wood":16.0,"boards":12.0,"dry":8.0,"furniture":2.0,"walls":4.0,"roofs":3.0,"parts":0.0,"stone":0.0,"gravel":0.0}
 if c>=4:buffer.merge({"wood":40.0,"boards":40.0,"dry":30.0,"furniture":12.0,"walls":40.0,"roofs":25.0,"parts":24.0,"stone":60.0,"gravel":40.0},true)
 return needed+float(buffer.get(key,0))
func income() -> bool:
 if game.level("prefab")>0 and not game.state.town.rent_manager and game.state.coins>=4000:
  if game.set_rent_auto(true):record("rent_manager");return true
 if game.rent_total()>=100:game.collect_rent();record("rent");return true
 if float(game.state.city_services.treasury)>=100:game.collect_city_income();record("city_income");return true
 # Do not liquidate ingredients forever after income already covers the goal.
 # Furniture sales are themselves the visible chapter objective.
 var goal=Journey.current(game.state)
 var selling_furniture=str(goal.get("id","")) in ["workshop:2","skyline:2","empire:2"]
 var need_cash=float(game.state.coins)<cash_goal(goal)
 for key in ["furniture","walls","roofs","parts","dry","boards","wood","sawdust","stone","gravel"]:
  if not need_cash and not (key=="furniture" and selling_furniture):continue
  var available=float(game.state.resources[key])
  var extra=maxf(0,available-keep(key))
  if extra*float(Catalog.PRICES[key])<(1 if selling_furniture and key=="furniture" else 100):continue
  game.sell(key,extra/available);record("sale",key);return true
 return false
func cash_goal(goal: Dictionary) -> float:
 if goal.is_empty():return 0
 if int(goal.index)<0:return Journey.hall_cost(int(goal.chapter)+1)+1000
 var action=str(goal.action)
 if action in Catalog.BUILDINGS:return game.cost_for(action)+1500
 if action=="world":return float(Catalog.BIOMES[int(game.state.unlocked)].cost)+1000
 if action=="empire":return (6000*pow(5,game.state.region) if game.state.region<2 else game.district_cost())+1000
 if action=="city":return 30000
 return 5000
func build_own_road() -> bool:
 var existing=TownRules.road_cells(game.state.town)
 for point in existing:
  for offset in [Vector2i(4,0),Vector2i(-4,0),Vector2i(0,4),Vector2i(0,-4)]:
   if existing.has(point+offset):continue
   var cells=[point,point+offset]
   if game.road_reason("asphalt",cells).is_empty() and game.build_road("asphalt",cells):record("road",cells);return true
 return false
func goal_action(goal: Dictionary) -> bool:
 var c=int(goal.chapter)
 if int(goal.index)<0:
  if pending("townhall"):return false
  var hall=Journey.townhall_index(game.state)
  if game.state.coins<Journey.hall_cost(c+1):return false
  var ok=game.order_home("townhall",-1) if hall<0 else game.upgrade_home(hall)
  if ok:record("hall_order",c+1);return true
  return false
 match str(goal.action):
  "forest":
   if game.state.bag>0:game.deposit();record("deposit");return true
   var old=game.state.trees;game.chop()
   if game.state.trees>old:manual_cuts+=1;record("chop");return true
  "deposit":
   if game.state.bag>0:game.deposit();record("deposit");return true
   var old=game.state.trees;game.chop()
   if game.state.trees>old:manual_cuts+=1;record("chop");return true
  "market":
   if game.state.resources.wood>0:game.sell("wood",0.25);record("first_sale");return true
  "sawmill":
   if c==1 and int(goal.index)==1:return upgrade_building("sawmill",2)
  "team":
   if game.state.workers<3 and game.state.coins>=game.hire_cost() and game.hire():record("hire");return true
  "kiln","furniture","prefab","quarry","stoneworks":return order(str(goal.action))
  "delivery":
   if c==3 and not game.state.delivery.active and not pending("furniture"):
    if game.start_delivery():record("delivery_start");return true
  "city":return home("house",10 if c>=8 else 5 if c>=6 else 1) if str(goal.id)!="empire:1" else (home("apartments",5) if Journey.value(game.state,"residents")<100 else false)
  "networks":
   return build_own_road()
  "world":
   if game.state.unlocked<int(goal.target) and game.state.coins>=float(Catalog.BIOMES[int(game.state.unlocked)].cost) and game.unlock_biome():record("biome",game.state.unlocked);return true
  "empire":
   if game.state.region<2:
    if game.state.coins>=6000*pow(5,game.state.region) and game.expand_region():record("region",game.state.region);return true
   elif game.state.coins>=game.district_cost() and game.expand_district():record("district");return true
  "catalog":return order("sawmill",3)
 return false
func support(c: int) -> bool:
 if game.state.jobs.size()>=2:return false
 if c>=3 and game.state.delivery.active:
  if order("central_depot"):return true
  if order("sawmill",2):return true
 if c>=4 and order("joinery"):return true
 # Build capacity in bounded steps instead of buying every available upgrade.
 if c>=2 and game.state.coins>1200:
  if upgrade_building("station",2):return true
  var workers=5 if c<4 else 8
  if game.state.workers<workers and game.state.coins>game.hire_cost()+700 and game.hire():record("hire");return true
 if c>=3 and game.state.coins>1800:
  if game.state.trucks<2 and game.buy_truck():record("truck");return true
  if game.state.vehicle<2 and game.upgrade_vehicle():record("vehicle");return true
 if c>=4 and game.state.coins>3500:
  if order("garage"):return true
  if upgrade_building("kiln",3):return true
  if upgrade_building("sawmill",4):return true
  if upgrade_building("furniture",3):return true
  var extra=4 if c<7 else 6
  if c>=7 and upgrade_building("garage",2):return true
  if game.state.hub.extra_trucks<extra and game.buy_central_truck():record("central_truck");return true
  for i in game.state.buildings.size():
   if TransportCapacity.supported(game.state,i) and TransportCapacity.dock_level(game.state,i)<2 and game.upgrade_transport(i):record("dock",i);return true
 if c>=7 and order("joinery"):return true
 return false
func turn():
 if game.state.onboarding.active:
  match TutorialRules.phase(game.state):
   "chop":
    var old=game.state.trees;game.chop()
    if game.state.trees>old:manual_cuts+=1;record("chop")
    return
   "deposit":game.deposit();record("deposit");return
   "boards":return
   "sell":game.sell("boards",0.25);record("tutorial_sale");return
   "build":
    if not order("cabin",2):income()
    return
   "construction":return
   "done":game.end_tutorial(true);record("tutorial_complete");return
 var goal=Journey.current(game.state)
 if goal.is_empty():return
 if str(goal.id)!=last_goal:
  last_goal=str(goal.id);print("JOURNEY PLAYER GOAL ",int(game.state.elapsed)," ",goal.id," coins ",int(game.state.coins))
 if goal.ready:
  if game.claim_journey(str(goal.id)):
   record("claim",goal.id)
   if int(goal.index)<0:chapter_checkpoint(int(goal.chapter)+1)
  return
 # Hardware is bought, never seeded. Only a live build's actual shortages.
 for job in game.state.jobs:
  var price=game.job_hardware_cost(int(job.get("id",-1)))
  if price>0 and game.state.coins>=price and game.buy_job_hardware(int(job.id)):record("hardware",job.id);return
 if goal_action(goal):return
 if income():return
 # Early cuts are a legitimate player action and earn the XP required by stone.
 if game.company_level()<5:
  if game.state.bag>=game.bag_capacity()*0.5:game.deposit();record("deposit");return
  var old=game.state.trees;game.chop()
  if game.state.trees>old:manual_cuts+=1;record("chop");return
 if game.state.bag>0:game.deposit();record("deposit");return
 if support(int(goal.chapter)):return
 # A finite quarry vein must be explored through the paid action.
 for i in game.state.buildings.size():
  if game.state.buildings[i].kind=="quarry" and game.state.coins>=game.vein_cost(i) and game.explore_vein(i):record("quarry_vein");return
func chapter_checkpoint(level: int):
 chapters.append({"hall":level,"elapsed":int(game.state.elapsed),"coins":game.state.coins,"manual_cuts":manual_cuts,"workers":game.state.workers,"buildings":game.state.buildings.size(),"exported":game.state.exported})
 var before=game.state.duplicate(true)
 var saved=JSON.parse_string(JSON.stringify(game.snapshot(),"",true,true))
 if level in [3,6,9]:
  var store=game.get_node("/root/Store")
  checks+=1
  if not store.save_game(saved):failures.append("file save at hall "+str(level))
  else:saved=store.load_game()
 game.restore(saved)
 # Numeric JSON representation may change int to float; compare canonical JSON.
 before.erase("last_seen")
 var after=game.state.duplicate(true);after.erase("last_seen")
 checks+=1
 var normalized_before=JSON.parse_string(JSON.stringify(before,"",true,true))
 var normalized_after=JSON.parse_string(JSON.stringify(after,"",true,true))
 if normalized_before!=normalized_after:
  var keys=[]
  for key in normalized_before:
   if normalized_before[key]!=normalized_after.get(key):keys.append(key)
  failures.append("reload at hall %s: %s" % [level,keys])
 saved_halls[str(level)]=saved
 print("JOURNEY PLAYER HALL ",level," at ",int(game.state.elapsed)," coins ",int(game.state.coins))
func sample():
 var goal=Journey.current(game.state)
 var jobs=[]
 for j in game.state.jobs:jobs.append({"kind":j.kind,"status":ConstructionRules.status(j),"materials":j.get("materials",{}).duplicate(true),"delivered":j.get("delivered",{}).duplicate(true)})
 samples.append({"at":int(game.state.elapsed),"hall":Journey.townhall_level(game.state),"goal":goal,"coins":game.state.coins,"stocks":game.state.resources.duplicate(true),"jobs":jobs,"wood":ForestCycle.wait_reason(game.state),"exported":game.state.exported})
 print("JOURNEY PLAYER SAMPLE ",int(game.state.elapsed)," ",goal.get("id","done")," coins ",int(game.state.coins)," stocks ",game.state.resources," jobs ",jobs)
func observe():
 invariant_samples+=1
 var inventories=[game.state.resources,game.state.hub.receiving]
 for group in [game.state.hub.outputs,game.state.hub.inputs,game.state.hub.express,game.state.delivery.buffers,game.state.delivery.recovered]:
  inventories.append_array(group.values())
 for site in game.state.stone.sites.values():inventories.append(site.stock)
 for stock in inventories:
  for key in stock:
   if not is_finite(float(stock[key])) or float(stock[key]) < -0.00001:failures.append("invalid stock %s at %s" % [key,game.state.elapsed])
 for key in game.state.resources:
  if float(game.state.resources[key])>game.capacity()+0.00001:failures.append("warehouse over capacity: "+str(key))
 if not is_finite(float(game.state.coins)) or game.state.coins < -0.00001:failures.append("invalid currency")
