# EarthOrbit.gd
extends Node3D

@export var AU_UNITS: float = 30.0		# 1 AU = 30 Units
@export var a_au: float = 1.0			# Erdbahn-Radius (Kreis)
@export var days_per_orbit: float = 365.256	# siderisches Jahr
@export var seconds_per_day: float = 1.0	# 1 s = 1 Tag (wie bei dir)
@export var orbit_incl_deg: float = 0.0	# i=0: Ekliptik-Ebene
@export var start_phase_deg: float = 0.0	# Startwinkel auf der Bahn

var t_days := 0.0

func _process(delta: float) -> void:
	# Zeit in "Tagen" hochzählen
	t_days += delta * seconds_per_day

	# Winkel und Kreisbahn-Position
	var theta := TAU * (t_days / days_per_orbit) + deg_to_rad(start_phase_deg)
	var r := a_au * AU_UNITS
	var pos := Vector3(r * cos(theta), 0.0, r * sin(theta))

	# Optionale Bahnneigung
	if orbit_incl_deg != 0.0:
		pos = pos.rotated(Vector3.RIGHT, deg_to_rad(orbit_incl_deg))

	# Sonne bei (0,0,0)
	global_position = pos
