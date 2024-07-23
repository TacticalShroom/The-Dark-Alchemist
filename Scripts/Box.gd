extends StaticBody2D

@onready var breakSound = $BreakSound
@onready var queueTimer = $QueueTimer

func shatter():
	breakSound.play()
	for player in get_parent().get_children():
		if player is Player:
			player.shadowShards += 1
	self.visible = false


func queueTimeout():
	queue_free()
