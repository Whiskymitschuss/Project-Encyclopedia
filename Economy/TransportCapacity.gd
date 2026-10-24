class_name TransportCapacity
extends RefCounted

# Physical buffer space, not inventory. Existing saved goods are never topped up.
const MAX_DOCK_LEVEL=4
static func supported(state: Dictionary,index: int) -> bool:
 if index<0 or index>=state.buildings.size(): return false
 return Catalog.RECIPES.has(state.buildings[index].kind) or state.buildings[index].kind in ["station","quarry","stoneworks"]
static func dock_level(state: Dictionary,index: int) -> int:
 return clampi(int(state.buildings[index].get("transport_level",0)),0,MAX_DOCK_LEVEL) if supported(state,index) else 0
static func buffer(state: Dictionary,index: int) -> float:
 return minf(384,96+int(state.buildings[index].level)*16+dock_level(state,index)*32)
static func load_multiplier(state: Dictionary,origin: int=-1,destination: int=-1) -> float:
 return 1.0+maxi(dock_level(state,origin),dock_level(state,destination))*0.25
static func handling_seconds(state: Dictionary,origin: int,destination: int) -> float:
 return maxf(2,4-maxi(dock_level(state,origin),dock_level(state,destination))*0.5)
static func upgrade_cost(state: Dictionary,index: int) -> float:
 return ceilf(500*pow(1.8,dock_level(state,index))*pow(1.6,int(state.prestige)))
static func fleet_base(state: Dictionary) -> int:
 var index=CentralLogistics.depot(state)
 if index<0: return 0
 var result=mini(10,4+int(state.buildings[index].level))
 for b in state.buildings:
  if b.kind=="express": result+=1+mini(2,(int(b.level)-1)/4)
 return mini(16,result)
static func fleet_purchase_limit(state: Dictionary) -> int:
 var garage=0
 for b in state.buildings:
  if b.kind=="garage": garage+=int(b.level)
 return maxi(0,mini(2+garage*2,16-fleet_base(state)))
static func fleet_cost(state: Dictionary) -> float:
 return ceilf(800*pow(1.6,int(state.hub.get("extra_trucks",0)))*pow(1.6,int(state.prestige)))
