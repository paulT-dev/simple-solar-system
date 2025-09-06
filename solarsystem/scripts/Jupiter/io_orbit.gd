# IoKeplerOrbit.gd — elliptische Bahn RELATIV zu Jupiter
extends Node3D

@export var center_body: NodePath				# Jupiter (leer = Parent)
@export var AU_UNITS: float = 30.0				# 1 AU = 30 Units
@export var distance_scale: float = 1.0			# zusätzl. Sichtbarkeits-Skala

# Bahndaten (nahe J2000, ekliptikbezogen; Demo-tauglich)
@export var a_au: float = 0.002819				# ~421,700 km
@export var e: float = 0.0041
@export var i_deg: float = 0.04
@export var Omega_deg: float = 0.0
@export var omega_deg: float = 0.0

@export var days_per_orbit: float = 1.769137	# siderische Umlaufzeit (Tage)
@export var mean_anomaly_deg_at_t0: float = 0.0	# Startphase

var _t_days := 0.0
var _center: Node3D

func _ready() -> void:
	if center_body != NodePath():
		_center = get_node_or_null(center_body) as Node3D
	if _center == null:
		_center = get_parent() as Node3D

func _process(delta: float) -> void:
	# simulierte Tage (global skaliert)
	_t_days += delta / SimGlobals.seconds_per_day

	# Mittlere Anomalie
	var M := TAU * (_t_days / days_per_orbit) + deg_to_rad(mean_anomaly_deg_at_t0)

	# Kepler lösen (exzentrische Anomalie)
	var E := _solve_kepler(M, e)

	# Wahrer Anomaliewinkel ν und Radius r (in AU)
	var cosE := cos(E)
	var sinE := sin(E)
	var r_au := a_au * (1.0 - e * cosE)
	var nu := atan2(sqrt(1.0 - e * e) * sinE, cosE - e)

	# Orientierung (Ekliptik-Referenz)
	var i := deg_to_rad(i_deg)
	var Omega := deg_to_rad(Omega_deg)
	var omega := deg_to_rad(omega_deg)
	var u := omega + nu

	# Position relativ zu Jupiter (Godot: Y = up)
	var x := r_au * (cos(Omega) * cos(u) - sin(Omega) * sin(u) * cos(i))
	var z := -r_au * (sin(Omega) * cos(u) + cos(Omega) * sin(u) * cos(i))
	var y := r_au * (sin(i) * sin(u))

	var offset := Vector3(x, y, z) * AU_UNITS * distance_scale
	var center_pos: Vector3 = Vector3.ZERO
	if _center != null:
		center_pos = _center.global_position
	global_position = center_pos + offset

func _solve_kepler(M: float, ecc: float) -> float:
	M = fmod(M + PI, TAU) - PI
	var E: float = M
	if ecc >= 0.8:
		E = PI
	for _i in 8:
		var f := E - ecc * sin(E) - M
		var fp := 1.0 - ecc * cos(E)
		E -= f / fp
	return E
