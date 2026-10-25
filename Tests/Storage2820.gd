extends SceneTree
var game
var checks=0
var failures=[]
func _initialize(): call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok: failures.append(message);printerr("FAILED: ",message)
func fresh(center: bool=true) -> Dictionary:
 game.state=game.initial_state()
 var s=game.state
 s.workers=0;s.auto_export=false;s.city_services.enabled=false;s.reserve=false;s.coins=10000000;s.company_xp=220
 if center:s.buildings.append({"kind":"central_depot","level":1,"paused":false,"position":[44,20]})
 return s
func run():
 await process_frame
 game=root.get_node("Game");game.set_process(false)
 var s=fresh(false)
 check(game.capacity()==1000,"Starter company has 1,000 finite places per material")
 s=fresh()
 check(game.capacity()==2500,"A level-one depot adds 1,500 real places per material")
 var before=s.resources.duplicate(true)
 s.buildings[2].level=2
 check(game.capacity()==3000 and s.resources==before,"A warehouse upgrade expands capacity without granting stock")
 s.buildings[2].level=5000;s.buildings[5].level=5000
 check(game.capacity()==55500,"Capacity contributions cannot exceed the catalog's finite building levels")
 s=fresh()
 for key in Catalog.RESOURCES:
  s.resources[key]=game.capacity()-1
  game.add_resource(key,30)
  check(s.resources[key]==game.capacity(),"Positive receipts obey the material shelf: "+key)
  game.add_resource(key,0)
  check(s.resources[key]==game.capacity(),"A zero receipt changes no owned material: "+key)
 # Every already loaded arrival books the same shelf, including old mineral
 # trucks and multiple centers. Goods are not counted as available before unload.
 s=fresh()
 s.resources.boards=game.capacity()-10
 var source=CentralLogistics.stock(s,1);source.boards=30.0
 check(CentralLogistics.launch(s,1,5,"boards",10,"central",source),"A fitting pickup books the last ten shelf places")
 check(CentralLogistics.storage_room(s,"boards")==0,"Road cargo reserves physical shelf capacity")
 game.add_resource("boards",50)
 check(s.resources.boards==game.capacity()-10,"A direct receipt cannot steal an incoming load's reservation")
 check(not CentralLogistics.launch(s,1,5,"boards",1,"central",source) and source.boards==20,"A second pickup cannot overbook or withdraw goods")
 s.buildings.append({"kind":"central_depot","level":1,"position":[-44,52]})
 s.resources.boards=game.capacity()-10
 check(CentralLogistics.storage_room(s,"boards")==0,"All central yards share the same shelf reservations")
 s.resources.boards=game.capacity()-20
 var second_depot=s.buildings.size()-1
 check(CentralLogistics.launch(s,1,second_depot,"boards",10,"central",source),"A second yard books only the remaining shared shelf")
 check(CentralLogistics.storage_room(s,"boards")==0,"Bookings to another yard cannot bypass the company limit")
 CentralLogistics.tick(s,300)
 check(s.resources.boards==game.capacity() and s.hub.shipments.is_empty(),"Both reserved loads unload once and release their trucks")
 check(StorageLimits.central_status(s,"boards").contains("VOLL"),"The full shelf has an explicit visible stop reason")
 s=fresh(false)
 s.resources.stone=game.capacity()-10
 s.stone.shipments=[{"destination":-1,"key":"stone","amount":10.0,"arrived":false}]
 check(CentralLogistics.storage_room(s,"stone")==0,"Legacy mineral freight books the same central shelf")
 var coins=s.coins
 check(not game.buy_stone_material("stone",1) and s.coins==coins,"A blocked stone purchase charges no money and cannot steal road space")
 s=fresh()
 s.resources.nuts=game.capacity()-5;s.hub.receiving.nuts=5.0
 coins=s.coins
 check(not game.buy_hardware("nuts",1) and s.coins==coins,"Paid hardware cannot overbook receiving stock")
 s.resources.nuts-=1
 check(game.buy_hardware("nuts",1) and s.resources.nuts==game.capacity()-5,"Only genuinely free hardware space can be purchased")
 # A loaded old line truck waits at its occupied destination instead of
 # pushing stock over the maximum, then unloads exactly once after consumption.
 s=fresh(false)
 s.buildings.append({"kind":"furniture","level":1,"position":[-20,-12]})
 DeliveryChain.start(s);s.delivery.paused=true
 var cap=DeliveryChain.capacity(s,"sawmill")
 s.delivery.buffers.sawmill.wood=cap
 s.delivery.shipments=[{"id":99,"source":"station","target":"sawmill","key":"wood","amount":2.0,"mode":"truck","age":0.0,"load":2.0,"drive":2.0,"unload":2.0,"travel":6.0,"total":10.0,"arrived":false,"path":[[0,0,0],[1,0,0]]}]
 var trip=s.delivery.shipments[0]
 DeliveryChain.tick(s,20,{})
 check(not trip.arrived and s.delivery.buffers.sawmill.wood==cap,"A restored full factory waits with cargo still on its truck")
 s.delivery.buffers.sawmill.wood-=2
 DeliveryChain.tick(s,1,{})
 check(trip.arrived and s.delivery.buffers.sawmill.wood==cap,"Freeing space allows the same cargo to unload")
 DeliveryChain.tick(s,20,{})
 check(s.delivery.buffers.sawmill.wood==cap and s.delivery.shipments.is_empty(),"Returning line trucks never duplicate cargo")
 # A previous over-capacity save is not a license for more goods and never
 # causes negative transfers from a central shelf back into a local buffer.
 s=fresh(false)
 s.buildings.append({"kind":"furniture","level":1,"position":[-20,-12]})
 DeliveryChain.start(s)
 s.resources.boards=game.capacity()+50
 s.delivery.buffers.sawmill.boards=3
 var wood_before=s.delivery.buffers.sawmill.wood
 check(game.unload_delivery("sawmill")==0 and s.resources.boards==game.capacity()+50 and s.delivery.buffers.sawmill.boards==3 and s.delivery.buffers.sawmill.wood==wood_before,"Legacy surplus is retained without a negative unload or duplicated local goods")
 game.add_resource("boards",20)
 check(s.resources.boards==game.capacity()+50 and StorageLimits.central_status(s,"boards").contains("Überbestand"),"An over-cap save accepts no fresh receipt and is clearly labelled")
 var saved=JSON.parse_string(JSON.stringify(s,"",true,true))
 game.restore(saved);s=game.state
 check(s.resources.boards==game.capacity()+50 and s.delivery.buffers.sawmill.boards==3,"Saving and restoring preserve all previous surplus")
 # Express shelves and generic inputs/outputs remain finite and independent.
 s=fresh()
 s.buildings.append({"kind":"express","level":1,"position":[-44,116]})
 var express=s.buildings.size()-1
 CentralLogistics.stock(s,express,true).dry=96
 s.resources.dry=100
 check(not CentralLogistics.launch(s,5,express,"dry",1,"express",s.resources) and s.resources.dry==100,"A full express rejects another speculative load")
 check(DepotNetwork.room(s,express,"wood")==96,"A full dry-material shelf does not block the express wood shelf")
 s.buildings[express].level=9999
 check(DepotNetwork.capacity(s,express)==312,"An express has at most 312 places per material at catalog level ten")
 s=fresh()
 s.buildings.append({"kind":"kiln","level":1,"paused":false,"position":[21,52]})
 var kiln=s.buildings.size()-1
 for b in s.buildings:b.paused=true
 s.buildings[kiln].paused=false
 LogisticsDispatch.synchronize(s)
 for key in Catalog.RESOURCES:s.resources[key]=game.capacity()
 var output=CentralLogistics.stock(s,kiln)
 output.dry=CentralLogistics.output_capacity(s,kiln)
 FactorySupply.stock(s,kiln).boards=FactorySupply.capacity(s,kiln)
 var output_before=output.dry
 var input_before=FactorySupply.stock(s,kiln).boards
 for second in 180:game.step(1)
 check(output.dry==output_before and FactorySupply.stock(s,kiln).boards==input_before,"A full factory output pauses production without consuming its inputs")
 check(s.hub.shipments.is_empty(),"No pickup starts into completely full depots")
 for key in Catalog.RESOURCES:check(s.resources[key]<=game.capacity()+0.00001,"Idle/offline ticks respect the shelf maximum: "+key)
 s.resources.dry-=20;s.buildings[5].paused=false
 for second in 180:game.step(1)
 check(s.resources.dry>game.capacity()-20 and float(output.dry)+float(s.resources.dry)>output_before+game.capacity()-20,"Consumption resumes pickup and real production automatically")
 check(output.dry<=CentralLogistics.output_capacity(s,kiln)+0.00001 and s.resources.dry<=game.capacity()+0.00001,"Resumed production still respects local and central maxima")
 check(StorageLimits.network_capacity(s,"dry")==game.capacity()+CentralLogistics.output_capacity(s,kiln),"The total-stock denominator includes the actual local output shelf once")
 print("STORAGE 2820: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
