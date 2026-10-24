class_name SawmillProduction
extends RefCounted

const STAGES=["Entrinden","Sägen","Hobeln"]

static func initial() -> Dictionary: return {"sites":{}}
static func line_limit(level: int) -> int: return 3 if level>=7 else 2 if level>=4 else 1
static func line_count(state: Dictionary,index: int) -> int:
 return clampi(int(state.buildings[index].get("saw_lines",1)),1,line_limit(int(state.buildings[index].level)))
static func site(state: Dictionary,index: int) -> Dictionary:
 var key=str(index)
 if not state.sawmills.sites.has(key): state.sawmills.sites[key]={"lanes":[],"cursor":0,"completed":0.0}
 var data=state.sawmills.sites[key]
 while data.lanes.size()<line_count(state,index): data.lanes.append({"queues":[0.0,0.0,0.0],"work":[0.0,0.0,0.0]})
 return data
static func pending(state: Dictionary,index: int) -> float:
 var amount=0.0
 for lane in state.get("sawmills",{}).get("sites",{}).get(str(index),{}).get("lanes",[]):
  for quantity in lane.queues: amount+=float(quantity)
 return amount
static func pending_total(state: Dictionary) -> float:
 var result=0.0
 for id in state.get("sawmills",{}).get("sites",{}): result+=pending(state,int(id))
 return result
static func intake_room(state: Dictionary,index: int,rate: float) -> float:
 var result=0.0
 for lane in site(state,index).lanes: result+=maxf(0,maxf(2,rate*2)-float(lane.queues[0]))
 return result
static func accept(state: Dictionary,index: int,cycles: float,rate: float) -> void:
 var data=site(state,index)
 var rooms=[]
 var total=0.0
 for lane in data.lanes:
  var room=maxf(0,maxf(2,rate*2)-float(lane.queues[0]))
  rooms.append(room); total+=room
 for i in data.lanes.size(): data.lanes[i].queues[0]+=cycles*rooms[i]/maxf(total,0.000001)

# Every queue owns raw-wood equivalents until the final pass completes. There
# is no usable board, sawdust income or construction credit before that handoff.
static func advance(state: Dictionary,index: int,delta: float,rate: float,room: float) -> Dictionary:
 var data=site(state,index)
 var result={"finished":0.0,"working":0.0}
 for lane in data.lanes:
  lane.work=[0.0,0.0,0.0]
  if state.buildings[index].get("paused",false) or (DeliveryChain.owns(state,index) and state.delivery.paused): continue
  var budget=rate*maxf(0,delta)
  var finished=minf(float(lane.queues[2]),minf(budget,maxf(0,room-float(result.finished))))
  lane.queues[2]-=finished; lane.work[2]=finished; result.finished+=finished
  for stage in [1,0]:
   var capacity=maxf(2,rate*2)
   var moved=minf(float(lane.queues[stage]),minf(budget,maxf(0,capacity-float(lane.queues[stage+1]))))
   lane.queues[stage]-=moved; lane.queues[stage+1]+=moved; lane.work[stage]=moved
  for work in lane.work: result.working=maxf(float(result.working),float(work)/maxf(0.001,delta))
 data.completed+=float(result.finished)
 return result
static func status(state: Dictionary,index: int) -> String:
 var data=state.sawmills.sites.get(str(index),{})
 var sums=[0.0,0.0,0.0]
 for lane in data.get("lanes",[]):
  for i in 3: sums[i]+=float(lane.queues[i])
 return "%s/%s Fertigungslinien · Entrinden %s · Sägen %s · Hobeln %s\n%s Holz in Verarbeitung · %s fertige Bretter seit Umbau" % [line_count(state,index),line_limit(int(state.buildings[index].level)),Catalog.number(sums[0]),Catalog.number(sums[1]),Catalog.number(sums[2]),Catalog.number(pending(state,index)*2),Catalog.number(float(data.get("completed",0)))]
