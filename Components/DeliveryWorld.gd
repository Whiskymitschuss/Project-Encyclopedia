extends Node3D

var world: Node3D
var badges: Array = []
var visuals: Dictionary = {}
var visual_pool: Dictionary = {}
var overlay: Control
var clock = 0.0
var truck_visual_count = 0

func _ready() -> void:
 overlay = Control.new()
 overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
 world.hud.add_child(overlay)
 Game.changed.connect(refresh_badges)
 rebuild()

func rebuild() -> void:
 for child in get_children(): child.queue_free()
 for item in badges: item.button.queue_free()
 badges.clear()
 visuals.clear()
 visual_pool.clear()
 if Game.state.delivery.active:
  for kind in DeliveryChain.KINDS:
   var index = int(Game.state.delivery.nodes[kind])
   make_badge(kind,index,-1)
 for i in Game.state.buildings.size():
  if Game.state.buildings[i].kind in StoneIndustry.KINDS: make_badge("mineral",i,-1)
 for i in Game.state.jobs.size():
  if not Game.state.jobs[i].get("materials",{}).is_empty(): make_badge("construction",-1,i)
 refresh_badges()

func make_badge(kind: String, index: int, job_index: int) -> void:
 var button = Button.new()
 button.custom_minimum_size = Vector2(82,42)
 button.size = Vector2(82,42)
 button.focus_mode = Control.FOCUS_NONE
 var content = HBoxContainer.new()
 content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 content.offset_left = 7
 content.offset_right = -5
 content.mouse_filter = Control.MOUSE_FILTER_IGNORE
 var icon = TextureRect.new()
 icon.custom_minimum_size = Vector2(29,29)
 icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
 content.add_child(icon)
 var label = Label.new()
 label.add_theme_font_size_override("font_size",16)
 label.add_theme_color_override("font_color",Color("fff8e6"))
 label.mouse_filter = Control.MOUSE_FILTER_IGNORE
 content.add_child(label)
 button.add_child(content)
 var output_icon = TextureRect.new()
 var output_label = Label.new()
 if kind in ["sawmill","furniture"]:
  button.custom_minimum_size=Vector2(96,54)
  button.size=Vector2(96,54)
  content.offset_bottom=-27
  var output=HBoxContainer.new()
  output.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  output.offset_left=7
  output.offset_right=-5
  output.offset_top=27
  output.mouse_filter=Control.MOUSE_FILTER_IGNORE
  output_icon.custom_minimum_size=Vector2(24,24)
  output_icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
  output_icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  output_icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
  output.add_child(output_icon)
  output_label.add_theme_font_size_override("font_size",14)
  output_label.add_theme_color_override("font_color",Color("fff8e6"))
  output_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
  output.add_child(output_label)
  button.add_child(output)
 else:
  output_icon.free()
  output_label.free()
 button.pressed.connect(func():
  if kind=="construction":
   if job_index<Game.state.jobs.size(): world.hud.ux.select_job(int(Game.state.jobs[job_index].get("id",-1)))
  else: world.hud.ux.select_building(index))
 overlay.add_child(button)
 badges.append({"kind":kind,"index":index,"job":job_index,"button":button,"icon":icon,"label":label,"output_icon":output_icon if kind in ["sawmill","furniture"] else null,"output_label":output_label if kind in ["sawmill","furniture"] else null,"at":Vector3.ZERO})

func refresh_badges() -> void:
 for b in badges:
  var info: Dictionary
  if b.kind=="construction":
   if b.job>=Game.state.jobs.size(): b.button.hide(); continue
   var job = Game.state.jobs[b.job]
   info = {"key":"boards","amount":0,"need":1,"ready":ConstructionRules.ready(job),"empty":false,"full":false}
   for key in job.materials:
    info.key = key
    info.amount = float(job.get("delivered",{}).get(key,0))
    info.need = float(job.materials[key])
    if ConstructionRules.remaining(job,key)>0: break
   b.at = world.job_position(job)+Vector3(0,9,0)
   b.button.tooltip_text = ConstructionRules.status(job)
  elif b.kind=="mineral":
   var data=StoneIndustry.site(Game.state,b.index)
   if data.is_empty(): b.button.hide(); continue
   var quarry=Game.state.buildings[b.index].kind=="quarry"
   var product="stone" if data.recipe=="blocks" else "gravel"
   var full=not quarry and float(data.stock[product])>=StoneIndustry.capacity(Game.state,b.index)-4
   var key="rock" if quarry or not full else product
   var amount=float(data.stock[key])
   var need=int(StoneIndustry.capacity(Game.state,b.index)) if quarry or full else 3
   info={"key":key,"amount":amount,"need":need,"ready":amount>=need,"empty":amount<1,"full":full}
   b.at=Game.building_position(b.index)+Vector3(0,9,0)
   b.button.tooltip_text=StoneIndustry.status(Game.state,b.index)
  else:
   info = DeliveryChain.status(Game.state,b.kind)
   b.at = Game.building_position(b.index)+Vector3(0,9,0)
   b.button.tooltip_text = Catalog.BUILDINGS[b.kind].name+" · "+info.text
  b.icon.texture = load("res://Assets/Resources/%s.svg" % info.key) if ResourceLoader.exists("res://Assets/Resources/%s.svg" % info.key) else load("res://Assets/Resources/boards.svg")
  b.label.text = "%s/%s" % [int(info.amount),int(info.need)]
  if b.output_icon!=null:
   b.output_icon.texture=load("res://Assets/Resources/%s.svg" % info.output_key)
   b.output_label.text="→ %s/%s" % [int(info.output_amount),int(info.output_capacity)]
  var color = Color("42a77c") if info.ready else Color("bd624c") if info.empty else Color("c28c36")
  if info.full: color = Color("42a77c")
  if Game.state.delivery.get("paused",false) and b.kind!="construction": color = Color("667e85")
  b.button.add_theme_stylebox_override("normal",load("res://UI/SculptedSurface.gd").create(color,12))

func _process(delta: float) -> void:
 clock += delta
 if clock>=0.5: clock=0; refresh_badges()
 var occupied: Array[Rect2] = []
 if world.hud.get("ux")!=null:
  var ux=world.hud.ux
  for control in [ux.event_button,ux.sheet,ux.palette]:
   if control.visible: occupied.append(control.get_global_rect())
 var priority_count=0
 for b in badges:
  b.button.visible = not world.hud.overlay.visible and world.placement.is_empty() and world.view_zoom<260 and not world.camera.is_position_behind(b.at)
  var selected=world.hud.ux.selection
  var chosen=(selected.get("kind","")=="building" and int(selected.get("index",-2))==int(b.index)) or (b.kind=="construction" and selected.get("kind","")=="job" and b.job<Game.state.jobs.size() and int(Game.state.jobs[b.job].get("id",-2))==int(selected.get("id",-1)))
  if world.view_zoom>=105 and not chosen:
   if priority_count>=3: b.button.visible=false
   if b.button.visible: priority_count+=1
  if not b.button.visible: continue
  var extent: Vector2=b.button.size
  var p = world.camera.unproject_position(b.at)-Vector2(extent.x/2,extent.y-4)
  var rect = Rect2(p,extent)
  if p.x<4 or p.x+extent.x>world.hud.size.x-4 or p.y<170 or p.y+extent.y>world.hud.size.y-190: b.button.hide(); continue
  for previous in occupied:
   if rect.intersects(previous): b.button.hide(); break
  if not b.button.visible: continue
  occupied.append(rect)
  b.button.position = p
 truck_visual_count = 0
 var present = {}
 var shipments = Game.state.delivery.shipments+Game.state.construction_shipments+Game.state.stone.shipments+Game.state.trade.shipments
 for shipment in shipments:
  var id = visual_key(shipment)
  present[id] = true
  var signature = "truck:"+str(shipment.key)+":"+str(Game.state.vehicle)
  if visuals.has(id) and str(visuals[id].get_meta("pool_key"))!=signature:
   var old=visuals[id]
   var old_key=str(old.get_meta("pool_key"))
   old.hide()
   if not visual_pool.has(old_key): visual_pool[old_key]=[]
   if visual_pool[old_key].size()<4: visual_pool[old_key].append(old)
   else: old.queue_free()
   visuals.erase(id)
  if not visuals.has(id) and visual_pool.has(signature) and not visual_pool[signature].is_empty():
   visuals[id]=visual_pool[signature].pop_back()
   visuals[id].show()
  if not visuals.has(id):
   var node: Node3D
   node = load("res://Vehicles/DumpTruck.gd").new() if shipment.key in ["rock","gravel"] else TimberTruck.new()
   node.tier = maxi(2,int(Game.state.vehicle))
   node.cargo_furniture = shipment.key=="furniture"
   node.cargo_boxes = shipment.key not in ["wood","boards","furniture"]
   node.cargo_boards = shipment.key=="boards"
   node.cargo_stone = shipment.key=="stone"
   node.road_freight = true
   add_child(node)
   node.set_meta("pool_key",signature)
   var cargo_label=Label3D.new()
   cargo_label.layers=Models.WORLD_LABEL_LAYER
   cargo_label.name="RouteLabel"
   cargo_label.position=Vector3(0,7,0)
   cargo_label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
   cargo_label.font_size=32
   cargo_label.pixel_size=0.065
   cargo_label.outline_size=5
   cargo_label.no_depth_test=true
   node.add_child(cargo_label)
   visuals[id] = node
  var node: Node3D = visuals[id]
  var running = float(shipment.get("depart_in",0))<=0
  node.visible=running
  var age = float(shipment.age)+minf(Game.tick_clock,0.99) if running else float(shipment.age)
  if not shipment.arrived: age=minf(age,float(shipment.travel)-0.000001)
  var progress = clampf(age/float(shipment.travel),0,1)
  var returning = false
  if shipment.has("drive"):
   progress=clampf((age-float(shipment.get("load",0)))/float(shipment.drive),0,1)
   if age>=float(shipment.travel):
    returning=true
    progress=1-clampf((age-float(shipment.travel))/float(shipment.drive),0,1)
  elif age>float(shipment.travel)+2:
   returning=true
   progress = 1-clampf((age-float(shipment.travel)-2)/float(shipment.travel),0,1)
  var sample = LogisticsRoutes.sample(shipment.path,progress)
  node.position = sample.position
  var direction = -sample.direction if returning else sample.direction
  node.follow_heading(direction,delta)
  node.position+=Vector3(direction.z,0,-direction.x)*1.5
  truck_visual_count += 1
  if running and progress>0 and progress<1:
   for wheel in node.wheels: wheel.rotate_object_local(Vector3.UP,delta*6)
  if node.cargo!=null: node.cargo.visible = not shipment.arrived
  var cargo_stage=CargoTransfer.apply(Game,node,shipment,age)
  var cargo_label: Label3D=node.get_node("RouteLabel")
  var selected=world.hud.ux.selection
  var focused=selected.get("kind","")=="truck" and (str(selected.get("domain",""))+":"+str(selected.get("id",-1)))==str(id)
  cargo_label.visible=node.visible and (world.view_zoom<80 or focused)
  var destination="Bau" if shipment.target=="construction" else ("Lager" if int(shipment.destination)<0 else "Steinwerk") if shipment.target=="mineral" else "Autobahn" if shipment.target=="export" else Catalog.BUILDINGS[shipment.target].name
  cargo_label.text="LEER · zurück" if shipment.arrived else "%s %s → %s" % [int(shipment.amount),Catalog.RESOURCES[shipment.key],destination]
  if cargo_stage=="load": cargo_label.text="BELADEN · "+cargo_label.text
  elif cargo_stage=="unload": cargo_label.text="ENTLADEN · "+cargo_label.text
  cargo_label.modulate=Color("c9e5dc") if shipment.arrived else Color("fff2bf")
  if node.get("bed")!=null:
   node.tipping=-0.55 if age>=float(shipment.load)+float(shipment.drive) and age<float(shipment.travel) and float(shipment.age)<float(shipment.travel) else 0.0
 for id in visuals.keys():
  if not present.has(id):
   var node=visuals[id]
   var key=str(node.get_meta("pool_key"))
   node.hide()
   if not visual_pool.has(key): visual_pool[key]=[]
   if visual_pool[key].size()<4: visual_pool[key].append(node)
   else: node.queue_free()
   visuals.erase(id)

func visual_key(shipment: Dictionary) -> String:
 # Saves retain their original IDs. Separate domains prevent two simultaneous
 # jobs with the same numeric ID from sharing a model or swapping cargo types.
 return "%s:%s" % ["construction" if shipment.target=="construction" else "stone" if shipment.target=="mineral" else "export" if shipment.target=="export" else "wood",int(shipment.id)]

func _exit_tree() -> void:
 if is_instance_valid(overlay): overlay.queue_free()
