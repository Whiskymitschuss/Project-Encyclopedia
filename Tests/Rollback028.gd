extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func trips(state: Dictionary) -> Array:
 return state.delivery.shipments+state.construction_shipments+state.stone.shipments+state.trade.shipments
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 var store=root.get_node("Store")
 game.set_process(false)
 var legacy=JSON.parse_string(FileAccess.get_file_as_string("res://Tests/Fixtures/rollback028-from029.json"))
 check(store.valid_shape(legacy),"The generated 0.29 city remains a valid 0.28 save")
 var maintenance=legacy.city_services.missions[0].duplicate(true)
 maintenance.kind="technician"
 maintenance.id=987654
 maintenance.erase("fire_id")
 legacy.city_services.missions.append(maintenance)
 check(store.save_game(legacy),"A generated 0.29 file can be written in the isolated profile")
 var original_hash=FileAccess.get_sha256(store.PATH)
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://recovery"))
 var interrupted=FileAccess.open(store.ROLLBACK_COPY+".tmp",FileAccess.WRITE)
 interrupted.store_string("interrupted archive from a terminated process")
 interrupted.close()
 game.restore(store.load_game())
 for key in ["coins","diamonds","tickets","resources","buildings","homes","jobs","construction_shipments","trucks","builders","delivery","stone","trade"]:
  check(game.state[key]==legacy[key],"Rollback preserves existing "+key)
 check(not game.state.has("traffic") and not game.state.has("foreman"),"No 0.29 traffic or foreman engine remains active")
 check(game.state.city_services.missions.size()==legacy.city_services.missions.size()-1,"Only the unsupported zero-cargo technician assignment is retired")
 check(game.save(true),"The restored company saves without uninstalling or resetting")
 check(FileAccess.get_sha256(store.ROLLBACK_COPY)==original_hash,"The first rollback save archives the exact original 0.29 bytes")
 game.state.coins+=1
 check(game.save(true) and FileAccess.get_sha256(store.ROLLBACK_COPY)==original_hash,"Later autosaves keep the original rollback copy untouched")
 var before_ids=[]
 for trip in trips(game.state): before_ids.append(int(trip.id))
 check(not before_ids.is_empty(),"The compatibility fixture contains actual formerly blocked cargo")
 game.state.city_services.enabled=false
 game.state.workers=0
 game.state.delivery.paused=false
 for job in game.state.jobs: job.paused=true
 for second in 300: game.step(1)
 for trip in trips(game.state): check(not int(trip.id) in before_ids,"Old queued cargo finishes under the restored 0.28 rules")
 var remaining_ids=[]
 for trip in trips(game.state): remaining_ids.append(int(trip.id))
 for id in before_ids: check(not id in remaining_ids,"Each old cargo assignment clears: "+str(id))
 check(store.valid_shape(game.snapshot()),"The continued city still produces a valid save")

 # Completed housing must not depend on unrelated freight elsewhere in town.
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.city_services.enabled=false
 game.state.homes=[{"kind":"house","level":3,"plot":0,"rent_bank":123,"position":[-40,116]}]
 game.state.construction_shipments=[{"origin":0}]
 var coins=game.state.coins
 check(game.move_building(0,Vector3(-40,0,148),90,true),"An unrelated construction delivery no longer prevents moving a home")
 check(game.home_position(0)==Vector3(-40,0,148) and game.state.homes[0].rotation==90,"House location and orientation really change")
 check(game.state.coins==coins and game.state.homes[0].level==3 and game.state.homes[0].rent_bank==123,"Moving keeps money, level and earned rent")
 check(not game.move_reason(0,false).is_empty(),"The actual shipping depot remains protected")
 game.state.jobs=[{"type":"home_upgrade","index":0}]
 check(not game.move_building(0,Vector3(-40,0,116),0,true),"A house's own active upgrade remains protected")
 game.state.jobs=[]
 game.state.construction_shipments=[]
 check(not game.move_building(0,Vector3(0,0,-80),0,true),"Moving onto a road remains invalid")
 game.restore(JSON.parse_string(JSON.stringify(game.snapshot())))
 check(game.home_position(0)==Vector3(-40,0,148) and game.state.homes[0].rent_bank==123,"Moved house and rent survive serialization")

 # Pausing the app must stop both presentation and live processing, then catch
 # up only the missing seconds once. No physical temperature is simulated.
 var elapsed=float(game.state.elapsed)
 game.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 check(paused and game.application_suspended,"Minimizing suspends the scene tree")
 game._process(5)
 check(game.state.elapsed==elapsed,"No foreground simulation spins while the app is suspended")
 game.paused_at=Time.get_unix_time_from_system()-120
 game.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 check(not paused and not game.application_suspended,"Returning restores presentation")
 check(absf(float(game.state.elapsed)-elapsed-120)<2,"Return calculates missing time once")
 var resumed=game.state.elapsed
 game.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
 check(game.state.elapsed==resumed,"Duplicate resume cannot pay the absence twice")
 check(ProjectSettings.get_setting("rendering/lights_and_shadows/directional_shadow/size.mobile")==1024,"Mobile shadow atlas has a fixed smaller budget")
 print("ROLLBACK 028: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
