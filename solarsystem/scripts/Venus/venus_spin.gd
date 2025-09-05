# VenusSpin.gd — Eigenrotation (retrograd via Achsneigung)
extends Node3D

@export var days_per_turn: float = 243.025	# ~243.025 Tage (sehr langsam)
@export var axial_tilt_deg: float = 177.36	# ~180° -> retrograder Effekt
@export var axis: Vector3 = Vector3.UP
@export var use_local_axis: bool = true

func _ready() -> void:
	rotation_degrees.x = axial_tilt_deg

func _process(delta: float) -> void:
	if days_per_turn <= 0.0:
		return
	var rad := TAU * (delta / (days_per_turn * SimGlobals.seconds_per_day))
	if use_local_axis:
		rotate_object_local(axis.normalized(), rad)
	else:
		rotate(axis.normalized(), rad)
