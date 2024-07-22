extends AnimatableBody2D

@onready var collision = $CollisionShape2D

func setCollision(disabled : bool):
	collision.disabled = disabled
