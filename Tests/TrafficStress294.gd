extends SceneTree
var checks=0
var failures=[]
func check(ok: bool, detail: String):
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func _initialize(): call_deferred("run")
func run():
 await process_frame
 var g=root.get_node("Game")
 g.set_process(false);g.set_block_signals(true)
 var variants=range(16) if "--full" in OS.get_cmdline_user_args() else [0,7,8,15]
 for variant in variants:
  g.restore(g.initial_state())
  g.state.company_xp=800;g.state.coins=1000000;g.state.construction_intro=true;g.state.tutorial=5
  g.state.trucks=8 if variant<8 else 16
  g.state.vehicle=[2,3,4,6][variant%4]
  g.state.workers=17;g.state.builders=3;g.state.unlocked=10
  for kind in ["furniture","prefab","garage","sawmill","sawmill","station","furniture","market","warehouse","kiln","research"]:
   var p=g.free_position(Catalog.industry_position(g.state.buildings.size()))
   g.state.buildings.append({"kind":kind,"level":3,"paused":false,"position":[p.x,p.z]})
  for kind in ["fire","police","clinic","taxi","house","shop","house","shop","house","shop","house","shop"]:
   var i=g.state.homes.size()
   var p=g.free_position(Catalog.home_position(i))
   g.state.homes.append({"kind":kind,"level":3,"plot":i,"position":[p.x,p.z]})
  if variant%8>=4:
   for index in g.state.buildings.size():
    var p=g.state.buildings[index].get("position",[Catalog.industry_position(index).x,Catalog.industry_position(index).z])
    g.state.buildings[index].position=[-float(p[0]),float(p[1])]
   for h in g.state.homes: h.position[0]=-float(h.position[0])
  for key in g.state.resources: g.state.resources[key]=500
  g.start_delivery()
  for index in range(6,14): g.upgrade(index,true)
  for index in range(4,10): g.upgrade_home(index,true)
  CityServices.ignite(g.state,{"type":"home","index":4})
  CityServices.ignite(g.state,{"type":"home","index":5})
  var ages={};var waits={};var captured=false
  for second in 1200:
   g.step(1)
   for domain in [g.state.construction_shipments,g.state.delivery.shipments,g.state.city_services.missions]:
    for t in domain:
     var key=("s" if t.has("outward") else "c" if t.target=="construction" else "d")+str(t.id)
     waits[key]=int(waits.get(key,0))+1 if ages.get(key,-1)==float(t.age) else 0
     ages[key]=float(t.age)
     if waits[key]>=180 and float(t.age)>0.001:
      print("STUCK variant=",variant," second=",second," key=",key," age=",t.age," wait=",t.get("traffic_wait","")," sold=",g.state.delivery.sold)
      for domain2 in [g.state.construction_shipments,g.state.delivery.shipments,g.state.city_services.missions]:
       for x in domain2:
        print(" trip ",x.id," ",x.get("target",x.get("kind",""))," age=",x.age," pos=",TrafficRules.sample(x,x.age,x.has("outward"))," wait=",x.get("traffic_wait",""))
      captured=true;break
    if captured: break
   if captured: break
  check(not captured,"No deployed vehicle is permanently blocked in city variant "+str(variant))
  check(g.state.delivery.sold>5,"Orders keep receiving real furniture during concurrent construction")
  check(g.state.jobs.size()<14,"Real construction completes while the shop operates")
  check(g.state.city_services.fires_extinguished>=2,"Both original incidents are actually extinguished")
  check(g.state.delivery.shipments.size()+g.state.construction_shipments.size()<=int(g.state.trucks),"Both active and queued cargo fit the purchased fleet")
  print("VARIANT ",variant," jobs=",g.state.jobs.size()," sold=",g.state.delivery.sold," extinguished=",g.state.city_services.fires_extinguished," stuck=",captured)
 print("TRAFFIC STRESS 0.29.4: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
