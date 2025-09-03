extends Node3D

@export var display_name: String = "Planet"
@export var radius_units: float = 0.6
@export var albedo_tex: Texture2D
@export var spin_deg_per_sec: float = 12.0

@onready var mesh: MeshInstance3D = $Mesh

func _ready() -> void:
	if mesh == null:
		push_error("[Planet.gd] Child 'Mesh' nicht gefunden.")
		return

	# Sphere setzen/aktualisieren
	if mesh.mesh == null:
		var sphere := SphereMesh.new()
		sphere.radius = radius_units
		mesh.mesh = sphere
	elif mesh.mesh is SphereMesh:
		(mesh.mesh as SphereMesh).radius = radius_units

	# Material + (optional) Textur
	var mat := mesh.material_override
	if mat == null:
		mat = StandardMaterial3D.new()
		mesh.material_override = mat
	if albedo_tex:
		(mat as StandardMaterial3D).albedo_texture = albedo_tex
		(mat as StandardMaterial3D).roughness = 0.9

func _process(delta: float) -> void:
	rotate_y(deg_to_rad(spin_deg_per_sec) * delta)
