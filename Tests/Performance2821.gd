extends SceneTree
var checks=0
var failures=[]
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:failures.append(message);printerr("FAILED: ",message)
func mesh_count(node: Node) -> int:return node.find_children("*","MeshInstance3D",true,false).size()
func geometry(node: Node3D) -> Array:
 var result=[]
 for child in node.find_children("*","MeshInstance3D",true,false):
  for surface in child.mesh.get_surface_count():
   var material=child.material_override if child.material_override!=null else child.mesh.surface_get_material(surface)
   var a=child.mesh.surface_get_arrays(surface)
   var vertices=a[Mesh.ARRAY_VERTEX];var colors=a[Mesh.ARRAY_COLOR];var indices=a[Mesh.ARRAY_INDEX]
   var order=indices if indices!=null and not indices.is_empty() else range(vertices.size())
   var transform=node.global_transform.affine_inverse()*child.global_transform
   for index in order:
    var point=transform*vertices[index]
    var color=colors[index] if material.vertex_color_use_as_albedo else material.albedo_color
    result.append("%.3f/%.3f/%.3f/%s" % [point.x,point.y,point.z,color.to_html()])
 result.sort()
 return result
func run():
 await process_frame
 var game=root.get_node("Game");game.set_process(false)
 var models=load("res://Buildings/Models.gd");var optimizer=load("res://Components/StaticPaintBatch.gd")
 game.state=game.initial_state();var saved=game.state.duplicate(true)
 var fixture=Node3D.new();root.add_child(fixture)
 for i in 6:models.box(fixture,Vector3(1+i*0.1,2,1),Vector3(i*2,0,0),Color.from_hsv(i/6.0,0.65,0.8))
 models.bake(fixture)
 var material=models.material(Color.from_hsv(0,0.65,0.8));var tint=material.albedo_color
 var original=geometry(fixture);var count=mesh_count(fixture)
 optimizer.reduce(fixture)
 check(count==6 and mesh_count(fixture)==1,"Six compatible static paint draws become one mesh")
 check(geometry(fixture)==original,"Actual painted triangle vertices retain all positions and RGB colors")
 check(material.albedo_color==tint and not material.vertex_color_use_as_albedo,"Shared source material is never recolored or changed")
 optimizer.reduce(fixture)
 check(mesh_count(fixture)==1 and geometry(fixture)==original,"Repeated optimization is idempotent and never duplicates geometry")
 fixture.free()
 fixture=Node3D.new();root.add_child(fixture)
 var moving=Node3D.new();moving.name="MovingArm";fixture.add_child(moving)
 for color in [Color.RED,Color.BLUE]:models.box(moving,Vector3.ONE,Vector3.ZERO,color)
 models.bake(moving)
 var lamp=models.box(fixture,Vector3.ONE,Vector3.ZERO,Color.YELLOW);lamp.name="WarningLamp";lamp.set_meta("animated",true)
 var glass=models.box(fixture,Vector3.ONE,Vector3(3,0,0),Color.CYAN);glass.material_override=SurfaceLibrary.material(Color.CYAN,"glass")
 var glow=models.box(fixture,Vector3.ONE,Vector3(5,0,0),Color.ORANGE);glow.material_override=models.material(Color.ORANGE,true)
 models.bake(fixture)
 var special=[]
 for child in fixture.get_children():
  if child is MeshInstance3D and child!=lamp:special.append(child)
 optimizer.reduce(fixture)
 moving.position.x=4
 check(fixture.get_node("MovingArm")==moving and mesh_count(moving)==1 and moving.get_child(0).global_position.x==4,"Moving parent and attachment path survive static batching")
 check(is_instance_valid(lamp) and fixture.get_node("WarningLamp")==lamp,"Named animated geometry is never merged or freed")
 check(special.all(func(mesh):return is_instance_valid(mesh)),"Emissive and glass material surfaces retain their own meshes")
 check(game.state==saved,"Material batching does not touch company progress or inventories")
 fixture.free()
 var scene=load("res://Scenes/Main.tscn").instantiate();root.add_child(scene);scene.set_process(false)
 var valley=scene.landscape
 var before=game.state.duplicate(true)
 var original_pool=valley.records.size()
 scene.focus=Vector3(0,0,20);scene.zoom=100;scene.set_camera()
 var unchanged=valley.view_uploads;var rebuilt=valley.view_rebuilds
 for i in 60:scene.set_camera()
 check(valley.view_uploads==unchanged and valley.view_rebuilds==rebuilt,"A stationary camera uploads no decoration or redundant view rebuild")
 var uploads=valley.view_uploads
 var total_slots=0
 for data in valley.batches.values():total_slots+=data.entries.size()
 for position_value in [Vector3(16,0,20),Vector3(32,0,20),Vector3(16,0,20),Vector3(0,0,20)]:
  scene.focus=position_value;scene.set_camera()
  var correct=true
  var center=Vector2(scene.view_focus.x,scene.view_focus.z);var radius=maxf(65,scene.view_zoom*0.95+35)
  for kind in valley.batches:
   var data=valley.batches[kind]
   for index in data.entries.size():
    var entry=data.entries[index]
    if index<data.mesh.visible_instance_count and entry.point.distance_to(center)>radius+0.001:correct=false
    if index>=data.mesh.visible_instance_count and entry.point.distance_to(center)<radius-0.001:correct=false
    var transform=entry.render_transform
    if transform.origin.distance_to(Vector3(entry.point.x,valley.height_at(entry.point),entry.point.y))>0.001:correct=false
  check(correct,"Camera partition retains correct visible membership and cached terrain heights")
 check(valley.view_uploads-uploads<total_slots,"Four neighboring camera cells upload fewer slots than the old single complete pool rewrite")
 game.state.quality=0;valley._process(0)
 for kind in valley.batches:
  var data=valley.batches[kind]
  check(data.mesh.visible_instance_count<=ceili(data.entries.size()*0.45),"Battery mode keeps its bounded nearest-instance budget: "+kind)
 game.state.quality=before.quality
 valley._process(0)
 check(valley.records.size()==original_pool,"No trees, bushes or flowers are removed to obtain the performance gain")
 check(game.state==before,"Camera, quality changes and decoration batching preserve the complete saved company")
 scene.queue_free();await process_frame
 print("PERFORMANCE 2821: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
