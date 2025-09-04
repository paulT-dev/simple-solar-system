# SunSpin.gd
extends Node3D

@export var seconds_per_turn: float = 25.38	# ~25.38 Tage (äquatorial, sidereal)
@export var axial_tilt_deg: float = 7.25	# Neigung zur Ekliptik
@export var axis: Vector3 = Vector3.UP
@export var use_local_axis: bool = true
@export var retrograde: bool = false

func _ready() -> void:
	rotation_degrees.x = axial_tilt_deg

func _process(delta: float) -> void:
	if seconds_per_turn <= 0.0:
		return
	var dir := -1.0 if retrograde else 1.0
	var rad := dir * TAU * (delta / seconds_per_turn)
	if use_local_axis:
		rotate_object_local(axis.normalized(), rad)
	else:
		rotate(axis.normalized(), rad)
