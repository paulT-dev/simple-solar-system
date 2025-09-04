# Spin.gd
extends Node3D

@export var seconds_per_turn: float = 1.0	# z.B. Erde: 1.0  | Merkur: 58.646 | Venus: 243.025
@export var retrograde: bool = false
@export var axis: Vector3 = Vector3.UP
@export var use_local_axis: bool = true

func _process(delta: float) -> void:
	if seconds_per_turn == 0.0:
		return
	var dir := -1.0 if retrograde else 1.0
	var rad := dir * TAU * (delta / seconds_per_turn)	# TAU = 2π
	if use_local_axis:
		rotate_object_local(axis.normalized(), rad)
	else:
		rotate(axis.normalized(), rad)
