extends Control
var hud: Control
var panel: PanelContainer
var heading: Label
var detail: Label
var action: Button
var skip: Button
var progress: ProgressBar
var marker: ReferenceRect
var last_phase=""
var clock=0.0

func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 panel=PanelContainer.new()
 panel.add_theme_stylebox_override("panel",hud.style(hud.PAPER,17))
 panel.clip_contents=true
 add_child(panel)
 # Isolate transient text-wrapping minima from the visible card's size.
 var reading=load("res://UI/TouchScroll.gd").new()
 panel.add_child(reading)
 var column=VBoxContainer.new()
 column.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 column.set_meta("light_card",true)
 column.add_theme_constant_override("separation",5)
 reading.add_child(column)
 heading=hud.text(column,"",16,hud.INK)
 detail=hud.text(column,"",14,hud.INK)
 progress=ProgressBar.new()
 progress.show_percentage=false
 progress.custom_minimum_size.y=5
 progress.mouse_filter=Control.MOUSE_FILTER_IGNORE
 column.add_child(progress)
 var choices=hud.row(column)
 action=hud.button(choices,"",go)
 action.add_theme_font_size_override("font_size",13)
 skip=hud.button(choices,"Später",func(): Game.pause_tutorial())
 skip.custom_minimum_size.x=76
 skip.size_flags_horizontal=Control.SIZE_SHRINK_END
 skip.add_theme_font_size_override("font_size",13)
 marker=ReferenceRect.new()
 marker.editor_only=false
 marker.border_width=3
 marker.border_color=hud.GOLD
 marker.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(marker)
 Game.changed.connect(refresh)
 resized.connect(refresh)
 refresh()

func refresh() -> void:
 if panel==null: return
 var info=TutorialRules.info(Game.state)
 if not info.is_empty() and last_phase=="sell" and str(info.phase)=="build" and hud.current=="market" and hud.overlay.visible: hud.call_deferred("close_menu")
 var available=not info.is_empty() and not hud.overlay.visible and not hud.placement_panel.visible and not hud.ux.panels_visible()
 panel.visible=available
 marker.visible=false
 if not available: return
 var phase=str(info.phase)
 heading.text="BENNO · %s/5 · %s" % [info.step,info.title]
 detail.text=info.text
 action.text=info.action
 if phase=="build" and Game.state.coins<Game.cost_for("cabin"):
  detail.text="Für die Hütte brauchst du %s Münzen. Verkaufe etwas Holz, Bretter oder Sägespäne und komm dann zurück." % Catalog.number(Game.cost_for("cabin"))
  action.text="WAREN VERKAUFEN"
 if phase=="construction":
  for job in Game.state.jobs:
   if int(job.get("id",-1))==int(Game.state.onboarding.job):
    detail.text="%s entsteht · noch etwa %s Sekunden. Währenddessen kannst du weiter Holz sammeln." % [Catalog.BUILDINGS[job.kind].name,ceili(job.left)]
 progress.max_value=float(info.target)
 progress.value=float(info.value)
 var inset=maxf(14,(hud.size.x-760)/2)
 panel.position=Vector2(inset,hud.mission_button.get_global_rect().end.y+8)
 var limit=hud.bottom_panel.get_global_rect().position.y-8
 panel.size=Vector2(maxf(220,minf(400,hud.size.x-inset*2-66)),minf(190,maxf(100,limit-panel.position.y)))
 detail.visible=panel.size.y>=165
 var target: Control=hud.chop_button if phase=="chop" else hud.deposit_button if phase=="deposit" else hud.sell_button if phase=="sell" else null
 if target!=null:
  marker.position=target.get_global_rect().position-Vector2.ONE*3
  marker.size=target.size+Vector2.ONE*6
  marker.show()
 if last_phase=="sell" and phase=="build" and hud.current=="market": hud.call_deferred("close_menu")
 last_phase=phase

func go() -> void:
 var phase=TutorialRules.phase(Game.state)
 match phase:
  "chop": hud.focus_requested.emit(Catalog.biome_position(int(Game.state.biome)))
  "deposit": hud.focus_requested.emit(Game.building_position(0))
  "boards":
   for i in Game.state.buildings.size():
    if Game.state.buildings[i].kind=="sawmill": hud.focus_requested.emit(Game.building_position(i)); break
  "sell": hud.open_menu("market")
  "build":
   if float(Game.state.coins)<Game.cost_for("cabin"): hud.open_menu("market"); return
   hud.focus_requested.emit(Game.free_position(Catalog.industry_position(5)))
   hud.request_placement({"kind":"cabin","city":false,"index":-1})
  "construction":
   for job in Game.state.jobs:
    if int(job.get("id",-1))==int(Game.state.onboarding.job): hud.focus_requested.emit(ConstructionRules.job_position(Game.state,job)); break
  "done":
   Game.end_tutorial(true)
   hud.open_menu("journey")
 refresh()

func _process(delta: float) -> void:
 clock+=delta
 if clock>=0.25: clock=0; refresh()
 marker.modulate.a=0.78+sin(Time.get_ticks_msec()/340.0)*0.20 if Game.state.ux.motion and Game.state.quality>0 else 1.0
