extends RefCounted

static func fleet_controls(hud: Control,parent: Node) -> void:
 var state=Game.state
 var owned=int(state.hub.get("extra_trucks",0))
 var limit=TransportCapacity.fleet_purchase_limit(state)
 hud.text(parent,"Zusätzliche Lager-LKW: %s/%s · Holzladung bis %s · Palettenware bis %s" % [owned,limit,Catalog.number(CentralLogistics.pickup_capacity(state,"wood")),Catalog.number(CentralLogistics.pickup_capacity(state,"boards"))],14,hud.MUTED)
 if owned<limit:
  hud.button(parent,"LAGER-LKW KAUFEN · %s MÜNZEN" % Catalog.number(TransportCapacity.fleet_cost(state)),func(): hud.action(func(): Game.buy_central_truck()))
 elif CentralLogistics.fleet_size(state)>=16:
  hud.button(parent,"MAXIMAL 16 LAGER-LKW AKTIV",func(): pass,false)
 else:
  hud.button(parent,"MEHR STELLPLÄTZE · GARAGE AUSBAUEN",func(): hud.build_category="Versorgung"; hud.open_menu("catalog"))


static func workshop_controls(hud: Control,parent: Node,index: int) -> void:
 var state=Game.state
 var level=TransportCapacity.dock_level(state,index)
 var output=DeliveryChain.capacity(state,str(state.buildings[index].kind)) if DeliveryChain.owns(state,index) else StoneIndustry.capacity(state,index) if state.buildings[index].kind in StoneIndustry.KINDS else CentralLogistics.output_capacity(state,index)
 var buffer=FactorySupply.capacity(state,index) if not FactorySupply.requirements(state,index).is_empty() else output
 hud.text(parent,"Transportausbau %s/%s · Puffer %s je Ware\nLadung bis %s Holz / %s Waren · Umschlag %.1f s" % [level,TransportCapacity.MAX_DOCK_LEVEL,Catalog.number(buffer),Catalog.number(CentralLogistics.pickup_capacity(state,"wood",index,index)),Catalog.number(CentralLogistics.pickup_capacity(state,"boards",index,index)),TransportCapacity.handling_seconds(state,index,index)],14,hud.MUTED)
 hud.button(parent,"TRANSPORT AUSBAUEN · %s MÜNZEN" % Catalog.number(TransportCapacity.upgrade_cost(state,index)) if level<TransportCapacity.MAX_DOCK_LEVEL else "TRANSPORT VOLL AUSGEBAUT",func(): hud.action(func(): Game.upgrade_transport(index)),level<TransportCapacity.MAX_DOCK_LEVEL)
