extends Node3D

var world: Node3D
var borders: Node3D
var gate_label: Label3D
var status_clock=0.0
var border_unlocked=-1

func _ready() -> void:
 build_highway()
 borders=Node3D.new()
 add_child(borders)
 refresh_borders()
 Game.rebuild_world.connect(refresh_borders)

func build_highway() -> void:
 var structure=Node3D.new()
 add_child(structure)
 # Raised through road with a private ascending on-ramp; the public road stops
 # at the striped gate. No invisible connection to the player's network.
 var deck=Models.box(structure,Vector3(18,1,128),Vector3(330,3.1,140),Color("536c74"))
 deck.material_override=SurfaceLibrary.material(Color("536c74"),"asphalt")
 for x in [320.5,339.5]:
  Models.box(structure,Vector3(0.6,0.7,128),Vector3(x,4,140),Color("d2dad2"))
 Models.box(structure,Vector3(0.7,0.45,128),Vector3(330,3.9,140),Color("b8cabf"))
 for z in range(80,201,12):
  for x in [324,336]: Models.box(structure,Vector3(0.3,0.04,5),Vector3(x,3.63,z),Color("f8ebbf"))
 for z in range(88,201,24):
  for x in [324,336]: Models.box(structure,Vector3(1.3,4.5,1.3),Vector3(x,0.45,z),Color("a4aaa0"))
 var ramp=Models.box(structure,Vector3(27,0.6,7),Vector3(312,2.15,176),Color("6b8180"))
 ramp.material_override=SurfaceLibrary.material(Color("6b8180"),"asphalt")
 ramp.rotation.z=atan2(3.15,24.0)
 for z in [172,180]:
  var rail=Models.box(structure,Vector3(26,0.5,0.4),Vector3(312,3.15,z),Color("d0d8c9"))
  rail.rotation.z=atan2(3.15,24.0)
 Models.paving_box(structure,Vector3(18,0.25,12),Vector3(294,0.55,165),Color("b9bba6"))
 Models.crafted_box(structure,Vector3(7,5,6),Vector3(294,3.1,165),Color("e6dcc0"))
 Models.box(structure,Vector3(8,0.6,7),Vector3(294,5.9,165),Color("327178"))
 Models.box(structure,Vector3(4,1.7,0.14),Vector3(294,3.6,168.08),Color("81c9d1"))
 for z in [172,180]: Models.box(structure,Vector3(1,5.7,1),Vector3(300,3,z),Color("cbd3bd"))
 Models.box(structure,Vector3(1,2,10),Vector3(300,6.7,176),Color("246982"))
 for z in range(173,180,2): Models.box(structure,Vector3(1.3,0.04,0.8),Vector3(300,0.74,z),Color("f7dc83"))
 Models.bake(structure)
 Models.label(self,"AUTOBAHN · EXPORT",Vector3(307,11,172),29)
 gate_label=Models.label(self,"Straße verbinden",Vector3(294,8.7,161),24)

func refresh_borders() -> void:
 if borders==null or border_unlocked==int(Game.state.unlocked): return
 border_unlocked=int(Game.state.unlocked)
 for node in borders.get_children(): borders.remove_child(node); node.queue_free()
 for i in range(int(Game.state.unlocked),Catalog.BIOMES.size()):
  var center=Catalog.biome_position(i)
  for step in 40:
   var angle=TAU*step/40
   var next=TAU*(step+0.7)/40
   var a=center+Vector3(cos(angle)*WorldAccess.BIOME_RADIUS.x,0.75,sin(angle)*WorldAccess.BIOME_RADIUS.y)
   var b=center+Vector3(cos(next)*WorldAccess.BIOME_RADIUS.x,0.75,sin(next)*WorldAccess.BIOME_RADIUS.y)
   var piece=Models.box(borders,Vector3(0.35,0.12,a.distance_to(b)),(a+b)/2,Color("e8b56b"))
   piece.rotation.y=atan2(b.x-a.x,b.z-a.z)
 Models.bake(borders)
 for i in world.biome_labels.size():
  world.biome_labels[i].text=("ZU · " if i>=int(Game.state.unlocked) else "")+str(Catalog.BIOMES[i].name)

func _process(delta: float) -> void:
 status_clock+=delta
 if status_clock<1: return
 status_clock=0
 gate_label.text="EXPORT · verbunden" if not ExportTrade.route(Game.state).is_empty() else "Straße verbinden"
 gate_label.modulate=Color("c5edbf") if not ExportTrade.route(Game.state).is_empty() else Color("ffe0a5")
