extends StaticBody2D

@onready var breakSound = $BreakSound

func shatter():
	breakSound.play()
	for player in get_parent().get_children():
		if player is Player:
			player.shadowShards += 1
	self.visible = false
	await breakSound.finished
	queue_free()

