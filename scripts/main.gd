extends Node3D

const TARGET_SCENE := preload("res://scenes/target.tscn")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_build_training_arena()
	for i in range(6):
		var target = TARGET_SCENE.instantiate()
		target.position = Vector3(-7.5 + i * 3.0, 1.0, -8.0 - (i % 2) * 2.5)
		add_child(target)

func _build_training_arena() -> void:
	# Colorful low-poly training yard built from primitives, so no extra assets are needed.
	var blue := _material(Color(0.08, 0.35, 0.85))
	var orange := _material(Color(1.0, 0.42, 0.08))
	var teal := _material(Color(0.05, 0.62, 0.55))
	var yellow := _material(Color(1.0, 0.78, 0.12))
	var gray := _material(Color(0.25, 0.29, 0.35))
	var white := _material(Color(0.78, 0.84, 0.9))

	# Perimeter walls
	_add_box("BackWall", Vector3(0, 1.5, -19), Vector3(40, 3, 0.6), blue)
	_add_box("LeftWall", Vector3(-19, 1.5, 0), Vector3(0.6, 3, 38), teal)
	_add_box("RightWall", Vector3(19, 1.5, 0), Vector3(0.6, 3, 38), orange)
	_add_box("FrontWallLeft", Vector3(-13, 1.5, 19), Vector3(12, 3, 0.6), yellow)
	_add_box("FrontWallRight", Vector3(13, 1.5, 19), Vector3(12, 3, 0.6), yellow)

	# Containers and waist-high cover
	_add_box("BlueContainer", Vector3(-10, 1.2, -5), Vector3(4, 2.4, 3), blue)
	_add_box("OrangeContainer", Vector3(10, 1.2, -7), Vector3(4, 2.4, 3), orange)
	_add_box("TealContainer", Vector3(12, 1.2, 5), Vector3(3, 2.4, 4), teal)
	_add_box("CoverA", Vector3(-5, 0.65, 1), Vector3(3, 1.3, 1.2), yellow)
	_add_box("CoverB", Vector3(3, 0.65, -2), Vector3(3, 1.3, 1.2), blue)
	_add_box("CoverC", Vector3(7, 0.65, 9), Vector3(4, 1.3, 1.2), orange)
	_add_box("CoverD", Vector3(-11, 0.65, 10), Vector3(3, 1.3, 1.2), gray)

	# A simple raised platform and colorful marker pillars
	_add_box("Platform", Vector3(0, 0.25, -12), Vector3(8, 0.5, 3), white)
	_add_box("MarkerBlue", Vector3(-3, 1.0, -12), Vector3(0.6, 2, 0.6), blue)
	_add_box("MarkerOrange", Vector3(3, 1.0, -12), Vector3(0.6, 2, 0.6), orange)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	return material

func _add_box(box_name: String, box_position: Vector3, box_size: Vector3, material: Material) -> void:
	var body := StaticBody3D.new()
	body.name = box_name
	body.position = box_position
	add_child(body)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box_size
	collision.shape = shape
	body.add_child(collision)

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = box_size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	body.add_child(mesh_instance)
