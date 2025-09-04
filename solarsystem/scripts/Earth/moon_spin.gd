# MoonSpin.gd (robust)
extends Node3D

@export var center_body: NodePath			# optional: Erde hier zuweisen
@export var seconds_per_turn: float = 27.3217
@export var axial_tilt_deg: float = 6.68
@export var tidal_lock: bool = true
@export var axis: Vector3 = Vector3.UP
@export var use_local_axis: bool = true

var _center: Node3D

func _ready() -> void:
	rotation_degrees.x = axial_tilt_deg
	_resolve_center()

func _process(delta: float) -> void:
	if tidal_lock and _center != null:
		var pos := global_position
		var cpos := _center.global_position
		# Guard: nicht look_at() auf identische Position
		if pos.is_equal_approx(cpos):
			return
		look_at(cpos, Vector3.UP)
		return

	# freie Rotation (falls tidal_lock=false)
	if seconds_per_turn <= 0.0:
		return
	var rad := TAU * (delta / seconds_per_turn)
	if use_local_axis:
		rotate_object_local(axis.normalized(), rad)
	else:
		rotate(axis.normalized(), rad)

func _resolve_center() -> void:
	# 1) expliziter Pfad?
	if center_body != NodePath():
		_center = get_node_or_null(center_body) as Node3D
		if _center != null:
			return

	# 2) Gruppe 'earth' im gesamten Baum suchen
	var nodes := get_tree().get_nodes_in_group("earth")
	for n in nodes:
		if n is Node3D:
			_center = n
			return

	# 3) fallback: nächster Vorfahr, der 'Earth' heißt (nur als Notnagel)
	var a := get_parent()
	while a != null:
		if a.name.to_lower().contains("earth") and a is Node3D:
			_center = a as Node3D
			return
		a = a.get_parent()
