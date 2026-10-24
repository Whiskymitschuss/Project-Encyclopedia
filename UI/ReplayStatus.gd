extends CanvasLayer
var meter: ProgressBar
var detail: Label
var artwork: Control
func _ready() -> void:
 layer=100
 process_mode=Node.PROCESS_MODE_ALWAYS
 artwork=load("res://UI/LoadingArtwork.gd").new()
 add_child(artwork)
 meter=artwork.meter
 detail=artwork.subtitle
 _process(0)
func _process(_delta: float) -> void:
 artwork.progress(Game.replay_progress()*100,"DEINE FIRMA WIRD AKTUALISIERT","Fortschritt seit deiner letzten Sitzung wird berechnet.")
