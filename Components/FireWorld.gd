extends Node3D
# Two incidents maximum; fixed meshes and emitters are created once per incident.
var world: Node3D
var scenes={}
var clock=0.0
var hydrants={}
var protection_signature=[]

func create_incident(roof: float) -> Node3D:
 var node=Node3D.new()
 add_child(node)
 var flames=Node3D.new()
 flames.name="Flames"
 flames.position.y=roof+0.15
 node.add_child(flames)
 for i in 6:
  var flame=card(flames,Vector2(2.4,4.1),Vector3((i%3-1)*2.0,3.0,(i/3-0.5)*2.4),false,i*2.1)
  flame.set_meta("base",flame.position)
 var smoke=Node3D.new()
 smoke.name="Smoke"
 smoke.position.y=roof+0.6
 node.add_child(smoke)
 for i in 5: card(smoke,Vector2(6,6),Vector3(0,2+i*2,0),true,i*4.3)
 var sparks=FeedbackFX.emitter("spark",18)
 sparks.name="Sparks"
 sparks.position.y=roof+2
 node.add_child(sparks)
 var steam=FeedbackFX.emitter("water",18)
 steam.name="WaterMist"
 steam.position.y=roof+1
 node.add_child(steam)
 # One shadowless, tightly bounded light per incident; disabled in battery mode.
 var glow=OmniLight3D.new()
 glow.name="FireGlow"
 glow.position.y=roof
 glow.light_color=Color("ff9d4d")
 glow.omni_range=16
 glow.shadow_enabled=false
 node.add_child(glow)
 var badge=PanelContainer.new()
 badge.name="FireBadge"
 badge.mouse_filter=Control.MOUSE_FILTER_IGNORE
 badge.custom_minimum_size=Vector2(208,62)
 badge.add_theme_stylebox_override("panel",load("res://UI/SculptedSurface.gd").create(Color("183b3d"),12))
 var column=VBoxContainer.new()
 column.add_theme_constant_override("separation",2)
 badge.add_child(column)
 var status=Label.new()
 status.name="Status"
 status.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 status.add_theme_font_size_override("font_size",13)
 status.add_theme_color_override("font_color",Color("fff3d4"))
 column.add_child(status)
 for kind in ["Intensity","Extinguishing"]:
  var meter=ProgressBar.new()
  meter.name=kind
  meter.custom_minimum_size=Vector2(192,5)
  meter.show_percentage=false
  meter.step=0.0
  var fill=StyleBoxFlat.new()
  fill.bg_color=Color("f6a35d") if kind=="Intensity" else Color("94dcd8")
  fill.set_corner_radius_all(3)
  meter.add_theme_stylebox_override("fill",fill)
  var bg=fill.duplicate()
  bg.bg_color=Color("35575a")
  meter.add_theme_stylebox_override("background",bg)
  column.add_child(meter)
 world.hud.add_child(badge)
 node.set_meta("badge",badge)
 node.set_meta("roof",roof)
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
   var jet=Models.cylinder(water,0.045,a.distance_to(b),(a+b)*0.5,Color("9bdef4"))
   jet.quaternion=Quaternion(Vector3.UP,(b-a).normalized())
 return node

func _process(delta: float) -> void:
 clock+=delta
 update_hydrants()
 var present={}
 for incident in Game.state.city_services.get("fires",[]):
  var id=int(incident.id)
  present[id]=true
  if not scenes.has(id):
   var home=Game.state.homes[int(incident.target_ref.index)]
   var roof=TownEvolution.floors(str(home.kind),int(home.level))*2.7+1.15
   if home.kind in ["house","landhouse","villa"]: roof=(1+int((int(home.level)-1)/3.0))*2.7+2.5
   scenes[id]=create_incident(roof)
   scenes[id].rotation_degrees.y=int(home.get("rotation",0))
  var node=scenes[id]
  node.position=CityServices.location(Game.state,incident.target_ref)
  var spraying=false
  var assigned={}
  var progress=float(incident.progress)
  for mission in Game.state.city_services.missions:
   if int(mission.get("fire_id",-1))==id:
    assigned=mission
    spraying=float(mission.age)>=float(mission.drive) and not mission.served
  if not assigned.is_empty():
   var arrival=node.to_local(LogisticsRoutes.vector(assigned.outward[-1]))
   var angle=atan2(arrival.x,arrival.z)
   node.get_node("Crew").rotation.y=angle
   node.get_node("Water").rotation.y=angle
  update_supply_hose(node,assigned,spraying)
  node.get_node("Crew").visible=spraying
  node.get_node("Water").visible=spraying
  var motion=bool(Game.state.ux.motion)
  var nearby=node.position.distance_to(world.view_focus)<world.view_zoom*1.6+40
  var particles_allowed=motion and Game.state.ambient_enabled and nearby
  var sparks=node.get_node("Sparks")
  var mist=node.get_node("WaterMist")
  var count=6 if Game.state.quality==0 else 18
  for emitter in [sparks,mist]:
   if emitter.amount!=count: emitter.amount=count
  sparks.gravity=sparks.global_basis.inverse()*(Atmosphere.wind(Game.state)*0.8+Vector3.UP*0.3)
  sparks.emitting=particles_allowed and progress<0.9
  sparks.visible=sparks.emitting
  mist.emitting=particles_allowed and spraying
  mist.visible=mist.emitting
  var glow=node.get_node("FireGlow")
  glow.visible=nearby and Game.state.quality>0
  glow.light_energy=(1-progress)*(0.8+0.1*sin(clock*5) if motion else 0.8)
  for jet in node.get_node("Water").get_children():
   jet.scale.x=1+0.12*sin(clock*13) if motion else 1.0
   jet.scale.z=jet.scale.x
  var strength=FireSafety.intensity(incident)
  for i in node.get_node("Flames").get_child_count():
   var flame=node.get_node("Flames").get_child(i)
   var flicker=1+0.1*sin(clock*6+i*2.3) if motion else 1.0
   flame.scale=Vector3(0.6+strength*0.4,maxf(0.06,strength)*flicker,1)
   flame.position.y=2.05*flame.scale.y
   flame.material_override.set_shader_parameter("clock",clock if motion else 0.0)
   flame.material_override.set_shader_parameter("opacity",minf(1,strength*2.5))
  for i in node.get_node("Smoke").get_child_count():
   var puff=node.get_node("Smoke").get_child(i)
   var rise=fposmod(clock*1.3+i*2.8,14) if motion else 2.0+i*2.1
   var drift=node.global_basis.inverse()*Atmosphere.wind(Game.state)*rise*0.4
   puff.position=Vector3(drift.x+sin(i*2.4)*0.7,1.5+rise,drift.z)
   puff.scale=Vector3.ONE*(0.4+rise*0.09)*(0.7+strength*0.3)
   puff.material_override.set_shader_parameter("clock",clock*0.25 if motion else 0.0)
   puff.material_override.set_shader_parameter("opacity",smoothstep(0,2,rise)*(1-smoothstep(8,14,rise))*maxf(0.2,1-progress*0.7))
   puff.material_override.set_shader_parameter("cooling",progress)
   puff.visible=Game.state.quality!=0 or i<2
  var badge: Control=node.get_meta("badge")
  var column=badge.get_child(0)
  column.get_node("Status").text=("LÖSCHEN · %s %%" % int(progress*100) if spraying else "FEUERWEHR AUF ANFAHRT" if int(incident.mission_id)>=0 else "RAUCH · ALARM IN %s s" % ceili(FireSafety.alarm_left(incident)) if FireSafety.alarm_left(incident)>0 else "FEUERWEHR ANGEFORDERT")+"\nBrandstärke · %s %%" % int(strength*100)
  column.get_node("Intensity").value=strength*100
  column.get_node("Extinguishing").value=progress*100
  var at=node.to_global(Vector3(0,float(node.get_meta("roof"))+9,0))
  var screen=world.camera.unproject_position(at)
  var viewport_size=world.hud.size
  var top=world.hud.mission_button.get_global_rect().end.y+82
  var bottom=world.hud.bottom_panel.get_global_rect().position.y-badge.size.y-12
  var in_front=not world.camera.is_position_behind(at)
  var on_screen=screen.x>0 and screen.x<viewport_size.x and screen.y>top-70 and screen.y<bottom+100
  badge.visible=nearby and in_front and on_screen and bottom>top and not world.hud.overlay.visible
  badge.position=Vector2(clampf(screen.x-badge.size.x*0.5,12,viewport_size.x-badge.size.x-70),clampf(screen.y,top,maxf(top,bottom)))
  node.visible=nearby
 for id in scenes.keys():
  if not present.has(id):
   scenes[id].get_meta("badge").queue_free()
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

func update_hydrants() -> void:
 var installations=[]
 for i in Game.state.homes.size():
  if FireSafety.installed(Game.state,i,"hydrant"): installations.append([i,LogisticsRoutes.home_position(Game.state,i),int(Game.state.homes[i].get("rotation",0))])
 var signature=[installations,hash(Game.state.town.roads),int(Game.state.town.districts)]
 if signature!=protection_signature:
  for node in hydrants.values():
   remove_child(node)
   node.queue_free()
  hydrants.clear()
  var cells=TownRules.road_cells(Game.state.town)
  for item in installations:
   var node=Node3D.new()
   node.name="Hydrant_%s" % item[0]
   add_child(node)
   node.position=FireSafety.hydrant_position(Game.state,int(item[0]),cells)
   Models.cylinder(node,0.65,0.18,Vector3(0,0.05,0),Color("a3b1af"))
   Models.cylinder(node,0.42,1.55,Vector3(0,0.9,0),Color("c84132"))
   Models.cylinder(node,0.53,0.3,Vector3(0,1.75,0),Color("f0c269"))
   Models.box(node,Vector3(1.5,0.35,0.4),Vector3(0,1.2,0),Color("c84132"))
   for side in [-0.78,0.78]: Models.box(node,Vector3(0.16,0.42,0.45),Vector3(side,1.2,0),Color("d7dbcf"))
   Models.bake(node)
   hydrants[int(item[0])]=node
  protection_signature=signature.duplicate(true)
 for node in hydrants.values(): node.visible=node.position.distance_to(world.view_focus)<world.view_zoom*1.5+35

func update_supply_hose(node: Node3D, mission: Dictionary, spraying: bool) -> void:
 var hose=node.get_node_or_null("SupplyHose")
 if mission.is_empty() or mission.get("water_source_ref",{}).is_empty():
  if hose!=null: hose.hide()
  return
 if hose==null:
  hose=Node3D.new()
  hose.name="SupplyHose"
  node.add_child(hose)
  var ref=mission.water_source_ref
  var points=[FireSafety.hydrant_position(Game.state,int(ref.index))+Vector3(0,0.9,0)]
  for point in mission.get("water_route",[]):
   var p=LogisticsRoutes.vector(point)
   p.y=1.05
   points.append(p)
  points.append(LogisticsRoutes.vector(mission.outward[-1])+Vector3(0,0.5,0))
  for i in mini(96,points.size()-1):
   var a=node.to_local(points[i])
   var b=node.to_local(points[i+1])
   if a.distance_to(b)<0.01: continue
   var tube=Models.cylinder(hose,0.12,a.distance_to(b),(a+b)*0.5,Color("e1c76d"))
   tube.quaternion=Quaternion(Vector3.UP,(b-a).normalized())
  Models.bake(hose)
 hose.visible=spraying

func card(parent: Node3D, size: Vector2, at: Vector3, smoke: bool, seed_value: float) -> MeshInstance3D:
 var node=MeshInstance3D.new()
 var mesh=QuadMesh.new()
 mesh.size=size
 node.mesh=mesh
 node.position=at
 node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var material=ShaderMaterial.new()
 material.shader=preload("res://Shaders/Incident.gdshader")
 material.set_shader_parameter("smoke",smoke)
 material.set_shader_parameter("seed",seed_value)
 node.material_override=material
 parent.add_child(node)
 return node

func _exit_tree() -> void:
 for node in scenes.values():
  var badge=node.get_meta("badge",null)
  if is_instance_valid(badge): badge.queue_free()
