extends Area2D


var stairBias = 150

func _physics_process(delta):
	if !get_overlapping_bodies().is_empty():
		for body in get_overlapping_bodies():
			if body is CharacterBody2D:
				if body.velocity.x > 0:
					body.velocity.y = max(body.velocity.y-stairBias, -body.MAX_SPEED)
				if body.velocity.x < 0:
					body.velocity.y = min(body.velocity.y+stairBias, body.MAX_SPEED)
			
