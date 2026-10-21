extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 var state=game.state
 state.city_services.enabled=false
 state.homes=[{"kind":"house","level":1,"plot":0},{"kind":"house","level":1,"plot":1},{"kind":"house","level":1,"plot":2}]
 var target={"type":"home","index":0}
 check(not CityServices.ignite(state,{"type":"home","index":-1}),"Invalid target rejected")
 check(not CityServices.ignite(state,{"type":"building","index":0}),"Unsupported target rejected")
 check(CityServices.ignite(state,target),"Real home can catch fire")
 check(not CityServices.ignite(state,target),"No duplicate incident")
 check(CityServices.uses_building(state,0,true),"Burning building cannot be moved")
 check(CityServices.ignite(state,{"type":"home","index":1}),"Second incident supported")
 check(not CityServices.ignite(state,{"type":"home","index":2}),"Incident budget bounded")
 var cache={}
 CityServices.tick(state,1,cache)
 check(state.city_services.missions.size()==1,"Shared external fire engine dispatches automatically even with new events disabled")
 var mission=state.city_services.missions[0]
 check(mission.external and mission.has("fire_id"),"External help is attached to real incident")
 check(mission.target_ref==target,"Truck goes to the burning building")
 check(float(state.city_services.fires[0].progress)==0,"No extinguishing before arrival")
 check(int(state.city_services.fires_extinguished)==0,"No premature rescue credit")
 var restored=JSON.parse_string(JSON.stringify(state,"",false,true))
 for i in 300:
  CityServices.tick(state,1,cache)
  CityServices.tick(restored,1,{})
 check(state.city_services.fires.is_empty(),"Both incidents extinguished using limited fleet")
 check(restored.city_services.fires.is_empty(),"Saved ongoing incidents finish after restore")
 check(int(state.city_services.fires_extinguished)==2,"Exactly two completed rescues")
 check(int(restored.city_services.fires_extinguished)==2,"No lost or duplicate rescue after JSON restore")
 check(state.homes.size()==3 and int(state.homes[0].level)==1,"Fire does not delete or downgrade buildings")
 var treasury=float(state.city_services.treasury)
 CityServices.tick(state,300,{})
 check(float(state.city_services.treasury)==treasury,"Completed incidents cannot pay twice")
 check(state.city_services.fires.is_empty(),"Disabled events do not create new fires")
 state.city_services.enabled=true
 state.city_services.fire_clock=419.0
 CityServices.tick(state,1,{})
 check(state.city_services.fires.size()==1,"Automatic schedule creates actual incident")
 check(state.ux.events.size()>=3,"Incidents and rescue create persistent event notices")
 # An unreachable address remains an explicit incident without fabricated completion.
 state.city_services=CityServices.initial()
 state.city_services.enabled=false
 state.homes[0].position=[5000,5000]
 check(CityServices.ignite(state,target),"Unreachable home retains its alarm")
 CityServices.tick(state,1,{})
 check(state.city_services.missions.is_empty(),"No invented route to unreachable address")
 check(int(state.city_services.fires[0].mission_id)==-1,"Blocked dispatch is visible as waiting")
 print("FIRE SAFETY: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
