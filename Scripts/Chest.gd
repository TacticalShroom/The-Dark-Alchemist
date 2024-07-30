extends StaticBody2D

@onready var sprite = $Sprite2D

var openned = false

func open():
	if !openned:
		openned = true
		sprite.frame = 1
		for player in get_parent().get_children():
			if player is Player:
				player.shadowShards += RandomNumberGenerator.new().randi_range(2, 6)
