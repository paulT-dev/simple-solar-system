# OrbitTrailMultiMesh.gd — MultiMesh ohne per-Instance-Farben
extends Node3D

@export var follow_target: NodePath
@export var center: Vector3 = Vector3.ZERO
@export var axis: Vector3 = Vector3.UP
@export var degree_step: float = 1.0

@export var use_global_marker_radius := true
@export var marker_radius := 0.05 : set = _set_marker_radius
@export var unshaded := true
@export var alpha := 0.6

@export var max_markers := 360
@export var top_level_markers := true

var _target: Node3D
var _mmi: MultiMeshInstance3D
var _mm: MultiMesh
var _mat: StandardMaterial3D

var _u := Vector3.RIGHT
var _v := Vector3.FORWARD
var _have_last := false
var _last_angle := 0.0
var _accum := 0.0

var _write_idx := 0
var _count := 0
var _last_global_radius := -1.0

func _ready() -> void:
	# Ziel
	if follow_target != NodePath():
		_target = get_node_or_null(follow_target) as Node3D
	if _target == null:
		_target = (get_parent() as Node3D) if get_parent() is Node3D else self

	# MultiMesh
	_mm = MultiMesh.new()
	_mm.transform_format = MultiMesh.TRANSFORM_3D
	_mm.instance_count = max_markers

	# Mesh + Material
	var sphere := SphereMesh.new()
	sphere.radial_segments = 8
	sphere.rings = 6
	sphere.radius = 1.0 # wir skalieren per Transform
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = Color(1,1,1,alpha)
	if unshaded:
		_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	sphere.material = _mat
	_mm.mesh = sphere

	# Instance
	_mmi = MultiMeshInstance3D.new()
	_mmi.multimesh = _mm
	if top_level_markers:
		_mmi.top_level = true
		_mmi.global_transform = Transform3D.IDENTITY
	add_child(_mmi)

	# Basis initialisieren
	_rebuild_plane_basis()
	if use_global_marker_radius:
		_apply_radius(SimGlobals.trail_sphere_size)

	# Instanzen neutral setzen (am Ursprung „unsichtbar klein“)
	var id_t := Transform3D(Basis.IDENTITY.scaled(Vector3(0.0001,0.0001,0.0001)), Vector3.ZERO)
	for i in _mm.instance_count:
		_mm.set_instance_transform(i, id_t)

func _process(_dt: float) -> void:
	if use_global_marker_radius:
		var r := SimGlobals.trail_sphere_size
		if not is_equal_approx(r, _last_global_radius):
			_apply_radius(r)

	var pos := _target.global_position
	var ang := _angle_deg(pos)

	if not _have_last:
		_have_last = true
		_last_angle = ang
		_accum = 0.0
		_drop_marker(pos)
		return

	var diff := ang - _last_angle
	diff = fposmod(diff + 180.0, 360.0) - 180.0
	_accum += abs(diff)
	_last_angle = ang

	while _accum >= degree_step:
		_accum -= degree_step
		_drop_marker(pos)

func _drop_marker(pos: Vector3) -> void:
	var basis := Basis.IDENTITY.scaled(Vector3.ONE * marker_radius)
	var xform := Transform3D(basis, pos)
	_mm.set_instance_transform(_write_idx, xform)
	_write_idx = (_write_idx + 1) % max_markers
	_count = min(_count + 1, max_markers)

func _set_marker_radius(v: float) -> void:
	marker_radius = max(0.001, v)
	# existierende Marker neu skalieren (Position beibehalten)
	for i in _count:
		var t := _mm.get_instance_transform(i)
		var pos := t.origin
		var basis := Basis.IDENTITY.scaled(Vector3.ONE * marker_radius)
		_mm.set_instance_transform(i, Transform3D(basis, pos))

func _apply_radius(r: float) -> void:
	_last_global_radius = max(0.001, r)
	_set_marker_radius(_last_global_radius)

func _rebuild_plane_basis() -> void:
	var n := axis.normalized()
	var ref := Vector3.RIGHT
	if abs(n.dot(ref)) > 0.9:
		ref = Vector3.FORWARD
	_u = (ref - n * ref.dot(n)).normalized()
	_v = n.cross(_u).normalized()

func _angle_deg(world_pos: Vector3) -> float:
	var v := world_pos - center
	var x := v.dot(_u)
	var y := v.dot(_v)
	var a := rad_to_deg(atan2(y, x))
	return a + 360.0 if a < 0.0 else a
