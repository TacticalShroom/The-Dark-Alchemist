extends Area2D

@onready var sprite = $Sprite2D/AnimationPlayer
@export var direction = Vector2(1,0)
@export var projectileSpeed = 3

func _physics_process(delta):
	if visible:
		sprite.play("shoot")
		rotation = Vector2(direction.x, direction.y).angle() - (PI/2)
		global_position.x += direction.x * projectileSpeed
		global_position.y += direction.y * projectileSpeed
	


func _on_body_entered(body):
	self.queue_free() # Replace with function body.
