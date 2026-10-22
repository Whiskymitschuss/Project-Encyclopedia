extends CanvasLayer
var meter: ProgressBar
var detail: Label
func _ready() -> void:
 layer=100
 process_mode=Node.PROCESS_MODE_ALWAYS
 var background=ColorRect.new()
 background.color=Color("142d32")
 add_child(background)
 background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var center=CenterContainer.new()
 background.add_child(center)
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var box=VBoxContainer.new()
 box.custom_minimum_size=Vector2(280,0)
 box.add_theme_constant_override("separation",16)
 center.add_child(box)
 var logo=TextureRect.new()
 logo.texture=load("res://Assets/Brand/timber-icon.png")
 logo.custom_minimum_size=Vector2(80,80)
 logo.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 logo.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 box.add_child(logo)
 var title=Label.new()
 title.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 title.text="Dein Team macht alles bereit."
 title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 box.add_child(title)
 meter=ProgressBar.new()
 meter.custom_minimum_size.y=12
 meter.show_percentage=false
 box.add_child(meter)
 detail=Label.new()
 detail.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 detail.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 box.add_child(detail)
 var close=Button.new()
 close.text="APP SCHLIESSEN"
 close.custom_minimum_size.y=44
 close.pressed.connect(func(): get_tree().quit())
 box.add_child(close)
func _process(_delta: float) -> void:
 meter.value=Game.replay_progress()*100
 detail.text="%s %% · Dein bisheriger Stand bleibt gesichert." % roundi(meter.value)
