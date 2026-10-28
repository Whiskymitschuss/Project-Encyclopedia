extends RefCounted

static func populate(hud: Control) -> void:
 hud.modal_title.text="MENÜ"
 var quick=hud.row(hud.contents)
 hud.button(quick,"Logistik",func(): hud.open_menu("logistics"))
 hud.button(quick,"Bauen",func(): hud.open_menu("catalog"))
 hud.button(quick,"Bestände",func(): hud.open_menu("stock"))
 var search=LineEdit.new()
 search.placeholder_text="Menüpunkt suchen …"
 search.custom_minimum_size.y=48
 search.add_theme_color_override("font_color",hud.INK)
 search.add_theme_color_override("font_placeholder_color",Color("6c7472"))
 search.add_theme_stylebox_override("normal",hud.style(hud.PAPER,12))
 hud.contents.add_child(search)
 var tabs=GridContainer.new()
 tabs.columns=2
 tabs.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 hud.contents.add_child(tabs)
 var groups=[
  ["Firma",[["Logistik & Baustellen","logistics"],["Betriebsübersicht · Engpässe & LKW","operations"],["Betriebe verwalten","industry"],["Lieferaufträge","contracts"],["Lieferkette & Ladenaufträge","delivery"],["Steinbruch & Baustoffe","stone"],["Baustellen & Materialdepot","construction"],["Materialplaner","planner"],["Lager & Verkaufsstelle","market"],["Autobahn & Exporthandel","export"],["Spänebox","sawdust"],["Personal & Werkzeug","team"],["Garage & Fahrzeuge","garage"]]],
  ["Stadt",[["Stadtkarte & freie Grundstücke","overview"],["Stadt & Häuser","city"],["Viertel & Ausbaupläne","districts"],["Straßen & Wege","networks"],["Buslinien & Haltestellen","transit"],["Einsatzzentrale & Feuerwehr","services"],["Hinweise & Ereignisse","events"]]],
  ["Ausbau",[["Kapitel 1–10 & Rathaus","journey"],["Auszeichnungen","trophies"],["Regionen & Großprojekte","empire"],["Forschung","research"],["Loot & Inventar","loot"],["Booster","boosters"],["Neue Unternehmensära / Prestige","prestige"]]],
  ["Hilfe",[["Hilfe · Produktion & Transporte","guide_help"],["Speichern & Datenschutz","privacy"],["BENNOS WERKSHOF-RUNDE","welcome"],["Alpha 1 · Testen & Feedback","alpha"],["Startzeit, FPS & Kamerarunde","performance"],["Holzkette · Wald bis Lager","timberline"],["Holzwerkshof & Planung","timber_campus"],["Fotomodus & Galerie","photo"],["Erste Schritte mit Benno","guide"],["Einstellungen & Sicherung","settings"]]]
 ]
 var sections=[]
 for group in groups:
  var section=hud.card(str(group[0]))
  var buttons=[]
  for entry in group[1]:
   var key=str(entry[1])
   var button=hud.button(section,str(entry[0])+"  ›",func():
    if key=="welcome": hud.story_step=0; hud.focus_requested.emit(Catalog.biome_position(int(Game.state.biome)))
    hud.open_menu(key))
   buttons.append(button)
  sections.append({"name":str(group[0]),"card":section,"buttons":buttons})
 var filter=func(value: String):
  var query=value.strip_edges().to_lower()
  for section in sections:
   var shown=false
   for button in section.buttons:
    button.visible=query.is_empty() or button.text.to_lower().contains(query) or str(section.name).to_lower().contains(query)
    shown=shown or button.visible
   section.card.get_parent().visible=shown and (not query.is_empty() or str(section.name)==hud.more_category)
 for group in groups:
  var key=str(group[0])
  var button=hud.button(tabs,key,func(): hud.more_category=key; search.text=""; filter.call(""); hud.scroll.set_deferred("scroll_vertical",0))
  button.add_theme_font_size_override("font_size",14)
 search.text_changed.connect(filter)
 filter.call("")
