class_name EnemyCommon
extends CharacterBody2D

@onready var hurtBox = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D/AnimationPlayer
@onready var idleSound = $IdleSound
@onready var attackSound = $Attack
@onready var deathParticles = $DeathParticles
@onready var deathTimer = $DeathTimer
@onready var healthBar = $HealthBar

var frameProgress = 0.0

var maxHealth = 100
var health = maxHealth

var angleConeOfVision := deg_to_rad(80.0)
var maxViewDistance := 400.0
var angleBetweenRays := deg_to_rad(5.0)

var damageTakenMulti = 1


var direction = Vector2(1,0)
@export var starting_dir = Vector2(1,0)
@export var shadowShardReward = 2
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
var facingRight = false
var hit = false

var target = null
var rayCount = 0

func onHurt(damage, knockBackDir):
	health -= damage*damageTakenMulti
	setHealthBar()
	knockBackTimer = knockBackDuration
	knockBackDirection = knockBackDir
	movement = Vector2(-knockBackDir.x, -knockBackDir.y)
	movement = movement.normalized()
	if (health <= 0):
		sprite.get_parent().visible = false
		healthBar.visible = false
		for ray in get_children():
			if ray is RayCast2D:
				ray.enabled = false
		deathTimer.start()
		deathParticles.emitting = true
		for player in get_parent().get_children():
			if player is Player:
				player.shadowShards += shadowShardReward

func deathTimeout():
	self.queue_free()

func _ready():
	var rng = RandomNumberGenerator.new()
	generateRaycasts()
	$HealthBar.max_value = maxHealth
	setHealthBar()
	movement = starting_dir
	if starting_dir.x > 0:
		sprite.play("idle_right")
	else:
		sprite.play("idle_left")
	sprite.advance(rng.randi_range(0, 8)/10.0)

func setHealthBar():
	$HealthBar.value = health
	

func _physics_process(delta):
	var doesSeePlayer = target != null
	frameProgress = sprite.current_animation_position
	if (doesSeePlayer):
		movement = Vector2(target.position.x - position.x, target.position.y - position.y)
		if (abs(movement.x) > attackRange || abs(movement.y) > attackRange) && hurtBox.disabled == true && coolDownTimer <= attackCoolDown && coolDownTimer > attackCoolDown - 0.15:
			if movement.x > 0:
				sprite.play("walk_right")
				if !facingRight:
					facingRight = true
					sprite.advance(frameProgress)
			else:
				sprite.play("walk_left")
				if facingRight:
					facingRight = false
					sprite.advance(frameProgress)
			movement = movement.normalized()
			velocity.x = move_toward(velocity.x, movement.x * movementSpeed, acceleration)
			velocity.y = move_toward(velocity.y, movement.y * movementSpeed, acceleration)
			move_and_slide()
		elif attackTimer <= 0.0 && coolDownTimer <= 0.0:
			movement = movement.normalized()
			hurtBox.disabled = false #initiate attack
			if !attackSound.playing:
				attackSound.play()
			attackTimer = attackDuration
			coolDownTimer = attackCoolDown + attackDuration
		else:
			if attackTimer > 0.0:
				attackTimer -= delta
			else:
				hurtBox.disabled = true #attack finishes
				hit = false
			if coolDownTimer > 0.0:
				if movement.x > 0:
					sprite.play("bite_right")
					if !facingRight:
						facingRight = true
						sprite.advance(frameProgress)
				else:
					sprite.play("bite_left")
					if facingRight:
						facingRight = false
						sprite.advance(frameProgress)
				coolDownTimer -= delta
			movement = movement.normalized()
	else:
		if RandomNumberGenerator.new().randi_range(0, 420) == 69 && !idleSound.playing:
			idleSound.play()
		
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
			if ray.is_colliding() && ray.get_collider() != null:
				if ray.get_collider().is_in_group("Player"):
					target = ray.get_collider()
	
	hurtBox.rotation = atan2(direction.y, direction.x)
	hurtBox.position.x = direction.x * attackRange
	hurtBox.position.y = direction.y * attackRange
	direction = movement
	

func shatter():
	damageTakenMulti = 2

func generateRaycasts():
	rayCount = angleConeOfVision / angleBetweenRays
	for index in rayCount:
		var ray := RayCast2D.new()
		var angle = angleBetweenRays * (index - rayCount / 2)
		ray.target_position = Vector2(1,tan(angle)).normalized() * maxViewDistance
		add_child(ray)
		ray.enabled = true


func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("Player") && !hit:
		hit = true
		body.onHurt(atkDamage, direction)
