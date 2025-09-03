extends Node3D

@export var seconds_per_orbit := 20.0   # Echtzeit-Sekunden für eine volle Runde
@export var orbit_radius := 30.0

var theta := 0.0

func _process(delta: float) -> void:
	theta = fmod(theta + TAU * delta / seconds_per_orbit, TAU)
	$PlanetRoot/Earth.global_position = Vector3(
		orbit_radius * cos(theta),
		0.0,
		orbit_radius * sin(theta)
	)
