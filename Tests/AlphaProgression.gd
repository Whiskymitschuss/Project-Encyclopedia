extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.begin_tutorial()
 for i in 5: game.chop()
 game.deposit()
 game.simulate(5) # Entrinden, Sägen und Hobeln vor dem ersten echten Verkauf.
 game.sell("boards",0.25)
 if not game.order_building("cabin",game.free_position(Catalog.industry_position(5))): printerr("FAILED: First alpha hut cannot be afforded"); quit(1); return
 game.simulate(40)
 game.end_tutorial(true)
 var hall_ordered=false
 for second in 1800:
  game.step(1)
  if second%5==0: game.chop(); game.deposit()
  for i in 3:
   var id=Journey.goal_id(0,i)
   if game.state.journey.reached.has(id) and not game.state.journey.claimed.has(id): game.claim_journey(id)
  if not hall_ordered and game.home_available("townhall") and game.state.coins>=200:
   hall_ordered=game.order_home("townhall",-1)
  for job in game.state.jobs:
   for key in ConstructionRules.HARDWARE:
    var missing=ceili(ConstructionRules.remaining(job,key)-float(game.state.resources[key]))
    if missing>0 and game.state.coins>=float(ConstructionRules.HARDWARE[key])*missing: game.buy_hardware(key,missing)
  if Journey.townhall_level(game.state)>0:
   var before=Journey.resume_capture(game.state)
   var saved=JSON.parse_string(JSON.stringify(game.snapshot()))
   var started=Time.get_ticks_msec()
   game.simulate(28800)
   var elapsed=Time.get_ticks_msec()-started
   var online=game.snapshot()
   game.restore(saved)
   for i in 28800: game.step(1)
   if not is_equal_approx(float(game.state.coins),float(online.coins)) or not is_equal_approx(float(game.state.resources.boards),float(online.resources.boards)):
    printerr("FAILED: Eight-hour alpha offline progress diverges after reload"); quit(1); return
   print("ALPHA PROGRESSION: first hut and town hall in ",second+42," simulated seconds, no grants; eight offline hours replay correctly; host simulation ",elapsed," ms")
   quit()
   return
 printerr("FAILED: Guided alpha start cannot reach its first town hall within 30 simulated minutes")
 quit(1)
