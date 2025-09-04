# MarsKeplerOrbit.gd
extends Node3D

@export var AU_UNITS: float = 30.0			# 1 AU = 30 Units
@export var a_au: float = 1.523679			# große Halbachse (AU)
@export var e: float = 0.0934				# Exzentrizität
@export var i_deg: float = 1.850			# Inklination (°)
@export var Omega_deg: float = 49.558		# Länge des aufsteigenden Knotens (°)
@export var omega_deg: float = 286.502		# Argument des Perihels (°)

@export var days_per_orbit: float = 686.98	# siderische Umlaufzeit (Tage)
@export var seconds_per_day: float = 1.0	# 1 s = 1 Tag
@export var mean_anomaly_deg_at_t0: float = 0.0	# Startphase (M0 in °)

var t_days := 0.0

func _process(delta: float) -> void:
	# Simulationszeit in Tagen
	t_days += delta * seconds_per_day

	# Mittlere Anomalie M
	var M := TAU * (t_days / days_per_orbit) + deg_to_rad(mean_anomaly_deg_at_t0)

	# Exzentrische Anomalie E (Newton-Verfahren)
	var E := solve_kepler(M, e)

	# Wahrer Anomaliewinkel ν und Radius r (in AU)
	var cosE := cos(E)
	var sinE := sin(E)
	var r_au := a_au * (1.0 - e * cosE)
	var nu := atan2(sqrt(1.0 - e * e) * sinE, cosE - e)

	# Bahnorientierung
	var i := deg_to_rad(i_deg)
	var Omega := deg_to_rad(Omega_deg)
	var omega := deg_to_rad(omega_deg)
	var u := omega + nu

	# Position im ekliptischen Raum (Y = up in Godot)
	var x := r_au * (cos(Omega) * cos(u) - sin(Omega) * sin(u) * cos(i))
	var z := r_au * (sin(Omega) * cos(u) + cos(Omega) * sin(u) * cos(i))
	var y := r_au * (sin(i) * sin(u))

	# In Godot-Units skalieren (Sonne im Ursprung)
	global_position = Vector3(x * AU_UNITS, y * AU_UNITS, z * AU_UNITS)

func solve_kepler(M: float, ecc: float) -> float:
	# M in [-pi, pi] normalisieren (bessere Konvergenz)
	M = fmod(M + PI, TAU) - PI
	var E := 0.0
	if ecc < 0.8:
		E = M
	else:
		E = PI
	for _i in 8:
		var f := E - ecc * sin(E) - M
		var fp := 1.0 - ecc * cos(E)
		E -= f / fp
	return E
