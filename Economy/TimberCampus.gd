class_name TimberCampus
extends RefCounted
const KINDS=["station","sawmill","kiln","warehouse"]

static func quote(game: Node) -> Dictionary:
 var price=0.0
 for kind in KINDS:
  if not game.available(kind): return {"reason":"Zuerst %s freischalten" % Catalog.BUILDINGS[kind].name}
  price+=game.cost_for(kind)
 for z in [-44,-12,20,52,84,116,148]:
  var lots=[]
  var valid=true
  for i in 4:
   var point=Vector3([-44,-20,20,44][i],0,z)
   if not game.placement_reason(point,0,-1,-1,KINDS[i]).is_empty(): valid=false; break
   if LogisticsRoutes.between(game.state,Vector3(-44,0,z),point).size()<2: valid=false; break
   lots.append({"kind":KINDS[i],"point":[point.x,point.z]})
  if valid: return {"price":price,"lots":lots,"reason":"","center":Vector3(0,0,z)}
 return {"reason":"Kein freier, angeschlossener Vierer-Werkshof im Kerngebiet. Bestehende Betriebe bleiben erhalten."}

static func links(state: Dictionary) -> Array:
 var result=[]
 var road_cells=TownRules.road_cells(state.town).keys()
 for i in state.buildings.size():
  if state.buildings[i].kind not in KINDS+["central_depot","express","furniture","joinery","prefab"]: continue
  var a=LogisticsRoutes.building_position(state,i)
  for j in range(i+1,state.buildings.size()):
   if state.buildings[j].kind not in KINDS+["central_depot","express","furniture","joinery","prefab"]: continue
   var b=LogisticsRoutes.building_position(state,j)
   if absf(a.z-b.z)>0.1 or absf(a.x-b.x)>32: continue
   var ra=Placement.bounds(a,int(state.buildings[i].get("rotation",0)),state.buildings[i].kind)
   var rb=Placement.bounds(b,int(state.buildings[j].get("rotation",0)),state.buildings[j].kind)
   var left=ra if a.x<b.x else rb; var right=rb if a.x<b.x else ra
   var width=right.position.x-left.end.x
   if width<1 or width>8: continue
   var area=Rect2(left.end.x,a.z-1,width,2)
   if road_cells.any(func(cell): return area.grow(4).has_point(Vector2(cell))): continue
   result.append({"a":i,"b":j,"area":area})
 return result
