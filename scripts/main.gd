extends Node3D

const TARGET_SCENE := preload("res://scenes/target.tscn")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Simple target dummies for the first playable prototype.
	for i in range(5):
		var target = TARGET_SCENE.instantiate()
		target.position = Vector3(-6.0 + i * 3.0, 1.0, -5.0 - (i % 2) * 3.0)
		add_child(target)
