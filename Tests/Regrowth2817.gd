extends SceneTree
var game
var checks=0
var failures=[]
func _initialize(): call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok: failures.append(message);printerr("FAILED: ",message)
func company(workers: int=31,biome: int=1) -> Dictionary:
 game.state=game.initial_state();var s=game.state
 s.workers=workers;s.biome=biome;s.unlocked=maxi(1,biome+1);s.tool=11
 s.city_services.enabled=false;s.auto_export=false
 return s
func tick(s: Dictionary):
 s.elapsed+=1;ForestCycle.tick(s,1)
func same(a: Variant,b: Variant) -> bool:
 if (a is float or a is int) and (b is float or b is int): return absf(float(a)-float(b))<0.0000001
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
func run():
 await process_frame
 game=root.get_node("Game");game.set_process(false)
 var s=company()
 check(ForestCycle.limit(s)==16,"Healthy automatic woodland keeps its ordinary half-team allocation")
 var cut=ForestCycle.take(s,1,100000)
 check(cut>0 and ForestCycle.availability(s).mature==0,"Stress fixture genuinely depletes reachable mature timber")
 check(ForestCycle.limit(s)==28 and ForestCycle.limit(s)<int(s.workers),"A depleted forest automatically reserves more planters while retaining cutters")
 s.forest.assignment=3
 check(ForestCycle.limit(s)==3,"Explicit manual allocation remains authoritative")
 s.forest.assignment=0
 var snapshot=s.forest.stands.duplicate(true)
 for second in 150: tick(s)
 check(s.forest.stands==snapshot and s.forest.tasks.is_empty(),"Disabling planting never produces hidden replacement trees")
 check(ForestCycle.status(s).contains("deaktiviert") and ForestryFlow.overview(s,{}).contains("deaktiviert"),"Team and world explain disabled planting instead of zero-rate felling")
 s.forest.assignment=-1
 var first=-1;var first_planted=-1;var peak=0
 var stock=s.resources.duplicate(true)
 for second in 180:
  tick(s)
  peak=maxi(peak,ForestCycle.busy(s))
  if first_planted<0 and int(s.forest.planted)>0:first_planted=second+1
  if first<0 and int(ForestCycle.availability(s).mature)>0:first=second+1
 check(first_planted>0 and first>=first_planted+int(ForestCycle.GROW_SECONDS),"A worker must arrive, plant, then complete the full seedling phase")
 check(first<=70,"An initially bare oak forest returns first real harvestable trees within 70 seconds")
 check(int(ForestCycle.availability(s).mature)>=70,"A depleted reachable stand visibly recovers under real planting missions")
 check(peak<=int(s.workers) and s.resources==stock,"Recovery never invents workers or credits wood before felling")
 var ids={};var unique=true
 for task in s.forest.tasks:
  var key="%s:%s" % [task.biome,task.cell]
  if ids.has(key):unique=false
  ids[key]=true
 check(unique,"Concurrent planters never reserve the same cell twice")
 # Saved 90-second seedlings retain elapsed growth under the shorter rule.
 s=company();s.workers=0;s.elapsed=100
 var cells=ForestCycle.stand(s,1).cells
 cells["90"]={"state":"growing","wood":0.0,"ready_at":160.0}
 cells["91"]={"state":"growing","wood":0.0,"ready_at":120.0}
 stock=s.resources.duplicate(true)
 ForestCycle.tick(s,0)
 check(cells["90"].ready_at==115 and cells["90"].planted_at==70 and cells["90"].grow_seconds==45,"Legacy migration preserves thirty seconds of elapsed growth")
 check(not cells.has("91") and cells.has("90"),"Only old seedlings already beyond the new growth duration mature")
 check(s.resources==stock and s.forest.harvested==0,"Deadline migration cannot grant goods or harvest statistics")
 var encoded=JSON.new();var saved=JSON.parse_string(encoded.stringify(s,"",true,true))
 for second in 25:tick(s)
 var expected=s.forest.duplicate(true)
 game.restore(saved);s=game.state
 for second in 25:tick(s)
 check(same(s.forest,expected),"Migrated deadlines continue identically after a full-precision save")
 # A fully enclosed tree remains unreachable, even with alternate aisles.
 s=company();s.tool=0;s.forest.assignment=0;cells=ForestCycle.stand(s,1).cells
 var center=ForestLayout.point(1,44)
 for offset in [Vector3(16,0,0),Vector3(-16,0,0),Vector3(0,0,18),Vector3(0,0,-18)]:
  s.buildings.append({"kind":"warehouse","level":1,"position":[center.x+offset.x,center.z+offset.z]})
 for index in 100:cells[str(index)]={"state":"stump","wood":0.0}
 check(not ForestLayout.blocked(s,1,44) and not ForestLayout.walkable(s,1,44),"Enclosed-approach fixture leaves the actual tree free but blocks every route")
 cells["44"]={"state":"mature","wood":ForestCycle.timber_per_tree(1)}
 check(ForestCycle.take(s,1,100000)==0 and cells["44"].state=="mature","Felling never creates a permanent stump behind an unreachable planting aisle")
 # Continuous explicit demand stresses only real forest stock, not warehouse capacity.
 var measurements=[]
 for workers in [8,31]:
  s=company(workers)
  var minimum=100;var quiet=0;var longest=0;var harvested=0.0
  for second in 900:
   tick(s)
   var amount=ForestCycle.take(s,1,2.704*maxi(0,workers-ForestCycle.busy(s)))
   harvested+=amount
   quiet=quiet+1 if amount<0.00001 else 0;longest=maxi(longest,quiet)
   if second>=300:minimum=mini(minimum,int(ForestCycle.availability(s).mature))
  check(minimum>=15 and longest==0,"Unattended %s-worker oak stand retains harvestable trees under continuous demand" % workers)
  check(absf(float(s.forest.harvested)-harvested)<0.000001,"All stress yield is deducted from finite mature cells: %s workers" % workers)
  measurements.append({"workers":workers,"seconds":900,"minimum_reachable_mature_after_300s":minimum,"longest_no_harvest":longest,"wood":harvested})
 print("REGROWTH 2817 MEASURES: ",JSON.stringify(measurements))
 print("REGROWTH 2817: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
