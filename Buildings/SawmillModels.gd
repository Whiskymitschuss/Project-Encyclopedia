class_name SawmillModels
extends RefCounted
const BLUE=Color("328db8")
const WOOD=Color("bd874d")
const CREAM=Color("fff0d2")
const STEEL=Color("9bb9bd")
const STAGES=["Forsthütte","Entrinderwerkstatt","Bretterhof","Doppellinienhalle","Industriesägewerk","Technikflügel","Dreilinienhalle","Hallenverbund","Automatikwerk","Biber-Leitwerk"]

static func box(root: Node3D,size: Vector3,at: Vector3,color: Color) -> MeshInstance3D:
 return Models.box(root,size,at,color)
static func create(level: int) -> Node3D:
 var n=clampi(level,1,10)
 var root=Node3D.new()
 # Retain the established rendering metadata for the shared quality/feedback UI.
 root.set_meta("crafted_version",2); root.set_meta("quality_tier",mini(n,5))
 root.set_meta("quality_tier_name",STAGES[n-1])
 root.set_meta("kind","sawmill"); root.set_meta("open_factory",true)
 root.set_meta("evolution_level",n); root.set_meta("stage_name",STAGES[n-1]); root.set_meta("height",13 if n==10 else 10 if n>=8 else 8.6)
 var floor=Models.paving_box(root,Vector3(19,0.16,23),Vector3(0,0.46,0),ProductionCampus.CONCRETE,"plaster",1)
 floor.name="FactoryFloor"; floor.set_meta("animated",true)
 WoodYard.decorate(root,"sawmill")
 CraftedFrontage.detail_ranges(root.get_node("WoodYard"))
 # Buffers stay outside the three machinery strips and inside the perimeter aisle.
 var input=Node3D.new(); input.name="InputStock"; input.position=Vector3(-6.3,0.45,-4.5); root.add_child(input)
 load("res://Buildings/FactoryModels.gd").large_logs(input,6); Models.bake(input); input.scale.x=0.78
 var output=Node3D.new(); output.name="OutputStock"; output.position=Vector3(6.3,0.45,5.5); root.add_child(output)
 load("res://Buildings/FactoryModels.gd").planks(output,Vector3.ZERO,10); Models.bake(output)
 # Recoverable sawdust never blocks the outer forklift lane.
 for x in [-7.6,-5.4]: box(root,Vector3(0.15,2.2,2.5),Vector3(x,1.65,-8.8),Color("dcad54"))
 box(root,Vector3(2.3,2.2,0.15),Vector3(-6.5,1.65,-10),Color("dcad54"))
 var fill=box(root,Vector3(2,2.7,2.1),Vector3(-6.5,0.7,-8.8),Color("d3ab66"))
 fill.name="SawdustFill"; fill.set_meta("animated",true); fill.set_meta("label_point",Vector3(-6.5,4,-8.8))
 var process=load("res://Components/SawmillView.gd").new()
 process.name="Processing"; root.add_child(process)
 for i in 3:
  var lane=Node3D.new(); lane.name="Line%s" % i
  lane.position.x=[0,-3.3,3.3][i]; process.add_child(lane)
  lane.visible=i==0
  machine(lane,n,i)
  if i==0:
   for key in ["Feed","SawStock","Product","Rotor","Planer"]:
    var part=lane.get_node(key)
    part.reparent(process,false)
    if key=="Planer": part.name="ToolHead"
 var handler=load("res://Components/YardHandling.gd").new(); handler.name="YardHandling"; root.add_child(handler)
 transfer_belt(root,level)
 var beacon=load("res://Components/ProductionBeacon.gd").new(); beacon.name="ProductionBeacon"; beacon.position=Vector3(-5.1,2.1,1.5); root.add_child(beacon)
 architecture(root,n)
 var anchors=Node3D.new(); anchors.name="Connections"; root.add_child(anchors)
 for entry in [["VehicleEntry",Vector3(0,0.6,10.5)],["Loading",Vector3(6.3,0.6,5.5)],["Unloading",Vector3(-6.3,0.6,-4.5)],["Worker",Vector3(-1.65,0.6,0)]]:
  var marker=Marker3D.new(); marker.name=entry[0]; marker.position=entry[1]; anchors.add_child(marker)
 Models.bake(root)
 return root

static func machine(root: Node3D,level: int,variant: int) -> void:
 # Three distinct stations and transfer beds, each large enough for a beaver.
 for z in [-5.4,-0.2,4.8]:
  box(root,Vector3(2.1,0.6,4),Vector3(0,1.15,z),WOOD if level<=2 else BLUE)
  for x in [-1,1]: box(root,Vector3(0.12,0.3,4),Vector3(x,1.6,z),STEEL)
  for k in 5:
   var roller=Models.cylinder(root,0.13,1.9,Vector3(0,1.62,z-1.5+k*0.75),STEEL)
   roller.rotation.z=PI/2
 # Entrinder: two driven gripping drums, orange frame and a raw trunk.
 for x in [-0.85,0.85]:
  box(root,Vector3(0.18,2.4,1.5),Vector3(x,2.2,-5.4),Color("eaab42"))
 var drums=Node3D.new(); drums.name="Debarker"; drums.position=Vector3(0,2.1,-5.4); root.add_child(drums)
 for x in [-0.75,0.75]:
  var drum=Models.cylinder(drums,0.25,1.1,Vector3(x,0,0),STEEL); drum.rotation.x=PI/2
 Models.bake(drums)
 # Saw portal remains open to reveal a guarded moving blade.
 for x in [-0.9,0.9]: box(root,Vector3(0.2,2.7,1.2),Vector3(x,2.2,0),Color("e98c48"))
 box(root,Vector3(2,0.22,1.4),Vector3(0,3.7,0),Color("e98c48"))
 var rotor=Node3D.new(); rotor.name="Rotor"; rotor.position=Vector3(0,2.2,0); root.add_child(rotor)
 var saw=Models.cylinder(rotor,0.73,0.1,Vector3.ZERO,CREAM); saw.rotation.z=PI/2
 for k in 10:
  var angle=k*TAU/10
  var tooth=box(rotor,Vector3(0.12,0.23,0.16),Vector3(0,cos(angle)*0.74,sin(angle)*0.74),CREAM)
  tooth.rotation.x=-angle
 Models.bake(rotor)
 # Planer hood and independently moving pressure rollers.
 for x in [-0.9,0.9]: box(root,Vector3(0.22,1.7,1.8),Vector3(x,2.0,4.4),Color("35a999"))
 box(root,Vector3(2,0.45,1.8),Vector3(0,3.05,4.4),Color("35a999"))
 var planer=Node3D.new(); planer.name="Planer"; planer.position=Vector3(0,2.15,4.4); root.add_child(planer)
 for z in [-0.45,0.45]:
  var roll=Models.cylinder(planer,0.2,1.5,Vector3(0,0,z),STEEL); roll.rotation.z=PI/2
 Models.bake(planer)
 for entry in [["Feed",-6.3,Color("855731")],["SawStock",-1.0,Color("d3aa6c")]]:
  var piece=Node3D.new(); piece.name=entry[0]; piece.position=Vector3(0,2.0,entry[1]); root.add_child(piece)
  var timber=Models.cylinder(piece,0.34,2.3,Vector3.ZERO,entry[2]); timber.rotation.x=PI/2
  for end in [-1,1]:
   var face=Models.cylinder(piece,0.3,0.02,Vector3(0,0,end*1.16),Color("efce95")); face.rotation.x=PI/2
  Models.bake(piece); piece.hide()
 var product=Node3D.new(); product.name="Product"; product.position=Vector3(0,1.85,4.5); root.add_child(product)
 box(product,Vector3(0.9,0.25,2.5),Vector3.ZERO,Color("e1b374")); Models.bake(product); product.hide()
 var operator=BeaverModels.create(variant*3+1,"industry")
 operator.name="Operator"; operator.scale=Vector3.ONE*0.8
 operator.position=Vector3(-1.65,0.6,0); operator.rotation.y=PI/2
 root.add_child(operator)
 box(root,Vector3(0.18,1.1,0.7),Vector3(-1.1,1.2,0.6),BLUE)
 box(root,Vector3(0.12,0.5,0.5),Vector3(-1.23,1.8,0.6),Color("78c8b8"))
 Models.bake(root)
 for mesh in root.find_children("*","MeshInstance3D",true,false): mesh.visibility_range_end=300

static func transfer_belt(root: Node3D,level: int) -> void:
 var start=-3.3 if level>=4 else 0.0
 var length=6.3-start
 box(root,Vector3(length+0.8,0.4,0.85),Vector3((start+6.3)/2,1.2,8),BLUE)
 for z in [7.5,8.5]: box(root,Vector3(length+0.9,0.25,0.1),Vector3((start+6.3)/2,1.55,z),STEEL)
 for i in range(ceili(start),7):
  var roll=Models.cylinder(root,0.13,0.75,Vector3(i,1.5,8),STEEL); roll.rotation.x=PI/2
 box(root,Vector3(0.85,0.4,2.5),Vector3(6.3,1.2,6.8),BLUE)
 for z in [5.7,6.4,7.1,7.8]:
  var roll=Models.cylinder(root,0.13,0.75,Vector3(6.3,1.5,z),STEEL); roll.rotation.z=PI/2

static func architecture(root: Node3D,n: int) -> void:
 var architecture_root=Node3D.new(); architecture_root.name="Architecture"; root.add_child(architecture_root)
 for level in range(1,n+1):
  var group=Node3D.new(); group.name="Stage%s" % level; group.set_meta("feature",STAGES[level-1]); architecture_root.add_child(group)
  match level:
   1:
    for x in [-2.5,2.5]: box(group,Vector3(0.28,3.5,0.28),Vector3(x,2.25,-9.4),WOOD)
    Models.roof(group,5.8,3.6,4.1,WOOD)
    # The roof helper centres its geometry; move the complete shelter rearward.
    for child in group.get_children():
     if child.position.z==0: child.position.z=-9
   2:
    box(group,Vector3(3.4,2.8,2.4),Vector3(6.1,1.95,-9),CREAM)
    box(group,Vector3(3.8,0.25,2.8),Vector3(6.1,3.5,-9),BLUE)
    box(group,Vector3(2.6,1.1,0.12),Vector3(6.1,2.4,-7.75),Color("71becb"))
   3:
    for x in [5.3,7.3]: box(group,Vector3(0.16,3.2,0.16),Vector3(x,2.1,2.2),BLUE)
    for y in [0.5,2.1,3.5]: box(group,Vector3(2.4,0.15,1.4),Vector3(6.3,y,2.2),CREAM)
   4:
    for x in [-5.4,5.4]:
     for z in [-6.7,6.7]: box(group,Vector3(0.3,5.4,0.3),Vector3(x,3.2,z),STEEL)
    box(group,Vector3(11,0.3,0.3),Vector3(0,5.9,-6.7),BLUE)
   5:
    for x in [-5.4,5.4]: box(group,Vector3(0.3,6.4,0.3),Vector3(x,3.7,7.2),BLUE)
    box(group,Vector3(11.1,0.55,0.45),Vector3(0,7,7.2),BLUE)
    for x in [-4.2,4.2]: box(group,Vector3(2.3,1.2,0.18),Vector3(x,1.2,-7.8),CREAM)
   6:
    box(group,Vector3(2.2,1.8,2),Vector3(6.4,4.4,-9),STEEL)
    for x in [5.8,6.8]: Models.cylinder(group,0.3,2.1,Vector3(x,6,-9),CREAM)
   7:
    for x in [-5.4,5.4]: box(group,Vector3(0.25,7.2,0.25),Vector3(x,4.1,-4),BLUE)
    box(group,Vector3(11.1,0.45,0.6),Vector3(0,7.9,-4),BLUE)
    for x in [-3.3,0,3.3]: box(group,Vector3(0.8,0.8,0.8),Vector3(x,6.9,-4),Color("e9ae48"))
   8:
    for x in [-2.7,2.7]:
     var roof=Node3D.new(); roof.position=Vector3(x,0,-6.7); group.add_child(roof)
     Models.roof(roof,5.3,4.4,8.1,BLUE); Models.bake(roof)
   9:
    var pipe=Models.cylinder(group,0.2,10.5,Vector3(0,9.4,-7.2),STEEL); pipe.rotation.z=PI/2
    for x in [-3.3,0,3.3]: Models.cylinder(group,0.13,2,Vector3(x,8.3,-7.2),STEEL)
   10:
    box(group,Vector3(4.8,2.3,2.6),Vector3(0,10.1,-9.1),CREAM)
    box(group,Vector3(5.2,0.3,3),Vector3(0,11.4,-9.1),BLUE)
    for x in [-1.5,0,1.5]: box(group,Vector3(1.2,1.2,0.12),Vector3(x,10.2,-7.75),Color("71becb"))
    Models.cylinder(group,0.1,1.2,Vector3(0,12.1,-9.1),STEEL)
  Models.bake(group)
  for mesh in group.find_children("*","MeshInstance3D",true,false): mesh.visibility_range_end=360
