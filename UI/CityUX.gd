extends Control

var hud
var selection={}
var sheet: PanelContainer
var sheet_body: VBoxContainer
var sheet_scroll
var sheet_title: Label
var sheet_close: Button
var palette: PanelContainer
var palette_body: VBoxContainer
var event_button: Button
var carousel
var refresh_clock=0.0
var material_key="boards"
var preview_kind="apartments"
var preview_level=1
var unlock_district=0
var selected_biome=0
var group_id=-1
var palette_category="Produktion"
var sheet_start=Vector2.ZERO
var sheet_gesture=false
var last_feedback=-1000
var last_delivery_sound=-5000
var known_built=0

func world(): return hud.get_parent().get_parent()
func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 sheet=PanelContainer.new()
 add_child(sheet)
 sheet.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 sheet.offset_left=14
 sheet.offset_right=-14
 sheet.offset_top=-502
 sheet.offset_bottom=-204
 sheet.grow_vertical=Control.GROW_DIRECTION_BEGIN
 sheet.clip_contents=true
 sheet.add_theme_stylebox_override("panel",hud.style(hud.PAPER,20))
 var frame=VBoxContainer.new()
 frame.set_meta("light_card",true)
 frame.add_theme_constant_override("separation",5)
 sheet.add_child(frame)
 var handle=hud.text(frame,"━━  HOCHWISCHEN FÜR DETAILS",11,hud.MUTED)
 handle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 var heading=hud.row(frame)
 sheet_title=hud.text(heading,"",19,hud.INK)
 sheet_title.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 sheet_title.max_lines_visible=2
 sheet_title.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
 sheet_close=hud.button(heading,"×",func(): hide_panels(true))
 sheet_close.custom_minimum_size=Vector2(44,44)
 sheet_close.size_flags_horizontal=Control.SIZE_SHRINK_END
 # A scroll container isolates the content's minimum height from the panel.
 # Dynamic text wrapping must never grow and permanently displace this card.
 sheet_scroll=load("res://UI/TouchScroll.gd").new()
 sheet_scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
 frame.add_child(sheet_scroll)
 sheet_body=VBoxContainer.new()
 sheet_body.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 sheet_body.set_meta("light_card",true)
 sheet_body.add_theme_constant_override("separation",5)
 sheet_scroll.add_child(sheet_body)
 hud.resized.connect(layout_sheet)
 layout_sheet()
 sheet.hide()
 palette=PanelContainer.new()
 add_child(palette)
 palette.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 palette.offset_left=14
 palette.offset_right=-14
 palette.offset_top=-490
 palette.offset_bottom=-204
 palette.grow_vertical=Control.GROW_DIRECTION_BEGIN
 palette.add_theme_stylebox_override("panel",hud.style(hud.INK,20))
 palette_body=VBoxContainer.new()
 palette_body.add_theme_constant_override("separation",5)
 palette.add_child(palette_body)
 palette.hide()
 event_button=hud.button(self,"Hinweise",func(): hud.open_menu("return" if not Game.return_report.is_empty() else "events"))
 event_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
 event_button.offset_left=14
 event_button.offset_right=182
 event_button.offset_top=170
 event_button.offset_bottom=214
 event_button.custom_minimum_size.y=44
 event_button.add_theme_font_size_override("font_size",13)
 hud.compact_style(event_button,hud.INK)
 Game.changed.connect(refresh)
 Game.construction_finished.connect(on_completed)
 Game.shipment_delivered.connect(on_delivery)
 refresh()
func layout_sheet() -> void:
 var clearance=maxf(204,hud.bottom_panel.get_combined_minimum_size().y+24)
 var height=minf(360,maxf(120,hud.size.y-clearance-218))
 var inset=maxf(14,(hud.size.x-760)/2)
 sheet.offset_left=inset
 sheet.offset_right=-inset
 sheet.offset_top=-clearance-height
 sheet.offset_bottom=-clearance
func panels_visible() -> bool: return sheet.visible or palette.visible
func hide_panels(clear: bool=false) -> void:
 sheet.hide()
 palette.hide()
 sheet_scroll.scroll_vertical=0
 sheet_scroll.velocity=0
 if clear:
  selection={}
  if world().get("selection_world")!=null: world().selection_world.choose({})
func feedback(kind: String="tap") -> void:
 var now=Time.get_ticks_msec()
 if now-last_feedback<80: return
 last_feedback=now
 if bool(Game.state.ux.vibration) and OS.get_name()=="Android": Input.vibrate_handheld(25 if kind=="build" else 12)
 if world().get("audio")!=null: world().audio.play_tone(500 if kind=="build" else 340,0.06 if kind=="build" else 0.025)
func on_delivery(at: Vector3,_key: String,_amount: float) -> void:
 if not Game.state.ux.motion or Time.get_ticks_msec()-last_delivery_sound<2500: return
 if world().get("camera")==null or world().camera.is_position_behind(at) or world().zoom>180: return
 last_delivery_sound=Time.get_ticks_msec()
 if world().get("audio")!=null: world().audio.play_tone(640,0.045)
func on_completed(_at: Vector3,_kind: String) -> void:
 feedback("build")
 refresh()
func select_building(index: int,city: bool=false,focus: bool=false) -> void:
 var records=Game.state.homes if city else Game.state.buildings
 if index<0 or index>=records.size(): return
 selection={"kind":"home" if city else "building","index":index}
 hud.current="plot" if city else "building"
 hud.current_index=int(records[index].plot) if city else index
 hud.close_menu()
 palette.hide()
 sheet_scroll.scroll_vertical=0
 sheet_scroll.velocity=0
 if focus: hud.focus_requested.emit(Game.home_position(index) if city else Game.building_position(index))
 if world().get("selection_world")!=null: world().selection_world.choose(selection)
 render_sheet()
func select_job(id: int,focus: bool=false) -> void:
 for job in Game.state.jobs:
  if int(job.get("id",-1))!=id: continue
  selection={"kind":"job","id":id}
  hud.current="construction"
  hud.close_menu()
  palette.hide()
  sheet_scroll.scroll_vertical=0
  sheet_scroll.velocity=0
  if focus: hud.focus_requested.emit(ConstructionRules.job_position(Game.state,job))
  if world().get("selection_world")!=null: world().selection_world.choose(selection)
  render_sheet()
  return
func select_truck(value: Dictionary,focus: bool=false) -> void:
 selection=value.duplicate(true)
 if focus:
  var trip=find_trip()
  if not trip.is_empty():
   hud.focus_requested.emit(TrafficRules.sample(trip,TrafficRules.visual_age(trip,Game.tick_clock)).position)
  if world().get("selection_world")!=null: world().selection_world.show_routes=true
 hud.close_menu()
 palette.hide()
 sheet_scroll.scroll_vertical=0
 sheet_scroll.velocity=0
 if world().get("selection_world")!=null: world().selection_world.choose(selection)
 render_sheet()
func find_job() -> Dictionary:
 for job in Game.state.jobs:
  if int(job.get("id",-1))==int(selection.get("id",-2)): return job
 return {}
func find_trip() -> Dictionary:
 for s in Game.state.delivery.shipments+Game.state.construction_shipments+Game.state.stone.shipments+Game.state.trade.shipments:
  var domain="construction" if s.target=="construction" else "stone" if s.target=="mineral" else "export" if s.target=="export" else "wood"
  if domain==selection.get("domain","") and int(s.id)==int(selection.get("id",-1)): return s
 return {}
func clear_box(box: Node) -> void:
 for child in box.get_children(): box.remove_child(child); child.queue_free()
func sheet_actions() -> BoxContainer:
 if hud.size.x>=400: return hud.row(sheet_body)
 var column=VBoxContainer.new()
 column.add_theme_constant_override("separation",5)
 sheet_body.add_child(column)
 return column
func render_sheet() -> void:
 var previous_scroll=sheet_scroll.scroll_vertical
 clear_box(sheet_body)
 if selection.is_empty(): sheet.hide(); return
 var title=sheet_title
 if selection.kind in ["building","home"]:
  var city=selection.kind=="home"
  var index=int(selection.index)
  var records=Game.state.homes if city else Game.state.buildings
  if index>=records.size(): hide_panels(true); return
  var b=records[index]
  title.text="%s · %s%s" % [UXRules.title(Game.state,city,index),int(b.level),"/10" if city else ""]
  var status="Miete: %s Münzen · %s Bewohner" % [Catalog.number(float(b.get("rent_bank",0))),int(Catalog.HOMES[b.kind].people)*int(b.level)] if city else Game.production_status(index)
  var label=hud.text(sheet_body,status,14,hud.MUTED)
  label.max_lines_visible=3
  var goods=hud.row(sheet_body)
  var needs=[]
  if not city and Game.delivery_owns(index):
   var info=DeliveryChain.status(Game.state,b.kind)
   needs.append(str(info.key))
   if info.has("output_key"): needs.append(str(info.output_key))
  elif not city and Catalog.RECIPES.has(b.kind): needs=Catalog.RECIPES[b.kind]["in"].keys()
  elif city: needs=Catalog.HOMES[b.kind].materials.keys()
  for key_value in needs.slice(0,3):
   var key=str(key_value)
   var item=hud.button(goods,Catalog.RESOURCES[key],func(): open_material(key))
   item.clip_text=true
   item.add_theme_font_size_override("font_size",13)
  sheet_body.move_child(goods,0)
  var actions=sheet_actions()
  var bill=UXRules.upgrade_bill(Game.state,city,index)
  hud.button(actions,"Ausbauen · %s" % Catalog.number(bill.coins) if not bill.is_empty() else ("MAX · Stufe %s" % int(b.level) if int(b.level)>=(10 if city else int(Catalog.BUILDINGS[b.kind].max)) else "Ausbau läuft"),func():
   if city: Game.upgrade_home(index)
   else: Game.upgrade(index)
   refresh(),not bill.is_empty())
  if city and float(Catalog.HOMES[b.kind].rent)>0: hud.button(actions,"Miete abholen",func(): Game.collect_rent(index); refresh())
  else: hud.button(actions,"Wege ausblenden" if world().get("selection_world")!=null and world().selection_world.show_routes else "Wege anzeigen",func(): toggle_routes())
  if city and FireSafety.eligible(Game.state,index):
   hud.button(sheet_body,"BRANDSCHUTZ · RAUCHMELDER & HYDRANT",func(): hud.open_menu("fire_protection"))
  var other=sheet_actions()
  hud.button(other,"Details ↑",func(): expand_selection())
  hud.button(other,"Stufen 1–10" if city else "Verschieben",func():
   if city: show_evolution(b.kind,int(b.level))
   else: hud.request_placement({"kind":b.kind,"city":false,"index":index}))
 elif selection.kind=="job":
  var job=find_job()
  if job.is_empty(): hide_panels(true); return
  title.text="Baustelle · "+str(Catalog.HOMES[job.kind].name if job.type in ["home","home_upgrade"] else Catalog.BUILDINGS.get(job.kind,{"name":"Bauprojekt"}).name)
  hud.text(sheet_body,ConstructionRules.status(job),14,hud.MUTED)
  var row=hud.row(sheet_body)
  for resource in job.get("materials",{}):
   var key=str(resource)
   var count=UXRules.material_counts(Game.state,job,key)
   if count.missing<=0 and count.incoming<=0: continue
   var item=hud.button(row,"%s\n%s da · %s fährt · %s fehlt" % [Catalog.RESOURCES[key],int(count.arrived),int(count.incoming),int(count.missing)],func(): open_material(key))
   item.clip_text=true
   item.add_theme_font_size_override("font_size",12)
   if row.get_child_count()>=2: break
  var actions=sheet_actions()
  hud.button(actions,"Wege ausblenden" if world().get("selection_world")!=null and world().selection_world.show_routes else "Wege anzeigen",func(): toggle_routes())
  hud.button(actions,"Bauteam & Details ↑",func(): expand_selection())
 elif selection.kind=="truck":
  var s=find_trip()
  title.text="Lieferfahrzeug"
  if s.is_empty(): hud.text(sheet_body,"Fahrt abgeschlossen · Fahrzeug wieder verfügbar",15,hud.INK)
  else:
   var target="Baustelle" if s.target=="construction" else ("Lager" if int(s.destination)<0 else UXRules.title(Game.state,false,int(s.destination))) if s.target=="mineral" else "Autobahnexport" if s.target=="export" else Catalog.BUILDINGS[s.target].name
   var stage="Leere Rückfahrt" if s.arrived else "Beladen" if float(s.age)<float(s.load) else "Entladen" if float(s.age)>=float(s.load)+float(s.drive) else "Unterwegs"
   if not s.arrived and float(s.age)>=float(s.travel): stage="Wartet auf freien Entladeplatz"
   if not str(s.get("traffic_wait","")).is_empty(): stage=str(s.traffic_wait)
   var source=UXRules.title(Game.state,false,int(s.origin)) if int(s.get("origin",-1))>=0 else ConstructionRules.source_name(s)
   hud.text(sheet_body,"%s\n%s → %s\n%s" % [stage,source,target,"Leer" if s.arrived else "%s %s an Bord" % [Catalog.number(s.amount),Catalog.RESOURCES[s.key]]],15,hud.INK)
   var remaining=maxf(0,float(s.total if s.arrived else s.travel)-float(s.age))
   hud.text(sheet_body,"%s: ca. %s s" % ["Zurück am Start" if s.arrived else "Ankunft bei freiem Entladeplatz",ceili(remaining)],14,hud.MUTED)
  hud.button(sheet_body,"Route hervorheben",func(): toggle_routes())
 apply_fonts(sheet)
 layout_sheet()
 sheet.show()
 sheet_scroll.set_deferred("scroll_vertical",previous_scroll)
func expand_selection() -> void:
 if selection.is_empty(): return
 sheet.hide()
 match str(selection.kind):
  "building": hud.show_building(int(selection.index))
  "home": hud.show_plot(int(Game.state.homes[int(selection.index)].plot))
  "job": hud.open_menu("construction")
  "truck": hud.open_menu("export" if selection.get("domain","")=="export" else "delivery")
func toggle_routes() -> void:
 if world().get("selection_world")==null: return
 world().selection_world.show_routes=not world().selection_world.show_routes
 world().selection_world.refresh()
 hud.show_notice("Lieferwege eingeblendet" if world().selection_world.show_routes else "Lieferwege ausgeblendet")
func refresh() -> void:
 var count=UXRules.current_hints(Game.state).size()
 for event in Game.state.ux.events:
  if not event.read: count+=1
 event_button.text="● Mitteilungen · %s" % count if count>0 else "✓ Mitteilungen"
 if not Game.return_report.is_empty(): event_button.text="Rückkehrbilanz ›"
 var content_gesture=sheet_scroll.pointer!=-99 or absf(sheet_scroll.velocity)>=8
 if sheet.visible and not sheet_gesture and not content_gesture and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): render_sheet()
func _process(delta: float) -> void:
 refresh_clock+=delta
 event_button.visible=not hud.overlay.visible and not hud.placement_panel.visible and not palette.visible
 if refresh_clock>=1:
  refresh_clock=0
  refresh()
func _input(event: InputEvent) -> void:
 if not sheet.visible: sheet_gesture=false; return
 if event is InputEventScreenTouch:
  if event.pressed and Rect2(sheet.global_position,Vector2(sheet.size.x,32)).has_point(event.position):
   sheet_gesture=true
   sheet_start=event.position
   get_viewport().set_input_as_handled()
  elif not event.pressed and sheet_gesture:
   sheet_gesture=false
   if not event.canceled:
    if sheet_start.y-event.position.y>35: expand_selection()
    elif event.position.y-sheet_start.y>35: hide_panels(true)
   get_viewport().set_input_as_handled()
 elif event is InputEventScreenDrag and sheet_gesture: get_viewport().set_input_as_handled()

func open_palette() -> void:
 hud.close_menu()
 hide_panels(true)
 if hud.placement_panel.visible: hud.placement_action.emit("cancel")
 clear_box(palette_body)
 var heading=hud.row(palette_body)
 var title=hud.text(heading,"BAUEN · KARTE BLEIBT FREI",15,hud.GOLD)
 title.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 hud.button(heading,"×",func(): palette.hide()).size_flags_horizontal=Control.SIZE_SHRINK_END
 var tabs=hud.row(palette_body)
 for item in ["Produktion","Stadt","Versorgung","Wege"]:
  var category=str(item)
  var tab=hud.button(tabs,category,func(): palette_category=category; open_palette())
  tab.add_theme_font_size_override("font_size",12)
  hud.compact_style(tab,hud.GOLD if category==palette_category else hud.PANEL)
 carousel=load("res://UI/TouchCarousel.gd").new()
 carousel.custom_minimum_size.y=106
 carousel.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 palette_body.add_child(carousel)
 var tiles=HBoxContainer.new()
 tiles.add_theme_constant_override("separation",8)
 carousel.add_child(tiles)
 if palette_category=="Wege":
  for kind in ["asphalt","path","bus_stop","group"]:
   var key=str(kind)
   var label={"asphalt":"Asphaltstraße","path":"Fußweg","bus_stop":"Haltestelle","group":"Viertel markieren"}[key]
   var tile=hud.button(tiles,label+"\nStandort wählen",func():
    palette.hide()
    hud.request_placement({"kind":key,"network":true}))
   tile.custom_minimum_size=Vector2(156,100)
 else:
  var city=palette_category=="Stadt"
  var definitions=Catalog.HOMES if city else Catalog.BUILDINGS
  for kind_value in definitions:
   var key=str(kind_value)
   if not city and ((palette_category=="Versorgung")!=(key in ["station","cabin","warehouse","market","research","garage"])): continue
   var definition=definitions[key]
   var price=float(definition.cost)*Game.difficulty() if city else Game.cost_for(key)
   var enabled=Game.home_available(key) and (key=="townhall" or Game.next_city_plot()>=0) if city else Game.available(key)
   var name_value=TownEvolution.title(key,1) if city else str(definition.name)
   var tile=hud.button(tiles,"%s\n%s Münzen\n%s" % [name_value,Catalog.number(price),"Platzieren" if enabled else "Noch gesperrt"],func():
    palette.hide()
    hud.request_placement({"kind":key,"city":city,"index":-1}),enabled)
   tile.custom_minimum_size=Vector2(166,100)
   tile.add_theme_font_size_override("font_size",14)
 var actions=hud.row(palette_body)
 hud.button(actions,"Vollständiger Katalog",func(): palette.hide(); hud.open_menu("catalog"))
 hud.button(actions,"Karte & Viertel",func(): palette.hide(); hud.open_menu("overview"))
 apply_fonts(palette)
 palette.show()
func open_material(key: String) -> void:
 material_key=key
 hud.open_menu("material_help")
func show_evolution(kind: String,level: int) -> void:
 preview_kind=kind
 preview_level=clampi(level,1,10)
 hud.open_menu("evolution")
func populate_menu(tab: String) -> void:
 match tab:
  "material_help": material_menu()
  "overview": map_menu()
  "evolution": evolution_menu()
  "events": events_menu()
  "districts": groups_menu()
  "district_unlock": unlock_menu()
  "biome_unlock": biome_menu()
func material_menu() -> void:
 var key=material_key
 hud.modal_title.text=Catalog.RESOURCES.get(key,key).to_upper()+" · VERSORGUNG"
 var box=hud.card("Wo liegt die Ware?","Lager, lokale Ausgänge und LKW-Ladungen werden getrennt gezählt. Tippe auf eine Quelle, um ihren Betrieb und den tatsächlichen Zustand anzusehen.")
 for source in UXRules.material_sources(Game.state,key):
  var index=int(source.index)
  hud.button(box,"%s · Produktion fürs Lager →" % source.name if source.get("shared",false) else "%s · %s verfügbar →" % [source.name,Catalog.number(source.amount)],func(): select_building(index,false,true))
 for job in Game.state.jobs:
  if not job.get("materials",{}).has(key): continue
  var id=int(job.get("id",-1))
  var count=UXRules.material_counts(Game.state,job,key)
  var site=hud.card("Baustelle benötigt %s %s" % [Catalog.number(count.total),Catalog.RESOURCES[key]],"%s angekommen · %s unterwegs · %s fehlen" % [Catalog.number(count.arrived),Catalog.number(count.incoming),Catalog.number(count.missing)])
  hud.button(site,"BAUSTELLE ANSEHEN",func(): select_job(id,true))
 var cargo=hud.card("Tatsächlich unterwegs")
 var found=false
 for s in Game.state.delivery.shipments+Game.state.construction_shipments+Game.state.stone.shipments+Game.state.trade.shipments:
  if s.key!=key or s.arrived: continue
  found=true
  var selected={"kind":"truck","id":int(s.id),"domain":"construction" if s.target=="construction" else "stone" if s.target=="mineral" else "export" if s.target=="export" else "wood"}
  var at=TrafficRules.sample(s,TrafficRules.visual_age(s,Game.tick_clock)).position
  hud.button(cargo,"%s %s · LKW ansehen" % [Catalog.number(s.amount),Catalog.RESOURCES[key]],func(): hud.focus_requested.emit(at); select_truck(selected))
 if not found: hud.text(cargo,"Momentan keine beladene Lieferung dieser Ware.",15,hud.MUTED)
 if ConstructionRules.HARDWARE.has(key):
  hud.button(box,"10 EINHEITEN KAUFEN · %s MÜNZEN" % Catalog.number(float(ConstructionRules.HARDWARE[key])*10*Game.difficulty()),func(): hud.action(func(): Game.buy_hardware(key,10)),float(Game.state.resources[key])+10<=Game.capacity() and float(Game.state.coins)>=float(ConstructionRules.HARDWARE[key])*10*Game.difficulty())
 elif key in ["stone","gravel"]:
  hud.button(box,"10 EINHEITEN NOTMATERIAL · %s MÜNZEN" % Catalog.number(Game.stone_trader_price(key)*10),func(): hud.action(func(): Game.buy_stone_material(key,10)),Game.company_level()>=5 and float(Game.state.resources[key])+10<=Game.capacity() and float(Game.state.coins)>=Game.stone_trader_price(key)*10)
 var kind={"wood":"station","boards":"sawmill","dry":"kiln","furniture":"furniture","walls":"prefab","roofs":"prefab","parts":"joinery","paper":"paper","design":"design","pellets":"pellet","sawdust":"sawmill","rock":"quarry","stone":"stoneworks","gravel":"stoneworks"}.get(key,"")
 if not kind.is_empty(): hud.button(box,"WEITERE PRODUKTIONSQUELLE BAUEN",func(): hud.request_placement({"kind":kind,"city":false,"index":-1}),Game.available(kind))
 hud.button(hud.contents,"BAUMATERIAL & HARDWARE",func(): hud.open_menu("construction"))
func map_menu() -> void:
 hud.modal_title.text="DEINE STADT · ÜBERSICHT"
 hud.text(hud.contents,"Haus = Wohnen · Quadrat = Betrieb · Kreuzkreis = Baustelle · Zahlenkreis = Wald · ZU = gesperrt. Tippe auf einen Ort.",14,hud.CREAM)
 var map=load("res://UI/CityMap.gd").new()
 var tabs=hud.row(hud.contents)
 for value in ["Alles","Bau","Logistik"]:
  var mode=str(value)
  hud.button(tabs,mode,func(): map.filter=mode; map.queue_redraw())
 hud.contents.add_child(map)
 map.set_meta("gesture_passthrough",true)
 map.chosen.connect(on_map_choice)
 var actions=hud.row(hud.contents)
 hud.button(actions,"Viertel verwalten",func(): hud.open_menu("districts"))
 hud.button(actions,"Waldregionen",func(): hud.open_menu("world"))
 hud.button(hud.contents,"ALLE MIETEN ABHOLEN · %s" % Catalog.number(Game.rent_total()),func(): hud.action(func(): Game.collect_rent()))
func unlock_menu() -> void:
 hud.modal_title.text="OSTVIERTEL" if unlock_district==0 else "WESTVIERTEL"
 var open=int(Game.state.town.districts)>unlock_district
 var box=hud.card("Zufahrt vorhanden" if open else "Viertelzufahrt ausbauen","Optionaler Straßenausbau. Gebäude sind auf freiem Festland bereits frei platzierbar; gesperrte Biome bleiben geschützt.")
 if not open:
  hud.text(box,"Benötigt: drei Regionen und 20 Bewohner\nAktuell: %s Regionen · %s Bewohner\nKosten: %s Münzen" % [int(Game.state.region)+1,Game.residents(),Catalog.number(Game.district_cost())],16,hud.INK)
  hud.button(box,"VIERTEL ERSCHLIESSEN",func(): hud.action(func(): Game.expand_district()),int(Game.state.town.districts)==unlock_district and int(Game.state.region)>=2 and Game.residents()>=20)
 hud.button(box,"ZUM GEBIET",func(): hud.focus_requested.emit(Vector3(248 if unlock_district==0 else -248,0,20)); hud.close_menu())
 hud.button(box,"REGIONEN & BAUPROJEKTE",func(): hud.open_menu("empire"))
func evolution_menu() -> void:
 hud.modal_title.text="ARCHITEKTUR · 1 BIS 10"
 var box=hud.card(TownEvolution.title(preview_kind,preview_level),TownEvolution.description(preview_kind,preview_level))
 var preview=load("res://UI/EvolutionPreview.gd").new()
 preview.kind=preview_kind
 preview.level=preview_level
 box.add_child(preview)
 var choices=hud.row(box)
 hud.button(choices,"← Vorherige",func(): preview_level=maxi(1,preview_level-1); hud.render_menu(),preview_level>1)
 hud.text(choices,"Stufe %s / 10" % preview_level,16,hud.INK).size_flags_horizontal=Control.SIZE_EXPAND_FILL
 hud.button(choices,"Nächste →",func(): preview_level=mini(10,preview_level+1); hud.render_menu(),preview_level<10)
 hud.text(box,"Vorschau: Dein Gebäude verändert sich erst nach dem tatsächlichen Abschluss seines Ausbauauftrags.",14,hud.MUTED)
 if selection.get("kind","")=="home":
  var index=int(selection.index)
  if index<Game.state.homes.size():
   var bill=UXRules.upgrade_bill(Game.state,true,index)
   if not bill.is_empty(): hud.button(box,"NÄCHSTEN AUSBAU STARTEN · %s" % Catalog.number(bill.coins),func(): hud.action(func(): Game.upgrade_home(index)))
func events_menu() -> void:
 hud.modal_title.text="STADT IM BLICK"
 if not hud.notice_history.is_empty():
  var recent=hud.card("Zuletzt im Spiel","Die letzten Meldungen dieser Sitzung bleiben hier nachlesbar.")
  for message in hud.notice_history: hud.text(recent,message,14,hud.INK)
 var hints=UXRules.current_hints(Game.state)
 if hints.is_empty(): hud.card("Alles im Blick","Aktuell kein gemeldeter Versorgungsengpass. Deine Wirtschaft läuft weiter.")
 for hint in hints:
  var item=hint.duplicate(true)
  var box=hud.card("! "+str(item.text))
  hud.button(box,"ANSEHEN & LÖSEN",func():
   if item.has("job"): select_job(int(item.job),true)
   elif item.has("position"): hud.focus_requested.emit(item.position); hud.open_menu(item.menu)
   else: hud.open_menu(item.menu))
 var active=hud.card("Stadtdienste unterwegs","Feuerwehr, Polizei, Rettung und Taxis führen ihre tatsächlichen laufenden Dienstfahrten aus.")
 hud.text(active,"%s aktive Fahrten · %s Münzen abholbereit" % [Game.state.city_services.missions.size(),Catalog.number(Game.state.city_services.treasury)],15,hud.MUTED)
 hud.button(active,"STADTEINSÄTZE & FAHRZEUGE",func(): hud.open_menu("services"))
 for event in Game.state.ux.events:
  var item=event.duplicate(true)
  var box=hud.card(("✓ " if event.read else "● ")+str(event.text))
  hud.button(box,"ZUM ORT",func():
   event.read=true
   if not str(item.menu).is_empty(): hud.open_menu(item.menu)
   else:
    hud.focus_requested.emit(Vector3(float(item.position[0]),0,float(item.position[1])))
    hud.close_menu()
   Game.save(true)
   refresh())
 hud.button(hud.contents,"ALLE ALS GELESEN MARKIEREN",func():
  for event in Game.state.ux.events: event.read=true
  Game.save(true)
  hud.render_menu()
  refresh())
 if not Game.state.ux.road_undo.is_empty(): hud.button(hud.contents,"LETZTE UNBENUTZTE STRASSE ZURÜCKNEHMEN",func(): hud.action(func(): Game.undo_road()))
func groups_menu() -> void:
 hud.modal_title.text="DEINE VIERTEL"
 var help=hud.card("Ein Viertel. Ein gemeinsamer Ausbauplan.","Markiere einen Bereich auf der Karte. Die Gebäude innerhalb seiner Grenzen gehören zum Viertel, auch wenn später neue Gebäude dazukommen.")
 hud.button(help,"BEREICH AUF DER KARTE MARKIEREN",func(): hud.request_placement({"kind":"group","network":true}))
 for group in Game.state.ux.groups:
  var id=int(group.id)
  var box=hud.card(str(group.name),"%s Gebäude" % UXRules.group_members(Game.state,group).size())
  var name_input=LineEdit.new()
  name_input.text=str(group.name)
  name_input.max_length=32
  name_input.set_meta("gesture_passthrough",true)
  name_input.custom_minimum_size.y=48
  box.add_child(name_input)
  hud.button(box,"NAMEN SPEICHERN",func(): Game.rename_group(id,name_input.text); hud.render_menu())
  var bill=UXRules.group_bill(Game.state,group)
  hud.text(box,"Ausbauplan: %s Gebäude · %s Münzen\nMaterial: %s" % [bill.targets.size(),Catalog.number(bill.coins),hud.materials_text(bill.materials)],15,hud.INK)
  var choices=hud.row(box)
  hud.button(choices,"VIERTEL ANSEHEN",func():
   var b=group.bounds
   hud.focus_requested.emit(Vector3(float(b[0])+float(b[2])/2,0,float(b[1])+float(b[3])/2))
   hud.close_menu()
   if world().get("selection_world")!=null: world().selection_world.choose({"kind":"group","id":id}))
  hud.button(choices,"AUSBAUPLAN BESTÄTIGEN",func(): hud.action(func(): Game.upgrade_group(id,float(bill.coins))),not bill.targets.is_empty())
  hud.text(box,"Bezahlt werden die gesamten angezeigten Baukosten. Material kommt danach per LKW; freie Bauarbeiter übernehmen automatisch den nächsten Viertelauftrag.",13,hud.MUTED)
  hud.button(box,"NUR MARKIERUNG ENTFERNEN",func(): Game.state.ux.groups.erase(group); Game.save(true); hud.render_menu())
func settings_controls(box: Node) -> void:
 hud.text(box,"Vibration ist optional und beim ersten Start ausgeschaltet. Schrift, Kontrast und reduzierte Effekte bleiben gespeichert.",14,hud.MUTED)
 hud.button(box,"Vibration: AN" if Game.state.ux.vibration else "Vibration: AUS",func(): hud.action(func(): Game.state.ux.vibration=not Game.state.ux.vibration))
 hud.button(box,"Große Schrift: AN" if Game.state.ux.large_text else "Große Schrift: AUS",func(): Game.state.ux.large_text=not Game.state.ux.large_text; Game.save(true); hud.render_menu(); apply_accessibility())
 hud.button(box,"Starker Kontrast: AN" if Game.state.ux.high_contrast else "Starker Kontrast: AUS",func(): Game.state.ux.high_contrast=not Game.state.ux.high_contrast; Game.save(true); hud.render_menu(); apply_accessibility())
 hud.button(box,"Bewegung & Lieferfeedback: AN" if Game.state.ux.motion else "Bewegung & Lieferfeedback: REDUZIERT",func(): hud.action(func(): Game.state.ux.motion=not Game.state.ux.motion))
func apply_accessibility() -> void:
 apply_fonts(hud)
 hud.call_deferred("layout_interface")
func apply_fonts(node: Node) -> void:
 if node is Label or node is Button:
  if not node.has_meta("ux_base_font"): node.set_meta("ux_base_font",node.get_theme_font_size("font_size"))
  var base=int(node.get_meta("ux_base_font"))
  node.add_theme_font_size_override("font_size",roundi(base*(1.15 if Game.state.ux.large_text else 1.0)))
 for child in node.get_children(): apply_fonts(child)

func on_map_choice(kind: String,index: int) -> void:
 match kind:
  "gateway": hud.open_menu("export")
  "building": select_building(index,false,true)
  "home": select_building(index,true,true)
  "job": select_job(int(Game.state.jobs[index].get("id",-1)),true)
  "plot":
   hud.focus_requested.emit(Game.plot_position(index))
   hud.show_plot(index)
  "biome":
   selected_biome=index
   hud.open_menu("biome_unlock")
  "district":
   unlock_district=index
   hud.open_menu("district_unlock")

func biome_menu() -> void:
 var index=selected_biome
 var biome=Catalog.BIOMES[index]
 hud.modal_title.text=str(biome.name).to_upper()
 var box=hud.card("Waldregion %s / 10" % (index+1),"%s · +%s %% aktiver Holzertrag" % [biome.wood,index*40])
 if index<int(Game.state.unlocked):
  hud.button(box,"REGION BESUCHEN",func():
   Game.state.biome=index
   Game.changed.emit()
   Game.save(true)
   hud.focus_requested.emit(Catalog.biome_position(index))
   hud.close_menu())
 else:
  hud.text(box,"Erschließung: %s Münzen
%s" % [Catalog.number(float(biome.cost)*Game.difficulty()),"Als nächste Region verfügbar" if index==int(Game.state.unlocked) else "Zuerst die vorherigen Waldregionen erschließen"],16,hud.INK)
  hud.button(box,"REGION ERSCHLIESSEN",func(): hud.action(func(): Game.unlock_biome()),index==int(Game.state.unlocked))
 hud.button(box,"ZUR STADTKARTE",func(): hud.open_menu("overview"))
