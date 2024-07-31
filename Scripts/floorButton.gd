extends Node2D

var pressed = false

@onready var button = $Sprite2D
@onready var area = $Area2D

func _physics_process(delta):
	pressed = false	
	var l = area.get_overlapping_bodies()
	if area.has_overlapping_bodies():
		pressed = true
	
	if !pressed:
		button.frame = 0
	else:
		button.frame = 1

