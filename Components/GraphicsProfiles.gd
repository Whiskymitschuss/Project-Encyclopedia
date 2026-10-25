class_name GraphicsProfiles
extends RefCounted

const PROFILES=[
 {"name":"Sparmodus","fps":30,"pixels":2000000.0,"msaa":Viewport.MSAA_DISABLED,"lod_pixels":4.0,"shadow_distance":120.0,"description":"30 Bilder/s · weniger Effekte und Schatten"},
 {"name":"Standard","fps":30,"pixels":2000000.0,"msaa":Viewport.MSAA_DISABLED,"lod_pixels":2.0,"shadow_distance":160.0,"description":"30 Bilder/s · ausgewogene Darstellung"},
 {"name":"Hoch","fps":60,"pixels":3000000.0,"msaa":Viewport.MSAA_2X,"lod_pixels":1.0,"shadow_distance":220.0,"description":"60 Bilder/s · feinere Kanten und Details"},
 {"name":"Ultra","fps":60,"pixels":0.0,"msaa":Viewport.MSAA_4X,"lod_pixels":0.5,"shadow_distance":260.0,"description":"60 Bilder/s · native Auflösung und höchste Kantenglättung"}]
static func profile(quality: int) -> Dictionary:return PROFILES[clampi(quality,0,3)]
static func effective(quality: int,detail_level: int,adaptive: bool) -> int:
 return 0 if adaptive and detail_level>=2 else clampi(quality,0,3)
static func recommendation(frames: int,fps: float,p95: float,gpu: Dictionary) -> String:
 if frames<60:return "Die Empfehlung erscheint nach genügend gemessenen Spielbildern."
 if fps<24 or p95>65:return "Messwerte: Sparmodus empfohlen; die aktuelle Bildzeit überschreitet das 30-FPS-Ziel."
 if gpu.has("gpu_ms") and gpu.has("cpu_ms") and float(gpu.gpu_ms)<10 and float(gpu.cpu_ms)<8 and fps>=28:
  return "Die gemessenen Renderzeiten bieten Spielraum: Hoch ausprobieren. Das ist keine 60-FPS-Garantie."
 return "Messwerte: Standard empfohlen. Hoch und Ultra bleiben manuell wählbar."
