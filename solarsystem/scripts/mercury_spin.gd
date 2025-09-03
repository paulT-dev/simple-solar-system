# Mercury.gd
extends Node3D

# Maßstab/Orbit
@export var AU_UNITS: float = 30.0
@export var a_au: float = 0.387
@export var days_per_orbit: float = 87.969
@export var seconds_per_day: float = 1.0
@export var orbit_incl_deg: float = 7.0

# Eigenrotation
@export var axial_tilt_deg: float = 0.034
@export var days_per_rotation: float = 58.646

var t_days := 0.0
var spin_angle := 0.0

func _ready() -> void:
	rotation_degrees.x = axial_tilt_deg

func _process(delta: float) -> void:
	# Zeitfortschritt in "Tagen"
	t_days += delta * seconds_per_day

	# Orbit (Kreis um Ursprung)
	var theta := TAU * (t_days / days_per_orbit)
	var r := a_au * AU_UNITS
	var pos := Vector3(r * cos(theta), 0.0, r * sin(theta))
	if orbit_incl_deg != 0.0:
		var inc := deg_to_rad(orbit_incl_deg)
		pos = pos.rotated(Vector3.RIGHT, inc)

	global_position = pos

	# Eigenrotation
	var seconds_per_rotation := days_per_rotation * seconds_per_day
	if seconds_per_rotation > 0.0:
		spin_angle = fmod(spin_angle + 360.0 * delta / seconds_per_rotation, 360.0)
		rotation_degrees.y = spin_angle
