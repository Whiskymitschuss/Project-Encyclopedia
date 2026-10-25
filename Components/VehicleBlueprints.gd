class_name VehicleBlueprints
extends RefCounted
static var scenes={}
static func create(path: String,fallback: String) -> Node3D:
 if ResourceLoader.exists(path):
  if not scenes.has(path):
   if scenes.size()>=24:scenes.clear()
   scenes[path]=load(path)
  return scenes[path].instantiate()
 return load(fallback).new()
static func truck(tier: int,fleet: String,dump: bool) -> Node3D:
 return create("res://Assets/Baked/%s-%s-%s.scn" % ["dump" if dump else "truck",tier,fleet],"res://Vehicles/DumpTruck.gd" if dump else "res://Vehicles/Truck.gd")
static func crew_van() -> Node3D:
 return create("res://Assets/Baked/crew-van.scn","res://Vehicles/CrewVan.gd")
