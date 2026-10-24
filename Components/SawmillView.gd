extends "res://Components/ProductionMachine.gd"
var lanes=[]
func _ready() -> void:
 particles=FeedbackFX.emitter("chips",8)
 particles.position=Vector3(0,2.2,0); particles.name="ProductionFeedback"; add_child(particles)
 for i in 3:
  var node=get_node("Line%s" % i)
  var owner=self if i==0 else node
  lanes.append({"node":node,"feed":owner.get_node("Feed"),"saw_stock":owner.get_node("SawStock"),"product":owner.get_node("Product"),"debarker":node.get_node("Debarker"),"rotor":owner.get_node("Rotor"),"planer":owner.get_node("ToolHead" if i==0 else "Planer"),"operator":node.get_node("Operator")})
 # Existing inspectors use the primary station handles.
 pieces={"Feed":lanes[0].feed,"Product":lanes[0].product,"Rotor":lanes[0].rotor,"ToolHead":lanes[0].planer}
func _process(delta: float) -> void:
 if building_index<0 or building_index>=Game.state.buildings.size(): return
 detail_clock+=delta; stock_clock+=delta
 if detail_clock>=0.25: detail_clock=0; detail_visible=PresentationBudget.detailed(self)
 if stock_clock>=(0.5 if detail_visible else 1.0): stock_clock=0; refresh_stock()
 var count=SawmillProduction.line_count(Game.state,building_index)
 var data=Game.state.sawmills.sites.get(str(building_index),{})
 var suspended=Game.state.buildings[building_index].get("paused",false) or (Game.delivery_owns(building_index) and Game.state.delivery.paused)
 active=not suspended and (float(Game.flow.get("building:%s" % building_index,0))>0)
 particles.visible=active and detail_visible and FeedbackFX.allowed(self)
 particles.emitting=active and particles.visible
 if not detail_visible:
  skipped_updates+=1; animation_clock=0
  for lane in lanes:
   lane.feed.hide(); lane.saw_stock.hide(); lane.product.hide()
  return
 animation_clock+=delta
 if animation_clock<(0.1 if Game.state.quality==0 or RuntimeStats.low_detail else 1.0/30): return
 delta=animation_clock; animation_clock=0; detail_updates+=1
 var interpolate=clampf(Game.tick_clock,0,0.99) if Game.state.ux.motion else 0.3
 for i in lanes.size():
  var view=lanes[i]
  view.node.visible=i<count
  view.operator.visible=detail_visible and i<count
  var queue=data.get("lanes",[])[i].queues if i<data.get("lanes",[]).size() else [0.0,0.0,0.0]
  var work=data.get("lanes",[])[i].work if i<data.get("lanes",[]).size() else [0.0,0.0,0.0]
  view.feed.visible=i<count and float(queue[0])>0
  view.saw_stock.visible=i<count and float(queue[1])>0
  view.product.visible=i<count and float(queue[2])>0
  view.feed.position.z=lerpf(-6.5,-4.3,interpolate if not suspended and float(work[0])>0 else 0.3)
  view.saw_stock.position.z=lerpf(-1.2,1.1,interpolate if not suspended and float(work[1])>0 else 0.3)
  var progress=interpolate if not suspended and float(work[2])>0 else 0.2
  var base_x=float(view.node.position.x)
  view.product.position.x=0.0
  view.product.rotation.y=0
  if progress<0.5: view.product.position.z=lerpf(3.6,8,progress/0.5)
  elif progress<0.88:
   view.product.position.z=8; view.product.position.x=lerpf(0,6.3-base_x,(progress-0.5)/0.38); view.product.rotation.y=PI/2
  else:
   view.product.position.x=6.3-base_x; view.product.position.z=lerpf(8,5.5,(progress-0.88)/0.12)
  if suspended or not Game.state.ux.motion: continue
  if float(work[0])>0: view.debarker.rotation.z+=delta*4
  if float(work[1])>0: view.rotor.rotation.x+=delta*12
  if float(work[2])>0: view.planer.rotation.x+=delta*6
  for side in ["LeftArm","RightArm"]:
   view.operator.get_node(side).rotation.x=-0.6+sin((float(Game.state.elapsed)+Game.tick_clock)*4)*0.2 if work.any(func(value): return float(value)>0) else 0.0
