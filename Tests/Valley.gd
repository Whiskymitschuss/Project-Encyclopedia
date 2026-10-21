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
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.town.districts=2
 var before=game.state.duplicate(true)
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene.set_process(false)
 var valley=scene.landscape
 check(valley!=null and valley.has_node("ValleyTerrain") and valley.has_node("RiverAndSea"),"The world renders real terrain and water")
 check(game.state==before,"Natural scenery never changes money, resources, workers or saved progress")
 for x in [-300,-280,-248,-216,-60,-20,20,60,216,248,280,300]:
  for z in [-172,-144,-112,-80,-44,-12,20,52,84,116,148,176]:
   check(is_equal_approx(valley.height_at(Vector2(x,z)),0.38),"Existing and expanded construction land remains flat")
 check(valley.height_at(Vector2(-220,-225))>1,"Northern background has actual hills")
 check(valley.height_at(Vector2(-92,valley.river_z(-92)))<valley.water.position.y,"The river occupies a cut in terrain, outside the building area")
 check(valley.height_at(Vector2(235,239))<valley.water.position.y,"The lake is actual water below its banks")
 for p in [Vector2(-98,-115),Vector2(98,-115),Vector2(-140,8),Vector2(140,88)]:
  var a=valley.ground_color(p-Vector2(0.5,0))
  var b=valley.ground_color(p+Vector2(0.5,0))
  check(Vector3(a.r-b.r,a.g-b.g,a.b-b.b).length()<0.08,"Former biome rectangles have continuous colour transitions")
 check(valley.records.size()>=1500 and valley.records.size()<=2500,"The valley adds bounded dense vegetation")
 check(valley.batches.size()==6,"Vegetation uses six shared instanced meshes")
 var target=null
 for kind in valley.batches:
  var batch=valley.batches[kind]
  check(batch.mesh.instance_count==batch.entries.size(),"Decorative instances match their fixed pool: "+kind)
  if kind not in ["bush","flowers"]: continue
  for entry in batch.entries:
   if not entry.blocked and game.placement_reason(Vector3(entry.point.x,0,entry.point.y)).is_empty(): target=entry; break
  if target!=null: break
 check(target!=null,"Free construction ground can contain meadow vegetation")
 if target!=null:
  var money=game.state.coins
  check(game.move_building(1,Vector3(target.point.x,0,target.point.y)),"A saved production building can move into the meadow")
  var rectangle=Placement.bounds(game.building_position(1),0)
  var hidden=true
  for kind in valley.batches:
   var batch=valley.batches[kind]
   for i in batch.entries.size():
    if rectangle.has_point(batch.entries[i].point): hidden=hidden and bool(batch.entries[i].blocked)
  check(hidden,"Plant instances disappear from the actual moved building's footprint")
  check(game.state.coins==money,"Automatic clearing does not charge or reward the player")
 game.state.coins=10000
 var locations=[]
 for i in game.state.buildings.size(): locations.append(game.building_position(i))
 game.state.unlocked=2
 check(game.build_road("asphalt",TownRules.path(Vector2i(-80,-128),Vector2i(-120,-128))),"Player roads still construct in the natural landscape")
 var road_clear=true
 for kind in ["pine","leaf"]:
  var batch=valley.batches[kind]
  for i in batch.entries.size():
   var p=batch.entries[i].point
   if p.x>=-122 and p.x<=-78 and absf(p.y+128)<7.5:
    road_clear=road_clear and bool(batch.entries[i].blocked)
 check(road_clear,"New roads clear decorative tree crowns from their driving lanes")
 var positions_unchanged=true
 for i in locations.size(): positions_unchanged=positions_unchanged and locations[i]==game.building_position(i)
 check(positions_unchanged,"New landscaping preserves every saved building location")
 var count=valley.records.size()
 game.state.quality=0
 valley._process(0)
 for kind in valley.batches:
  var batch=valley.batches[kind]
  check(batch.mesh.visible_instance_count<=ceili(batch.entries.size()*0.45),"Battery mode reduces decorative vegetation: "+kind)
 game.state.quality=1
 valley._process(0)
 check(valley.records.size()==count,"Quality changes reuse the same vegetation pool")
 var tree_count=0
 for group in scene.trees: tree_count+=group.size()
 check(tree_count==1000,"Cosmetic trees do not replace or inflate the harvestable resource pool")
 scene.camera_action("world")
 check(scene.zoom>=300 and scene.zoom<500,"Overview stays close enough to see settlement life")
 game.state.time=19
 game.state.weather=3
 scene._process(0)
 check(scene.environment_resource.fog_density<=0.00025 and scene.environment_resource.ambient_light_energy>=0.32,"Fog and dusk keep the settlement readable")
 for size in [Vector2i(540,960),Vector2i(540,1170)]:
  root.size=size
  await process_frame
  scene.zoom=650
  scene.set_camera()
  var lower=Vector2(scene.get_viewport().get_visible_rect().size.x*0.5,scene.get_viewport().get_visible_rect().size.y-190)
  check(Plane(Vector3.UP,0).intersects_ray(scene.camera.project_ray_origin(lower),scene.camera.project_ray_normal(lower))!=null,"Wide camera keeps foreground land in front of the lens: %s" % size)
 scene.queue_free()
 await process_frame
 print("VALLEY: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
