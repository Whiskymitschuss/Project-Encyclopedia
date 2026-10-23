extends RefCounted
static func populate(hud: Control,tab: String) -> void:
 if tab=="performance":
  hud.modal_title.text="LEISTUNGSVERGLEICH"
  var box=hud.card("Eine Runde durch deine Stadt","Die Kamera fährt 30 Sekunden dieselben drei Ansichten ab. Vergleiche dieselbe Stadt bei gleicher Helligkeit und ohne Ladegerät, danach im Akkumodus. Das Spiel läuft normal weiter.")
  hud.text(box,"Gerät: %s · %s Betriebe · %s Häuser\nProfil: %s · maximal %s Bilder/s" % [OS.get_model_name(),Game.state.buildings.size(),Game.state.homes.size(),"Akku" if Game.state.quality==0 else "Standard",Engine.max_fps],15,hud.MUTED)
  hud.button(box,"KAMERARUNDE STARTEN",func(): hud.close_menu(); hud.camera_action.emit("benchmark"))
  if not Game.performance_results.is_empty():
   var r=Game.performance_results
   hud.card("Deine letzte Messung","%.1f Bilder/s im Mittel · 95 %% der Frames unter %.1f ms\n%s Frames · %.1f Sekunden · %s\nTemperatur bitte am Gerät vergleichen." % [r.fps,r.p95_ms,r.frames,r.seconds,r.profile])
  var live=hud.card("Startzeit & aktuelle Leistung","Sitzungsmessung auf diesem Gerät. Der erste Script-Frame beginnt bei der Engine, nicht beim Antippen des App-Symbols. Menüs bleiben scharf; automatische Entlastung betrifft nur die 3D-Darstellung. Keine Temperaturmessung.")
  hud.dynamic_text(live,func(): return RuntimeStats.summary())
  hud.button(live,"EINSTELLUNGEN",func(): hud.open_menu("settings"))
  return
 hud.modal_title.text="BETRIEBSÜBERSICHT"
 var queued=0
 for trip in FreightFlow.all_trips(Game.state):
  if float(trip.get("depart_in",0))>0: queued+=1
 var fleet=int(Game.state.trucks)+(CentralLogistics.fleet_size(Game.state)*2 if CentralLogistics.active(Game.state) else 0)
 hud.card("%s / %s LKW belegt" % [FreightFlow.all_trips(Game.state).size(),fleet],"%s warten mit reservierter Ladung im Depot. Laufende Fahrten enden auch bei Produktionspause. Platz im Ziellager bleibt nötig." % queued)
 for i in Game.state.buildings.size():
  var index=i
  var advice=ProductionPresentation.advice(Game,index)
  if advice.kind in ["ready","running"]: continue
  var box=hud.card(UXRules.title(Game.state,false,index),Game.production_status(index))
  if not str(advice.key).is_empty():
   var key=str(advice.key)
   hud.button(box,Catalog.RESOURCES[key]+" · QUELLEN & LIEFERUNGEN",func(): hud.ux.open_material(key))
  hud.button(box,"BETRIEB ANSEHEN",func(): hud.ux.select_building(index,false,true))
 hud.button(hud.contents,"ALLE BETRIEBE",func(): hud.open_menu("industry"))
 for trip in FreightFlow.all_trips(Game.state):
  var s=trip
  var domain="central" if s.target in ["central","express","factory"] else "construction" if s.target=="construction" else "stone" if s.target=="mineral" else "export" if s.target=="export" else "wood"
  var box=hud.card("%s %s" % [Catalog.number(s.amount),Catalog.RESOURCES[s.key]])
  hud.dynamic_text(box,func(): return FreightFlow.status(s))
  hud.button(box,"LKW & ROUTE",func(): hud.ux.select_truck({"kind":"truck","domain":domain,"id":int(s.id)},true))
