class_name StreetSurface
extends RefCounted

# One union of the actual graph. Junctions and repeated road records never
# create a second coplanar street. Integer rows give exact shared boundaries.
const ROAD_Y=0.74
const WALK_Y=0.90
const PATH_Y=0.57
const PAINT_Y=0.84
static var cache={}

static func merge_intervals(values: Array) -> Array:
 values.sort_custom(func(a,b): return a.x<b.x)
 var result=[]
 for value in values:
  if not result.is_empty() and value.x<=result[-1].y+0.0001: result[-1].y=maxf(result[-1].y,value.y)
  else: result.append(value)
 return result

static func rows_for(cells: Dictionary,radius: int) -> Dictionary:
 var rows={}
 for cell in cells:
  for y in range(cell.y-radius,cell.y+radius+1):
   if not rows.has(y): rows[y]=[]
   rows[y].append(Vector2(cell.x-radius-0.5,cell.x+radius+0.5))
 for y in rows: rows[y]=merge_intervals(rows[y])
 return rows

static func subtract(values: Array,cuts: Array) -> Array:
 var result=[]
 for value in values:
  var cursor=float(value.x)
  for cut in cuts:
   if cut.y<=cursor: continue
   if cut.x>=value.y: break
   if cut.x>cursor: result.append(Vector2(cursor,minf(cut.x,value.y)))
   cursor=maxf(cursor,cut.y)
   if cursor>=value.y: break
  if cursor<value.y: result.append(Vector2(cursor,value.y))
 return result

static func rectangles(rows: Dictionary) -> Array:
 var result=[]
 var active={}
 var ys=rows.keys()
 ys.sort()
 var previous=-100000
 for y in ys:
  if y!=previous+1:
   result.append_array(active.values())
   active={}
  var next={}
  for span in rows[y]:
   var rect=active.get(span,Rect2(Vector2(span.x,y-0.5),Vector2(span.y-span.x,0)))
   rect.size.y+=1
   next[span]=rect
  for span in active:
   if not next.has(span): result.append(active[span])
  active=next
  previous=y
 result.append_array(active.values())
 return result

static func plan(state: Dictionary,plots: Array) -> Dictionary:
 var cells=TownRules.road_cells(state.town)
 var signature=hash([cells,state.town.roads,plots])
 if cache.has(signature): return cache[signature]
 var roads=rows_for(cells,3)
 var outer=rows_for(cells,5)
 var foot_cells={}
 for record in state.town.roads:
  if record.kind=="path":
   for raw in record.cells: foot_cells[TownRules.cell(raw)]=true
 var paths=rows_for(foot_cells,1)
 var walks={}
 for y in outer:
  var cuts=roads.get(y,[]).duplicate()
  for plot in plots:
   if y+0.5>plot.position.y and y-0.5<plot.end.y: cuts.append(Vector2(plot.position.x-0.1,plot.end.x+0.1))
  walks[y]=subtract(outer[y],merge_intervals(cuts))
 for y in paths: paths[y]=subtract(paths[y],roads.get(y,[]))
 var data={"roads":rectangles(roads),"walks":rectangles(walks),"paths":rectangles(paths),"cells":cells}
 if cache.size()>=8: cache.clear()
 cache[signature]=data
 return data

static func contains(rectangles_value: Array,point: Vector2) -> bool:
 for rect in rectangles_value:
  if rect.has_point(point): return true
 return false

static func surface(rectangles_value: Array,height: float) -> ArrayMesh:
 if rectangles_value.is_empty(): return null
 var builder=SurfaceTool.new()
 builder.begin(Mesh.PRIMITIVE_TRIANGLES)
 for rect in rectangles_value:
  var a=rect.position
  var b=rect.end
  for point in [a,Vector2(b.x,a.y),Vector2(a.x,b.y),Vector2(b.x,a.y),b,Vector2(a.x,b.y)]:
   builder.set_normal(Vector3.UP)
   builder.set_uv(point/2.0)
   builder.add_vertex(Vector3(point.x,height,point.y))
 builder.index()
 return builder.commit()

static func add_surface(parent: Node3D,rects: Array,height: float,color: Color,finish: String,name_value: String) -> void:
 var mesh=surface(rects,height)
 if mesh==null: return
 var node=MeshInstance3D.new()
 node.name=name_value
 node.mesh=mesh
 node.material_override=SurfaceLibrary.material(color,finish)
 node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 node.set_meta("surface_height",height)
 node.set_meta("rectangles",rects)
 parent.add_child(node)

static func paint(parent: Node3D,ctx: Dictionary) -> void:
 var rects=[]
 for cell in ctx.cells:
  var east=ctx.cells.has(cell+Vector2i(4,0))
  var west=ctx.cells.has(cell-Vector2i(4,0))
  var north=ctx.cells.has(cell-Vector2i(0,4))
  var south=ctx.cells.has(cell+Vector2i(0,4))
  if int(east)+int(west)+int(north)+int(south)!=2: continue
  var close=false
  for junction in ctx.junctions:
   if Vector2(cell).distance_to(junction)<8: close=true; break
  if close or (cell.x+cell.y)%12!=0: continue
  if east and west: rects.append(Rect2(cell.x-1.2,cell.y-0.12,2.4,0.24))
  elif north and south: rects.append(Rect2(cell.x-0.12,cell.y-1.2,0.24,2.4))
 # Crossings occupy the approaches, leaving the turning box unpainted.
 for junction in ctx.junctions:
  for direction in [Vector2i(4,0),Vector2i(-4,0),Vector2i(0,4),Vector2i(0,-4)]:
   if not ctx.cells.has(Vector2i(junction)+direction): continue
   var center=junction+Vector2(direction).normalized()*5.5
   for stripe in 5:
    var offset=(stripe-2)*1.05
    rects.append(Rect2(center.x-0.65,center.y+offset-0.28,1.3,0.56) if direction.x!=0 else Rect2(center.x+offset-0.28,center.y-0.65,0.56,1.3))
 add_surface(parent,rects,PAINT_Y,Color("f1e7c8"),"paint","RoadMarkings")

static func curbs(parent: Node3D,rects: Array) -> void:
 # Split boundary edges at every neighbouring rectangle before cancellation.
 # Only the exposed perimeter receives a vertical kerb; internal seams vanish.
 var horizontal={}
 var vertical={}
 for rect in rects:
  for y in [rect.position.y,rect.end.y]:
   if not horizontal.has(y): horizontal[y]=[]
   horizontal[y].append(Vector2(rect.position.x,rect.end.x))
  for x in [rect.position.x,rect.end.x]:
   if not vertical.has(x): vertical[x]=[]
   vertical[x].append(Vector2(rect.position.y,rect.end.y))
 var builder=SurfaceTool.new()
 builder.begin(Mesh.PRIMITIVE_TRIANGLES)
 var count=0
 for axis in 2:
  var lines=horizontal if axis==0 else vertical
  for coordinate in lines:
   var ends=[]
   for span in lines[coordinate]:
    if not ends.has(span.x): ends.append(span.x)
    if not ends.has(span.y): ends.append(span.y)
   ends.sort()
   for i in ends.size()-1:
    var mid=(ends[i]+ends[i+1])*0.5
    var hits=0
    for span in lines[coordinate]:
     if mid>span.x and mid<span.y: hits+=1
    if hits%2==0: continue
    var a=Vector3(ends[i],WALK_Y,coordinate) if axis==0 else Vector3(coordinate,WALK_Y,ends[i])
    var b=Vector3(ends[i+1],WALK_Y,coordinate) if axis==0 else Vector3(coordinate,WALK_Y,ends[i+1])
    var c=b-Vector3(0,0.36,0)
    var d=a-Vector3(0,0.36,0)
    for point in [a,b,d,b,c,d]: builder.add_vertex(point)
    count+=1
 if count==0: return
 builder.generate_normals()
 var mesh=MeshInstance3D.new()
 mesh.name="Curbs"
 mesh.mesh=builder.commit()
 var finish=Models.material(StreetScape.CURB).duplicate()
 finish.cull_mode=BaseMaterial3D.CULL_DISABLED
 mesh.material_override=finish
 mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 parent.add_child(mesh)

static func build(parent: Node3D,state: Dictionary,ctx: Dictionary) -> void:
 var data=plan(state,ctx.plots)
 var root=Node3D.new()
 root.name="StreetNetwork"
 parent.add_child(root)
 add_surface(root,data.roads,ROAD_Y,StreetScape.ASPHALT,"asphalt","Asphalt")
 add_surface(root,data.walks,WALK_Y,StreetScape.WALK,"paving","Sidewalks")
 curbs(root,data.walks)
 add_surface(root,data.paths,PATH_Y,ProductionCampus.SAND,"plaster","Footpaths")
 paint(root,ctx)
