# UranusSpin.gd — Eigenrotation (starke Achsneigung, quasi „seitlich“)
extends Node3D

@export var days_per_turn: float = 0.71833	# ~17.24 h → 0.71833 Tage
@export var axial_tilt_deg: float = 97.77	# große Neigung → scheinbar retrograd
@export var axis: Vector3 = Vector3.UP
@export var use_local_axis: bool = true

func _ready() -> void:
	rotation_degrees.x = axial_tilt_deg

func _process(delta: float) -> void:
	if days_per_turn <= 0.0:
		return
	var rad := TAU * (delta / (SimGlobals.seconds_per_day * days_per_turn))
	if use_local_axis:
		rotate_object_local(axis.normalized(), rad)
	else:
		rotate(axis.normalized(), rad)
