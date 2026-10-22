extends StaticBody3D

@export var max_health: int = 100
var health: int = 100

func _ready() -> void:
	health = max_health

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
