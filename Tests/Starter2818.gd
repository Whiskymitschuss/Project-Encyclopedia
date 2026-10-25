extends SceneTree
var game
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func company(workers: int=8) -> Dictionary:
 game.state=game.initial_state();var s=game.state
 s.workers=workers;s.tool=11;s.biome=1;s.unlocked=2
 s.city_services.enabled=false;s.auto_export=false
 for biome in [0,1]:
  var cells=ForestCycle.stand(s,biome).cells
  for index in 100:cells[str(index)]={"state":"stump","wood":0.0}
 return s
func tick(s: Dictionary):
 s.elapsed+=1;ForestCycle.tick(s,1)
func same(a: Variant,b: Variant) -> bool:
 if (a is float or a is int) and (b is float or b is int):return absf(float(a)-float(b))<0.0000001
 if a is Dictionary and b is Dictionary:
  if a.size()!=b.size():return false
  for key in a:
   if not b.has(key) or not same(a[key],b[key]):return false
  return true
 if a is Array and b is Array:
  if a.size()!=b.size():return false
  for i in a.size():
   if not same(a[i],b[i]):return false
  return true
 return a==b
func run():
 await process_frame
 game=root.get_node("Game");game.set_process(false)
 var measurements=[]
 var encoded=JSON.new()
 for workers in [1,8,31]:
  var s=company(workers)
  s.forest.erase("next_plant_biome") # Existing 0.28.17 clear-cut starter field.
  var saved=JSON.parse_string(encoded.stringify(s,"",true,true))
  game.restore(saved);s=game.state
  check(s.forest.next_plant_biome==0 and s.biome==1,"An old bare starter save gets a scheduler cursor without switching the active forest")
  var first=-1;var got_starter=false;var got_current=false;var peak=0
  var stock=s.resources.duplicate(true)
  var stats=s.journey.stats.duplicate(true)
  for second in 900:
   tick(s)
   peak=maxi(peak,ForestCycle.busy(s))
   for task in s.forest.tasks:
    got_starter=got_starter or int(task.biome)==0
    got_current=got_current or int(task.biome)==1
   ForestCycle.take(s,1,2.704*maxi(0,workers-ForestCycle.busy(s)))
   if first<0 and int(ForestCycle.availability(s,0).mature)>0:first=second+1
  var recovered=int(ForestCycle.availability(s,0).mature)
  check(got_starter and got_current,"Both old and current woodland get real missions even with %s worker(s)" % workers)
  check(first>0 and first<=75,"Old starter land grows first actual mature trees within 75 seconds: %s worker(s)" % workers)
  check(recovered>=10 if workers==1 else recovered==100,"Starter reforestation progresses under continuous demand in the other forest: %s worker(s)" % workers)
  check(peak<=workers and s.resources==stock and s.journey.stats==stats,"Reforestation never invents staff, goods or harvest achievements: %s worker(s)" % workers)
  check(ForestCycle.recovery_status(s).contains("Starter-Wald") and ForestCycle.recovery_status(s).contains("Eichenwald"),"The real team overview includes the inactive starter forest")
  measurements.append({"workers":workers,"seconds":900,"first_starter_mature_seconds":first,"starter_mature":recovered,"active_biome":s.biome})
 # A one-person manual planting team also rotates; no parallel phantom worker.
 var s=company();s.forest.assignment=1
 tick(s)
 var first=s.forest.tasks[0]
 check(int(first.biome)==0 and ForestCycle.busy(s)==1,"One explicitly assigned planter first serves the old starter field")
 var saved=JSON.parse_string(encoded.stringify(s,"",true,true))
 var saved_age=float(first.age)
 for second in 45:tick(s)
 var expected=s.forest.duplicate(true)
 game.restore(saved);s=game.state
 check(s.forest.tasks[0].age==saved_age,"Loading preserves the existing planting mission age")
 for second in 45:tick(s)
 check(same(s.forest,expected),"Saved rotation and existing travel continue identically after reload")
 check(s.forest.tasks.any(func(task):return int(task.biome)==1),"After the first round trip, the single planter serves the other forest")
 # Disabling planting remains explicit and is never silently overridden.
 s=company();s.forest.assignment=0
 var before=s.forest.stands.duplicate(true)
 for second in 100:tick(s)
 check(s.forest.tasks.is_empty() and s.forest.stands==before,"Zero assigned planters remains zero across both forests")
 # A blocked older route cannot prevent all other stands from being planted.
 s=company();var center=Catalog.biome_position(0)
 s.buildings.append({"kind":"warehouse","level":1,"position":[center.x+34,center.z+34]})
 tick(s)
 check(not s.forest.tasks.is_empty() and s.forest.tasks.all(func(task):return int(task.biome)==1),"Unreachable starter approaches are skipped without deadlocking the other forest")
 # Already saved current-forest missions must finish before slots rotate.
 s=company(8)
 var old_starter=s.forest.stands["0"]
 s.forest.stands.erase("0")
 tick(s)
 s.forest.stands["0"]=old_starter
 s.forest.erase("next_plant_biome")
 var old_tasks=s.forest.tasks.duplicate(true)
 saved=JSON.parse_string(encoded.stringify(s,"",true,true))
 game.restore(saved);s=game.state
 check(same(s.forest.tasks,old_tasks),"Loading old busy planting crews preserves every mission and travel time")
 for second in 120:
  tick(s)
  ForestCycle.take(s,1,2.704*maxi(0,int(s.workers)-ForestCycle.busy(s)))
 check(int(ForestCycle.availability(s,0).mature)>0,"An old fully busy current-forest team makes room for the bare starter field after returning")
 # One real worker must reach every visited stand, across changing selection.
 game.state=game.initial_state();s=game.state;s.workers=1;s.unlocked=10;s.tool=0
 for biome in 10:
  for index in 100:
   if ForestLayout.blocked(s,biome,index) or not ForestLayout.walkable(s,biome,index):continue
   ForestCycle.stand(s,biome).cells[str(index)]={"state":"stump","wood":0.0}
   break
 var seen={}
 for second in 600:
  s.biome=second%10
  tick(s)
  for task in s.forest.tasks:seen[int(task.biome)]=true
 check(seen.size()==10,"One planter reaches all ten visited forests despite continuous selection changes")
 print("STARTER 2818 MEASURES: ",JSON.stringify(measurements))
 print("STARTER 2818: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
