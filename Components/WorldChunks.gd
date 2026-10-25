class_name WorldChunks
extends Node

# Virtual 64-unit cells preserve the public scene paths and all saved IDs.
# Only rendering/animation is suspended; the independent Game tick still owns
# every factory, worker, shipment and construction site, even off camera.
const CELL=64.0
var world: Node3D
var cells={}
var clock=0.0
var last_key=[]
var visible_cells=0
var sleeping_models=0
var updates=0
func reindex() -> void:
 cells.clear()
 for model in world.world_buildings.get_children():
  if not model.get_meta("chunk_visual",false):continue
  var point=Vector2(model.position.x,model.position.z)
  var id=Vector2i(floori(point.x/CELL),floori(point.y/CELL))
  if not cells.has(id):cells[id]=[]
  cells[id].append(model)
  if not model.has_meta("chunk_process"):model.set_meta("chunk_process",model.process_mode)
 last_key=[]
 update_view(true)
func intersects_view(id: Vector2i) -> bool:
 var bounds=Rect2()
 var first=true
 # Conservative bounds include tall level-10 buildings and loading aprons.
 for x in [id.x*CELL-28,(id.x+1)*CELL+28]:
  for z in [id.y*CELL-28,(id.y+1)*CELL+28]:
   for y in [-2,80]:
    var point=Vector3(x,y,z)
    if world.camera.is_position_behind(point):return true
    var screen=world.camera.unproject_position(point)
    if first:bounds=Rect2(screen,Vector2.ZERO);first=false
    else:bounds=bounds.expand(screen)
 return bounds.intersects(world.get_viewport().get_visible_rect().grow(80))
func update_view(force: bool=false) -> void:
 if world.camera==null:return
 var key=[snappedf(world.view_focus.x,8),snappedf(world.view_focus.z,8),snappedf(world.view_zoom,8),snappedf(world.camera_yaw,0.04),world.get_viewport().get_visible_rect().size]
 if not force and key==last_key:return
 last_key=key;updates+=1;visible_cells=0;sleeping_models=0
 var measured=RuntimeStats.begin_work()
 for id in cells:
  var show=intersects_view(id)
  if show:visible_cells+=1
  for model in cells[id]:
   if not is_instance_valid(model):continue
   if model.visible!=show:model.visible=show
   var mode=int(model.get_meta("chunk_process")) if show else Node.PROCESS_MODE_DISABLED
   if model.process_mode!=mode:model.process_mode=mode
   if not show:sleeping_models+=1
 RuntimeStats.end_work("Sichtbereiche",measured)
func _process(delta: float) -> void:
 clock+=delta
 if clock<0.15:return
 clock=0
 update_view()
func restore_all() -> void:
 for models in cells.values():
  for model in models:
   if is_instance_valid(model):
    model.visible=true;model.process_mode=int(model.get_meta("chunk_process"))
