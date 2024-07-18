extends CharacterBody2D

const MAX_SPEED = 250
const ACCELERATION = 50

var health = 100
var shadowShards = 0




func _physics_process(delta):
	var movement = Vector2.ZERO
	
	if Input.is_action_pressed("up"):
		movement.y -= 1
	if Input.is_action_pressed("down"):
		movement.y += 1
	if Input.is_action_pressed("left"):
		movement.x -= 1
	if Input.is_action_pressed("right"):
		movement.x += 1
		
	movement = movement.normalized()
	velocity.x = move_toward(velocity.x, movement.x*MAX_SPEED, ACCELERATION)
	velocity.y = move_toward(velocity.y, movement.y*MAX_SPEED, ACCELERATION)
	
	move_and_slide()
