extends StaticBody2D

@onready var breakSound = $BreakSound
@export var brittle = true

@onready var collision = $CollisionShape2D
@onready var pos = position

func _ready():
	if get_parent().is_in_group("Immune"):
		setCollision(true)
	if !brittle:
		setSolid()

func setSolid():
	remove_from_group("Brittle")

func shatter():
	breakSound.play()
	for player in get_parent().get_children():
		if player is Player:
			player.shadowShards += 1
	self.visible = false
	await breakSound.finished
	queue_free()

func _physics_process(delta):
	global_position = pos

func queueTimeout():
	self.queue_free()
	
func setPos(p):
	pos = p
	

func setCollision(disabled : bool):
	collision.disabled = disabled
