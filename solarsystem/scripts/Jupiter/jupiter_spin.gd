# JupiterSpin.gd — Eigenrotation (separater Spin-Node)
extends Node3D

@export var seconds_per_turn: float = 0.41354	# ~9.925 h -> 0.41354 Tage
@export var axial_tilt_deg: float = 3.13
@export var axis: Vector3 = Vector3.UP
@export var use_local_axis: bool = true

func _ready() -> void:
	rotation_degrees.x = axial_tilt_deg

func _process(delta: float) -> void:
	if seconds_per_turn <= 0.0:
		return
	var rad := TAU * (delta / seconds_per_turn)
	if use_local_axis:
		rotate_object_local(axis.normalized(), rad)
	else:
		rotate(axis.normalized(), rad)
