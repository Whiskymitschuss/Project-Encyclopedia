class_name Journey
extends RefCounted
const HALL_PLOT=100

# Permanent achievements and optional commissions share actual economy events.
# No wall-clock rewards, streaks, expiry timers or synthetic material grants.
const CHAPTERS = [
 {"id":"roots","name":"Ein guter Anfang","title":"Waldfreund","color":"e7b460","goals":[
  ["trees",5,"Fälle fünf Bäume","forest",40],
  ["deposited",20,"Liefere 20 Holz aus dem Rucksack ab","deposit",60],
  ["sales",1,"Verkaufe deine erste Ware","market",100]]},
 {"id":"sawmill","name":"Die Säge singt","title":"Sägemeister","color":"4fc3c8","goals":[
  ["boards",20,"Produziere 20 Bretter","sawmill",100],
  ["sawmill_level",2,"Baue ein Sägewerk auf Stufe 2 aus","sawmill",150],
  ["workers",3,"Beschäftige drei Holzarbeiter","team",180]]},
 {"id":"workshop","name":"Mehr als nur Holz","title":"Möbelmacher","color":"ec9364","goals":[
  ["kiln",1,"Stelle deine erste Trockenkammer fertig","kiln",200],
  ["furniture_factory",1,"Eröffne deine erste Möbelfabrik","furniture",250],
  ["exported",12,"Verkaufe zwölf Möbel","delivery",350]]},
 {"id":"routes","name":"Alles kommt an","title":"Logistikprofi","color":"62aee6","goals":[
  ["delivery_active",1,"Verbinde die kleine Holz-Lieferkette","delivery",250],
  ["shipments",6,"Schließe sechs echte Materiallieferungen ab","delivery",350],
  ["shop_orders",1,"Beliefere einen vollständigen Ladenauftrag","delivery",450]]},
 {"id":"builders","name":"Aus Plänen wird Heimat","title":"Baumeister","color":"f1c85a","goals":[
  ["prefab",1,"Eröffne dein Fertighauswerk","prefab",500],
  ["homes",1,"Stelle dein erstes Stadthaus fertig","city",600],
  ["rent",100,"Erhalte 100 Münzen Miete","city",700]]},
 {"id":"stone","name":"Ein festes Fundament","title":"Steinpionier","color":"bbb6c6","goals":[
  ["quarry",1,"Erschließe deinen ersten Steinbruch","quarry",600],
  ["stoneworks",1,"Eröffne dein erstes Steinwerk","stoneworks",750],
  ["stone_delivered",50,"Liefere 50 eigene Baustoffe ins Lager","stone",900]]},
 {"id":"town","name":"Eine Stadt für alle","title":"Stadtgestalter","color":"80cc88","goals":[
  ["roads",1,"Baue eine eigene Straße oder einen Weg","networks",500],
  ["residents",20,"Schaffe Platz für 20 Bewohner","city",1000],
  ["services",3,"Beende drei echte Stadtfahrten","services",1200]]},
 {"id":"horizon","name":"Neue Horizonte","title":"Timber-Pionier","color":"c693e5","goals":[
  ["biomes",3,"Erschließe drei Waldregionen","world",1500],
  ["home_level",5,"Entwickle ein Stadtgebäude bis Stufe 5","city",2000],
  ["districts",1,"Erschließe ein neues Stadtviertel","empire",2500]]},
 {"id":"skyline","name":"Deine eigene Skyline","title":"Imperiumsarchitekt","color":"ffcd53","goals":[
  ["home_level",10,"Entwickle ein Stadtgebäude bis Stufe 10","city",3000],
  ["biomes",5,"Erschließe fünf Waldregionen","world",3500],
  ["exported",500,"Verkaufe insgesamt 500 Möbel","delivery",5000]]},
 {"id":"empire","name":"Dein Industrieimperium","title":"Timber-Legende","color":"f4a2d6","goals":[
  ["sawmill_count",3,"Stelle drei eigene Sägewerke fertig","catalog",4000],
  ["residents",100,"Schaffe Platz für 100 Bewohner","city",6000],
  ["exported",2000,"Verkaufe insgesamt 2.000 Möbel","delivery",8000]]}]

const COMMISSIONS = {
 "wood":{"name":"Nachschub fürs Team","metric":"gathered","target":80,"reward":100,"action":"forest","text":"Gewinne 80 Holz. Dein Team darf mithelfen."},
 "boards":{"name":"Frische Bretter","metric":"boards","target":30,"reward":140,"action":"sawmill","text":"Produziere 30 neue Bretter. Verkauf oder Weiterverarbeitung ist erlaubt."},
 "deliver":{"name":"Auf der richtigen Spur","metric":"shipments","target":4,"reward":220,"action":"delivery","text":"Bringe vier beladene LKW-Lieferungen ans Ziel. Leere Rückfahrten zählen nicht."},
 "furniture":{"name":"Einrichten mit Holz","metric":"furniture","target":8,"reward":300,"action":"furniture","text":"Produziere acht neue Möbel. Sie zählen bei ihrer Fertigung."},
 "build":{"name":"Ein Stück weiterbauen","metric":"completed","target":1,"reward":350,"action":"catalog","text":"Stelle ein Gebäude oder einen echten Ausbau fertig."},
 "stone":{"name":"Solider Nachschub","metric":"stone_delivered","target":25,"reward":350,"action":"stone","text":"Liefere 25 selbst hergestellte Bausteine oder Kies ins Lager."}}

static func initial() -> Dictionary:
 return {"version":1,"stats":{},"reached":{},"claimed":{},"trophies":[],"selected":"","active":{},"completed_orders":0}

static func add(state: Dictionary,key: String,amount: float=1.0) -> void:
 if amount<=0: return
 var stats=state.journey.stats
 stats[key]=float(stats.get(key,0))+amount

static func migrate(state: Dictionary,saved: Dictionary) -> void:
 for key in initial():
  if not state.journey.has(key): state.journey[key]=initial()[key]
 if saved.has("journey"): return
 # Only known historical counters can be recovered; never invent production.
 for pair in [["trees","trees"],["gathered","gathered"],["exported","exported"]]:
  state.journey.stats[pair[0]]=float(state.get(pair[1],0))
 state.journey.stats.rent=float(state.town.rent_collected)
 state.journey.stats.stone_delivered=float(state.stone.delivered)
 state.journey.stats.shop_orders=int(state.delivery.orders)
 refresh(state)

static func value(state: Dictionary,key: String) -> float:
 match key:
  "workers": return int(state.workers)
  "homes":
   var count=0
   for home in state.homes:
    if home.kind!="townhall": count+=1
   return count
  "townhall": return townhall_level(state)
  "sawmill_count":
   var count=0
   for b in state.buildings:
    if b.kind=="sawmill": count+=1
   return count
  "roads": return state.town.roads.size()
  "districts": return int(state.town.districts)
  "biomes": return int(state.unlocked)
  "prestige": return int(state.prestige)
  "delivery_active": return 1 if state.delivery.active else 0
  "residents":
   var people=0
   for h in state.homes: people+=int(Catalog.HOMES[h.kind].people)*int(h.level)
   return people
  "home_level":
   var highest=0
   for h in state.homes:
    if h.kind!="townhall": highest=maxi(highest,int(h.level))
   return highest
  "sawmill_level":
   var highest=0
   for b in state.buildings:
    if b.kind=="sawmill": highest=maxi(highest,int(b.level))
   return highest
  "kiln","prefab","quarry","stoneworks","furniture_factory":
   var kind="furniture" if key=="furniture_factory" else key
   for b in state.buildings:
    if b.kind==kind: return 1
   return 0
 return float(state.journey.stats.get(key,0))

static func goal_id(chapter: int,index: int) -> String:
 return str(CHAPTERS[chapter].id)+":"+str(index)

static func refresh(state: Dictionary) -> void:
 # Latch achievements at the time they happen, even before opening the UI.
 var hall=townhall_level(state)
 for c in CHAPTERS.size():
  for i in CHAPTERS[c].goals.size():
   var goal=CHAPTERS[c].goals[i]
   var id=goal_id(c,i)
   if not state.journey.reached.has(id) and value(state,goal[0])+0.00001>=float(goal[1]): state.journey.reached[id]=true
  if hall>=c+1: state.journey.reached[hall_id(c)]=true

static func hall_id(chapter: int) -> String:
 return str(CHAPTERS[chapter].id)+":hall"

static func townhall_index(state: Dictionary) -> int:
 for i in state.homes.size():
  if state.homes[i].kind=="townhall": return i
 return -1

static func townhall_level(state: Dictionary) -> int:
 var index=townhall_index(state)
 return int(state.homes[index].level) if index>=0 else 0

static func hall_unlocked(state: Dictionary,target: int) -> bool:
 if target<1 or target>CHAPTERS.size(): return false
 # Every previous chapter must have actually been finished and claimed.
 for c in target-1:
  if not state.journey.claimed.has(hall_id(c)): return false
 for i in CHAPTERS[target-1].goals.size():
  if not state.journey.claimed.has(goal_id(target-1,i)): return false
 return true

static func hall_materials(target: int) -> Dictionary:
 var materials={"wood":float(8+target*4),"boards":float(4+target*4)}
 if target>=3: materials.furniture=float(target*2)
 if target>=5: materials.walls=float(target*2); materials.roofs=float(target)
 if target>=6: materials.stone=float(target*4); materials.gravel=float(target*2)
 if target>=8: materials.parts=float(target*2)
 return materials

static func hall_cost(target: int) -> float:
 return [200,450,900,1800,4000,8000,16000,32000,64000,120000][clampi(target-1,0,9)]

static func current(state: Dictionary) -> Dictionary:
 for c in CHAPTERS.size():
  for i in CHAPTERS[c].goals.size():
   var id=goal_id(c,i)
   if not state.journey.claimed.has(id):
    var goal=CHAPTERS[c].goals[i]
    return {"id":id,"chapter":c,"index":i,"name":goal[2],"target":float(goal[1]),"value":minf(float(goal[1]),value(state,goal[0])),"ready":state.journey.reached.has(id),"action":goal[3],"coins":int(goal[4]),"chapter_name":CHAPTERS[c].name}
  if not state.journey.claimed.has(hall_id(c)):
   return {"id":hall_id(c),"chapter":c,"index":-1,"name":"Rathaus auf Stufe %s fertigstellen" % (c+1),"target":float(c+1),"value":float(townhall_level(state)),"ready":state.journey.reached.has(hall_id(c)),"action":"townhall","coins":100*(c+1),"chapter_name":CHAPTERS[c].name}
 return {}

static func choices(state: Dictionary) -> Array:
 var pool=["wood","boards","build"]
 if state.delivery.active: pool.append("deliver")
 if value(state,"furniture_factory")>0: pool.append("furniture")
 if value(state,"stoneworks")>0 and value(state,"quarry")>0: pool.append("stone")
 var result=[]
 var start=int(state.journey.completed_orders)%pool.size()
 for i in mini(3,pool.size()): result.append(pool[(start+i)%pool.size()])
 return result

static func order_progress(state: Dictionary) -> float:
 var order=state.journey.active
 if order.is_empty(): return 0
 return clampf(float(state.journey.stats.get(order.metric,0))-float(order.baseline),0,float(order.target))

static func resume_capture(state: Dictionary) -> Dictionary:
 var places={}
 for city in [false,true]:
  var records=state.homes if city else state.buildings
  for i in records.size(): places[("home:" if city else "building:")+str(i)]=int(records[i].level)
 return {"coins":float(state.coins),"completed":float(state.journey.stats.get("completed",0)),"shipments":float(state.journey.stats.get("shipments",0)),"boards":float(state.journey.stats.get("boards",0)),"furniture":float(state.journey.stats.get("furniture",0)),"rent":banked_rent(state),"elapsed":float(state.elapsed),"places":places,"exported":float(state.exported)}

static func banked_rent(state: Dictionary) -> float:
 var amount=0.0
 for h in state.homes: amount+=float(h.get("rent_bank",0))
 return amount

static func resume_report(state: Dictionary,before: Dictionary,seconds: float) -> Dictionary:
 var now=resume_capture(state)
 var report={"seconds":seconds,"coins":now.coins-before.coins,"rent":maxf(0,now.rent-before.rent)}
 for key in ["completed","shipments","boards","furniture"]: report[key]=maxf(0,now[key]-before[key])
 report.sold=maxf(0,float(state.exported)-float(before.get("exported",state.exported)))
 report.destinations=[]
 for city in [false,true]:
  var records=state.homes if city else state.buildings
  for i in records.size():
   var key=("home:" if city else "building:")+str(i)
   if before.has("places") and int(records[i].level)>int(before.places.get(key,0)) and report.destinations.size()<8:
    report.destinations.append({"city":city,"index":i,"name":UXRules.title(state,city,i)})
 return report
