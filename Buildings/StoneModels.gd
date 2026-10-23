extends RefCounted

static func create(kind: String, level: int) -> Node3D:
 var root=Node3D.new()
 root.set_meta("open_factory",true)
 root.set_meta("kind",kind)
 var quarry=kind=="quarry"
 Models.box(root,Vector3(19,0.35,23),Vector3(0,0.2,0),Color("c7b88d") if quarry else Color("b0c3bc"))
 for x in [-9,9]:
  Models.box(root,Vector3(0.18,0.2,22),Vector3(x,0.45,0),Color("fff0bd"))
  for z in [-10,-6,-2,2,6,10]:
   Models.box(root,Vector3(0.22,1.3,0.22),Vector3(x,1.05,z),Color("738d87"))
 for z in [-10.5,10.5]: Models.box(root,Vector3(18,0.12,0.3),Vector3(0,0.45,z),Color("edc46c"))
 var stock=Node3D.new()
 stock.name="Stock"
 stock.set_meta("animated",true)
 root.add_child(stock)
 stock.position=Vector3(5.7,0.5,4)
 if quarry:
  var face=Node3D.new()
  face.name="RockFace"
  face.set_meta("animated",true)
  root.add_child(face)
  for i in 8:
   var rock=Models.cylinder(face,1.1+(i%3)*0.2,2.2+(i%2),Vector3(-6+(i%4)*3.2,1.5+(i%2)*0.3,-7.8+(i/4)*2),Color("a89e83").lightened((i%3)*0.04),0.7)
   rock.rotation.y=i*0.7
  Models.bake(face)
  var excavator=load("res://Vehicles/QuarryExcavator.gd").new()
  excavator.name="Excavator"
  excavator.position=Vector3(-2,0.5,-0.4)
  root.add_child(excavator)
  stock.position=Vector3(0,0.5,3)
  Models.box(root,Vector3(4,1.1,5),Vector3(0,0.9,3),Color("727d76"))
  Models.box(root,Vector3(3.7,0.15,4.7),Vector3(0,1.5,3),Color("ab9b72"))
  for i in 6: Models.cylinder(stock,0.85,1.2,Vector3((i%2)*1.1-0.5,1+(i/2)*0.25,(i%3)*0.9-0.9),Color("b9ae90"),0.4)
 else:
  Models.box(root,Vector3(5.5,3.3,5),Vector3(-1,2.2,-3),Color("e5954d"))
  Models.box(root,Vector3(4.7,0.4,4.3),Vector3(-1,4,-3),Color("f8d077"))
  Models.cylinder(root,2,1.8,Vector3(-1,4.8,-3),Color("62898e"),2.7)
  Models.box(root,Vector3(2.3,1.3,2.5),Vector3(-1,1.5,1),Color("b8ccc3"))
  var rotor=Models.cylinder(root,1.25,0.5,Vector3(-1,2.6,-0.3),Color("547787"))
  rotor.rotation.z=PI/2
  rotor.name="Rotor"
  rotor.set_meta("animated",true)
  Models.box(root,Vector3(1.5,1.4,1.1),Vector3(-5,1.4,0),Color("328f9b"))
  Models.box(root,Vector3(1.2,0.6,0.1),Vector3(-5,2.2,0.6),Color("95e7c9"))
  Models.box(root,Vector3(5,0.35,4.5),Vector3(5.8,0.6,4),Color("8b7856"))
  var stones=Node3D.new()
  stones.name="StonePile"
  stock.add_child(stones)
  stones.position.x=-1
  stones.scale.x=0.75
  for y in 3:
   for x in 2:
    for z in 3: Models.box(stones,Vector3(1.8,0.65,1),Vector3((x-0.5)*1.9,0.55+y*0.7,z*1.1-1.1),Color("d5ccb1"))
  Models.bake(stones)
  var gravel=Node3D.new()
  gravel.name="GravelPile"
  stock.add_child(gravel)
  gravel.position.x=1.8
  for i in 6: Models.cylinder(gravel,0.65,1.0,Vector3((i%2-0.5)*0.7,0.65+(i%2)*0.2,(i/2-1)*0.75),Color("bfad7d"),0.3)
  Models.bake(gravel)
  var input=Node3D.new()
  input.name="InputStock"
  input.set_meta("animated",true)
  root.add_child(input)
  input.position=Vector3(-6,0.6,-6)
  for i in 5: Models.cylinder(input,0.9,1.3,Vector3(i%2,0.8,(i/2)*0.6),Color("aca38b"),0.3)
  Models.bake(input)
 InfrastructureEvolution.add_to(root,kind,level)
 Models.bake(stock)
 var controller=load("res://Components/StonePlant.gd").new()
 controller.name="StonePlant"
 root.add_child(controller)
 CraftedFrontage.decorate(root,kind,level,false)
 Models.bake(root)
 return root
