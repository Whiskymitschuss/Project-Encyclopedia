class_name TownModels
extends RefCounted

# Preserve the existing scene/model entry point and stored building IDs.
static func create(kind: String,level: int) -> Node3D:
 return CityEvolution.create(kind,level,Game.state.skin)
