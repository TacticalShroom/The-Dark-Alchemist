extends Node2D

@onready var textureRect = $TextureRect
@onready var playButton = $TitleButtons/VBoxContainer/PlayButton
@onready var creditButton = $TitleButtons/VBoxContainer/CreditButton
@onready var menuSound = $MenuSound

var levelScene = load("res://Scenes/main.tscn")
var credits = load("res://Scenes/Credits.tscn")

func _process(delta):
	pass


func playPressed():
	menuSound.play()
	SceneTransition.changeScene(levelScene)


func creditPressed():
	menuSound.play()
	SceneTransition.changeScene(credits)
