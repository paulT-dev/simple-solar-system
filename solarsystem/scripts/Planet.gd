extends Node3D

@export var display_name: String = "Planet"
@export var radius_units: float = 0.6
@export var albedo_tex: Texture2D
@export var spin_deg_per_sec: float = 5.0

func _ready() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = radius_units
	($Mesh as MeshInstance3D).mesh = sphere

	var mat := StandardMaterial3D.new()
	if albedo_tex:
		mat.albedo_texture = albedo_tex
	mat.roughness = 0.9
	($Mesh as MeshInstance3D).material_override = mat

func _process(delta: float) -> void:
	rotate_y(deg_to_rad(spin_deg_per_sec) * delta)
