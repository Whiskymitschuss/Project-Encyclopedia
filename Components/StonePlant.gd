extends Node3D
var building_index=-1
var active=false
func _process(delta: float) -> void:
 if building_index<0 or building_index>=Game.state.buildings.size(): return
 var data=StoneIndustry.site(Game.state,building_index)
 if data.is_empty(): return
 var root=get_parent()
 var building=Game.state.buildings[building_index]
 active=float(Game.flow.get("building:%s" % building_index,0))>0 and not building.get("paused",false)
 var excavator=root.get_node_or_null("Excavator")
 if excavator!=null:
  excavator.phase_value=int(data.phase)
  var extra=minf(Game.tick_clock,0.99)*(1+(int(building.level)-1)*0.08)*(1+Game.research_level("production")*0.12)*Game.multiplier()*Game.boost("processing") if active else 0.0
  excavator.phase_fraction=(float(data.phase_work)+extra)/float(StoneIndustry.definitions.extraction.phase_seconds[int(data.phase)])
  excavator.loaded=float(data.bucket)>0
  excavator.active=active
 var face=root.get_node_or_null("RockFace")
 if face!=null: face.scale.y=0.2+0.8*clampf(float(data.reserve)/maxf(1,float(data.vein_size)),0,1)
 var pile=root.get_node_or_null("Stock")
 if pile!=null:
  var amount=float(data.stock.rock) if building.kind=="quarry" else float(data.stock.stone)+float(data.stock.gravel)
  pile.visible=amount>0
  pile.scale.y=0.2+0.8*clampf(amount/StoneIndustry.capacity(Game.state,building_index),0,1) if building.kind=="quarry" else 1.0
  for key in ["stone","gravel"]:
   var part=pile.get_node_or_null("StonePile" if key=="stone" else "GravelPile")
   if part!=null:
    part.visible=float(data.stock[key])>0
    part.scale.y=0.2+0.8*clampf(float(data.stock[key])/StoneIndustry.capacity(Game.state,building_index),0,1)
 var input=root.get_node_or_null("InputStock")
 if input!=null: input.visible=float(data.stock.rock)>0
 var rotor=root.get_node_or_null("Rotor")
 if rotor!=null and active: rotor.rotate_object_local(Vector3.UP,delta*9)
