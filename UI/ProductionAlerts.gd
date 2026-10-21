extends Node
var world: Node3D
var overlay: Control
var pool=[]
var known={}
var clock=0.0

func _ready() -> void:
 overlay=Control.new()
 overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE
 world.hud.add_child(overlay)
 for i in 3:
  var panel=PanelContainer.new()
  panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
  panel.custom_minimum_size=Vector2(120,32)
  overlay.add_child(panel)
  var label=world.hud.text(panel,"",13,world.hud.CREAM)
  label.mouse_filter=Control.MOUSE_FILTER_IGNORE
  label.autowrap_mode=TextServer.AUTOWRAP_OFF
  pool.append({"panel":panel,"label":label,"index":-1,"left":0.0})
  panel.hide()

func refresh() -> void:
 var current={}
 for i in Game.state.buildings.size():
  var status=ProductionPresentation.describe(Game,i)
  var key=str(status.kind)+":"+str(status.text)
  current[i]=key
  var selected=world.hud.ux.selection.get("kind","")=="building" and int(world.hud.ux.selection.get("index",-1))==i
  if status.kind in ["running","ready"]: continue
  if known.get(i,"")==key and not selected: continue
  var at=Game.building_position(i)+Vector3.UP*10
  if at.distance_to(world.view_focus)>world.view_zoom*1.3+35 or world.camera.is_position_behind(at): continue
  var candidate=null
  for item in pool:
   if item.index==i: candidate=item; break
   if item.left<=0 and candidate==null: candidate=item
  if candidate==null: continue
  candidate.index=i
  candidate.left=4.5
  candidate.label.text=status.text
  var tone={"paused":Color("53686c"),"full":Color("325e72"),"missing":Color("885b30")}[status.kind]
  var skin=world.hud.style(tone,10)
  skin.content_margin_top=5
  skin.content_margin_bottom=5
  skin.content_margin_left=9
  skin.content_margin_right=9
  candidate.panel.add_theme_stylebox_override("panel",skin)
 known=current

func _process(delta: float) -> void:
 clock+=delta
 if clock>=0.5: clock=0; refresh()
 var occupied=[]
 for control in [world.hud.ux.sheet,world.hud.ux.palette,world.hud.ux.event_button,world.hud.camera_controls,world.hud.emergency_button]:
  if control.visible: occupied.append(control.get_global_rect())
 for badge in world.delivery_world.badges:
  if badge.button.visible: occupied.append(badge.button.get_global_rect())
 for i in pool.size():
  var item=pool[i]
  item.left=maxf(0,float(item.left)-delta)
  var show=item.left>0 and not world.hud.overlay.visible and world.placement.is_empty() and (Game.state.quality!=0 or i<2)
  if item.index<0 or item.index>=Game.state.buildings.size(): show=false
  if show:
   var status=ProductionPresentation.describe(Game,int(item.index))
   if status.kind in ["running","ready"]: show=false
  item.panel.visible=show
  if not show: continue
  var at=Game.building_position(int(item.index))+Vector3.UP*10
  var point=world.camera.unproject_position(at)-Vector2(item.panel.size.x/2,0)
  var rect=Rect2(point,item.panel.size)
  if point.x<4 or rect.end.x>world.hud.size.x-4 or point.y<world.hud.mission_button.get_global_rect().end.y+52 or rect.end.y>world.hud.bottom_panel.position.y-8:
   item.panel.hide(); continue
  for other in occupied:
   if rect.intersects(other): item.panel.hide(); break
  if item.panel.visible:
   item.panel.position=point
   occupied.append(rect)

func _exit_tree() -> void:
 if is_instance_valid(overlay): overlay.queue_free()
