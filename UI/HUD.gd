extends Control

signal camera_action(action: String)
signal focus_requested(point: Vector3)

const INK = Color("193e45")
const PANEL = Color("244b52")
const GOLD = Color("f4cd79")
const CREAM = Color("fff5da")
const MUTED = Color("b5d2cb")
var money: Label
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

func style(color: Color, radius: int = 18) -> StyleBoxFlat:
 var s = StyleBoxFlat.new()
 s.bg_color = color
 s.corner_radius_top_left = radius
 s.corner_radius_top_right = radius
 s.corner_radius_bottom_left = radius
 s.corner_radius_bottom_right = radius
 s.content_margin_left = 15
 s.content_margin_right = 15
 s.content_margin_top = 12
 s.content_margin_bottom = 12
 return s

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
 design.set_stylebox("pressed","Button",style(INK,13))
 design.set_stylebox("disabled","Button",style(Color("385457"),13))
 design.set_stylebox("focus","Button",style(PANEL.lightened(0.15),13))
 theme = design
 var header = PanelContainer.new()
 add_child(header)
 header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 header.offset_left = 14
 header.offset_right = -14
 header.offset_top = 14
 header.offset_bottom = 138
 header.add_theme_stylebox_override("panel",style(INK,24))
 var top = VBoxContainer.new()
 header.add_child(top)
 var brand = row(top)
 var title = text(brand,"TIMBER LOOT",26)
 title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 text(brand,"REBUILD / 07",12,GOLD)
 money = text(top,"",23,GOLD)
 subtitle = text(top,"",13,MUTED)
 mission_button = button(self,"",func(): open_menu("missions"))
 mission_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 mission_button.offset_left = 14
 mission_button.offset_right = -14
 mission_button.offset_top = 146
 mission_button.offset_bottom = 192
 var right = VBoxContainer.new()
 add_child(right)
 right.anchor_left = 1
 right.anchor_right = 1
 right.offset_left = -66
 right.offset_right = -14
 right.offset_top = 220
 for entry in [["+","+"],["−","−"],["⌂","home"],["▦","world"]]:
  var action = str(entry[1])
  button(right,str(entry[0]),func(): camera_action.emit(action)).custom_minimum_size = Vector2(48,48)
 var bottom = VBoxContainer.new()
 add_child(bottom)
 bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 bottom.offset_left = 14
 bottom.offset_right = -14
 bottom.offset_top = -220
 bottom.offset_bottom = -18
 bottom.add_theme_constant_override("separation",8)
 var strip = PanelContainer.new()
 strip.add_theme_stylebox_override("panel",style(INK,17))
 bottom.add_child(strip)
 supply = text(strip,"",14,CREAM)
 supply.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 supply.custom_minimum_size.y = 35
 var actions = row(bottom)
 var chop = button(actions,"FÄLLEN",func(): Game.chop())
 chop.add_theme_stylebox_override("normal",style(GOLD,14))
 chop.add_theme_color_override("font_color",INK)
 button(actions,"Abliefern",func(): Game.deposit())
 button(actions,"Verkaufen",func(): open_menu("market"))
 var navigation = row(bottom)
 for entry in [["Industrie","industry"],["Stadt","city"],["Aufträge","contracts"],["Welt","world"],["Mehr","more"]]:
  var tab = str(entry[1])
  var nav_button = button(navigation,str(entry[0]),func(): open_menu(tab))
  nav_button.add_theme_font_size_override("font_size",14)
 toast = text(self,"",16,CREAM)
 toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
 toast.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 toast.offset_left = 20
 toast.offset_right = -20
 toast.offset_top = -272
 toast.offset_bottom = -224
 toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 toast.add_theme_color_override("font_shadow_color",INK)
 toast.add_theme_constant_override("shadow_offset_x",1)
 toast.add_theme_constant_override("shadow_offset_y",2)
 build_overlay()
 Game.changed.connect(update_stats)
 Game.notice.connect(show_notice)
 Game.rebuild_world.connect(func(): if overlay.visible: call_deferred("render_menu"))
 update_stats()
 if not Game.offline_report.is_empty(): show_notice(Game.offline_report)
 else: show_notice("Willkommen zurück im Wald. Fälle Holz, baue dein Imperium.")

func build_overlay() -> void:
 overlay = PanelContainer.new()
 add_child(overlay)
 overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 overlay.offset_left = 14
 overlay.offset_right = -14
 overlay.offset_top = 204
 overlay.offset_bottom = -228
 overlay.add_theme_stylebox_override("panel",style(INK,22))
 var container = VBoxContainer.new()
 container.add_theme_constant_override("separation",12)
 overlay.add_child(container)
 var heading = row(container)
 modal_title = text(heading,"",23,GOLD)
 modal_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 var close_button = button(heading,"×",func(): close_menu())
 close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
 close_button.custom_minimum_size.x = 46
 scroll = ScrollContainer.new()
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
 label.add_theme_color_override("font_color",color)
 label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 parent.add_child(label)
 return label

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
 panel.add_theme_stylebox_override("panel",style(PANEL,16))
 contents.add_child(panel)
 var box = VBoxContainer.new()
 box.add_theme_constant_override("separation",8)
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
 money.text = "%s MÜNZEN    ◆ %s    ▣ %s" % [Catalog.number(Game.state.coins),Game.state.diamonds,Game.state.tickets]
 subtitle.text = "%s · Rucksack %s/%s · Team %s" % [Catalog.TOOLS[int(Game.state.tool)],int(Game.state.bag),int(Game.bag_capacity()),Game.state.workers]
 supply.text = "HOLZ %s  →  BRETTER %s  →  TROCKEN %s\nMÖBEL %s · %s LKW · %02d:00 · %s" % [Catalog.number(Game.state.resources.wood),Catalog.number(Game.state.resources.boards),Catalog.number(Game.state.resources.dry),Catalog.number(Game.state.resources.furniture),Game.state.trucks,int(Game.state.time),["Sonnig","Wolkig","Regen","Nebel"][int(Game.state.weather)]]
 mission_button.text = "MISSIONEN · Dein nächster Meilenstein"
 for m in Game.mission_definitions():
  if not Game.state.missions_claimed.has(m.id):
   mission_button.text = "%s · %s/%s %s" % [m.name,Catalog.number(m.value),Catalog.number(m.target),"ABHOLEN" if m.value >= m.target else "›"]
   break

func _process(delta: float) -> void:
 toast_left -= delta
 toast.modulate.a = clampf(toast_left,0,1)
 refresh_clock += delta
 if refresh_clock >= 1.0:
  refresh_clock = 0
  for item in live_labels:
   if is_instance_valid(item.label): item.label.text = item.callback.call()

func _unhandled_key_input(event: InputEvent) -> void:
 if event.is_action_pressed("ui_cancel") and overlay.visible:
  close_menu()
  get_viewport().set_input_as_handled()

func open_menu(tab: String) -> void:
 current = tab
 scroll.scroll_vertical = 0
 overlay.show()
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
  "industry": industry_menu()
  "building": building_menu()
  "catalog": catalog_menu()
  "team": team_menu()
  "garage": garage_menu()
  "city": city_menu()
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
  "confirm_prestige": confirm_prestige_menu()
 scroll.set_deferred("scroll_vertical",old_scroll)

func industry_menu() -> void:
 modal_title.text = "DEINE INDUSTRIE"
 var help = card("Vom Wald zum Imperium","Fälle Holz und liefere es ab. Helfer füllen das Lager automatisch. Baue zuerst Trockenkammer und Möbelfabrik; danach das Fertighauswerk für deine Stadt.")
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
  var box = card("Baustelle · %s" % (Catalog.HOMES[job.kind].name if job.type in ["home","home_upgrade"] else Catalog.BUILDINGS[job.kind].name))
  dynamic_text(box,func():
   var progress = 1-float(job.left)/float(job.total)
   return "%s · %s Sekunden" % [["Anlieferung","Fundament","Rohbau","Dach","Innenausbau"][mini(int(progress*5),4)],ceili(job.left)])

func catalog_menu() -> void:
 modal_title.text = "BAUEN & ERWEITERN"
 text(contents,"16 Industrieflächen. Mehrere Betriebe derselben Art arbeiten gemeinsam und lassen sich einzeln verbessern.",15,MUTED)
 for kind in Catalog.BUILDINGS:
  var key = str(kind)
  var d = Catalog.BUILDINGS[kind]
  var unlocked = Game.available(kind)
  var box = card(d.name,d.desc)
  text(box,"Kosten: %s Münzen · %s vorhanden" % [Catalog.number(Game.cost_for(kind)),Game.count(kind)],15,GOLD)
  if not unlocked: text(box,"Benötigt die vorherige Produktionsstufe.",14,MUTED)
  button(box,"BAU BEAUFTRAGEN",func(): action(func(): Game.order_building(key)),unlocked)

func building_menu() -> void:
 if current_index < 0 or current_index >= Game.state.buildings.size(): return
 var index = current_index
 var b = Game.state.buildings[index]
 var d = Catalog.BUILDINGS[b.kind]
 modal_title.text = d.name.to_upper()
 var box = card("Stufe %s / %s" % [b.level,d.max],d.desc)
 dynamic_text(box,func(): return "Produktion: %.2f Zyklen/s" % float(Game.flow.get(b.kind,0)))
 text(box,"Ausbau: %s Münzen" % Catalog.number(Game.cost_for(b.kind,int(b.level)+1)),17,GOLD)
 button(box,"AUSBAUEN" if not Game.job_for("upgrade",index) else "AUSBAU LÄUFT",func(): action(func(): Game.upgrade(index)),not Game.job_for("upgrade",index) and b.level < d.max)
 if Catalog.RECIPES.has(b.kind):
  button(box,"Produktion fortsetzen" if b.paused else "Produktion pausieren",func(): action(func(): b.paused = not b.paused))
 button(box,"IN DER WELT ANSEHEN",func(): focus_requested.emit(Catalog.industry_position(int(b.get("slot",index)))); close_menu())
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

func garage_menu() -> void:
 modal_title.text = "VEHICLE GARAGE"
 var box = card("%s LKW unterwegs" % Game.state.trucks,"Export wird automatisch aus dem Möbelbestand bezahlt. Ein LKW transportiert je Marktstufe 15 Möbel pro Minute. Garage schafft weitere Stellplätze.")
 button(box,"LKW KAUFEN · %s" % Catalog.number(Game.truck_cost()),func(): action(func(): Game.buy_truck()))
 var vehicle = card(Catalog.VEHICLES[int(Game.state.vehicle)],"Fahrzeugverbesserungen erhöhen Rucksack, Exportkapazität und sichtbare Fahrgeschwindigkeit.")
 if Game.state.vehicle < 9:
  button(vehicle,"NÄCHSTE STUFE · %s" % Catalog.number(Game.vehicle_cost()),func(): action(func(): Game.upgrade_vehicle()))

func city_menu() -> void:
 modal_title.text = "DEINE STADT"
 card("%s Bewohner · %s Gebäude" % [Game.residents(),Game.state.homes.size()],"Bauwirtschaft: Möbelproduktion → Fertighauswerk → Wand- und Dachmodule → Häuser → Miete. Material und Geld werden bei Auftrag bezahlt. Erst fertiggestellte Gebäude erwirtschaften Ertrag.")
 jobs_cards()
 for i in 12:
  var index = i
  var title = "Freies Grundstück %s" % (i+1)
  for h in Game.state.homes:
   if int(h.plot) == i: title = "%s · Stufe %s" % [Catalog.HOMES[h.kind].name,h.level]
  button(contents,title,func(): show_plot(index))

func plot_menu() -> void:
 var plot = current_index
 modal_title.text = "GRUNDSTÜCK %s" % (plot+1)
 button(contents,"IN DER WELT ANSEHEN",func(): focus_requested.emit(Catalog.home_position(plot)); close_menu())
 for i in Game.state.homes.size():
  var index = i
  var h = Game.state.homes[i]
  if int(h.plot) == plot:
   var d = Catalog.HOMES[h.kind]
   var box = card("%s · Stufe %s" % [d.name,h.level],"Grundmiete: %s Münzen/s · Bewohner: %s" % [float(d.rent)*int(h.level),int(d.people)*int(h.level)])
   var materials = {}
   for key in d.materials: materials[key] = ceilf(float(d.materials[key])*0.5*int(h.level))
   text(box,"Ausbau: %s Münzen\n%s" % [Catalog.number(float(d.cost)*pow(1.4,int(h.level))*Game.difficulty()),materials_text(materials)],15,GOLD)
   button(box,"GEBÄUDE AUSBAUEN",func(): action(func(): Game.upgrade_home(index)),not Game.job_for("home_upgrade",index) and h.level < 10)
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
  var box = card(d.name,"Miete %s/s · %s Bewohner" % [d.rent,d.people])
  text(box,"%s Münzen\n%s" % [Catalog.number(float(d.cost)*Game.difficulty()),materials_text(d.materials)],15,GOLD)
  button(box,"BAU BEAUFTRAGEN",func(): action(func(): Game.order_home(key,plot)))

func contracts_menu() -> void:
 modal_title.text = "GROSSKUNDEN"
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
 for entry in [["Loot & Inventar","loot"],["Forschung","research"],["Booster","boosters"],["Neue Unternehmensära / Prestige","prestige"],["Personal & Werkzeug","team"],["Garage & Fahrzeuge","garage"],["Lager & Verkaufsstelle","market"],["Einstellungen & Sicherung","settings"]]:
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
 for key in Game.state.inventory: card(str(key),"Bestand: %s" % Game.state.inventory[key])
 if Game.state.inventory.is_empty(): text(contents,"Dein Inventar wartet auf den ersten Fund.",16,MUTED)
 text(contents,"Geldscheine: %s · Mythic Tokens: %s" % [Game.state.cash,Game.state.tokens],16,GOLD)

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
 var box = card("Kapazität: %s je Rohstoff" % Catalog.number(Game.capacity()),"Manuelle Verkäufe verwenden auch reservierte Vorräte. Automatische Verarbeitung hält bei aktivierter Baureserve kleine Materialbestände zurück.")
 button(box,"Baureserve: AN" if Game.state.reserve else "Baureserve: AUS",func(): action(func(): Game.state.reserve = not Game.state.reserve))
 button(box,"Auto-Export: AN" if Game.state.auto_export else "Auto-Export: AUS",func(): action(func(): Game.state.auto_export = not Game.state.auto_export))
 for key in Catalog.RESOURCES:
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
 button(box,"Qualität: AKKUMODUS" if Game.state.quality == 0 else "Qualität: STANDARD",func(): action(func(): Game.state.quality = 1-int(Game.state.quality)))
 text(contents,"Version 0.7.0 · Wiederaufbau\nKeine Werbung, keine In-App-Käufe, kein Cloud-Save. Geräteleistung und langfristige Balance werden separat geprüft.",14,MUTED)
