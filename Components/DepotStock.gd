extends Node3D
var building_index=-1
var refresh_clock=0.0
var stacks=[]
var width=31.0
var slots=6
func _ready() -> void:
 width=31.0 if get_parent().get_meta("kind","")=="central_depot" else 19.0
 slots=6 if width>20 else 3
 var keys=["wood","boards","dry","furniture","walls","parts"]
 for key in Catalog.RESOURCES:
  if key not in keys: keys.append(key)
 # All SKUs have reusable meshes. Only the occupied visible rack slots draw;
 # a changing quantity never regenerates geometry on the simulation thread.
 for key in keys:
  var pile=CargoModels.create(self,str(key))
  pile.hide()
  stacks.append({"key":key,"node":pile})
func _process(delta: float) -> void:
 refresh_clock+=delta
 if refresh_clock<0.5: return
 refresh_clock=0
 if building_index<0 or building_index>=Game.state.buildings.size(): return
 var central=Game.state.buildings[building_index].kind=="central_depot"
 var stock=Game.state.resources if central else Game.state.hub.express.get(str(building_index),{})
 var occupied=[]
 for entry in stacks:
  entry.node.hide()
  entry.amount=float(stock.get(entry.key,0))+(float(Game.state.hub.get("receiving",{}).get(entry.key,0)) if central else 0)
  if float(entry.amount)>0.00001: occupied.append(entry)
 occupied.sort_custom(func(a,b): return float(a.amount)>float(b.amount) if not is_equal_approx(float(a.amount),float(b.amount)) else str(a.key)<str(b.key))
 for i in mini(slots,occupied.size()):
  var entry=occupied[i]
  entry.node.show()
  entry.node.position=Vector3(-width/2+3+i*(width-6)/maxf(1,slots-1),1.2,-8)
  entry.node.scale.y=0.65+0.35*clampf(float(entry.amount)/24,0,1)
