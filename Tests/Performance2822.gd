extends SceneTree
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
# Independent original linear sampler: compare positions and facing at corners,
# endpoints, repeated checkpoints and clamped fractions, including curved roads.
func reference(points: Array,fraction: float) -> Dictionary:
 if points.size()<2:return {"position":Vector3.ZERO,"direction":Vector3.FORWARD}
 var line=LogisticsRoutes.driving_path(points)
 var distance=LogisticsRoutes.length(line)*clampf(fraction,0,1)
 for i in range(1,line.size()):
  var a=LogisticsRoutes.vector(line[i-1]);var b=LogisticsRoutes.vector(line[i]);var length=a.distance_to(b)
  if distance<=length and length>0.00001:return {"position":a.lerp(b,distance/length),"direction":(b-a).normalized()}
  distance-=length
 return {"position":LogisticsRoutes.vector(line[-1]),"direction":(LogisticsRoutes.vector(line[-1])-LogisticsRoutes.vector(line[-2])).normalized()}
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 var stats=root.get_node("RuntimeStats");stats.set_process(false)
 var saved=game.state.duplicate(true)
 var routes=[[],[[0,0,0]],[[0,0,0],[0,0,0]],[[0,0,0],[10,0,0]],[[0,0,0],[0,0,0],[10,0,0],[10,0,10],[10,0,10]],[[0,0,0],[0,0,8],[0,2,8],[7,2,8]]]
 var long_route=[]
 for i in 160:long_route.append([int(i/2.0)*4,0,(int((i+1)/2.0)%2)*4])
 routes.append(long_route)
 var unchanged=routes.duplicate(true)
 for route in routes:
  var correct=true
  for step in range(-2,103):
   var fraction=step/100.0
   var expected=reference(route,fraction);var actual=LogisticsRoutes.sample(route,fraction)
   if expected.position.distance_to(actual.position)>0.0002 or expected.direction.distance_to(actual.direction)>0.0002:correct=false
  check(correct,"Prepared route retains original position and facing for %s checkpoints" % route.size())
 check(routes==unchanged,"Sampling never edits saved checkpoints, route reservations or cargo")
 var path=[[0,0,0],[10,0,0],[10,0,10]]
 LogisticsRoutes.sample_cache.clear();LogisticsRoutes.sample(path,0.5)
 var built=LogisticsRoutes.sample_builds
 for i in 100:LogisticsRoutes.sample(path,i/99.0)
 check(LogisticsRoutes.sample_builds==built,"One hundred moving frames reuse one prepared route")
 path[1][0]=20
 check(LogisticsRoutes.sample(path,0.5).position.distance_to(reference(path,0.5).position)<0.0002 and LogisticsRoutes.sample_builds==built+1,"Editing an existing route invalidates its prepared geometry")
 for i in 530:LogisticsRoutes.sample([[i,0,0],[i+1,0,0]],0.5)
 check(LogisticsRoutes.sample_cache.size()==512,"Prepared geometry has a fixed bounded cache")
 stats.start_profile()
 for i in 300:
  var started=stats.begin_work()
  stats.end_work("Test",started)
 var result=stats.finish_profile()
 check(result.Test.samples==180 and result.Test.p95_ms>=0 and not stats.profiling,"Tour CPU diagnostics use bounded real elapsed samples and stop explicitly")
 var prior=stats.work.duplicate(true)
 stats.end_work("Disabled",Time.get_ticks_usec());check(stats.begin_work()==0 and stats.work==prior,"Passive play records no CPU section samples")
 check(game.state==saved,"Sampling and diagnostics preserve every saved company field")
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene
 scene.set_process(false);scene.hud.ux.set_process(false)
 var forest=scene.forest_world
 var s=game.state;var before=s.duplicate(true)
 ForestCycle.stand(s,0).cells["0"]={"state":"stump","wood":0.0}
 forest.sync_trees(false)
 var updates=forest.tree_updates
 for i in 15:forest.sync_trees(false)
 check(forest.tree_updates==updates,"An unchanged harvested cell causes no redundant tree/stump transform writes")
 var cell=s.forest.stands["0"].cells["0"]
 cell.state="growing";cell.ready_at=float(s.elapsed)+45;cell.grow_seconds=45.0
 forest.sync_trees(false)
 check(forest.tree_updates==updates+1,"Actual planting updates exactly the affected visible tree slot")
 s.elapsed+=5;forest.sync_trees(false)
 check(forest.tree_updates==updates+2,"A growing seedling still visibly grows over time")
 scene.refresh_forest_clearance();updates=forest.tree_updates
 check(forest.rendered.has("0:0"),"Placement/clearance refresh immediately restores the true growth display")
 forest.sync_trees(false)
 check(forest.tree_updates==updates,"Clearing geometry invalidation settles without perpetual uploads")
 s.forest.stands["0"].cells.erase("0");forest.sync_trees(false)
 check(forest.rendered["0:0"].y==1,"A newly mature cell restores its full tree, including an erased sparse record")
 game.restore(before)
 scene.queue_free();await process_frame
 print("PERFORMANCE 2822: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
