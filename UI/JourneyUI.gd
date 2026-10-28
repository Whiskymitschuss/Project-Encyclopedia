extends RefCounted
var hud
var trophy_page=0

func meter(parent: Node,callback: Callable,target: float) -> void:
 var bar=ProgressBar.new()
 bar.custom_minimum_size=Vector2(0,10)
 bar.max_value=maxf(1,target)
 bar.value=callback.call()
 bar.show_percentage=false
 bar.mouse_filter=Control.MOUSE_FILTER_IGNORE
 bar.add_theme_stylebox_override("background",hud.style(Color("c6d8c1"),7))
 bar.add_theme_stylebox_override("fill",hud.style(Color("e4aa3c"),7))
 parent.add_child(bar)
 hud.live_labels.append({"label":bar,"update":func(): bar.value=callback.call()})

func meter_style(color: Color) -> StyleBoxFlat:
 var skin=StyleBoxFlat.new()
 skin.bg_color=color
 skin.set_corner_radius_all(5)
 return skin

func progress(goal: Dictionary) -> float:
 if Game.state.journey.reached.has(goal.id): return float(goal.target)
 if int(goal.index)<0: return Journey.townhall_level(Game.state)
 return minf(goal.target,Journey.value(Game.state,Journey.CHAPTERS[int(goal.chapter)].goals[int(goal.index)][0]))

func populate(tab: String) -> void:
 match tab:
  "journey": journey_menu()
  "commissions": commission_menu()
  "trophies": trophy_menu()
  "return": return_menu()
  "townhall": townhall_menu()

func go(action: String) -> void:
 if action=="forest":
  hud.close_menu()
  hud.focus_requested.emit(Catalog.biome_position(int(Game.state.biome)))
  return
 if action=="deposit":
  if float(Game.state.bag)<=0:
   go("forest")
   hud.show_notice("Fälle zuerst etwas Holz für deinen Rucksack")
   return
  if float(Game.state.resources.wood)>=Game.capacity():
   hud.open_menu("market")
   hud.show_notice("Das Holzlager ist voll · erst Holz verkaufen oder verarbeiten")
   return
  Game.deposit()
  Game.queue_save()
  hud.close_menu()
  hud.camera_action.emit("home")
  return
 if action in ["sawmill","kiln","furniture","prefab","quarry","stoneworks"]:
  for i in Game.state.buildings.size():
   if Game.state.buildings[i].kind==action:
    hud.ux.select_building(i,false,true)
    return
  hud.build_category="Produktion"
  hud.open_menu("catalog")
  hud.show_notice("Wähle %s und bestätige einen freien Bauplatz" % Catalog.BUILDINGS[action].name)
  return
 hud.open_menu(action)

func journey_menu() -> void:
 hud.modal_title.text="DEINE GESCHICHTE"
 var next=Journey.current(Game.state)
 var links=hud.row(hud.contents)
 hud.button(links,"Kurzaufträge",func(): hud.open_menu("commissions"))
 hud.button(links,"Auszeichnungen",func(): hud.open_menu("trophies"))
 if not Game.return_report.is_empty(): hud.button(hud.contents,"WILLKOMMEN ZURÜCK · DEINE BILANZ",func(): hud.open_menu("return"))
 if next.is_empty():
  hud.card("Dein Imperium hat Geschichte","Alle zehn Kapitel geschafft! Deine Stadt, neue Unternehmensären und freiwillige Kurzaufträge bleiben offen. Deine Auszeichnungen gehören dir dauerhaft.")
 else:
  var c=int(next.chapter)
  var box=hud.card("KAPITEL %s/10 · %s" % [c+1,next.chapter_name],"Dein nächstes Ziel: "+next.name)
  meter(box,func(): return progress(next),float(next.target))
  hud.dynamic_text(box,func(): return "%s / %s · %s Münzen" % [Catalog.number(progress(next)),Catalog.number(next.target),next.coins])
  var reward=hud.button(box,"BELOHNUNG ABHOLEN",func(): hud.action(func(): Game.claim_journey(next.id)),bool(next.ready))
  # Allow readiness to change while this menu is open without rebuilding the
  # button under a finger, preserving touch and scroll gestures.
  hud.live_labels.append({"label":reward,"callback":func():
   reward.disabled=not Game.state.journey.reached.has(next.id)
   return "BELOHNUNG ABHOLEN"})
  hud.button(box,"ZEIG MIR DEN NÄCHSTEN SCHRITT",func(): go(next.action))
  if str(next.id) in ["workshop:2","skyline:2","empire:2"]:
   hud.text(box,"Es zählen verkaufte Möbel: im Ladenauftrag, im Fernhandel oder über den lokalen Verkauf. Lagerbestand allein zählt nicht. Prüfe bei Stillstand Bretter-Nachschub, Abholungen und den Fuhrpark.",14,hud.MUTED)
   hud.button(box,"MÖBELKETTE & LKW PRÜFEN",func(): hud.open_menu("logistics"))
  elif str(next.id)=="stone:2":
   hud.text(box,"Es zählen eigene Bausteine und Kies nach dem Entladen aus dem Steinwerk: im Zentrallager oder Abhol-Express. Gestein, Käufe und Umlagerungen zählen nicht. Neue Steinwerke wählen Bausteine und Kies nach Bedarf; ältere Werke kannst du auf Automatik stellen.",14,hud.MUTED)
  elif int(next.index)<0 and not next.ready:
   hud.text(box,"Ein bezahlter Ausbau zählt erst nach Materiallieferung und Fertigstellung. Öffne bei Wartezeiten die Baustellenübersicht; Lagerbestand und laufende LKW sind getrennte Vorräte.",14,hud.MUTED)
   hud.button(box,"BAUSTELLE & MATERIAL PRÜFEN",func(): hud.logistics_tab="sites";hud.open_menu("logistics"))
  hud.text(box,"Kapitelabschluss: 3 Diamanten, 1 Loot-Ticket und die bleibende Auszeichnung „%s“." % Journey.CHAPTERS[c].title,14,hud.MUTED)
 hud.button(hud.contents,"DEIN RATHAUS · STUFE %s/10" % Journey.townhall_level(Game.state),func(): hud.open_menu("townhall"))
 for c in Journey.CHAPTERS.size():
  var chapter=Journey.CHAPTERS[c]
  var finished=str(chapter.id) in Game.state.journey.trophies
  var box=hud.card("%s %s · %s" % ["✓" if finished else "›",c+1,chapter.name],"Auszeichnung: "+chapter.title)
  for i in chapter.goals.size():
   var id=Journey.goal_id(c,i)
   var goal=chapter.goals[i]
   var status="✓" if Game.state.journey.claimed.has(id) else "BEREIT" if Game.state.journey.reached.has(id) else "○"
   hud.text(box,"%s  %s" % [status,goal[2]],14,hud.MUTED)
  hud.text(box,"%s  Rathaus auf Stufe %s fertigstellen" % ["✓" if Game.state.journey.claimed.has(Journey.hall_id(c)) else "○",c+1],14,hud.MUTED)
 hud.button(hud.contents,"WEITERE MEILENSTEINE",func(): hud.open_menu("missions"))
 hud.text(hud.contents,"Keine tägliche Pflicht. Bereits erreichte Kapitelziele, Auszeichnungen und Titel bleiben beim Prestige erhalten.",14,hud.MUTED)

func commission_menu() -> void:
 hud.modal_title.text="WAS HAST DU HEUTE VOR?"
 hud.card("Dein Tempo, dein Auftrag","Wähle ein Vorhaben passend zu deinem Betrieb. Neue echte Produktion und abgeschlossene Lieferungen zählen ab Annahme. Der Auftrag läuft offline weiter und verfällt nicht.")
 var order=Game.state.journey.active
 if not order.is_empty():
  var box=hud.card(order.name,order.text)
  meter(box,func(): return Journey.order_progress(Game.state),float(order.target))
  hud.dynamic_text(box,func(): return "%s / %s · %s Münzen" % [Catalog.number(Journey.order_progress(Game.state)),order.target,order.reward])
  var reward=hud.button(box,"AUFTRAG ABSCHLIESSEN",func(): hud.action(func(): Game.claim_commission()),Journey.order_progress(Game.state)>=float(order.target))
  hud.live_labels.append({"label":reward,"callback":func():
   reward.disabled=Journey.order_progress(Game.state)<float(order.target)
   return "AUFTRAG ABSCHLIESSEN"})
  hud.button(box,"ZUM BETRIEB",func(): go(order.action))
  hud.button(box,"OHNE KOSTEN ZURÜCKLEGEN",func(): hud.action(func(): Game.cancel_commission()))
 else:
  for key_value in Journey.choices(Game.state):
   var key=str(key_value)
   var offer=Journey.COMMISSIONS[key]
   var box=hud.card(offer.name,offer.text)
   hud.text(box,"Belohnung: %s Münzen" % offer.reward,16,hud.GOLD)
   hud.button(box,"DIESEN AUFTRAG WÄHLEN",func(): hud.action(func(): Game.accept_commission(key)))
 var completed=int(Game.state.journey.completed_orders)
 hud.text(hud.contents,"%s Aufträge geschafft · noch %s bis zum nächsten zusätzlichen Loot-Ticket. Kein Zeitlimit, keine Echtgeldkosten." % [completed,3-completed%3],14,hud.MUTED)
 hud.button(hud.contents,"ZUR KAPITELREISE",func(): hud.open_menu("journey"))

func trophy_menu() -> void:
 hud.modal_title.text="DEINE AUSZEICHNUNGEN"
 trophy_page=clampi(trophy_page,0,Journey.CHAPTERS.size()-1)
 var chapter=Journey.CHAPTERS[trophy_page]
 var owned=str(chapter.id) in Game.state.journey.trophies
 var box=hud.card(chapter.title,"VERDIENT · bleibt über Prestige hinaus" if owned else "VORSCHAU · Abschluss von Kapitel %s: %s" % [trophy_page+1,chapter.name])
 var preview=load("res://UI/TrophyPreview.gd").new()
 preview.chapter=trophy_page
 preview.owned=owned
 box.add_child(preview)
 var browse=hud.row(box)
 var previous=hud.button(browse,"‹",func(): trophy_page-=1; hud.render_menu(),trophy_page>0)
 var pager=hud.text(browse,"%s / 10" % (trophy_page+1),17,hud.INK)
 pager.autowrap_mode=TextServer.AUTOWRAP_OFF
 pager.custom_minimum_size.x=80
 pager.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 pager.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 var following=hud.button(browse,"›",func(): trophy_page+=1; hud.render_menu(),trophy_page<9)
 for arrow in [previous,following]:
  arrow.custom_minimum_size=Vector2(56,48)
  arrow.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
 hud.button(box,"ALS TITEL ANZEIGEN" if Game.state.journey.selected!=chapter.id else "DEIN AKTIVER TITEL",func(): hud.action(func(): Game.select_trophy(chapter.id)),owned and Game.state.journey.selected!=chapter.id)
 hud.button(hud.contents,"TITEL AUSBLENDEN",func(): hud.action(func(): Game.select_trophy("")),not str(Game.state.journey.selected).is_empty())
 hud.button(hud.contents,"KAPITEL & VORAUSSETZUNGEN",func(): hud.open_menu("journey"))

func return_menu() -> void:
 hud.modal_title.text="SCHÖN, DASS DU WIEDER DA BIST"
 var report=Game.return_report
 if report.is_empty():
  hud.card("Dein Team ist bereit","Beim nächsten längeren Besuch zeigt dir Benno hier die tatsächliche Entwicklung deines Betriebs. Die Wirtschaft arbeitet bis zu acht Stunden offline weiter.")
 else:
  var box=hud.card("Dein Betrieb hat weitergearbeitet","%s Minuten berücksichtigt · tatsächliche Entwicklung" % int(float(report.seconds)/60))
  hud.text(box,"Münzbilanz: %s Münzen\n%s Bretter und %s Möbel produziert\n%s Materiallieferungen angekommen\n%s Gebäude / Ausbauten fertig\n%s neue Münzen in den Hauskonten" % [Catalog.number(report.coins),Catalog.number(report.boards),Catalog.number(report.furniture),int(report.shipments),int(report.completed),Catalog.number(report.rent)],17,hud.INK)
  hud.text(box,"Münzen und Waren sind bereits im Spiel verbucht. Miete liegt im jeweiligen Hauskonto, sofern du keinen Hausverwalter nutzt.",14,hud.MUTED)
  hud.text(box,"%s Einheiten tatsächlich verkauft" % Catalog.number(float(report.get("sold",0))),15,hud.INK)
  var links=hud.row(box)
  hud.button(links,"ZUM SÄGEWERK",func(): go("sawmill"))
  hud.button(links,"LIEFERUNGEN",func(): hud.open_menu("operations"))
  for destination in report.get("destinations",[]):
   var place=destination
   hud.button(box,str(place.name)+" · FERTIG ANSEHEN",func(): hud.ux.select_building(int(place.index),bool(place.city),true))
 if Game.rent_total()>0: hud.button(hud.contents,"MIETE ABHOLEN · %s" % Catalog.number(Game.rent_total()),func(): hud.action(func(): Game.collect_rent()))
 var next=Journey.current(Game.state)
 if not next.is_empty():
  var box=hud.card("Dein nächster schöner Schritt",next.name)
  hud.button(box,"ZUR KAPITELREISE",func(): hud.open_menu("journey"))
 if not Game.state.journey.active.is_empty(): hud.button(hud.contents,"DEIN ANGEFANGENER KURZAUFTRAG",func(): hud.open_menu("commissions"))
 hud.button(hud.contents,"WEITERSPIELEN",func(): Game.return_report={}; hud.close_menu(); hud.ux.refresh())

func townhall_menu() -> void:
 hud.modal_title.text="DEIN RATHAUS"
 var current=Journey.townhall_level(Game.state)
 var target=mini(10,current+1)
 var box=hud.card(TownEvolution.title("townhall",maxi(1,current)),"Stufe %s/10 · Jedes abgeschlossene Kapitel eröffnet die nächste Ausbaustufe. Der Ausbau wird erst nach echten Materiallieferungen und Bauarbeit fertig." % current)
 hud.text(box,"Stadtverwaltung: +%s %% Grundmiete für alle Häuser. Gemeinsam mit Parks und Kliniken maximal +100 %%." % (current*2),15,hud.MUTED)
 var preview=load("res://UI/EvolutionPreview.gd").new()
 preview.kind="townhall"
 preview.level=target
 box.add_child(preview)
 hud.text(box,"Vorschau: "+TownEvolution.title("townhall",target),16,hud.GOLD)
 var index=Journey.townhall_index(Game.state)
 var pending=false
 for job in Game.state.jobs:
  if job.kind=="townhall": pending=true
 if pending:
  hud.button(box,"BAUSTELLE & NÄCHSTE LIEFERUNG",func(): hud.open_menu("construction"))
 elif current<10:
  var unlocked=Journey.hall_unlocked(Game.state,target)
  var materials=Journey.hall_materials(target)
  hud.text(box,"Nächster Ausbau: %s Münzen\n%s" % [Catalog.number(Journey.hall_cost(target)*Game.difficulty()),hud.materials_text(materials)],15,hud.GOLD)
  hud.text(box,"Aufgaben für Kapitel %s zuerst abschließen und abholen." % target if not unlocked else "Aufgaben erfüllt! Baustoffe kommen nach Beauftragung per LKW.",15,hud.MUTED)
  if current==0: hud.text(box,"Eigenes Verwaltungsgrundstück: Das Rathaus verbraucht keinen deiner Wohnbauplätze. Wähle einen freien Standort im erschlossenen Gebiet.",15,hud.MUTED)
  hud.button(box,"RATHAUS PLATZIEREN" if current==0 else "AUSBAU AUF STUFE %s STARTEN" % target,func():
   if current==0: hud.request_placement({"kind":"townhall","city":true,"index":-1,"plot":-1})
   else: hud.action(func(): Game.upgrade_home(index)),unlocked and Game.state.coins>=Journey.hall_cost(target)*Game.difficulty())
  for key_value in materials:
   var key=str(key_value)
   hud.button(box,Catalog.RESOURCES[key]+" · VERSORGUNG ANSEHEN",func(): hud.ux.open_material(key))
 if index>=0: hud.button(hud.contents,"ZUM RATHAUS IN DER STADT",func(): hud.ux.select_building(index,true,true))
 hud.button(hud.contents,"KAPITELAUFGABEN ANSEHEN",func(): hud.open_menu("journey"))
