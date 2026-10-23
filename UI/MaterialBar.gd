extends GridContainer

const KEYS=["wood","boards","dry","furniture","walls","roofs"]
const NAMES={"wood":"Holz","boards":"Bretter","dry":"Trocken","furniture":"Möbel","walls":"Wände","roofs":"Dächer"}
var hud
var counters={}
var controls={}
var captions={}
var warehouse_counts={}
func _ready() -> void:
 columns=3
 size_flags_horizontal=Control.SIZE_EXPAND_FILL
 add_theme_constant_override("h_separation",4)
 add_theme_constant_override("v_separation",4)
 for key_value in KEYS:
  var key=str(key_value)
  var item=hud.button(self,"",func(): hud.ux.open_material(key))
  item.custom_minimum_size=Vector2(0,54)
  item.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  hud.compact_style(item,hud.PAPER)
  var box=VBoxContainer.new()
  box.mouse_filter=Control.MOUSE_FILTER_IGNORE
  item.add_child(box)
  box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  box.offset_left=4
  box.offset_right=-4
  box.offset_top=2
  box.offset_bottom=-2
  box.add_theme_constant_override("separation",0)
  var name_label=hud.text(box,NAMES[key],12,hud.INK)
  name_label.autowrap_mode=TextServer.AUTOWRAP_OFF
  name_label.clip_text=true
  name_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  captions[key]=name_label
  var count=hud.text(box,"0",18,hud.INK)
  count.autowrap_mode=TextServer.AUTOWRAP_OFF
  count.clip_text=true
  count.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  counters[key]=count
  var warehouse=hud.text(box,"Lager 0",10,hud.INK)
  warehouse.autowrap_mode=TextServer.AUTOWRAP_OFF
  warehouse.clip_text=true
  warehouse.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  warehouse_counts[key]=warehouse
  # Buttons do not propagate their children's minimum size. Derive the height
  # from all three labels, including the active font/accessibility metrics.
  var fit=func(): item.custom_minimum_size.y=maxf(54,box.get_combined_minimum_size().y+4)
  box.minimum_size_changed.connect(fit)
  fit.call()
  controls[key]=item
 refresh()
func refresh() -> void:
 columns=3
 for key in counters:
  var stock=UXRules.material_stock(Game.state,key)
  counters[key].text=compact_number(stock.stored)
  warehouse_counts[key].text="Lager "+compact_number(stock.warehouse)
  if key=="wood" and int(Game.state.workers)>0 and float(Game.flow.get("harvest",0))<=0 and CentralLogistics.active(Game.state):
   var waiting=false
   var working=false
   for index in Game.state.buildings.size():
    if Game.state.buildings[index].kind!="station" or Game.state.buildings[index].get("paused",false): continue
    if CentralLogistics.output_room(Game.state,index,"wood")>0.00001: working=true
    else: waiting=true
   if waiting and not working: warehouse_counts[key].text+=" · Abholung"
  var trend=Game.material_trend(key)
  captions[key].text=NAMES[key]+(" "+str(trend.arrow) if trend.ready else "")
  controls[key].tooltip_text="%s: %s im Lager · %s in Betrieben · %s unterwegs. Antippen für Quellen und Lieferungen." % [Catalog.RESOURCES[key],Catalog.number(stock.warehouse),Catalog.number(stock.local),Catalog.number(stock.transit)]

func compact_number(value: float) -> String:
 if value<10000: return str(int(value))
 if value<1000000: return "%.1fk" % (value/1000.0)
 return "%.1fM" % (value/1000000.0)
