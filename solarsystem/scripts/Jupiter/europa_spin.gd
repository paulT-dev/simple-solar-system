# EuropaSpin.gd — Eigenrotation (synchron, optional Tidal-Lock)
extends Node3D

@export var center_body: NodePath				# Jupiter (für Tidal-Lock)
@export var days_per_turn: float = 3.551181	# synchron zur Umlaufzeit
@export var axial_tilt_deg: float = 0.1			# ~0.1° ggü. Jupiter, Demo-Wert
@export var tidal_lock: bool = true
@export var axis: Vector3 = Vector3.UP
@export var use_local_axis: bool = true

var _center: Node3D

func _ready() -> void:
	rotation_degrees.x = axial_tilt_deg
	if center_body != NodePath():
		_center = get_node_or_null(center_body) as Node3D
	if _center == null:
		_center = get_parent() as Node3D

func _process(delta: float) -> void:
	if tidal_lock and _center != null:
		if not global_position.is_equal_approx(_center.global_position):
			look_at(_center.global_position, Vector3.UP)
		return

	if days_per_turn <= 0.0:
		return
	var rad := TAU * (delta / (SimGlobals.seconds_per_day * days_per_turn))
	if use_local_axis:
		rotate_object_local(axis.normalized(), rad)
	else:
		rotate(axis.normalized(), rad)
