extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func run() -> void:
 await process_frame
 var game=root.get_node("Game"); game.set_process(false)
 game.state=game.initial_state(); var s=game.state
 s.workers=6;s.city_services.enabled=false;s.auto_export=false
 var before=s.duplicate(true)
 for slot in 4:
  var site=ForestLayout.worksite(s,slot,4)
  check(not site.is_empty(),"A hired woodcutter has a genuinely reachable standing tree")
  if site.is_empty(): continue
  var tree=ForestLayout.point(0,int(site.cell));var center=Catalog.biome_position(0)
  check(site.origin.distance_to(tree)<3.5 and site.origin.z<center.z+30,"The axe workplace is next to a tree inside the forest, not on the outside path")
  var route=[]
  for point in site.route: route.append(LogisticsRoutes.vector(point))
  check(not ForestLayout.rectangles(s).any(func(rect): return ForestLayout.intersects(route,rect.grow(0.35))),"The complete carrying route avoids plots, roads and machinery stands")
 check(s==before,"Planning visible woodcutter paths never writes company inventory or forestry state")
 var site=ForestLayout.worksite(s,0,1)
 s.forest.stands["0"]={"cursor":90,"cells":{str(site.cell):{"state":"growing","ready_at":9999.0}}}
 check(ForestLayout.worksite(s,0,1).cell!=site.cell,"A growing replacement cannot be selected as the next standing work tree")
 s=game.initial_state(); game.state=s;s.workers=6;s.city_services.enabled=false;s.auto_export=false
 s.buildings[0].level=2
 s.buildings.append({"kind":"central_depot","level":1,"paused":false,"position":[44,20]})
 LogisticsDispatch.synchronize(s)
 s.resources.wood=1050;s.resources.boards=1183
 CentralLogistics.stock(s,0).wood=80
 check(CentralLogistics.output_room(s,0,"wood")>0,"The old eighty-log landing gains real free space without inventing a waiting stop")
 CentralLogistics.stock(s,0).wood=CentralLogistics.output_capacity(s,0)
 check(ForestryFlow.overview(s,{"harvest":0})=="Wartet auf Holzabholung","A genuinely full current landing has an honest collection reason")
 var gathered=float(s.gathered); var picked=false
 for second in 600:
  game.step(1)
  picked=picked or s.hub.shipments.any(func(trip): return int(trip.origin)==0 and trip.key=="wood")
 check(picked and float(s.gathered)>gathered,"The screenshot-shaped company actually dispatches collection and resumes automatic harvest without manual cutting")
 check(ForestryFlow.overview(s,{"harvest":1}).is_empty(),"Running actual forestry never retains an obsolete waiting badge")
 # A correctly full store is a stop condition, not permission to invent logs.
 game.state=game.initial_state();s=game.state;s.workers=6
 for building in s.buildings:
  if building.kind!="station": building.paused=true
 s.resources.wood=game.capacity()
 gathered=float(s.gathered)
 for second in 30: game.step(1)
 check(float(s.gathered)==gathered and ForestryFlow.overview(s,game.flow)=="Holzlager voll","A full store stops real wood production and explains the stop")
 print("FOREST ACCESS 2813: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
