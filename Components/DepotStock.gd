extends Node3D
var building_index=-1
var refresh_clock=0.0
var stacks=[]
func _ready() -> void:
 var width=31.0 if get_parent().get_meta("kind","")=="central_depot" else 19.0
 var count=6 if width>20 else 3
 for i in count:
  var key=["wood","boards","dry","furniture","walls","parts"][i]
  var pile=Node3D.new()
  pile.position=Vector3(-width/2+3+i*(width-6)/maxf(1,count-1),1.2,-8)
  add_child(pile)
  if key=="wood":
   for side in [-0.65,0.65]:
    var log=Models.cylinder(pile,0.55,2.0,Vector3(side,0.6,0),Color("99633a"))
    log.rotation.x=PI/2
  elif key=="furniture":
   Models.box(pile,Vector3(1.8,0.3,1.4),Vector3(0,0.7,0),Color("dfb16a"))
   Models.box(pile,Vector3(1.8,1.1,0.2),Vector3(0,1.25,-0.6),Color("dfb16a"))
   for side in [-0.65,0.65]: Models.box(pile,Vector3(0.2,0.7,1.1),Vector3(side,0.35,0),Color("a67644"))
  else:
   for layer in 3: Models.box(pile,Vector3(2.7,0.25,1.7),Vector3(0,0.2+layer*0.3,0),Color("d7a567") if key in ["boards","dry"] else Color("b7bec3"))
  Models.bake(pile)
  pile.hide()
  stacks.append({"key":key,"node":pile})
func _process(delta: float) -> void:
 refresh_clock+=delta
 if refresh_clock<0.5: return
 refresh_clock=0
 if building_index<0 or building_index>=Game.state.buildings.size(): return
 var central=Game.state.buildings[building_index].kind=="central_depot"
 var stock=Game.state.resources if central else Game.state.hub.express.get(str(building_index),{})
 for entry in stacks:
  var amount=float(stock.get(entry.key,0))+(float(Game.state.hub.get("receiving",{}).get(entry.key,0)) if central else 0)
  entry.node.visible=amount>0.00001
  entry.node.scale.y=0.65+0.35*clampf(amount/24,0,1)
