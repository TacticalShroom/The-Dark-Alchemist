extends StaticBody2D

var pressed = false
var justPressed = false

@onready var button = $Sprite2D
@onready var area = $Area2D

func _physics_process(delta):
	var l = area.get_overlapping_bodies()
	if area.has_overlapping_bodies():
		pressed = true
	else:
		pressed = false
		justPressed = false
	
	if !pressed:
		button.frame = 0
	else:
		button.frame = 1

func isPressed():
	return pressed

func isJustPressed():
	if !justPressed && pressed:
		justPressed = true
		return true
	return false
