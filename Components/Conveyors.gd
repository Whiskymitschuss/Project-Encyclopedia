class_name ConveyorNetwork
extends Node3D

const SOURCES = {"sawmill":["station"],"warehouse":["station"],"kiln":["sawmill"],"furniture":["kiln"],"prefab":["kiln"],"joinery":["sawmill"],"pellet":["sawmill"],"paper":["sawmill"],"design":["furniture"],"market":["furniture"]}
var links: Array = []
var goods: MultiMesh
var road_spans: Array = []

func build() -> void:
 road_spans = LogisticsRoutes.road_spans_for(Game.state)
 links = LogisticsRoutes.belts(Game.state)
 links = links.slice(0,12 if Game.state.quality==0 else 24)
 # Actual deliveries are drawn by DeliveryWorld; this network only decorates legacy lines.
 for link in links:
  if Game.delivery_owns(int(link.target)): continue
  for k in range(1,link.points.size()): deck(link.points[k-1],link.points[k])
 Models.bake(self)
 goods = MultiMesh.new()
 goods.transform_format = MultiMesh.TRANSFORM_3D
 goods.use_colors = true
 var mesh = BoxMesh.new()
 mesh.size = Vector3(1.4,0.65,1.2)
 goods.mesh = mesh
 goods.instance_count = links.size()*3
 var view = MultiMeshInstance3D.new()
 view.multimesh = goods
 var mat = Models.material(Color("f7c779")).duplicate()
 mat.vertex_color_use_as_albedo = true
 view.material_override = mat
 add_child(view)

func deck(from: Vector3, to: Vector3) -> void:
 var center = (from+to)/2
 var basis = Basis.looking_at((to-from).normalized(),Vector3.UP)
 var length = from.distance_to(to)
 var belt = Models.box(self,Vector3(2.4,0.3,length+0.15),center,Color("3f6670"))
 belt.basis = basis
 for side in [-1,1]:
  var rail = Models.box(self,Vector3(0.15,0.65,length+0.15),center+basis.x*side*1.25+Vector3(0,0.25,0),Color("f3c45b"))
  rail.basis = basis
 if (center.y>3 or length>6) and elevation(Vector2(center.x,center.z))<6.0:
  for side in [-1,1]: Models.box(self,Vector3(0.35,center.y,0.35),Vector3(center.x,center.y/2,center.z)+basis.x*side*1.0,Color("6f8e93"))

func point_at(link: Dictionary, distance: float) -> Vector3:
 var points = link.points
 for i in range(1,points.size()):
  var length = points[i-1].distance_to(points[i])
  if distance<=length: return points[i-1].lerp(points[i],distance/maxf(length,0.001))
  distance -= length
 return points[-1]

func _process(delta: float) -> void:
 if goods==null: return
 for i in links.size():
  var link = links[i]
  if Game.delivery_owns(int(link.target)):
   for j in 3: goods.set_instance_transform(i*3+j,Transform3D(Basis.IDENTITY.scaled(Vector3.ZERO),Vector3.ZERO))
   continue
  var rate = float(Game.flow.get("building:%s" % link.target,0))
  if link.kind=="market": rate=float(Game.flow.get("export",0))
  if link.kind=="warehouse": rate=float(Game.flow.get("harvest",0))
  if rate>0: link.phase=fmod(float(link.phase)+delta*4.5/maxf(link.length,1),1.0)
  for j in 3:
   var position_value = point_at(link,fmod(float(link.phase)+j/3.0,1)*float(link.length))+Vector3(0,0.6,0)
   goods.set_instance_transform(i*3+j,Transform3D(Basis.IDENTITY,position_value))
   goods.set_instance_color(i*3+j,Color("fff2bf") if link.kind in ["furniture","design","market"] else Color.WHITE)


func elevation(point: Vector2) -> float:
 return LogisticsRoutes.elevation(Game.state,point,road_spans)
