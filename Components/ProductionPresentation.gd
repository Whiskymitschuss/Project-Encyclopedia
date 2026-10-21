class_name ProductionPresentation
extends RefCounted

static func describe(game: Node,index: int) -> Dictionary:
 var state=game.state
 if index<0 or index>=state.buildings.size(): return {"kind":"ready","text":""}
 var b=state.buildings[index]
 if b.get("paused",false): return {"kind":"paused","text":"Ⅱ Pause"}
 if b.kind in StoneIndustry.KINDS:
  var site=StoneIndustry.site(state,index)
  if site.is_empty(): return {"kind":"ready","text":""}
  if b.kind=="quarry":
   if float(site.reserve)<=0 and float(site.bucket)<=0 and int(site.phase)==0: return {"kind":"missing","text":"! Felsader leer"}
   if float(site.stock.rock)+float(site.bucket)>=StoneIndustry.capacity(state,index): return {"kind":"full","text":"↑ Abholmulde voll"}
  elif site.batch.is_empty():
   var recipe=StoneIndustry.definitions.recipes[site.recipe]
   for key in recipe.out:
    if float(site.stock[key])+float(recipe.out[key])>StoneIndustry.capacity(state,index): return {"kind":"full","text":"↑ Ausgang voll"}
   if float(site.stock.rock)<3: return {"kind":"missing","text":"! Gestein fehlt"}
  return {"kind":"running","text":""}
 if game.delivery_owns(index):
  if state.delivery.paused: return {"kind":"paused","text":"Ⅱ Lieferlinie pausiert"}
  for selected in state.delivery.nodes.values():
   if state.buildings[int(selected)].get("paused",false): return {"kind":"paused","text":"Ⅱ Lieferlinie wartet"}
  var info=DeliveryChain.status(state,b.kind)
  if info.full: return {"kind":"full","text":"↑ Ausgang voll"}
  if not info.ready and b.kind in ["sawmill","furniture"]: return {"kind":"missing","text":"! %s fehlt" % Catalog.RESOURCES[info.key]}
  return {"kind":"running","text":""}
 if not Catalog.RECIPES.has(b.kind): return {"kind":"ready","text":""}
 var recipe=Catalog.RECIPES[b.kind]
 for key in recipe.out:
  if key not in recipe.get("overflow_sell",[]) and float(state.resources[key])>=game.capacity()-0.0001: return {"kind":"full","text":"↑ %s-Lager voll" % Catalog.RESOURCES[key]}
 for key in recipe["in"]:
  if float(state.resources[key])<=game.reserve_for(key)+0.0001:
   return {"kind":"missing","text":"! %s reserviert" % Catalog.RESOURCES[key] if game.reserve_for(key)>0 else "! %s fehlt" % Catalog.RESOURCES[key]}
 return {"kind":"running","text":""}
