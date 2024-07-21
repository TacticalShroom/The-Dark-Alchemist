extends Area2D

@export var direction = Vector2(1,0)
@export var projectileSpeed = 5

func _physics_process(delta):
	if visible:
		global_position.x += direction.x * projectileSpeed
		global_position.y += direction.y * projectileSpeed
