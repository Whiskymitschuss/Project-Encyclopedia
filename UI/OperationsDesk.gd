extends RefCounted
static func populate(hud: Control,tab: String) -> void:
 if tab=="performance":
  hud.modal_title.text="LEISTUNGSVERGLEICH"
  var device=hud.card("Dein Gerät")
  hud.text(device,"%s · Version %s\n%s Betriebe · %s Häuser · %s · maximal %s Bilder/s" % [OS.get_model_name(),ProjectSettings.get_setting("application/config/version"),Game.state.buildings.size(),Game.state.homes.size(),GraphicsProfiles.profile(int(Game.state.quality)).name,Engine.max_fps],14,hud.MUTED)
  var live=hud.card("Startzeit & aktuelle Leistung","Während des Spielens gemessen. Menü in voller Auflösung; keine Temperaturmessung.")
  hud.dynamic_text(live,func(): return RuntimeStats.summary())
  hud.button(live,"EINSTELLUNGEN",func(): hud.open_menu("settings"))
  var automatic=hud.card("Automatische Messdetails","Auf Android beim Spielen aktiv; keine Kamerarunde nötig. Es wird nichts gesendet.")
  hud.dynamic_text(automatic,func():return RuntimeStats.passive_summary())
  var stalls=hud.card("Letzte lange Hänger")
  hud.dynamic_text(stalls,func():return RuntimeStats.stalls_summary())
  var saving=hud.card("Speichern")
  hud.dynamic_text(saving,func():return Store.status_text())
  var startup=hud.card("Weltaufbau nach Bereichen")
  hud.text(startup,RuntimeStats.startup_summary(),14,hud.MUTED)
  var memory=hud.card("Speicher und Szenenobjekte")
  hud.dynamic_text(memory,func():return "Engine-Speicher: %.1f MiB · %s Nodes\nGPU-Speicher (Engine): %.1f MiB. Kein Android-Gesamtspeicher oder Temperaturwert." % [OS.get_static_memory_usage()/1048576.0,hud.get_tree().get_node_count(),Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1048576.0])
  var graphics=hud.card("Grafikzeit messen")
  hud.dynamic_text(graphics,func():return RuntimeStats.render_probe_summary())
  hud.button(graphics,"10 SEKUNDEN MESSEN",func(): RuntimeStats.start_render_probe())
  var box=hud.card("Eine Runde durch deine Stadt","Optionaler Vergleich: 30 Sekunden dieselben drei Ansichten. Erst in Standard, danach im Akkumodus vergleichen. Das Spiel läuft weiter.")
  hud.button(box,"KAMERARUNDE STARTEN",func(): hud.close_menu(); hud.camera_action.emit("benchmark"))
  if not Game.performance_results.is_empty():
   var r=Game.performance_results
   hud.card("Deine letzte Messung","%.1f Bilder/s im Mittel · 95 %% der Frames unter %.1f ms\n%s Frames · %.1f Sekunden · %s\nTemperatur bitte am Gerät vergleichen." % [r.fps,r.p95_ms,r.frames,r.seconds,r.profile])
   if r.has("work"):
    hud.card("Messdetails · "+str(r.get("version","")),"Zeichenaufrufe (Median): %s\nEngine-Prozess P95: %.1f ms\n%s\nCPU-Zeiten je Aufruf; Unterbereiche können sich überschneiden. Kein GPU- oder Temperaturtest." % [int(r.draw_calls),r.process_p95_ms,RuntimeStats.profile_summary(r.work)])
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
