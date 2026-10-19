extends SceneTree

func _initialize() -> void:
 call_deferred("run")

func run() -> void:
 await process_frame
 var game = root.get_node("Game")
 game.set_process(false)
 game.state = game.initial_state()
 # Exercise an ordinary fresh save without money or material grants.
 for i in 25:
  game.chop()
  game.deposit()
 game.claim_mission("trees")
 var ordered = {}
 var house_started = false
 for second in 7200:
  game.step(1)
  for kind in ["kiln","furniture","prefab"]:
   if game.available(kind) and not ordered.has(kind) and game.state.coins>=game.cost_for(kind):
    if game.order_building(kind): ordered[kind]=true
  if game.level("furniture")==0 and int(game.state.elapsed)%20==0:
   game.fulfill_contract()
   if game.state.coins<900: game.sell("boards",0.5)
  if game.level("prefab")>0 and game.state.plan.is_empty() and not house_started:
   game.set_plan("house",0)
   game.state.plan.auto = true
  if not game.state.jobs.is_empty():
   for job in game.state.jobs:
    if job.type=="home": house_started = true
  if not game.state.homes.is_empty():
   var before = game.state.coins
   game.simulate(10)
   game.collect_rent()
   if game.state.coins<=before:
    printerr("FAILED: First home has no income")
    quit(1)
    return
   print("PROGRESSION: first home completed in ",second," simulated seconds, no granted resources")
   quit()
   return
 printerr("FAILED: Fresh save cannot reach first home within two simulated hours")
 printerr(game.state)
 quit(1)
