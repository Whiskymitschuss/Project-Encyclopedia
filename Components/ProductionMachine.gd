extends Node3D

var kind="sawmill"
var input_key="wood"
var output_key="boards"
var building_index=-1
var phase=0.0
var active=false
var animation_time=0.0
var stock_clock=0.0
var particles: CPUParticles3D

func _ready() -> void:
 particles=FeedbackFX.emitter("steam" if kind=="kiln" else "chips",12)
 particles.name="ProductionFeedback"
 particles.position=Vector3(1.8,8.6,-1) if kind=="kiln" else Vector3(0,2.7,0)
 particles.spread=22 if kind=="kiln" else 70
 add_child(particles)

func _process(delta: float) -> void:
 if building_index<0 or building_index>=Game.state.buildings.size(): return
 var local_line=Game.delivery_owns(building_index)
 var stock=Game.state.delivery.buffers[kind] if local_line else FactorySupply.stock(Game.state,building_index) if FactorySupply.managed(Game.state,building_index) else Game.state.resources
 var actual_input="boards" if local_line and kind=="furniture" else input_key
 var rate=float(Game.flow.get("building:%s" % building_index,0))
 active=rate>0 and not Game.state.buildings[building_index].get("paused",false)
 var animate=active and bool(Game.state.ux.motion)
 if particles!=null:
  if kind=="kiln": Atmosphere.drift(particles,Game.state)
  var enabled=active and FeedbackFX.allowed(self)
  var count=5 if Game.state.quality==0 else 12
  if particles.amount!=count: particles.amount=count
  particles.visible=enabled
  particles.emitting=enabled
 if animate:
  animation_time+=delta
  phase=fmod(phase+delta*clampf(rate*0.65,0.15,1.5),1.0)
 var feed=get_node_or_null("Feed")
 if feed!=null:
  feed.visible=phase<0.56 and (active or float(stock.get(actual_input,0))>0)
  feed.position=Vector3(0,2.6 if kind=="sawmill" else 2.0,lerpf(-6,-0.3,minf(phase/0.56,1)))
 var product=get_node_or_null("Product")
 if product!=null:
  product.visible=phase>=0.56
  product.position=Vector3(0,1.9,lerpf(2.1,7.2,clampf((phase-0.56)/0.44,0,1)))
 var rotor=get_node_or_null("Rotor")
 if rotor!=null and animate: rotor.rotation.x+=delta*12
 var tool=get_node_or_null("ToolHead")
 if tool!=null:
  if kind=="kiln": tool.position.y=2.6+(1-cos(animation_time*1.8))*1.4
  elif kind in ["furniture","design","joinery","prefab"]:
   tool.position.x=sin(animation_time*2.3)*1.7
  else: tool.position.y=2.5+sin(animation_time*3)*0.35
 stock_clock+=delta
 if stock_clock>=0.5:
  stock_clock=0
  var root=get_parent()
  for entry in [["InputStock",input_key],["OutputStock",output_key]]:
   var pile=root.get_node_or_null(entry[0])
   if pile!=null:
    var pile_stock=Game.state.hub.outputs.get(str(building_index),{}) if entry[0]=="OutputStock" and not local_line and CentralLogistics.active(Game.state) else stock
    var amount=float(pile_stock.get(actual_input if entry[0]=="InputStock" else entry[1],0))
    pile.visible=amount>=0.5
    pile.scale.y=0.55+0.45*clampf(amount/50.0,0,1)
