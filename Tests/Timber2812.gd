extends SceneTree
var game
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func company(lines: int=1,level: int=7) -> Dictionary:
 game.state=game.initial_state()
 var s=game.state
 s.workers=0; s.reserve=false; s.auto_export=false; s.city_services.enabled=false; s.trucks=0
 for b in s.buildings: b.paused=true
 s.buildings[1].paused=false; s.buildings[1].level=level; s.buildings[1].saw_lines=lines
 s.resources.wood=1000
 return s
func equivalent(s: Dictionary) -> float:
 var wood=UXRules.material_stock(s,"wood")
 var boards=UXRules.material_stock(s,"boards")
 return float(wood.stored)+float(wood.transit)+2*(float(boards.stored)+float(boards.transit)+SawmillProduction.pending_total(s))
func same(a: Variant,b: Variant) -> bool:
 if (a is float or a is int) and (b is float or b is int): return absf(float(a)-float(b))<0.000000001
 if a is Dictionary and b is Dictionary:
  if a.size()!=b.size(): return false
  for key in a:
   if not b.has(key) or not same(a[key],b[key]): return false
  return true
 if a is Array and b is Array:
  if a.size()!=b.size(): return false
  for i in a.size():
   if not same(a[i],b[i]): return false
  return true
 return a==b
func run() -> void:
 await process_frame
 game=root.get_node("Game"); game.set_process(false)
 var s=company(1,1)
 var before=equivalent(s)
 game.step(1)
 check(s.resources.boards==0 and absf(SawmillProduction.pending(s,1)-0.9)<0.00001,"Raw intake creates owned work-in-progress, never instant boards")
 check(absf(equivalent(s)-before)<0.00001,"First raw intake preserves all wood equivalents")
 game.step(1)
 check(s.resources.boards==0 and float(s.sawmills.sites["1"].lanes[0].queues[1])>0,"Debarking has its own real intermediate buffer")
 game.step(1)
 check(s.resources.boards==0 and float(s.sawmills.sites["1"].lanes[0].queues[2])>0,"Sawing hands real work to planing before any saleable board exists")
 game.step(1)
 check(absf(float(s.resources.boards)-0.9)<0.00001 and absf(float(s.resources.sawdust)-0.9)<0.00001,"Only the final pass creates the exact board and by-product recipe")
 check(absf(equivalent(s)-before)<0.00001,"Every stage and final credit preserve the original material ledger")
 var rates=[]
 for lines in [1,2,3]:
  s=company(lines)
  for tick in 12: game.step(1)
  var start=float(s.resources.boards)
  before=equivalent(s)
  for tick in 10: game.step(1)
  rates.append(float(s.resources.boards)-start)
  check(absf(equivalent(s)-before)<0.00001,"Parallel lines never duplicate their real input, lines=%s" % lines)
 check(absf(rates[1]-rates[0]*2)<0.00001 and absf(rates[2]-rates[0]*3)<0.00001,"Two and three purchased lines produce exactly twice and three times the steady throughput")
 s=company()
 game.step(1)
 s.buildings[1].paused=true
 var snapshot=s.sawmills.duplicate(true)
 for tick in 10: game.step(1)
 check(s.sawmills==snapshot and s.resources.boards==0,"Paused machinery retains owned work without advancing or crediting goods")
 s.buildings[1].paused=false
 s.resources.boards=game.capacity()
 var raw=float(s.resources.wood)
 for tick in 5: game.step(1)
 check(s.resources.wood==raw and SawmillProduction.pending(s,1)>0,"A full output stops new raw intake while preserving work already inside")
 s.resources.boards=0
 for tick in 6: game.step(1)
 check(s.resources.boards>0,"Free shelf space automatically resumes the actual in-process material")
 # Full-precision save continuation includes each lane, forestry job and seedling.
 s=company(2)
 for tick in 5: game.step(1)
 var encoded=JSON.new();var saved=JSON.parse_string(encoded.stringify(s,"",true,true))
 for tick in 12: game.step(1)
 var expected=s.duplicate(true)
 game.restore(saved);s=game.state
 for tick in 12: game.step(1)
 check(same(s,expected),"Save/reload continues each real processing lane identically")
 if not same(s,expected):
  FileAccess.open("/tmp/timber2812-save-actual.json",FileAccess.WRITE).store_string(encoded.stringify(s,"",true,true))
  FileAccess.open("/tmp/timber2812-save-expected.json",FileAccess.WRITE).store_string(encoded.stringify(expected,"",true,true))
 s=company(1,4)
 s.coins=100000; s.company_xp=600; s.buildings[3].paused=false
 s.buildings.append({"kind":"central_depot","level":1,"paused":false,"position":[44,20]})
 var coins=float(s.coins);var price=game.saw_line_cost(1)
 check(game.order_saw_line(1) and s.coins==coins-price and SawmillProduction.line_count(s,1)==1,"Ordering another line pays once and cannot grant machinery before construction")
 var job=s.jobs.back()
 check(job.get("saw_line",false) and job.has("phases") and not job.materials.is_empty(),"Additional machinery uses the actual staffed delivery/build phases")
 check(not game.order_saw_line(1) and s.coins==coins-price,"A running installation cannot be purchased or charged twice")
 for key in job.materials: s.resources[key]=float(job.materials[key])+50
 var delivered=false;var crew=false
 for tick in 600:
  game.step(1)
  delivered=delivered or not s.construction_shipments.is_empty()
  crew=crew or int(job.get("crew_present",0))>0
  if job not in s.jobs: break
 check(job not in s.jobs and SawmillProduction.line_count(s,1)==2 and int(s.buildings[1].level)==4,"Only real completed construction installs the second line without inventing a building level")
 check(delivered and crew,"The machinery installation was supplied by actual freight and an arrived construction team")
 # A paused owned delivery line takes precedence over its retained work-in-progress.
 s=company()
 for building in s.buildings: building.paused=false
 s.buildings.append({"kind":"furniture","level":1,"position":[-20,-12]})
 DeliveryChain.start(s)
 SawmillProduction.accept(s,1,1,1)
 s.delivery.paused=true
 check(game.production_status(1).contains("Pausiert") and ProductionPresentation.describe(game,1).kind=="paused","Retained intermediate material cannot hide a paused delivery line in the real status and beacon")
 # Forest resources belong to persistent cells, independent of camera/animations.
 s=company();s.workers=8
 var timber=ForestCycle.timber_per_tree(0)
 var amount=ForestCycle.take(s,0,timber)
 check(amount==timber and s.forest.stands["0"].cells.values().any(func(cell): return cell.state=="stump"),"A real cut removes finite standing timber and creates a persistent planting site")
 check(ForestCycle.busy(s)==0,"Cutting itself never grants a phantom planting worker")
 s.elapsed+=1;ForestCycle.tick(s,1)
 check(ForestCycle.busy(s)==1 and ForestCycle.busy(s)<=s.workers,"Actual planting reserves an existing helper and a reachable stump")
 var task=s.forest.tasks[0]
 check(ForestLayout.walkable(s,int(task.biome),int(task.cell)),"A planting assignment uses an unobstructed private forest aisle")
 var route=ForestLayout.path(int(task.biome),int(task.cell))
 check(ForestLayout.reserved(s,Rect2(Vector2(route[1].x-1,route[1].z-1),Vector2(2,2))),"An active planter's actual walk is protected from new building placement")
 check(float(task.walk)>0 and task.total==task.walk*2+4,"Planter travel time follows the real aisle route and includes return")
 while not task.planted:
  s.elapsed+=1;ForestCycle.tick(s,1)
 check(s.forest.planted==1 and s.forest.stands["0"].cells[str(int(task.cell))].state=="growing","The seedling appears only after the worker reaches and plants the actual site")
 var forest_saved=JSON.parse_string(encoded.stringify(s,"",true,true))
 for tick in 40: s.elapsed+=1;ForestCycle.tick(s,1)
 var forest_expected=s.forest.duplicate(true)
 game.restore(forest_saved);s=game.state
 for tick in 40: s.elapsed+=1;ForestCycle.tick(s,1)
 check(same(s.forest,forest_expected),"Active planting, return travel and seedling deadlines continue identically after a full-precision save")
 check(ForestCycle.take(s,0,100000)<timber*100,"Growing trees cannot be harvested as mature stock")
 var ready=float(s.forest.stands["0"].cells[str(int(task.cell))].ready_at)
 s.elapsed=ready;ForestCycle.tick(s,1)
 check(not s.forest.stands["0"].cells.has(str(int(task.cell))),"A finished growth timer restores exactly one mature cell")
 # Disable replanting deliberately: no hidden regrowth creates wood.
 s=company();s.workers=2;s.forest.assignment=0
 ForestCycle.take(s,0,timber*100)
 var cells=s.forest.stands["0"].cells.duplicate(true)
 for tick in 150: s.elapsed+=1;ForestCycle.tick(s,1)
 check(s.forest.tasks.is_empty() and s.forest.stands["0"].cells==cells,"Zero assigned planters does not silently regenerate harvested woodland")
 s=company();s.tool=11;s.quality=0
 var low=ForestCycle.take(s,0,100000)
 s=company();s.tool=11;s.quality=1
 check(ForestCycle.take(s,0,100000)==low,"Changing render quality cannot alter mature timber or reserved forestry-machine stands")
 # Existing saves keep their buildings, levels and goods; no campus teleport.
 s=company();s.coins=100000;s.company_xp=600
 var layout=s.buildings.duplicate(true)
 var quote=TimberCampus.quote(game)
 check(str(quote.reason).is_empty() and quote.lots.size()==4,"A real connected four-facility campus can be planned in free normal lots")
 coins=float(s.coins);snapshot=s.resources.duplicate(true)
 var ordered=game.order_timber_campus(float(quote.price))
 check(ordered and s.jobs.size()==4 and s.coins==coins-float(quote.price),"A campus creates four regular paid construction jobs")
 check(s.jobs.all(func(record): return record.has("phases") and record.requested),"An industrial campus uses actual material-requesting construction phases for all four buildings")
 if not ordered or s.jobs.size()!=4 or s.coins!=coins-float(quote.price): print("CAMPUS DEBUG ",JSON.stringify({"quote":quote,"jobs":s.jobs,"coins":s.coins,"before":coins,"ordered":ordered}))
 check(s.buildings==layout and s.resources==snapshot,"Campus planning never moves old buildings or grants/takes unshipped material")
 check(TimberCampus.links(s).all(func(link): return not link.area.has_point(Vector2.ZERO)),"Private campus connectors do not replace the public central boulevard")
 print("TIMBER 2812 RATES: ",JSON.stringify(rates))
 print("TIMBER 2812: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
