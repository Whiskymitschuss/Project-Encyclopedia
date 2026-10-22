class_name TownWorld
extends Node3D

var world: Node3D
var rent_labels: Array = []
var clock = 0.0

func rebuild() -> void:
 for node in get_children():
  remove_child(node)
  node.queue_free()
 rent_labels.clear()
 # All permanent and player-built roads share the canonical surface in World.
 for i in int(Game.state.town.districts):
  var side=1 if i==0 else -1
  Models.label(self,"Ostviertel" if i==0 else "Westviertel",Vector3(side*248,2,-148),36)
 var cells=TownRules.road_cells(Game.state.town)
 var waiting_count=0
 for stop in Game.state.town.stops:
  var at=TownRules.point(TownRules.cell(stop.cell))
  var vertical=cells.has(TownRules.cell(stop.cell)+Vector2i(0,4))
  var shelter=stop_model()
  add_child(shelter)
  shelter.position=at
  shelter.rotation.y=PI/2 if vertical else 0.0
  Models.label(shelter,stop.name,Vector3(0,5,0),25)
  if Game.residents()>0 and waiting_count<(2 if Game.state.quality==0 else 4):
   var person=TimberWorker.new()
   person.role="resident"
   var turn=Basis(Vector3.UP,shelter.rotation.y)
   person.origin_point=at+turn*Vector3(-1.5,0,4.0)
   person.destination=at+turn*Vector3(1.5,0,4.0)
   person.pace=0.35
   person.phase=waiting_count*2.0
   add_child(person)
   waiting_count+=1
 for i in Game.state.town.lines.size():
  var bus=TimberBus.new()
  bus.line_index=i
  add_child(bus)
 for i in Game.state.homes.size():
  if float(Catalog.HOMES[Game.state.homes[i].kind].rent)<=0: continue
  var top=7.0
  for model in world.world_buildings.get_children():
   if model.position.distance_to(Game.home_position(i))<0.1: top=float(model.get_meta("height",10.0)); break
  var label=Models.label(self,"",Game.home_position(i)+Vector3(0,top+2,0),32)
  label.modulate=Color("ffdb64")
  rent_labels.append({"label":label,"index":i})
 refresh_rents()

static func draw_strip(parent: Node3D, at: Vector3, size: Vector3, kind: String) -> void:
 if kind=="asphalt":
  StreetScape.strip(parent,at,size,true,parent.get_meta("street_context",{}))
  return
 var tone=Color(TownRules.TYPES[kind].color)
 Models.box(parent,size+Vector3(0.8,-0.05,0.8),at-Vector3(0,0.08,0),Color("c8d0b4"))
 Models.box(parent,size,at,tone)
 if kind=="asphalt":
  var vertical=size.z>size.x
  var length=size.z if vertical else size.x
  for d in range(-int(length/2)+3,int(length/2)-2,9):
   Models.box(parent,Vector3(0.18,0.03,2.7) if vertical else Vector3(2.7,0.03,0.18),at+Vector3(0,0.14,d) if vertical else at+Vector3(d,0.14,0),Color("f1dfae"))

static func draw_segment(parent: Node3D, a: Vector3, b: Vector3, kind: String) -> void:
 var width=float(TownRules.TYPES[kind].width)
 var size=Vector3(width,0.22,absf(b.z-a.z)+width) if absf(b.z-a.z)>0.1 else Vector3(absf(b.x-a.x)+width,0.22,width)
 draw_strip(parent,(a+b)/2.0+Vector3(0,0.76,0),size,kind)

static func stop_model() -> Node3D:
 var root=Node3D.new()
 Models.box(root,Vector3(8,0.24,2.8),Vector3(0,0.85,5.1),Color("e9d6a6"))
 for x in [-2.9,2.9]: Models.box(root,Vector3(0.2,3.6,0.2),Vector3(x,2.4,5.6),Color("3d8394"))
 Models.box(root,Vector3(6.5,0.3,2.8),Vector3(0,4.2,5.1),Color("f3c75b"))
 Models.box(root,Vector3(5.7,2.5,0.14),Vector3(0,2.6,6.3),Color("82cbd0"))
 load("res://Buildings/CozyProps.gd").bench(root,Vector3(0,0.5,5.3))
 Models.cylinder(root,0.11,4.6,Vector3(4.2,2.8,4.8),Color("3f7b8b"))
 Models.box(root,Vector3(1.3,1.6,0.22),Vector3(4.2,4.4,4.8),Color("f6cc5e"))
 Models.box(root,Vector3(0.7,0.6,0.24),Vector3(4.2,4.4,4.9),Color("39869b"))
 Models.bake(root)
 return root

func refresh_rents() -> void:
 for entry in rent_labels:
  if int(entry.index)>=Game.state.homes.size(): entry.label.hide(); continue
  var amount=float(Game.state.homes[entry.index].get("rent_bank",0))
  var burning=false
  for incident in Game.state.city_services.fires:
   if int(incident.target_ref.index)==int(entry.index): burning=true; break
  entry.label.visible=amount>=1 and world.view_zoom<135 and not burning
  entry.label.text="● %s · ABHOLEN" % Catalog.number(amount)

func tap_rent(screen: Vector2) -> bool:
 var closest=-1
 var distance=32.0
 for entry in rent_labels:
  if not entry.label.visible or world.camera.is_position_behind(entry.label.global_position): continue
  var d=screen.distance_to(world.camera.unproject_position(entry.label.global_position))
  if d<distance: closest=int(entry.index); distance=d
 if closest<0: return false
 var amount=Game.collect_rent(closest)
 if amount>0 and world.hud.get("ux")!=null: world.hud.ux.feedback("build")
 refresh_rents()
 return true

func _process(delta: float) -> void:
 clock+=delta
 if clock>=0.5: clock=0; refresh_rents()
