extends RefCounted
static func mill_controls(hud: Control,parent: Node,index: int) -> void:
 var building=Game.state.buildings[index]
 var stage=clampi(int(building.level),1,10)
 hud.text(parent,"Bauform %s/10 · %s" % [stage,SawmillModels.STAGES[stage-1]],17,hud.GOLD)
 hud.dynamic_text(parent,func(): return SawmillProduction.status(Game.state,index))
 hud.text(parent,"2 Holz bleiben während Entrinden, Sägen und Hobeln in der Anlage. Erst am Ende entstehen 1 Brett und 1 Sägespäne. Zusätzliche Linien erhöhen die echte Verarbeitungskapazität; Nachschub und Abholung bestimmen den tatsächlichen Durchsatz.",14,hud.MUTED)
 hud.text(parent,"Zur Linie gehört ein Biber-Maschinenführer. Deine Waldhelfer teilen sich Fällen und Pflanzen.",13,hud.MUTED)
 var count=SawmillProduction.line_count(Game.state,index)
 var limit=SawmillProduction.line_limit(int(building.level))
 if count<limit:
  hud.button(parent,"LINIE %s EINRICHTEN · %s MÜNZEN" % [count+1,Catalog.number(Game.saw_line_cost(index))],func(): hud.action(func(): Game.order_saw_line(index)),not Game.job_for("upgrade",index))
  hud.text(parent,"Baumaterial kommt per LKW; das Bauteam installiert die Maschinen vor der Freigabe.",13,hud.MUTED)
 else: hud.text(parent,"Zweite Linie ab Werkstufe 4, dritte ab Werkstufe 7. Gebäudestufen über 10 behalten die zehnte Bauform und ihren bisherigen wirtschaftlichen Fortschritt.",13,hud.MUTED)
 hud.button(parent,"BAUFORMEN 1–10 ANSEHEN",func(): hud.open_menu("mill_stages",index))

static func populate(hud: Control,tab: String) -> void:
 if tab=="mill_stages":
  hud.modal_title.text="SÄGEWERK · BAUFORMEN"
  for i in 10:
   var descriptions=["Offener Holzunterstand mit einer kompakten Verarbeitungslinie.","Entrinderwerkstatt mit eigenem Bedien- und Technikraum.","Mehrstöckige Bretterregale und sortierte Ausgangsbuchten.","Neue Stahlrahmenhalle; eine zweite Linie kann eingerichtet werden.","Großes Hallenportal, feste Arbeitsbereiche und gesicherte Ladehöfe.","Technikflügel mit zusätzlichen Aggregaten und Ablufttechnik.","Versorgung der dritten unabhängig arbeitenden Fertigungslinie.","Zwei Dachfelder und ein erkennbarer Hallenverbund mit offenem Einblick.","Verbundene Versorgungsleitungen und automatisierte Maschinenanschlüsse.","Hoher Biber-Leitstand, Leitbrücke und vollständiger Dreilinienausbau."]
   hud.card("%s · %s" % [i+1,SawmillModels.STAGES[i]],descriptions[i])
  return
 hud.modal_title.text="DEIN HOLZWERKSHOF"
 hud.card("Ein zusammenhängender Betrieb","Sammelstation, Sägewerk, Trocknung und Lager bilden einen Werkshof. Private Fußverbindungen verbinden benachbarte Grundstücke; öffentliche Straßen bleiben frei. Bestehende Gebäude und laufende Transporte behalten ihre Standorte.")
 var links=TimberCampus.links(Game.state)
 hud.card("%s private Hofverbindungen" % links.size(),"Türkis: Wareneingang · Gold: Ausgang. Stapler fahren über die freigehaltenen Randgassen. Die Hallen bleiben zur Kamera offen, damit du Verarbeitung und Biber beobachten kannst.")
 var quote=TimberCampus.quote(Game)
 if not str(quote.reason).is_empty(): hud.card("Werkshofplanung",quote.reason)
 else:
  var box=hud.card("Neuen Werkshof planen","Vier reguläre Bauaufträge an einer angeschlossenen Industriezeile. Grundstücke werden vor der Bestellung gemeinsam geprüft; Baustellen erhalten Material und Mitarbeiter über das bestehende Netz.")
  for lot in quote.lots: hud.text(box,"%s · Standort %s / %s" % [Catalog.BUILDINGS[lot.kind].name,lot.point[0],lot.point[1]],14,hud.INK)
  var cost=float(quote.price)
  hud.button(box,"WERKSHOF BESTELLEN · %s MÜNZEN" % Catalog.number(cost),func(): hud.action(func(): Game.order_timber_campus(cost)))
  hud.button(box,"STANDORT ANSEHEN",func(): hud.close_menu(); hud.focus_requested.emit(quote.center))
 hud.button(hud.contents,"HOLZKETTE & LIEFERUNGEN",func(): hud.open_menu("timberline"))
