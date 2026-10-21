extends Control
# This scene owns only branding/navigation; the game world starts after PLAY.
const BACKGROUND=Color("102c29")
const GOLD=Color("f3c779")
const WHITE=Color("f7faf5")
const STEPS=["Ein Wald voller Möglichkeiten.","Aus Holz werden Ideen.","Aus deiner Firma wird eine Stadt."]
var elapsed=0.0
var ready_to_play=false
var starting=false
var reduced_motion=false
var logo: TextureRect
var chapter: Label
var subtitle: Label
var play: Button
var skip: Button
var column: VBoxContainer
var margin: MarginContainer
var dots: Array=[]

func label(parent: Node, value: String, font_size: int, color: Color=WHITE) -> Label:
 var item=Label.new()
 item.text=value
 item.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 item.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 item.add_theme_font_size_override("font_size",font_size)
 item.add_theme_color_override("font_color",color)
 parent.add_child(item)
 return item

func button_skin(color: Color) -> StyleBoxFlat:
 var skin=StyleBoxFlat.new()
 skin.bg_color=color
 skin.set_corner_radius_all(16)
 skin.content_margin_top=14
 skin.content_margin_bottom=14
 skin.content_margin_left=20
 skin.content_margin_right=20
 return skin

func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 reduced_motion=not bool(Game.state.ux.motion)
 var background=ColorRect.new()
 background.color=BACKGROUND
 background.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(background)
 background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 margin=MarginContainer.new()
 add_child(margin)
 margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,24)
 var center=CenterContainer.new()
 margin.add_child(center)
 column=VBoxContainer.new()
 column.add_theme_constant_override("separation",14)
 center.add_child(column)
 label(column,"WILLKOMMEN IN DEINEM WALDIMPERIUM",12,GOLD)
 logo=TextureRect.new()
 logo.texture=load("res://Assets/Brand/timber-icon.png")
 logo.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 logo.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 logo.mouse_filter=Control.MOUSE_FILTER_IGNORE
 column.add_child(logo)
 label(column,"TIMBER LOOT",34,GOLD)
 label(column,"T Y C O O N",16,WHITE)
 chapter=label(column,STEPS[0],22)
 subtitle=label(column,"Fällen. Bauen. Wachsen.",15,Color("bad1c2"))
 var indicators=HBoxContainer.new()
 indicators.alignment=BoxContainer.ALIGNMENT_CENTER
 indicators.add_theme_constant_override("separation",10)
 column.add_child(indicators)
 for i in 3:
  var dot=ColorRect.new()
  dot.custom_minimum_size=Vector2(28,4)
  indicators.add_child(dot)
  dots.append(dot)
 play=Button.new()
 play.text="SPIELEN  ›"
 play.custom_minimum_size.y=56
 play.add_theme_font_size_override("font_size",20)
 play.add_theme_color_override("font_color",BACKGROUND)
 for state in ["normal","hover","pressed","focus"]: play.add_theme_stylebox_override(state,button_skin(GOLD.darkened(0.12) if state=="pressed" else GOLD))
 play.pressed.connect(start_game)
 column.add_child(play)
 label(column,"WALDLEBEN · 0.25",12,Color("bad1c2"))
 skip=Button.new()
 skip.text="Intro überspringen  ›"
 skip.flat=true
 skip.custom_minimum_size.y=44
 skip.add_theme_color_override("font_color",WHITE)
 skip.pressed.connect(finish_intro)
 column.add_child(skip)
 resized.connect(layout)
 layout()
 if reduced_motion: finish_intro()
 update_phase()

func layout() -> void:
 if column==null: return
 var width=minf(440,maxf(250,size.x-48))
 column.custom_minimum_size.x=width
 column.add_theme_constant_override("separation",8 if size.y<760 else 14)
 logo.custom_minimum_size=Vector2(width,minf(280,maxf(120,size.y*0.27)))

func update_phase() -> void:
 var phase=2 if ready_to_play else mini(2,int(elapsed/1.6))
 chapter.text="Dein Wald. Deine Stadt. Dein Weg." if ready_to_play else STEPS[phase]
 for i in dots.size(): dots[i].color=GOLD if i<=phase else Color("34554a")

func finish_intro() -> void:
 ready_to_play=true
 if skip!=null: skip.hide()
 if logo!=null: logo.modulate.a=1
 update_phase()

func start_game() -> void:
 if starting: return
 starting=true
 play.disabled=true
 play.text="WELT WIRD GEÖFFNET …"
 # Defer the scene switch to let a held touch finish without double activation.
 call_deferred("open_world")

func open_world() -> void:
 var error=get_tree().change_scene_to_file("res://Scenes/Main.tscn")
 if error!=OK:
  starting=false
  play.disabled=false
  play.text="ERNEUT VERSUCHEN"
  subtitle.text="Die Welt konnte nicht geöffnet werden."
  push_error("Game scene failed to open: "+str(error))

func _process(delta: float) -> void:
 if ready_to_play or starting: return
 elapsed+=maxf(0,delta)
 logo.modulate.a=clampf(elapsed/0.55,0,1)
 update_phase()
 if elapsed>=4.8: finish_intro()

func _unhandled_key_input(event: InputEvent) -> void:
 if event.is_action_pressed("ui_accept"):
  start_game()
  get_viewport().set_input_as_handled()
 elif event.is_action_pressed("ui_cancel"):
  finish_intro()
  get_viewport().set_input_as_handled()
