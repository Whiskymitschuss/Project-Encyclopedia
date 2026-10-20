class_name CraftedGeometry
extends RefCounted

# Shared rounded meshes: building instances reuse topology instead of tessellating
# a separate imported model for every facade or upgrade.
static var boxes: Dictionary={}
static var crowns: Dictionary={}
static var slabs: Dictionary={}

static func rounded_slab(size: Vector3,radius: float=0.65) -> ArrayMesh:
 var r=minf(radius,minf(size.x,size.z)*0.45)
 var key=Vector4(size.x,size.y,size.z,r)
 if slabs.has(key): return slabs[key]
 var surface=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 var h=size*0.5
 var points=[]
 for corner in 4:
  var center=[Vector2(h.x-r,h.z-r),Vector2(-h.x+r,h.z-r),Vector2(-h.x+r,-h.z+r),Vector2(h.x-r,-h.z+r)][corner]
  for step in 5:
   var angle=corner*PI/2+step*PI/8
   points.append(center+Vector2(cos(angle),sin(angle))*r)
 for i in points.size():
  var a: Vector2=points[i]
  var b: Vector2=points[(i+1)%points.size()]
  for side in [-1,1]:
   for p in [Vector2.ZERO,a,b] if side>0 else [Vector2.ZERO,b,a]:
    surface.set_normal(Vector3.UP*side)
    surface.set_uv(Vector2(p.x/size.x+0.5,p.y/size.z+0.5))
    surface.add_vertex(Vector3(p.x,h.y*side,p.y))
  var normal=Vector3(b.y-a.y,0,a.x-b.x).normalized()
  for p in [Vector3(a.x,-h.y,a.y),Vector3(b.x,-h.y,b.y),Vector3(a.x,h.y,a.y),Vector3(b.x,-h.y,b.y),Vector3(b.x,h.y,b.y),Vector3(a.x,h.y,a.y)]:
   surface.set_normal(normal)
   surface.set_uv(Vector2(p.x/size.x+0.5,p.y/size.y+0.5))
   surface.add_vertex(p)
 surface.index()
 var mesh=surface.commit()
 if slabs.size()>=256: slabs.clear()
 slabs[key]=mesh
 return mesh

static func rounded_box(size: Vector3,radius: float=0.16) -> ArrayMesh:
 var r=minf(radius,minf(size.x,minf(size.y,size.z))*0.22)
 var key=Vector4(size.x,size.y,size.z,r)
 if boxes.has(key): return boxes[key]
 var h=size*0.5
 var inner=h-Vector3.ONE*r
 var surface=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for axis in 3:
  var u=(axis+1)%3
  var v=(axis+2)%3
  var us=[-h[u],-inner[u],inner[u],h[u]]
  var vs=[-h[v],-inner[v],inner[v],h[v]]
  for side in [-1,1]:
   for row in 3:
    for col in 3:
     # Godot front faces use clockwise winding.
     var order=[Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)] if side>0 else [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,1),Vector2i(0,1)]
     for offset in order:
      var p=Vector3.ZERO
      p[axis]=h[axis]*side
      p[u]=us[col+offset.x]
      p[v]=vs[row+offset.y]
      var core=p.clamp(-inner,inner)
      var normal=(p-core).normalized()
      surface.set_normal(normal)
      surface.set_uv(Vector2((p[u]/size[u])+0.5,(p[v]/size[v])+0.5))
      surface.add_vertex(core+normal*r)
 surface.index()
 var mesh=surface.commit()
 if boxes.size()>=512: boxes.clear()
 boxes[key]=mesh
 return mesh

static func pine_crown(radius: float,height: float) -> ArrayMesh:
 var key=Vector2(radius,height)
 if crowns.has(key): return crowns[key]
 var surface=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 var profile=[Vector2(0,0.38),Vector2(0.08,0.92),Vector2(0.24,1),Vector2(0.48,0.68),Vector2(0.74,0.34),Vector2(1,0.025)]
 for ring in range(profile.size()-1):
  for side in 10:
   for step in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
    var p: Vector2=profile[ring+step.y]
    var angle=(side+step.x)*TAU/10.0
    surface.set_uv(Vector2((side+step.x)/10.0,p.x))
    surface.add_vertex(Vector3(sin(angle)*radius*p.y,(p.x-0.5)*height,cos(angle)*radius*p.y))
 surface.generate_normals()
 surface.index()
 var mesh=surface.commit()
 crowns[key]=mesh
 return mesh
