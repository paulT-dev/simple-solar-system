extends Node3D

@export var axial_tilt_deg: float = 23.44
@export var seconds_per_day: float = 24.0  # 24s = 1 Umdrehung (Demo)
var angle: float = 0.0

func _ready() -> void:
	rotation_degrees.x = axial_tilt_deg  # Achsneigung setzen

func _process(delta: float) -> void:
	angle = fmod(angle + 360.0 * delta / seconds_per_day, 360.0)
	rotation_degrees.y = angle
