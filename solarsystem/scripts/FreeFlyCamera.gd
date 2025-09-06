# FreeFlyCamera.gd (mit Zoom)
extends Node3D

@export var move_speed: float = 0.1
@export var min_speed: float = 0.1
@export var max_speed: float = 10000.0
@export var mouse_sense: float = 0.0025
@export var boost_mult: float = 10.0
@export var slow_mult: float = 0.25
@export var invert_y: bool = false
@export var pitch_limit_deg: float = 89.0

# Zoom-Parameter
@export var fov_min: float = 20.0
@export var fov_max: float = 90.0
@export var fov_step: float = 2.0		# pro Mausrad-Klick bei Ctrl
@export var dolly_step: float = 5.0		# Units pro Mausrad-Klick bei Alt

var yaw := 0.0
var pitch := 0.0
var captured := false

@onready var pivot: Node3D = $Pivot
@onready var cam: Camera3D = $Pivot/Camera3D

func _ready() -> void:
	# Startwerte aus aktueller Ausrichtung übernehmen
	yaw = rotation.y
	pitch = pivot.rotation.x
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Optional sinnvoll fürs Sonnensystem:
	if cam:
		cam.far = 4000.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			captured = !captured
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			# Ctrl + Wheel: FOV-Zoom (optisch)
			if event.ctrl_pressed and cam:
				cam.fov = clamp(cam.fov - fov_step, fov_min, fov_max)
			# Alt + Wheel: Dolly (vor/zurück entlang Blickrichtung)
			elif event.alt_pressed:
				translate(-transform.basis.z * dolly_step)
			# sonst: Bewegungsgeschwindigkeit anpassen
			else:
				move_speed = clamp(move_speed * 1.1, min_speed, max_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if event.ctrl_pressed and cam:
				cam.fov = clamp(cam.fov + fov_step, fov_min, fov_max)
			elif event.alt_pressed:
				translate(transform.basis.z * dolly_step)
			else:
				move_speed = clamp(move_speed / 1.1, min_speed, max_speed)

	elif event is InputEventMouseMotion and captured:
		yaw -= event.relative.x * mouse_sense
		var dy = event.relative.y * mouse_sense * ( -1.0 if invert_y else 1.0 )
		pitch = clamp(pitch + dy, deg_to_rad(-pitch_limit_deg), deg_to_rad(pitch_limit_deg))
		rotation.y = yaw
		pivot.rotation.x = pitch

func _process(delta: float) -> void:
	var speed := move_speed
	if Input.is_key_pressed(KEY_SHIFT):
		speed *= boost_mult
	if Input.is_key_pressed(KEY_CTRL):
		speed *= slow_mult

	var dir := Vector3.ZERO
	# Vor/Zurück/Links/Rechts relativ zur Blickrichtung
	if Input.is_key_pressed(KEY_W):
		dir -= transform.basis.z
	if Input.is_key_pressed(KEY_S):
		dir += transform.basis.z
	if Input.is_key_pressed(KEY_A):
		dir -= transform.basis.x
	if Input.is_key_pressed(KEY_D):
		dir += transform.basis.x
	# Vertikal: E hoch, Q runter (Space optional hoch)
	if Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_SPACE):
		dir += Vector3.UP
	if Input.is_key_pressed(KEY_Q):
		dir -= Vector3.UP

	if dir != Vector3.ZERO:
		dir = dir.normalized()
		translate(dir * speed * delta)
