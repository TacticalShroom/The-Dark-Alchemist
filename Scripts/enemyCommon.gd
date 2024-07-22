class_name EnemyCommon
extends CharacterBody2D

@onready var hurtBox = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D/AnimationPlayer

var maxHealth = 100
var health = maxHealth

var angleConeOfVision := deg_to_rad(80.0)
var maxViewDistance := 400.0
var angleBetweenRays := deg_to_rad(5.0)


var direction = Vector2(1,0)
@export var starting_dir = Vector2(1,0)
var movement = starting_dir
var movementSpeed = 100
var acceleration = 25
var attackRange = 26
var atkDamage = 10
var attackDuration = 0.8
var attackTimer = 0.0
var attackCoolDown = 1.4
var coolDownTimer = attackCoolDown
var knockBackSpeed = 300
var knockBackDuration = 0.2
var knockBackTimer = 0.0
var knockBackDirection = Vector2.ZERO

var target = null
var rayCount = 0

func onHurt(damage, knockBackDir):
	health -= damage
	setHealthBar()
	knockBackTimer = knockBackDuration
	knockBackDirection = knockBackDir
	movement = Vector2(-knockBackDir.x, -knockBackDir.y)
	movement = movement.normalized()
	if (health <= 0):
		self.queue_free()
		
func _ready():
	generateRaycasts()
	$HealthBar.max_value = maxHealth
	setHealthBar()
	movement = starting_dir

func setHealthBar():
	$HealthBar.value = health
	

func _physics_process(delta):
	var doesSeePlayer = target != null
	
	if (doesSeePlayer):
		movement = Vector2(target.position.x - position.x, target.position.y - position.y)
		if (abs(movement.x) > attackRange || abs(movement.y) > attackRange) && hurtBox.disabled == true && coolDownTimer <= attackCoolDown && coolDownTimer > attackCoolDown - 0.15:
			if movement.x > 0:
				sprite.play("walk_right")
			else:
				sprite.play("walk_left")
			movement = movement.normalized()
			velocity.x = move_toward(velocity.x, movement.x * movementSpeed, acceleration)
			velocity.y = move_toward(velocity.y, movement.y * movementSpeed, acceleration)
			move_and_slide()
		elif attackTimer <= 0.0 && coolDownTimer <= 0.0:
			movement = movement.normalized()
			hurtBox.disabled = false #initiate attack
			attackTimer = attackDuration
			coolDownTimer = attackCoolDown + attackDuration
		else:
			if attackTimer > 0.0:
				attackTimer -= delta
			else:
				hurtBox.disabled = true #attack finishes
			if coolDownTimer > 0.0:
				if movement.x > 0:
					sprite.play("bite_right")
				else:
					sprite.play("bite_left")
				coolDownTimer -= delta
			movement = movement.normalized()
	else:
		if (direction.x > 0):
			sprite.play("idle_right")
		else:
			sprite.play("idle_left")
	
	if hurtBox.disabled == false && coolDownTimer > attackCoolDown + attackDuration - (attackDuration / 3):
		movement = movement.normalized()
		velocity.x = movement.x * movementSpeed
		velocity.y = movement.y * movementSpeed
		move_and_slide()
	if knockBackTimer > 0.0:
		knockBackTimer -= delta
		velocity.x = move_toward(velocity.x, knockBackDirection.x * knockBackSpeed, acceleration)
		velocity.y = move_toward(velocity.y, knockBackDirection.y * knockBackSpeed, acceleration)
		move_and_slide()
	
	target = null
	for ray in get_children():
		if (ray is RayCast2D):
			ray.rotate(movement.angle()-direction.angle())
			if ray.is_colliding() && ray.get_collider().is_in_group("Player"):
				target = ray.get_collider()
	
	hurtBox.rotation = atan2(direction.y, direction.x)
	hurtBox.position.x = direction.x * attackRange
	hurtBox.position.y = direction.y * attackRange
	direction = movement
	
	
	

func generateRaycasts():
	rayCount = angleConeOfVision / angleBetweenRays
	for index in rayCount:
		var ray := RayCast2D.new()
		var angle = angleBetweenRays * (index - rayCount / 2)
		ray.target_position = Vector2(1,tan(angle)).normalized() * maxViewDistance
		add_child(ray)
		ray.enabled = true


func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("Player"):
		body.onHurt(atkDamage)
