extends Control
signal chosen(kind: String,index: int)
var filter="Alles"
var markers=[]
var press=Vector2.ZERO
func _ready() -> void:
 custom_minimum_size=Vector2(0,340)
 mouse_filter=Control.MOUSE_FILTER_STOP
 resized.connect(queue_redraw)
func map_point(at: Vector3) -> Vector2:
 return Vector2((at.x+320)/640.0*size.x,(at.z+280)/560.0*size.y)
func _draw() -> void:
 markers.clear()
 draw_style_box(load("res://UI/SculptedSurface.gd").create(Color("5c9973"),14),Rect2(Vector2.ZERO,size))
 var water=PackedVector2Array()
 for x in range(-320,321,8): water.append(map_point(Vector3(x,0,ValleyLandscape.river_z(x))))
 draw_polyline(water,Color("65cad8"),maxf(3,size.y*0.022),true)
 draw_circle(map_point(Vector3(235,0,239)),size.x*0.042,Color("65cad8"))
 for district in 2:
  var side=1 if district==0 else -1
  var a=map_point(Vector3(side*212,0,-144))
  var b=map_point(Vector3(side*288,0,136))
  var rect=Rect2(Vector2(minf(a.x,b.x),a.y),Vector2(absf(b.x-a.x),b.y-a.y))
  if int(Game.state.town.districts)<=district:
   draw_rect(rect,Color("334e58"))
   draw_string(ThemeDB.fallback_font,rect.position+Vector2(3,18),"ZU",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("fff0ca"))
  else: draw_rect(rect,Color("c2d78c"),false,1)
  markers.append({"kind":"district","index":district,"point":rect.get_center(),"rect":rect})
 for x in [-80,0,80]: draw_line(map_point(Vector3(x,0,-172)),map_point(Vector3(x,0,180)),Color("b2beb0"),2)
 for z in Placement.ROADS: draw_line(map_point(Vector3(-80,0,z)),map_point(Vector3(80,0,z)),Color("b2beb0"),2)
 for road in Game.state.town.roads:
  var points=PackedVector2Array()
  for cell in road.cells: points.append(map_point(TownRules.point(TownRules.cell(cell))))
  draw_polyline(points,Color("e9d2a1") if road.kind=="path" else Color("c2cdd0"),1 if road.kind=="path" else 2,true)
 if filter!="Bau":
  for i in 10:
   var p=map_point(Catalog.biome_position(i))
   var opened=i<int(Game.state.unlocked)
   draw_circle(p,6,Color("c5da85") if opened else Color("304f5b"))
   draw_string(ThemeDB.fallback_font,p+Vector2(-3,4),str(i+1),HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("fff2ce"))
   markers.append({"kind":"biome","index":i,"point":p})
 for i in Game.city_plot_count():
  var p=map_point(Game.plot_position(i))
  draw_rect(Rect2(p-Vector2(3,3),Vector2(6,6)),Color("a9c990"),false,1)
  markers.append({"kind":"plot","index":i,"point":p})
 for city in [false,true]:
  var records=Game.state.homes if city else Game.state.buildings
  for i in records.size():
   var p=map_point(Game.home_position(i) if city else Game.building_position(i))
   var tone=Color("f1c56b") if city else Color("7ed6e5")
   draw_rect(Rect2(p-Vector2(4,4),Vector2(8,8)),tone)
   if city: draw_line(p+Vector2(-4,-4),p+Vector2(0,-7),tone,2)
   markers.append({"kind":"home" if city else "building","index":i,"point":p})
 for i in Game.state.jobs.size():
  var p=map_point(ConstructionRules.job_position(Game.state,Game.state.jobs[i]))
  draw_circle(p,5,Color("f6a56b"))
  draw_line(p-Vector2(3,3),p+Vector2(3,3),Color("483f38"),2)
  markers.append({"kind":"job","index":i,"point":p})
 if filter=="Logistik":
  for s in Game.state.delivery.shipments+Game.state.construction_shipments+Game.state.stone.shipments:
   var points=PackedVector2Array()
   for p in s.path: points.append(map_point(LogisticsRoutes.vector(p)))
   if points.size()>1: draw_polyline(points,Color("fff6cf"),1,true)
 for group in Game.state.ux.groups:
  var a=map_point(Vector3(float(group.bounds[0]),0,float(group.bounds[1])))
  var b=map_point(Vector3(float(group.bounds[0])+float(group.bounds[2]),0,float(group.bounds[1])+float(group.bounds[3])))
  draw_rect(Rect2(a,b-a),Color("ffe08a"),false,2)
func select_at(point: Vector2) -> void:
 var best={}
 var distance=15.0
 for marker in markers:
  if marker.kind=="district": continue
  var d=point.distance_to(marker.point)
  if d<=distance: distance=d; best=marker
 if not best.is_empty(): chosen.emit(best.kind,int(best.index)); return
 for marker in markers:
  if marker.kind=="district" and marker.rect.has_point(point): chosen.emit("district",int(marker.index)); return
func _gui_input(event: InputEvent) -> void:
 if event is InputEventScreenTouch:
  if event.pressed: press=event.position
  elif not event.canceled and event.position.distance_to(press)<12: select_at(event.position)
  accept_event()
 elif event is InputEventMouseButton and event.device!=InputEvent.DEVICE_ID_EMULATION and event.button_index==MOUSE_BUTTON_LEFT:
  if event.pressed: press=event.position
  elif event.position.distance_to(press)<12: select_at(event.position)
  accept_event()
