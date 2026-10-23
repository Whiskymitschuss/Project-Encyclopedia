class_name PlacementAccess
extends RefCounted

static func describe(state: Dictionary,point: Vector3,rotation: int,kind: String) -> Dictionary:
 var cells=TownRules.road_cells(state.town)
 var nearest=TownRules.nearest(point,cells,32)
 if nearest==null: return {"connected":false,"path":[],"text":"Keine LKW-Zufahrt in Reichweite · zuerst Straße bauen"}
 var road=TownRules.point(nearest)
 var anchor=CentralLogistics.depot(state)
 if anchor<0 and not state.buildings.is_empty(): anchor=0
 var connected=anchor>=0 and LogisticsRoutes.road_to_point(state,anchor,point).size()>=2
 var direction=(road-point).normalized()
 var half=Placement.size_for(rotation,kind)/2
 var edge=minf(half.x/maxf(absf(direction.x),0.001),half.y/maxf(absf(direction.z),0.001))
 var start=point+direction*edge
 return {"connected":connected,"path":[start,road],"text":"LKW-Anschluss %s m · an das Straßennetz angebunden" % roundi(point.distance_to(road)) if connected else "Straße vorhanden, aber noch nicht mit dem Betrieb verbunden"}
