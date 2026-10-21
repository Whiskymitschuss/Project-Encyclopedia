extends Node3D
# Two incidents maximum; pooled fixed meshes, no particle/light allocation per frame.
var world: Node3D
var scenes={}
var clock=0.0

func create_incident(roof: float) -> Node3D:
 var node=Node3D.new()
 add_child(node)
 var flames=Node3D.new()
 flames.name="Flames"
 flames.position.y=roof-2.0
 node.add_child(flames)
 for i in 6:
  var mesh=Models.cylinder(flames,0.85,3.6,Vector3((i%3-1)*2.0,3.0,(i/3-0.5)*2.4),Color("ff8c37"))
  mesh.mesh.top_radius=0.06
  mesh.material_override=Models.material(Color("ff8c37"),true)
  Models.cylinder(mesh,0.43,2.8,Vector3(0,-0.3,0),Color("ffdd75"))
 var smoke=Node3D.new()
 smoke.name="Smoke"
 smoke.position.y=roof-3.0
 node.add_child(smoke)
 for i in 5:
  sphere(smoke,2.0,Vector3(sin(i*2.0)*1.3,6+i*1.8,cos(i*2.0)),Color("626e78"))
 var crew=Node3D.new()
 crew.name="Crew"
 node.add_child(crew)
 for x in [-2.0,2.0]:
  var person=Node3D.new()
  crew.add_child(person)
  person.position=Vector3(x,0,12)
  Models.box(person,Vector3(0.9,1.2,0.6),Vector3(0,1.3,0),Color("253d55"))
  Models.box(person,Vector3(0.96,0.18,0.65),Vector3(0,1.3,0),Color("f2db70"))
  sphere(person,0.42,Vector3(0,2.2,0),Color("f2db70"))
  for side in [-0.23,0.23]:
   Models.box(person,Vector3(0.32,0.7,0.4),Vector3(side,0.45,0),Color("253d55"))
  Models.box(person,Vector3(0.18,0.18,1.3),Vector3(0,1.5,-0.8),Color("b9d5df"))
 var water=Node3D.new()
 water.name="Water"
 node.add_child(water)
 # Segmented parabolic water jets from the firefighters towards the facade.
 for side in [-2.0,2.0]:
  for i in 8:
   var t=float(i)/8
   var t2=float(i+1)/8
   var a=Vector3(side*(1-t),1.5+(roof-1.5)*t+3*sin(t*PI),11-10*t)
   var b=Vector3(side*(1-t2),1.5+(roof-1.5)*t2+3*sin(t2*PI),11-10*t2)
   var jet=Models.cylinder(water,0.10,a.distance_to(b),(a+b)*0.5,Color("9bdef4"))
   jet.quaternion=Quaternion(Vector3.UP,(b-a).normalized())
 var label=Label3D.new()
 label.name="Status"
 label.position=Vector3(0,roof+13,0)
 label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
 label.font_size=40
 label.pixel_size=0.035
 label.modulate=Color("fff1d5")
 label.outline_size=9
 node.add_child(label)
 return node

func _process(delta: float) -> void:
 clock+=delta
 var present={}
 for incident in Game.state.city_services.get("fires",[]):
  var id=int(incident.id)
  present[id]=true
  if not scenes.has(id):
   var home=Game.state.homes[int(incident.target_ref.index)]
   var roof=TownEvolution.floors(str(home.kind),int(home.level))*2.7+2.0
   scenes[id]=create_incident(roof)
   scenes[id].rotation_degrees.y=int(home.get("rotation",0))
  var node=scenes[id]
  node.position=CityServices.location(Game.state,incident.target_ref)
  var spraying=false
  var progress=float(incident.progress)
  for mission in Game.state.city_services.missions:
   if int(mission.get("fire_id",-1))==id:
    spraying=float(mission.age)>=float(mission.drive) and not mission.served
  node.get_node("Crew").visible=spraying
  node.get_node("Water").visible=spraying
  var motion=bool(Game.state.ux.motion)
  for i in node.get_node("Flames").get_child_count():
   var flame=node.get_node("Flames").get_child(i)
   flame.scale=Vector3.ONE*maxf(0.12,1-progress)*(1+0.12*sin(clock*7+i) if motion else 1.0)
  for i in node.get_node("Smoke").get_child_count():
   var puff=node.get_node("Smoke").get_child(i)
   puff.scale=Vector3.ONE*(0.7+i*0.15)*maxf(0.2,1-progress)
   if motion:
    puff.position.x=sin(clock*0.7+i)*1.5
    puff.position.y=6+fposmod(clock*0.9+i*1.8,10)
   puff.visible=Game.state.quality!=0 or i<2
  node.get_node("Status").text="LÖSCHEN %s %%" % int(progress*100) if spraying else "FEUERWEHR AUF ANFAHRT" if int(incident.mission_id)>=0 else "BRAND · WARTET AUF FEUERWEHR"
  var status=node.get_node("Status")
  var screen=world.camera.unproject_position(node.position+status.position)
  var viewport_size=world.get_viewport().get_visible_rect().size
  status.visible=not world.camera.is_position_behind(node.position+status.position) and screen.y>280 and screen.y<viewport_size.y-210
  node.visible=node.position.distance_to(world.focus)<world.zoom*1.6+40
 for id in scenes.keys():
  if not present.has(id):
   scenes[id].queue_free()
   scenes.erase(id)

func sphere(parent: Node3D, radius: float, at: Vector3, color: Color) -> MeshInstance3D:
 var node=MeshInstance3D.new()
 var mesh=SphereMesh.new()
 mesh.radius=radius
 mesh.height=radius*2
 mesh.radial_segments=10
 mesh.rings=5
 node.mesh=mesh
 node.position=at
 node.material_override=Models.material(color)
 parent.add_child(node)
 return node
