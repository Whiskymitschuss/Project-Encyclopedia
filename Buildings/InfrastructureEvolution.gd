class_name InfrastructureEvolution
extends RefCounted

# Additions occupy the rear service strip, perimeter or upper structure. Saved
# plots, actual inventory racks, excavation and forklift aisles stay in place.
const DEPOT_STAGES=["Holzhof","Technikanschluss","Seitenschutz","Verladeportal","Dachtechnik","Regalgalerie","Dispositionsbüro","Versorgungsbrücke","Energiedach","Logistikleitstand"]
const STONE_STAGES=["Werkzeugunterstand","Stützwand","Schutzgalerie","Technikbucht","Stahltragwerk","Bedienkabine","Siloanlage","Wartungssteg","Filteranlage","Betriebsleitstand"]
const BLUE=Color("368dd2")
const WOOD=Color("b67a42")
const CREAM=Color("fff0cf")
const STEEL=Color("a7bec2")

static func box(parent: Node3D,size: Vector3,at: Vector3,color: Color) -> void:
 IndustryEvolution.box(parent,size,at,color)

static func cabin(parent: Node3D,at: Vector3,width: float,tone: Color) -> void:
 box(parent,Vector3(width,2.2,2.0),at,CREAM)
 box(parent,Vector3(width+0.35,0.25,2.35),at+Vector3(0,1.25,0),tone)
 for side in [-1,1]: box(parent,Vector3(width*0.35,1.1,0.12),at+Vector3(side*width*0.25,0.15,1.06),Color("67c4d5"))

static func add_to(root: Node3D,kind: String,level: int) -> void:
 var n=clampi(level,1,10)
 var depot=kind in ["central_depot","express"]
 var names=DEPOT_STAGES if depot else STONE_STAGES
 root.set_meta("evolution_level",n)
 root.set_meta("stage_name",names[n-1])
 var architecture=Node3D.new()
 architecture.name="Architecture"
 root.add_child(architecture)
 for stage in n:
  var group=Node3D.new()
  group.name="Stage%s" % (stage+1)
  group.set_meta("feature",names[stage])
  architecture.add_child(group)
  if depot: depot_module(group,kind,stage)
  else: stone_module(group,kind,stage)
  Models.bake(group)
  # Structural silhouettes survive an overview; small roof fittings disappear
  # sooner. This does not disable economic production or actual freight.
  for mesh in group.find_children("*","MeshInstance3D",true,false):
   mesh.visibility_range_end=360 if stage<4 else 260 if stage<8 else 200
   mesh.visibility_range_end_margin=12
 root.set_meta("height",maxf(float(root.get_meta("height",7.5)),13.5 if n==10 else 11.0 if n>=8 else 9.8 if n>=7 else 7.5))
 var anchors=Node3D.new()
 anchors.name="Connections"
 root.add_child(anchors)
 var work=Vector3(-4.5,0.6,-1) if depot else Vector3(-5,0.6,1)
 for entry in [["VehicleEntry",Vector3(0,0.6,10.5)],["Loading",Vector3(5.5,0.6,6)],["Unloading",Vector3(-5.5,0.6,6)],["Worker",work]]:
  var point=Marker3D.new()
  point.name=entry[0]
  point.position=entry[1]
  anchors.add_child(point)

static func depot_module(group: Node3D,kind: String,stage: int) -> void:
 var width=31.0 if kind=="central_depot" else 19.0
 var edge=width/2-0.7
 var tone=BLUE if kind=="central_depot" else Color("eea642")
 match stage:
  0:
   for x in [-edge,edge]:
    box(group,Vector3(0.25,2.8,0.25),Vector3(x,1.9,-10.95),WOOD)
   for y in [1.0,1.7,2.4]: box(group,Vector3(width-1,0.18,0.16),Vector3(0,y,-11.12),WOOD)
  1:
   box(group,Vector3(1.1,2.5,1.6),Vector3(edge-0.2,1.8,-2),tone)
   box(group,Vector3(0.7,0.7,0.12),Vector3(edge-0.2,2.4,-1.13),CREAM)
   for y in [1.1,1.4,1.7]: box(group,Vector3(0.7,0.08,0.12),Vector3(edge-0.2,y,-1.13),STEEL)
  2:
   for side in [-1,1]:
    box(group,Vector3(2.2,0.22,4.0),Vector3(side*(edge-0.8),5.0,-2.2),tone)
    box(group,Vector3(0.22,4.3,0.22),Vector3(side*edge,2.7,-0.4),STEEL)
  3:
   for x in [-edge,edge]: box(group,Vector3(0.25,6.0,0.25),Vector3(x,3.5,-4),STEEL)
   box(group,Vector3(width-1.2,0.45,0.65),Vector3(0,6.4,-4),tone)
   for x in [-width*0.27,width*0.27]:
    box(group,Vector3(2.8,0.9,0.25),Vector3(x,6.2,-3.5),CREAM)
    for side in [-0.8,0,0.8]: box(group,Vector3(0.45,0.35,0.12),Vector3(x+side,6.2,-3.3),tone)
  4:
   for x in [-width*0.2,width*0.2]:
    box(group,Vector3(2.3,0.8,1.8),Vector3(x,7.35,-8),CREAM)
    for z in [-0.4,0.4]: Models.cylinder(group,0.45,0.18,Vector3(x,7.85,-8+z),STEEL)
  5:
   box(group,Vector3(width-2,0.2,2.2),Vector3(0,4.35,-8.4),STEEL)
   for x in range(-int(width/2)+2,int(width/2)-1,3):
    box(group,Vector3(0.1,1.1,0.1),Vector3(x,5,-7.2),tone)
   for y in [4.7,5.5]: box(group,Vector3(width-2,0.12,0.12),Vector3(0,y,-7.2),tone)
  6: cabin(group,Vector3(-width*0.27,8.1,-8.2),4.0,tone)
  7:
   for x in [-edge+0.4,edge-0.4]: Models.cylinder(group,0.16,3.0,Vector3(x,8.5,-10),STEEL)
   var pipe=Models.cylinder(group,0.24,width-2.2,Vector3(0,10,-10),STEEL)
   pipe.rotation.z=PI/2
  8:
   for x in [0,width*0.15,width*0.3]:
    var panel=Models.box(group,Vector3(2.1,0.14,3.4),Vector3(x,7.4,-7.3),Color("294e70"))
    panel.rotation.x=-0.18
    for z in [-8.2,-7.3,-6.4]: box(group,Vector3(2,0.035,0.035),Vector3(x,7.58,z),STEEL)
  9:
   for x in [-1.2,1.2]: box(group,Vector3(0.3,3.6,0.3),Vector3(x,8.8,-10),tone)
   cabin(group,Vector3(0,11.4,-9.8),4.0,tone)
   Models.cylinder(group,0.12,1.0,Vector3(0,13.2,-9.8),STEEL)

static func stone_module(group: Node3D,kind: String,stage: int) -> void:
 var quarry=kind=="quarry"
 var tone=Color("e5a74c") if quarry else Color("df8755")
 match stage:
  0:
   for x in [6.7,8.3]: box(group,Vector3(0.2,2.6,0.2),Vector3(x,1.8,-9.8),WOOD)
   box(group,Vector3(2.1,0.2,2),Vector3(7.5,3.2,-9.8),WOOD)
   box(group,Vector3(1.3,1.4,0.7),Vector3(7.5,1.3,-10.2),tone)
  1:
   for x in [-8,-4,0,4,8]:
    box(group,Vector3(0.3,3.6,0.35),Vector3(x,2.3,-10.9),STEEL)
   for y in [1.0,2.7,3.9]: box(group,Vector3(16.5,0.22,0.3),Vector3(0,y,-10.9),STEEL)
  2:
   for x in [-8.3,8.3]: box(group,Vector3(0.25,4.6,0.25),Vector3(x,2.8,-9.5),tone)
   box(group,Vector3(17,0.22,2.4),Vector3(0,5.2,-9.5),tone)
  3:
   box(group,Vector3(1.7,2.9,2.0),Vector3(7.7,2,-5.8),CREAM)
   for y in [1.1,1.7,2.3]: box(group,Vector3(1.5,0.18,0.15),Vector3(7.7,y,-4.72),STEEL)
   if quarry:
    for z in [-6.3,-5.3]: Models.cylinder(group,0.4,0.3,Vector3(7.7,3.65,z),tone)
   else: Models.cylinder(group,0.55,1.2,Vector3(7.7,4,-5.8),tone)
  4:
   for x in [-8.3,8.3]: box(group,Vector3(0.35,6.1,0.35),Vector3(x,3.6,-7.7),STEEL)
   box(group,Vector3(17,0.55,0.8),Vector3(0,6.7,-7.7),tone)
   for x in [-4,4]:
    var brace=Models.box(group,Vector3(8.3,0.16,0.3),Vector3(x,5.9,-7.7),STEEL)
    brace.rotation.z=0.18 if x<0 else -0.18
  5: cabin(group,Vector3(-5.8,6.6,-9.4),3.5,tone)
  6:
   for x in [5.2,7.2]:
    Models.cylinder(group,0.8,3.9,Vector3(x,3,-3.6),CREAM)
    Models.cylinder(group,0.84,0.25,Vector3(x,5.1,-3.6),tone)
    for side in [-0.5,0.5]: box(group,Vector3(0.16,1.0,0.16),Vector3(x+side,1,-3.6),STEEL)
  7:
   box(group,Vector3(16.4,0.22,1.3),Vector3(0,7.95,-7.6),STEEL)
   for x in range(-8,9,2): box(group,Vector3(0.12,1,0.12),Vector3(x,8.6,-6.9),tone)
   box(group,Vector3(16.4,0.12,0.12),Vector3(0,9.05,-6.9),tone)
  8:
   Models.cylinder(group,0.6,3,Vector3(7.5,9.5,-9.4),CREAM)
   Models.cylinder(group,0.85,0.3,Vector3(7.5,11.1,-9.4),tone)
   var pipe=Models.cylinder(group,0.22,11.0,Vector3(1.6,10.4,-9.4),STEEL)
   pipe.rotation.z=PI/2
  9:
   for x in [-1.2,1.2]: box(group,Vector3(0.22,2.7,0.22),Vector3(x,9.1,-9.5),STEEL)
   cabin(group,Vector3(0,11.3,-9.5),4.3,tone)
   Models.cylinder(group,0.1,1.0,Vector3(0,13.1,-9.5),STEEL)
