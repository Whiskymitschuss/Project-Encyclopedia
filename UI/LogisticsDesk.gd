extends RefCounted

static func focus_building(hud: Control,index: int) -> void:
 hud.close_menu()
 hud.ux.select_building(index,false,true)

static func overview(game: Node) -> String:
 var state=game.state
 var pickup=0
 var supply=0
 var regional=0
 for trip in state.hub.shipments:
  if trip.arrived: continue
  if trip.target=="factory": supply+=1
  elif trip.target=="central" or (trip.target=="express" and state.buildings[int(trip.origin)].kind not in ["central_depot","express"]): pickup+=1
  else: regional+=1
 return "%s Abholungen · %s Werkslieferungen · %s Regionaltransporte\nLager-LKW: %s/%s frei · Baustellenlieferungen: %s\nBauteam: %s Mitarbeiter · %s/%s Sprinter unterwegs" % [pickup,supply,regional,CentralLogistics.available_trucks(state),CentralLogistics.fleet_size(state),state.construction_shipments.size(),int(state.builders),state.crew.missions.size(),CrewTransport.fleet_size(state)]

static func populate(hud: Control) -> void:
 hud.modal_title.text="LOGISTIK"
 var state=Game.state
 var summary=hud.card("Dein Warenfluss","Automatisch: Fabrik → Lager → Baustelle. Das Bauteam reist separat im Sprinter an.")
 hud.dynamic_text(summary,func(): return overview(Game))
 hud.dynamic_text(summary,func(): return "Zentrale: maximal %s je Warenart. Volle Fächer stoppen neue Abholungen; Verbrauch schafft automatisch wieder Platz." % Catalog.number(CentralLogistics.capacity(Game.state)))
 if not CentralLogistics.active(state):
  hud.text(summary,"Baue ein Zentrallager für die automatische Versorgung aller Werke und die regionalen Abholungen.",15,hud.GOLD)
  hud.button(summary,"ZENTRALLAGER BAUEN",func(): hud.request_placement({"kind":"central_depot","city":false,"index":-1}))
 if LogisticsDispatch.enabled(state): load("res://UI/TransportDesk.gd").fleet_controls(hud,summary)
 var tabs=GridContainer.new()
 tabs.columns=2
 tabs.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 hud.contents.add_child(tabs)
 for entry in [["Übersicht","overview"],["Betriebe","factories"],["Baustellen","sites"],["Fahrten","trips"]]:
  var key=str(entry[1])
  var button=hud.button(tabs,str(entry[0]),func(): hud.logistics_tab=key; hud.render_menu())
  button.add_theme_font_size_override("font_size",13)
  button.custom_minimum_size.x=0
  if hud.logistics_tab==key: button.add_theme_stylebox_override("normal",hud.style(hud.GOLD,12)); button.add_theme_color_override("font_color",hud.INK)
 var links=hud.row(hud.contents)
 hud.button(links,"Bestände",func(): hud.open_menu("stock"))
 hud.button(links,"Bauteam",func(): hud.open_menu("team"))
 hud.button(links,"Fuhrpark",func(): hud.open_menu("garage"))
 match str(hud.logistics_tab):
  "factories": factories(hud)
  "sites": sites(hud)
  "trips": trips(hud)
  _:
   var count=0
   for i in state.buildings.size():
    var advice=ProductionPresentation.advice(Game,i)
    if advice.kind not in ["full","missing"]: continue
    var index=i
    var box=hud.card(UXRules.factory_name(state,i))
    hud.dynamic_text(box,func(): return Game.production_status(index)+"\n"+LogisticsDispatch.collection_status(Game.state,index))
    hud.button(box,"BETRIEB ÖFFNEN",func(): focus_building(hud,index))
    count+=1
    if count>=4: break
   if count==0: hud.card("Kein Produktionsengpass gemeldet","Die Transporte werden automatisch nach Materialbedarf, Wartezeit und freiem Lagerplatz vergeben.")
   hud.button(hud.contents,"ALLE BETRIEBE & ABHOLUNGEN",func(): hud.logistics_tab="factories"; hud.render_menu())
   hud.button(hud.contents,"HOLZKETTE · WALD BIS BRETTERLAGER",func(): hud.open_menu("timberline"))
   sites(hud,3)

static func factories(hud: Control) -> void:
 for i in Game.state.buildings.size():
  var index=i
  if LogisticsDispatch.outputs(Game.state,i).is_empty() and FactorySupply.requirements(Game.state,i).is_empty(): continue
  var box=hud.card(UXRules.factory_name(Game.state,i))
  hud.dynamic_text(box,func(): return Game.production_status(index))
  if not FactorySupply.requirements(Game.state,i).is_empty():
   hud.text(box,"Wareneingang · automatisch",14,hud.GOLD)
   hud.dynamic_text(box,func(): return FactorySupply.status(Game.state,index))
  if not LogisticsDispatch.outputs(Game.state,i).is_empty():
   hud.text(box,"Fertigwaren · automatische Abholung",14,hud.GOLD)
   hud.dynamic_text(box,func(): return LogisticsDispatch.collection_status(Game.state,index))
  var actions=hud.row(box)
  hud.button(actions,"Betrieb ansehen",func(): focus_building(hud,index))
  if not FactorySupply.requirements(Game.state,i).is_empty(): hud.button(actions,"Nachschub prüfen",func(): hud.action(func(): Game.request_material(index)))

static func sites(hud: Control,limit: int=1000) -> void:
 if Game.state.jobs.is_empty():
  hud.card("Keine offenen Baustellen","Ein bezahlter Bauauftrag fordert Material und ein freies Bauteam automatisch an.")
  return
 var count=0
 for job in Game.state.jobs:
  var record=job
  var title=str(Catalog.HOMES.get(str(job.kind),Catalog.BUILDINGS.get(str(job.kind),{"name":"Bauprojekt"})).name)
  var box=hud.card(title)
  hud.dynamic_text(box,func(): return ConstructionRules.status(record)+"\n"+CrewTransport.status(Game.state,record)+"\n"+ConstructionRules.logistics_status(Game.state,record))
  var hardware=Game.job_hardware_cost(int(record.id))
  if hardware>0: hud.button(box,"KLEINTEILE BESORGEN · %s MÜNZEN" % Catalog.number(hardware),func(): hud.action(func(): Game.buy_job_hardware(int(record.id))))
  hud.button(box,"BAUSTELLE & MATERIAL",func(): hud.open_menu("construction",-2,int(record.id)))
  count+=1
  if count>=limit: break
 if Game.state.jobs.size()>count: hud.button(hud.contents,"ALLE BAUSTELLEN",func(): hud.logistics_tab="sites"; hud.render_menu())

static func trips(hud: Control) -> void:
 for trip in FreightFlow.all_trips(Game.state):
  var shipment=trip
  var source=UXRules.factory_name(Game.state,int(trip.origin)) if int(trip.get("origin",-1))>=0 else ConstructionRules.source_name(trip)
  var target="Baustelle" if trip.target=="construction" else "Autobahn" if trip.target=="export" else "Lager" if trip.target=="mineral" and int(trip.destination)<0 else UXRules.factory_name(Game.state,int(trip.destination)) if trip.has("destination") else Catalog.BUILDINGS.get(str(trip.target),{"name":"Werk"}).name
  var box=hud.card("%s %s" % [Catalog.number(trip.amount),Catalog.RESOURCES[trip.key]],source+" → "+str(target))
  hud.dynamic_text(box,func(): return FreightFlow.status(shipment))
  var domain="central" if trip.target in ["central","express","factory"] else "construction" if trip.target=="construction" else "stone" if trip.target=="mineral" else "export" if trip.target=="export" else "wood"
  hud.button(box,"FAHRZEUG & ROUTE",func(): hud.close_menu(); hud.ux.select_truck({"kind":"truck","id":int(shipment.id),"domain":domain},true))
 for trip in Game.state.crew.missions:
  var mission=trip
  var box=hud.card("Sprinter · %s Mitarbeiter" % int(trip.workers))
  hud.dynamic_text(box,func(): return ("Rückfahrt zur Arbeiterhütte" if mission.arrived else "Mitarbeiter zur Baustelle" if mission.kind=="dropoff" else "Bauteam abholen")+" · "+FreightFlow.status(mission))
  hud.button(box,"SPRINTER ANSEHEN",func():
   hud.ux.select_truck({"kind":"truck","id":int(mission.id),"domain":"crew"},true))
 if FreightFlow.all_trips(Game.state).is_empty() and Game.state.crew.missions.is_empty(): hud.card("Alle Fahrzeuge verfügbar","Neue Fahrten starten, sobald Ware und Bedarf vorhanden sind und eine Straßenverbindung besteht.")
