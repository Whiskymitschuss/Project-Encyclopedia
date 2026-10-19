extends SceneTree

var checks=0
var failures=[]
func check(ok: bool, detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func _initialize() -> void: call_deferred("run")
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 var original=game.state.duplicate(true)
 game.state=game.initial_state()
 game.flow.clear()
 var legacy=game.snapshot()
 legacy.erase("ambient_enabled")
 game.restore(legacy)
 check(game.state.ambient_enabled and game.state.coins==350,"Legacy saves enable everyday scenes without changing the wallet")
 game.state.tutorial=5
 game.state.workers=6
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene.sync_actors()
 var life=scene.life
 life.set_process(false)
 check(life.effects.size()==2 and life.celebrations==0,"Loaded buildings do not trigger opening celebrations")
 var neighbor=null
 var eligible=[]
 for worker in life.people():
  worker.set_process(false)
  worker.social_cooldown=100
  if worker.role=="neighbor": neighbor=worker
  if worker.role=="forester": eligible.append(worker)
 check(life.people().size()==6,"Resting representative belongs to the hired team, no free extra worker")
 check(neighbor!=null,"A sufficiently staffed cabin has a visible visitor")
 var economy=game.state.duplicate(true)
 if neighbor!=null:
  neighbor.phase=12
  neighbor._process(0)
  check(neighbor.resting and neighbor.mug.visible,"Rest cycle sits at the bench and holds a cup")
  var rectangle=Placement.bounds(game.building_position(3),0)
  var inside=true
  for i in 21:
   var point=neighbor.rest_route(i/20.0)
   inside=inside and rectangle.has_point(Vector2(point.x,point.z))
  check(inside,"Entire rest walk stays within the cabin parcel")
  neighbor.phase=26
  neighbor._process(0)
  check(not neighbor.resting and not neighbor.mug.visible,"Visitor leaves the bench after the break")
 check(game.state==economy,"Rest choreography never consumes or creates resources")
 check(eligible.size()>=2,"Two ordinary workers can meet")
 if eligible.size()>=2:
  var a=eligible[0]
  var b=eligible[1]
  a.position=Vector3(20,0,-80)
  b.position=Vector3(24,0,-80)
  a.social_cooldown=0
  b.social_cooldown=0
  life.greet_neighbors()
  check(a.social_kind=="wave" and b.social_kind=="wave" and a.social_left>0 and b.social_left>0,"Nearby workers greet one another")
  var count=life.greetings
  life.greet_neighbors()
  check(life.greetings==count,"Encounter cooldown prevents continuous waving")
  var phase=a.phase
  a._process(0.2)
  check(a.phase==phase and a.limbs[3].rotation.x< -2,"Greeting stops walking and visibly raises a hand")
  game.state.ambient_enabled=false
  a._process(0.2)
  life._process(3)
  check(a.social_left==0 and life.greetings==count,"Disabling everyday scenes stops greetings")
  game.state.ambient_enabled=true
 var rotated_point=game.free_position(Vector3(44,0,-44),90,3)
 check(game.move_building(3,rotated_point,90),"Cabin can move and rotate with its cozy props")
 scene.sync_actors()
 var rotation_ok=false
 var route_inside=true
 for worker in life.people():
  if worker.role!="neighbor": continue
  var expected=rotated_point+Basis.from_euler(Vector3(0,PI/2,0))*Vector3(4.2,0,9.7)
  rotation_ok=worker.destination.is_equal_approx(expected)
  var rectangle=Placement.bounds(rotated_point,90)
  for i in 21:
   var point_on_route=worker.rest_route(i/20.0)
   route_inside=route_inside and rectangle.has_point(Vector2(point_on_route.x,point_on_route.z))
 check(rotation_ok,"Resting visitor follows the cabin's saved rotation and location")
 check(route_inside,"Rotated rest route stays on its own parcel")
 game.state.coins=10000
 var point=game.free_position(Vector3(20,0,-80))
 check(point!=null and game.order_building("kiln",point),"Construction starts through the real paid build system")
 check(life.celebrations==0,"A paid construction site does not pretend to be open")
 game.simulate(100)
 check(life.celebrations==1,"Exactly one real completion triggers a celebration")
 check(life.effects[0].root.position==point and life.effects[0].label.text=="ERÖFFNET!","Celebration appears at the chosen building location")
 var crowd=0
 for worker in life.people():
  if worker.social_kind=="cheer" and worker.social_left>0: crowd+=1
 check(crowd>0 and crowd<=5,"A bounded nearby crowd celebrates the new factory")
 game.state.homes.append({"kind":"house","level":1,"plot":0,"position":[-40,84],"rotation":90})
 game.rebuild_world.emit()
 scene.sync_actors()
 var garden_ok=true
 var residents=0
 var garden=Placement.bounds(game.home_position(0),90)
 for worker in life.people():
  if worker.role!="resident": continue
  residents+=1
  for i in 11:
   var garden_point=worker.origin_point.lerp(worker.destination,i/10.0)
   garden_ok=garden_ok and garden.has_point(Vector2(garden_point.x,garden_point.z))
 check(residents>0 and garden_ok,"Residents stroll in their actual rotated home's garden, outside industrial traffic")
 life._process(5)
 check(not life.effects[0].label.visible,"Opening caption expires without a popup dismissal")
 economy=game.state.duplicate(true)
 for i in 5: life.on_completed(point,"upgrade")
 check(life.effects.size()==2,"Repeated completions reuse a fixed effect pool")
 check(game.state==economy,"Celebration rendering never grants rewards or alters production")
 game.state.quality=0
 life.on_completed(point,"upgrade")
 check(life.effects[(life.next_effect+1)%2].particles.amount==12,"Battery mode reduces confetti")
 crowd=0
 for worker in life.people():
  if worker.social_kind=="cheer" and worker.social_left>0: crowd+=1
 check(crowd<=2,"Battery mode limits the celebrating crowd")
 game.state.ambient_enabled=false
 var count=life.celebrations
 life.on_completed(point,"building")
 life._process(0)
 check(life.celebrations==count and not life.effects[0].label.visible and not life.effects[0].particles.visible,"Disabled scenes immediately suppress opening captions and particles")
 var saved=game.snapshot()
 game.restore(saved)
 check(not game.state.ambient_enabled,"Everyday scene preference survives restore")
 game.state.earned=game.prestige_requirement()
 game.state.unlocked=3
 check(game.prestige() and not game.state.ambient_enabled,"Prestige preserves the everyday scene preference")
 scene.queue_free()
 game.state=original
 await process_frame
 print("WORLD LIFE: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
