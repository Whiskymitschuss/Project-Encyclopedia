extends SceneTree
var game
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func fresh() -> void:
 game.state=game.initial_state()
 game.state.city_services.enabled=false
 game.state.workers=0
 game.state.traffic.enabled=false
func trip(id: int, path: Array) -> Dictionary:
 return {"id":id,"job":1,"source":"warehouse","target":"construction","mode":"truck","key":"wood","amount":2.0,"path":path,"age":0.0,"load":2.0,"drive":10.0,"unload":2.0,"travel":14.0,"total":26.0,"arrived":false}
func advance(seconds: int) -> void:
 for i in seconds:
  TrafficRules.prepare(game.state,1)
  ConstructionRules.transport_tick(game.state,1)
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 fresh()
 game.state.jobs=[{"id":1,"delivered":{},"materials":{"wood":4}}]
 var a=trip(1,[[-40,0.95,4],[40,0.95,4]])
 var b=trip(2,[[0,0.95,-36],[0,0.95,44]])
 game.state.construction_shipments=[a,b]
 var wait_seen=false
 var conflicting=false
 for i in 80:
  TrafficRules.prepare(game.state,1)
  ConstructionRules.transport_tick(game.state,1)
  wait_seen=wait_seen or not str(a.get("traffic_wait","")).is_empty() or not str(b.get("traffic_wait","")).is_empty()
  if i<14 and not b.arrived: check(float(game.state.jobs[0].delivered.get("wood",0))<=2,"Stopped cross traffic never credits an undelivered load")
  if game.state.construction_shipments.size()==2:
   var pa=TrafficRules.sample(a,a.age).position
   var pb=TrafficRules.sample(b,b.age).position
   if pa.distance_to(pb)<5 and not a.get("traffic_hidden",false) and not b.get("traffic_hidden",false): conflicting=true
 check(wait_seen and not conflicting,"Perpendicular trucks yield at an actual saved signal without overlapping")
 check(game.state.construction_shipments.is_empty() and game.state.jobs[0].delivered.wood==4,"Both physical loads arrive once and release their trucks after returning")
 fresh()
 game.state.jobs=[{"id":1,"delivered":{},"materials":{"wood":6}}]
 for i in 3: game.state.construction_shipments.append(trip(i+1,[[-40,0.95,4],[40,0.95,4]]))
 TrafficRules.prepare(game.state,1)
 check(game.state.construction_shipments[1].traffic_hidden,"A queued truck stays inside its depot instead of occupying the loading truck")
 ConstructionRules.transport_tick(game.state,1)
 # One circulating truck per yard now includes its empty return. Allow all
 # three complete round trips and their real red-light waits to drain.
 advance(180)
 check(game.state.construction_shipments.is_empty() and game.state.jobs[0].delivered.wood==6,"Three trucks from the same depot drain their queue without losing cargo")
 fresh()
 var cell=Vector2i(-80,-60)
 check(TrafficRules.break_signal(game.state,cell),"An actual junction can suffer one saved fault")
 check(TrafficRules.dispatch_repair(game.state,{}),"A real technician van is dispatched from the neighbouring town")
 var mission=game.state.city_services.missions[0]
 check(mission.kind=="technician" and not mission.served and game.state.traffic.repaired==0,"Dispatch alone never repairs a light")
 var snapshot=JSON.parse_string(JSON.stringify(game.snapshot(),"",true,true))
 game.simulate(180)
 check(game.state.traffic.faults.is_empty() and game.state.traffic.repaired==1,"Technician reaches the faulty light, works there and restores its phase")
 check(game.state.city_services.missions.is_empty(),"Maintenance van returns and releases the service slot")
 var expected=JSON.parse_string(JSON.stringify(game.state.traffic))
 game.restore(snapshot)
 game.simulate(180)
 check(is_equal_approx(float(game.state.traffic.clock),float(expected.clock)) and int(game.state.traffic.repaired)==int(expected.repaired) and game.state.traffic.faults==expected.faults,"Saved fault and technician mission replay identically after JSON restore")
 fresh()
 game.state.builders=1
 var first={"id":1,"type":"upgrade","index":1,"materials":{"wood":10},"delivered":{},"left":14.0,"total":14.0}
 var second={"id":2,"type":"upgrade","index":0,"materials":{},"delivered":{},"left":14.0,"total":14.0}
 ConstructionRules.attach(first,1)
 ConstructionRules.attach(second,0)
 game.state.jobs=[first,second]
 check(ForemanRules.tick(game.state,1) and first.workers==0 and second.workers==1,"Foreman moves an idle crew to a site with actual work available")
 check("Bauteam" in ForemanRules.diagnosis(game.state,first),"Waiting site explains its real missing crew")
 second.auto_crew=false
 second.workers=0
 ForemanRules.tick(game.state,1)
 check(second.workers==0 and first.workers==1,"Manual assignment overrides automatic crew management")
 var legacy=game.snapshot()
 legacy.erase("traffic")
 legacy.erase("foreman")
 game.restore(legacy)
 check(game.state.traffic.faults.is_empty() and game.state.foreman.enabled,"Alpha 1 saves receive clean traffic and crew defaults")
 fresh()
 var center=Catalog.biome_position(0)
 game.state.homes=[{"kind":"house","level":1,"plot":0,"position":[center.x,center.z]}]
 var obstacles=ForestSites.obstacles(game.state)
 check(not ForestSites.clear_at(center,obstacles),"A house excludes normal trees and forestry camps")
 var site=ForestSites.worksite(0,0,obstacles,[])
 check(site!=null and ForestSites.clear_at(site,obstacles,7),"Displaced forestry machinery receives a real clear site inside its biome")
 print("TRAFFIC & MAINTENANCE 29: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
