extends SceneTree
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func mesh_checks(mesh: ArrayMesh,size: Vector3) -> void:
 var arrays=mesh.surface_get_arrays(0)
 var vertices=arrays[Mesh.ARRAY_VERTEX]
 var normals=arrays[Mesh.ARRAY_NORMAL]
 var indices=arrays[Mesh.ARRAY_INDEX]
 var valid=true
 var front=true
 for i in vertices.size():
  valid=valid and vertices[i].is_finite() and normals[i].is_normalized()
  valid=valid and absf(vertices[i].x)<=size.x/2+0.001 and absf(vertices[i].y)<=size.y/2+0.001 and absf(vertices[i].z)<=size.z/2+0.001
 for i in range(0,indices.size(),3):
  var a=indices[i]; var b=indices[i+1]; var c=indices[i+2]
  var cross_value=(vertices[b]-vertices[a]).cross(vertices[c]-vertices[a])
  front=front and cross_value.dot(normals[a]+normals[b]+normals[c])<=0.0001
 check(valid,"Rounded geometry has finite normals and stays inside the original dimensions")
 check(front,"Rounded geometry uses Godot's outward clockwise faces")
func run() -> void:
 await process_frame
 var game=root.get_node("Game")
 game.set_process(false)
 game.state=game.initial_state()
 for size in [Vector3(10,6,8),Vector3(7,0.1,7),Vector3(0.2,4,0.2)]:
  var mesh=CraftedGeometry.rounded_box(size)
  mesh_checks(mesh,size)
  check(mesh==CraftedGeometry.rounded_box(size),"Repeated architecture reuses the same rounded mesh")
  mesh_checks(CraftedGeometry.rounded_slab(size),size)
 var crown=CraftedGeometry.pine_crown(2.5,4.5)
 var arrays=crown.surface_get_arrays(0)
 var outward=true
 for i in arrays[Mesh.ARRAY_VERTEX].size():
  var p: Vector3=arrays[Mesh.ARRAY_VERTEX][i]
  var n: Vector3=arrays[Mesh.ARRAY_NORMAL][i]
  outward=outward and Vector3(p.x,0,p.z).dot(n)>0
 check(outward,"Curved tree crowns have outward lighting normals")
 check(crown==CraftedGeometry.pine_crown(2.5,4.5),"Forests share a fixed crown mesh")
 var original=[[0,0.95,0],[0,0.95,4],[0,0.95,8],[4,0.95,8],[8,0.95,8]]
 var before=original.duplicate(true)
 var curve=LogisticsRoutes.driving_path(original)
 check(original==before,"Curves do not rewrite saved road checkpoints or reservations")
 check(curve[0]==original[0] and curve[-1]==original[-1],"Driving curves keep the real pickup and destination")
 check(LogisticsRoutes.length(curve)<LogisticsRoutes.length(original),"A real rounded corner replaces the sharp right angle")
 var restored=LogisticsRoutes.driving_path(JSON.parse_string(JSON.stringify(original)))
 var same=curve.size()==restored.size()
 for i in mini(curve.size(),restored.size()): same=same and LogisticsRoutes.vector(curve[i]).is_equal_approx(LogisticsRoutes.vector(restored[i]))
 check(same,"JSON-restored routes derive identical curves")
 for i in 101:
  var sampled=LogisticsRoutes.sample(original,i/100.0)
  var p: Vector3=sampled.position
  var near=INF
  for j in range(1,original.size()): near=minf(near,p.distance_to(Geometry3D.get_closest_point_to_segment(p,LogisticsRoutes.vector(original[j-1]),LogisticsRoutes.vector(original[j]))))
  check(near<0.5 and sampled.direction.is_normalized(),"Rounded driving stays within its road corridor")
 SurfaceLibrary.daylight(0)
 var glass=SurfaceLibrary.material(Color("62b9c8"),"glass")
 check(glass.emission_energy_multiplier>0.5,"Windows built at night immediately use night lighting")
 SurfaceLibrary.daylight(1)
 check(glass.emission_energy_multiplier<0.1,"Shared windows return to daylight without rebuilding houses")
 var snapshot=game.state.duplicate(true)
 var context=load("res://Components/StreetScape.gd").context(game.state)
 check(game.state==snapshot and not context.junctions.is_empty(),"Street detailing reads real roads without changing progress")
 var model=load("res://Buildings/Models.gd").building("sawmill",1)
 check(model.has_node("Processing/Feed") and model.has_node("Processing/Product") and model.has_node("SawdustFill"),"Detailed sawmill retains its actual machine, products and sawdust")
 check(model.has_node("WoodYard"),"The reworked sawmill retains its actual marked input/output yard")
 var details=model.get_node("WoodYard")
 var limited=true
 for mesh in details.find_children("*","MeshInstance3D",true,false): limited=limited and mesh.visibility_range_end==360
 check(limited,"Small frontage geometry is culled beyond its bounded view distance")
 model.free()
 print("CRAFTED WORLD: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
