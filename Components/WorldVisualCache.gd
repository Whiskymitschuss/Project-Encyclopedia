class_name WorldVisualCache
extends RefCounted

# Owns presentation instances only. Inventories, jobs and transport reservations
# remain in Game; moving a camera never creates or removes an economic object.
var instances={}
var used={}
var created=0
var reused=0
var retired=0
func begin() -> void:
 used.clear()
func take(id: String,revision: Variant,create: Callable) -> Node3D:
 var key=hash(revision)
 if instances.has(id):
  var entry=instances[id]
  if is_instance_valid(entry.node) and entry.revision==key:
   used[id]=true;reused+=1
   return entry.node
  dispose(entry.node)
 var node: Node3D=create.call()
 instances[id]={"node":node,"revision":key}
 used[id]=true;created+=1
 return node
func dispose(node: Node3D) -> void:
 if not is_instance_valid(node):return
 if node.get_parent()!=null:node.get_parent().remove_child(node)
 node.queue_free();retired+=1
func finish() -> void:
 for id in instances.keys():
  if used.has(id):continue
  dispose(instances[id].node);instances.erase(id)
