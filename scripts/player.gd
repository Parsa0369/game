extends CharacterBody3D

@export var move_speed: float = 6.0
@export var sprint_speed: float = 9.0
@export var slide_speed: float = 12.0
@export var mouse_sensitivity: float = 0.002
@export var jump_velocity: float = 4.5
@export var max_health: int = 100
@export var ammo: int = 30

var health: int = 100
var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
var pitch: float = 0.0
var is_prone: bool = false
var slide_time: float = 0.0
var slide_direction: Vector3 = Vector3.ZERO

@onready var head: Node3D = $Head
@onready var body_shape: CollisionShape3D = $CollisionShape3D
@onready var status_label: Label = get_node_or_null("/root/Main/UI/Status")

func _ready() -> void:
	health = max_health
	_update_status()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch = clampf(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-85), deg_to_rad(85))
		head.rotation.x = pitch
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_shoot()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventKey and event.pressed and event.keycode == KEY_R:
		ammo = 30
		_update_status()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_Z:
		is_prone = not is_prone
		_update_stance()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_CTRL:
		_start_slide()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor() and not is_prone and slide_time <= 0.0:
		velocity.y = jump_velocity

	if slide_time > 0.0:
		slide_time = maxf(slide_time - delta, 0.0)
		velocity.x = slide_direction.x * slide_speed
		velocity.z = slide_direction.z * slide_speed
	else:
		var input_dir := Vector2(
			float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A)),
			float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W))
		)
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		var current_speed := move_speed
		if Input.is_key_pressed(KEY_SHIFT) and not is_prone:
			current_speed = sprint_speed
		if is_prone:
			current_speed = 2.0
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed * 8.0 * delta)
			velocity.z = move_toward(velocity.z, 0, move_speed * 8.0 * delta)
	move_and_slide()

func _start_slide() -> void:
	if not is_on_floor() or is_prone or slide_time > 0.0:
		return
	var forward := -global_transform.basis.z
	var flat_velocity := Vector3(velocity.x, 0, velocity.z)
	slide_direction = flat_velocity.normalized() if flat_velocity.length() > 1.0 else forward
	slide_time = 0.65
	head.position.y = 0.25

func _update_stance() -> void:
	head.position.y = 0.25 if is_prone else 0.6
	if is_prone:
		slide_time = 0.0

func _shoot() -> void:
	if ammo <= 0:
		return
	ammo -= 1
	var camera: Camera3D = head.get_node("Camera3D")
	var from := camera.global_position
	var to := from + (-camera.global_transform.basis.z * 100.0)
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var collider = hit.get("collider")
		if collider and collider.has_method("take_damage"):
			collider.take_damage(25)
	_update_status()

func take_damage(amount: int) -> void:
	health = maxi(health - amount, 0)
	_update_status()
	if health <= 0:
		get_tree().reload_current_scene()

func _update_status() -> void:
	if is_instance_valid(status_label):
		var stance := "خوابیده" if is_prone else ("سُر خوردن" if slide_time > 0.0 else "ایستاده")
		status_label.text = "سلامتی: %d   |   مهمات: %d   |   حالت: %s" % [health, ammo, stance]
