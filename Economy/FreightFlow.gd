class_name FreightFlow
extends RefCounted

# Reserve departure times, never stop another truck in an intersection.
# Every truck has a finite complete out-and-back slot, so there is no cycle
# of mutual waiting. Queued cargo remains owned by its assigned depot truck.
const GAP=3.0
static var geometry={}

static func all_trips(state: Dictionary) -> Array:
 return state.delivery.shipments+state.construction_shipments+state.stone.shipments+state.trade.shipments

static func segments(path: Array) -> Array:
 var key=hash(path)
 if geometry.has(key) and geometry[key].path==path: return geometry[key].segments
 var points=[]
 for raw in path:
  var p=LogisticsRoutes.vector(raw)
  if not points.is_empty() and p.distance_to(points.back())<0.001: continue
  if points.size()>=2:
   if (points[-1]-points[-2]).normalized().dot((p-points[-1]).normalized())>0.9999: points.pop_back()
  points.append(p)
 var result=[]
 var length=LogisticsRoutes.length(path)
 var along=0.0
 for i in range(1,points.size()):
  var a: Vector3=points[i-1]
  var b: Vector3=points[i]
  var distance=a.distance_to(b)
  result.append({"a":Vector2(a.x,a.z),"b":Vector2(b.x,b.z),"start":along/maxf(length,0.001),"end":(along+distance)/maxf(length,0.001)})
  along+=distance
 if geometry.size()>=128: geometry.clear()
 geometry[key]={"path":path.duplicate(true),"segments":result}
 return result

static func legs(trip: Dictionary) -> Array:
 var result=[]
 var drive=float(trip.get("drive",trip.travel))
 for segment in segments(trip.path):
  result.append({"a":segment.a,"b":segment.b,"start":float(trip.get("load",0))+segment.start*drive,"end":float(trip.get("load",0))+segment.end*drive})
  result.append({"a":segment.b,"b":segment.a,"start":float(trip.travel)+(1-segment.end)*drive,"end":float(trip.travel)+(1-segment.start)*drive})
 return result

static func at(leg: Dictionary, fraction: float) -> float:
 return lerpf(float(leg.start),float(leg.end),fraction)

static var window_cache={}
static func windows(ours: Dictionary,theirs: Dictionary) -> Array:
 var source=[ours.path,float(ours.get("drive",ours.travel)),float(ours.get("load",0)),float(ours.travel)]
 var peer=[theirs.path,float(theirs.get("drive",theirs.travel)),float(theirs.get("load",0)),float(theirs.travel)]
 var key=hash([source,peer])
 if window_cache.has(key) and window_cache[key].source==source and window_cache[key].peer==peer: return window_cache[key].windows
 var intervals=[]
 for a in legs(ours):
  for b in legs(theirs):
   var u: Vector2=a.b-a.a
   var v: Vector2=b.b-b.a
   var relative: Vector2=b.a-a.a
   var cross=u.cross(v)
   if absf(cross)>0.001:
    var x=relative.cross(v)/cross
    var y=relative.cross(u)/cross
    if x>=0 and x<=1 and y>=0 and y<=1:
     var center=at(b,y)-at(a,x)
     intervals.append(Vector2(center-GAP,center+GAP))
   elif u.length_squared()>0.001 and v.length_squared()>0.001 and u.normalized().dot(v.normalized())>0.99 and absf(relative.cross(u.normalized()))<=0.5:
    var start=maxf(0,relative.dot(u)/u.length_squared())
    var end=minf(1,(b.b-a.a).dot(u)/u.length_squared())
    if start>end: continue
    var differences=[]
    for x in [start,end]:
     var y=clampf((a.a+u*x-b.a).dot(v)/v.length_squared(),0,1)
     differences.append(at(b,y)-at(a,x))
    intervals.append(Vector2(minf(differences[0],differences[1])-GAP,maxf(differences[0],differences[1])+GAP))
 intervals.sort_custom(func(a,b): return a.x<b.x)
 var merged=[]
 for interval in intervals:
  if not merged.is_empty() and interval.x<=merged.back().y: merged[-1].y=maxf(merged.back().y,interval.y)
  else: merged.append(interval)
 if window_cache.size()>=256: window_cache.clear()
 window_cache[key]={"source":source.duplicate(true),"peer":peer.duplicate(true),"windows":merged}
 return merged

static func enqueue(state: Dictionary, fleet: Array, trip: Dictionary) -> void:
 var occupied=[]
 for other in all_trips(state):
  var clock=float(other.get("depart_in",0))-float(other.age)
  for interval in windows(trip,other):
   if interval.y+clock>=0: occupied.append(interval+Vector2.ONE*clock)
 occupied.sort_custom(func(a,b): return a.x<b.x)
 var delay=0.0
 for interval in occupied:
  if delay>interval.x-0.001 and delay<interval.y+0.001: delay=interval.y+0.01
 trip.depart_in=delay
 fleet.append(trip)

static func advance(trip: Dictionary,delta: float) -> void:
 var wait=minf(maxf(0,float(trip.get("depart_in",0))),delta)
 trip.depart_in=maxf(0,float(trip.get("depart_in",0))-wait)
 trip.age=float(trip.age)+delta-wait
