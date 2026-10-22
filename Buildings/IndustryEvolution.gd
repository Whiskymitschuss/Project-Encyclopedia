class_name IndustryEvolution
extends RefCounted

# Completed economic levels select a physical module set. The existing plot
# size and working aisle remain reserved even at stage ten, including old saves.
const STAGES=["Holzunterstand","Werkstatt","Lagerbucht","Förderwerkstatt","Industriehalle","Technikflügel","Automatikportal","Hallenverbund","Versorgungsbrücke","Leitstand"]
const BLUE=Color("368dd2")
const CREAM=Color("fff0cf")
const STEEL=Color("a7bec2")
const WOOD=Color("b67a42")

static func box(parent: Node3D,size: Vector3,at: Vector3,color: Color) -> void:
 Models.crafted_box(parent,size,at,color,"timber" if color==WOOD else "paint",minf(0.15,minf(size.x,minf(size.y,size.z))*0.2))

static func add_to(root: Node3D,kind: String,level: int) -> void:
 var n=clampi(level,1,10)
 root.set_meta("evolution_level",n)
 root.set_meta("stage_name",STAGES[n-1])
 var architecture=Node3D.new()
 architecture.name="Architecture"
 root.add_child(architecture)
 var width=31.0 if kind=="central_depot" else 19.0
 var storage=kind in ["warehouse","station","central_depot","express"]
 var utility=kind in ["cabin","market","research","garage"]
 var stone=kind in ["quarry","stoneworks"]
 var tone=Color("57a99d") if utility else Color("ea9a4d") if stone else BLUE
 for stage in n:
  var group=Node3D.new()
  group.name="Stage%s" % (stage+1)
  group.set_meta("feature",STAGES[stage])
  architecture.add_child(group)
  match stage:
   0:
    # Base rear work shelter: an actual roof, posts and enclosed tool bench.
    for x in [-2.7,2.7]: box(group,Vector3(0.24,3.3,0.24),Vector3(x,2.2,-9),WOOD)
    box(group,Vector3(6.2,0.22,3.0),Vector3(0,3.95,-9),WOOD)
    box(group,Vector3(4.2,0.85,1.3),Vector3(0,1.0,-9.2),WOOD)
   1:
    box(group,Vector3(2.0,2.7,1.0),Vector3(-4.3,1.9,-9.5),tone)
    for y in [1.3,2.1,2.9]: box(group,Vector3(1.7,0.12,0.12),Vector3(-4.3,y,-8.94),STEEL)
    Models.cylinder(group,0.40,0.6,Vector3(0,1.8,-9),STEEL)
   2:
    for x in [-7.5,-5.8]: box(group,Vector3(0.18,3.1,0.18),Vector3(x,2.1,-9.4),tone)
    for y in [1.0,2.3,3.4]: box(group,Vector3(2.1,0.14,2),Vector3(-6.65,y,-9.4),CREAM)
    for x in [-7,-6.2]: box(group,Vector3(0.55,0.45,1.4),Vector3(x,1.3,-9.4),WOOD)
   3:
    # High rear transfer bridge keeps the existing ground circulation free.
    for x in [-8,8]: box(group,Vector3(0.22,4.5,0.22),Vector3(x,2.8,-7.6),STEEL)
    box(group,Vector3(16,0.32,1.0),Vector3(0,5.15,-7.6),tone)
    for x in range(-7,8,2):
     var roller=Models.cylinder(group,0.13,0.9,Vector3(x,5.43,-7.6),STEEL)
     roller.rotation.x=PI/2
   4:
    for x in [-8.2,8.2]: box(group,Vector3(0.35,6.4,0.35),Vector3(x,3.8,-10.5),tone)
    box(group,Vector3(17.0,0.45,0.4),Vector3(0,7,-10.5),tone)
    for x in [-4.3,4.3]:
     var brace=Models.box(group,Vector3(8.8,0.18,0.2),Vector3(x,5.8,-10.5),CREAM)
     brace.rotation.z=0.26 if x<0 else -0.26
   5:
    box(group,Vector3(2.5,4.7,2.3),Vector3(6.0,2.9,-9.2),CREAM)
    box(group,Vector3(2.9,0.3,2.7),Vector3(6,5.45,-9.2),tone)
    box(group,Vector3(1.8,1.0,0.12),Vector3(6,4.1,-7.99),Color("67c4d5"))
    Models.cylinder(group,0.35,1.2,Vector3(6,6.2,-9.2),STEEL)
   6:
    for x in [-8.2,8.2]: box(group,Vector3(0.3,5.5,0.3),Vector3(x,3.3,-6.4),tone)
    box(group,Vector3(16.7,0.5,0.7),Vector3(0,6.2,-6.4),tone)
    box(group,Vector3(1.7,1.0,1.0),Vector3(-3,5.6,-6.4),Color("f6bf45"))
    box(group,Vector3(0.30,1.4,0.3),Vector3(-3,4.45,-6.4),STEEL)
   7:
    # Two independently framed roof bays, instead of uniform model scaling.
    for side in [-1,1]:
     var canopy=Node3D.new()
     canopy.position=Vector3(side*4.2,0,-8.8)
     group.add_child(canopy)
     Models.roof(canopy,8.1,4.0,7.3,tone)
     Models.bake(canopy)
   8:
    for x in [-7.4,7.4]:
     Models.cylinder(group,0.16,3.0,Vector3(x,8.4,-9),STEEL)
    var pipe=Models.cylinder(group,0.20,14.8,Vector3(0,9.8,-9),STEEL)
    pipe.rotation.z=PI/2
    box(group,Vector3(2.8,1.1,2.8),Vector3(5.5,8.6,-9),CREAM)
    for x in [4.8,6.1]: Models.cylinder(group,0.4,0.18,Vector3(x,9.3,-9),tone)
   9:
    box(group,Vector3(5.0,2.2,2.8),Vector3(0,8.7,-9),CREAM)
    box(group,Vector3(5.3,0.3,3.1),Vector3(0,9.95,-9),tone)
    for x in [-1.5,0,1.5]: box(group,Vector3(1.2,1.3,0.16),Vector3(x,8.8,-7.5),Color("67c4d5"))
    if storage:
     for x in [-width/2+0.7,width/2-0.7]:
      box(group,Vector3(0.3,6.8,0.3),Vector3(x,4,-10.3),tone)
    if not utility:
     Models.cylinder(group,0.12,1.1,Vector3(0,10.65,-9),STEEL)
     Models.cylinder(group,0.35,0.3,Vector3(0,11.25,-9),Color("f6bf45"))
  Models.bake(group)
  for mesh in group.find_children("*","MeshInstance3D",true,false):
   mesh.visibility_range_end=360
   mesh.visibility_range_end_margin=20
   mesh.visibility_range_fade_mode=GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
 root.set_meta("height",maxf(float(root.get_meta("height",8.6)),11.6 if n==10 else 10.1 if n>=9 else 8.3 if n>=8 else 8.6))
 # Connection and work anchors are shared by the real main-world instances.
 var anchors=Node3D.new()
 anchors.name="Connections"
 root.add_child(anchors)
 for entry in [["VehicleEntry",Vector3(0,0.6,10.5)],["Loading",Vector3(5.5,0.6,6)],["Unloading",Vector3(-5.5,0.6,6)],["Worker",Vector3(-3.5,0.6,2.7)]]:
  var marker=Marker3D.new()
  marker.name=entry[0]
  marker.position=entry[1]
  anchors.add_child(marker)
