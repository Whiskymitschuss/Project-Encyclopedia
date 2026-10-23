extends RefCounted

static func create(kind: String,level: int) -> Node3D:
 var central=kind=="central_depot"
 var root=Node3D.new()
 root.set_meta("kind",kind)
 WoodYard.decorate(root,kind)
 root.set_meta("height",7.5)
 var width=31.0 if central else 19.0
 var floor_mesh=Models.paving_box(root,Vector3(width,0.16,23),Vector3(0,0.46,0),ProductionCampus.CONCRETE,"plaster",0.8)
 floor_mesh.name="FactoryFloor"
 floor_mesh.set_meta("animated",true)
 var blue=Color("328dd2") if central else Color("eea642")
 # Open loading hall: racks at rear, unobstructed two-way aisle in front.
 for x in [-width/2+1,width/2-1]:
  Models.box(root,Vector3(0.4,6,0.4),Vector3(x,3.5,-7.5),blue)
 Models.box(root,Vector3(width-1,0.5,7),Vector3(0,6.7,-7.8),blue)
 Models.box(root,Vector3(width-1,4.8,0.3),Vector3(0,2.9,-10.5),Color("fff5df"))
 for x in range(-int(width/2)+3,int(width/2)-1,5):
  for y in [1.0,3.0]:
   Models.box(root,Vector3(3.8,0.18,2.4),Vector3(x,y,-8),blue)

  for side in [-2,2]: Models.box(root,Vector3(0.15,4,0.2),Vector3(x+side,2.5,-8),blue)
 for side in [-1,1]:
  for z in [-3,0,3,6]: Models.box(root,Vector3(0.18,0.025,1.8),Vector3(side*(width/2-1),0.585,z),Color("ffda4c"))
 # The shared turquoise/gold bays already mark parking and unloading here.
 var sign_board=Models.box(root,Vector3(width-3,1.0,0.25),Vector3(0,5.4,-4.2),blue)
 var label=Models.label(root,"ZENTRALLAGER" if central else "ABHOL · EXPRESS",Vector3(0,5.4,-3.95),24)
 label.billboard=BaseMaterial3D.BILLBOARD_DISABLED
 label.no_depth_test=false
 label.pixel_size=0.014 if central else 0.012
 label.outline_size=0
 label.modulate=Color("ffffff")
 for i in (2 if central else 1):
  var handler=load("res://Components/YardHandling.gd").new()
  handler.name="DepotHandler%s" % i
  handler.depot_handler=true
  handler.handler_lane=i
  handler.handler_lanes=2 if central else 1
  handler.points=[Vector3(-7 if i==0 else 7,0.6,-4),Vector3(-7 if i==0 else 7,0.6,3),Vector3(-4 if i==0 else 4,0.6,6),Vector3(-7 if i==0 else 7,0.6,3),Vector3(-7 if i==0 else 7,0.6,-4)]
  root.add_child(handler)
 var stock=load("res://Components/DepotStock.gd").new()
 stock.name="DepotStock"
 root.add_child(stock)
 InfrastructureEvolution.add_to(root,kind,level)
 Models.bake(root)
 return root
