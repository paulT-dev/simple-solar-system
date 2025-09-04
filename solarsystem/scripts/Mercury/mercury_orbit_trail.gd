# OrbitTrail.gd — 1 Marker pro Winkel-Schritt (Standard 1°)
extends Node3D

# Ziel: leer = Parent tracken
@export var follow_target: NodePath

# Winkel-Setup
@export var center: Vector3 = Vector3.ZERO	# Bezugspunkt (Sonne)
@export var axis: Vector3 = Vector3.UP		# Rotationsachse (Y-Achse)
@export var degree_step: float = 1.0		# 1 Marker je X Grad

# Marker-Erscheinung
@export var marker_radius: float = 0.05
@export var marker_color: Color = Color(1,1,1,0.6)
@export var unshaded: bool = true

# Sicherheit/Performance
@export var max_markers: int = 360			# älteste werden entfernt
@export var top_level_markers: bool = true	# Marker bleiben an Weltkoordinaten

var _target: Node3D
var _markers_root: Node3D
var _counter := 0

# Winkel-Basis (u,v) in der Ebene ⟂ axis
var _u := Vector3.RIGHT
var _v := Vector3.FORWARD
var _have_last := false
var _last_angle := 0.0
var _accum := 0.0

func _ready() -> void:
	# Ziel bestimmen
	if follow_target != NodePath():
		_target = get_node_or_null(follow_target) as Node3D
	if _target == null:
		_target = get_parent() as Node3D
	if _target == null:
		_target = self

	# Container für Marker
	_markers_root = Node3D.new()
	_markers_root.name = "Markers"
	add_child(_markers_root)
	if top_level_markers:
		_markers_root.top_level = true
		_markers_root.global_transform = Transform3D.IDENTITY

	# Winkelbasis aus Achse berechnen
	_rebuild_plane_basis()

func _process(_delta: float) -> void:
	var pos := _target.global_position
	var ang := _angle_deg(pos)

	if not _have_last:
		_have_last = true
		_last_angle = ang
		_accum = 0.0
		_drop_marker(pos)
		return

	# signiertes kleinste-Differenz-Winkelmaß (-180..+180)
	var diff := ang - _last_angle
	diff = fposmod(diff + 180.0, 360.0) - 180.0
	_accum += abs(diff)
	_last_angle = ang

	while _accum >= degree_step:
		_accum -= degree_step
		_drop_marker(pos)

func _drop_marker(pos: Vector3) -> void:
	# Älteste entfernen, wenn voll
	if _markers_root.get_child_count() >= max_markers:
		var oldest := _markers_root.get_child(0)
		if oldest:
			oldest.queue_free()

	# Marker erstellen
	var m := MeshInstance3D.new()
	m.name = "mk_%d" % _counter
	_counter += 1

	if top_level_markers:
		m.top_level = true
		m.global_transform = Transform3D.IDENTITY

	# Kugel
	var sphere := SphereMesh.new()
	sphere.radius = marker_radius
	sphere.height = marker_radius
	m.mesh = sphere

	# Material
	var mat := StandardMaterial3D.new()
	mat.albedo_color = marker_color
	if unshaded:
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.material_override = mat

	_markers_root.add_child(m)
	m.global_position = pos

# ---- Hilfsfunktionen ----

func _rebuild_plane_basis() -> void:
	var n := axis.normalized()
	# Referenz wählen, die nicht parallel zur Achse ist
	var ref := Vector3.RIGHT
	if abs(n.dot(ref)) > 0.9:
		ref = Vector3.FORWARD
	# ref auf Ebene ⟂ n projizieren → u, dann v = n × u
	_u = (ref - n * ref.dot(n)).normalized()
	_v = n.cross(_u).normalized()

func _angle_deg(world_pos: Vector3) -> float:
	var v := world_pos - center
	var x := v.dot(_u)
	var y := v.dot(_v)
	var a := rad_to_deg(atan2(y, x))
	if a < 0.0:
		a += 360.0
	return a
