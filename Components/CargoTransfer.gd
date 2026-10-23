class_name CargoTransfer
extends RefCounted

static func phase(shipment: Dictionary, age: float) -> Dictionary:
 if shipment.get("arrived",false): return {"kind":"return","progress":1.0}
 if not shipment.has("drive"): return {"kind":"drive","progress":1.0}
 var load_time=float(shipment.get("load",0))
 var drive_end=load_time+float(shipment.drive)
 if age<load_time: return {"kind":"load","progress":clampf(age/maxf(0.001,load_time),0,1)}
 if age>=drive_end and age<float(shipment.travel):
  return {"kind":"unload","progress":clampf((age-drive_end)/maxf(0.001,float(shipment.get("unload",2))),0,1)}
 return {"kind":"drive","progress":1.0}

static func has_forklift(state: Dictionary,shipment: Dictionary,loading: bool) -> bool:
 # Loose bulk stays in the tipper bed; it is never a forklift pallet.
 if shipment.key in ["rock","gravel"]: return false
 var index=int(shipment.get("origin",-1)) if loading else int(shipment.get("destination",-1))
 var kind=str(shipment.get("source","") if loading else shipment.get("target",""))
 if index>=0 and index<state.buildings.size(): kind=str(state.buildings[index].kind)
 return Catalog.RECIPES.has(kind) or kind in ["central_depot","express","stoneworks"]

static func dock(game: Node, shipment: Dictionary, loading: bool) -> Vector3:
 var state=game.state
 var index=int(shipment.get("origin",-1)) if loading else int(shipment.get("destination",-1))
 if index>=0 and index<state.buildings.size(): return game.building_position(index)
 if not loading and shipment.target=="construction":
  for job in state.jobs:
   if int(job.get("id",-1))==int(shipment.get("job",-2)): return ConstructionRules.job_position(state,job)
 var kind=str(shipment.source if loading else shipment.target)
 if state.delivery.nodes.has(kind): return game.building_position(int(state.delivery.nodes[kind]))
 return LogisticsRoutes.vector(shipment.path[0 if loading else -1])

static func apply(game: Node, node: Node3D, shipment: Dictionary, age: float) -> String:
 var stage=phase(shipment,age)
 if node.cargo==null: return str(stage.kind)
 var cargo: Node3D=node.cargo
 if not cargo.has_meta("rest_position"): cargo.set_meta("rest_position",cargo.position)
 cargo.position=cargo.get_meta("rest_position")
 if not game.state.ux.motion or stage.kind not in ["load","unload"]: return str(stage.kind)
 # Keep the real load on its deck. The former sideways 3.8 m slide sent
 # pallets through machines and roofs; a small hoist pulse stays in the bay.
 cargo.position+=Vector3.UP*sin(float(stage.progress)*PI)*0.18
 return str(stage.kind)
