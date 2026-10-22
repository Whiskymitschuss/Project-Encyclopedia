extends GridContainer

const KEYS=["wood","boards","dry","furniture","walls","roofs"]
const NAMES={"wood":"Holz","boards":"Bretter","dry":"Trocken","furniture":"Möbel","walls":"Wände","roofs":"Dächer"}
var hud
var counters={}
var controls={}
func _ready() -> void:
 columns=3
 size_flags_horizontal=Control.SIZE_EXPAND_FILL
 add_theme_constant_override("h_separation",4)
 add_theme_constant_override("v_separation",4)
 for key_value in KEYS:
  var key=str(key_value)
  var item=hud.button(self,"",func(): hud.ux.open_material(key))
  item.custom_minimum_size=Vector2(0,44)
  item.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  hud.compact_style(item,Color("24433f"))
  var box=VBoxContainer.new()
  box.mouse_filter=Control.MOUSE_FILTER_IGNORE
  item.add_child(box)
  box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  box.offset_left=4
  box.offset_right=-4
  box.offset_top=2
  box.offset_bottom=-2
  box.add_theme_constant_override("separation",0)
  var name_label=hud.text(box,NAMES[key],11,hud.MUTED)
  name_label.autowrap_mode=TextServer.AUTOWRAP_OFF
  name_label.clip_text=true
  name_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  var count=hud.text(box,"0",17,hud.GOLD)
  count.autowrap_mode=TextServer.AUTOWRAP_OFF
  count.clip_text=true
  count.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  counters[key]=count
  controls[key]=item
 refresh()
func refresh() -> void:
 for key in counters:
  var stock=UXRules.material_stock(Game.state,key)
  counters[key].text=Catalog.number(stock.stored)
  controls[key].tooltip_text="%s: %s im Lager · %s in Betrieben · %s unterwegs. Antippen für Quellen und Lieferungen." % [Catalog.RESOURCES[key],Catalog.number(stock.warehouse),Catalog.number(stock.local),Catalog.number(stock.transit)]
