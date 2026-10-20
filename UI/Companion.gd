extends Control

var hud: Control
var portrait: SubViewport
var avatar: Button
var bubble: PanelContainer
var message: Label
var link: LinkButton
var target_menu=""
var remaining=0.0
var cooldown=0.0
var idle=0.0
var greeted=false
var enabled_before=true
var pending: Dictionary={}
var seen_hints={}
var previous: Dictionary={}
var fresh=false
var reported_offline=false
var last_resume=0

func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 fresh=int(Game.state.tutorial)==0
 previous=progress()
 portrait=load("res://UI/BeaverPortrait.gd").new()
 add_child(portrait)
 avatar=Button.new()
 avatar.tooltip_text="Benno, dein Waldfreund · antippen zum Plaudern"
 avatar.flat=true
 avatar.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 add_child(avatar)
 avatar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
 avatar.offset_left=8
 avatar.offset_right=92
 avatar.offset_top=-354
 avatar.offset_bottom=-234
 var view=TextureRect.new()
 view.texture=portrait.get_texture()
 view.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 view.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 view.mouse_filter=Control.MOUSE_FILTER_IGNORE
 avatar.add_child(view)
 view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 avatar.pressed.connect(chat)
 bubble=PanelContainer.new()
 add_child(bubble)
 bubble.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 bubble.offset_left=98
 bubble.offset_right=-72
 bubble.offset_top=-378
 bubble.offset_bottom=-240
 bubble.add_theme_stylebox_override("panel",hud.style(hud.PAPER,18))
 var column=VBoxContainer.new()
 column.set_meta("light_card",true)
 bubble.add_child(column)
 var heading=HBoxContainer.new()
 heading.set_meta("light_card",true)
 column.add_child(heading)
 var name_label=hud.text(heading,"BENNO · DEIN WALDFREUND",12,hud.INK)
 name_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 var close_button=Button.new()
 close_button.text="×"
 close_button.tooltip_text="Sprechblase schließen"
 close_button.custom_minimum_size=Vector2(28,28)
 for key in ["normal","hover","pressed"]:
  var skin=hud.style(hud.PANEL,9,key=="pressed")
  skin.content_margin_top=2
  skin.content_margin_bottom=2
  skin.content_margin_left=5
  skin.content_margin_right=5
  close_button.add_theme_stylebox_override(key,skin)
 heading.add_child(close_button)
 close_button.pressed.connect(dismiss)
 message=hud.text(column,"",15,hud.INK)
 link=LinkButton.new()
 link.add_theme_color_override("font_color",Color("147b89"))
 link.add_theme_font_size_override("font_size",13)
 link.text="Zeig’s mir →"
 link.pressed.connect(func():
  if not target_menu.is_empty(): hud.open_menu(target_menu)
  dismiss())
 column.add_child(link)
 bubble.hide()
 Game.changed.connect(observe)
 Game.loot_found.connect(on_loot)

func progress() -> Dictionary:
 var levels=0
 for home in Game.state.homes: levels+=int(home.level)
 for building in Game.state.buildings: levels+=int(building.level)
 return {"buildings":Game.state.buildings.size(),"homes":Game.state.homes.size(),"levels":levels,"unlocked":int(Game.state.unlocked),"prestige":int(Game.state.prestige),"trees":int(Game.state.trees)}

func observe() -> void:
 var now=progress()
 var tree_target=25*(int(Game.state.prestige)+1)
 if not previous.is_empty():
  if now.prestige>previous.prestige: queue_message("Ein neues Kapitel! Ich bin wieder an deiner Seite. Lass uns etwas Schönes aufbauen.",true)
  elif now.homes>previous.homes: queue_message(TownEvolution.title(str(Game.state.homes.back().kind),int(Game.state.homes.back().level))+" ist fertig! Unser Wald wächst zu einer Stadt.",true,"city")
  elif now.buildings>previous.buildings: queue_message(str(Catalog.BUILDINGS[Game.state.buildings.back().kind].name)+" ist fertig! Das Team hat ganze Arbeit geleistet.",true,"industry")
  elif now.levels>previous.levels: queue_message("Ausbau geschafft! Ich mag es, wenn aus kleinen Anfängen etwas Großes wächst.",true)
  elif now.unlocked>previous.unlocked: queue_message("Eine neue Waldregion! Ich bin gespannt, was wir dort entdecken.",true)
  elif previous.trees<tree_target and now.trees>=tree_target: queue_message("%s Bäume – stark gemacht! Schau bei den Missionen nach deiner Belohnung." % tree_target,true,"missions")
 previous=now

func queue_message(words: String, celebrate: bool=false, menu: String="") -> void:
 if not Game.state.get("companion_enabled",true): return
 # A single latest event prevents a queue of interruptions after offline progress.
 pending={"text":words,"celebrate":celebrate,"menu":menu}
 cooldown=minf(cooldown,18)

func speak(words: String, celebrate: bool=false, menu: String="") -> void:
 message.text=words
 target_menu=menu
 link.visible=not menu.is_empty()
 remaining=9.0
 cooldown=40.0
 idle=0
 bubble.show()
 portrait.greet(celebrate)

func dismiss() -> void:
 remaining=0
 cooldown=maxf(cooldown,40)
 bubble.hide()

func greeting() -> String:
 if fresh: return "Hallo, ich bin Benno! Schön, dass du da bist. Wir machen es uns hier richtig gemütlich."
 if not reported_offline and not Game.offline_report.is_empty():
  reported_offline=true
  return "Da bist du ja! Ich habe nach dem Team geschaut. "+Game.offline_report+". Schön, dass du wieder da bist!"
 var greetings=["Schön, dass du wieder da bist! Helm auf, tief durchatmen – heute bauen wir an deinem Waldimperium weiter.","Da bist du ja! Schön, dich zu sehen. Mach es dir gemütlich – unser kleines Stück Wald wartet auf deine Ideen.","Willkommen zurück! Ich habe schon mal meinen Helm geputzt. Was bauen wir heute Schönes?"]
 return greetings[int(float(Game.state.elapsed)/60.0)%greetings.size()]

func hint() -> Dictionary:
 if float(Game.state.resources.sawdust)>Game.capacity()*0.65: return {"id":"bin","text":"Unsere Spänebox ist gut gefüllt. Du kannst die Späne verkaufen oder für Papier und Pellets aufheben.","menu":"sawdust"}
 if float(Game.state.bag)>=Game.bag_capacity(): return {"id":"bag","text":"Dein Rucksack ist voll. Bei Abliefern wird daraus Nachschub für unsere Säge.","menu":""}
 var hints=UXRules.current_hints(Game.state)
 if not hints.is_empty():
  var next=hints[0]
  return {"id":next.id,"text":next.text+". Ich zeige dir, was gebraucht wird.","menu":"events"}
 if Game.level("kiln")==0 and float(Game.state.resources.boards)>5: return {"id":"kiln","text":"Aus Brettern wird in der Trockenkammer Trockenholz. Damit können wir später Möbel fertigen.","menu":"catalog"}
 if not Game.state.homes.is_empty(): return {"id":"city","text":"Ich mag unsere kleine Stadt. Jedes neue Zuhause macht aus dem Betrieb ein Stück Heimat.","menu":"city"}
 return {"id":"forest","text":"Ein guter Moment, einfach mal zuzuschauen. Unser Wald sieht heute besonders schön aus.","menu":""}

func chat() -> void:
 var advice=hint()
 speak(advice.text,false,advice.menu)

func _notification(what: int) -> void:
 if what==NOTIFICATION_APPLICATION_RESUMED:
  var now=Time.get_ticks_msec()
  if now-last_resume>300000:
   greeted=false
   last_resume=now

func _process(delta: float) -> void:
 var enabled=bool(Game.state.get("companion_enabled",true))
 if not enabled:
  remaining=0
  pending={}
 elif not enabled_before: greeted=false
 enabled_before=enabled
 var available=enabled and not hud.overlay.visible and not hud.placement_panel.visible and (hud.get("ux")==null or not hud.ux.panels_visible())
 avatar.visible=available
 portrait.running=available
 if not available:
  bubble.hide()
  portrait.render_target_update_mode=SubViewport.UPDATE_DISABLED
  return
 cooldown=maxf(0,cooldown-delta)
 idle+=delta
 if not greeted:
  greeted=true
  last_resume=Time.get_ticks_msec()
  speak(greeting())
 elif remaining>0:
  remaining=maxf(0,remaining-delta)
  bubble.visible=remaining>0
 elif not pending.is_empty() and cooldown<=0:
  var next=pending
  pending={}
  speak(next.text,next.celebrate,next.menu)
 elif idle>=100 and cooldown<=0:
  var advice=hint()
  if not seen_hints.has(advice.id):
   seen_hints[advice.id]=true
   speak(advice.text,false,advice.menu)
  idle=0

func on_loot(rarity: int) -> void:
 if rarity>=2: queue_message("%s-Loot! So ein Fund macht den Tag doch gleich noch schöner." % Catalog.RARITIES[rarity],true,"loot")
