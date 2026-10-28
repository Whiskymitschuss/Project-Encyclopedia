extends SceneTree
var game
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func fresh() -> Dictionary:
 game.restore(game.initial_state())
 game.state.buildings.append({"kind":"central_depot","level":1,"position":[-44,20]})
 game.state.buildings.append({"kind":"stoneworks","level":1,"position":[-24,-12]})
 game.state.buildings.append({"kind":"express","level":1,"position":[44,20]})
 StoneIndustry.synchronize(game.state)
 return game.state
func run():
 await process_frame
 game=root.get_node("Game");game.set_process(false);game.simulation_only=true
 root.get_node("Music").shutdown()
 # Isolated edge fixtures complement the separate, unseeded full playthrough.
 for key in ["stone","gravel"]:
  for target in ["central","express"]:
   var state=fresh();var to=5 if target=="central" else 7
   var stock=StoneIndustry.site(state,6).stock;stock[key]=12.0
   check(CentralLogistics.launch(state,6,to,key,12.0,target,stock),"Real pickup launches: "+key+"/"+target)
   var trip=state.hub.shipments.back()
   CentralLogistics.tick(state,float(trip.travel)-0.01)
   check(state.stone.delivered==0,"No delivery credit before completed unloading")
   # Game.step owns the chapter counter delta; automatic dispatch may continue.
   game.step(0.02)
   check(state.stone.delivered==12.0 and float(state.journey.stats.get("stone_delivered",0))==12,"Both warehouse and chapter counters credit an actual arrival")
   var saved=JSON.parse_string(JSON.stringify(game.snapshot()))
   game.restore(saved);game.step(0.1)
   check(game.state.stone.delivered==12 and game.state.journey.stats.stone_delivered==12,"Reloading an arrived return cannot credit a delivery twice")
 var state=fresh()
 var regional=CentralLogistics.stock(state,7,true);regional.stone=8.0
 check(CentralLogistics.launch(state,7,5,"stone",8.0,"central",regional),"Regional forwarding launches")
 CentralLogistics.tick(state,500)
 check(state.stone.delivered==0,"Regional forwarding cannot count produced goods for a second time")
 var raw=StoneIndustry.site(state,6).stock;raw.rock=6.0
 check(CentralLogistics.launch(state,6,5,"rock",6.0,"central",raw),"Raw cargo launches for counter exclusion check")
 CentralLogistics.tick(state,500)
 check(state.stone.delivered==0,"Raw rock never fulfills the finished-material chapter")
 state=fresh();state.resources.stone=CentralLogistics.capacity(state)
 state.hub.receiving.stone=CentralLogistics.receiving_capacity(state)
 var cargo={"id":330001,"origin":6,"destination":5,"target":"central","key":"stone","amount":5.0,"path":[[-24,0,-12],[-44,0,20]],"load":1.0,"drive":1.0,"unload":1.0,"travel":3.0,"total":5.0,"age":0.0,"arrived":false}
 state.hub.shipments.append(cargo)
 CentralLogistics.tick(state,4)
 check(not cargo.arrived and state.stone.delivered==0,"A fully blocked unloading bay cannot award delivery progress")
 state.resources.stone-=10
 CentralLogistics.tick(state,0.1)
 check(cargo.arrived and state.stone.delivered==5,"The delayed load is credited exactly when space allows unloading")
 state=fresh();var site=StoneIndustry.site(state,6)
 check(not StoneIndustry.auto_recipe(state,6),"Legacy works keep their manual recipe")
 check(game.set_stone_auto(6,true),"Existing works can enable demand-based production")
 state.resources.stone=30;site.stock.rock=6
 StoneIndustry.factory_tick(state,6,5,1)
 check(site.stock.gravel==4 and site.stock.stone==0 and site.stock.rock==3,"Automatic gravel batch consumes three real rocks and creates four gravel")
 check(game.set_stone_recipe(6,"blocks") and not StoneIndustry.auto_recipe(state,6),"Explicit recipe selection disables automatic switching")
 StoneIndustry.factory_tick(state,6,2,1)
 check(not site.batch.is_empty() and site.batch.recipe=="blocks","Manual choice starts the selected real batch")
 game.set_stone_auto(6,true)
 StoneIndustry.factory_tick(state,6,4,1)
 check(site.stock.stone==5 and site.batch.is_empty(),"Enabling automation completes the existing batch before changing recipe")
 var before=state.resources.duplicate(true)
 game.restore(JSON.parse_string(JSON.stringify(game.snapshot())))
 check(StoneIndustry.auto_recipe(game.state,6) and JSON.parse_string(JSON.stringify(game.state.resources))==JSON.parse_string(JSON.stringify(before)),"Automatic preference and inventories survive JSON save reload")
 var corrupted=game.snapshot();corrupted.buildings[6].auto_recipe="auto"
 check(not root.get_node("Store").valid_shape(corrupted),"Malformed automatic-recipe preferences do not pass durable save validation")
 game.state.jobs.append({"materials":{"gravel":100.0},"delivered":{},"paused":false})
 check(StoneIndustry.recipe_choice(game.state,6)=="gravel","An actual outstanding gravel bill selects gravel")
 game.state.jobs.back().paused=true
 game.state.resources.gravel=30
 game.state.resources.stone=0
 check(StoneIndustry.recipe_choice(game.state,6)=="blocks","Paused construction does not override a missing base supply")
 print("JOURNEY LOGISTICS: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
