class_name WorkTools
extends RefCounted

static func ladder(parent: Node3D,height: float=4.6) -> Node3D:
 var model=Node3D.new()
 parent.add_child(model)
 for x in [-0.48,0.48]: Models.box(model,Vector3(0.12,height,0.14),Vector3(x,height/2,0),Color("d5e1dc"))
 for i in floori(height/0.4): Models.box(model,Vector3(0.95,0.11,0.16),Vector3(0,0.25+i*0.4,0),Color("8fa9ac"))
 Models.bake(model)
 return model

static func toolbox(parent: Node3D) -> Node3D:
 var model=Node3D.new()
 parent.add_child(model)
 Models.box(model,Vector3(0.95,0.55,0.48),Vector3.ZERO,Color("e6963d"))
 Models.box(model,Vector3(0.98,0.13,0.5),Vector3(0,0.27,0),Color("405f70"))
 Models.box(model,Vector3(0.5,0.12,0.14),Vector3(0,0.5,0),Color("405f70"))
 for x in [-0.22,0.22]: Models.box(model,Vector3(0.09,0.18,0.12),Vector3(x,0.4,0),Color("405f70"))
 Models.bake(model)
 return model
