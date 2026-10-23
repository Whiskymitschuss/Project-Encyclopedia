class_name CargoModels
extends RefCounted

static func create(parent: Node3D,key: String) -> Node3D:
 var root=Node3D.new()
 root.set_meta("resource",key)
 parent.add_child(root)
 for x in [-0.9,0,0.9]: Models.box(root,Vector3(0.2,0.18,1.8),Vector3(x,0.1,0),Color("9c784d"))
 Models.box(root,Vector3(2.7,0.12,1.9),Vector3(0,0.24,0),Color("d5aa69"))
 match key:
  "wood":
   for x in [-0.65,0,0.65]:
    var log=Models.cylinder(root,0.34,2.2,Vector3(x,0.63,0),Color("99633a"))
    log.rotation.x=PI/2
  "furniture","design":
   var finish=Color("dca966") if key=="furniture" else Color("579ca6")
   Models.box(root,Vector3(1.8,0.25,1.4),Vector3(0,1.0,0),finish)
   Models.box(root,Vector3(1.8,1.2,0.25),Vector3(0,1.6,-0.6),finish)
   for x in [-0.65,0.65]:
    for z in [-0.45,0.45]: Models.box(root,Vector3(0.18,0.7,0.18),Vector3(x,0.62,z),Color("956d42"))
  "boards","dry":
   for y in 3:
    for x in [-0.65,0.65]: Models.box(root,Vector3(1.2,0.22,1.7),Vector3(x,0.4+y*0.26,0),Color("d6a45f") if key=="boards" else Color("efca83"))
  "walls":
   for i in 3:
    Models.box(root,Vector3(2.35,0.2,1.7),Vector3(0,0.45+i*0.25,0),Color("8cb9a7"))
    Models.box(root,Vector3(2.4,0.22,0.12),Vector3(0,0.45+i*0.25,0.8),Color("cfac73"))
  "roofs":
   for i in 3:
    for side in [-1,1]:
     var tile=Models.box(root,Vector3(1.2,0.16,1.7),Vector3(side*0.52,0.6+i*0.3,0),Color("bc7854"))
     tile.rotation.z=side*-0.22
  "parts":
   for i in 3:
    Models.box(root,Vector3(2.4,0.25,0.35),Vector3(0,0.45+i*0.3,-0.55),Color("cca263"))
    Models.box(root,Vector3(2.4,0.25,0.35),Vector3(0,0.45+i*0.3,0.55),Color("cca263"))
  "paper":
   for i in 3:
    Models.box(root,Vector3(2.2,0.35,1.5),Vector3(0,0.5+i*0.4,0),Color("f0e4c7"))
    Models.box(root,Vector3(0.18,0.38,1.54),Vector3(0,0.5+i*0.4,0),Color("6a9eab"))
  "pellets":
   for x in [-0.6,0.6]:
    Models.cylinder(root,0.52,1.2,Vector3(x,0.9,0),Color("dac59d"),0.35)
    Models.box(root,Vector3(0.6,0.12,0.2),Vector3(x,1.52,0),Color("a69c70"))
  "stone":
   for y in 2:
    for x in [-0.62,0.62]: Models.box(root,Vector3(1.15,0.5,1.5),Vector3(x,0.6+y*0.55,0),Color("c6c6b4"))
  "rock","gravel":
   for i in 6: Models.cylinder(root,0.4+(i%2)*0.1,0.6,Vector3((i%3-1)*0.7,0.65+(i/3)*0.25,(i%2-0.5)*0.8),Color("b2a68a"),0.15)
  _:
   for x in [-1.15,1.15]: Models.box(root,Vector3(0.12,0.8,1.7),Vector3(x,0.7,0),Color("b9915e"))
   for z in [-0.8,0.8]: Models.box(root,Vector3(2.3,0.8,0.12),Vector3(0,0.7,z),Color("c4a270"))
   for i in 4:
    var item=Models.cylinder(root,0.16 if key=="screws" else 0.3,0.65 if key=="screws" else 0.22,Vector3((i%2-0.5)*0.9,0.8,(i/2-0.5)*0.6),Color("8da1a5") if key in ["nuts","screws"] else Color("b79862"))
    item.rotation.z=PI/2 if key=="screws" else 0
 Models.bake(root)
 return root
