extends CanvasLayer
# Pure 2D: appears before offline simulation and accepts input every frame.
var game: Node
var caption: Label
var progress: ProgressBar
var detail: Label

func _ready() -> void:
 layer=100
 process_mode=Node.PROCESS_MODE_ALWAYS
 game=get_node("/root/Game")
 var panel=ColorRect.new()
 panel.color=Color("102c29")
 panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(panel)
 var margin=MarginContainer.new()
 panel.add_child(margin)
 margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,26)
 var center=CenterContainer.new()
 margin.add_child(center)
 var column=VBoxContainer.new()
 column.custom_minimum_size.x=280
 column.add_theme_constant_override("separation",16)
 center.add_child(column)
 label(column,"TIMBER LOOT · "+str(ProjectSettings.get_setting("application/config/version")).get_slice("-",0),13)
 var icon=TextureRect.new()
 icon.texture=load("res://Assets/Brand/timber-icon.png")
 icon.custom_minimum_size=Vector2(92,92)
 icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 column.add_child(icon)
 caption=label(column,"Deine Firma wird aktualisiert.",22)
 progress=ProgressBar.new()
 progress.custom_minimum_size=Vector2(280,14)
 progress.show_percentage=false
 progress.step=0.01
 var fill=StyleBoxFlat.new()
 fill.bg_color=Color("f3c779")
 fill.set_corner_radius_all(7)
 progress.add_theme_stylebox_override("fill",fill)
 var background=fill.duplicate()
 background.bg_color=Color("355a52")
 progress.add_theme_stylebox_override("background",background)
 column.add_child(progress)
 detail=label(column,"Offline-Fortschritt wird vorbereitet …",15)
 label(column,"Deine Firma bleibt erhalten.\nBei längerer Abwesenheit kann das etwas dauern.",14)
 var later=Button.new()
 later.text="SPÄTER WEITERSPIELEN"
 later.custom_minimum_size.y=48
 later.add_theme_font_size_override("font_size",14)
 for style in ["normal","hover","pressed","focus"]:
  var skin=StyleBoxFlat.new()
  skin.bg_color=Color("355a52") if style=="pressed" else Color("193c37")
  skin.border_color=Color("f3c779") if style=="focus" else Color("557a6d")
  skin.set_border_width_all(1)
  skin.set_corner_radius_all(12)
  later.add_theme_stylebox_override(style,skin)
 later.pressed.connect(func(): get_tree().quit())
 column.add_child(later)
 update_progress()

func label(parent: Node, value: String, font_size: int) -> Label:
 var result=Label.new()
 result.text=value
 result.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 result.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 result.add_theme_font_size_override("font_size",font_size)
 result.add_theme_color_override("font_color",Color("f4efd9"))
 parent.add_child(result)
 return result

func update_progress() -> void:
 if game==null: return
 var amount=clampf(1-float(game.catchup_left)/maxf(0.001,float(game.catchup_total)),0,1)
 progress.value=amount*100
 detail.text="%s %% · %s von %s Min. verarbeitet" % [int(amount*100),int((float(game.catchup_total)-float(game.catchup_left))/60),ceili(float(game.catchup_total)/60)]

func _process(_delta: float) -> void:
 update_progress()

func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.is_action_pressed("ui_cancel"):
  get_tree().quit()
  get_viewport().set_input_as_handled()
