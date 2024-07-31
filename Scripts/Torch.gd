extends AnimatedSprite2D


@export var lit = false

func light(isLit):
	lit = isLit

func _process(delta):
	if lit:
		play("Lit")
	else:
		play("default")
