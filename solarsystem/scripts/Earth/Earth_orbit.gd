# EarthKeplerOrbit.gd — elliptische Bahn um (0,0,0)
extends Node3D

@export var AU_UNITS: float = 30.0			# 1 AU = 30 Units
@export var a_au: float = 1.0				# große Halbachse (AU)
@export var e: float = 0.0167086			# Exzentrizität
@export var i_deg: float = 0.0				# Inklination (°) ~0 zur Ekliptik
@export var Omega_deg: float = 0.0			# Länge aufst. Knoten (°)
@export var omega_deg: float = 102.937		# Argument des Perihels (°)

@export var days_per_orbit: float = 365.256	# siderisches Jahr (Tage)
@export var mean_anomaly_deg_at_t0: float = 0.0	# Startphase M0 (°)

var t_days := 0.0

func _process(delta: float) -> void:
	t_days += delta / SimGlobals.seconds_per_day

	# Mittlere Anomalie M
	var M := TAU * (t_days / days_per_orbit) + deg_to_rad(mean_anomaly_deg_at_t0)

	# Exzentrische Anomalie E (Newton)
	var E := _solve_kepler(M, e)

	# Wahrer Anomaliewinkel ν und Radius r (AU)
	var cosE := cos(E)
	var sinE := sin(E)
	var r_au := a_au * (1.0 - e * cosE)
	var nu := atan2(sqrt(1.0 - e * e) * sinE, cosE - e)

	# Bahnorientierung
	var i := deg_to_rad(i_deg)
	var Omega := deg_to_rad(Omega_deg)
	var omega := deg_to_rad(omega_deg)
	var u := omega + nu

	# Position (Y = up)
	var x := r_au * (cos(Omega) * cos(u) - sin(Omega) * sin(u) * cos(i))
	var z := r_au * (sin(Omega) * cos(u) + cos(Omega) * sin(u) * cos(i))
	var y := r_au * (sin(i) * sin(u))

	global_position = Vector3(x * AU_UNITS, y * AU_UNITS, z * AU_UNITS)

func _solve_kepler(M: float, ecc: float) -> float:
	# bessere Konvergenz
	M = fmod(M + PI, TAU) - PI
	var E: float = M if ecc < 0.8 else PI
	for _i in 8:
		var f := E - ecc * sin(E) - M
		var fp := 1.0 - ecc * cos(E)
		E -= f / fp
	return E
