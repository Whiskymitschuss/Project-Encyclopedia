extends Control

# Shared, lightweight cover for cold start and offline replay. No 3D viewport,
# timer animation or company mutations. Percentage is supplied by real work.
const ART=preload("res://Assets/Brand/timber-loading.png")
const DISPLAY_FONT=preload("res://Assets/Fonts/Anton-Regular.ttf")
const CREAM=Color("fff3cf")
const GOLD=Color("ffc54e")
var background: TextureRect
var brand: VBoxContainer
var column: VBoxContainer
var title: Label
var chapter: Label
var subtitle: Label
var meter: ProgressBar
var percentage: Label
var version: Label
var play: Button

func text(parent: Node,value: String,points: int) -> Label:
 var item=Label.new()
 item.text=value
 item.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 item.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 item.mouse_filter=Control.MOUSE_FILTER_IGNORE
 item.add_theme_font_size_override("font_size",points)
 item.add_theme_color_override("font_color",CREAM)
 item.add_theme_color_override("font_outline_color",Color("253e2e"))
 item.add_theme_constant_override("outline_size",4)
 parent.add_child(item)
 return item

func skin(color: Color,radius: int=8) -> StyleBoxFlat:
 var box=StyleBoxFlat.new()
 box.bg_color=color
 box.set_corner_radius_all(radius)
 box.content_margin_top=10
 box.content_margin_bottom=10
 return box

func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 var base=ColorRect.new()
 base.color=Color("173e35")
 base.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(base)
 base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 background=TextureRect.new()
 background.name="ForestCover"
 background.texture=ART
 background.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 background.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
 background.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(background)
 var shade=TextureRect.new()
 var texture=GradientTexture2D.new()
 var gradient=Gradient.new()
 gradient.set_color(0,Color(0.04,0.12,0.08,0))
 gradient.set_color(1,Color(0.03,0.10,0.07,0.92))
 texture.gradient=gradient
 texture.fill_from=Vector2(0,0.60)
 texture.fill_to=Vector2(0,1)
 shade.texture=texture
 shade.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(shade)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 brand=VBoxContainer.new()
 brand.mouse_filter=Control.MOUSE_FILTER_IGNORE
 brand.add_theme_constant_override("separation",-10)
 add_child(brand)
 title=text(brand,"TIMBER LOOT",58)
 title.autowrap_mode=TextServer.AUTOWRAP_OFF
 title.add_theme_font_override("font",DISPLAY_FONT)
 title.add_theme_color_override("font_color",GOLD)
 title.add_theme_color_override("font_outline_color",Color("713f22"))
 title.add_theme_constant_override("outline_size",9)
 title.add_theme_color_override("font_shadow_color",Color("4d311c"))
 title.add_theme_constant_override("shadow_offset_y",5)
 var second=text(brand,"T Y C O O N",24)
 second.add_theme_font_override("font",DISPLAY_FONT)
 second.add_theme_constant_override("outline_size",6)
 column=VBoxContainer.new()
 column.add_theme_constant_override("separation",8)
 column.mouse_filter=Control.MOUSE_FILTER_PASS
 add_child(column)
 chapter=text(column,"DEIN WALD WIRD VORBEREITET",25)
 chapter.add_theme_font_override("font",DISPLAY_FONT)
 meter=ProgressBar.new()
 meter.name="ActualLoadingProgress"
 meter.custom_minimum_size.y=24
 meter.show_percentage=false
 meter.mouse_filter=Control.MOUSE_FILTER_IGNORE
 meter.add_theme_stylebox_override("background",skin(Color("263e2f")))
 var fill=skin(Color("92d34f"))
 fill.set_border_width_all(2)
 fill.border_color=Color("b8ed76")
 meter.add_theme_stylebox_override("fill",fill)
 column.add_child(meter)
 percentage=text(meter,"0 %",16)
 percentage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 subtitle=text(column,"Dein Spielstand wird geladen.",14)
 play=Button.new()
 play.text="WEITERSPIELEN  ›"
 play.custom_minimum_size.y=52
 play.add_theme_font_size_override("font_size",19)
 play.add_theme_color_override("font_color",Color("3f321e"))
 for state in ["normal","hover","pressed","focus"]:
  var panel=skin(GOLD.darkened(0.12) if state=="pressed" else GOLD,12)
  if state=="focus": panel.set_border_width_all(3); panel.border_color=CREAM
  play.add_theme_stylebox_override(state,panel)
 column.add_child(play)
 play.hide()
 version=text(column,"ALPHA · %s" % ProjectSettings.get_setting("application/config/version"),11)
 version.modulate.a=0.75
 resized.connect(layout)
 column.minimum_size_changed.connect(layout.call_deferred)
 layout()

func layout() -> void:
 if column==null: return
 var wide=size.x>size.y*1.15
 background.position=Vector2.ZERO
 background.size=Vector2(size.x*0.56 if wide else size.x,size.y)
 background.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED if wide else TextureRect.STRETCH_KEEP_ASPECT_COVERED
 var width=minf(480,size.x*(0.39 if wide else 0.88))
 var x=size.x*0.58 if wide else (size.x-width)*0.5
 brand.position=Vector2(x,size.y*(0.16 if wide else 0.035))
 brand.size=Vector2(width,150)
 title.add_theme_font_size_override("font_size",clampi(roundi(width/6.2),34,72))
 column.custom_minimum_size.x=width
 column.size.x=width
 # Account for recovery actions and larger system text before positioning.
 var height=column.get_combined_minimum_size().y
 column.position=Vector2(x,maxf(size.y*0.40,size.y-height-maxf(28,size.y*0.045)))
 column.size.y=height
 chapter.add_theme_font_size_override("font_size",21 if width<340 else 25)

func progress(value: float,message: String,detail: String="") -> void:
 meter.value=clampf(value,0,100)
 percentage.text="%s %%" % roundi(meter.value)
 chapter.text=message
 subtitle.text=detail
 layout()
