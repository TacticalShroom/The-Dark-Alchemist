extends Area2D

var credits = load("res://Scenes/Credits.tscn")

func _physics_process(delta):
	if !get_overlapping_bodies().is_empty():
		for body in get_overlapping_bodies():
			if body is Player:
				SceneTransition.changeScene(credits)
