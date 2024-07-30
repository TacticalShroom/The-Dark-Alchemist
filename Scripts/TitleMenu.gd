extends Node2D

@onready var textureRect = $TextureRect
@onready var playButton = $TitleButtons/VBoxContainer/PlayButton
@onready var creditButton = $TitleButtons/VBoxContainer/CreditButton

var levelScene = load("res://Scenes/main.tscn")

func _process(delta):
	pass


func playPressed():
	SceneTransition.changeScene(levelScene)


func creditPressed():
	pass
