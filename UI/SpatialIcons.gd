extends SubViewport

const KEYS=["factory","team","orders","world","more","coin","gem"]
var models: Array=[]
var camera: Camera3D

func _notification(what: int) -> void:
 if what==NOTIFICATION_APPLICATION_RESUMED:
  render_target_update_mode=SubViewport.UPDATE_ONCE

func _ready() -> void:
 size=Vector2i(KEYS.size()*128,128)
 own_world_3d=true
 transparent_bg=true
 render_target_update_mode=SubViewport.UPDATE_ONCE
 msaa_3d=Viewport.MSAA_2X
 var environment=WorldEnvironment.new()
 var env=Environment.new()
 env.background_mode=Environment.BG_CLEAR_COLOR
 env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color=Color.WHITE
 env.ambient_light_energy=0.65
 environment.environment=env
 add_child(environment)
 var light=DirectionalLight3D.new()
 light.rotation_degrees=Vector3(-38,-35,0)
 light.light_energy=1.3
 add_child(light)
 camera=Camera3D.new()
 camera.projection=Camera3D.PROJECTION_ORTHOGONAL
 camera.size=4.5
 camera.position=Vector3(0,9,16)
 add_child(camera)
 camera.look_at(Vector3(0,1.0,0))
 for i in KEYS.size():
  var model=make_icon(KEYS[i])
  model.position.x=(i-(KEYS.size()-1)/2.0)*4.5
  model.rotation.y=-0.35
  add_child(model)
  models.append(model)

func texture_for(key: String) -> AtlasTexture:
 var tile=AtlasTexture.new()
 tile.atlas=get_texture()
 tile.region=Rect2(maxi(0,KEYS.find(key))*128,0,128,128)
 tile.filter_clip=true
 return tile

func make_icon(kind: String) -> Node3D:
 var root=Node3D.new()
 var blue=Color("20a6d2")
 var gold=Color("ffbf38")
 var wood=Color("ba773f")
 if kind=="factory":
  Models.box(root,Vector3(2.7,1.5,1.8),Vector3(0,0.85,0),blue)
  Models.roof(root,2.7,1.8,1.85,Color("ed793e"))
  Models.box(root,Vector3(0.5,2.4,0.5),Vector3(0.85,1.3,-0.5),Color("ecd8a4"))
  for x in [-0.7,0,0.7]: Models.box(root,Vector3(0.4,0.5,0.08),Vector3(x,1,0.94),Color("c1f7ff"))
 elif kind=="team":
  for x in [-0.65,0.65]:
   Models.box(root,Vector3(0.95,1.2,0.65),Vector3(x,0.8,0),blue)
   Models.box(root,Vector3(0.65,0.65,0.65),Vector3(x,1.7,0),Color("f6d2a5"))
   Models.cylinder(root,0.55,0.2,Vector3(x,2.1,0),gold)
   Models.cylinder(root,0.44,0.35,Vector3(x,2.28,0),gold,0.28)
   for stripe in [-0.22,0.22]: Models.box(root,Vector3(0.12,1.1,0.1),Vector3(x+stripe,0.9,0.38),gold)
 elif kind=="orders":
  Models.box(root,Vector3(2.1,2.7,0.4),Vector3(0,1.4,0),wood)
  Models.box(root,Vector3(1.8,2.3,0.08),Vector3(0,1.35,0.25),Color("fff3d6"))
  Models.box(root,Vector3(1.0,0.4,0.3),Vector3(0,2.65,0.3),gold)
  for y in [0.7,1.3,1.9]:
   Models.box(root,Vector3(0.25,0.22,0.12),Vector3(-0.48,y,0.35),Color("37b997"))
   Models.box(root,Vector3(0.85,0.12,0.1),Vector3(0.25,y,0.35),blue)
 elif kind=="world":
  Models.box(root,Vector3(2.9,0.35,2.4),Vector3(0,0.15,0),wood)
  Models.box(root,Vector3(2.9,0.15,2.4),Vector3(0,0.4,0),Color("82d657"))
  for x in [-0.7,0.65]:
   Models.cylinder(root,0.15,0.8,Vector3(x,0.9,0),wood)
   Models.cylinder(root,0.75,1.5,Vector3(x,1.7,0),Color("25ae63"),0.0)
  Models.box(root,Vector3(0.5,0.12,2.4),Vector3(0,0.53,0),Color("f3d58d"))
 elif kind=="coin":
  var coin=Models.cylinder(root,1.15,0.32,Vector3(0,1.4,0),gold)
  coin.rotation.x=PI/2
  var face=Models.cylinder(root,0.92,0.36,Vector3(0,1.4,0),Color("ffe789"))
  face.rotation.x=PI/2
  Models.box(root,Vector3(0.24,1.4,0.12),Vector3(0,1.4,0.23),Color("dc911f"))
  for y in [0.92,1.4,1.88]: Models.box(root,Vector3(0.9,0.18,0.15),Vector3(0,y,0.26),Color("dc911f"))
 elif kind=="gem":
  Models.cylinder(root,1.1,0.8,Vector3(0,1.9,0),Color("6ef2f4"),0.65)
  Models.cylinder(root,0.0,1.5,Vector3(0,0.75,0),Color("22acd9"),1.1)
 else:
  Models.box(root,Vector3(2.6,1.6,1.8),Vector3(0,0.9,0),wood)
  Models.box(root,Vector3(2.7,0.55,1.9),Vector3(0,2.0,0),Color("e4a74c"))
  for x in [-0.8,0.8]: Models.box(root,Vector3(0.23,2.0,1.94),Vector3(x,1.2,0),gold)
  Models.box(root,Vector3(0.5,0.6,0.14),Vector3(0,1.5,1.04),gold)
 Models.bake(root)
 return root
