class_name ProductionPresentation
extends RefCounted

static func advice(game: Node,index: int) -> Dictionary:
 var status=describe(game,index)
 var key=""
 var b=game.state.buildings[index]
 if b.kind=="station": return {"kind":status.kind,"text":status.text,"key":"wood" if status.kind in ["full","missing"] else "","index":index}
 if status.kind=="missing":
  if b.kind in StoneIndustry.KINDS: key="rock" if b.kind=="stoneworks" else ""
  elif game.delivery_owns(index): key=str(DeliveryChain.status(game.state,b.kind).key)
  elif Catalog.RECIPES.has(b.kind):
   for input in Catalog.RECIPES[b.kind]["in"]:
    if (float(FactorySupply.stock(game.state,index).get(input,0)) if FactorySupply.managed(game.state,index) else float(game.state.resources[input])-game.processing_reserve_for(input))<=0.0001: key=input; break
 if status.kind=="full":
  if game.delivery_owns(index): key=str(DeliveryChain.status(game.state,b.kind).get("output_key","wood"))
  elif b.kind in StoneIndustry.KINDS: key="rock" if b.kind=="quarry" else "stone"
  elif Catalog.RECIPES.has(b.kind):
   for output in Catalog.RECIPES[b.kind].out:
    if (CentralLogistics.output_room(game.state,index,output)<=0.0001 if CentralLogistics.active(game.state) else float(game.state.resources[output])>=game.capacity()-0.0001): key=output; break
 return {"kind":status.kind,"text":status.text,"key":key,"index":index}

static func describe(game: Node,index: int) -> Dictionary:
 var state=game.state
 if index<0 or index>=state.buildings.size(): return {"kind":"ready","text":""}
 var b=state.buildings[index]
 if b.get("paused",false): return {"kind":"paused","text":"Ⅱ Pause"}
 if b.kind=="station": return ForestryFlow.describe(state,index,game.flow)
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
  var info=DeliveryChain.status(state,b.kind)
  if info.full: return {"kind":"full","text":"↑ Ausgang voll"}
  if not info.ready and b.kind in ["sawmill","furniture"]: return {"kind":"missing","text":"! %s fehlt" % Catalog.RESOURCES[info.key]}
  return {"kind":"running","text":""}
 if not Catalog.RECIPES.has(b.kind): return {"kind":"ready","text":""}
 var recipe=Catalog.RECIPES[b.kind]
 for key in recipe.out:
  if key not in recipe.get("overflow_sell",[]) and (CentralLogistics.output_room(state,index,key)<=0.0001 if CentralLogistics.active(state) else float(state.resources[key])>=game.capacity()-0.0001): return {"kind":"full","text":"↑ %s-Lager voll" % Catalog.RESOURCES[key]}
 for key in recipe["in"]:
  var local_inputs=FactorySupply.managed(state,index)
  if (float(FactorySupply.stock(state,index).get(key,0)) if local_inputs else float(state.resources[key])-game.processing_reserve_for(key))<=0.0001:
   return {"kind":"missing","text":"! %s reserviert" % Catalog.RESOURCES[key] if not local_inputs and game.processing_reserve_for(key)>0 else "! %s fehlt" % Catalog.RESOURCES[key]}
 return {"kind":"running","text":""}
