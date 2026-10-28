extends SceneTree
func _initialize():call_deferred("run")
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false);game.simulation_only=true
 root.get_node("Music").shutdown();root.get_node("RuntimeStats").set_process(false)
 var player=load("res://Tests/Support/JourneyPlayer.gd").new(game)
 player.seed_value=int(OS.get_environment("TIMBER_JOURNEY_SEED")) if not OS.get_environment("TIMBER_JOURNEY_SEED").is_empty() else 41
 player.interval=maxi(5,int(OS.get_environment("TIMBER_JOURNEY_INTERVAL"))) if not OS.get_environment("TIMBER_JOURNEY_INTERVAL").is_empty() else 5
 game.restore(game.initial_state());game.rng.seed=player.seed_value;seed(player.seed_value)
 game.begin_tutorial()
 var started=Time.get_ticks_msec()
 var limit=int(OS.get_environment("TIMBER_JOURNEY_SECONDS")) if not OS.get_environment("TIMBER_JOURNEY_SECONDS").is_empty() else 64800
 for second in limit:
  if second%player.interval==0:player.turn()
  game.step(1)
  if second%60==0:player.observe()
  if second%1800==1799:player.sample()
  if second%500==0:await process_frame
  if Journey.current(game.state).is_empty() or not player.failures.is_empty():break
 var tutorial_ok=bool(game.state.onboarding.finished) and not bool(game.state.onboarding.active) and player.actions.any(func(a):return a.action=="tutorial_complete")
 var passed=Journey.current(game.state).is_empty() and Journey.townhall_level(game.state)==10 and player.failures.is_empty() and tutorial_ok
 # Compare the real background replay worker against live ticks from the same
 # earned mid-game checkpoint. No second offline payout is merged into play.
 var offline_ok=false
 if passed:
  var final=game.snapshot()
  var middle=player.saved_halls["6"]
  var replay=load("res://Managers/CompanyReplay.gd").new()
  if replay.start(game.get_script(),middle,1800)==OK:
   while not replay.finished():await process_frame
   var offline=replay.take()
   game.restore(middle);game.simulate(1800)
   offline.erase("last_seen")
   var online=game.state.duplicate(true);online.erase("last_seen")
   offline_ok=JSON.parse_string(JSON.stringify(online,"",true,true))==JSON.parse_string(JSON.stringify(offline,"",true,true))
  else:replay.cancel()
  if not offline_ok:player.failures.append("midgame background offline replay differs from live economy")
  game.restore(final)
 passed=passed and offline_ok
 player.sample()
 var report={"baseline":"73cd20bc9e490634fe7c75123bbd45bf44c72967","seed":player.seed_value,"action_interval":player.interval,"grants":false,"tutorial_completed":tutorial_ok,"simulated_seconds":game.state.elapsed,"host_ms":Time.get_ticks_msec()-started,"passed":passed,"offline_replay_equal":offline_ok,"invariant_samples":player.invariant_samples,"earned":game.state.earned,"spent":350.0+float(game.state.earned)-float(game.state.coins),"reload_checks":player.checks,"failures":player.failures,"chapters":player.chapters,"samples":player.samples,"actions":player.actions}
 report.candidate_version=ProjectSettings.get_setting("application/config/version")
 var path=OS.get_environment("TIMBER_JOURNEY_REPORT")
 if not path.is_empty():
  var f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(report," ",true,true));f.close()
 var snapshot=OS.get_environment("TIMBER_JOURNEY_SAVE")
 if not snapshot.is_empty():
  var f=FileAccess.open(snapshot,FileAccess.WRITE);f.store_string(JSON.stringify(game.snapshot()," ",true,true));f.close()
 print("JOURNEY PLAYTHROUGH: passed=",passed," hall=",Journey.townhall_level(game.state)," seconds=",game.state.elapsed," host_ms=",report.host_ms," reload_failures=",player.failures)
 quit(0 if passed else 1)
