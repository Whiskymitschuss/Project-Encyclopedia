extends Node3D
var building_index=-1
var clock=0.0
var lens: MeshInstance3D
var status="ready"
func _ready() -> void:
 Models.cylinder(self,0.08,1.1,Vector3(0,0.55,0),Color("4b6370"))
 Models.bake(self)
 lens=Models.cylinder(self,0.25,0.55,Vector3(0,1.35,0),Color("4b6370"))
func _process(delta: float) -> void:
 clock+=delta
 if clock<0.5: return
 clock=0
 visible=PresentationBudget.detailed(self)
 if not visible or building_index<0 or building_index>=Game.state.buildings.size(): return
 status=ProductionPresentation.describe(Game,building_index).kind
 lens.material_override=Models.material({"missing":Color("df634b"),"full":Color("e7ad43"),"running":Color("61b982")}.get(status,Color("4b6370")),status in ["missing","full","running"])
