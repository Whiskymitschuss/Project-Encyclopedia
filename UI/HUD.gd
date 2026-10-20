extends Control

signal camera_action(action: String)
signal focus_requested(point: Vector3)
signal placement_requested(request: Dictionary)
signal placement_action(action: String)

const INK = Color("123e50")
const PANEL = Color("197b87")
const GOLD = Color("ffd05b")
const CREAM = Color("fff5da")
const MUTED = Color("a6dcd7")
const PAPER = Color("fff3d9")
const Surface = preload("res://UI/SculptedSurface.gd")
var money: Label
var diamonds: Label
var loot_counter: Label
var subtitle: Label
var supply: Label
var toast: Label
var mission_button: Button
var overlay: PanelContainer
var contents: VBoxContainer
var scroll: ScrollContainer
var modal_title: Label
var current = ""
var current_index = -1
var refresh_clock = 0.0
var toast_left = 0.0
var live_labels: Array = []
var sawdust_button: Button
var placement_panel: PanelContainer
var placement_title: Label
var placement_hint: Label
var placement_materials: Label
var placement_confirm: Button
var build_category = "Produktion"
var spatial_icons: SubViewport
var companion: Control
var route_selection: Array = []
var placement_rotate: Button

func style(color: Color, radius: int = 18, pressed: bool = false) -> StyleBoxTexture:
 return Surface.create(color,radius,pressed)

func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 var design = Theme.new()
 design.default_font_size = 17
 design.set_color("font_color","Label",CREAM)
 design.set_color("font_color","Button",CREAM)
 design.set_color("font_disabled_color","Button",Color("8ba4a3"))
 design.set_stylebox("normal","Button",style(PANEL,13))
 design.set_stylebox("hover","Button",style(PANEL.lightened(0.10),13))
 design.set_stylebox("pressed","Button",style(PANEL,13,true))
 design.set_stylebox("disabled","Button",style(Color("385457"),13))
 design.set_stylebox("focus","Button",style(PANEL.lightened(0.15),13))
 theme = design
 spatial_icons=load("res://UI/SpatialIcons.gd").new()
 add_child(spatial_icons)
 var header = PanelContainer.new()
 add_child(header)
 header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 header.offset_left = 14
 header.offset_right = -14
 header.offset_top = 14
 header.offset_bottom = 114
 header.add_theme_stylebox_override("panel",style(INK,24))
 var top = VBoxContainer.new()
 header.add_child(top)
 var brand = row(top)
 var title = text(brand,"TIMBER LOOT",21)
 title.autowrap_mode = TextServer.AUTOWRAP_OFF
 title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 var edition = text(brand,"STEIN & HOLZ / 17",11,GOLD)
 edition.autowrap_mode = TextServer.AUTOWRAP_OFF
 var counters=row(top)
 money=resource_counter(counters,"coin",19)
 money.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 diamonds=resource_counter(counters,"gem",17)
 loot_counter=resource_counter(counters,"more",17)
 subtitle = text(top,"",12,MUTED)
 mission_button = button(self,"",func(): open_menu("guide" if int(Game.state.tutorial)<5 else "missions"))
 mission_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 mission_button.offset_left = 14
 mission_button.offset_right = -14
 mission_button.offset_top = 122
 mission_button.offset_bottom = 162
 mission_button.custom_minimum_size.y=40
 mission_button.add_theme_font_size_override("font_size",14)
 compact_style(mission_button,PANEL)
 var right = VBoxContainer.new()
 add_child(right)
 right.anchor_left = 1
 right.anchor_right = 1
 right.offset_left = -66
 right.offset_right = -14
 right.offset_top = 184
 for entry in [["+","+"],["−","−"],["⌂","home"],["▦","world"]]:
  var action = str(entry[1])
  var quick=button(right,str(entry[0]),func(): camera_action.emit(action))
  quick.custom_minimum_size = Vector2(48,44)
  compact_style(quick,PAPER)
  quick.add_theme_color_override("font_color",INK)
 var bottom = VBoxContainer.new()
 add_child(bottom)
 bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 bottom.offset_left = 14
 bottom.offset_right = -14
 bottom.offset_top = -184
 bottom.offset_bottom = -12
 bottom.add_theme_constant_override("separation",6)
 var strip = PanelContainer.new()
 var strip_style=style(INK,14)
 strip_style.content_margin_top=6
 strip_style.content_margin_bottom=6
 strip.add_theme_stylebox_override("panel",strip_style)
 bottom.add_child(strip)
 var supply_row = row(strip)
 supply = text(supply_row,"",13,CREAM)
 supply.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 supply.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 supply.custom_minimum_size.y = 35
 sawdust_button = button(supply_row,"SPÄNEBOX",func():
  if float(Game.state.resources.sawdust)>0: Game.sell("sawdust"); Game.save(true)
  else: open_menu("sawdust"))
 sawdust_button.size_flags_horizontal=Control.SIZE_SHRINK_END
 sawdust_button.custom_minimum_size=Vector2(100,40)
 sawdust_button.add_theme_font_size_override("font_size",12)
 compact_style(sawdust_button,PANEL)
 var actions = row(bottom)
 var chop = button(actions,"FÄLLEN",func():
  if Game.state.bag < Game.bag_capacity(): focus_requested.emit(Catalog.biome_position(int(Game.state.biome)))
  Game.chop())
 chop.add_theme_stylebox_override("normal",style(GOLD,14))
 chop.add_theme_color_override("font_color",INK)
 button(actions,"Abliefern",func(): Game.deposit(); camera_action.emit("home"))
 button(actions,"Verkaufen",func(): open_menu("market"))
 for control in actions.get_children():
  control.custom_minimum_size.y=40
  compact_style(control,GOLD if control==chop else PANEL)
 var navigation = row(bottom)
 for entry in [["Bauen","catalog","factory"],["Team","team","team"],["Aufträge","contracts","orders"],["Welt","world","world"],["Mehr","more","more"]]:
  var tab = str(entry[1])
  var nav_button = button(navigation,str(entry[0]),func(): open_menu(tab))
  nav_button.text="\n\n"+str(entry[0])
  nav_button.custom_minimum_size.y=68
  nav_button.add_theme_font_size_override("font_size",12)
  nav_button.add_theme_color_override("font_color",INK)
  compact_style(nav_button,PAPER)
  var icon=TextureRect.new()
  icon.texture=spatial_icons.texture_for(str(entry[2]))
  icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
  icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
  nav_button.add_child(icon)
  icon.anchor_left=0.5
  icon.anchor_right=0.5
  icon.offset_left=-23
  icon.offset_right=23
  icon.offset_top=0
  icon.offset_bottom=46
 toast = text(self,"",15,CREAM)
 toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
 toast.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 toast.offset_left = 20
 toast.offset_right = -20
 toast.offset_top = -232
 toast.offset_bottom = -188
 toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 toast.add_theme_color_override("font_shadow_color",INK)
 toast.add_theme_constant_override("shadow_offset_x",1)
 toast.add_theme_constant_override("shadow_offset_y",2)
 build_overlay()
 build_placement_bar()
 companion=load("res://UI/Companion.gd").new()
 companion.hud=self
 add_child(companion)
 Game.changed.connect(update_stats)
 Game.notice.connect(show_notice)
 Game.rebuild_world.connect(func(): if overlay.visible: call_deferred("render_menu"))
 update_stats()
 if int(Game.state.tutorial)==0: call_deferred("open_menu","welcome")

func build_overlay() -> void:
 overlay = PanelContainer.new()
 add_child(overlay)
 overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 overlay.offset_left = 14
 overlay.offset_right = -14
 overlay.offset_top = 168
 overlay.offset_bottom = -192
 overlay.add_theme_stylebox_override("panel",style(Color("125263"),22))
 var container = VBoxContainer.new()
 container.add_theme_constant_override("separation",12)
 overlay.add_child(container)
 var heading = row(container)
 modal_title = text(heading,"",23,GOLD)
 modal_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 var close_button = button(heading,"×",func(): close_menu())
 close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
 close_button.custom_minimum_size.x = 46
 scroll = load("res://UI/TouchScroll.gd").new()
 scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
 scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 container.add_child(scroll)
 contents = VBoxContainer.new()
 contents.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 contents.add_theme_constant_override("separation",12)
 scroll.add_child(contents)
 overlay.hide()

func text(parent: Node, value: String, font_size: int = 17, color: Color = CREAM) -> Label:
 var label = Label.new()
 label.text = value
 label.add_theme_font_size_override("font_size",font_size)
 var ink = color
 if parent.has_meta("light_card"):
  ink = INK if color==CREAM else Color("ad6508") if color==GOLD else Color("52767a") if color==MUTED else color
 label.add_theme_color_override("font_color",ink)
 label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 parent.add_child(label)
 return label

func compact_style(control: Button, color: Color) -> void:
 for entry in [["normal",color],["hover",color.lightened(0.08)],["pressed",color.darkened(0.10)]]:
  var box=style(entry[1],12,entry[0]=="pressed")
  box.content_margin_top=5
  box.content_margin_bottom=5
  box.content_margin_left=8
  box.content_margin_right=8
  control.add_theme_stylebox_override(entry[0],box)

func resource_counter(parent: Control, key: String, font_size: int) -> Label:
 var icon=TextureRect.new()
 icon.texture=spatial_icons.texture_for(key)
 icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 icon.custom_minimum_size=Vector2(28,28)
 icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
 parent.add_child(icon)
 var value=text(parent,"",font_size,GOLD)
 value.autowrap_mode=TextServer.AUTOWRAP_OFF
 return value

func row(parent: Node) -> HBoxContainer:
 var node = HBoxContainer.new()
 node.add_theme_constant_override("separation",7)
 parent.add_child(node)
 return node

func button(parent: Node, title: String, callback: Callable, enabled: bool = true) -> Button:
 var node = Button.new()
 node.text = title
 node.custom_minimum_size = Vector2(0,48)
 node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 node.disabled = not enabled
 node.pressed.connect(callback)
 parent.add_child(node)
 return node

func card(title: String, detail: String = "") -> VBoxContainer:
 var panel = PanelContainer.new()
 panel.add_theme_stylebox_override("panel",style(PAPER,16))
 contents.add_child(panel)
 var box = VBoxContainer.new()
 box.add_theme_constant_override("separation",8)
 box.set_meta("light_card",true)
 panel.add_child(box)
 text(box,title,19,CREAM)
 if not detail.is_empty(): text(box,detail,15,MUTED)
 return box

func action(callback: Callable) -> void:
 callback.call()
 Game.save(true)
 render_menu()
 update_stats()

func show_notice(message: String) -> void:
 toast.text = message
 toast_left = 5.0

func update_stats() -> void:
 money.text = "%s Münzen" % Catalog.number(Game.state.coins)
 diamonds.text=Catalog.number(Game.state.diamonds)
 loot_counter.text=Catalog.number(Game.state.tickets)
 subtitle.text = "%s · Rucksack %s/%s · Team %s · Lv. %s" % [Catalog.TOOLS[int(Game.state.tool)],int(Game.state.bag),int(Game.bag_capacity()),int(Game.state.workers),Game.company_level()]
 supply.text = "HOLZ %s → BRETTER %s → TROCKEN %s\nMÖBEL %s · %s LKW · %02d:00 · %s" % [Catalog.number(Game.state.resources.wood),Catalog.number(Game.state.resources.boards),Catalog.number(Game.state.resources.dry),Catalog.number(Game.state.resources.furniture),int(Game.state.trucks),int(Game.state.time),["Sonnig","Wolkig","Regen","Nebel"][int(Game.state.weather)]]
 if Game.state.delivery.active:
  var order = Game.state.delivery.order
  supply.text = "HOLZ → BRETTER → MÖBEL\nLADEN %s/%s · %s" % [int(order.delivered),int(order.amount),"SPÄT · 70 %" if order.late else "%02d:%02d" % [int(float(order.left)/60),int(order.left)%60]]
 var fill = float(Game.state.resources.sawdust)/Game.capacity()
 sawdust_button.text="SPÄNEBOX\n%s %% · LEEREN" % int(fill*100)
 compact_style(sawdust_button,Color("e78a45") if fill>=0.8 else Color("258f8d"))
 mission_button.text = "MISSIONEN · Dein nächster Meilenstein"
 for m in Game.mission_definitions():
  if not Game.state.missions_claimed.has(m.id):
   mission_button.text = "%s · %s/%s %s" % [m.name,Catalog.number(m.value),Catalog.number(m.target),"ABHOLEN" if m.value >= m.target else "›"]
   break
 if int(Game.state.tutorial)<5:
  mission_button.text = ["WILLKOMMEN · Dein Waldimperium wartet","ANLEITUNG 1/4 · Fälle fünf Bäume","ANLEITUNG 2/4 · Holz abliefern","ANLEITUNG 3/4 · Erste Rohstoffe verkaufen","ANLEITUNG 4/4 · Erstes Gebäude platzieren"][int(Game.state.tutorial)]

func _process(delta: float) -> void:
 toast_left -= delta
 toast.modulate.a = clampf(toast_left,0,1)
 if Game.company_level()>=4 and not Game.state.construction_intro and not overlay.visible and not placement_panel.visible:
  Game.state.construction_intro=true
  Game.save(true)
  open_menu("construction")
 refresh_clock += delta
 if refresh_clock >= 1.0:
  refresh_clock = 0
  for item in live_labels:
   if is_instance_valid(item.label): item.label.text = item.callback.call()

func _unhandled_key_input(event: InputEvent) -> void:
 if event.is_action_pressed("ui_cancel") and placement_panel.visible:
  placement_action.emit("cancel")
  get_viewport().set_input_as_handled()
  return
 if event.is_action_pressed("ui_cancel") and overlay.visible:
  close_menu()
  get_viewport().set_input_as_handled()

func open_menu(tab: String) -> void:
 if placement_panel!=null and placement_panel.visible: placement_action.emit("cancel")
 current = tab
 scroll.scroll_vertical = 0
 overlay.show()
 overlay.offset_top=maxf(168,size.y-574) if tab=="building" else 168.0
 render_menu()

func close_menu() -> void:
 overlay.hide()
 live_labels.clear()

func show_building(index: int) -> void:
 current_index = index
 open_menu("building")

func show_plot(index: int) -> void:
 current_index = index
 open_menu("plot")

func dynamic_text(parent: Node, callback: Callable) -> void:
 var label = text(parent,callback.call(),15,MUTED)
 label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 live_labels.append({"label":label,"callback":callback})

func materials_text(materials: Dictionary) -> String:
 var parts = []
 for key in materials:
  parts.append("%s %s (%s vorhanden)" % [Catalog.number(materials[key]),Catalog.RESOURCES[key],Catalog.number(Game.state.resources[key])])
 return ", ".join(parts)

func render_menu() -> void:
 var old_scroll = scroll.scroll_vertical
 for child in contents.get_children():
  contents.remove_child(child)
  child.queue_free()
 live_labels.clear()
 match current:
  "stone": stone_menu()
  "delivery": delivery_menu()
  "construction": construction_menu()
  "industry": industry_menu()
  "building": building_menu()
  "catalog": catalog_menu()
  "team": team_menu()
  "garage": garage_menu()
  "city": city_menu()
  "networks": networks_menu()
  "transit": transit_menu()
  "services": services_menu()
  "plot": plot_menu()
  "contracts": contracts_menu()
  "world": world_menu()
  "more": more_menu()
  "missions": missions_menu()
  "loot": loot_menu()
  "research": research_menu()
  "boosters": boosters_menu()
  "prestige": prestige_menu()
  "market": market_menu()
  "settings": settings_menu()
  "empire": empire_menu()
  "planner": planner_menu()
  "sawdust": sawdust_menu()
  "welcome": welcome_menu()
  "guide": guide_menu()
  "confirm_prestige": confirm_prestige_menu()
 scroll.set_deferred("scroll_vertical",old_scroll)

func industry_menu() -> void:
 modal_title.text = "DEINE INDUSTRIE"
 var help = card("Vom Wald zum Imperium","Fälle Holz und liefere es ab. Helfer füllen das Lager automatisch. Baue zuerst Trockenkammer und Möbelfabrik; danach das Fertighauswerk für deine Stadt.")
 button(help,"LIEFERKETTE · HOLZ → BRETTER → MÖBEL",func(): open_menu("delivery"))
 button(help,"STEINBRUCH & BAUSTOFFE · AB LEVEL 5",func(): open_menu("stone"))
 button(help,"NEUEN BETRIEB BAUEN",func(): open_menu("catalog"))
 var links = row(contents)
 button(links,"Personal",func(): open_menu("team"))
 button(links,"Garage",func(): open_menu("garage"))
 button(links,"Forschung",func(): open_menu("research"))
 jobs_cards()
 for i in Game.state.buildings.size():
  var index = i
  var b = Game.state.buildings[i]
  var box = card("%s · Stufe %s" % [Catalog.BUILDINGS[b.kind].name,b.level],Catalog.BUILDINGS[b.kind].desc)
  button(box,"VERWALTEN / AUSBAUEN",func(): show_building(index))

func jobs_cards() -> void:
 for job in Game.state.jobs:
  var title = Catalog.PROJECTS[int(job.index)].name if job.type=="project" else Catalog.HOMES[job.kind].name if job.type in ["home","home_upgrade"] else Catalog.BUILDINGS[job.kind].name
  var box = card("Baustelle · %s" % title)
  dynamic_text(box,func(): return ConstructionRules.status(job))
  if not job.get("materials",{}).is_empty():
   for resource_key in job.materials:
    var material_key=str(resource_key)
    var material_row=row(box)
    material_row.set_meta("light_card",true)
    var icon=TextureRect.new()
    icon.custom_minimum_size=Vector2(30,30)
    icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    var icon_path="res://Assets/Resources/%s.svg" % material_key
    icon.texture=load(icon_path if ResourceLoader.exists(icon_path) else "res://Assets/Resources/boards.svg")
    material_row.add_child(icon)
    dynamic_text(material_row,func(): return "%s  %s / %s" % [Catalog.RESOURCES[material_key],Catalog.number(float(job.get("delivered",{}).get(material_key,0))),Catalog.number(float(job.materials[material_key]))])
   var id = int(job.get("id",-1))
   button(box,"LIEFERUNG AUS DEM LAGER ANFORDERN",func(): action(func(): Game.deliver_job(id)),not ConstructionRules.ready(job))
   var hardware_cost=Game.job_hardware_cost(id)
   if hardware_cost>0: button(box,"FEHLENDE TEILE KAUFEN · %s MÜNZEN" % Catalog.number(hardware_cost),func(): action(func(): Game.buy_job_hardware(id)))
   if job.has("phases"):
    dynamic_text(box,func():
     var underway=0
     for s in Game.state.construction_shipments:
      if int(s.job)==id and not s.arrived: underway+=1
     return "Bauarbeiter: %s/5 · Lieferfahrzeuge: %s\nRestarbeit: %s s + fehlende Lieferzeit" % [job.workers,underway,ceili(float(job.left)/maxf(1,int(job.workers)*(1+Game.research_level("construction")*0.12+minf(Game.public_level("fire")*0.05,0.5))*Game.boost("workers")))])
    var crew=row(box)
    button(crew,"− Arbeiter",func(): action(func(): Game.assign_builders(id,int(job.workers)-1)))
    button(crew,"+ Arbeiter",func(): action(func(): Game.assign_builders(id,int(job.workers)+1)))
    var controls=row(box)
    button(controls,"Fortsetzen" if job.paused else "Pausieren",func(): action(func(): job.paused=not job.paused))
    button(controls,"Priorität: AN" if job.priority else "Priorisieren",func(): action(func(): job.priority=not job.priority))
    button(box,"BAUKAMERA",func(): focus_requested.emit(ConstructionRules.job_position(Game.state,job)); close_menu())
    button(box,"ABBRECHEN · MATERIAL ZURÜCK",func(): action(func(): Game.cancel_construction(id)))
    text(box,"Bei Abbruch kommen Material und Ladung ins Lager zurück. Die Baukosten werden nicht erstattet.",13,MUTED)
   button(box,"MATERIALDEPOT ÖFFNEN",func(): open_menu("construction"))

func catalog_menu() -> void:
 modal_title.text = "BAUWERK AUSWÄHLEN"
 button(contents,"BAUSTELLEN & MATERIALDEPOT",func(): open_menu("construction"))
 button(contents,"STEINBRUCH & BAUSTOFFE",func(): open_menu("stone"))
 text(contents,"Auswählen → in der Welt platzieren → drehen → bestätigen. Bezahlt wird erst beim Bestätigen. Straßen bleiben frei; Waldflächen werden geräumt.",15,MUTED)
 var tabs=row(contents)
 for name_value in ["Produktion","Stadt","Versorgung"]:
  var category=str(name_value)
  var tab=button(tabs,category,func(): build_category=category; render_menu())
  tab.add_theme_font_size_override("font_size",14)
  if category==build_category: tab.add_theme_stylebox_override("normal",style(Color("d99432"),13))
 var routes=row(contents)
 button(routes,"Straßen & Wege",func(): open_menu("networks"))
 button(routes,"Bus & Haltestellen",func(): open_menu("transit"))
 var grid=GridContainer.new()
 grid.columns=2
 grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 grid.add_theme_constant_override("h_separation",10)
 grid.add_theme_constant_override("v_separation",10)
 contents.add_child(grid)
 var city=build_category=="Stadt"
 var definitions=Catalog.HOMES if city else Catalog.BUILDINGS
 var ordered=definitions.keys()
 for mineral in StoneIndustry.KINDS:
  if ordered.has(mineral): ordered.erase(mineral); ordered.append(mineral)
 for kind in ordered:
  if not city and ((build_category=="Versorgung")!=(kind in ["station","cabin","warehouse","market","research","garage"])): continue
  var key=str(kind)
  var d=definitions[kind]
  var enabled=(Game.level("prefab")>0 and Game.next_city_plot()>=0) if city else Game.available(kind)
  var price=float(d.cost)*Game.difficulty() if city else Game.cost_for(kind)
  var caption="%s\n%s Münzen\n%s" % [d.name,Catalog.number(price),"PLATZIEREN" if enabled else "AB LEVEL 5" if kind in StoneIndustry.KINDS else "GESPERRT"]
  var tile=button(grid,caption,func(): request_placement({"kind":key,"city":city,"index":-1,"plot":-1}),enabled)
  tile.custom_minimum_size.y=100
  tile.add_theme_font_size_override("font_size",15)
  var background=Color(d.color).lerp(Color("0b6472"),0.2)
  tile.add_theme_stylebox_override("normal",style(background,16))
 var links=row(contents)
 button(links,"Betriebe verwalten",func(): open_menu("industry"))
 button(links,"Stadt & Regionen",func(): open_menu("city"))

func building_menu() -> void:
 if current_index < 0 or current_index >= Game.state.buildings.size(): return
 var index = current_index
 var b = Game.state.buildings[index]
 var d = Catalog.BUILDINGS[b.kind]
 modal_title.text = d.name.to_upper()
 var description = "Lieferbetrieb: 2 Bretter → 1 Möbel. Fertige Möbel werden zum Laden gefahren." if Game.delivery_owns(index) and b.kind=="furniture" else d.desc
 var box = card("Stufe %s / %s" % [b.level,d.max],description)
 dynamic_text(box,func(): return Game.production_status(index))
 if b.kind == "sawmill":
  text(box,"Leere die sichtbare Spänebox regelmäßig. Ein voller Behälter stoppt die Bretterproduktion nicht; neuer Überlauf wird kompostiert oder auf Wunsch verkauft.",15,MUTED)
  button(box,"SPÄNEBOX LEEREN",func(): open_menu("sawdust"))
 if Game.company_level()>=4: text(box,"Material für Stufe %s: %s" % [int(b.level)+1,materials_text(Game.build_materials(b.kind,int(b.level)+1))],15,MUTED)
 else: text(box,"Bis Level 3: Ausbau nur mit Münzen. Ab Level 4 kommen Baustoffe und Lieferfahrzeuge dazu.",15,MUTED)
 if Game.delivery_owns(index):
  text(box,"Zum Verschieben zuerst die Lieferlinie auflösen. Ihre Vorräte und Ladungen kommen vollständig ins Lager zurück.",14,MUTED)
  button(box,"LIEFERKETTE & LOKALEN VORRAT ANSEHEN",func(): open_menu("delivery"))
 text(box,"Ausbau: %s Münzen" % Catalog.number(Game.cost_for(b.kind,int(b.level)+1)),17,GOLD)
 var management=row(box)
 button(management,"AUSBAUEN" if not Game.job_for("upgrade",index) else "AUSBAU LÄUFT",func(): action(func(): Game.upgrade(index)),not Game.job_for("upgrade",index) and b.level < d.max)
 button(management,"VERSCHIEBEN",func(): request_placement({"kind":b.kind,"city":false,"index":index}),not Game.delivery_owns(index) and not Game.job_for("upgrade",index))
 if b.kind in StoneIndustry.KINDS:
  stone_site_controls(box,index)
 if Catalog.RECIPES.has(b.kind) or b.kind in StoneIndustry.KINDS:
  button(box,"Produktion fortsetzen" if b.paused else "Produktion pausieren",func(): action(func(): b.paused = not b.paused))
 if b.kind=="cabin": button(box,"PERSONAL EINSTELLEN",func(): open_menu("team"))
 if b.kind=="garage": button(box,"FAHRZEUGE VERWALTEN",func(): open_menu("garage"))
 if b.kind=="research": button(box,"FORSCHUNG",func(): open_menu("research"))
 button(box,"IN DER WELT ANSEHEN",func(): focus_requested.emit(Game.building_position(index)); close_menu())
 jobs_cards()

func team_menu() -> void:
 modal_title.text = "DEIN TEAM"
 var box = card("%s / %s Arbeiter" % [Game.state.workers,Game.worker_capacity()],"Helfer fällen und liefern Holz automatisch. Hütten und Stadtbewohner schaffen zusätzlichen Wohnraum. Forschungsboni erhöhen die Leistung.")
 text(box,"Einstellung: %s Münzen" % Catalog.number(Game.hire_cost()),17,GOLD)
 button(box,"ARBEITER EINSTELLEN",func(): action(func(): Game.hire()))
 var tool = card(Catalog.TOOLS[int(Game.state.tool)],"Aktiver Ertrag: %s Holz · Boss-Schaden: %s" % [int((4+int(Game.state.tool)*3)*(1+int(Game.state.biome)*0.4)),Catalog.number(pow(2.0,int(Game.state.tool))*10)])
 if int(Game.state.tool) < 14:
  text(tool,"Nächste Stufe: %s" % Catalog.TOOLS[int(Game.state.tool)+1],16,GOLD)
  button(tool,"VERBESSERN · %s" % Catalog.number(Game.tool_cost()),func(): action(func(): Game.upgrade_tool()))
  button(tool,"AUS TEILEN BAUEN · %s Teile" % (3+int(Game.state.tool)*2),func(): action(func(): Game.craft_tool()))

func garage_menu() -> void:
 text(contents,"Transportupgrades verbessern Ladekapazität und Fahrtempo. Höhere Stufen zeigen Gelenk-Auflieger und Tiefbetttransporter. Maschinen im Wald schaltest du unter Team mit den Werkzeugstufen frei.",15,MUTED)
 modal_title.text = "VEHICLE GARAGE"
 var box = card("%s Transportfahrzeuge" % Game.state.trucks,"Deine gemeinsame Flotte transportiert Holz, Bretter, Möbel und Baumaterial. Beladen, Entladen und leere Rückfahrt belegen das Fahrzeug. Die Garage schafft zusätzliche Stellplätze.")
 button(box,"LIEFERKETTE & ZUTEILUNG",func(): open_menu("delivery"))
 button(box,"LKW KAUFEN · %s" % Catalog.number(Game.truck_cost()),func(): action(func(): Game.buy_truck()))
 var vehicle = card(Catalog.VEHICLES[int(Game.state.vehicle)],"Fahrzeugverbesserungen erhöhen Rucksack, Exportkapazität und sichtbare Fahrgeschwindigkeit.")
 if Game.state.vehicle < 9:
  button(vehicle,"NÄCHSTE STUFE · %s" % Catalog.number(Game.vehicle_cost()),func(): action(func(): Game.upgrade_vehicle()))
  button(vehicle,"AUS TEILEN BAUEN · %s Teile" % (4+int(Game.state.vehicle)*3),func(): action(func(): Game.craft_vehicle()))

func city_menu() -> void:
 modal_title.text = "DEINE STADT"
 card("%s Bewohner · %s Gebäude" % [Game.residents(),Game.state.homes.size()],"Bauwirtschaft: Möbelproduktion → Fertighauswerk → Wand- und Dachmodule → Häuser → Miete. Ab Level 4 wird der Bauauftrag mit Münzen bezahlt; das Baumaterial kommt danach per LKW zur Baustelle. Erst fertiggestellte Gebäude erwirtschaften Ertrag.")
 var navigation = row(contents)
 button(navigation,"Regionen & Projekte",func(): open_menu("empire"))
 button(navigation,"Materialplaner",func(): open_menu("planner"))
 var urban=row(contents)
 button(urban,"Straßen & Wege",func(): open_menu("networks"))
 button(urban,"Buslinien",func(): open_menu("transit"))
 button(contents,"STADTLEBEN · POLIZEI, FEUERWEHR & TAXIS",func(): open_menu("services"))
 var rents=card("Deine Miete","Auf die goldene Münzanzeige über einem Haus tippen oder hier gesammelt abholen. Bewohner und öffentliche Einrichtungen erhöhen den Ertrag.")
 dynamic_text(rents,func(): return "Abholbereit: %s Münzen" % Catalog.number(Game.rent_total()))
 button(rents,"ALLE MIETEN ABHOLEN",func(): action(func(): Game.collect_rent()))
 button(rents,"Hausverwaltung: AUTOMATISCH" if Game.state.town.rent_auto else "Hausverwaltung einschalten"+(" · %s Münzen" % Catalog.number(2500*Game.difficulty()) if not Game.state.town.rent_manager else ""),func(): action(func(): Game.set_rent_auto(not Game.state.town.rent_auto)))
 jobs_cards()
 for i in Game.city_plot_count():
  var index = i
  var title = "Freies Grundstück %s" % (i+1)
  for h in Game.state.homes:
   if int(h.plot) == i: title = "%s · Stufe %s" % [Catalog.HOMES[h.kind].name,h.level]
  button(contents,title,func(): show_plot(index))

func plot_menu() -> void:
 var plot = current_index
 modal_title.text = "GRUNDSTÜCK %s" % (plot+1)
 button(contents,"IN DER WELT ANSEHEN",func(): focus_requested.emit(Game.plot_position(plot)); close_menu())
 if plot >= Game.city_plot_count():
  card("Neue Region benötigt","Erweitere dein Unternehmen, um weitere Grundstücke zu erschließen.")
  button(contents,"REGIONEN",func(): open_menu("empire"))
  return
 for i in Game.state.homes.size():
  var index = i
  var h = Game.state.homes[i]
  if int(h.plot) == plot:
   var d = Catalog.HOMES[h.kind]
   var box = card("%s · Stufe %s" % [d.name,h.level],"Grundmiete: %s Münzen/s · Bewohner: %s" % [float(d.rent)*int(h.level),int(d.people)*int(h.level)])
   if float(d.rent)>0:
    dynamic_text(box,func(): return "Abholbereit: %s Münzen" % Catalog.number(Game.state.homes[index].get("rent_bank",0)))
    button(box,"MIETE ABHOLEN",func(): action(func(): Game.collect_rent(index)))
   var materials = {}
   for key in d.materials: materials[key] = ceilf(float(d.materials[key])*0.5*int(h.level))
   text(box,"Ausbau: %s Münzen\n%s" % [Catalog.number(float(d.cost)*pow(1.4,int(h.level))*Game.difficulty()),materials_text(materials)],15,GOLD)
   button(box,"GEBÄUDE AUSBAUEN",func(): action(func(): Game.upgrade_home(index)),not Game.job_for("home_upgrade",index) and h.level < 10)
   button(box,"GEBÄUDE VERSCHIEBEN",func(): request_placement({"kind":h.kind,"city":true,"index":index,"plot":plot}))
   return
 for j in Game.state.jobs:
  if j.type == "home" and int(j.plot) == plot:
   card("Bau läuft bereits","Das Grundstück wird nach Fertigstellung nutzbar.")
   return
 if Game.level("prefab") < 1:
  card("Fertighauswerk benötigt","Baue zuerst Möbelfabrik und Fertighauswerk im Industriemenü.")
  return
 for kind in Catalog.HOMES:
  var key = str(kind)
  var d = Catalog.HOMES[kind]
  var public_effect = {"park":"Unternehmensweit +4 % Miete pro Stufe (zusammen maximal +100 %)","school":"+4 % Produktionsleistung pro Stufe (maximal +50 %)","clinic":"Unternehmensweit +4 % Miete pro Stufe (zusammen maximal +100 %)","fire":"+5 % Baugeschwindigkeit pro Stufe (maximal +50 %)"}.get(kind,"")
  var box = card(d.name,public_effect if not public_effect.is_empty() else "Miete %s/s · %s Bewohner" % [d.rent,d.people])
  text(box,"%s Münzen\n%s" % [Catalog.number(float(d.cost)*Game.difficulty()),materials_text(d.materials)],15,GOLD)
  button(box,"STANDORT AUSWÄHLEN",func(): request_placement({"kind":key,"city":true,"index":-1,"plot":plot}))
  button(box,"ALS BAUZIEL VORMERKEN",func(): Game.set_plan(key,plot); open_menu("planner"))

func contracts_menu() -> void:
 modal_title.text = "AUFTRÄGE & LIEFERUNGEN"
 var line = card("Dein Laden · echte Lieferkette","Holz → Bretter → Möbel. Holz-, Bretter- und Möbellieferungen fahren mit deinen Fahrzeugen über Straßen. Pünktliche Aufträge bringen einen Bonus.")
 if Game.state.delivery.active: dynamic_text(line,func(): return delivery_order_text())
 button(line,"LIEFERKETTE ÖFFNEN",func(): open_menu("delivery"))
 button(contents,"BAUSTELLEN & MATERIALDEPOT",func(): open_menu("construction"))
 var c = Game.contract()
 var box = card("Lieferauftrag %s" % (int(Game.state.contracts)+1),"Ohne Zeitlimit. Materialien werden einmalig geliefert; die Aufträge wachsen mit deinem Unternehmen.")
 dynamic_text(box,func(): return "%s %s benötigt · %s im Lager" % [c.amount,Catalog.RESOURCES[c.key],Catalog.number(Game.state.resources[c.key])])
 text(box,"Prämie: %s Münzen + 1 Ticket + 1 Geldschein" % Catalog.number(float(c.reward)*Game.multiplier()),17,GOLD)
 button(box,"LIEFERN & PRÄMIE ABHOLEN",func(): action(func(): Game.fulfill_contract()))
 button(contents,"MISSIONEN",func(): open_menu("missions"))

func world_menu() -> void:
 modal_title.text = "WELTKARTE"
 text(contents,"Zehn Waldregionen mit eigenen Farben und Erträgen. Die Unternehmensära erhöht Erschließungskosten; dauerhafte Boni bleiben.",15,MUTED)
 for i in 10:
  var index = i
  var biome = Catalog.BIOMES[i]
  var box = card(biome.name,"%s · +%s %% aktiver Holzertrag" % [biome.wood,i*40])
  if i < Game.state.unlocked:
   button(box,"BESUCHEN" if i != Game.state.biome else "AKTIVES BIOM",func(): Game.state.biome = index; focus_requested.emit(Catalog.biome_position(index)); close_menu(); Game.changed.emit())
  elif i == Game.state.unlocked:
   button(box,"ERSCHLIESSEN · %s" % Catalog.number(float(biome.cost)*Game.difficulty()),func(): action(func(): Game.unlock_biome()))
  else: text(box,"Vorherige Region zuerst erschließen",14,MUTED)
 var boss = card("Bossbaum · %s" % Catalog.BIOMES[int(Game.state.biome)].name)
 dynamic_text(boss,func(): return "Verbleibende Stärke: %s" % Catalog.number(Game.state.boss_hp))
 button(boss,"BOSSBAUM ANGREIFEN",func(): action(func(): Game.attack_boss()))

func more_menu() -> void:
 modal_title.text = "DEIN IMPERIUM"
 for entry in [["Steinbruch & Baustoffe","stone"],["Lieferkette & Ladenaufträge","delivery"],["Baustellen & Materialdepot","construction"],["Betriebe verwalten","industry"],["Stadt & Häuser","city"],["Stadtleben & Fahrzeuge","services"],["Straßen & Wege","networks"],["Buslinien & Haltestellen","transit"],["Spänebox leeren","sawdust"],["Anleitung & Hilfe","guide"],["Regionen & Großprojekte","empire"],["Materialplaner","planner"],["Loot & Inventar","loot"],["Forschung","research"],["Booster","boosters"],["Neue Unternehmensära / Prestige","prestige"],["Personal & Werkzeug","team"],["Garage & Fahrzeuge","garage"],["Lager & Verkaufsstelle","market"],["Einstellungen & Sicherung","settings"]]:
  var key = str(entry[1])
  button(contents,str(entry[0]),func(): open_menu(key))

func missions_menu() -> void:
 modal_title.text = "MEILENSTEINE"
 for m in Game.mission_definitions():
  var id = str(m.id)
  var claimed = Game.state.missions_claimed.has(id)
  var box = card(m.name,"%s / %s · %s Münzen, 5 Diamanten, 2 Tickets" % [Catalog.number(m.value),Catalog.number(m.target),Catalog.number(m.reward)])
  button(box,"ABGEHOLT" if claimed else "BELOHNUNG ABHOLEN",func(): action(func(): Game.claim_mission(id)),not claimed and m.value >= m.target)

func loot_menu() -> void:
 modal_title.text = "LOOT & INVENTAR"
 var box = card("%s Loot-Tickets" % Game.state.tickets,"Common 50 % · Uncommon 28 % · Rare 15 % · Epic 5,5 % · Legendary 1,4 % · Mythic 0,1 %. Jede Kiste enthält Münzen, Diamanten und einen Inventargegenstand. Keine Echtgeldkäufe.")
 button(box,"LOOTBOX ÖFFNEN",func(): action(func(): Game.open_loot()))
 for key in Game.state.inventory:
  var item = str(key)
  var slot = card(item,"Bestand: %s" % Game.state.inventory[key])
  if item in ["Gebäude-Skin: Modern","Gold-Axt-Skin","Titan-Skin"]:
   button(slot,"AUSRÜSTEN",func(): action(func(): Game.equip_skin(item)))
 if Game.state.inventory.is_empty(): text(contents,"Dein Inventar wartet auf den ersten Fund.",16,MUTED)
 text(contents,"Geldscheine: %s · Mythic Tokens: %s" % [Game.state.cash,Game.state.tokens],16,GOLD)
 button(contents,"DAUERHAFT +10 % LOOT · 3 TOKENS",func(): action(func(): Game.invest_tokens()),Game.state.tokens>=3)

func empire_menu() -> void:
 modal_title.text = "KONZERN & REGIONEN"
 var region = card(["Waldquartier","Seenregion","Stadtregion"][int(Game.state.region)],"%s Stadtgrundstücke verfügbar · %s Bewohner" % [Game.city_plot_count(),Game.residents()])
 if Game.state.region < 2:
  text(region,"Nächste Region: %s Münzen · %s Bewohner" % [Catalog.number(6000*pow(5,int(Game.state.region))*Game.difficulty()),4 if Game.state.region==0 else 20],16,GOLD)
  button(region,"REGION ERSCHLIESSEN",func(): action(func(): Game.expand_region()))
 var district=card("Stadtviertel · %s/2" % Game.state.town.districts,"Ost- und Westviertel bieten je zwölf zusätzliche Bauplätze und acht weitere Industriebetriebe. Eine Zufahrt verbindet sie mit deinem Netz; die Straßen im Viertel legst du selbst an.")
 if int(Game.state.town.districts)<2:
  text(district,"%s Münzen · drei Regionen und 20 Bewohner" % Catalog.number(Game.district_cost()),15,GOLD)
  button(district,"NEUES STADTVIERTEL ERSCHLIESSEN",func(): action(func(): Game.expand_district()))
 for i in Catalog.PROJECTS.size():
  var index = i
  var p = Catalog.PROJECTS[i]
  var stage = int(Game.state.projects.get(str(i),0))
  var box = card("%s · %s/3" % [p.name,stage],"Fundament → Baukörper → Eröffnung. Erst nach drei abgeschlossenen Bauabschnitten entstehen dauerhaft %s Münzen/s." % p.income)
  if stage<3:
   var required = {}
   for key in p.materials: required[key] = float(p.materials[key])*(stage+1)
   text(box,"%s Münzen\n%s" % [Catalog.number(float(p.cost)*(stage+1)*Game.difficulty()),materials_text(required)],15,GOLD)
   button(box,"BAUABSCHNITT BEAUFTRAGEN",func(): action(func(): Game.order_project(index)),not Game.job_for("project",index))
  button(box,"IN DER WELT ANSEHEN",func(): focus_requested.emit(p.position); close_menu())
 jobs_cards()

func planner_menu() -> void:
 modal_title.text = "MATERIALPLANER"
 if Game.state.plan.is_empty():
  card("Wähle dein nächstes Bauziel","Öffne ein freies Grundstück, wähle einen Gebäudetyp und tippe auf „Als Bauziel vormerken“. Die Vormerkung selbst kostet nichts.")
  button(contents,"ZUR STADT",func(): open_menu("city"))
  return
 var plan = Game.state.plan
 var definition = Catalog.HOMES[plan.kind]
 var box = card("%s · Grundstück %s" % [definition.name,int(plan.plot)+1],"Benötigte Endprodukte werden vor automatischer Verarbeitung und Export geschützt. Rohstoffbedarf: Wand-/Dachmodule brauchen Trockenholz und Bretter; Bauelemente kommen aus der Tischlerei. Manuelle Verkäufe bleiben möglich.")
 dynamic_text(box,func(): return "Budget: %s / %s Münzen\n%s" % [Catalog.number(Game.state.coins),Catalog.number(float(definition.cost)*Game.difficulty()),materials_text(definition.materials)])
 button(box,"Automatisch beauftragen: AN" if plan.auto else "Automatisch beauftragen: AUS",func(): action(func(): Game.state.plan.auto = not Game.state.plan.auto))
 button(box,"JETZT BEAUFTRAGEN",func(): action(func(): Game.order_home(plan.kind,int(plan.plot))))
 button(box,"BAUZIEL ENTFERNEN",func(): action(func(): Game.state.plan = {}))

func research_menu() -> void:
 modal_title.text = "FORSCHUNGSZENTRUM"
 if Game.level("research") < 1: card("Forschungszentrum bauen","Im Industrie-Baukatalog freischalten. Danach stehen fünf Forschungsrichtungen bereit.")
 for key in Catalog.RESEARCH:
  var id = str(key)
  var box = card("%s · %s/12" % [Catalog.RESEARCH[key],Game.research_level(key)],{"production":"+12 % Verarbeitung pro Stufe","forestry":"+15 % automatische Holzgewinnung pro Stufe","logistics":"+12 % automatische Exportkapazität pro Stufe","loot":"+8 % Ticket-Fundchance pro Stufe","construction":"+12 % Baugeschwindigkeit pro Stufe"}[key])
  button(box,"FORSCHEN · %s" % Catalog.number(Game.research_cost(key)),func(): action(func(): Game.research_buy(id)),Game.level("research")>0 and Game.research_level(key)<12)

func boosters_menu() -> void:
 modal_title.text = "BOOSTER"
 for entry in [["money","Münz-Booster"],["loot","Loot-Booster"],["workers","Turbo-Arbeiter"],["processing","Turbo-Verarbeitung"]]:
  var key = str(entry[0])
  var box = card(str(entry[1]),"Zwei Minuten Laufzeit. Gilt auch während Offline-Fortschritt. Kein Echtgeld nötig.")
  dynamic_text(box,func(): return "Aktiv: %.0f× · %s Sekunden" % [Game.boost(key),int(Game.state.boosters.get(key,{"left":0}).left)])
  var choices = row(box)
  button(choices,"2× · 5 ◆",func(): action(func(): Game.buy_booster(key,2.0)))
  button(choices,"5× · 15 ◆",func(): action(func(): Game.buy_booster(key,5.0)))

func prestige_menu() -> void:
 modal_title.text = "UNTERNEHMENSÄRA"
 var box = card("Ära %s · %s Prestige-Punkte" % [int(Game.state.prestige)+1,Game.state.prestige_points],"Jede neue Ära bringt dauerhaft +25 % Geld und Produktion. Bau- und Erschließungskosten steigen um 60 %. Diamanten, Geldscheine, Mythic Tokens und Inventar bleiben. Grundstücke, Betriebe, Ressourcen, Forschung und Aufträge starten neu.")
 dynamic_text(box,func(): return "Gesamteinnahmen: %s / %s\nBiome: %s / mindestens 3" % [Catalog.number(Game.state.earned),Catalog.number(Game.prestige_requirement()),Game.state.unlocked])
 button(box,"NEUE ÄRA VORBEREITEN",func(): open_menu("confirm_prestige"),float(Game.state.earned)>=Game.prestige_requirement() and Game.state.unlocked>=3)

func confirm_prestige_menu() -> void:
 modal_title.text = "PRESTIGE BESTÄTIGEN"
 var box = card("Neues Unternehmen gründen?","Dein aktueller lokaler Betrieb und die Stadt werden zurückgesetzt. Dauerhafte Boni und die oben genannten permanenten Gegenstände bleiben erhalten. Dieser Schritt lässt sich im Spiel nicht rückgängig machen.")
 button(box,"JETZT NEUE ÄRA STARTEN",func(): action(func(): Game.prestige()); open_menu("prestige"))
 button(box,"ZURÜCK",func(): open_menu("prestige"))

func market_menu() -> void:
 modal_title.text = "LAGER & VERKAUF"
 var box = card("Kapazität: %s je Rohstoff" % Catalog.number(Game.capacity()),"Manuelle Verkäufe verwenden auch reservierte Vorräte. Die Baureserve schützt Material für neue Häuser. Die Spänebox lässt sich direkt unten oder am Sägewerk öffnen; ihr voller Behälter stoppt nie die Bretterproduktion.")
 button(box,"Baureserve: AN" if Game.state.reserve else "Baureserve: AUS",func(): action(func(): Game.state.reserve = not Game.state.reserve))
 button(box,"Auto-Export: AN" if Game.state.auto_export else "Auto-Export: AUS",func(): action(func(): Game.state.auto_export = not Game.state.auto_export))
 for key in Catalog.RESOURCES:
  if ConstructionRules.HARDWARE.has(key): continue
  var id = str(key)
  var resource_box = card(Catalog.RESOURCES[key])
  dynamic_text(resource_box,func(): return "%s im Lager · %.1f Münzen/Stück" % [Catalog.number(Game.state.resources[id]),float(Catalog.PRICES[id])*Game.multiplier()*Game.boost("money")])
  var choices = row(resource_box)
  button(choices,"25 % verkaufen",func(): action(func(): Game.sell(id,0.25)))
  button(choices,"Alles verkaufen",func(): action(func(): Game.sell(id)))

func settings_menu() -> void:
 modal_title.text = "EINSTELLUNGEN"
 var box = card("Lokaler Spielstand","Automatische Speicherung alle 20 Sekunden, beim Wechsel in den Hintergrund und nach Bauaufträgen. Eine Backup-Datei schützt den vorherigen gültigen Stand. Bis zu acht Stunden Offline-Wirtschaft.")
 button(box,"JETZT SPEICHERN",func(): Game.save())
 button(box,"Sounds: AUS" if Game.state.muted else "Sounds: AN",func(): action(func(): Game.state.muted = not Game.state.muted))
 button(box,"Benno: AN" if Game.state.companion_enabled else "Benno: AUS",func(): action(func(): Game.state.companion_enabled=not Game.state.companion_enabled))
 button(box,"Alltagsszenen: AN" if Game.state.ambient_enabled else "Alltagsszenen: AUS",func(): action(func(): Game.state.ambient_enabled=not Game.state.ambient_enabled))
 button(box,"Qualität: AKKUMODUS" if Game.state.quality == 0 else "Qualität: STANDARD",func(): action(func(): Game.state.quality = 1-int(Game.state.quality)))
 text(contents,"Version 0.17.0 · Stein & Holz\nKeine Werbung, keine In-App-Käufe, kein Cloud-Save. Geräteleistung und langfristige Balance werden separat geprüft.",14,MUTED)

func build_placement_bar() -> void:
 placement_panel=PanelContainer.new()
 add_child(placement_panel)
 placement_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 placement_panel.offset_left=14
 placement_panel.offset_right=-14
 placement_panel.offset_top=-390
 placement_panel.offset_bottom=-202
 placement_panel.add_theme_stylebox_override("panel",style(INK,20))
 var box=VBoxContainer.new()
 placement_panel.add_child(box)
 placement_title=text(box,"",20,GOLD)
 placement_hint=text(box,"",14,CREAM)
 placement_materials=text(box,"",13,MUTED)
 var choices=row(box)
 button(choices,"Abbrechen",func(): placement_action.emit("cancel"))
 placement_rotate=button(choices,"Drehen 90°",func(): placement_action.emit("rotate"))
 placement_confirm=button(choices,"BAUEN",func(): placement_action.emit("confirm"))
 placement_confirm.add_theme_stylebox_override("normal",style(Color("e2a536"),12))
 placement_panel.hide()

func request_placement(request: Dictionary) -> void:
 close_menu()
 placement_requested.emit(request)

func show_placement(request: Dictionary) -> void:
 close_menu()
 placement_rotate.text="Drehen 90°"
 placement_rotate.disabled=false
 if request.get("network",false):
  placement_materials.text=""
  placement_title.text="HALTESTELLE" if request.kind=="bus_stop" else "STRASSE / WEG"
  placement_confirm.text="BAUEN"
  placement_rotate.text="Kurve wechseln"
  placement_rotate.disabled=request.kind=="bus_stop"
  placement_panel.show()
  return
 var city=bool(request.get("city",false))
 var definition=(Catalog.HOMES if city else Catalog.BUILDINGS)[request.kind]
 var moving=int(request.get("index",-1))>=0
 var price=0.0 if moving else float(definition.cost)*Game.difficulty() if city else Game.cost_for(request.kind)
 placement_title.text="%s · %s" % [definition.name,"kostenlos verschieben" if moving else Catalog.number(price)+" Münzen"]
 var materials={} if moving else definition.materials if city else Game.build_materials(request.kind) if Game.company_level()>=4 else {}
 placement_materials.text="" if materials.is_empty() else ("Später per LKW: " if Game.company_level()>=4 else "Beim Bau bezahlen: ")+materials_text(materials)
 placement_confirm.text="SETZEN" if moving else "BAUEN"
 placement_panel.show()

func update_placement(reason: String) -> void:
 placement_hint.text="Standort frei · tippen oder ziehen, dann bestätigen" if reason.is_empty() else reason
 placement_confirm.disabled=not reason.is_empty()

func hide_placement() -> void:
 if placement_panel!=null: placement_panel.hide()

func sawdust_menu() -> void:
 modal_title.text="DEINE SPÄNEBOX"
 var box=card("Aus Sägespänen wird Geld","Leere den Behälter regelmäßig per Verkauf. Pellet- und Papierfabriken können den gespeicherten Vorrat weiterverarbeiten. Ein voller Behälter blockiert niemals das Sägewerk.")
 dynamic_text(box,func(): return "%s / %s Sägespäne · %s %% gefüllt\nVerkaufserlös: %s Münzen" % [Catalog.number(Game.state.resources.sawdust),Catalog.number(Game.capacity()),int(100*float(Game.state.resources.sawdust)/Game.capacity()),Catalog.number(float(Game.state.resources.sawdust)*float(Catalog.PRICES.sawdust)*Game.multiplier()*Game.boost("money"))])
 button(box,"BEHÄLTER LEEREN & VERKAUFEN",func(): action(func(): Game.sell("sawdust")))
 text(box,"Bei voller Box wird nur neuer Überlauf kompostiert, bis du Platz schaffst. Optional kannst du neuen Überlauf automatisch verkaufen lassen. Der gesammelte Vorrat bleibt immer erhalten.",15,MUTED)
 button(box,"Überlauf-Autoverkauf: AN" if Game.state.auto_sawdust else "Überlauf-Autoverkauf: AUS",func(): action(func(): Game.state.auto_sawdust=not Game.state.auto_sawdust))

func welcome_menu() -> void:
 modal_title.text="WILLKOMMEN IM WALD"
 var illustration=TextureRect.new()
 illustration.texture=load("res://Assets/Brand/timber-beaver.jpg")
 illustration.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 illustration.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 illustration.custom_minimum_size=Vector2(0,210)
 illustration.mouse_filter=Control.MOUSE_FILTER_IGNORE
 contents.add_child(illustration)
 var box=card("Dein erstes Holz. Dein eigenes Imperium.","Aus einer kleinen Forststation wird deine lebendige Industriestadt. Du bestimmst, wo neue Gebäude stehen und wie dein Betrieb wächst.")
 text(box,"1  Bäume fällen und Holz abliefern\n2  Bretter und Möbel herstellen und liefern\n3  Gebäude platzieren, Baumaterial liefern und ausbauen\n4  Häuser bauen und neue Regionen erschließen",18,CREAM)
 button(box,"LOS GEHT’S · KURZE ANLEITUNG",func(): Game.state.tutorial=1; Game.save(true); update_stats(); close_menu(); focus_requested.emit(Catalog.biome_position(int(Game.state.biome))))
 button(box,"Ich kenne mich aus · überspringen",func(): Game.state.tutorial=5; Game.save(true); update_stats(); close_menu())

func guide_menu() -> void:
 if int(Game.state.tutorial)==0: welcome_menu(); return
 modal_title.text="DEIN WEG ZUM IMPERIUM"
 var step=mini(int(Game.state.tutorial),4)
 var box=card("Schritt %s / 4" % step,["","Tippe auf Fällen oder auf Bäume. Nach fünf gefällten Bäumen geht es weiter.","Tippe auf Abliefern. Dein Rucksack wird in das Holzlager geleert; Helfer liefern zusätzlich automatisch.","Öffne Verkaufen und verkaufe etwas Holz oder Bretter. Missionsprämien helfen beim ersten Ausbau.","Öffne Bauen, wähle ein Gebäude und platziere es in der Welt. Grün bedeutet frei; Rot zeigt Straßen oder belegte Flächen."][step])
 button(box,"WEITER SPIELEN",func(): close_menu())
 var help=card("So funktioniert deine Produktion","Holz → Sägewerk → Bretter → Trockenkammer → Trockenholz → Möbelfabrik → Möbel. LKWs verkaufen Möbel automatisch. Tippe direkt auf ein Gebäude für Zustand, Ausbau und Verschieben. LKWs verbinden die Betriebe über das Straßennetz.")
 text(help,"Spänebox: regelmäßig leeren und verkaufen. Bei Störungen zeigt das Betriebsfenster den konkreten Grund. Mit einem Finger die Welt bewegen, mit zwei Fingern zoomen. Im Baumodus bewegt ein Finger das Bauwerk; zwei Finger bewegen die Kamera.",15,MUTED)
 button(help,"LIEFERKETTE & LADENAUFTRÄGE",func(): open_menu("delivery"))
 button(help,"BAUSTELLEN & MATERIALDEPOT",func(): open_menu("construction"))
 button(help,"BAUKATALOG ÖFFNEN",func(): open_menu("catalog"))
 if int(Game.state.tutorial)<5: button(help,"ANLEITUNG ÜBERSPRINGEN",func(): Game.state.tutorial=5; Game.save(true); update_stats(); close_menu())


func networks_menu() -> void:
 modal_title.text="STRASSEN & WEGE"
 card("Dein eigenes Wegenetz","Startpunkt antippen, Ziel antippen oder ziehen, Kurve wählen und bestätigen. Zwei Finger bewegen die Karte. Straßen müssen an das vorhandene Netz anschließen; Fußwege dürfen auch frei liegen. Gebäude und Wasser bleiben frei.")
 var links=row(contents)
 button(links,"Stadt",func(): open_menu("city"))
 button(links,"Buslinien",func(): open_menu("transit"))
 for kind in TownRules.TYPES:
  var key=str(kind)
  var d=TownRules.TYPES[kind]
  var box=card(d.name,"%s Münzen je Meter · bezahlt wird nur neu gebaute Strecke" % Catalog.number(float(d.price)*Game.difficulty()))
  button(box,"STRECKE ZEICHNEN",func(): request_placement({"network":true,"kind":key}))
 text(contents,"%s / 48 eigene Strecken. Entfernen erstattet keine Baukosten. Haltestellen und laufende Linien bleiben geschützt." % Game.state.town.roads.size(),15,MUTED)
 for i in Game.state.town.roads.size():
  var index=i
  var record=Game.state.town.roads[i]
  var box=card("%s %s" % [TownRules.TYPES[record.kind].name,i+1],"%s Meter" % ((record.cells.size()-1)*4))
  var choices=row(box)
  button(choices,"ANSEHEN",func(): focus_requested.emit(TownRules.point(TownRules.cell(record.cells[0]))); close_menu())
  button(choices,"ENTFERNEN",func(): action(func(): Game.remove_road(index)))

func transit_menu() -> void:
 modal_title.text="BUS & HALTESTELLEN"
 card("Die Stadt kommt in Bewegung","Baue mindestens zwei Haltestellen an verbundenen Straßen. Wähle sie in Fahrreihenfolge und kaufe einen Bus. Er hält vier Sekunden, fährt alle Stationen und kehrt zurück. Ab vier Bewohnern startet der Linienbetrieb.")
 var nav=row(contents)
 button(nav,"Straßen bauen",func(): open_menu("networks"))
 button(nav,"HALTESTELLE · %s" % Catalog.number(300*Game.difficulty()),func(): request_placement({"network":true,"kind":"bus_stop"}),Game.state.town.stops.size()<8)
 text(contents,"Neue Linie · Haltestellen in der gewünschten Reihenfolge antippen",16,GOLD)
 var valid_ids=[]
 for stop in Game.state.town.stops: valid_ids.append(int(stop.id))
 route_selection=route_selection.filter(func(id): return id in valid_ids)
 for stop in Game.state.town.stops:
  var id=int(stop.id)
  var selected=route_selection.find(id)
  var box=card(stop.name)
  var choices=row(box)
  button(choices,"%s · AUSWÄHLEN" % (str(selected+1) if selected>=0 else "○"),func():
   if id in route_selection: route_selection.erase(id)
   else: route_selection.append(id)
   render_menu())
  button(choices,"ANSEHEN",func(): focus_requested.emit(TownRules.point(TownRules.cell(stop.cell))); close_menu())
  button(box,"Haltestelle entfernen",func(): action(func(): Game.remove_stop(id)))
 var planned=Game.transit_plan(route_selection)
 if not planned.is_empty():
  text(contents,"Rundfahrt: %s Sekunden · bis zu 12 Fahrgäste
Ertrag nach Betriebskosten: %s Münzen je Runde" % [ceili(planned.duration),Catalog.number(Game.bus_profit({"stops":route_selection},planned))],15,MUTED)
 button(contents,"BUS KAUFEN & LINIE STARTEN · %s" % Catalog.number(1800*Game.difficulty()),func():
  if Game.create_bus_line(route_selection): route_selection.clear()
  Game.save(true)
  render_menu(),not planned.is_empty() and Game.state.town.lines.size()<3 and Game.residents()>=4)
 for i in Game.state.town.lines.size():
  var index=i
  var line=Game.state.town.lines[i]
  var plan=Game.transit_plan(line.stops)
  var box=card("Linie %s · %s Stationen" % [line.id,line.stops.size()])
  dynamic_text(box,func(): return "%s Rundfahrten · %s Münzen verdient" % [line.trips,Catalog.number(line.income)])
  if plan.is_empty(): text(box,"Straßenverbindung fehlt",15,GOLD)
  button(box,"BUS ANSEHEN",func():
   focus_requested.emit(TownRules.bus_sample(plan,float(line.phase)).position)
   close_menu())
  button(box,"LINIE EINSTELLEN · keine Erstattung",func(): action(func(): Game.remove_bus_line(index)))


func delivery_order_text() -> String:
 var data = Game.state.delivery
 if not data.active: return "Noch kein Lieferbetrieb eröffnet"
 var order = data.order
 var seconds = ceili(order.left)
 return "Laden: %s/%s Möbel · %s\n%s" % [int(order.delivered),int(order.amount),"Verspätet · 70 % Verkaufspreis" if order.late else "%02d:%02d bis Bonusende" % [int(seconds/60.0),seconds%60],"Lieferbetrieb pausiert" if data.paused else data.last_receipt]

func delivery_menu() -> void:
 modal_title.text = "DEIN LIEFERBETRIEB"
 var help = card("Aus deinem Holz werden Möbel","Kleine Lieferkette: Sammelstation → Sägewerk (2 Holz → 1 Brett) → Möbelfabrik (2 Bretter → 1 Möbel) → Verkaufsstelle. Material im Fahrzeug gehört noch nicht zum Zielgebäude.")
 var data = Game.state.delivery
 if not data.active:
  text(help,"Der erste betriebsbereite Betrieb jeder Art wird dieser Linie zugeordnet. Die beiden Fabriken arbeiten dann mit eigenen Puffern; weitere Betriebe behalten ihre bisherigen Rezepte. Für diese einfache Möbellinie ist keine Trockenkammer nötig.",15,MUTED)
  for kind in DeliveryChain.KINDS:
   text(help,"%s · %s" % [Catalog.BUILDINGS[kind].name,"vorhanden" if Game.count(kind)>0 else "noch bauen"],16,CREAM)
  button(help,"LIEFERBETRIEB ERÖFFNEN",func(): action(func(): Game.start_delivery()),Game.count("furniture")>0)
  button(help,"MÖBELFABRIK BAUEN",func(): request_placement({"kind":"furniture","city":false,"index":-1,"plot":-1}))
  button(help,"BAUMATERIAL BESORGEN",func(): open_menu("construction"))
  return
 var demand = card("Ladenauftrag %s" % (int(data.orders)+1),"Innerhalb der Frist: voller Verkaufspreis, Abschlussbonus und ein Loot-Ticket. Nach Ablauf wird derselbe Auftrag zu 70 % des Verkaufspreises weiter beliefert. Kein Geldverlust und kein Game Over.")
 dynamic_text(demand,func(): return delivery_order_text())
 text(demand,"%s pünktlich · %s verspätet · %s Möbel verkauft" % [data.on_time,data.late_orders,data.sold],15,MUTED)
 button(demand,"FORTSETZEN" if data.paused else "LIEFERBETRIEB PAUSIEREN",func(): action(func(): data.paused = not data.paused))
 var routes = Game.delivery_routes()
 for kind in DeliveryChain.KINDS:
  var key = str(kind)
  var index = int(data.nodes[kind])
  var building = Game.state.buildings[index]
  var box = card(Catalog.BUILDINGS[kind].name+" · Stufe %s" % building.level)
  dynamic_text(box,func():
   var buf = Game.state.delivery.buffers[key]
   return "Lokaler Vorrat: Holz %s · Bretter %s · Möbel %s\nPuffer je Ware: %s" % [Catalog.number(buf.wood),Catalog.number(buf.boards),Catalog.number(buf.furniture),int(DeliveryChain.capacity(Game.state,key))])
  if kind!="station" and routes.get(kind,[]).size()<2: text(box,"Keine freie Verbindung · Betrieb näher ans Straßennetz setzen",15,Color("b33f32"))
  var actions = row(box)
  button(actions,"ANSEHEN / AUSBAUEN",func(): show_building(index))
  button(actions,"INS LAGER HOLEN",func(): action(func(): Game.unload_delivery(key)))
 var freight = card("Unterwegs · %s Fahrzeuge" % int(Game.state.trucks),"Lieferfahrzeuge bleiben während der leeren Rückfahrt belegt. Voller Zielpuffer reserviert Platz für ankommende Ware und verhindert Überladung.")
 dynamic_text(freight,func(): return "%s aktive Lieferungen" % Game.state.delivery.shipments.size())
 button(freight,"GARAGE",func(): open_menu("garage"))
 button(contents,"LINIE AUFLÖSEN & VORRÄTE ZURÜCKHOLEN",func(): action(func(): Game.stop_delivery()))

func construction_menu() -> void:
 modal_title.text = "BAUSTELLEN & MATERIAL"
 var help = card("Erst Material. Dann Richtfest.","Neue Fabriken und Ausbaustufen brauchen Holz, Bretter und Bauteile. Jede Bauphase startet erst mit ihren angelieferten Materialien.")
 button(help,"AUTO-LOGISTIK AB LEVEL 10" if Game.company_level()<10 else "Automatisch anliefern: AN" if Game.state.construction_auto else "Automatisch anliefern: AUS",func(): action(func(): Game.state.construction_auto = not Game.state.construction_auto),Game.company_level()>=10)
 if Game.state.jobs.is_empty(): card("Keine offenen Baustellen","Im Baukatalog ein Gebäude platzieren oder auf einen Betrieb tippen und Ausbauen wählen.")
 else: jobs_cards()
 var crew=card("Bauteam: %s · %s frei" % [Game.state.builders,Game.free_builders()],"Ab Unternehmenslevel 4 arbeiten bis zu fünf zugewiesene Bauarbeiter pro Baustelle. Weitere Kollegen kosten Spielmünzen.")
 button(crew,"BAUARBEITER EINSTELLEN · %s" % Catalog.number(150*pow(1.6,int(Game.state.builders)-2)*Game.difficulty()),func(): action(func(): Game.hire_builder()),Game.company_level()>=4 and int(Game.state.builders)<8)
 if Game.company_level()<4: text(crew,"Dein Level: %s/4 · Neue Betriebe und Upgrades benötigen bis dahin nur Geld." % Game.company_level(),15,MUTED)
 var depot = card("Materialdepot · nur Spielmünzen","Muttern und Schrauben werden hier mit erspielten Münzen gekauft. Holz und Bretter liefert deine Produktion.")
 for key in ConstructionRules.HARDWARE:
  var id = str(key)
  dynamic_text(depot,func(): return "%s: %s im Lager · %s Münzen/Stück" % [Catalog.RESOURCES[id],Catalog.number(Game.state.resources[id]),Catalog.number(float(ConstructionRules.HARDWARE[id])*Game.difficulty())])
  var choices = row(depot)
  button(choices,"1 KAUFEN",func(): action(func(): Game.buy_hardware(id,1)))
  button(choices,"10 KAUFEN",func(): action(func(): Game.buy_hardware(id,10)))
 button(contents,"STEINBRUCH & BAUSTOFFE",func(): open_menu("stone"))
 card("So wird geliefert","Der Bauauftrag wird beim Platzieren bezahlt. Ein Transportfahrzeug nimmt tatsächlichen Vorrat am Lager auf, fährt über Straßen zur Baustelle, entlädt und kehrt leer zurück. Belegte Fahrzeuge fehlen an der Möbellinie. Automatik kauft keine Teile. Material bleibt für den Bau geschützt. Laufende alte Baustellen bleiben gültig.")
 button(contents,"BAUKATALOG",func(): open_menu("catalog"))


func services_menu() -> void:
 modal_title.text="LEBEN IN DEINER STADT"
 var data=Game.state.city_services
 var box=card("Deine Gemeindedienste","Polizei hilft in der Nachbarschaft, Feuerwehr prüft Rauchmelder und Rettungswagen leisten Erste Hilfe. Taxis holen Fahrgäste ab und bringen sie zu ihren Zielen. Ohne eigene Wache kommt die Gemeinde von der westlichen Zufahrt.")
 button(box,"Neue Fahrten: AN" if data.enabled else "Neue Fahrten: AUS",func(): action(func(): data.enabled=not data.enabled))
 dynamic_text(box,func(): return "%s aktive Fahrten · %s Spaziergänger\nStadtkasse: %s Münzen" % [data.missions.size(),data.walkers.size(),Catalog.number(float(data.treasury)*Game.multiplier())])
 button(box,"STADTKASSE ABHOLEN",func(): action(func(): Game.collect_city_income()))
 text(box,"Fahrgeld und Gemeindebonus entstehen erst nach erledigter Fahrt beziehungsweise Hilfe vor Ort. Laufende Fahrten enden auch bei ausgeschalteten neuen Aufträgen. Offline bleibt die Simulation aktiv.",14,MUTED)
 for kind in CityServices.TYPES:
  var key=str(kind)
  var definition=Catalog.HOMES[CityServices.BUILDINGS[kind]]
  var card_box=card({"police":"Polizei","fire":"Feuerwehr","ambulance":"Rettungsdienst","taxi":"Taxi"}[kind],"Eigener Standort: "+definition.name+". Kürzere Wege und mit höherem Gebäudelevel mehr gleichzeitig verfügbare Dienstfahrzeuge.")
  dynamic_text(card_box,func(): return "%s abgeschlossene Aufträge" % int(data.completed.get(key,0)))
  button(card_box,"FAHRT ANFORDERN",func(): action(func(): Game.request_city_service(key)))
  button(card_box,"STANDORT BAUEN",func(): request_placement({"kind":CityServices.BUILDINGS[key],"city":true,"index":-1,"plot":-1}),Game.level("prefab")>0)
 for mission in data.missions:
  var job=mission
  var entry=card(CityServices.NAMES[job.kind])
  var focus_button=button(entry,"FAHRZEUG ANSEHEN",func():
   if not job in data.missions: return
   focus_requested.emit(CityServices.sample(job).position)
   close_menu())
  dynamic_text(entry,func():
   focus_button.disabled=not job in data.missions
   return "%s · %s s bis Rückkehr" % [CityServices.sample(job).status,maxi(0,ceili(float(job.total)-float(job.age)))] if job in data.missions else "Auftrag abgeschlossen · Bonus in der Stadtkasse")


func stone_site_controls(parent: Node, index: int) -> void:
 StoneIndustry.synchronize(Game.state)
 var b=Game.state.buildings[index]
 var data=StoneIndustry.site(Game.state,index)
 dynamic_text(parent,func(): return "Lokales Lager · %s je Material\nGestein %s · Bausteine %s · Kies %s" % [int(StoneIndustry.capacity(Game.state,index)),int(data.stock.rock),int(data.stock.stone),int(data.stock.gravel)])
 if b.kind=="quarry":
  var vein_button=button(parent,"NEUE FELSADER · %s MÜNZEN" % Catalog.number(Game.vein_cost(index)),func(): action(func(): Game.explore_vein(index)))
  dynamic_text(parent,func():
   vein_button.disabled=float(data.reserve)>0 or float(data.bucket)>0
   return "Vorkommen: %s/%s · Schaufel: %s\nEine neue Felsader kann nach Erschöpfung mit Spielmünzen erschlossen werden." % [int(data.reserve),int(data.vein_size),int(data.bucket)])
 else:
  dynamic_text(parent,func(): return "Nächster Auftrag: "+StoneIndustry.definitions.recipes[data.recipe].name+". Ein laufender Arbeitsgang wird zuerst abgeschlossen.")
  var choices=row(parent)
  for key in StoneIndustry.definitions.recipes:
   var id=str(key)
   var recipe=StoneIndustry.definitions.recipes[id]
   button(choices,recipe.name,func(): action(func(): Game.set_stone_recipe(index,id)))
 button(parent,"STEINKETTE ANSEHEN",func(): open_menu("stone"))

func stone_menu() -> void:
 modal_title.text="STEINBRUCH & BAUSTOFFE"
 var unlocked=Game.company_level()>=5
 card("Holz bleibt dein Fundament","Ab Unternehmenslevel 5: Steinbruch bauen → Steinwerk bauen → Muldenkipper liefern Gestein → Bausteine oder Kies herstellen → LKWs bringen fertige Ware ins Lager. Dort kann sie verkauft oder zu Materialbaustellen geliefert werden. Alle Güterfahrten teilen deinen gekauften Fuhrpark. Beide Betriebe brauchen eine erreichbare Straße. Baue bei entlegenen Grundstücken zuerst eine Zufahrt.")
 if not unlocked: text(contents,"Dein Unternehmenslevel: %s/5. Bäume, neue Gebäude und Ausbauten liefern Erfahrung." % Game.company_level(),16,GOLD)
 var choices=row(contents)
 for kind in StoneIndustry.KINDS:
  var key=str(kind)
  button(choices,Catalog.BUILDINGS[key].name+" BAUEN",func(): request_placement({"kind":key,"city":false,"index":-1}),unlocked)
 dynamic_text(contents,func(): return "%s LKW für Holz, Stein und Baustellen · %s Steinfahrten aktiv\nBaustoffe im Lager: %s Bausteine · %s Kies" % [Game.state.trucks,Game.state.stone.shipments.size(),int(Game.state.resources.stone),int(Game.state.resources.gravel)])
 button(contents,"GARAGE & FAHRZEUGE",func(): open_menu("garage"))
 for i in Game.state.buildings.size():
  if Game.state.buildings[i].kind not in StoneIndustry.KINDS: continue
  var index=i
  var b=Game.state.buildings[index]
  var box=card("%s · Stufe %s/10" % [Catalog.BUILDINGS[b.kind].name,int(b.level)])
  dynamic_text(box,func(): return Game.production_status(index))
  stone_site_controls(box,index)
  button(box,"ANSEHEN & AUSBAUEN",func(): show_building(index))
 var trader=card("Baustoffhändler · nur Spielmünzen","Notversorgung für neue Bauaufträge. Eigene Produktion ist günstiger. Du kannst den ersten Steinbruch und das erste Steinwerk mit Holz, Brettern und einfachen Teilen errichten; sie benötigen noch keine eigenen Steinprodukte.")
 for key in StoneIndustry.definitions.trader:
  var id=str(key)
  dynamic_text(trader,func(): return "%s: %s im Lager · %s Münzen/Stück" % [Catalog.RESOURCES[id],int(Game.state.resources[id]),Catalog.number(Game.stone_trader_price(id))])
  var buttons=row(trader)
  button(buttons,"1 KAUFEN",func(): action(func(): Game.buy_stone_material(id,1)),unlocked)
  button(buttons,"10 KAUFEN",func(): action(func(): Game.buy_stone_material(id,10)),unlocked)
 button(contents,"BAUSTELLEN & LIEFERUNGEN",func(): open_menu("construction"))
