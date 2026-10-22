class_name ValleyLandscape
extends Node3D

# Scenic terrain stays outside the flat, saved construction area.
const HALF = Vector2(390,340)
const GRID = 8
const DECOR_LIMIT = 2500
var world: Node3D
var noise = FastNoiseLite.new()
var detail_noise = FastNoiseLite.new()
var records: Array = []
var batches: Dictionary = {}
var spans: Array = []
var landmarks: Node3D
var quality = -1
var water: MeshInstance3D
var view_key=Vector3(INF,INF,INF)

func _init() -> void:
 noise.seed=140718
 noise.frequency=0.012
 detail_noise.seed=140826
 detail_noise.frequency=0.061

static func river_z(x: float) -> float:
 return 216.0+sin(x*0.022)*14.0

func coast(point: Vector2) -> float:
 return pow(absf(point.x)/382.0,6)+pow(absf(point.y-5)/327.0,6)

func height_at(point: Vector2) -> float:
 var edge=coast(point)
 if edge>1.10: return -3.0
 if edge>0.91: return lerpf(0.38,-3.0,smoothstep(0.91,1.10,edge))
 if absf(point.x)<=310 and point.y>=-183 and point.y<=185: return 0.38
 var hill=maxf(smoothstep(310,365,absf(point.x)),smoothstep(183,280,-point.y))
 hill=maxf(hill,smoothstep(238,300,point.y)*0.6)
 var height=0.38+hill*(4.0+maxf(0,noise.get_noise_2d(point.x,point.y)+0.45)*25)
 var river_distance=absf(point.y-river_z(point.x))
 if absf(point.x)<338 and river_distance<16:
  height=lerpf(-2.2,height,smoothstep(5.0,16.0,river_distance))
 var lake=Vector2((point.x-235)/30.0,(point.y-239)/24.0).length()
 if lake<1.25: height=lerpf(-2.2,height,smoothstep(0.8,1.25,lake))
 return height

func ground_color(point: Vector2) -> Color:
 var tone=Color("829b59")
 var total=0.0
 var blend=Color(0,0,0,1)
 for i in 10:
  var p=Catalog.biome_position(i)
  var distance=Vector2((point.x-p.x)/49.0,(point.y-p.z)/44.0).length()
  var weight=pow(maxf(0,1.0-distance/1.5),2)
  blend+=Color(Catalog.BIOMES[i].ground).lerp(Color("a1ad72"),0.4).darkened(0.15)*weight
  total+=weight
 if total>0.001:
  blend/=total
  tone=tone.lerp(blend,clampf(total*0.68,0,0.78))
 var river_distance=absf(point.y-river_z(point.x))
 if absf(point.x)<340 and river_distance<18: tone=tone.lerp(Color("bdc78e"),1-smoothstep(9,18,river_distance))
 if coast(point)>0.84: tone=tone.lerp(Color("d7c795"),smoothstep(0.84,1.0,coast(point)))
 return tone.darkened(clampf(noise.get_noise_2d(point.x,point.y)*0.13+detail_noise.get_noise_2d(point.x,point.y)*0.04,-0.07,0.13))

func build() -> void:
 build_water()
 var surface=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for z in range(-344,345,GRID):
  for x in range(-392,393,GRID):
   var a=Vector2(x,z)
   var b=a+Vector2(GRID,0)
   var c=a+Vector2(0,GRID)
   var d=a+Vector2(GRID,GRID)
   for p in [a,b,c,b,d,c]:
    var h=height_at(p)
    var normal=Vector3(height_at(p-Vector2(1,0))-height_at(p+Vector2(1,0)),2,height_at(p-Vector2(0,1))-height_at(p+Vector2(0,1))).normalized()
    surface.set_normal(normal)
    surface.set_color(ground_color(p))
    surface.add_vertex(Vector3(p.x,h,p.y))
 var material=StandardMaterial3D.new()
 material.vertex_color_use_as_albedo=true
 material.vertex_color_is_srgb=true
 material.roughness=0.95
 surface.set_material(material)
 surface.index()
 var land=MeshInstance3D.new()
 land.name="ValleyTerrain"
 land.mesh=surface.commit()
 add_child(land)
 landmarks=Node3D.new()
 add_child(landmarks)
 build_landmarks()
 seed_decor()
 refresh()

func build_water() -> void:
 water=MeshInstance3D.new()
 water.name="RiverAndSea"
 var plane=PlaneMesh.new()
 plane.size=Vector2(2200,2200)
 water.mesh=plane
 water.position.y=-1.05
 var shader=Shader.new()
 shader.code="""shader_type spatial;
render_mode cull_back;
varying vec2 world_xz;
void vertex(){world_xz=(MODEL_MATRIX*vec4(VERTEX,1.0)).xz;}
void fragment(){
 float ripple=sin(world_xz.x*0.36+TIME*0.75)*sin(world_xz.y*0.27-TIME*0.5);
 ALBEDO=mix(vec3(0.06,0.32,0.37),vec3(0.10,0.42,0.45),0.52+ripple*0.12);
 ROUGHNESS=0.45; SPECULAR=0.3;
}
"""
 var mat=ShaderMaterial.new()
 mat.shader=shader
 water.material_override=mat
 add_child(water)

func trail(root: Node3D, points: Array, width: float = 2.5) -> void:
 for i in range(1,points.size()):
  var a: Vector2=points[i-1]
  var b: Vector2=points[i]
  var count=maxi(1,ceili(a.distance_to(b)/4.0))
  for step in count:
   var p=a.lerp(b,(step+0.5)/count)
   var deck=Models.box(root,Vector3(width,0.12,a.distance_to(b)/count+0.5),Vector3(p.x,height_at(p)+0.08,p.y),Color("cebd8b"))
   deck.rotation.y=atan2(b.x-a.x,b.y-a.y)

func build_landmarks() -> void:
 var x=-92.0
 var z=river_z(x)
 # A pedestrian bridge and riverside picnic place give the southern valley a destination.
 for dz in range(-11,12,2):
  Models.box(landmarks,Vector3(5.5,0.35,1.85),Vector3(x,1.4,z+dz),Color("c4935d"))
 for side in [-1,1]:
  for dz in [-10,-5,0,5,10]: Models.box(landmarks,Vector3(0.28,2.6,0.28),Vector3(x+side*2.8,1.7,z+dz),Color("8d6b4b"))
  Models.box(landmarks,Vector3(0.25,0.25,24),Vector3(x+side*2.8,2.7,z),Color("d3ae76"))
 trail(landmarks,[Vector2(-80,180),Vector2(x,z-12)])
 trail(landmarks,[Vector2(x,z+12),Vector2(-112,238),Vector2(-137,242)])
 var picnic=Node3D.new()
 landmarks.add_child(picnic)
 picnic.position=Vector3(-137,height_at(Vector2(-137,242)),242)
 for side in [-1,1]: load("res://Buildings/CozyProps.gd").bench(picnic,Vector3(side*3,0,0),side*PI/2)
 Models.box(picnic,Vector3(3.6,0.25,2.2),Vector3(0,2.0,0),Color("c89e68"))
 for px in [-1.3,1.3]: Models.box(picnic,Vector3(0.25,1.5,1.6),Vector3(px,1.2,0),Color("6b7768"))
 Models.cylinder(picnic,0.15,6,Vector3(0,3.5,0),Color("8b714d"))
 Models.cylinder(picnic,3.6,0.9,Vector3(0,6.4,0),Color("dcad56"),0.2)
 Models.bake(picnic)
 # A small lookout on the northern slope replaces the empty map margin.
 var tower=Node3D.new()
 landmarks.add_child(tower)
 var point=Vector2(-220,-215)
 tower.position=Vector3(point.x,height_at(point),point.y)
 for px in [-2.4,2.4]:
  for pz in [-2.4,2.4]: Models.box(tower,Vector3(0.45,9,0.45),Vector3(px,4.6,pz),Color("9f7b51"))
 Models.box(tower,Vector3(6.3,0.5,6.3),Vector3(0,8.2,0),Color("d4b279"))
 for side in [-1,1]:
  Models.box(tower,Vector3(6.1,1.1,0.2),Vector3(0,9,side*3),Color("c3955e"))
  Models.box(tower,Vector3(0.2,1.1,6.1),Vector3(side*3,9,0),Color("c3955e"))
 Models.roof(tower,7,7,12,Color("548878"))
 for y in range(1,9): Models.box(tower,Vector3(1.2,0.15,0.5),Vector3(1,y,3.0),Color("d1ab70"))
 Models.bake(tower)
 Models.bake(landmarks)

func seed_decor() -> void:
 var rng=RandomNumberGenerator.new()
 rng.seed=141706
 # Dense reeds, shrubs and stones make the water belong to the landscape.
 for i in 180:
  var x=rng.randf_range(-315,315)
  var side=-1 if i%2==0 else 1
  var p=Vector2(x,river_z(x)+side*rng.randf_range(12,22))
  if height_at(p)<0.2: continue
  var kind=["bush","flowers","rock","leaf"][i%4]
  var color=Color("8caf63") if kind=="bush" else Color("e9bc70") if kind=="flowers" else Color("a4aaa0") if kind=="rock" else Color("4d9565")
  records.append({"point":p,"kind":kind,"scale":rng.randf_range(0.6,1.0),"angle":rng.randf_range(0,TAU),"color":color,"blocked":false})
 # Empty building lots remain meadow, with low plants instead of empty plates.
 # These share the existing fixed instance pool and disappear when built on.
 for i in 160:
  var p=Vector2(rng.randf_range(-66,66),rng.randf_range(-147,151))
  var kind="bush" if i%5==0 else "flowers"
  records.append({"point":p,"kind":kind,"scale":rng.randf_range(0.45,0.8),"angle":rng.randf_range(0,TAU),"color":Color("6a9b5c") if kind=="bush" else Color("f5d58a") if i%2==0 else Color("dda8a0"),"blocked":false})
 var attempts=0
 while records.size()<DECOR_LIMIT and attempts<22000:
  attempts+=1
  var p=Vector2(rng.randf_range(-353,353),rng.randf_range(-292,292))
  if coast(p)>0.85 or height_at(p)<0.2: continue
  var central=absf(p.x)<90 and p.y>-175 and p.y<178
  var density=noise.get_noise_2d(p.x,p.y)
  if not central and density < -0.12: continue
  var type="pine"
  var roll=rng.randf()
  if central:
   if roll<0.5: continue
   type="flowers" if roll<0.8 else "bush"
  else:
   type="rock" if roll<0.07 else "flowers" if roll<0.16 else "bush" if roll<0.26 else "leaf" if roll<0.51 else "pine"
  var nearest=0
  var distance=INF
  for i in 10:
   var b=Catalog.biome_position(i)
   var d=p.distance_squared_to(Vector2(b.x,b.z))
   if d<distance: distance=d; nearest=i
  # The original thousand harvestable trees remain the working forest.
  if distance<1600 and type in ["pine","leaf"]: continue
  var tone=Color(Catalog.BIOMES[nearest].tree) if distance<8000 else Color("398b57")
  if type=="rock": tone=Color("a1ada0")
  elif type=="flowers": tone=Color("f5cc72") if rng.randf()<0.65 else Color("e895a7")
  records.append({"point":p,"kind":type,"scale":rng.randf_range(0.65,1.25),"angle":rng.randf_range(0,TAU),"color":tone.darkened(rng.randf_range(0,0.16)),"blocked":false})
 for kind in ["pine","leaf","bush","rock","flowers","trunk"]:
  var entries=[]
  for record in records:
   if record.kind==kind or (kind=="trunk" and record.kind in ["pine","leaf"]): entries.append(record)
  var mesh=decor_mesh(kind)
  var multi=MultiMesh.new()
  multi.transform_format=MultiMesh.TRANSFORM_3D
  multi.use_colors=true
  multi.mesh=mesh
  multi.instance_count=entries.size()
  var view=MultiMeshInstance3D.new()
  view.name="Valley_"+kind
  view.multimesh=multi
  var mat=StandardMaterial3D.new()
  mat.vertex_color_use_as_albedo=true
  mat.vertex_color_is_srgb=true
  mat.roughness=0.9
  view.material_override=mat
  if kind in ["flowers","bush"]: view.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  add_child(view)
  batches[kind]={"mesh":multi,"entries":entries,"view":view,"near":mesh,"far":decor_mesh(kind,true)}

func decor_mesh(kind: String,far: bool=false) -> ArrayMesh:
 var surface=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 if kind=="trunk":
  var trunk=CylinderMesh.new()
  trunk.bottom_radius=0.32; trunk.top_radius=0.22; trunk.height=3.2; trunk.radial_segments=6
  append_mesh(surface,trunk,Vector3(0,1.6,0),Color("b28b5b"))
 if kind=="pine":
  for i in 2:
   if far:
    var crown=CylinderMesh.new()
    crown.bottom_radius=2.7-i*0.6; crown.top_radius=0.15; crown.height=4.8; crown.radial_segments=7
    append_mesh(surface,crown,Vector3(0,4.8+i*2.4,0),Color.WHITE.lightened(i*0.05))
   else: append_mesh(surface,CraftedGeometry.pine_crown(2.7-i*0.6,4.8),Vector3(0,4.8+i*2.4,0),Color.WHITE.lightened(i*0.05))
 elif kind in ["leaf","bush","rock"]:
  var crown=SphereMesh.new()
  crown.radial_segments=7 if far else 10; crown.rings=3 if far else 5
  crown.radius=2.8 if kind=="leaf" else 1.5 if kind=="rock" else 1.1
  crown.height=5.5 if kind=="leaf" else 1.8 if kind=="rock" else 1.7
  append_mesh(surface,crown,Vector3(0,5.1 if kind=="leaf" else 0.9,0),Color.WHITE)
 elif kind=="flowers":
  for i in 3:
   var flower=BoxMesh.new()
   flower.size=Vector3(0.5,0.16,0.5)
   append_mesh(surface,flower,Vector3(sin(i*2.3)*0.6,0.55+i*0.1,cos(i*2.3)*0.6),Color.WHITE)
   var stem=BoxMesh.new()
   stem.size=Vector3(0.08,0.45,0.08)
   append_mesh(surface,stem,Vector3(sin(i*2.3)*0.6,0.3,cos(i*2.3)*0.6),Color("5a8e4e"))
 return surface.commit()

func append_mesh(surface: SurfaceTool, mesh: Mesh, at: Vector3, color: Color) -> void:
 var arrays=mesh.surface_get_arrays(0)
 var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
 var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
 var indices: PackedInt32Array=arrays[Mesh.ARRAY_INDEX]
 for i in indices:
  surface.set_color(color)
  surface.set_normal(normals[i])
  surface.add_vertex(vertices[i]+at)

func road_spans() -> Array:
 var result=[]
 for x in [-80,0,80]: result.append([Vector2(x,-172),Vector2(x,180)])
 for z in Placement.ROADS: result.append([Vector2(-82,z),Vector2(82,z)])
 for project in Catalog.PROJECTS:
  var side=signf(project.position.x)
  result.append([Vector2(side*80,Catalog.project_road_z(project)),Vector2(side*190,Catalog.project_road_z(project))])
 for district in int(Game.state.town.districts):
  var side=1 if district==0 else -1
  result.append([Vector2(side*80,-160),Vector2(side*300,-160)])
  result.append([Vector2(side*200,-160),Vector2(side*200,148)])
 for road in Game.state.town.roads:
  var start=Vector2(TownRules.cell(road.cells[0]))
  var previous=start
  var last_direction=Vector2.ZERO
  for i in range(1,road.cells.size()):
   var p=Vector2(TownRules.cell(road.cells[i]))
   var direction=(p-previous).normalized()
   if last_direction!=Vector2.ZERO and direction!=last_direction:
    result.append([start,previous])
    start=previous
   last_direction=direction
   previous=p
  result.append([start,previous])
 # Scenic paths also stay walkable, but are not bus roads.
 result.append([Vector2(-80,180),Vector2(-92,river_z(-92)-12)])
 result.append([Vector2(-92,river_z(-92)+12),Vector2(-112,238)])
 result.append([Vector2(-112,238),Vector2(-137,242)])
 return result

func clear_at(point: Vector2, radius: float, bounds: Array, routes: Array) -> bool:
 for rectangle in bounds:
  if rectangle.grow(radius).has_point(point): return false
 for span in routes:
  var clearance=float(span[2]) if span.size()>2 else 4.7
  if point.distance_to(Geometry2D.get_closest_point_to_segment(point,span[0],span[1]))<clearance+radius: return false
 if absf(point.x+92)<6+radius and absf(point.y-river_z(-92))<14+radius: return false
 if point.distance_to(Vector2(-137,242))<7+radius: return false
 if point.distance_to(Vector2(-220,-215))<6+radius: return false
 return true

func refresh() -> void:
 var bounds=[WorldAccess.HIGHWAY_SITE,Rect2(319,72,24,136)]
 for i in Game.state.buildings.size(): bounds.append(Placement.bounds(Game.building_position(i),int(Game.state.buildings[i].get("rotation",0))))
 for i in Game.state.homes.size(): bounds.append(Placement.bounds(Game.home_position(i),int(Game.state.homes[i].get("rotation",0))))
 for job in Game.state.jobs:
  if job.type not in ["building","home"]: continue
  var fallback=Catalog.home_position(int(job.plot)) if job.type=="home" else Catalog.industry_position(int(job.get("slot",0)))
  bounds.append(Placement.bounds(Placement.position_of(job,fallback),int(job.get("rotation",0))))
 for project in Catalog.PROJECTS: bounds.append(Placement.bounds(project.position,0))
 for stop in Game.state.town.stops: bounds.append(Rect2(Vector2(TownRules.cell(stop.cell))-Vector2(8,8),Vector2(16,16)))
 if world!=null and world.actors!=null:
  for actor in world.actors.get_children():
   if actor.has_meta("forestry_tier"): bounds.append(Rect2(Vector2(actor.origin_point.x,actor.origin_point.z)-Vector2(9,9),Vector2(18,18)))
 spans=road_spans()
 quality=int(Game.state.quality)
 for kind in batches:
  var data=batches[kind]
  data.mesh.visible_instance_count=data.entries.size() if quality>0 else ceili(data.entries.size()*0.45)
  for i in data.entries.size():
   var entry=data.entries[i]
   var radius=2.8*entry.scale if entry.kind in ["pine","leaf"] else 1.4*entry.scale if entry.kind in ["rock","bush"] else 0.7
   entry.blocked=not clear_at(entry.point,radius,bounds,spans)
   var size=0.001 if entry.blocked else float(entry.scale)
   var basis=Basis(Vector3.UP,float(entry.angle)).scaled(Vector3.ONE*size)
   data.mesh.set_instance_transform(i,Transform3D(basis,Vector3(entry.point.x,height_at(entry.point),entry.point.y)))
   data.mesh.set_instance_color(i,Color.WHITE if kind=="trunk" else entry.color)
 update_view(true)

func update_view(force: bool=false) -> void:
 if world==null: return
 var key=Vector3(snappedf(world.view_focus.x,16),snappedf(world.view_focus.z,16),snappedf(world.view_zoom,12))
 if not force and key==view_key: return
 view_key=key
 var center=Vector2(world.view_focus.x,world.view_focus.z)
 var radius=maxf(65,world.view_zoom*0.95+35)
 for kind in batches:
  var data=batches[kind]
  data.entries.sort_custom(func(a,b): return a.point.distance_squared_to(center)<b.point.distance_squared_to(center))
  var visible_count=0
  for i in data.entries.size():
   var entry=data.entries[i]
   if entry.point.distance_to(center)<=radius: visible_count+=1
   var size=0.001 if entry.blocked else float(entry.scale)
   data.mesh.set_instance_transform(i,Transform3D(Basis(Vector3.UP,float(entry.angle)).scaled(Vector3.ONE*size),Vector3(entry.point.x,height_at(entry.point),entry.point.y)))
   data.mesh.set_instance_color(i,Color.WHITE if kind=="trunk" else entry.color)
  data.mesh.mesh=data.near if world.view_zoom<180 and quality>0 else data.far
  data.mesh.visible_instance_count=mini(visible_count,ceili(data.entries.size()*0.45)) if quality==0 else visible_count

func _process(_delta: float) -> void:
 if quality!=int(Game.state.quality): refresh()
