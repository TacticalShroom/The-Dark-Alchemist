extends Node

@onready var main = load("res://Scenes/main.tscn")

@onready var currentScene = main

func _ready():
	pass 

func _process(delta):
	pass

func switchScene(newScene):
	get_tree().change_scene_to_packed(newScene)
	currentScene = newScene
	switchScene(currentScene)
