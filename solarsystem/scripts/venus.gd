# Venus.gd
extends Node3D

# Orbit / Maßstab
@export var AU_UNITS: float = 30.0
@export var a_au: float = 0.723332
@export var days_per_orbit: float = 224.701
@export var seconds_per_day: float = 1.0
@export var orbit_incl_deg: float = 3.3947

# Eigenrotation (wie bei Merkur)
@export var axial_tilt_deg: float = 177.36	# ~180° -> retrograder Effekt ohne Vorzeichen-Trick
@export var days_per_rotation: float = 243.025

var t_days := 0.0
var spin_angle := 0.0

func _ready() -> void:
	rotation_degrees.x = axial_tilt_deg

func _process(delta: float) -> void:
	# --- Orbit (Kreis um (0,0,0)) ---
	t_days += delta * seconds_per_day
	var theta := TAU * (t_days / days_per_orbit)
	var r := a_au * AU_UNITS
	var pos := Vector3(r * cos(theta), 0.0, r * sin(theta))
	if orbit_incl_deg != 0.0:
		pos = pos.rotated(Vector3.RIGHT, deg_to_rad(orbit_incl_deg))
	global_position = pos

	# --- Eigenrotation (identisch zu Merkur-Logik) ---
	var seconds_per_rotation := days_per_rotation * seconds_per_day
	if seconds_per_rotation > 0.0:
		spin_angle = fmod(spin_angle + 360.0 * delta / seconds_per_rotation, 360.0)
		rotation_degrees.y = spin_angle
