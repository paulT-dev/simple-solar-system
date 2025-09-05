# CameraSwitcher.gd
extends Node

@export var group_name: String = "cams"	# alle Camera3D in dieser Gruppe werden gefunden
@export var enable_number_keys: bool = true	# 1..9 direkt anwählbar

var cams: Array[Camera3D] = []
var idx := 0

func _ready() -> void:
	_collect_cameras()
	# Kameras, die später geladen/instanziert werden, automatisch aufnehmen
	get_tree().node_added.connect(_on_node_added)
	if cams.is_empty():
		push_warning("Keine Kameras in Gruppe '%s' gefunden." % group_name)
	else:
		_set_current(0)

func _on_node_added(n: Node) -> void:
	if n is Camera3D and n.is_in_group(group_name):
		cams.append(n)
		if cams.size() == 1:
			_set_current(0)

func _collect_cameras() -> void:
	cams.clear()
	for n in get_tree().get_nodes_in_group(group_name):
		if n is Camera3D:
			cams.append(n)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_N: _set_current(idx + 1)	# Next
			KEY_P: _set_current(idx - 1)	# Previous
			KEY_1: if enable_number_keys: _set_current(0)
			KEY_2: if enable_number_keys: _set_current(1)
			KEY_3: if enable_number_keys: _set_current(2)
			KEY_4: if enable_number_keys: _set_current(3)
			KEY_5: if enable_number_keys: _set_current(4)
			KEY_6: if enable_number_keys: _set_current(5)
			KEY_7: if enable_number_keys: _set_current(6)
			KEY_8: if enable_number_keys: _set_current(7)
			KEY_9: if enable_number_keys: _set_current(8)

func _set_current(i: int) -> void:
	if cams.is_empty():
		return
	idx = (i % cams.size() + cams.size()) % cams.size()  # wrap around
	# alle „entkoppeln“
	for c in cams:
		c.clear_current()
	# ausgewählte aktivieren
	var cur := cams[idx]
	cur.make_current()
	print("Aktive Kamera:", cur.name, "(", cur.get_path(), ")")
