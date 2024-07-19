class_name Player
extends CharacterBody2D

const MAX_SPEED = 250
const ACCELERATION = 50

var damage = 25
var health = 100
var shadowShards = 0
var direction = Vector2.ZERO
var hurtBoxDistance = 27 #attack range
var attackCoolDownTimer = 0.0
var attackCoolDown = 0.25 #time between attacks
@onready var hurtBox = $Area2D/CollisionShape2D



func _physics_process(delta):
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && attackCoolDownTimer <= 0.0):
		hurtBox.disabled = false
		attackCoolDownTimer = attackCoolDown
		#do attack animation
	if (attackCoolDownTimer > 0.0):
		attackCoolDownTimer -= delta
	else:
		hurtBox.disabled = true
	var movement = Vector2.ZERO
	
	if attackCoolDownTimer <= 0.0:
		if Input.is_action_pressed("up"):
			movement.y -= 1
		if Input.is_action_pressed("down"):
			movement.y += 1
		if Input.is_action_pressed("left"):
			movement.x -= 1
		if Input.is_action_pressed("right"):
			movement.x += 1
	
	movement = movement.normalized()
	
	if (movement != Vector2.ZERO):
		direction = movement
	
	velocity.x = move_toward(velocity.x, movement.x*MAX_SPEED, ACCELERATION)
	velocity.y = move_toward(velocity.y, movement.y*MAX_SPEED, ACCELERATION)
	
	move_and_slide()

	if attackCoolDownTimer <= 0.0:
		updateHurtBox()

		
func updateHurtBox():
	hurtBox.rotation = atan2(direction.y, direction.x)
	hurtBox.position.x = direction.x * hurtBoxDistance
	hurtBox.position.y = direction.y * hurtBoxDistance


func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print("HIT")
	if body.is_in_group("Hit"):
		body.onHurt(damage)
	else:
		pass # Replace with function body.
