extends CanvasLayer
var world: Node3D
var active=false
var busy=false
var saved={}
var root_control: Control
var toolbar: PanelContainer
var gallery: PanelContainer
var image_view: TextureRect
var status: Label
var gallery_status: Label
var paths=[]
var page=0
var last_path=""
var controls=[]

func _ready() -> void:
 layer=20
 root_control=Control.new()
 root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root_control.mouse_filter=Control.MOUSE_FILTER_IGNORE
 root_control.theme=world.hud.theme
 add_child(root_control)
 toolbar=PanelContainer.new()
 toolbar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 toolbar.offset_left=14
 toolbar.offset_right=-14
 toolbar.offset_top=-174
 toolbar.offset_bottom=-16
 toolbar.add_theme_stylebox_override("panel",world.hud.style(world.hud.INK,20))
 root_control.add_child(toolbar)
 var box=VBoxContainer.new()
 toolbar.add_child(box)
 var heading=world.hud.row(box)
 status=world.hud.text(heading,"DEIN STADTPANORAMA",16,world.hud.GOLD)
 status.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 make_button(heading,"Fertig",leave).size_flags_horizontal=Control.SIZE_SHRINK_END
 var angles=world.hud.row(box)
 for entry in [["Links",-35],["Klassisch",0],["Rechts",35]]:
  var angle=float(entry[1])
  make_button(angles,entry[0],func(): world.camera_yaw=deg_to_rad(angle); world.ease_camera())
 var actions=world.hud.row(box)
 make_button(actions,"−",func(): world.camera_action("−"))
 make_button(actions,"+",func(): world.camera_action("+"))
 make_button(actions,"Aufnehmen",capture)
 make_button(actions,"Meine Fotos",open_gallery)
 gallery=PanelContainer.new()
 gallery.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 gallery.offset_left=14
 gallery.offset_right=-14
 gallery.offset_top=14
 gallery.offset_bottom=-14
 gallery.add_theme_stylebox_override("panel",world.hud.style(world.hud.INK,20))
 root_control.add_child(gallery)
 var gallery_box=VBoxContainer.new()
 gallery.add_child(gallery_box)
 var gallery_heading=world.hud.row(gallery_box)
 gallery_status=world.hud.text(gallery_heading,"DEINE FOTOS",17,world.hud.GOLD)
 gallery_status.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 make_button(gallery_heading,"Zurück",func(): gallery.hide()).size_flags_horizontal=Control.SIZE_SHRINK_END
 image_view=TextureRect.new()
 image_view.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 image_view.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 image_view.size_flags_vertical=Control.SIZE_EXPAND_FILL
 gallery_box.add_child(image_view)
 var browse=world.hud.row(gallery_box)
 make_button(browse,"‹ Voriges",func(): page=maxi(0,page-1); show_page())
 make_button(browse,"Nächstes ›",func(): page=mini(paths.size()-1,page+1); show_page())
 toolbar.minimum_size_changed.connect(layout)
 world.get_viewport().size_changed.connect(layout)
 gallery.hide()
 root_control.hide()
 layout()

func make_button(parent: Node,title: String,callback: Callable) -> Button:
 var button=world.hud.button(parent,title,callback)
 button.add_theme_font_size_override("font_size",14)
 world.hud.compact_style(button,world.hud.PANEL)
 controls.append(button)
 return button

func layout() -> void:
 var size=world.get_viewport().get_visible_rect().size
 var inset=maxf(14,(size.x-760)/2)
 toolbar.offset_left=inset
 toolbar.offset_right=-inset
 toolbar.offset_top=-maxf(174,toolbar.get_combined_minimum_size().y+16)

func enter() -> void:
 if active or busy or not world.placement.is_empty(): return
 saved={"focus":world.view_focus,"zoom":world.view_zoom,"yaw":world.camera_yaw,"hud":world.hud.visible,"mask":world.camera.cull_mask,"routes":world.selection_world.visible,"render_scale":world.get_viewport().scaling_3d_scale}
 world.get_viewport().scaling_3d_scale=1.0
 world.focus=world.view_focus
 world.zoom=world.view_zoom
 world.set_camera()
 world.touches.clear()
 world.dragging=false
 world.right_drag=false
 world.hud.close_menu()
 world.hud.ux.hide_panels()
 active=true
 world.apply_camera()
 world.hud.ux.apply_fonts(root_control)
 world.hud.hide()
 world.selection_world.hide()
 world.camera.cull_mask=saved.mask & ~Models.WORLD_LABEL_LAYER
 root_control.show()
 status.text="DEIN STADTPANORAMA"
 gallery.hide()
 layout()

func leave() -> void:
 if not active or busy: return
 active=false
 world.get_viewport().scaling_3d_scale=float(saved.render_scale)
 root_control.hide()
 world.focus=saved.focus
 world.zoom=saved.zoom
 world.camera_yaw=saved.yaw
 world.set_camera()
 world.camera.cull_mask=saved.mask
 world.hud.visible=saved.hud
 world.selection_world.visible=saved.routes
 world.pan_velocity=Vector3.ZERO
 world.touches.clear()
 world.dragging=false
 world.right_drag=false

func capture() -> void:
 if not active or busy or DisplayServer.get_name()=="headless": return
 busy=true
 root_control.hide()
 # Allow visibility changes to reach a complete rendered frame before readback.
 await RenderingServer.frame_post_draw
 await RenderingServer.frame_post_draw
 var image=world.get_viewport().get_texture().get_image()
 var folder="user://Fotos"
 var result=DirAccess.make_dir_recursive_absolute(folder)
 if result==OK:
  last_path=folder.path_join("Timber-%s-%s.png" % [int(Time.get_unix_time_from_system()),Time.get_ticks_usec()])
  result=image.save_png(last_path)
 root_control.show()
 busy=false
 status.text="FOTO GESPEICHERT · Meine Fotos" if result==OK else "Speichern fehlgeschlagen · erneut versuchen"

func open_gallery() -> void:
 paths.clear()
 var directory=DirAccess.open("user://Fotos")
 if directory!=null:
  for file in directory.get_files():
   if file.begins_with("Timber-") and file.ends_with(".png"): paths.append("user://Fotos/"+file)
 paths.sort()
 paths.reverse()
 page=0
 gallery.show()
 show_page()

func show_page() -> void:
 if paths.is_empty():
  gallery_status.text="NOCH KEINE FOTOS · Nimm dein erstes Panorama auf"
  image_view.texture=null
  return
 page=clampi(page,0,paths.size()-1)
 var image=Image.load_from_file(paths[page])
 image_view.texture=ImageTexture.create_from_image(image) if image!=null else null
 gallery_status.text="FOTO %s / %s · auf diesem Gerät" % [page+1,paths.size()]

func _unhandled_key_input(event: InputEvent) -> void:
 if active and event.is_action_pressed("ui_cancel"):
  if gallery.visible: gallery.hide()
  else: leave()
  world.get_viewport().set_input_as_handled()
