extends RefCounted

# Nine-slice lacquered face with a shaded lower rim. Cached, never redrawn per frame.
static var textures={}
static func create(color: Color, radius: int=18, pressed: bool=false) -> StyleBoxTexture:
 var key=str(color)+str(radius)+str(pressed)
 if not textures.has(key):
  var svg='<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96"><defs><linearGradient id="face" x2="0" y2="1"><stop stop-color="#%s"/><stop offset="0.48" stop-color="#%s"/><stop offset="1" stop-color="#%s"/></linearGradient></defs>' % [color.lightened(0.10).to_html(false),color.to_html(false),color.darkened(0.10).to_html(false)]
  svg+='<rect x="1" y="5" width="94" height="90" rx="%s" fill="#%s"/>' % [radius,color.darkened(0.55).to_html(false)]
  svg+='<rect x="1" y="%s" width="94" height="90" rx="%s" fill="url(#face)" stroke="#%s" stroke-width="1"/>' % [4 if pressed else 1,radius,color.darkened(0.28).to_html(false)]
  svg+='<path d="M%s %s H%s" stroke="#ffffff" stroke-opacity="0.20" stroke-width="1" stroke-linecap="round"/></svg>' % [radius+5,9 if pressed else 5,91-radius]
  var picture=Image.new()
  picture.load_svg_from_string(svg,1)
  textures[key]=ImageTexture.create_from_image(picture)
 var skin=StyleBoxTexture.new()
 skin.texture=textures[key]
 for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]: skin.set_texture_margin(side,20 if side in [SIDE_LEFT,SIDE_RIGHT] else 12)
 skin.content_margin_left=15
 skin.content_margin_right=15
 skin.content_margin_top=14 if pressed else 11
 skin.content_margin_bottom=9 if pressed else 12
 return skin
