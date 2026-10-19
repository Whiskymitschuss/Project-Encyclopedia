extends RefCounted

const PATHS={
 "factory":"M5 25V13L13 18V11L21 16V7H27V29H5Z M10 23H12 M18 23H20 M25 23H26",
 "team":"M10 15A4 4 0 1 0 10 7A4 4 0 1 0 10 15 M23 15A4 4 0 1 0 23 7A4 4 0 1 0 23 15 M4 28V23Q4 18 10 18Q16 18 16 23V28 M19 28V23Q19 18 24 18Q29 18 29 23V28",
 "orders":"M8 5H25V29H8Z M12 11H21 M12 17H21 M12 23H18 M13 3H20V7H13Z",
 "world":"M4 9L12 5L21 9L29 5V25L21 29L12 25L4 29Z M12 5V25 M21 9V29",
 "more":"M6 10H27 M6 17H27 M6 24H27",
 "home":"M4 16L16 5L29 16 M8 13V29H25V13 M14 29V21H20V29"
}
static var cache={}

static func get_icon(key: String) -> Texture2D:
 if cache.has(key): return cache[key]
 var svg='<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32"><path d="%s" fill="none" stroke="#d78025" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg>' % PATHS.get(key,PATHS.more)
 var picture=Image.new()
 picture.load_svg_from_string(svg,2)
 var texture=ImageTexture.create_from_image(picture)
 cache[key]=texture
 return texture
