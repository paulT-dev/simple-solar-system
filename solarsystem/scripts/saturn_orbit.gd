# SaturnKeplerOrbit.gd – elliptische Bahn um (0,0,0)
extends Node3D

@export var AU_UNITS: float = 30.0
@export var a_au: float = 9.5826
@export var e: float = 0.0565
@export var i_deg: float = 2.485
@export var Omega_deg: float = 113.715
@export var omega_deg: float = 339.392

@export var days_per_orbit: float = 10759.0	# ~29.46 Jahre
@export var seconds_per_day: float = 1.0
@export var mean_anomaly_deg_at_t0: float = 0.0

var t_days := 0.0

func _process(delta: float) -> void:
	t_days += delta * seconds_per_day

	var M := TAU * (t_days / days_per_orbit) + deg_to_rad(mean_anomaly_deg_at_t0)
	var E := solve_kepler(M, e)

	var cosE := cos(E)
	var sinE := sin(E)
	var r_au := a_au * (1.0 - e * cosE)
	var nu := atan2(sqrt(1.0 - e * e) * sinE, cosE - e)

	var i := deg_to_rad(i_deg)
	var Omega := deg_to_rad(Omega_deg)
	var omega := deg_to_rad(omega_deg)
	var u := omega + nu

	var x := r_au * (cos(Omega) * cos(u) - sin(Omega) * sin(u) * cos(i))
	var z := r_au * (sin(Omega) * cos(u) + cos(Omega) * sin(u) * cos(i))
	var y := r_au * (sin(i) * sin(u))

	global_position = Vector3(x * AU_UNITS, y * AU_UNITS, z * AU_UNITS)

func solve_kepler(M: float, ecc: float) -> float:
	M = fmod(M + PI, TAU) - PI
	var E: float = M if ecc < 0.8 else PI
	for _i in 8:
		var f := E - ecc * sin(E) - M
		var fp := 1.0 - ecc * cos(E)
		E -= f / fp
	return E
