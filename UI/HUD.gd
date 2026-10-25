extends Control

signal camera_action(action: String)
signal focus_requested(point: Vector3)
signal placement_requested(request: Dictionary)
signal placement_action(action: String)

const INK = Color("533b30")
const PANEL = TycoonStyle.COPPER
const GOLD = Color("f4c56b")
const CREAM = Color("fff8ed")
const MUTED = Color("ebcdb0")
const PAPER = TycoonStyle.PAPER
const Surface = preload("res://UI/SculptedSurface.gd")
var money: Label
var diamonds: Label
var loot_counter: Label
var subtitle: Label
var supply: Label
var material_bar: GridContainer
var all_stock_button: Button
var compact_materials=false
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
var coach: Control
var alpha_desk
var market_all=false
var narrow_layout=false
var navigation_buttons=[]
var chop_button: Button
var deposit_button: Button
var sell_button: Button
var build_category = "Produktion"
var spatial_icons: SubViewport
var ux: Control
var companion: Control
var route_selection: Array = []
var placement_undo: Button
var placement_rotate: Button
var journey_ui
var edition: Label
var header_panel: PanelContainer
var bottom_panel: VBoxContainer
var camera_controls: VBoxContainer
var emergency_button: Button
var quest_progress: ProgressBar
var notice_queue: Array[String] = []
var notice_history: Array[String] = []
var income_label: Label
var income_left=0.0
var quest_target=0.0
var last_goal=""
var story_step=0
var story_detail: Label
var story_shown=0.0
var stock_strip: PanelContainer
var menu_history=[]
var menu_back: Button
var logistics_tab="overview"
var more_category="Firma"
var job_filter=-1

func style(color: Color, radius: int = 18, pressed: bool = false) -> StyleBoxFlat:
 var skin=StyleBoxFlat.new()
 skin.bg_color=color.darkened(0.12) if pressed else color
 skin.set_corner_radius_all(radius)
 skin.set_border_width_all(1)
 skin.border_color=color.lightened(0.10)
 skin.shadow_color=Color(0.02,0.09,0.08,0.22)
 skin.shadow_size=2 if pressed else 4
 skin.shadow_offset=Vector2(0,2)
 skin.content_margin_left=16
 skin.content_margin_right=16
 skin.content_margin_top=12
 skin.content_margin_bottom=12
 return skin

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
 header_panel=header
 add_child(header)
 header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 header.offset_left = 14
 header.offset_right = -14
 header.offset_top = 14
 header.offset_bottom = 114
 var header_skin=style(Color("e58a3c"),14)
 header_skin.content_margin_top=6
 header_skin.content_margin_bottom=6
 header_skin.content_margin_left=6
 header_skin.content_margin_right=6
 header.add_theme_stylebox_override("panel",header_skin)
 var top = row(header)
 var profile=button(top,"",func(): open_menu("team"))
 profile.custom_minimum_size=Vector2(44,44)
 profile.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
 compact_style(profile,GOLD)
 profile.icon=load("res://Assets/Brand/timber-icon.png")
 profile.expand_icon=true
 profile.add_theme_constant_override("icon_max_width",40)
 profile.tooltip_text="Dein Team und Werkzeuge"
 money=resource_counter(top,"coin",21)
 money.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 diamonds=resource_counter(top,"gem",17)
 loot_counter=resource_counter(top,"more",17)
 subtitle=text(self,"",12,MUTED)
 subtitle.hide()
 edition=text(self,"",11,GOLD)
 edition.hide()
 mission_button = button(self,"",func(): open_menu("guide" if int(Game.state.tutorial)<=4 and not Game.state.onboarding.paused else "journey"))
 mission_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 mission_button.offset_left = 14
 mission_button.offset_right = -14
 mission_button.offset_top = 122
 mission_button.offset_bottom = 162
 mission_button.custom_minimum_size.y=44
 mission_button.add_theme_font_size_override("font_size",14)
 compact_style(mission_button,PANEL)
 quest_progress=ProgressBar.new()
 mission_button.add_child(quest_progress)
 quest_progress.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 quest_progress.offset_left=14
 quest_progress.offset_right=-14
 quest_progress.offset_top=-5
 quest_progress.offset_bottom=-2
 quest_progress.show_percentage=false
 quest_progress.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var track_skin=StyleBoxFlat.new()
 track_skin.bg_color=INK
 track_skin.set_corner_radius_all(3)
 quest_progress.add_theme_stylebox_override("background",track_skin)
 var progress_skin=StyleBoxFlat.new()
 progress_skin.bg_color=GOLD
 progress_skin.set_corner_radius_all(3)
 quest_progress.add_theme_stylebox_override("fill",progress_skin)
 var right = VBoxContainer.new()
 camera_controls=right
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
 bottom_panel=bottom
 add_child(bottom)
 bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 bottom.offset_left = 14
 bottom.offset_right = -14
 bottom.offset_top = -184
 bottom.offset_bottom = -12
 bottom.add_theme_constant_override("separation",6)
 var strip = PanelContainer.new()
 stock_strip=strip
 var strip_style=style(INK,12)
 strip_style.content_margin_top=4
 strip_style.content_margin_bottom=4
 strip.add_theme_stylebox_override("panel",strip_style)
 bottom.add_child(strip)
 var supply_row = row(strip)
 var supply_column=VBoxContainer.new()
 supply_column.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 supply_row.add_child(supply_column)
 material_bar=load("res://UI/MaterialBar.gd").new()
 material_bar.hud=self
 supply_column.add_child(material_bar)
 supply = text(supply_column,"",11,MUTED)
 supply.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 var stock_actions=VBoxContainer.new()
 stock_actions.add_theme_constant_override("separation",4)
 supply_row.add_child(stock_actions)
 sawdust_button = button(stock_actions,"SPÄNEBOX",func():
  if float(Game.state.resources.sawdust)>0: Game.sell("sawdust"); Game.save(true)
  else: open_menu("sawdust"))
 sawdust_button.size_flags_horizontal=Control.SIZE_SHRINK_END
 sawdust_button.custom_minimum_size=Vector2(64,44)
 sawdust_button.add_theme_font_size_override("font_size",11)
 compact_style(sawdust_button,PANEL)
 var all_stock=button(stock_actions,"WAREN",func(): open_menu("stock"))
 all_stock_button=all_stock
 all_stock.autowrap_mode=TextServer.AUTOWRAP_OFF
 all_stock.custom_minimum_size=Vector2(64,44)
 all_stock.add_theme_font_size_override("font_size",12)
 compact_style(all_stock,PANEL)
 var actions = row(bottom)
 var chop = button(actions,"FÄLLEN",func():
  if Game.state.bag < Game.bag_capacity(): focus_requested.emit(Catalog.biome_position(int(Game.state.biome)))
  Game.chop())
 chop_button=chop
 chop.add_theme_stylebox_override("normal",style(GOLD,14))
 chop.add_theme_color_override("font_color",INK)
 deposit_button=button(actions,"Abliefern",func(): Game.deposit(); camera_action.emit("home"))
 sell_button=button(actions,"Verkaufen",func(): open_menu("market"))
 for control in actions.get_children():
  control.custom_minimum_size.y=40
  compact_style(control,GOLD if control==chop else PANEL)
 var navigation = row(bottom)
 for entry in [["Bauen","catalog","factory"],["Team","team","team"],["Logistik","logistics","orders"],["Welt","world","world"],["Mehr","more","more"]]:
  var tab = str(entry[1])
  var nav_button = button(navigation,str(entry[0]),func():
   if tab=="catalog" and ux!=null: ux.open_palette()
   else: open_menu("overview" if tab=="world" else tab))
  navigation_buttons.append({"button":nav_button,"name":str(entry[0])})
  nav_button.text="\n\n"+str(entry[0])
  nav_button.custom_minimum_size.y=60
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
  icon.offset_left=-19
  icon.offset_right=19
  icon.offset_top=0
  icon.offset_bottom=38
 toast = text(self,"",15,CREAM)
 toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
 toast.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 toast.offset_left = 20
 toast.offset_right = -20
 toast.offset_top = -232
 toast.offset_bottom = -188
 toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 toast.add_theme_stylebox_override("normal",style(INK,14))
 toast.visible=false
 toast.add_theme_color_override("font_shadow_color",INK)
 toast.add_theme_constant_override("shadow_offset_x",1)
 toast.add_theme_constant_override("shadow_offset_y",2)
 emergency_button=button(self,"",func(): open_menu("services"))
 emergency_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
 emergency_button.offset_left=-238
 emergency_button.offset_right=-76
 emergency_button.offset_top=220
 emergency_button.offset_bottom=270
 emergency_button.add_theme_font_size_override("font_size",13)
 compact_style(emergency_button,Color("a54235"))
 emergency_button.hide()
 build_overlay()
 build_placement_bar()
 journey_ui=load("res://UI/JourneyUI.gd").new()
 journey_ui.hud=self
 alpha_desk=load("res://UI/AlphaDesk.gd").new()
 alpha_desk.hud=self
 companion=load("res://UI/Companion.gd").new()
 companion.hud=self
 add_child(companion)
 ux=load("res://UI/CityUX.gd").new()
 ux.hud=self
 add_child(ux)
 coach=load("res://UI/TutorialCoach.gd").new()
 coach.hud=self
 add_child(coach)
 Game.back_requested.connect(back)
 ux.call_deferred("apply_accessibility")
 Game.changed.connect(update_stats)
 Game.notice.connect(show_notice)
 Game.sale_completed.connect(func(_key,coins,_point): show_income(coins))
 Game.reward_claimed.connect(func(_title,coins): show_income(coins))
 income_label=text(self,"",14,GOLD)
 income_label.autowrap_mode=TextServer.AUTOWRAP_OFF
 income_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
 income_label.hide()
 Game.rebuild_world.connect(func(): if overlay.visible: call_deferred("render_menu"))
 header_panel.resized.connect(layout_interface)
 bottom_panel.resized.connect(layout_interface)
 bottom_panel.minimum_size_changed.connect(func(): call_deferred("layout_interface"))
 resized.connect(layout_interface)
 for panel in [overlay,placement_panel,ux.sheet,ux.palette]: panel.visibility_changed.connect(layout_interface)
 layout_interface()
 update_stats()
 if int(Game.state.tutorial)==0: call_deferred("open_menu","welcome")

# Keep a consistent, centered reading width on tablets without stretching controls.
func layout_interface() -> void:
 if material_bar!=null: material_bar.columns=3
 # On short screens an open detail sheet gets the reading space. Main play
 # always shows all six counters; detail mode keeps a compact stock summary.
 var compact=placement_panel.visible or (size.y<750 and (overlay.visible or ux.panels_visible()))
 if compact!=compact_materials:
  compact_materials=compact
  material_bar.visible=not compact
  all_stock_button.visible=not compact
  supply.custom_minimum_size.y=35 if compact else 0
  update_stats()
 var narrow=size.x<430
 if narrow!=narrow_layout:
  narrow_layout=narrow
  update_stats()
 for item in navigation_buttons:
  var caption=str(item.name)
  if narrow: caption={"Bauen":"Bau","Aufträge":"Jobs"}.get(caption,caption)
  item.button.text="\n\n"+caption
 for control in [chop_button,deposit_button,sell_button]:
  if control==null: continue
  control.add_theme_font_size_override("font_size",roundi((15 if narrow else 17)*(1.15 if Game.state.ux.large_text else 1.0)))
  control.custom_minimum_size.y=44 if narrow else 40
 if sell_button!=null: sell_button.text="Verkauf" if narrow else "Verkaufen"
 var inset=maxf(14,(size.x-760)/2)
 for panel in [header_panel,bottom_panel,mission_button,overlay]:
  if panel!=null:
   panel.offset_left=inset
   panel.offset_right=-inset
 if camera_controls!=null:
  camera_controls.offset_right=-inset
  camera_controls.offset_left=-inset-52
 bottom_panel.offset_top=-maxf(156,bottom_panel.get_combined_minimum_size().y+12)
 header_panel.offset_bottom=header_panel.offset_top+56
 mission_button.offset_top=header_panel.get_global_rect().end.y+6
 mission_button.offset_bottom=mission_button.offset_top+44
 overlay.offset_top=maxf(118,mission_button.offset_bottom+6) if current!="building" else maxf(118,size.y-574)
 overlay.offset_bottom=-maxf(164,bottom_panel.get_combined_minimum_size().y+20)
 if placement_panel!=null:
  placement_panel.offset_bottom=overlay.offset_bottom
  placement_panel.offset_top=maxf(placement_panel.offset_bottom-268,mission_button.offset_bottom+6-size.y)
 if ux!=null:
  ux.event_button.offset_left=inset
  ux.event_button.offset_right=inset+168
  ux.event_button.offset_top=mission_button.offset_bottom+8
  ux.event_button.offset_bottom=ux.event_button.offset_top+44
  ux.layout_sheet()
  if current=="welcome" and overlay.visible:
   overlay.offset_left=inset+66
   overlay.offset_top=maxf(mission_button.offset_bottom+60,size.y+overlay.offset_bottom-minf(300,size.y*0.45))
   if coach!=null: coach.refresh()
  ux.palette.offset_left=inset
  ux.palette.offset_right=-inset
 toast.offset_top=bottom_panel.offset_top-56
 toast.offset_bottom=bottom_panel.offset_top-8
 toast.offset_left=inset
 toast.offset_right=-inset
 camera_controls.offset_top=mission_button.offset_bottom+12
 emergency_button.offset_top=mission_button.offset_bottom+64
 emergency_button.offset_bottom=emergency_button.offset_top+50
 emergency_button.offset_left=-inset-230
 emergency_button.offset_right=-inset-62

func build_overlay() -> void:
 overlay = PanelContainer.new()
 add_child(overlay)
 overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 overlay.offset_left = 14
 overlay.offset_right = -14
 overlay.offset_top = 168
 overlay.offset_bottom = -192
 overlay.add_theme_stylebox_override("panel",style(INK,22))
 var container = VBoxContainer.new()
 container.add_theme_constant_override("separation",12)
 overlay.add_child(container)
 var heading = row(container)
 menu_back=button(heading,"‹",func(): previous_menu())
 menu_back.custom_minimum_size.x=44
 menu_back.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
 menu_back.tooltip_text="Zurück zum vorherigen Menü"
 menu_back.hide()
 modal_title = text(heading,"",23,GOLD)
 modal_title.add_theme_font_override("font",preload("res://Assets/Fonts/Anton-Regular.ttf"))
 modal_title.max_lines_visible=2
 modal_title.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
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
  ink = INK if color==CREAM or Game.state.ux.high_contrast else Color("ad6508") if color==GOLD else Color("52767a") if color==MUTED else color
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
 var panel=PanelContainer.new()
 panel.size_flags_horizontal=Control.SIZE_EXPAND_FILL if key=="coin" else Control.SIZE_FILL
 var skin=style(PAPER,8)
 skin.content_margin_left=8
 skin.content_margin_right=8
 skin.content_margin_top=4
 skin.content_margin_bottom=4
 panel.add_theme_stylebox_override("panel",skin)
 parent.add_child(panel)
 var line=row(panel)
 line.add_theme_constant_override("separation",4)
 var icon=TextureRect.new()
 icon.texture=spatial_icons.texture_for(key)
 icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 icon.custom_minimum_size=Vector2(20,24)
 icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
 line.add_child(icon)
 var value=text(line,"",font_size,INK)
 value.autowrap_mode=TextServer.AUTOWRAP_OFF
 value.tooltip_text={"coin":"Münzen","gem":"Diamanten","more":"Tickets"}[key]
 return value

func row(parent: Node) -> HBoxContainer:
 var node = HBoxContainer.new()
 node.add_theme_constant_override("separation",7)
 parent.add_child(node)
 return node

func button(parent: Node, title: String, callback: Callable, enabled: bool = true) -> Button:
 var node = Button.new()
 node.text = title
 node.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 node.custom_minimum_size = Vector2(0,48)
 node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 node.disabled = not enabled
 node.pressed.connect(func():
  if ux!=null: ux.feedback()
  callback.call())
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
 if message.is_empty(): return
 if notice_history.is_empty() or notice_history[0]!=message:
  notice_history.push_front(message)
  if notice_history.size()>12: notice_history.pop_back()
 if message==toast.text and toast_left>0: return
 if message not in notice_queue: notice_queue.append(message)
 if notice_queue.size()>4: notice_queue.pop_front()
 if toast_left<=0: next_notice()

func next_notice() -> void:
 if notice_queue.is_empty(): return
 toast.text=notice_queue.pop_front()
 toast_left=3.2
 toast.visible=true

func show_income(coins: float) -> void:
 if coins<=0: return
 income_label.text="+ %s Münzen" % Catalog.number(coins)
 income_left=1.8
 income_label.show()

func update_goal_progress(goal: Dictionary) -> void:
 var value=clampf(float(goal.get("value",0))/maxf(1,float(goal.get("target",1))),0,1)*100
 var id=str(goal.get("id","tutorial"))
 quest_target=value
 if not Game.state.ux.motion or id!=last_goal: quest_progress.value=value
 last_goal=id
 compact_style(mission_button,Color("628840") if goal.get("ready",false) else Color("825031"))

func update_stats() -> void:
 emergency_button.visible=not Game.state.city_services.fires.is_empty()
 emergency_button.text="FEUERWEHR · %s\nEINSÄTZE ANSEHEN" % Game.state.city_services.fires.size()
 edition.text="WALDKONTO"
 for chapter in Journey.CHAPTERS:
  if chapter.id==Game.state.journey.selected: edition.text=chapter.title.to_upper()
 money.text = Catalog.number(Game.state.coins)
 diamonds.text=Catalog.number(Game.state.diamonds)
 loot_counter.text=Catalog.number(Game.state.tickets)
 subtitle.text = "%s · Rucksack %s/%s · Team %s · Lv. %s" % [Catalog.TOOLS[int(Game.state.tool)],int(Game.state.bag),int(Game.bag_capacity()),int(Game.state.workers),Game.company_level()]
 material_bar.refresh()
 supply.text="Vorräte · Lager + Betriebe"
 if Game.state.delivery.active:
  var order = Game.state.delivery.order
  supply.text = "Laden %s/%s · %s" % [int(order.delivered),int(order.amount),"SPÄT · 70 %" if order.late else "%02d:%02d" % [int(float(order.left)/60),int(order.left)%60]]
 if compact_materials:
  supply.text="Holz %s · Bretter %s\nMöbel %s" % [Catalog.number(UXRules.material_stock(Game.state,"wood").stored),Catalog.number(UXRules.material_stock(Game.state,"boards").stored),Catalog.number(UXRules.material_stock(Game.state,"furniture").stored)]
 var fill = float(Game.state.resources.sawdust)/Game.capacity()
 sawdust_button.text="Späne %s%%\nLeeren" % int(fill*100)
 compact_style(sawdust_button,Color("e78a45") if fill>=0.8 else Color("258f8d"))
 mission_button.text = "MISSIONEN · Dein nächster Meilenstein"
 for m in Game.mission_definitions():
  if not Game.state.missions_claimed.has(m.id):
   mission_button.text = "%s · %s/%s %s" % [m.name,Catalog.number(m.value),Catalog.number(m.target),"ABHOLEN" if m.value >= m.target else "›"]
   break
 if Game.state.onboarding.active:
  var guide=TutorialRules.info(Game.state)
  mission_button.text="DEIN START · %s/5 · %s" % [guide.step,guide.title]
  var partial=float(guide.value)/maxf(1,float(guide.target)) if guide.phase in ["chop","done"] else 0.0
  update_goal_progress({"id":"guided_start","value":float(guide.step)-1+partial,"target":5})
 elif int(Game.state.tutorial)<=4 and not Game.state.onboarding.paused:
  mission_button.text = ["WILLKOMMEN · Dein Waldimperium wartet","ANLEITUNG 1/4 · Fälle fünfmal Holz","ANLEITUNG 2/4 · Holz abliefern","ANLEITUNG 3/4 · Erste Rohstoffe verkaufen","ANLEITUNG 4/4 · Erstes Gebäude platzieren"][int(Game.state.tutorial)]
 else:
  var goal=Journey.current(Game.state)
  update_goal_progress(goal)
  if not goal.is_empty():
   mission_button.text="K%s · %s %s" % [int(goal.chapter)+1,goal.name,"✓ ABHOLEN" if goal.ready else "%s/%s ›" % [Catalog.number(goal.value),Catalog.number(goal.target)]]
  else: mission_button.text="DEIN IMPERIUM · Alle zehn Kapitel geschafft!"
 if not Game.state.onboarding.active and int(Game.state.tutorial)<=4 and not Game.state.onboarding.paused:
  update_goal_progress({"id":"tutorial","value":Game.state.tutorial,"target":4})
 mission_button.clip_text=true
 mission_button.add_theme_font_size_override("font_size",12 if mission_button.text.length()>60 else 14)

func _process(delta: float) -> void:
 if current=="welcome" and overlay.visible and is_instance_valid(story_detail):
  story_shown+=delta*42
  story_detail.visible_characters=floori(story_shown) if Game.state.ux.motion else -1
 # Smooth the one existing meter without allocating a new Tween on every refresh.
 if Game.state.ux.motion:
  quest_progress.value=lerpf(quest_progress.value,quest_target,minf(1,delta*12))
  if absf(quest_progress.value-quest_target)<0.05: quest_progress.value=quest_target
 else: quest_progress.value=quest_target
 toast_left -= delta
 toast.modulate.a = clampf(toast_left*2,0,1)
 if toast_left<=0:
  toast.hide()
  next_notice()
 income_left=maxf(0,income_left-delta)
 income_label.visible=income_left>0 and not overlay.visible
 income_label.modulate.a=minf(1,income_left*2)
 income_label.position=header_panel.global_position+Vector2(64,8)
 subtitle.modulate.a=0 if income_left>0 and not overlay.visible else 1
 if Game.company_level()>=4 and not Game.state.construction_intro and not overlay.visible and not placement_panel.visible:
  Game.state.construction_intro=true
  Game.save(true)
  open_menu("construction")
 refresh_clock += delta
 if refresh_clock >= 1.0:
  refresh_clock = 0
  for item in live_labels:
   if is_instance_valid(item.label):
    if item.has("update"): item.update.call()
    else: item.label.text = item.callback.call()

func back() -> void:
 var world=get_parent().get_parent()
 if world.get("photo")!=null and world.photo.active: world.photo.leave(); return
 if ux!=null and ux.panels_visible(): ux.hide_panels(true); return
 if placement_panel.visible: placement_action.emit("cancel"); return
 if overlay.visible: previous_menu(); return
 open_menu("game_menu")

func _unhandled_key_input(event: InputEvent) -> void:
 if event.is_action_pressed("ui_cancel"):
  back()
  get_viewport().set_input_as_handled()

func open_menu(tab: String,index: int=-2,job: int=-2) -> void:
 if current=="alpha" and alpha_desk!=null: alpha_desk.capture_draft()
 if tab=="photo": camera_action.emit("photo"); return
 if ux!=null: ux.hide_panels()
 if placement_panel!=null and placement_panel.visible: placement_action.emit("cancel")
 if overlay.visible and current!=tab:
  menu_history.append({"tab":current,"index":current_index,"scroll":scroll.scroll_vertical,"job_filter":job_filter,"logistics_tab":logistics_tab})
  if menu_history.size()>12: menu_history.pop_front()
 elif not overlay.visible: menu_history.clear()
 if index>=-1: current_index=index
 if tab=="construction": job_filter=job if job>=-1 else -1
 current = tab
 scroll.scroll_vertical = 0
 overlay.show()
 if ux!=null: ux.event_button.hide()
 overlay.offset_top=maxf(168,size.y-574) if tab=="building" else maxf(168,mission_button.offset_bottom+6)
 render_menu()

func close_menu() -> void:
 if current=="alpha" and alpha_desk!=null: alpha_desk.capture_draft()
 overlay.hide()
 live_labels.clear()
 menu_history.clear()

func previous_menu() -> void:
 if menu_history.is_empty(): close_menu(); return
 if current=="alpha" and alpha_desk!=null: alpha_desk.capture_draft()
 var entry=menu_history.pop_back()
 current=str(entry.tab)
 current_index=int(entry.index)
 job_filter=int(entry.job_filter)
 logistics_tab=str(entry.logistics_tab)
 render_menu()
 scroll.set_deferred("scroll_vertical",int(entry.scroll))

func show_building(index: int) -> void:
 open_menu("building",index)

func show_plot(index: int) -> void:
 open_menu("plot",index)

func dynamic_text(parent: Node, callback: Callable) -> void:
 var label = text(parent,callback.call(),15,MUTED)
 label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 live_labels.append({"label":label,"callback":callback})

func materials_text(materials: Dictionary) -> String:
 var parts = []
 for key in materials:
  var needed=float(materials[key])
  var quote=UXRules.build_quote(Game.state,key,needed)
  parts.append("%s: %s nötig · %s frei · %s fehlen · %s für andere Baustellen unterwegs" % [Catalog.RESOURCES[key],Catalog.number(needed),Catalog.number(quote.available),Catalog.number(quote.missing),Catalog.number(quote.incoming)])
 return ", ".join(parts)

func render_menu() -> void:
 var old_scroll = scroll.scroll_vertical
 contents.set_meta("light_card",current=="welcome")
 overlay.add_theme_stylebox_override("panel",style(PAPER,16) if current=="welcome" else style(INK,22))
 modal_title.add_theme_color_override("font_color",INK if current=="welcome" else GOLD)
 modal_title.set_meta("ux_base_font",18 if current=="welcome" else 23)
 for child in contents.get_children():
  contents.remove_child(child)
  child.queue_free()
 live_labels.clear()
 menu_back.visible=not menu_history.is_empty()
 match current:
  "logistics": load("res://UI/LogisticsDesk.gd").populate(self)
  "timberline": load("res://UI/TimberLineDesk.gd").populate(self)
  "timber_campus","mill_stages": load("res://UI/TimberCampusDesk.gd").populate(self,current)
  "journey","commissions","trophies","return","townhall": journey_ui.populate(current)
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
  "fire_protection": fire_protection_menu()
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
  "stock": stock_menu()
  "operations","performance": load("res://UI/OperationsDesk.gd").populate(self,current)
  "export": export_menu()
  "settings": settings_menu()
  "alpha": alpha_desk.populate()
  "game_menu": game_menu()
  "empire": empire_menu()
  "planner": planner_menu()
  "sawdust": sawdust_menu()
  "welcome": welcome_menu()
  "guide": guide_menu()
  "confirm_prestige": confirm_prestige_menu()
  _:
   if ux!=null: ux.populate_menu(current)
 if ux!=null: ux.apply_accessibility()
 scroll.set_deferred("scroll_vertical",old_scroll)

func industry_menu() -> void:
 modal_title.text = "DEINE INDUSTRIE"
 button(contents,"LOGISTIK · ABHOLUNGEN & BAUSTELLEN",func(): open_menu("logistics"))
 var help = card("Vom Wald zum Imperium","Fälle Holz und liefere es ab. Helfer füllen das Lager automatisch. Baue zuerst Trockenkammer und Möbelfabrik; danach das Fertighauswerk für deine Stadt.")
 button(help,"LIEFERKETTE · HOLZ → BRETTER → MÖBEL",func(): open_menu("delivery"))
 button(help,"STEINBRUCH & BAUSTOFFE · AB LEVEL 5",func(): open_menu("stone"))
 button(help,"NEUEN BETRIEB BAUEN",func(): open_menu("catalog"))
 var links = row(contents)
 button(links,"Personal",func(): open_menu("team"))
 button(links,"Garage",func(): open_menu("garage"))
 button(links,"Forschung",func(): open_menu("research"))
 if not Game.state.jobs.is_empty(): button(contents,"%s BAUSTELLEN ANSEHEN" % Game.state.jobs.size(),func(): job_filter=-1; open_menu("construction"))
 for i in Game.state.buildings.size():
  var index = i
  var b = Game.state.buildings[i]
  var box = card("%s · Stufe %s" % [Catalog.BUILDINGS[b.kind].name,b.level],Catalog.BUILDINGS[b.kind].desc)
  button(box,"VERWALTEN / AUSBAUEN",func(): show_building(index))

func jobs_cards(only_id: int=-1) -> void:
 for job in Game.state.jobs:
  if only_id>=0 and int(job.get("id",-1))!=only_id: continue
  var title = Catalog.PROJECTS[int(job.index)].name if job.type=="project" else Catalog.HOMES[job.kind].name if job.type in ["home","home_upgrade"] else Catalog.BUILDINGS[job.kind].name
  var box = card("Baustelle · %s" % title)
  dynamic_text(box,func(): return ConstructionRules.status(job))
  if not job.get("materials",{}).is_empty():
   for resource_key in job.materials:
    var material_key=str(resource_key)
    var material_row=row(box)
    material_row.set_meta("light_card",true)
    var help=button(material_row,"?",func(): ux.open_material(material_key))
    help.custom_minimum_size=Vector2(44,48)
    help.size_flags_horizontal=Control.SIZE_SHRINK_END
    var icon=TextureRect.new()
    icon.custom_minimum_size=Vector2(30,30)
    icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    var icon_path="res://Assets/Resources/%s.svg" % material_key
    icon.texture=load(icon_path if ResourceLoader.exists(icon_path) else "res://Assets/Resources/boards.svg")
    material_row.add_child(icon)
    dynamic_text(material_row,func():
     var cargo=ConstructionRules.incoming(Game.state,int(job.get("id",-1)),material_key)
     return "%s  %s / %s%s · %s fehlen" % [Catalog.RESOURCES[material_key],Catalog.number(float(job.get("delivered",{}).get(material_key,0))),Catalog.number(float(job.materials[material_key]))," · +%s unterwegs" % Catalog.number(cargo) if cargo>0 else "",Catalog.number(maxf(0,ConstructionRules.remaining(job,material_key)-cargo))])
   var id = int(job.get("id",-1))
   button(box,"LIEFERUNG JETZT PRÜFEN",func(): action(func(): Game.deliver_job(id)),not ConstructionRules.ready(job) and not job.get("paused",false))
   var hardware_cost=Game.job_hardware_cost(id)
   if hardware_cost>0: button(box,"FEHLENDE TEILE KAUFEN · %s MÜNZEN" % Catalog.number(hardware_cost),func(): action(func(): Game.buy_job_hardware(id)))
   if job.has("phases"):
    dynamic_text(box,func(): return CrewTransport.status(Game.state,job))
    dynamic_text(box,func(): return ConstructionRules.logistics_status(Game.state,job))
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
 button(contents,"BAULEISTE AN DER KARTE",func(): ux.open_palette())
 button(contents,"BAUSTELLEN & MATERIALDEPOT",func(): open_menu("construction"))
 button(contents,"STEINBRUCH & BAUSTOFFE",func(): open_menu("stone"))
 text(contents,"Auswählen → in der Welt platzieren → drehen → bestätigen. Bezahlt wird erst beim Bestätigen. Straßen bleiben frei; Waldflächen werden geräumt.",15,MUTED)
 var tabs=row(contents)
 for name_value in ["Produktion","Stadt","Versorgung"]:
  var category=str(name_value)
  var tab=button(tabs,category,func(): build_category=category; render_menu())
  tab.add_theme_font_size_override("font_size",14)
  if category==build_category: tab.add_theme_stylebox_override("normal",style(Color("d99432"),13))
 if build_category=="Versorgung":
  var logistics=card("Ein Warenfluss für deine Baustellen","Betriebe → Zentrallager → Baustelle. In der Ferne: Zentrallager → Abhol-Express → Baustelle. Die 31 × 23 m große Zentrale bringt eine eigene weiß-blaue Lagerflotte und schwarz-weiße Baustellenfahrer mit.")
  button(logistics,"ZENTRALLAGER PLATZIEREN",func(): request_placement({"kind":"central_depot","city":false,"index":-1}))
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
  if not city and ((build_category=="Versorgung")!=(kind in ["station","cabin","warehouse","central_depot","express","market","research","garage"])): continue
  var key=str(kind)
  var d=definitions[kind]
  var enabled=(Game.home_available(kind) and (kind=="townhall" or Game.next_city_plot()>=0)) if city else Game.available(kind)
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
 if LogisticsDispatch.enabled(Game.state) and not LogisticsDispatch.outputs(Game.state,index).is_empty():
  dynamic_text(box,func(): return LogisticsDispatch.collection_status(Game.state,index))
  button(box,"ABHOLUNGEN & LAGER ANSEHEN",func(): logistics_tab="factories"; open_menu("logistics"))
 if not FactorySupply.requirements(Game.state,index).is_empty():
  button(box,"WARE ANFORDERN · ZENTRALLAGER → WERK",func(): action(func(): Game.request_material(index)))
  dynamic_text(box,func(): return FactorySupply.status(Game.state,index))
 if LogisticsDispatch.enabled(Game.state) and TransportCapacity.supported(Game.state,index): load("res://UI/TransportDesk.gd").workshop_controls(self,box,index)
 if b.kind == "sawmill":
  text(box,"Leere die sichtbare Spänebox regelmäßig. Ein voller Behälter stoppt die Bretterproduktion nicht; neuer Überlauf wird kompostiert oder auf Wunsch verkauft.",15,MUTED)
  button(box,"SPÄNEBOX LEEREN",func(): open_menu("sawdust"))
 if Game.company_level()>=4: text(box,"Material für Stufe %s: %s" % [int(b.level)+1,materials_text(Game.build_materials(b.kind,int(b.level)+1))],15,MUTED)
 else: text(box,"Bis Level 3: Ausbau nur mit Münzen. Ab Level 4 kommen Baustoffe und Lieferfahrzeuge dazu.",15,MUTED)
 if Game.delivery_owns(index):
  text(box,"Zum Verschieben zuerst die Lieferlinie auflösen. Ihre Vorräte und Ladungen kommen vollständig ins Lager zurück.",14,MUTED)
  button(box,"LIEFERKETTE & LOKALEN VORRAT ANSEHEN",func(): open_menu("delivery"))
 text(box,"Ausbau: %s Münzen" % Catalog.number(Game.cost_for(b.kind,int(b.level)+1)),17,GOLD)
 if b.kind=="sawmill": load("res://UI/TimberCampusDesk.gd").mill_controls(self,box,index)
 var management=row(box)
 button(management,"AUSBAUEN" if not Game.job_for("upgrade",index) else "AUSBAU LÄUFT",func(): action(func(): Game.upgrade(index)),not Game.job_for("upgrade",index) and b.level < d.max)
 button(management,"VERSCHIEBEN",func(): request_placement({"kind":b.kind,"city":false,"index":index}),not Game.delivery_owns(index) and not Game.job_for("upgrade",index))
 if b.kind in StoneIndustry.KINDS:
  stone_site_controls(box,index)
 if Catalog.RECIPES.has(b.kind) or b.kind in StoneIndustry.KINDS:
  button(box,"Produktion fortsetzen" if b.paused else "Produktion pausieren",func(): action(func(): b.paused = not b.paused))
 if b.kind in ["cabin","station"]: button(box,"PERSONAL EINSTELLEN",func(): open_menu("team"))
 if b.kind=="garage": button(box,"FAHRZEUGE VERWALTEN",func(): open_menu("garage"))
 if b.kind=="research": button(box,"FORSCHUNG",func(): open_menu("research"))
 button(box,"IN DER WELT ANSEHEN",func(): focus_requested.emit(Game.building_position(index)); close_menu())
 for job in Game.state.jobs:
  if job.type=="upgrade" and int(job.index)==index: jobs_cards(int(job.id))

func team_menu() -> void:
 modal_title.text = "DEIN TEAM"
 var hero=card("Gemeinsam wächst dein Werkshof","Holzfäller sammeln, das Werk verarbeitet und Transporte verbinden deine Firma. Stelle Helfer ein und verbessere ihre Werkzeuge.")
 var portrait=TextureRect.new()
 portrait.texture=load("res://Assets/Brand/timber-icon.png")
 portrait.custom_minimum_size=Vector2(64,64)
 portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 hero.add_child(portrait)
 var box = card("%s / %s Arbeiter" % [int(Game.state.workers),Game.worker_capacity()],"Helfer fällen und liefern Holz automatisch. Hütten und Stadtbewohner schaffen zusätzlichen Wohnraum. Forschungsboni erhöhen die Leistung.")
 dynamic_text(box,func(): return ForestryFlow.team_status(Game.state,Game.flow))
 button(box,"HOLZFÄLLER ANSEHEN",func(): focus_requested.emit(ForestryFlow.work_position(Game.state)); close_menu())
 var planting=card("Biber-Baumpflanzer","Das Pflanzteam stammt aus deinen eingestellten Helfern. Es pflanzt echte abgeerntete Stellen nach; während Hinweg, Pflanzen und Rückkehr sind diese Biber keine Holzfäller. Jungbäume wachsen anschließend selbständig heran.")
 dynamic_text(planting,func(): return ForestCycle.status(Game.state))
 var allocation=row(planting)
 button(allocation,"Automatisch",func(): action(func(): Game.assign_planters(-1)))
 button(allocation,"Weniger",func(): action(func(): Game.assign_planters(maxi(0,ForestCycle.limit(Game.state)-1))))
 button(allocation,"Mehr",func(): action(func(): Game.assign_planters(mini(int(Game.state.workers),ForestCycle.limit(Game.state)+1))))
 button(planting,"PFLANZARBEIT ANSEHEN",func():
  var at=Catalog.biome_position(int(Game.state.biome))+Vector3(25,0,28)
  if not Game.state.forest.tasks.is_empty():
   var task=Game.state.forest.tasks[0]
   at=ForestLayout.point(int(task.biome),int(task.cell))
  focus_requested.emit(at); close_menu())
 var builders=card("Bauteam & Sprinter","Bauarbeiter werden von der Arbeiterhütte zur Baustelle gefahren. Sie beginnen nach der Ankunft und warten auf das Material ihrer Bauphase.")
 dynamic_text(builders,func(): return "%s Bauarbeiter · %s frei · %s/%s Sprinter unterwegs" % [int(Game.state.builders),Game.free_builders(),Game.state.crew.missions.size(),CrewTransport.fleet_size(Game.state)])
 button(builders,"BAUSTELLEN ANSEHEN",func(): logistics_tab="sites"; open_menu("logistics"))
 text(box,"Einstellung: %s Münzen" % Catalog.number(Game.hire_cost()),17,GOLD)
 button(box,"ARBEITER EINSTELLEN",func(): action(func(): Game.hire()))
 var tool = card(Catalog.TOOLS[int(Game.state.tool)],"Aktiver Ertrag: %s Holz · Boss-Schaden: %s" % [int((4+int(Game.state.tool)*3)*(1+int(Game.state.biome)*0.4)),Catalog.number(pow(2.0,int(Game.state.tool))*10)])
 if int(Game.state.tool) < 14:
  text(tool,"Nächste Stufe: %s" % Catalog.TOOLS[int(Game.state.tool)+1],16,GOLD)
  button(tool,"VERBESSERN · %s" % Catalog.number(Game.tool_cost()),func(): action(func(): Game.upgrade_tool()))
  button(tool,"AUS TEILEN BAUEN · %s Teile" % (3+int(Game.state.tool)*2),func(): action(func(): Game.craft_tool()))

func garage_menu() -> void:
 text(contents,"Transportupgrades verbessern Ladekapazität und Fahrtempo. Höhere Stufen zeigen Gelenk-Auflieger und Tiefbetttransporter. Maschinen im Wald schaltest du unter Team mit den Werkzeugstufen frei.",15,MUTED)
 modal_title.text = "GARAGE & FUHRPARK"
 if CentralLogistics.active(Game.state):
  var logistics=card("Lagerflotte · %s LKW" % CentralLogistics.fleet_size(Game.state),"Weiß-blaue LKW holen Fabrikprodukte ab und versorgen Werke und Abhol-Express. Zusätzliche Lager-LKW hier kaufen. Zentrale und Abhol-Express erhöhen die Grundflotte; eine Garage schafft weitere Kaufplätze. Bis zu 16 Lager-LKW sind aktiv.")
  load("res://UI/TransportDesk.gd").fleet_controls(self,logistics)
  button(logistics,"ZENTRALLAGER VERWALTEN",func(): show_building(CentralLogistics.depot(Game.state)))
  button(logistics,"ABHOL-EXPRESS BAUEN",func(): request_placement({"kind":"express","city":false,"index":-1}),Game.available("express"))
  card("Baustellenflotte · %s LKW" % CentralLogistics.construction_fleet_size(Game.state),"Schwarz-weiße Fahrer bringen Material vom Lager zur Baustelle. Die Mitarbeiter kommen separat mit höchstens zwei Sprintern aus der Arbeiterhütte.")
 var box = card("%s allgemeine Transportfahrzeuge" % int(Game.state.trucks),"Diese LKW bedienen den Fernhandel. Lager- und Baustellenflotten sind mit Zentrallager eigenständig." if CentralLogistics.active(Game.state) else "Deine gemeinsame Flotte transportiert Holz, Bretter, Möbel und Baumaterial. Beladen, Entladen und leere Rückfahrt belegen das Fahrzeug. Die Garage schafft zusätzliche Stellplätze.")
 button(box,"LIEFERKETTE & ZUTEILUNG",func(): open_menu("delivery"))
 button(box,("FERNHANDELS-LKW KAUFEN · %s" if CentralLogistics.active(Game.state) else "LKW KAUFEN · %s") % Catalog.number(Game.truck_cost()),func(): action(func(): Game.buy_truck()))
 var vehicle = card(Catalog.VEHICLES[int(Game.state.vehicle)],"Verbessert Ladekapazität und Fahrtempo der Transporte sowie deinen Rucksack. Lager-LKW kaufst du oben; einzelne Werke erhalten unter Transportausbau größere Puffer und Ladungen.")
 if Game.state.vehicle < 9:
  button(vehicle,"NÄCHSTE STUFE · %s" % Catalog.number(Game.vehicle_cost()),func(): action(func(): Game.upgrade_vehicle()))
  button(vehicle,"AUS TEILEN BAUEN · %s Teile" % (4+int(Game.state.vehicle)*3),func(): action(func(): Game.craft_vehicle()))

func city_menu() -> void:
 modal_title.text = "DEINE STADT"
 button(contents,"STADTKARTE & VIERTEL",func(): open_menu("overview"))
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
 button(contents,"NEUES GEBÄUDE FREI PLATZIEREN",func(): build_category="Stadt"; open_menu("catalog"))
 text(contents,"Baue auf freiem Festland. Nur gesperrte Biome, Gewässer, Straßen und belegte Flächen bleiben geschützt. Es gibt keine feste Zahl an Bauplätzen.",15,MUTED)
 for home in Game.state.homes:
  var plot=int(home.plot)
  button(contents,"%s · Stufe %s" % [Catalog.HOMES[home.kind].name,home.level],func(): show_plot(plot))

func plot_menu() -> void:
 var plot = current_index
 modal_title.text = "GRUNDSTÜCK %s" % (plot+1)
 button(contents,"IN DER WELT ANSEHEN",func(): focus_requested.emit(Game.plot_position(plot)); close_menu())
 for i in Game.state.homes.size():
  var index = i
  var h = Game.state.homes[i]
  if int(h.plot) == plot:
   var d = Catalog.HOMES[h.kind]
   var box = card("%s · Stufe %s / 10" % [TownEvolution.title(h.kind,int(h.level)),h.level],"Grundmiete: %s Münzen/s · Bewohner: %s" % [float(d.rent)*int(h.level),int(d.people)*int(h.level)])
   button(box,"ALLE 10 ARCHITEKTURSTUFEN ANSEHEN",func(): ux.show_evolution(h.kind,int(h.level)))
   if int(h.level)<10: text(box,"Nächste Stufe: "+TownEvolution.title(h.kind,int(h.level)+1),16,GOLD)
   if float(d.rent)>0:
    dynamic_text(box,func(): return "Abholbereit: %s Münzen" % Catalog.number(Game.state.homes[index].get("rent_bank",0)))
    button(box,"MIETE ABHOLEN",func(): action(func(): Game.collect_rent(index)))
   var materials = {}
   for key in d.materials: materials[key] = ceilf(float(d.materials[key])*0.5*int(h.level))
   if h.kind=="townhall": button(box,"RATHAUS & KAPITELFORTSCHRITT",func(): open_menu("townhall"))
   else:
    text(box,"Ausbau: %s Münzen\n%s" % [Catalog.number(float(d.cost)*pow(1.4,int(h.level))*Game.difficulty()),materials_text(materials)],15,GOLD)
    button(box,"GEBÄUDE AUSBAUEN",func(): action(func(): Game.upgrade_home(index)),not Game.job_for("home_upgrade",index) and h.level < 10)
   button(box,"GEBÄUDE VERSCHIEBEN",func(): request_placement({"kind":h.kind,"city":true,"index":index,"plot":plot}))
   return
 for j in Game.state.jobs:
  if j.type == "home" and int(j.plot) == plot:
   card("Bau läuft bereits","Das Grundstück wird nach Fertigstellung nutzbar.")
   return
 if Game.level("prefab") < 1 and not Game.home_available("townhall"):
  card("Fertighauswerk benötigt","Baue zuerst Möbelfabrik und Fertighauswerk im Industriemenü.")
  return
 for kind in Catalog.HOMES:
  var key = str(kind)
  var d = Catalog.HOMES[kind]
  var public_effect = {"park":"Unternehmensweit +4 % Miete pro Stufe (zusammen maximal +100 %)","school":"+4 % Produktionsleistung pro Stufe (maximal +50 %)","clinic":"Unternehmensweit +4 % Miete pro Stufe (zusammen maximal +100 %)","fire":"+5 % Baugeschwindigkeit pro Stufe (maximal +50 %)"}.get(kind,"")
  var box = card(d.name,public_effect if not public_effect.is_empty() else "Miete %s/s · %s Bewohner" % [d.rent,d.people])
  text(box,"%s Münzen\n%s" % [Catalog.number(float(d.cost)*Game.difficulty()),materials_text(d.materials)],15,GOLD)
  button(box,"STANDORT AUSWÄHLEN",func(): request_placement({"kind":key,"city":true,"index":-1,"plot":plot}),Game.home_available(key))
  if kind=="townhall": button(box,"KAPITEL & RATHAUSAUSBAU",func(): open_menu("townhall"))
  else: button(box,"ALS BAUZIEL VORMERKEN",func(): Game.set_plan(key,plot); open_menu("planner"))

func contracts_menu() -> void:
 modal_title.text = "AUFTRÄGE & LIEFERUNGEN"
 button(contents,"FREIWILLIGE KURZAUFTRÄGE · DEIN NÄCHSTES VORHABEN",func(): open_menu("commissions"))
 button(contents,"KAPITEL 1–10 & RATHAUS",func(): open_menu("journey"))
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
 modal_title.text = "WALDREGIONEN"
 button(contents,"STADTKARTE & FREIE GRUNDSTÜCKE",func(): open_menu("overview"))
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
 load("res://UI/MenuDirectory.gd").populate(self)


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
 var region = card(["Waldquartier","Seenregion","Stadtregion"][int(Game.state.region)],"Freie Standortwahl auf dem Festland · %s Bewohner" % Game.residents())
 if Game.state.region < 2:
  text(region,"Nächste Region: %s Münzen · %s Bewohner" % [Catalog.number(6000*pow(5,int(Game.state.region))*Game.difficulty()),4 if Game.state.region==0 else 20],16,GOLD)
  button(region,"REGION ERSCHLIESSEN",func(): action(func(): Game.expand_region()))
 var district=card("Stadtviertel · %s/2" % Game.state.town.districts,"Optionaler Ausbau der Infrastruktur: Ost- und Westzufahrt erweitern das Straßennetz. Auf freiem Festland darfst du schon vorher bauen; gesperrte Biome müssen weiterhin erschlossen werden.")
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

func stock_menu() -> void:
 modal_title.text="MATERIALBESTÄNDE"
 button(contents,"LOGISTIK · WER LIEFERT WOHIN?",func(): open_menu("logistics"))
 card("Deine Vorräte auf einen Blick","Die Hauptanzeige zählt Lager und lokale Betriebsbestände. LKW-Ladungen stehen separat unter unterwegs. Bereits verbaute Materialien sind keine Vorräte mehr.")
 for key_value in Catalog.RESOURCES:
  var key=str(key_value)
  var box=card(Catalog.RESOURCES[key])
  dynamic_text(box,func():
   var stock=UXRules.material_stock(Game.state,key)
   var reading="%s Vorrat\n%s Zentrale · %s Abhol-Express · %s Betriebe · %s unterwegs" % [Catalog.number(stock.stored),Catalog.number(float(stock.warehouse)+float(stock.receiving)),Catalog.number(stock.regional),Catalog.number(float(stock.local)-float(stock.regional)-float(stock.receiving)),Catalog.number(stock.transit)]
   if key=="wood" and float(stock.processing)>0: reading+="\n%s Holz in Verarbeitung · noch nicht lieferbar" % Catalog.number(stock.processing)
   return reading)
  button(box,"QUELLEN & LIEFERUNGEN ›",func(): ux.open_material(key))

func market_menu() -> void:
 modal_title.text = "LAGER & VERKAUF"
 var box = card("Kapazität: %s je Rohstoff" % Catalog.number(Game.capacity()),"Manuelle Verkäufe verwenden auch reservierte Vorräte. Die Baureserve schützt Material für neue Häuser. Die Spänebox lässt sich direkt unten oder am Sägewerk öffnen; ihr voller Behälter stoppt nie die Bretterproduktion.")
 button(box,"Baureserve: AN" if Game.state.reserve else "Baureserve: AUS",func(): action(func(): Game.state.reserve = not Game.state.reserve))
 button(box,"AUTOBAHN & EXPORTHANDEL",func(): open_menu("export"))
 text(box,"Hier verkaufst du direkt am lokalen Markt. Autobahnexport benötigt eine Straßenverbindung und bezahlt erst bei Ankunft.",15,MUTED)
 button(contents,"ALLE WAREN ANZEIGEN" if not market_all else "NUR MEINE VORRÄTE",func(): market_all=not market_all; render_menu())
 var has_stock=false
 for key in Catalog.RESOURCES:
  if ConstructionRules.HARDWARE.has(key): continue
  if not market_all and float(Game.state.resources[key])<0.001: continue
  has_stock=true
  var id = str(key)
  var resource_box = card(Catalog.RESOURCES[key])
  dynamic_text(resource_box,func(): return "%s im Lager · %.1f Münzen/Stück" % [Catalog.number(Game.state.resources[id]),float(Catalog.PRICES[id])*Game.multiplier()*Game.boost("money")])
  var choices = row(resource_box)
  button(choices,"25 % verkaufen",func(): action(func(): Game.sell(id,0.25)))
  button(choices,"Alles verkaufen",func(): action(func(): Game.sell(id)))
 if not has_stock: card("Dein Lager ist noch leer","Fälle ein paar Bäume und liefere das Holz ab. Das Sägewerk verarbeitet es automatisch zu Brettern.")

func export_menu() -> void:
 modal_title.text="AUTOBAHN & EXPORT"
 var box=card("LKW-Fernhandel","Baue eine durchgehende Straße vom aktiven Markt bis zum markierten Anschluss bei 300 / 176. Zum Beispiel vom südlichen Straßenende bei 80 / 176 gerade nach Osten. Fußwege zählen nicht als LKW-Zufahrt.")
 dynamic_text(box,func(): return ExportTrade.status(Game.state))
 button(box,"ANSCHLUSS ANSEHEN",func(): focus_requested.emit(Vector3(288,0,176)); close_menu())
 button(box,"STRASSE ZUM ANSCHLUSS BAUEN",func(): request_placement({"network":true,"kind":"asphalt","overview":[220,245],"zoom":420}))
 button(box,"Neue Fahrten: AN" if Game.state.auto_export else "Neue Fahrten: AUS",func(): action(func(): Game.state.auto_export=not Game.state.auto_export))
 var key=str(Game.state.trade.material)
 var goods=card("Exportware · "+str(Catalog.RESOURCES.get(key,key)),"Geladen wird nur freie Lagerware nach Baureserve. Holz-, Stein- und Baustellenlieferungen teilen sich dieselben LKW und werden zuerst bedient. Die leere Rückfahrt belegt den LKW weiter.")
 dynamic_text(goods,func(): return "%s freie LKW · %s Exportfahrten
Bezahlt: %s Waren · %s Münzen" % [ExportTrade.available_trucks(Game.state),Game.state.trade.shipments.size(),Catalog.number(Game.state.trade.sold),Catalog.number(Game.state.trade.revenue)])
 text(goods,"Exportpreis: %.1f Münzen/Stück · 15 %% Fernhandelsbonus
Abrechnung erst nach Ankunft. Der beim Beladen vereinbarte Preis bleibt für diese Fahrt gültig." % (float(Catalog.PRICES[key])*ExportTrade.PREMIUM*Game.multiplier()*Game.boost("money")),15,GOLD)
 for material in ExportTrade.GOODS:
  var id=str(material)
  button(goods,("✓ " if id==key else "")+str(Catalog.RESOURCES[id]),func(): action(func(): Game.state.trade.material=id))
 for shipment in Game.state.trade.shipments:
  var trip=shipment
  var freight=card("%s %s · %s" % [int(trip.amount),Catalog.RESOURCES[trip.key],"Leere Rückfahrt" if trip.arrived else "Exportlieferung"])
  dynamic_text(freight,func(): return "%s in ca. %s s" % ["Zurück am Markt" if trip.arrived else "Bezahlung",ceili(maxf(0,float(trip.total if trip.arrived else trip.travel)-float(trip.age)))])
  button(freight,"LKW & ROUTE ANSEHEN",func(): close_menu(); ux.select_truck({"kind":"truck","domain":"export","id":int(trip.id)},true))
 card("Als Nächstes: Hafen & Flughafen","See- und Luftfracht sind geplant. Der Autobahnhandel nutzt bereits gespeicherte Frachtaufträge und getrennte Abrechnungen je Frachtweg. Das bestehende Hafen-Großprojekt erzielt weiterhin Projektertrag; Schiffs- und Flugexport sind noch nicht aktiv.")

func settings_menu() -> void:
 modal_title.text = "EINSTELLUNGEN"
 var box = card("Lokaler Spielstand","Automatische Speicherung alle 20 Sekunden, beim Wechsel in den Hintergrund und nach Bauaufträgen. Eine Backup-Datei schützt den vorherigen gültigen Stand. Bis zu acht Stunden Offline-Wirtschaft.")
 button(box,"JETZT SPEICHERN",func(): Game.save())
 button(box,"ALPHA 1 · TESTBERICHT & HILFE",func(): open_menu("alpha"))
 button(box,"Sounds: AUS" if Game.state.muted else "Sounds: AN",func(): action(func(): Game.state.muted = not Game.state.muted))
 button(box,"Benno: AN" if Game.state.companion_enabled else "Benno: AUS",func(): action(func(): Game.state.companion_enabled=not Game.state.companion_enabled))
 button(box,"Alltagsszenen: AN" if Game.state.ambient_enabled else "Alltagsszenen: AUS",func(): action(func(): Game.state.ambient_enabled=not Game.state.ambient_enabled))
 button(box,"Qualität: AKKUMODUS" if Game.state.quality == 0 else "Qualität: STANDARD",func(): action(func(): Game.state.quality = 1-int(Game.state.quality); Game.apply_device_profile()))
 button(box,"Automatische Detailentlastung: AN" if Game.state.ux.get("adaptive_detail",true) else "Automatische Detailentlastung: AUS",func(): action(func(): Game.state.ux.adaptive_detail=not Game.state.ux.get("adaptive_detail",true); RuntimeStats.low_detail=false))
 button(box,"STARTZEIT & FPS ANSEHEN",func(): open_menu("performance"))
 text(box,"Android: maximal 30 Bilder/s. Im Hintergrund ruht die Darstellung. Akkumodus reduziert zusätzlich 3D-Auflösung, Schatten und Umwelteffekte. Automatische Detailentlastung reagiert auf schlechte Bildzeiten; ein Temperatursensor wird nicht ausgelesen.",14,MUTED)
 if ux!=null: ux.settings_controls(box)
 text(contents,"Alpha 1 · %s · Testfassung\nKeine Werbung, keine In-App-Käufe, kein Cloud-Save. Geräteleistung und langfristige Balance werden separat geprüft." % ProjectSettings.get_setting("application/config/version"),14,MUTED)

func build_placement_bar() -> void:
 placement_panel=PanelContainer.new()
 add_child(placement_panel)
 placement_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 placement_panel.offset_left=14
 placement_panel.offset_right=-14
 placement_panel.offset_top=-470
 placement_panel.offset_bottom=-202
 placement_panel.grow_vertical=Control.GROW_DIRECTION_BEGIN
 placement_panel.clip_contents=true
 placement_panel.add_theme_stylebox_override("panel",style(INK,20))
 var frame=VBoxContainer.new()
 placement_panel.add_child(frame)
 var reading=load("res://UI/TouchScroll.gd").new()
 reading.size_flags_vertical=Control.SIZE_EXPAND_FILL
 frame.add_child(reading)
 var box=VBoxContainer.new()
 box.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 reading.add_child(box)
 placement_title=text(box,"",20,GOLD)
 placement_hint=text(box,"",14,CREAM)
 placement_materials=text(box,"",13,MUTED)
 var choices=row(frame)
 button(choices,"Abbrechen",func(): placement_action.emit("cancel"))
 placement_rotate=button(choices,"Drehen 90°",func(): placement_action.emit("rotate"))
 placement_undo=button(frame,"LETZTEN VORSCHAUSCHRITT ZURÜCK",func(): placement_action.emit("undo"))
 placement_confirm=button(choices,"BAUEN",func(): placement_action.emit("confirm"))
 placement_confirm.add_theme_stylebox_override("normal",style(Color("e2a536"),12))
 placement_panel.hide()

func request_placement(request: Dictionary) -> void:
 close_menu()
 placement_requested.emit(request)

func show_placement(request: Dictionary) -> void:
 close_menu()
 placement_undo.disabled=true
 placement_rotate.text="Drehen 90°"
 placement_rotate.disabled=false
 if request.get("network",false):
  placement_materials.text=""
  placement_title.text="HALTESTELLE" if request.kind=="bus_stop" else "VIERTEL MARKIEREN" if request.kind=="group" else "STRASSE / WEG"
  placement_confirm.text="BAUEN"
  placement_rotate.text="Kurve wechseln"
  placement_rotate.disabled=request.kind in ["bus_stop","group"]
  placement_panel.show()
  return
 var city=bool(request.get("city",false))
 var definition=(Catalog.HOMES if city else Catalog.BUILDINGS)[request.kind]
 var moving=int(request.get("index",-1))>=0
 var price=0.0 if moving else float(definition.cost)*Game.difficulty() if city else Game.cost_for(request.kind)
 placement_title.text="%s · %s" % [definition.name,"kostenlos verschieben" if moving else Catalog.number(price)+" Münzen"]
 var materials={} if moving else definition.materials if city else Game.build_materials(request.kind) if Game.company_level()>=4 else {}
 placement_materials.text="" if materials.is_empty() else ("Später per LKW: " if Game.company_level()>=4 or request.kind=="townhall" else "Beim Bau bezahlen: ")+materials_text(materials)
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
 modal_title.text="BENNO · DEIN ANFANG"
 companion.portrait.greet()
 var stories=["Hi, ich bin Benno! Hier wächst mehr als ein Wald: Hier beginnt deine eigene Holzfirma.","Vom Wald zum Hof: Dein Team sammelt Holz, Transporte bringen es zu den offenen Arbeitsplätzen.","Schau den Maschinen zu: Aus Stämmen werden Bretter und später Möbel. Du entscheidest, wie deine Firma wächst."]
 story_detail=text(contents,stories[story_step],15 if size.x<430 else 17,CREAM)
 # Shape the full paragraph before revealing it. Typing must never move the
 # action under a finger between touch-down and touch-up.
 story_detail.visible_characters_behavior=TextServer.VC_CHARS_AFTER_SHAPING
 story_shown=0
 story_detail.visible_ratio=0 if Game.state.ux.motion else 1
 var choices=row(contents)
 if story_step<2:
  var next=button(choices,"HOF ENTDECKEN ›",func():
   story_step+=1
   var point=Game.building_position(0 if story_step==1 else mini(1,Game.state.buildings.size()-1))
   focus_requested.emit(point)
   render_menu())
  next.add_theme_font_size_override("font_size",13)
 var resumable=TutorialRules.can_resume(Game.state)
 var free=button(choices,"Frei spielen" if resumable else "Zurück",func():
  if resumable: Game.end_tutorial()
  close_menu())
 free.add_theme_font_size_override("font_size",13)
 if resumable:
  button(contents,"LOS GEHT’S · KURZE ANLEITUNG",func(): Game.begin_tutorial(); close_menu(); focus_requested.emit(Catalog.biome_position(int(Game.state.biome))))
 else: button(contents,"WEITERSPIELEN",close_menu)
 call_deferred("layout_interface")

func guide_menu() -> void:
 if int(Game.state.tutorial)==0: welcome_menu(); return
 modal_title.text="DEIN WEG ZUM IMPERIUM"
 button(contents,"KAPITEL 1–10 · DEIN RATHAUS AUFBAUEN",func(): open_menu("journey"))
 var step=mini(int(Game.state.tutorial),4)
 var box=card("Schritt %s / 4" % step,["","Tippe auf Fällen oder auf Bäume. Nach fünf Fällaktionen geht es weiter.","Tippe auf Abliefern. Dein Rucksack wird in das Holzlager geleert; Helfer liefern zusätzlich automatisch.","Öffne Verkaufen und verkaufe etwas Holz oder Bretter. Missionsprämien helfen beim ersten Ausbau.","Öffne Bauen, wähle ein Gebäude und platziere es in der Welt. Grün bedeutet frei; Rot zeigt Straßen oder belegte Flächen."][step])
 button(box,"WEITER SPIELEN",func(): close_menu())
 var help=card("So funktioniert deine Produktion","Holz → Sägewerk → Bretter → Trockenkammer → Trockenholz → Möbelfabrik → Möbel. Der lokale Laden verkauft seine Lieferware; Fernexporte fahren über den verbundenen Autobahnanschluss. Tippe direkt auf ein Gebäude für Zustand, Ausbau und Verschieben. LKWs verbinden die Betriebe über das Straßennetz.")
 text(help,"Spänebox: regelmäßig leeren und verkaufen. Bei Störungen zeigt das Betriebsfenster den konkreten Grund. Mit einem Finger die Welt bewegen, mit zwei Fingern zoomen. Im Baumodus bewegt ein Finger das Bauwerk; zwei Finger bewegen die Kamera.",15,MUTED)
 button(help,"LIEFERKETTE & LADENAUFTRÄGE",func(): open_menu("delivery"))
 button(help,"BAUSTELLEN & MATERIALDEPOT",func(): open_menu("construction"))
 button(help,"BAUKATALOG ÖFFNEN",func(): open_menu("catalog"))
 if TutorialRules.can_resume(Game.state):
  button(help,"BENNO ZEIGT MIR DEN NÄCHSTEN SCHRITT",func(): Game.begin_tutorial(); close_menu())
  button(help,"ANLEITUNG ÜBERSPRINGEN",func(): Game.end_tutorial(); close_menu())


func networks_menu() -> void:
 modal_title.text="STRASSEN & WEGE"
 card("Dein eigenes Wegenetz","Startpunkt antippen, Ziel antippen oder ziehen, Kurve wählen und bestätigen. Zwei Finger bewegen die Karte. Straßen müssen an das vorhandene Netz anschließen; Fußwege dürfen auch frei liegen. Gebäude und Wasser bleiben frei.")
 var links=row(contents)
 button(links,"Stadt",func(): open_menu("city"))
 button(links,"Buslinien",func(): open_menu("transit"))
 button(contents,"AUTOBAHNANSCHLUSS & EXPORTHANDEL",func(): open_menu("export"))
 button(contents,"LETZTE UNBENUTZTE STRASSE ZURÜCKNEHMEN",func(): action(func(): Game.undo_road()),not Game.state.ux.road_undo.is_empty())
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
 card("Erst Material. Dann Richtfest.","Jede Bauphase wartet auf ihre tatsächlichen Materialien. Mit fertigem Zentrallager nutzen Baustellen eine eigene schwarz-weiße Flotte und entfernte Baustellen den Abhol-Express. Ohne Zentrale teilen sie den gekauften Fuhrpark.")
 if Game.state.jobs.is_empty(): card("Keine offenen Baustellen","Im Baukatalog ein Gebäude platzieren oder auf einen Betrieb tippen und Ausbauen wählen.")
 else:
  if job_filter>=0:
   button(contents,"ALLE BAUSTELLEN",func(): job_filter=-1; render_menu())
  jobs_cards(job_filter)
 button(contents,"LOGISTIKÜBERSICHT",func(): logistics_tab="sites"; open_menu("logistics"))
 var crew=card("Bauteam: %s · %s frei" % [Game.state.builders,Game.free_builders()],"Freie Bauteams übernehmen automatisch den nächsten bezahlten Auftrag. Eine manuelle Zuweisung bleibt erhalten. Ab Unternehmenslevel 4 gilt das Materialsystem auch für weitere Gebäude; bis zu fünf Bauarbeiter arbeiten je Baustelle.")
 button(crew,"BAUARBEITER EINSTELLEN · %s" % Catalog.number(150*pow(1.6,int(Game.state.builders)-2)*Game.difficulty()),func(): action(func(): Game.hire_builder()),Game.company_level()>=4 and int(Game.state.builders)<8)
 if Game.company_level()<4: text(crew,"Dein Level: %s/4 · Neue Industriebetriebe benötigen bis dahin nur Geld. Dein Rathaus erhält schon echte Lieferungen." % Game.company_level(),15,MUTED)
 var depot = card("Materialdepot · nur Spielmünzen","Muttern und Schrauben werden hier mit erspielten Münzen gekauft. Holz und Bretter liefert deine Produktion.")
 for key in ConstructionRules.HARDWARE:
  var id = str(key)
  dynamic_text(depot,func(): return "%s: %s im Lager · %s Münzen/Stück" % [Catalog.RESOURCES[id],Catalog.number(Game.state.resources[id]),Catalog.number(float(ConstructionRules.HARDWARE[id])*Game.difficulty())])
  var choices = row(depot)
  button(choices,"1 KAUFEN",func(): action(func(): Game.buy_hardware(id,1)))
  button(choices,"10 KAUFEN",func(): action(func(): Game.buy_hardware(id,10)))
 button(contents,"STEINBRUCH & BAUSTOFFE",func(): open_menu("stone"))
 card("So wird geliefert","Der Bauauftrag wird beim Platzieren bezahlt. Ein LKW lädt tatsächliche Ware, fährt über Straßen, entlädt und kehrt leer zurück. Fertigwaren bleiben vor automatischem Verkauf geschützt; Zutaten dürfen fehlendes Baumaterial erzeugen. Muttern und Schrauben werden mit Spielmünzen im Materialdepot gekauft. Tippe auf eine Ware für Bestand, Quelle und Lieferstatus.")
 button(contents,"BAUKATALOG",func(): open_menu("catalog"))


func services_menu() -> void:
 modal_title.text="EINSATZZENTRALE & STADTLEBEN"
 var data=Game.state.city_services
 var summary=card("Feuerwehr im Einsatz" if not data.fires.is_empty() else "Keine aktiven Brände")
 dynamic_text(summary,func(): return "%s aktive Brände · %s erfolgreich gelöscht" % [data.fires.size(),int(data.fires_extinguished)])
 dynamic_text(summary,func():
  var fleet=FireSafety.fleet(Game.state)
  return "Löschfahrzeuge: %s/%s belegt · %s frei · %s" % [fleet.busy,fleet.capacity,fleet.free,"Gemeindehilfe" if fleet.external else "Eigene Wache"])
 button(summary,"RAUCHMELDER & HYDRANTEN",func(): open_menu("fire_protection"))
 for incident in data.fires:
  var fire=incident
  var home=Game.state.homes[int(fire.target_ref.index)]
  var alert=card("BRAND · "+str(Catalog.HOMES[home.kind].name))
  dynamic_text(alert,func(): return FireSafety.status(Game.state,fire) if fire in data.fires else "Brand gelöscht")
  text(alert,"Brandstärke (verbleibender Brand)",13,MUTED)
  journey_ui.meter(alert,func(): return (1-float(fire.progress))*100 if fire in data.fires else 0,100)
  text(alert,"Löschfortschritt",13,MUTED)
  journey_ui.meter(alert,func(): return float(fire.progress)*100 if fire in data.fires else 100,100)
  text(alert,"Gebäudeschaden: 0 · Gebäude und Ausbaustufe bleiben erhalten.",13,MUTED)
  if FireSafety.alarm_left(fire)>0:
   button(alert,"JETZT FEUERWEHR ALARMIEREN",func(): action(func(): Game.report_fire(int(fire.id))))
  if fire.get("wait_reason","")=="route":
   button(alert,"STRASSENANSCHLUSS PRÜFEN",func(): open_menu("networks"))
  button(alert,"EINSATZORT ANSEHEN",func():
   if fire in data.fires:
    focus_requested.emit(CityServices.location(Game.state,fire.target_ref))
    close_menu())
 var box=card("Gemeindedienste","Ohne eigene Wache hilft die Nachbargemeinde. Eigene Standorte verkürzen Wege und stellen mit jedem Ausbau mehr Fahrzeuge bereit.")
 button(box,"Neue Ereignisse & Fahrten: AN" if data.enabled else "Neue Ereignisse & Fahrten: AUS",func(): action(func(): data.enabled=not data.enabled))
 dynamic_text(box,func(): return "%s aktive Fahrten · %s Spaziergänger\nStadtkasse: %s Münzen" % [data.missions.size(),data.walkers.size(),Catalog.number(float(data.treasury)*Game.multiplier())])
 button(box,"STADTKASSE ABHOLEN",func(): action(func(): Game.collect_city_income()))
 text(box,"Neue Ereignisse lassen sich pausieren. Gemeldete Brände werden weiter gelöscht, auch während deiner Abwesenheit. Gebäude bleiben erhalten; es gibt keine Strafzahlungen.",14,MUTED)
 for kind in CityServices.TYPES:
  var key=str(kind)
  var definition=Catalog.HOMES[CityServices.BUILDINGS[kind]]
  var card_box=card({"police":"Polizei","fire":"Feuerwehr","ambulance":"Rettungsdienst","taxi":"Taxi"}[kind],"Eigener Standort: "+definition.name+". Kürzere Wege und mit höherem Gebäudelevel mehr gleichzeitig verfügbare Dienstfahrzeuge.")
  dynamic_text(card_box,func(): return "%s abgeschlossene Aufträge" % int(data.completed.get(key,0)))
  button(card_box,"FAHRT ANFORDERN",func(): action(func(): Game.request_city_service(key)))
  button(card_box,"STANDORT BAUEN",func(): request_placement({"kind":CityServices.BUILDINGS[key],"city":true,"index":-1,"plot":-1}),Game.level("prefab")>0)
 for mission in data.missions:
  var job=mission
  var entry=card("Gebäudebrand löschen" if job.has("fire_id") else CityServices.NAMES[job.kind])
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

func fire_protection_menu() -> void:
 modal_title.text="BRANDSCHUTZ FÜR DEINE STADT"
 card("Früh erkennen. Schneller löschen.","Rauchmelder: sofortige automatische Erkennung neuer Brände statt 12 Sekunden Wartezeit. Hydrant: versorgt angeschlossene Gebäude im Umkreis von 44 m; Löscharbeit 24 statt 36 Sekunden. Kein laufender Münzverbrauch.")
 var found=false
 for i in Game.state.homes.size():
  if not FireSafety.eligible(Game.state,i): continue
  found=true
  var index=i
  var home=Game.state.homes[index]
  var box=card(str(Catalog.HOMES[home.kind].name)+" · Grundstück %s" % (int(home.plot)+1))
  var water=FireSafety.water_source(Game.state,index,Game.city_route_cache)
  text(box,"Löschwasserversorgung: Hydrant in Reichweite" if not water.is_empty() else "Löschwasserversorgung: Fahrzeugversorgung",14,MUTED)
  for part in ["detector","hydrant"]:
   var kind=str(part)
   var installed=FireSafety.installed(Game.state,index,kind)
   var title="RAUCHMELDER" if kind=="detector" else "HYDRANT"
   button(box,title+" INSTALLIERT" if installed else title+" · %s MÜNZEN" % Game.fire_protection_cost(kind),func(): action(func(): Game.buy_fire_protection(index,kind)),not installed and float(Game.state.coins)>=Game.fire_protection_cost(kind))
  button(box,"GEBÄUDE ANSEHEN",func(): focus_requested.emit(Game.home_position(index)); close_menu())
 if not found: card("Zuerst Wohnraum bauen","Sobald das erste bewohnte Stadtgebäude fertig ist, kannst du dort Rauchmelder und Hydranten installieren.")
 text(contents,"Neue Rauchmelder gelten für neue Brandereignisse. Hydranten werden bei der Disposition geprüft; bereits laufende Einsätze behalten ihre geplante Löschzeit. Die Wirkung wird vor dem Kauf angezeigt.",14,MUTED)
 button(contents,"ZUR EINSATZZENTRALE",func(): open_menu("services"))

func game_menu() -> void:
 modal_title.text="DEIN WALD · SPIELMENÜ"
 button(contents,"WEITERSPIELEN",close_menu)
 button(contents,"ANLEITUNG & HILFE",func(): open_menu("guide"))
 button(contents,"ALPHA 1 · FEEDBACK",func(): open_menu("alpha"))
 button(contents,"EINSTELLUNGEN",func(): open_menu("settings"))
 button(contents,"SPEICHERN & ZUM STARTBILDSCHIRM",func():
  if not Game.save(true): show_notice(Store.last_error); return
  Game.title_requested=true
  var error=get_tree().change_scene_to_file("res://Scenes/Boot.tscn")
  if error!=OK:
   Game.title_requested=false
   show_notice("Der Startbildschirm konnte nicht geöffnet werden"))
