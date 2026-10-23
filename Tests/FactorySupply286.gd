extends SceneTree
var game
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func company(line: bool=false) -> Dictionary:
 game.state=game.initial_state()
 var s=game.state
 s.workers=0
 s.trucks=0
 s.vehicle=0
 s.city_services.enabled=false
 s.auto_export=false
 s.reserve=false
 s.jobs=[]
 for b in s.buildings: b.paused=true
 s.buildings.append({"kind":"furniture","level":2,"paused":false,"position":[-20,-12]})
 s.buildings.append({"kind":"central_depot","level":1,"paused":false,"position":[44,20]})
 for key in s.resources: s.resources[key]=0.0
 if line:
  for b in s.buildings: b.paused=false
  DeliveryChain.start(s)
 return s
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 var s=company()
 s.resources.dry=60.0
 s.resources.boards=60.0
 var result=game.request_material(5)
 check(s.hub.shipments.size()==1,"Manual request immediately sends a dedicated central truck with zero general trucks")
 var trip=s.hub.shipments[0]
 var key=str(trip.key)
 check(trip.target=="factory" and int(trip.origin)==6 and int(trip.destination)==5 and trip.fleet=="central","Real trip belongs to the central fleet and actual requested workshop")
 check(float(s.resources[key])==60-float(trip.amount) and FactorySupply.stock(s,5).is_empty(),"Stock withdrawn exactly once, not credited before unload")
 check(FactorySupply.incoming(s,5,key)==float(trip.amount) and result.contains("im LKW"),"UI shows the real incoming cargo")
 for press in 12: game.request_material(5)
 for input in ["dry","boards"]:
  check(FactorySupply.incoming(s,5,input)+FactorySupply.queued(s,5,input)<=FactorySupply.capacity(s,5),"Repeated taps reserve only remaining input space: "+input)
 check(s.hub.shipments.size()<=CentralLogistics.fleet_size(s),"Manual orders never invent additional trucks")
 check(FactorySupply.status(s,5).contains("freien LKW"),"Orders explain waiting when the entire fleet is occupied")
 var total_before=float(s.resources[key])+UXRules.material_stock(s,key).transit
 check(absf(total_before-60)<0.00001,"Material UI does not double-count loaded cargo")
 # Finish real loading, route and unloading. No production needed for this assertion.
 for i in 400: CentralLogistics.tick(s,1)
 check(float(FactorySupply.stock(s,5).get(key,0))>0,"Local factory receives stock only after actual unload")
 s.hub.requests=[]
 var boards=s.resources.boards
 var dry=s.resources.dry
 game.step(1)
 check(float(game.flow.get("building:5",0))>0,"Generic factory consumes its delivered local ingredients")
 check(float(s.resources.boards)==float(boards) and float(s.resources.dry)==float(dry),"Local production never also consumes warehouse ingredients")
 check(float(UXRules.material_stock(s,"furniture").stored)+float(UXRules.material_stock(s,"furniture").transit)>0,"Result is a real collectable factory output")
 check(game.production_status(5).contains("Läuft") and ProductionPresentation.describe(game,5).kind=="running","Status and visual workers use the same local inventory")
 # Resume through the real save migration, including queued requests and cargo.
 s.buildings[5].paused=true
 s.resources.boards=20
 s.resources.dry=20
 s.buildings[5].paused=false
 game.request_material(5)
 var saved=JSON.parse_string(JSON.stringify(s))
 game.restore(saved)
 var restored=game.state
 check(restored.hub.inputs==saved.hub.inputs and restored.hub.requests==saved.hub.requests and restored.hub.shipments==saved.hub.shipments,"JSON save/restore keeps physical stock, orders and in-flight cargo")
 check(not game.start_delivery(),"Switching production modes waits for existing input trucks to return")
 # Missing stock queues without creating cargo or goods, then dispatches later.
 s=company()
 result=game.request_material(5)
 check(s.hub.shipments.is_empty() and s.hub.requests.size()==2 and result.contains("fehlend/reserviert"),"Missing warehouse stock creates explicit pending ingredient orders")
 s.resources.boards=8
 s.resources.dry=8
 for tick in 420: game.step(1)
 check(float(s.hub.outputs.get("5",{}).get("furniture",0))+float(s.resources.furniture)>0,"Queued request automatically launches after stock becomes available")
 check(CentralLogistics.available_trucks(s)>=0,"Continuous resupply respects the shared dedicated fleet")
 # Continuous local manufacture preserves the actual stock balance.
 s=company()
 s.resources.dry=60
 s.resources.boards=60
 game.request_material(5)
 for tick in 700: game.step(1)
 var balance=0.0
 for material in {"boards":2,"dry":4,"furniture":10}:
  var amounts=UXRules.material_stock(s,material)
  balance+=(float(amounts.stored)+float(amounts.transit))*{"boards":2,"dry":4,"furniture":10}[material]
 check(absf(balance-360)<0.00001,"Auto-replenishment, real transport and local processing neither duplicate nor lose material")
 # A new workshop command must target that workshop, even with older orders.
 s=company()
 s.resources.dry=60
 s.resources.boards=60
 s.resources.wood=60
 s.buildings[1].paused=false
 game.request_material(5)
 game.request_material(1)
 check(s.hub.shipments.size()==2 and int(s.hub.shipments[1].destination)==1,"An immediate request prioritizes the selected workshop rather than an older unrelated order")
 # Delivery-line requests share its existing reservation and transport owner.
 s=company(true)
 s.resources.wood=40
 result=game.request_material(1)
 check(s.delivery.shipments.size()==1 and s.hub.shipments.is_empty(),"Selected wood line uses its existing real transport owner")
 trip=s.delivery.shipments[0]
 check(float(s.delivery.buffers.sawmill.wood)==0 and float(s.resources.wood)==40-float(trip.amount),"Selected sawmill cannot consume manually requested cargo early")
 for press in 10: game.request_material(1)
 check(DeliveryChain.reserved(s.delivery,"sawmill","wood")<=DeliveryChain.capacity(s,"sawmill"),"Manual and automatic delivery share the same input capacity")
 s.delivery.paused=true
 var copy=s.duplicate(true)
 result=game.request_material(1)
 check(s==copy and result.contains("pausiert"),"Paused line requests explain the block without reserving any goods")
 s.delivery.paused=false
 check(game.stop_delivery() and s.hub.requests.is_empty(),"Closing the line cancels unallocated orders and preserves existing refund behavior")
 # Requests validate roads before adopting local logistics.
 s=company()
 s.buildings[5].position=[900,900]
 copy=s.duplicate(true)
 result=FactorySupply.request(s,5)
 check(s==copy and result.contains("Straßenverbindung"),"Disconnected workshops do not lose stock or acquire phantom reservations")
 s=company()
 s.buildings[6].paused=true
 copy=s.duplicate(true)
 result=FactorySupply.request(s,5)
 check(s==copy and result.contains("Zentrallager pausiert"),"A paused central depot does not launch requested trucks")
 # Stone requests also take the real central route instead of an ornamental trip.
 s=company()
 s.buildings[5].paused=true
 s.buildings.append({"kind":"quarry","level":1,"paused":true,"position":[28,-52]})
 s.buildings.append({"kind":"stoneworks","level":1,"paused":false,"position":[-20,-12]})
 StoneIndustry.synchronize(s)
 StoneIndustry.site(s,7).stock.rock=12.0
 result=game.request_material(8)
 check(result.contains("angefordert") and FactorySupply.managed(s,8),"Stoneworks requests missing raw rock through the central depot")
 var saw_pickup=false
 var saw_delivery=false
 for tick in 600:
  game.step(1)
  for haul in s.hub.shipments:
   if haul.key=="rock" and haul.target=="central": saw_pickup=true
   if haul.key=="rock" and haul.target=="factory": saw_delivery=true
 check(saw_pickup and saw_delivery,"Rock is physically collected into central stock then trucked to the requested works")
 var stone=UXRules.material_stock(s,"stone")
 check(float(stone.stored)+float(stone.transit)>0,"Requested stoneworks actually processes delivered material")
 # Untouched generic factories retain the compatible legacy mode.
 s=company()
 s.resources.dry=4
 s.resources.boards=4
 game.step(1)
 check(not FactorySupply.managed(s,5) and float(game.flow.get("building:5",0))>0,"Existing unrequested factories keep working without migration or forced stock loss")
 await process_frame
 await process_frame
 print("FACTORY SUPPLY 286: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
