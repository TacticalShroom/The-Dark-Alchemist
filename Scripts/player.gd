extends CharacterBody2D

@onready var potionWheel = $PotionWheel

const MAX_SPEED = 250
const ACCELERATION = 50

var health = 100
var shadowShards = 0

func _physics_process(delta):
	potionListener()
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

const potionWheelVel = 0.05
var spinning = false
var spinSpeed = 5
var spinDir = -1
var spinAmountMax = 45
var spinAmountRemaining = 45

func potionListener():
	if Input.is_action_pressed("PotionMenu"):
		potionWheel.scale.x = move_toward(potionWheel.scale.x, 1.5, potionWheelVel)
		potionWheel.scale.y = move_toward(potionWheel.scale.y, 1.5, potionWheelVel)
		potionWheel.position.x = move_toward(potionWheel.position.x, 310, 1)
		potionWheel.position.y = move_toward(potionWheel.position.y, 170, 1)
	else:
		potionWheel.scale.x = move_toward(potionWheel.scale.x, 1, potionWheelVel)
		potionWheel.scale.y = move_toward(potionWheel.scale.y, 1, potionWheelVel)
		potionWheel.position.x = move_toward(potionWheel.position.x, 320, 1)
		potionWheel.position.y = move_toward(potionWheel.position.y, 180, 1)
	if !spinning && Input.is_action_pressed("PotionMenu"):
		if Input.is_action_just_pressed("scroll_up"):
			spinDir = 1
			spinning = true
		if Input.is_action_just_pressed("scroll_down"):
			spinDir = -1
			spinning = true
	elif spinning:
		if spinAmountRemaining > 0:
			potionWheel.rotate(spinSpeed*spinDir)
			spinAmountRemaining -= spinSpeed
		else:
			spinning = false
			spinAmountRemaining = spinAmountMax
		
