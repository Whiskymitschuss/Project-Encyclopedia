extends Node3D
var world: Node3D
var wetness=0.0
var puddles: MultiMeshInstance3D
var material: StandardMaterial3D
var road_signature=-1

func _ready() -> void:
 puddles=MultiMeshInstance3D.new()
 var mm=MultiMesh.new()
 mm.transform_format=MultiMesh.TRANSFORM_3D
 var mesh=CylinderMesh.new()
 mesh.top_radius=1
 mesh.bottom_radius=1
 mesh.height=0.015
 mesh.radial_segments=12
 mm.mesh=mesh
 mm.instance_count=28
 mm.visible_instance_count=0
 puddles.multimesh=mm
 material=StandardMaterial3D.new()
 material.albedo_color=Color(0.40,0.56,0.59,0.0)
 material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 material.roughness=0.12
 material.metallic=0.25
 puddles.material_override=material
 puddles.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(puddles)
 rebuild_puddles()

func rebuild_puddles() -> void:
 var cells=TownRules.road_cells(Game.state.town).keys()
 cells.sort_custom(func(a,b): return a.x<b.x if a.x!=b.x else a.y<b.y)
 if cells.is_empty(): puddles.multimesh.visible_instance_count=0; return
 for i in 28:
  var cell=cells[(i*37+13)%cells.size()]
  var at=TownRules.point(cell)+Vector3(sin(i*2.3)*0.7,0.98,cos(i*1.7)*0.6)
  var basis=Basis(Vector3.UP,i*1.7).scaled(Vector3(0.55+(i%3)*0.18,1,0.32+(i%2)*0.13))
  puddles.multimesh.set_instance_transform(i,Transform3D(basis,at))

func _process(delta: float) -> void:
 var signature=hash([Game.state.town.roads,Game.state.town.districts])
 if signature!=road_signature:
  road_signature=signature
  rebuild_puddles()
 wetness=move_toward(wetness,1.0 if int(Game.state.weather)==2 else 0.0,delta*(0.22 if int(Game.state.weather)==2 else 0.055))
 SurfaceLibrary.weather(wetness)
 material.albedo_color.a=wetness*0.5
 puddles.visible=wetness>0.02 and Game.state.ambient_enabled
 puddles.multimesh.visible_instance_count=10 if Game.state.quality==0 else 28
