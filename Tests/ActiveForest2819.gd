extends SceneTree
var game
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func company(workers: int=31) -> Dictionary:
 game.state=game.initial_state();var s=game.state
 s.workers=workers;s.tool=14;s.biome=1;s.unlocked=2;s.city_services.enabled=false;s.auto_export=false
 for b in s.buildings:b.paused=true
 s.buildings[0].paused=false;s.buildings[0].level=50
 for index in 100:ForestCycle.stand(s,1).cells[str(index)]={"state":"stump","wood":0.0}
 ForestCycle.stand(s,0)
 return s
func route_length(route: Array) -> float:
 var result=0.0
 for i in range(1,route.size()):result+=route[i-1].distance_to(route[i])
 return result
func run():
 await process_frame
 game=root.get_node("Game");game.set_process(false)
 var s=company()
 var recovered=0;var bypassed=0
 for index in 100:
  if ForestLayout.blocked(s,1,index):continue
  var route=ForestLayout.planting_path(s,1,index)
  check(not route.is_empty() and not ForestLayout.rectangles(s).any(func(rect):return ForestLayout.intersects(route,rect.grow(0.4))),"Free oak planting cell %s has a collision-free real approach" % index)
  if route!=ForestLayout.path(1,index):bypassed+=1
  recovered+=int(not route.is_empty())
 check(recovered==93 and bypassed>0,"All 93 physically free oak cells are reachable, including old stumps behind machine pads")
 var center=Catalog.biome_position(1)
 s.buildings.append({"kind":"warehouse","level":1,"position":[center.x+34,center.z+34]})
 var route=ForestLayout.planting_path(s,1,0)
 check(not route.is_empty() and route[0]!=center+Vector3(34,0,34),"A blocked former entrance selects another free side aisle")
 var copy=route.duplicate();copy.reverse()
 check(ForestLayout.planting_path(s,1,0)==route,"Reversing an actor's route cannot mutate the cached planting path")
 s.elapsed+=1;ForestCycle.tick(s,1)
 var task=s.forest.tasks[0]
 var booked=ForestLayout.task_path(task)
 check(task.has("route") and not ForestLayout.rectangles(s).any(func(rect):return ForestLayout.intersects(booked,rect.grow(0.4))),"An actual mission reserves and saves its chosen detour")
 var midpoint=booked[0].lerp(booked[1],0.5)
 check(ForestLayout.reserved(s,Rect2(midpoint.x-0.4,midpoint.z-0.4,0.8,0.8)),"Placement protects the actual alternate route, rather than the obsolete entry")
 var stock=s.resources.duplicate(true)
 for second in 240:s.elapsed+=1;ForestCycle.tick(s,1)
 check(ForestCycle.availability(s,1).growing==0 and int(ForestCycle.availability(s,1).mature)>75 and s.resources==stock,"Old bare land really regrows around an obstructed entrance without granting warehouse wood")
 # Screenshot reproduction: ten assigned helpers, 95 open oak cells,
 # no growing trees, and the one old entrance blocked by a plot.
 s=company(10);s.tool=0;s.forest.assignment=10
 center=Catalog.biome_position(1)
 s.buildings.append({"kind":"warehouse","level":1,"position":[center.x+28,center.z+28]})
 var old_reachable=0;var free_cells=0
 for index in 100:
  if ForestLayout.blocked(s,1,index):continue
  free_cells+=1
  var old_route=ForestLayout.path(1,index)
  if not ForestLayout.rectangles(s).any(func(rect):return ForestLayout.intersects(old_route,rect.grow(0.4))):old_reachable+=1
 check(free_cells==95 and old_reachable==0,"Screenshot-shaped old layout reproduces 95 open cells with no usable legacy entrance")
 stock=s.resources.duplicate(true)
 s.elapsed+=1;ForestCycle.tick(s,1)
 check(s.forest.tasks.size()==10 and s.forest.tasks.all(func(item):return int(item.biome)==1),"The ten explicitly assigned helpers actually start oak replanting on free side paths")
 for second in 240:s.elapsed+=1;ForestCycle.tick(s,1)
 check(int(ForestCycle.availability(s,1).mature)==95 and s.resources==stock,"All 95 free screenshot-shaped oak cells regrow without a stock grant")
 print("SCREENSHOT 2819: 10 assigned helpers, 95 open cells, 0 legacy routes -> 10 missions, 95 mature after 240 simulated seconds")
 # Legacy in-flight trips retain their route and times when bonuses change.
 s=company();s.forest.tasks=[{"id":1,"biome":1,"cell":0,"age":1.0,"walk":20.0,"total":44.0,"planted":false}];s.forest.next_id=2
 s.research.forestry=10;s.boosters.workers={"factor":2.0,"left":2000.0}
 s.elapsed+=1;ForestCycle.tick(s,1)
 task=s.forest.tasks[0]
 check(task.walk==20 and task.total==44 and ForestLayout.task_path(task)==ForestLayout.path(1,0),"A saved legacy mission keeps its existing timing and geometry")
 var fresh=s.forest.tasks.filter(func(t):return int(t.id)>1)[0]
 check(absf(float(fresh.walk)-maxf(1,route_length(ForestLayout.task_path(fresh))/16.0))<0.00001 and fresh.plant<4,"New boosted missions actually travel and plant faster")
 var saved=JSON.parse_string(JSON.stringify(s,"",true,true))
 game.restore(saved);s=game.state
 check(s.forest.tasks[0].walk==20 and ForestLayout.task_path(s.forest.tasks[1])==ForestLayout.task_path(fresh),"Saving preserves both old and new route representations")
 # Continue actual boosted research and saved deadlines through a reload.
 for second in 120:game.step(1)
 var expected=s.forest.duplicate(true)
 game.restore(saved);s=game.state
 game.simulate(120)
 check(s.forest==expected,"Boosted planting, saved detours and researched seedlings continue identically after reload")
 # Full actual Game.step, with an explicit test wood sink after every tick.
 # The sink isolates the forest from downstream truck or storage limits.
 var measurements=[]
 for workers in [8,31]:
  for mode in [0,1,2,3]:
   s=company(workers)
   s.research.forestry=12 if mode==3 else 10 if mode>0 else 0
   if mode>=2:s.boosters.workers={"factor":2.0,"left":2000.0}
   var low=100;var empty=0;var total=0.0;var mature_peak=0
   for second in 900:
    game.step(1)
    total+=float(game.flow.harvest)
    var info=ForestCycle.availability(s,1)
    if second>=300:low=mini(low,int(info.mature));empty+=int(info.mature==0)
    mature_peak=maxi(mature_peak,int(info.mature))
    s.resources.wood=0.0
   check(low>=10 and empty==0,"The real active oak forest stays harvestable at workers=%s, research/boost mode=%s" % [workers,mode])
   check(total>1000 and absf(float(s.journey.stats.automatic_wood)-total)<0.000001,"Every generated log is accounted as real worker harvest")
   check(ForestCycle.busy(s)<=workers and int(ForestCycle.availability(s,0).mature)==100,"Planting uses hired staff and leaves the recovered starter forest intact")
   measurements.append({"workers":workers,"forestry_research":int(s.research.forestry),"worker_boost":2 if mode>=2 else 1,"seconds":900,"minimum_active_mature_after_300s":low,"empty_seconds_after_300s":empty,"automatic_wood":total})
 # A full pickup output stops cutting, but must never stop replanting.
 s=company();s.buildings.append({"kind":"central_depot","level":1,"paused":true,"position":[44,20]})
 LogisticsDispatch.synchronize(s)
 CentralLogistics.stock(s,0).wood=CentralLogistics.output_capacity(s,0)
 var owned=float(CentralLogistics.stock(s,0).wood)
 for second in 240:game.step(1)
 check(int(ForestCycle.availability(s,1).mature)==93,"All physically free trees recover while the collection landing remains full")
 check(float(s.journey.stats.get("automatic_wood",0))==0 and float(CentralLogistics.stock(s,0).wood)==owned,"Regeneration never bypasses a full pickup output or grants stock")
 print("ACTIVE FOREST 2819 MEASURES: ",JSON.stringify(measurements))
 print("ACTIVE FOREST 2819: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
