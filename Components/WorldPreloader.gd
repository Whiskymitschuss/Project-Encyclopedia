class_name WorldPreloader
extends RefCounted

# Godot's resource loader handles file/resource work off-thread. Scene instances,
# nodes, UI and GPU objects are attached only by the main thread afterward.
static func prepare(state: Dictionary,tree: SceneTree,art: Control) -> Array:
 var paths={}
 for city in [false,true]:
  for record in state.homes if city else state.buildings:
   var path=Models.blueprint_path(record.kind,int(record.level),city)
   if ResourceLoader.exists(path):paths[path]=true
 for profession in ["forester","industry","logistics","planter"]:
  for id in 10:
   var path="res://Assets/Baked/beaver-%s-%s-%s.scn" % [id,profession,int(profession=="logistics")]
   if ResourceLoader.exists(path):paths[path]=true
 for fleet in ["general","central","construction"]:
  for prefix in ["truck","dump"]:
   var path="res://Assets/Baked/%s-%s-%s.scn" % [prefix,maxi(2,int(state.vehicle)),fleet]
   if ResourceLoader.exists(path):paths[path]=true
 if ResourceLoader.exists("res://Assets/Baked/crew-van.scn"):paths["res://Assets/Baked/crew-van.scn"]=true
 if ResourceLoader.exists(ValleyLandscape.BLUEPRINT):paths[ValleyLandscape.BLUEPRINT]=true
 var queue=paths.keys();var pending=[];var retained=[];var done=0
 while not queue.is_empty() or not pending.is_empty():
  while pending.size()<4 and not queue.is_empty():
   var path=queue.pop_front()
   if ResourceLoader.load_threaded_request(path)==OK:pending.append(path)
   else:done+=1
  for path in pending.duplicate():
   var status=ResourceLoader.load_threaded_get_status(path)
   if status==ResourceLoader.THREAD_LOAD_LOADED:
    var resource=ResourceLoader.load_threaded_get(path)
    retained.append(resource)
    var filename=path.get_file()
    if filename.begins_with("truck-") or filename.begins_with("dump-") or filename=="crew-van.scn":VehicleBlueprints.scenes[path]=resource
    elif filename.begins_with("beaver-"):
     var pieces=filename.trim_suffix(".scn").split("-")
     BeaverModels.scenes["%s/%s/%s" % [int(pieces[1]),pieces[2],pieces[3]=="1"]]=resource
    pending.erase(path);done+=1
   elif status in [ResourceLoader.THREAD_LOAD_FAILED,ResourceLoader.THREAD_LOAD_INVALID_RESOURCE]:
    pending.erase(path);done+=1
  art.progress(5+float(done)*20/maxi(1,paths.size()),"DEINE FIRMA WIRD VORBEREITET","Gebäude und Biber werden geladen.")
  await tree.process_frame
 return retained
