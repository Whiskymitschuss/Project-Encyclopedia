class_name YardRoutes
extends RefCounted

# Work-cell traffic uses the perimeter aisle. The central saw/conveyor and
# buffer stacks are never crossed by a straight diagonal forklift shortcut.
const CORNERS=[Vector3(-8.5,0.6,-10),Vector3(8.5,0.6,-10),Vector3(8.5,0.6,9.5),Vector3(-8.5,0.6,9.5)]

static func port(point: Vector3) -> Dictionary:
 var best=INF
 var result={}
 for i in 4:
  var a: Vector3=CORNERS[i]
  var b: Vector3=CORNERS[(i+1)%4]
  var at=Geometry3D.get_closest_point_to_segment(point,a,b)
  if at.distance_squared_to(point)<best:
   best=at.distance_squared_to(point)
   result={"point":at,"edge":i}
 return result

static func route(a: Vector3,b: Vector3) -> Array:
 var start=port(a)
 var end=port(b)
 if start.edge==end.edge: return [a,start.point,end.point,b]
 var forward=[a,start.point]
 var reverse=[a,start.point]
 var edge=int(start.edge)
 while edge!=int(end.edge):
  edge=(edge+1)%4
  forward.append(CORNERS[edge])
 forward.append(end.point); forward.append(b)
 edge=int(start.edge)
 while edge!=int(end.edge):
  reverse.append(CORNERS[edge])
  edge=posmod(edge-1,4)
 reverse.append(end.point); reverse.append(b)
 return forward if length(forward)<=length(reverse) else reverse

static func length(path: Array) -> float:
 var result=0.0
 for i in range(1,path.size()): result+=path[i-1].distance_to(path[i])
 return result

static func sample(path: Array,fraction: float) -> Dictionary:
 var along=length(path)*clampf(fraction,0,1)
 for i in range(1,path.size()):
  var distance=path[i-1].distance_to(path[i])
  if distance>0.0001 and along<=distance:
   return {"position":path[i-1].lerp(path[i],along/distance),"direction":path[i]-path[i-1]}
  along-=distance
 return {"position":path[-1],"direction":path[-1]-path[-2]}
