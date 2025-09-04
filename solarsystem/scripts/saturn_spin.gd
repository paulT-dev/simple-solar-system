# SaturnSpin.gd – Eigenrotation (an Saturn-Spin-Node hängen)
extends Node3D

@export var seconds_per_turn: float = 0.440	# ~10h33m -> 0.440 Tage bei 1 s = 1 Tag
@export var axial_tilt_deg: float = 26.73
@export var retrograde: bool = false
@export var axis: Vector3 = Vector3.UP
@export var use_local_axis: bool = true

func _ready() -> void:
	rotation_degrees.x = axial_tilt_deg

func _process(delta: float) -> void:
	if seconds_per_turn <= 0.0:
		return
	var dir := 1.0
	if retrograde:
		dir = -1.0
	var rad := dir * TAU * (delta / seconds_per_turn)
	if use_local_axis:
		rotate_object_local(axis.normalized(), rad)
	else:
		rotate(axis.normalized(), rad)
