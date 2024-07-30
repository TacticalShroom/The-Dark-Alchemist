extends CanvasLayer

@onready var animator = $AnimationPlayer

func changeScene(newScene):
	animator.play("dissolve")
	await animator.animation_finished
	get_tree().change_scene_to_packed(newScene)
	animator.play_backwards("dissolve")
