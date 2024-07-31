extends Node2D

var title = load("res://Scenes/TitleMenu.tscn")

func _process(delta):
	if Input.is_action_just_pressed("ExitCredit"):
		SceneTransition.changeScene(title)
