class_name AlphaReport
extends RefCounted

static func build(state: Dictionary, device: Dictionary, save_status: String) -> String:
 # A deliberately small allowlist: never include the save, paths, user/unique IDs,
 # clipboard content, screenshots, private keys or environment variables.
 return """TIMBER LOOT · ALPHA 1 · TESTBERICHT
Version: %s
System: %s · %s
Gerät/Grafik: %s
Ansicht: %s
Qualität: %s · reduzierte Bewegung: %s
Speicherstatus: %s
Fortschritt: Tutorial %s · %s Betriebe · %s Häuser · %s Bauaufträge
Transporte: %s Holz · %s Bau · %s Stein · %s Export

Was ist passiert?
[Bitte kurz beschreiben]

So kann man es wiederholen:
1.
2.
3.

Was hattest du erwartet?

Wie oft passiert es? [immer / manchmal / einmal]
Screenshot oder kurzes Video: [optional separat beilegen]
""" % [ProjectSettings.get_setting("application/config/version"),device.get("os","unbekannt"),device.get("os_version",""),device.get("model","unbekannt"),device.get("viewport","unbekannt"),"Akku" if int(state.quality)==0 else "Standard",not bool(state.ux.motion),save_status,int(state.tutorial),state.buildings.size(),state.homes.size(),state.jobs.size(),state.delivery.shipments.size(),state.construction_shipments.size(),state.stone.shipments.size(),state.trade.shipments.size()]
