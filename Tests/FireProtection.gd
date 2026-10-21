extends SceneTree
var game
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func equivalent(a: Variant,b: Variant) -> bool:
 if (a is float or a is int) and (b is float or b is int): return absf(float(a)-float(b))<0.00000001
 if a is Dictionary and b is Dictionary:
  if a.size()!=b.size(): return false
  for key in a:
   if not b.has(key) or not equivalent(a[key],b[key]): return false
  return true
 if a is Array and b is Array:
  if a.size()!=b.size(): return false
  for i in a.size():
   if not equivalent(a[i],b[i]): return false
  return true
 return a==b
func fresh() -> Dictionary:
 game.state=game.initial_state()
 game.state.city_services.enabled=false
 game.state.coins=10000
 game.state.homes=[{"kind":"house","level":1,"plot":0,"position":[-24,86]},{"kind":"house","level":1,"plot":1,"position":[0,86]},{"kind":"house","level":1,"plot":2,"position":[100,86]}]
 game.city_route_cache.clear()
 return game.state
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 var s=fresh()
 var target={"type":"home","index":1}
 check(not game.buy_fire_protection(-1,"hydrant"),"Invalid index rejected")
 check(not game.buy_fire_protection(0,"unknown"),"Unknown equipment rejected")
 s.coins=0
 check(not game.buy_fire_protection(0,"detector") and not s.homes[0].has("fire_safety"),"Insufficient funds neither grants equipment nor creates metadata")
 s.coins=10000
 check(game.buy_fire_protection(0,"detector"),"Detector can be bought for a real home")
 check(s.coins==9875,"Detector charges exactly the displayed price")
 check(not game.buy_fire_protection(0,"detector") and s.coins==9875,"Duplicate purchase cannot charge again")
 check(game.buy_fire_protection(0,"hydrant") and s.coins==9525,"Hydrant charges its displayed price exactly once")
 check(s.homes[0].fire_safety.hydrant_offset.size()==3,"Hydrant placement is saved with the purchase")
 var fixed_position=FireSafety.hydrant_position(s,0)
 s.town.roads.append({"kind":"asphalt","cells":[[-24,88]],"cost":0})
 check(FireSafety.hydrant_position(s,0)==fixed_position,"Building a closer road cannot teleport an installed hydrant")
 s.town.roads.clear()
 check(FireSafety.water_source(s,1,{}).get("index",-1)==0,"Hydrant supplies a connected nearby home")
 check(FireSafety.water_source(s,2,{}).is_empty(),"Hydrant has a finite range")
 var position=FireSafety.hydrant_position(s,0)
 s.homes[2].position=[position.x+44,position.z]
 check(not FireSafety.water_source(s,2,{}).is_empty(),"Displayed 44 m range includes its horizontal boundary")
 s.homes[2].position=[position.x+44.01,position.z]
 check(FireSafety.water_source(s,2,{}).is_empty(),"Just beyond 44 m is outside coverage")
 s.homes[2].position=[100,86]
 var pure=s.duplicate(true)
 FireSafety.water_source(s,1,{})
 FireSafety.fleet(s)
 check(s==pure,"Coverage and fleet queries cannot modify a saved state")
 CityServices.ignite(s,target)
 CityServices.tick(s,1,{})
 var mission=s.city_services.missions[0]
 check(float(mission.work)==24,"Coverage shortens actual on-site work from 36 to 24 seconds")
 check(int(mission.water_source_ref.index)==0 and mission.water_route.size()>=2,"Dispatch saves the real water source and connected hose route")
 check(CityServices.uses_building(s,0,true),"A supplying home is protected while its hydrant is in use")
 check(FireSafety.fleet(s).busy==1 and FireSafety.fleet(s).free==0,"External engine is counted while dispatched")
 var restored=JSON.parse_string(JSON.stringify(s,"",false,true))
 for i in 160:
  CityServices.tick(s,1,{})
  CityServices.tick(restored,1,{})
 check(equivalent(s.city_services,restored.city_services),"JSON restore preserves all service outcomes during an actual hydrated fire")
 check(bool(restored.homes[0].fire_safety.detector) and bool(restored.homes[0].fire_safety.hydrant),"Purchased equipment survives JSON restore")
 check(s.city_services.fires_extinguished==1 and s.city_services.treasury==20,"Shorter work does not duplicate bonuses")
 check(FireSafety.fleet(s).free==1,"Engine becomes available only after return")
 s=fresh()
 CityServices.ignite(s,target,false)
 CityServices.tick(s,11,{})
 check(s.city_services.missions.is_empty() and FireSafety.alarm_left(s.city_services.fires[0])==1,"An unprotected automatic fire has a real detection delay")
 check(FireSafety.status(s,s.city_services.fires[0]).contains("Erkennung"),"Detection delay has an explicit player-facing status")
 CityServices.tick(s,1,{})
 check(s.city_services.missions.size()==1 and s.city_services.missions[0].work==36,"After 12 seconds an unprotected fire receives normal engine supply")
 var original_work=s.city_services.missions[0].work
 game.buy_fire_protection(0,"hydrant")
 check(s.city_services.missions[0].work==original_work,"Installing after dispatch cannot rewrite an active mission's clock")
 s=fresh()
 game.buy_fire_protection(1,"detector")
 CityServices.ignite(s,target,false)
 CityServices.tick(s,1,{})
 check(s.city_services.missions.size()==1,"Detector dispatches immediately for new automatic fires")
 s=fresh()
 CityServices.ignite(s,target,false)
 CityServices.tick(s,2,{})
 var fire=s.city_services.fires[0]
 check(game.report_fire(int(fire.id)),"Player can report an undetected fire")
 check(not game.report_fire(int(fire.id)),"Repeated reporting cannot repeat the alarm")
 CityServices.tick(s,1,{})
 check(s.city_services.missions.size()==1,"Manual alarm dispatches before automatic detection")
 s=fresh()
 s.homes[0].position=[5000,5000]
 s.homes[1].position=[5020,5000]
 game.buy_fire_protection(0,"hydrant")
 check(FireSafety.water_source(s,1,{}).is_empty(),"Proximity alone does not invent a connected water supply")
 CityServices.ignite(s,target)
 CityServices.tick(s,1,{})
 check(FireSafety.status(s,s.city_services.fires[0]).contains("Straßenanschluss"),"Blocked roads have a distinct status")
 s=fresh()
 s.homes[0].position=[-116,-120]
 s.homes[1].position=[-80,-120]
 check(game.build_road("asphalt",TownRules.path(Vector2i(-80,-140),Vector2i(-116,-140))),"Actual road extension can serve the hydrant")
 game.buy_fire_protection(0,"hydrant")
 CityServices.ignite(s,target)
 CityServices.tick(s,1,{})
 check(s.city_services.missions[0].water_source_ref.get("index",-1)==0,"Water supply uses the new road branch")
 check(not game.remove_road(0),"Road occupied only by a supply hose cannot be removed")
 CityServices.tick(s,300,{})
 check(game.remove_road(0),"Road can be removed after hose and engine return")
 s=fresh()
 CityServices.ignite(s,target)
 s.city_services.fires[0].erase("alarm_after")
 CityServices.tick(s,1,{})
 check(s.city_services.missions.size()==1,"Legacy active fires remain reported and immediately serviceable")
 var saved=game.snapshot()
 game.restore(saved)
 check(not FireSafety.installed(game.state,0,"hydrant"),"Old houses are not silently charged or granted equipment")
 print("FIRE PROTECTION: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
