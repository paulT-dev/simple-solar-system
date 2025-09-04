# MoonSpin.gd — Eigenrotation (optional: Tidal-Lock zur Erde)
extends Node3D

@export var center_body: NodePath				# Erde (leer = Parent.Parent o. explizit setzen)
@export var seconds_per_turn: float = 27.3217	# = siderischer Monat (für synchrone Rotation)
@export var axial_tilt_deg: float = 6.68		# Achsneigung ~6.68° gegen Ekliptik
@export var tidal_lock: bool = true				# immer die gleiche Seite zur Erde?
@export var axis: Vector3 = Vector3.UP
@export var use_local_axis: bool = true

var _center: Node3D

func _ready() -> void:
	rotation_degrees.x = axial_tilt_deg
	if center_body != NodePath():
		_center = get_node_or_null(center_body) as Node3D
	if _center == null:
		# häufige Struktur: MoonSpin ist Child von Moon, dessen Parent ist Orbit, dessen Parent ist Erde
		var p := get_parent()
		if p != null:
			var gp := p.get_parent()
			if gp is Node3D:
				_center = gp as Node3D

func _process(delta: float) -> void:
	if tidal_lock and _center != null:
		# „immer zur Erde schauen“ (Vorwärtsachse -Z zeigt zur Erde)
		look_at(_center.global_position, Vector3.UP)
		return

	# freie Rotation (falls tidal_lock=false)
	if seconds_per_turn <= 0.0:
		return
	var rad := TAU * (delta / seconds_per_turn)
	if use_local_axis:
		rotate_object_local(axis.normalized(), rad)
	else:
		rotate(axis.normalized(), rad)
