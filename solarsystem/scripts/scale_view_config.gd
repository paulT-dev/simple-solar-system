# MainConfig.gd
extends Node
@export var seconds_per_day: float = 1.0   # z. B. 1.0 (1 s = 1 Tag) oder 0.2
@export var trail_size: float = 0.05

func _ready() -> void:
	SimGlobals.seconds_per_day = seconds_per_day
	SimGlobals.trail_sphere_size = trail_size
