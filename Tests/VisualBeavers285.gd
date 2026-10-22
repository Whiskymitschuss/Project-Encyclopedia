extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func descendants(node: Node) -> Array:
 var result=[node]
 for child in node.get_children(): result.append_array(descendants(child))
 return result
func settle() -> void:
 for i in 5: await process_frame
 await RenderingServer.frame_post_draw
func run() -> void:
 await process_frame
 var beavers=load("res://characters/beavers/BeaverModels.gd")
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.workers=16
 game.state.ux.motion=true
 game.state.time=10
 for kind in ["kiln","furniture","joinery","prefab"]:
  var at=game.free_position(Catalog.industry_position(game.state.buildings.size()))
  game.state.buildings.append({"kind":kind,"level":4,"paused":false,"position":[at.x,at.z]})
 for i in 2:
  var at=game.free_position(Vector3(-40+i*32,0,85))
  game.state.homes.append({"kind":"house","level":2,"plot":i,"position":[at.x,at.z]})
 var before=game.state.duplicate(true)
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.size=Vector2i(1100,1000)
 root.content_scale_size=root.size
 root.add_child(scene)
 scene.sync_actors()
 scene.set_process(false)
 scene.hud.ux.set_process(false)
 await settle()
 var variants={}
 var roles={}
 for node in descendants(scene):
  if node.get_meta("species","")=="beaver":
   variants[node.get_meta("variant_id")]=true
   roles[node.get_meta("profession")]=true
   check(node.has_node("Tail") and node.has_node("Head/EyeLeft") and node.has_node("RightArm"),"Integrated NPC has the common animated beaver anatomy")
 check(variants.size()==10,"All ten beaver shapes occur in the populated main world")
 check(roles.has("forester") and roles.has("industry") and roles.has("logistics"),"All three worker professions are integrated into the main world")
 check(game.state==before,"Replacing every visual character leaves the authoritative company unchanged")
 var worker=scene.actors.get_child(0)
 var arm=worker.limbs[3]
 worker.working=true
 game.flow["building:%s" % worker.production_index]=1
 worker._process(0.3)
 check(absf(arm.rotation.x)>0.1,"Existing production controller animates the beaver work arms")
 var samples=Node3D.new()
 scene.add_child(samples)
 var shapes={}
 for i in 10:
  shapes[str(beavers.VARIANTS[i].head)+str(beavers.VARIANTS[i].body)+str(beavers.VARIANTS[i].tail)]=true
  for job in ["forester","industry","logistics"]:
   var rig=beavers.create(i,job)
   check(rig.get_meta("profession")==job and rig.get_meta("variant_id")==i,"Variant and interchangeable occupation remain independent")
   rig.free()
  var rig=beavers.create(i,"forester" if i%3==0 else "industry" if i%3==1 else "logistics")
  rig.position=Vector3((i%5-2)*4.0,0,floori(i/5.0)*6.0)
  samples.add_child(rig)
  check(rig.find_children("*","MeshInstance3D",true,false).size()<=12,"Multi-colour beaver parts have a bounded mobile draw budget")
 check(shapes.size()==10,"Ten variants have distinct body, head and tail proportions beyond recolouring")
 check(samples.get_child(6).scale.y<samples.get_child(0).scale.y and samples.get_child(1).scale.y>samples.get_child(0).scale.y,"Young and large beavers also differ in overall stature")
 var seat=beavers.create(5,"logistics",true)
 samples.add_child(seat)
 seat.position=Vector3(11,0,0)
 check(seat.seated and seat.get_node("LeftLeg").rotation.x< -1,"Cached seated rig keeps its sitting pose and driver animation")
 var first=beavers.create(1,"industry")
 var second=beavers.create(1,"industry")
 samples.add_child(first); samples.add_child(second)
 first.hide(); second.hide()
 var a=first.get_node("Head/EyeLeft").get_child(0)
 var b=second.get_node("Head/EyeLeft").get_child(0)
 check(a.mesh==b.mesh,"Repeated characters share baked meshes instead of rebuilding geometry")
 var tail=seat.get_node("Tail")
 seat._process(0.5)
 check(absf(tail.rotation.y)>0,"Close beaver drivers animate their tail and steering")
 game.state.ux.motion=false
 var angle=tail.rotation.y
 seat._process(0.5)
 check(tail.rotation.y==angle,"Reduced motion stops the additional beaver animations")
 game.state.ux.motion=true
 for node in [scene.world_buildings,scene.actors,scene.base_streets]:
  if node!=null: node.hide()
 scene.hud.hide()
 samples.position=Vector3(0,20,0)
 scene.camera.position=Vector3(14,34,27)
 scene.camera.look_at(Vector3(1,21.5,3))
 scene.camera.size=27
 scene.camera.far=1800
 scene.camera.near=0.1
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber285-beavers.png")
 # Every operated vehicle family uses the rig, including older cart tiers.
 for path in ["Truck","DumpTruck","ServiceVehicle","Bus","ForestryMachine","QuarryExcavator"]:
  var vehicle=load("res://Vehicles/%s.gd" % path).new()
  if path in ["Truck","DumpTruck"]: vehicle.road_freight=true
  samples.add_child(vehicle)
  var drivers=[]
  for node in descendants(vehicle):
   if node.name=="Driver" and node.get_meta("species","")=="beaver": drivers.append(node)
  check(not drivers.is_empty(),"%s has a visible beaver driver" % path)
  vehicle.free()
 for i in [0,1,2,3,6]:
  var truck=load("res://Vehicles/Truck.gd").new()
  truck.tier=i
  samples.add_child(truck)
  var found=false
  for node in descendants(truck):
   if node.get_meta("species","")=="beaver": found=true
  check(found,"Legacy transport tier %s also has a beaver operator" % i)
  truck.free()
 samples.hide()
 var vehicles=Node3D.new()
 scene.add_child(vehicles)
 vehicles.position=Vector3(0,20,0)
 var names=["Truck","DumpTruck","ServiceVehicle","Bus","ForestryMachine","QuarryExcavator"]
 for i in names.size():
  var vehicle=load("res://Vehicles/%s.gd" % names[i]).new()
  if names[i] in ["Truck","DumpTruck"]: vehicle.road_freight=true; vehicle.fleet="central"
  vehicles.add_child(vehicle)
  vehicle.position=Vector3((i%3-1)*9,0,floori(i/3.0)*12)
  vehicle.set_process(false)
 scene.camera.position=Vector3(22,40,38)
 scene.camera.look_at(Vector3(0,22,6))
 scene.camera.size=38
 await settle()
 root.get_texture().get_image().save_png("/workspace/timber285-drivers.png")
 print("BEAVER WORLD: %s checks, %s failures" % [checks,failures.size()])
 scene.free()
 quit(0 if failures.is_empty() else 1)
