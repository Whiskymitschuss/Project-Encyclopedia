class_name CraftedFrontage
extends RefCounted

const Props=preload("res://Buildings/CozyProps.gd")

static func decorate(root: Node3D,kind: String,level: int,city: bool) -> void:
 root.set_meta("crafted_version",2)
 root.set_meta("quality_tier",mini(5,maxi(1,level)))
 root.set_meta("quality_tier_name",["Einfach","Gepflegt","Erweitert","Großbetrieb","Premium"][clampi(level,1,5)-1])
 var details=Node3D.new()
 details.name="FrontageDetails"
 root.add_child(details)
 if city:
  if kind in ["house","landhouse","apartments","office","townhall","school"]:
   for x in [-7.3,7.3]:
    Models.crafted_box(details,Vector3(2.1,0.2,2.7),Vector3(x,0.57,8.5),Color("74a96a"),"plaster",0.3)
    Models.crafted_box(details,Vector3(1.8,0.65,0.65),Vector3(x,0.95,9.0),Color("57935e"),"plaster",0.22)
   var entry_x=-2.0 if kind in ["house","landhouse"] else -1.0 if kind in ["apartments","office","school"] else 0.0
   Models.paving_box(details,Vector3(2.6,0.08,8.8),Vector3(entry_x,0.71,6.6),Color("d9cbb2"),"paving",0.25)
  if kind in ["house","landhouse","villa"]:
   # The central pedestrian entrance stays clear; no decoration covers a pool.
   Models.crafted_box(details,Vector3(0.7,1.1,0.5),Vector3(7.7,1.05,10.2),Color("2e7584"),"paint")
   Models.box(details,Vector3(0.4,0.08,0.03),Vector3(7.7,1.3,10.46),Color("fff0ce"))
   for x in [-8.5,8.5]:
    for z in [-6,-2,2]:
     Models.crafted_box(details,Vector3(0.24,1.25,0.24),Vector3(x,1.1,z),Color("e7dbc1"))
    Models.box(details,Vector3(0.13,0.17,8),Vector3(x,1.45,-2),Color("d4bb92"))
  elif kind in ["shop","nightclub","hotel"]:
   for x in [-7.8,7.8]: Props.planter(details,Vector3(x,0,9.8))
  if kind in ["house","landhouse","villa","shop"]:
   Models.crafted_box(details,Vector3(1.0,2.2,0.8),Vector3(6.8,1.65,-8.9),Color("bba98e"),"paint")
  if kind in ["fire","clinic","police","taxi"]:
   # A flush apron is usable by the existing service vehicles.
   for x in [-7.6,7.6]:
    Models.cylinder(details,0.14,1,Vector3(x,1.0,10.7),Color("e7bb55"))
 else:
  for x in [-8.0,8.0]:
   Models.crafted_box(details,Vector3(0.8,0.4,2.0),Vector3(x,0.73,9.7),Color("61796d"),"paint")
   Models.box(details,Vector3(0.85,0.06,0.25),Vector3(x,0.97,9.7),Color("f2c95c"))
  # Distinct office pod behind the working machinery, within the old 19×23 lot.
  if kind not in ["warehouse","station","cabin","market","garage","research","quarry","stoneworks"]:
   Models.crafted_box(details,Vector3(3.2,2.8,2),Vector3(-5.8,1.95,-9.2),Color("eee0bf"))
   Models.crafted_box(details,Vector3(3.5,0.25,2.3),Vector3(-5.8,3.5,-9.2),Color("32677a"),"paint")
   Models.crafted_box(details,Vector3(2.4,1.2,0.12),Vector3(-5.8,2.4,-8.14),Color("62b9c8"),"glass",0.04)
   Models.box(details,Vector3(0.12,1.3,0.2),Vector3(-5.8,2.4,-8.1),Color("e6dbc3"))
  for i in mini(3,1+level/4):
   Models.crafted_box(details,Vector3(1.0,0.9,0.8),Vector3(4+i*1.3,0.96,-9.9),Color("ac8659"),"timber")
 decorate_progress(details,root,kind,level,city)
 Models.bake(details)
 detail_ranges(details)

static func detail_ranges(node: Node) -> void:
 if node is GeometryInstance3D:
  node.visibility_range_end=360
  node.visibility_range_end_margin=20
 for child in node.get_children(): detail_ranges(child)

static func decorate_progress(details: Node3D,root: Node3D,kind: String,level: int,city: bool) -> void:
 var tier=clampi(level,1,5)
 # A coherent timber/brass badge remains legible even when silhouettes share floors.
 var brass=Color("e5bd72") if tier==5 else Color("c9b394")
 Models.box(details,Vector3(0.6,2.4+tier*0.12,0.6),Vector3(-8.4,1.7,7.0),Color("41645c"))
 Models.box(details,Vector3(2.1,1.5,0.25),Vector3(-8.1,3,7.0),Color("24463f"))
 for i in tier:
  Models.box(details,Vector3(0.23,0.65,0.31),Vector3(-8.8+i*0.34,3,7.03),brass)
 if tier>=2:
  for x in [-8.0,8.0]:
   for j in 3:
    var z=-5.0+j*1.3
    Models.cylinder(details,0.25,0.38,Vector3(x,1.05,z),Color("eab77d") if j%2==0 else Color("df8e9a"),0.14)
 if tier>=3 and not city:
  Models.box(details,Vector3(1.8,1.4,3.3),Vector3(7.7,1.2,-5.2),Color("bf9361"))
  for y in [0.9,1.6]: Models.box(details,Vector3(1.84,0.12,3.35),Vector3(7.7,y,-5.2),Color("e4c58b"))
 if tier>=4 and not city:
  # Enlarged rear service canopy leaves tools, delivery lanes and stock visible.
  for x in [-8.0,8.0]: Models.box(details,Vector3(0.35,6,0.35),Vector3(x,3.5,-7.6),Color("436e66"))
  Models.box(details,Vector3(17.6,0.3,4.3),Vector3(0,6.55,-8.8),Color("487f77"))
 if tier>=5:
  var height=float(root.get_meta("height",7.0))
  if not city: height=6.8
  for x in [-5.8,5.8]:
   Models.box(details,Vector3(2.5,0.17,1.5),Vector3(x,height,-8.8),Color("35647b"))
   Models.box(details,Vector3(2.7,0.12,0.15),Vector3(x,height+0.1,-7.98),brass)
  Models.box(details,Vector3(2.3,0.16,0.4),Vector3(-8.1,3.85,7),brass)
 # Stylized contact shading works on GL ES without screen-space AO passes.
 Models.box(details,Vector3(15.8,0.035,0.7),Vector3(0,0.68 if city else 0.46,-10.1),Color("6d7966"))
 Models.box(details,Vector3(0.65,0.035,18.8),Vector3(-8.6,0.68 if city else 0.46,-0.6),Color("71846d"))
 if kind in ["house","landhouse","villa","cabin"]:
  var top=float(root.get_meta("height",7))
  var chimney_at=Vector3(-4.5,top-1.6,-3)
  Models.box(details,Vector3(0.85,1.8,0.85),chimney_at,Color("b18c73"))
  Models.box(details,Vector3(1.05,0.16,1.05),chimney_at+Vector3(0,1,0),Color("51635c"))
  var chimney=load("res://Components/ChimneySmoke.gd").new()
  chimney.name="ChimneySmoke"
  chimney.position=chimney_at+Vector3(0,1.1,0)
  root.add_child(chimney)
