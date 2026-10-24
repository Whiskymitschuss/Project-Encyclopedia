extends RefCounted

static func focus(hud: Control,index: int) -> void:
 hud.close_menu()
 hud.ux.select_building(index,false,true)

static func populate(hud: Control) -> void:
 hud.modal_title.text="DEINE HOLZKETTE"
 hud.card("Vom Wald bis zum Brett","Mit Zentrallager: Wald → Rohstofflager → Sägewerk → Bretterlager. Die LKW bedienen die tatsächlich erreichbaren Lager und Werke. Türkise Hofmarkierungen zeigen Eingänge, goldene Markierungen Ausgänge.")
 hud.button(hud.contents,"WERKSHOF PLANEN & AUSBAUEN",func(): hud.open_menu("timber_campus"))
 hud.card("Die Maschine verstehen","Grün: Material vorhanden · Gold: Ausgang voll · Rot: Nachschub fehlt. Bei Pause erlischt die Leuchte. Der genaue Grund steht am ausgewählten Betrieb.")
 var found=0
 for kind in ["station","central_depot","express","sawmill"]:
  for i in Game.state.buildings.size():
   if Game.state.buildings[i].kind!=kind: continue
   var index=i
   var box=hud.card(UXRules.factory_name(Game.state,i))
   if kind in ["central_depot","express"]:
    hud.dynamic_text(box,func(): return "Holz %s · Bretter %s" % [Catalog.number(DepotNetwork.quantity(Game.state,index,"wood")),Catalog.number(DepotNetwork.quantity(Game.state,index,"boards"))])
   else:
    hud.dynamic_text(box,func(): return Game.production_status(index)+"\n"+LogisticsDispatch.collection_status(Game.state,index))
    if kind=="sawmill":
     hud.dynamic_text(box,func(): return SawmillProduction.status(Game.state,index))
     hud.button(box,"WERK & FERTIGUNGSLINIEN",func(): hud.show_building(index))
    if kind=="sawmill": hud.dynamic_text(box,func(): return "Eingang · "+FactorySupply.status(Game.state,index) if FactorySupply.managed(Game.state,index) else "Gemeinsamer Rohstoffbestand · %s Holz" % Catalog.number(Game.state.resources.wood))
   hud.button(box,"IM BETRIEB ANSEHEN",func(): focus(hud,index))
   found+=1
 if found==0: hud.card("Noch kein Betrieb","Errichte zuerst eine Sammelstation und ein Sägewerk.")
 var shipments=FreightFlow.all_trips(Game.state).filter(func(trip): return trip.key in ["wood","boards"])
 var current=hud.card("Holz und Bretter unterwegs","%s tatsächliche Warenfahrten. Auch die leere Rückfahrt hält das Fahrzeug belegt." % shipments.size())
 for trip in shipments.slice(0,6):
  var shipment=trip
  hud.dynamic_text(current,func(): return "%s %s · %s" % [Catalog.number(shipment.amount),Catalog.RESOURCES[shipment.key],FreightFlow.status(shipment)])
 hud.button(hud.contents,"ALLE LIEFERUNGEN",func(): hud.logistics_tab="trips"; hud.open_menu("logistics"))
