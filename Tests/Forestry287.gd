extends SceneTree
var game
var checks=0
var failures=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok: failures.append(message); printerr("FAILED: ",message)
func company(line: bool=true) -> Dictionary:
 game.state=game.initial_state()
 var s=game.state
 s.workers=17
 s.tool=10
 s.vehicle=3
 s.trucks=0
 s.city_services.enabled=false
 s.auto_export=false
 s.reserve=false
 s.buildings[0].level=7
 s.buildings[1].level=7
 s.buildings.append({"kind":"furniture","level":1,"paused":false,"position":[-20,-12]})
 s.buildings.append({"kind":"central_depot","level":1,"paused":false,"position":[44,20]})
 if line: DeliveryChain.start(s)
 return s
func total(s: Dictionary,key: String) -> float:
 var stock=UXRules.material_stock(s,key)
 return float(stock.stored)+float(stock.transit)
func equivalent(a: Variant,b: Variant) -> bool:
 if (a is int or a is float) and (b is int or b is float): return absf(float(a)-float(b))<0.00000001
 if a is Dictionary and b is Dictionary:
  if a.size()!=b.size(): return false
  for k in a:
   if not b.has(k) or not equivalent(a[k],b[k]): return false
  return true
 if a is Array and b is Array:
  if a.size()!=b.size(): return false
  for i in a.size():
   if not equivalent(a[i],b[i]): return false
  return true
 return a==b
func jammed() -> Dictionary:
 var s=company()
 var source=CentralLogistics.stock(s,0)
 source.wood=120
 s.resources.wood=game.capacity()-54
 for i in 3: CentralLogistics.launch(s,0,6,"wood",18,"central",source)
 # Restored legacy stock may already occupy every slot booked by these trucks.
 s.resources.wood=game.capacity()
 source.wood=120
 return s
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 var s=jammed()
 var original=total(s,"wood")
 for tick in 300: CentralLogistics.tick(s,1)
 check(s.hub.shipments.is_empty() and CentralLogistics.available_trucks(s)==3,"All already loaded pickups unload and return even when the central shelves are full")
 check(s.resources.wood==game.capacity() and s.hub.receiving.wood==54,"Overflow cargo remains real stock in the bounded depot receiving area")
 check(absf(total(s,"wood")-original)<0.000001,"Receiving, shelving and empty returns never duplicate or discard wood")
 check(CentralLogistics.storage_room(s,"wood")==0,"The receiving buffer cannot be exploited to order extra speculative collections")
 var before=s.duplicate(true)
 var snapshot=game.production_status(0)
 check(s==before and snapshot.contains("Zentrallager voll"),"A genuine full storage stop is explained without changing the company")
 s.resources.wood-=10
 CentralLogistics.tick(s,1)
 check(s.resources.wood==game.capacity() and s.hub.receiving.wood==44,"Staged cargo is shelved only into genuinely freed capacity")
 check(absf(total(s,"wood")-(original-10))<0.000001,"Internal shelving cannot credit the same load twice")
 var saved=JSON.parse_string(JSON.stringify(s,"",true,true))
 game.simulate(180)
 var expected=game.state.duplicate(true)
 game.restore(saved)
 game.simulate(180)
 check(equivalent(expected,game.state),"Staged freight, outbound factory supply and harvest replay identically after JSON restoration")
 # The original deadlock must recover production and felling, not just free trucks.
 s=jammed()
 var gathered=float(s.gathered)
 var produced=0.0
 var sold_before=float(s.delivery.sold)
 var max_trucks=0
 for tick in 1800:
  game.step(1)
  produced+=float(game.flow.get("building:1",0))
  max_trucks=maxi(max_trucks,s.hub.shipments.size()+DeliveryChain.central_busy(s))
 check(produced>0 and float(s.delivery.sold)>sold_before,"An empty sawmill resumes processing and completes sales after the fully occupied receiving jam")
 check(float(s.gathered)>gathered,"Real worker harvest resumes after the repaired backlog, without clicking Chop or restarting")
 check(max_trucks<=CentralLogistics.fleet_size(s),"Recovery never creates extra trucks or removes real road assignments")
 # Depositing a backpack must not cause the same deadlock again.
 s=company()
 var output=CentralLogistics.stock(s,0)
 output.wood=18
 s.resources.wood=game.capacity()-18
 CentralLogistics.launch(s,0,6,"wood",18,"central",output)
 s.bag=18
 var all_wood=total(s,"wood")+float(s.bag)
 game.deposit()
 check(s.bag==18 and s.resources.wood==game.capacity()-18,"Manual deposit respects shelf space reserved for the incoming truck")
 check(absf(total(s,"wood")+float(s.bag)-all_wood)<0.000001,"Blocked deposit leaves the backpack and booked load intact")
 # Two stations share the actual harvest; a full first one cannot stop the second.
 s=company(false)
 s.buildings.append({"kind":"station","level":7,"paused":false,"position":[-44,20]})
 s.buildings[1].paused=true
 s.buildings[5].paused=true
 CentralLogistics.stock(s,0).wood=120
 var second=s.buildings.size()-1
 game.step(1)
 check(float(s.gathered)>0 and float(s.hub.outputs.get(str(second),{}).get("wood",0))>0,"A free second collection station accepts real wood when the first one is full")
 check(float(game.flow.get("harvest:%s" % second,0))>0 and float(game.flow.get("harvest:0",0))==0,"Each collection station reports its own accepted yield")
 var result=ForestryFlow.harvest(s,10000,1)
 check(float(result.amount)<=70 and CentralLogistics.output_room(s,second,"wood")>=0,"Harvest never exceeds actual active stations' work rate or output capacity")
 s.buildings[0].paused=true
 s.buildings[second].paused=true
 var stock_before=total(s,"wood")
 result=ForestryFlow.harvest(s,100,1)
 check(result.amount==0 and total(s,"wood")==stock_before,"Explicitly paused collection stations produce no wood")
 s.buildings[0].paused=false
 s.workers=0
 check(ForestryFlow.describe(s,0).text.contains("Keine Holzfäller"),"Missing workers have a clear reason in the actual station status")
 s.workers=17
 s.buildings[0].position=[900,900]
 check(ForestryFlow.describe(s,0).text.contains("Straßenverbindung"),"A full disconnected collection point identifies the missing route")
 # A factory inventory above today's capacity is owned legacy stock, not trash.
 game.state=game.initial_state()
 s=game.state
 s.city_services.enabled=false
 for b in s.buildings: b.paused=true
 s.buildings[0].paused=false
 s.resources.wood=game.capacity()+40
 s.resources.boards=game.capacity()+20
 s.bag=10
 s.workers=1
 game.step(1)
 game.deposit()
 check(s.resources.wood==game.capacity()+40 and s.bag==10 and s.gathered==0,"A full legacy wood stock cannot cause negative harvest or delete backpack/warehouse goods")
 game.add_resource("boards",0)
 check(s.resources.boards==game.capacity()+20,"A zero production award cannot trim a restored surplus")
 s.buildings[0].paused=true
 s.resources.wood=0
 game.step(1)
 check(s.gathered==0 and s.resources.wood==0,"Without the central depot, a paused lone station also halts its harvest")
 # Existing warehouse-only companies still have positive unattended production.
 game.state=game.initial_state()
 game.state.city_services.enabled=false
 game.step(1)
 check(float(game.flow.harvest)>0 and game.state.gathered>0,"A new company still harvests autonomously before a depot exists")
 await process_frame
 print("FORESTRY 287: %s checks, %s failures" % [checks,failures.size()])
 quit(0 if failures.is_empty() else 1)
