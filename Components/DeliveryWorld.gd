extends Node3D

var world: Node3D
var belt_root: Node3D
var badges: Array = []
var visuals: Dictionary = {}
var visual_pool: Dictionary = {}
var overlay: Control
var clock = 0.0
var truck_visual_count = 0
var belt_visual_count = 0

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
 belt_root = Node3D.new()
 add_child(belt_root)
 if Game.state.delivery.active:
  var drawing = ConveyorNetwork.new()
  belt_root.add_child(drawing)
  for kind in ["sawmill","furniture"]:
   var route = Game.delivery_routes().get(kind,[])
   for i in range(1,route.size()): drawing.deck(LogisticsRoutes.vector(route[i-1]),LogisticsRoutes.vector(route[i]))
  Models.bake(drawing)
  for kind in DeliveryChain.KINDS:
   var index = int(Game.state.delivery.nodes[kind])
   make_badge(kind,index,-1)
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
 button.pressed.connect(func():
  if kind=="construction": world.hud.open_menu("construction")
  else: world.hud.show_building(index))
 overlay.add_child(button)
 badges.append({"kind":kind,"index":index,"job":job_index,"button":button,"icon":icon,"label":label,"at":Vector3.ZERO})

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
  else:
   info = DeliveryChain.status(Game.state,b.kind)
   b.at = Game.building_position(b.index)+Vector3(0,9,0)
   b.button.tooltip_text = Catalog.BUILDINGS[b.kind].name+" · "+info.text
  b.icon.texture = load("res://Assets/Resources/%s.svg" % info.key) if ResourceLoader.exists("res://Assets/Resources/%s.svg" % info.key) else load("res://Assets/Resources/boards.svg")
  b.label.text = "%s/%s" % [int(info.amount),int(info.need)]
  var color = Color("42a77c") if info.ready else Color("bd624c") if info.empty else Color("c28c36")
  if info.full: color = Color("42a77c")
  if Game.state.delivery.get("paused",false) and b.kind!="construction": color = Color("667e85")
  b.button.add_theme_stylebox_override("normal",load("res://UI/SculptedSurface.gd").create(color,12))

func _process(delta: float) -> void:
 clock += delta
 if clock>=0.5: clock=0; refresh_badges()
 var occupied: Array[Rect2] = []
 for b in badges:
  b.button.visible = not world.hud.overlay.visible and world.placement.is_empty() and world.zoom<260 and not world.camera.is_position_behind(b.at)
  if not b.button.visible: continue
  var p = world.camera.unproject_position(b.at)-Vector2(41,38)
  var rect = Rect2(p,Vector2(82,42))
  if p.x<4 or p.x+82>world.hud.size.x-4 or p.y<170 or p.y+42>world.hud.size.y-190: b.button.hide(); continue
  for previous in occupied:
   if rect.intersects(previous): b.button.hide(); break
  if not b.button.visible: continue
  occupied.append(rect)
  b.button.position = p
 truck_visual_count = 0
 belt_visual_count = 0
 var present = {}
 var shipments = Game.state.delivery.shipments+Game.state.construction_shipments
 for shipment in shipments:
  var id = int(shipment.id)
  present[id] = true
  var is_truck = shipment.mode=="truck"
  var signature = ("truck:" if is_truck else "belt:")+str(shipment.key)+":"+str(Game.state.vehicle)
  if not visuals.has(id) and visual_pool.has(signature) and not visual_pool[signature].is_empty():
   visuals[id]=visual_pool[signature].pop_back()
   visuals[id].show()
  if not visuals.has(id):
   var node: Node3D
   if is_truck:
    node = TimberTruck.new()
    node.tier = maxi(2,mini(4,int(Game.state.vehicle)))
    node.cargo_furniture = shipment.key=="furniture"
    node.cargo_boxes = shipment.key not in ["wood","furniture"]
   else:
    node = Node3D.new()
    if shipment.key=="wood": Models.log_pile(node,Vector3(-0.5,0.5,0),2)
    else:
     for j in 3: Models.box(node,Vector3(1.6,0.18,2.3),Vector3(0,0.3+j*0.2,0),Color("f5c777"))
    Models.bake(node)
   add_child(node)
   node.set_meta("pool_key",signature)
   visuals[id] = node
  var node: Node3D = visuals[id]
  var running = true
  if shipment.target!="construction":
   running = not Game.state.delivery.paused
   for kind in DeliveryChain.KINDS:
    if Game.state.buildings[int(Game.state.delivery.nodes[kind])].get("paused",false): running=false
  var age = float(shipment.age)+minf(Game.tick_clock,0.99) if running else float(shipment.age)
  var progress = clampf(age/float(shipment.travel),0,1)
  var returning = false
  if is_truck and shipment.has("drive"):
   progress=clampf((age-float(shipment.get("load",0)))/float(shipment.drive),0,1)
   if age>=float(shipment.travel):
    returning=true
    progress=1-clampf((age-float(shipment.travel))/float(shipment.drive),0,1)
  elif is_truck and age>float(shipment.travel)+2:
   returning=true
   progress = 1-clampf((age-float(shipment.travel)-2)/float(shipment.travel),0,1)
  var sample = LogisticsRoutes.sample(shipment.path,progress)
  node.position = sample.position+Vector3(0,0.55,0) if not is_truck else sample.position
  var direction = -sample.direction if returning else sample.direction
  node.rotation.y = atan2(direction.x,direction.z)
  if is_truck and progress>0.02 and progress<0.98: node.position+=Vector3(direction.z,0,-direction.x)*1.0
  if is_truck:
   truck_visual_count += 1
   if running:
    for wheel in node.wheels: wheel.rotate_object_local(Vector3.UP,delta*6)
   if node.cargo!=null: node.cargo.visible = not shipment.arrived
  else: belt_visual_count += 1
 for id in visuals.keys():
  if not present.has(id):
   var node=visuals[id]
   var key=str(node.get_meta("pool_key"))
   node.hide()
   if not visual_pool.has(key): visual_pool[key]=[]
   if visual_pool[key].size()<4: visual_pool[key].append(node)
   else: node.queue_free()
   visuals.erase(id)

func _exit_tree() -> void:
 if is_instance_valid(overlay): overlay.queue_free()
