extends Control
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
var diorama: SubViewportContainer
var title: Label
var returning=false
var recovery_box: VBoxContainer

func label(parent: Node,value: String,font_size: int,color: Color=WHITE) -> Label:
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
 skin.content_margin_top=12
 skin.content_margin_bottom=12
 skin.content_margin_left=16
 skin.content_margin_right=16
 return skin

func _ready() -> void:
 Game.live_world=false
 Game.back_requested.connect(back)
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 reduced_motion=not bool(Game.state.ux.motion)
 returning=int(Game.state.tutorial)>0 or float(Game.state.elapsed)>0 or int(Game.state.trees)>0
 var texture=GradientTexture2D.new()
 var gradient=Gradient.new()
 gradient.set_color(0,Color("214c48"))
 gradient.set_color(1,Color("0b211f"))
 texture.gradient=gradient
 texture.fill_from=Vector2.ZERO
 texture.fill_to=Vector2(0.65,1)
 var background=TextureRect.new()
 background.texture=texture
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
 column.add_theme_constant_override("separation",10)
 center.add_child(column)
 label(column,"DEIN KLEINES STÜCK WALD",12,GOLD)
 var brand=HBoxContainer.new()
 brand.alignment=BoxContainer.ALIGNMENT_CENTER
 brand.add_theme_constant_override("separation",12)
 column.add_child(brand)
 logo=TextureRect.new()
 logo.texture=load("res://Assets/Brand/timber-icon.png")
 logo.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 logo.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 logo.mouse_filter=Control.MOUSE_FILTER_IGNORE
 brand.add_child(logo)
 var names=VBoxContainer.new()
 names.alignment=BoxContainer.ALIGNMENT_CENTER
 brand.add_child(names)
 title=label(names,"TIMBER LOOT",30,GOLD)
 title.autowrap_mode=TextServer.AUTOWRAP_OFF
 var tycoon=label(names,"T Y C O O N",14)
 tycoon.autowrap_mode=TextServer.AUTOWRAP_OFF
 var frame=PanelContainer.new()
 var frame_skin=button_skin(Color("39635b"))
 frame_skin.set_border_width_all(1)
 frame_skin.border_color=Color("648679")
 frame_skin.content_margin_top=0
 frame_skin.content_margin_bottom=0
 frame_skin.content_margin_left=0
 frame_skin.content_margin_right=0
 frame.add_theme_stylebox_override("panel",frame_skin)
 frame.clip_contents=true
 column.add_child(frame)
 diorama=load("res://UI/IntroWorld.gd").new()
 diorama.animated=not reduced_motion and Game.state.quality>0
 diorama.low=Game.state.quality==0
 frame.add_child(diorama)
 chapter=label(column,STEPS[0],21)
 subtitle=label(column,"Fälle dein erstes Holz. Baue etwas Eigenes.",15,Color("c6dcd0"))
 var indicators=HBoxContainer.new()
 indicators.alignment=BoxContainer.ALIGNMENT_CENTER
 indicators.add_theme_constant_override("separation",8)
 column.add_child(indicators)
 for i in 3:
  var dot=ColorRect.new()
  dot.custom_minimum_size=Vector2(28,3)
  indicators.add_child(dot)
  dots.append(dot)
 play=Button.new()
 play.text="WEITERSPIELEN  ›" if returning else "MEINEN WALD ENTDECKEN  ›"
 play.custom_minimum_size.y=56
 play.add_theme_font_size_override("font_size",18)
 play.add_theme_color_override("font_color",BACKGROUND)
 for state in ["normal","hover","pressed","focus"]: play.add_theme_stylebox_override(state,button_skin(GOLD.darkened(0.12) if state=="pressed" else GOLD))
 play.pressed.connect(start_game)
 column.add_child(play)
 label(column,"ALPHA 2 · TESTFASSUNG · "+str(ProjectSettings.get_setting("application/config/version")).get_slice("-",0),12,Color("bdd4c5"))
 skip=Button.new()
 skip.text="Intro überspringen  ›"
 skip.flat=true
 skip.custom_minimum_size.y=44
 skip.add_theme_color_override("font_color",WHITE)
 skip.pressed.connect(finish_intro)
 column.add_child(skip)
 recovery_box=VBoxContainer.new()
 recovery_box.hide()
 column.add_child(recovery_box)
 if Store.recovery_required:
  play.disabled=true
  play.hide()
  diorama.hide()
  subtitle.text="Dein lokaler Spielstand kann nicht gelesen werden. Deine Dateien werden nicht überschrieben."
  var recovery=Button.new()
  recovery.text="WIEDERHERSTELLUNG ANSEHEN"
  recovery.custom_minimum_size.y=48
  recovery.pressed.connect(show_recovery)
  recovery_box.add_child(recovery)
  recovery_box.show()
 elif Store.load_status=="backup": subtitle.text="Deine letzte gültige Sicherung wurde wiederhergestellt. Schön, dass du zurück bist."
 resized.connect(layout)
 layout()
 if reduced_motion or returning: finish_intro()
 update_phase()

func layout() -> void:
 if column==null: return
 var width=minf(500,maxf(260,size.x-48))
 column.custom_minimum_size.x=width
 column.add_theme_constant_override("separation",6 if size.y<760 else 12)
 logo.custom_minimum_size=Vector2(64,64) if size.y<760 else Vector2(84,84)
 title.add_theme_font_size_override("font_size",25 if width<330 else 30)
 diorama.custom_minimum_size=Vector2(0,clampf(size.y*0.20,112,220))

func update_phase() -> void:
 var phase=2 if ready_to_play else mini(2,int(elapsed/1.6))
 chapter.text=("Dein Wald wartet auf dich." if returning else "Dein Wald. Deine Stadt. Dein Weg.") if ready_to_play else STEPS[phase]
 for i in dots.size(): dots[i].color=GOLD if i<=phase else Color("527568")
 if diorama!=null: diorama.present(phase,ready_to_play)

func finish_intro() -> void:
 ready_to_play=true
 if skip!=null: skip.hide()
 if logo!=null: logo.modulate.a=1
 update_phase()

func start_game() -> void:
 if starting or Store.recovery_required or Game.catching_up: return
 starting=true
 play.disabled=true
 play.text="DEIN WALD WIRD VORBEREITET …"
 call_deferred("open_after_frame")

func open_after_frame() -> void:
 await get_tree().process_frame
 await get_tree().process_frame
 # A resume notification can arrive after Play but before the deferred switch.
 # Scene initialization must not read shared route caches while a worker runs.
 while Game.catching_up: await get_tree().process_frame
 open_world()

func open_world() -> void:
 var error=get_tree().change_scene_to_file("res://Scenes/Main.tscn")
 if error!=OK:
  starting=false
  play.disabled=false
  play.text="ERNEUT VERSUCHEN"
  subtitle.text="Die Welt konnte nicht geöffnet werden. Bitte versuche es noch einmal."
  push_error("Game scene failed to open: "+str(error))

func show_recovery() -> void:
 for child in recovery_box.get_children(): recovery_box.remove_child(child); child.queue_free()
 diorama.hide()
 label(recovery_box,"Beide Speicherdateien sind beschädigt. Du kannst eine neue Firma beginnen. Die bisherigen Dateien bleiben als separate Sicherung erhalten.",14)
 var confirm=Button.new()
 confirm.text="DATEIEN BEWAHREN & NEU BEGINNEN"
 confirm.custom_minimum_size.y=48
 confirm.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 recovery_box.add_child(confirm)
 confirm.pressed.connect(func():
  if not Store.archive_unreadable(): subtitle.text=Store.last_error; return
  Game.state=Game.initial_state()
  if not Game.save(true): subtitle.text=Store.last_error; return
  recovery_box.hide()
  diorama.show()
  play.disabled=false
  play.show()
  subtitle.text="Deine bisherigen Dateien sind gesichert. Dein neuer Wald ist bereit.")

func back() -> void:
 if Game.catching_up: get_tree().quit(); return
 if not ready_to_play: finish_intro()
 elif not starting:
  Game.save(true)
  get_tree().quit()

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
  back()
  get_viewport().set_input_as_handled()
