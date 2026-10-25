extends SceneTree
# Offline content build: never run scene-tree APIs on a worker thread.
# Exact source geometry, no player profile, no economy/transport mutation.
func _initialize():call_deferred("run")
func run():
 await process_frame
 root.get_node("Game").set_process(false)
 var directory="res://Assets/Baked"
 DirAccess.make_dir_recursive_absolute(directory)
 # This folder contains reproducible generated resources, never authored art.
 for file in DirAccess.get_files_at(directory):
  if file.begins_with("building-") and file.ends_with(".scn"):DirAccess.remove_absolute(directory+"/"+file)
 var valley=load("res://Components/ValleyLandscape.gd")
 valley.use_baked=false
 var landscape=valley.new()
 var data=SceneryBlueprint.new()
 data.terrain=landscape.build_terrain()
 landscape.generate_decor()
 data.decor=landscape.records
 var error=ResourceSaver.save(data,directory+"/valley.res",ResourceSaver.FLAG_COMPRESS)
 if error!=OK:quit(1);return
 landscape.free()
 var lod=load("res://scripts/MeshLodBake.gd").new()
 var beavers=load("res://characters/beavers/BeaverModels.gd")
 beavers.use_baked=false
 for profession in beavers.CLOTHES:
  for seated in [false,true]:
   for variant in 10:
    var rig=beavers.build(variant,profession,seated)
    lod.apply(rig)
    beavers.own(rig,rig)
    var scene=PackedScene.new()
    if scene.pack(rig)!=OK:quit(1);return
    var path=directory+"/beaver-%s-%s-%s.scn" % [variant,profession,int(seated)]
    error=ResourceSaver.save(scene,path,ResourceSaver.FLAG_COMPRESS)
    rig.free()
    if error!=OK:quit(1);return
 beavers.use_baked=true
 beavers.scenes.clear()
 var emitted={}
 var game=root.get_node("Game")
 var models=load("res://Buildings/Models.gd")
 models.use_baked=false
 for skin in ["Rustikal","Modern"]:
  game.state.skin=skin
  for city in [false,true]:
   var definitions=Catalog.HOMES if city else Catalog.BUILDINGS
   for kind in definitions:
    for level in range(1,11):
     var path=models.blueprint_path(kind,level,city)
     if emitted.has(path):continue
     emitted[path]=true
     var model=models.build_building(kind,level,city)
     StaticPaintBatch.reduce(model)
     lod.apply(model)
     # Flatten inherited character instances before packing a containing model.
     # Keeping both an inherited SceneState and owned overrides can orphan parts
     # when the packed parent is freed (especially auto-named mesh children).
     var flattened=model.duplicate(Node.DUPLICATE_SIGNALS|Node.DUPLICATE_GROUPS|Node.DUPLICATE_SCRIPTS)
     model.free()
     model=flattened
     clear_scene_paths(model)
     beavers.own(model,model)
     var scene=PackedScene.new()
     if scene.pack(model)!=OK:quit(1);return
     error=ResourceSaver.save(scene,path,ResourceSaver.FLAG_COMPRESS)
     model.free()
     if error!=OK:quit(1);return
 var truck_script=load("res://Vehicles/Truck.gd")
 var dump_script=load("res://Vehicles/DumpTruck.gd")
 for tier in range(2,10):
  for fleet in ["general","central","construction"]:
   for dump in [false,true]:
    var truck=dump_script.new() if dump else truck_script.new()
    truck.tier=tier;truck.fleet=fleet;truck.road_freight=true
    root.add_child(truck)
    var cargos={"wood":truck.cargo}
    if not dump:
     for key in ["boards","stone","crates","furniture"]:
      truck.cargo_boards=key=="boards";truck.cargo_stone=key=="stone";truck.cargo_boxes=key=="crates";truck.cargo_furniture=key=="furniture"
      cargos[key]=truck.build_freight_cargo(truck.trailer if truck.trailer!=null else truck)
      cargos[key].hide()
    truck.cargo_boards=false;truck.cargo_stone=false;truck.cargo_boxes=false;truck.cargo_furniture=false
    truck.remember_prepared(cargos)
    if dump:truck.prepared_nodes.bed=truck.get_path_to(truck.bed)
    save_vehicle(truck,directory+"/%s-%s-%s.scn" % ["dump" if dump else "truck",tier,fleet],lod,beavers)
 var van=load("res://Vehicles/CrewVan.gd").new()
 root.add_child(van);van.remember_prepared()
 save_vehicle(van,directory+"/crew-van.scn",lod,beavers)
 print("GENERATED LOD SURFACES: ",lod.lod_surfaces)
 print("BAKED RUNTIME: exact terrain, 2500 scenic records and 120 shared beaver rigs and all existing building levels/skins")
 quit()

func clear_scene_paths(node: Node) -> void:
 node.scene_file_path=""
 for child in node.get_children():clear_scene_paths(child)

func save_vehicle(vehicle: Node3D,path: String,lod: RefCounted,beavers: Script) -> void:
 StaticPaintBatch.reduce(vehicle)
 lod.apply(vehicle)
 var flat=vehicle.duplicate(Node.DUPLICATE_SIGNALS|Node.DUPLICATE_GROUPS|Node.DUPLICATE_SCRIPTS)
 vehicle.free();clear_scene_paths(flat);beavers.own(flat,flat)
 var scene=PackedScene.new()
 if scene.pack(flat)!=OK:quit(1);return
 if ResourceSaver.save(scene,path,ResourceSaver.FLAG_COMPRESS)!=OK:quit(1);return
 flat.free()
