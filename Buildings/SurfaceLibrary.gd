class_name SurfaceLibrary
extends RefCounted

static var materials: Dictionary={}
static var textures: Dictionary={}
static var windows: Array=[]
static var last_night=-1.0
static var wetness=0.0
static var wet_surfaces: Array=[]

static func texture(kind: String) -> ImageTexture:
 if textures.has(kind): return textures[kind]
 var image=Image.create(64,64,false,Image.FORMAT_RGB8)
 for y in 64:
  for x in 64:
   var noise_value=float(posmod(x*31+y*73+x*y*7,29))/29.0
   var value=0.96+noise_value*0.04
   if kind=="timber":
    value=0.9+sin(y*0.55+sin(x*0.12)*1.5)*0.035+noise_value*0.055
    if y%16==0: value=0.86
   elif kind=="paving":
    if y%16==0 or posmod(x+(8 if (y/16)%2==0 else 0),16)==0: value=0.82
   elif kind=="roof":
    value=0.91+noise_value*0.04
    if y%16<2: value=0.86
    if posmod(x+(8 if (y/16)%2==0 else 0),16)==0: value*=0.97
   image.set_pixel(x,y,Color(value,value,value))
 image.generate_mipmaps()
 var result=ImageTexture.create_from_image(image)
 textures[kind]=result
 return result

static func material(color: Color,kind: String="plaster") -> StandardMaterial3D:
 color=TycoonStyle.paint(color)
 var key=str(color)+kind
 if materials.has(key): return materials[key]
 var mat=StandardMaterial3D.new()
 mat.albedo_color=color
 if kind in ["paint","plaster"]: mat.set_meta("static_paint",true)
 mat.roughness=0.9
 mat.albedo_texture=texture(kind) if kind in ["timber","paving","roof"] else null
 if kind=="glass":
  mat.albedo_texture=null
  mat.roughness=0.23
  mat.metallic=0.12
  mat.emission_enabled=true
  mat.emission=Color("ffbe70")
  mat.emission_energy_multiplier=0.04+maxf(0,last_night)*0.55
  mat.albedo_color=color.lerp(Color("cf9d64"),maxf(0,last_night)*0.8)
  windows.append({"material":mat,"day":color})
 elif kind=="paint": mat.roughness=0.9; mat.metallic=0.0
 elif kind=="timber": mat.roughness=0.9
 if kind in ["asphalt","roof","paving"]:
  wet_surfaces.append({"material":mat,"color":mat.albedo_color,"roughness":mat.roughness})
  apply_wet(wet_surfaces[-1])
 materials[key]=mat
 return mat

static func daylight(day: float) -> void:
 var night=snappedf(1.0-clampf(day*1.8,0,1),0.05)
 if night==last_night: return
 last_night=night
 for entry in windows:
  entry.material.emission_energy_multiplier=0.04+night*0.55
  entry.material.albedo_color=entry.day.lerp(Color("cf9d64"),night*0.8)

static func apply_wet(entry: Dictionary) -> void:
 entry.material.albedo_color=entry.color.darkened(wetness*0.08)
 entry.material.roughness=lerpf(float(entry.roughness),0.22,wetness)

static func weather(amount: float) -> void:
 var value=snappedf(clampf(amount,0,1),0.02)
 if is_equal_approx(value,wetness): return
 wetness=value
 for entry in wet_surfaces: apply_wet(entry)
