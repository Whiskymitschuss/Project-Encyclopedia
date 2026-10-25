extends SceneTree
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 game.restore(game.initial_state())
 var saved=game.state.duplicate(true);saved.coins=7123;saved.resources.wood=321;saved.elapsed=721
 game.restore(saved);var daytime=game.state.duplicate(true)
 var legacy=daytime.duplicate(true);legacy.time=23;legacy.weather=2
 game.restore(legacy)
 check(game.state==daytime,"Migrating an old rainy night changes only the requested time/weather fields")
 check(legacy.time==23 and legacy.weather==2,"Migration never edits the input save dictionary")
 var s=game.state;s.workers=0;s.city_services.enabled=false
 for b in s.buildings:b.paused=true
 var elapsed=float(s.elapsed)
 var stable=true
 for i in 1500:
  game.step(1)
  if s.time!=12 or s.weather!=0:stable=false
 check(stable and s.elapsed==elapsed+1500,"More than a complete former day/weather cycle advances simulation while staying at noon and clear")
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);current_scene=scene;scene.set_process(false)
 var light=[scene.sun.rotation,scene.sun.light_color,scene.sun.light_energy,scene.environment_resource.ambient_light_energy,scene.environment_resource.background_color]
 check(scene.weather==null and scene.wet_weather==null,"The real main world allocates no rain emitter or wet-weather controller")
 check(not ResourceLoader.exists("res://Components/WetWeather.gd"),"Retired puddle/weather script is removed")
 var unchanged=s.duplicate(true)
 s.time=23;s.weather=3
 var legacy_state=s.duplicate(true)
 for delta in [0.0,0.5,180.0,600.0]:scene._process(delta)
 check([scene.sun.rotation,scene.sun.light_color,scene.sun.light_energy,scene.environment_resource.ambient_light_energy,scene.environment_resource.background_color]==light,"Legacy night/fog values cannot change the actual light or background")
 check(not scene.environment_resource.fog_enabled and scene.environment_resource.fog_density==0,"Fog stays completely disabled")
 check(Atmosphere.wind(s)==Vector3.ZERO and scene.wind_clock==0,"No weather wind or wind clock runs")
 SurfaceLibrary.weather(1);SurfaceLibrary.daylight(0)
 check(SurfaceLibrary.wetness==0 and SurfaceLibrary.last_night==0,"Legacy requests cannot activate wet materials or night windows")
 check(s==legacy_state,"Rendering does not edit inventories or progress while ignoring old weather fields")
 scene.queue_free();await process_frame
 print("DAYLIGHT 2824: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
