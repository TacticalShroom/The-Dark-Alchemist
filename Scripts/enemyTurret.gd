class_name EnemyTurret
extends CharacterBody2D

@onready var bullet = $Area2D
@onready var animation = $Sprite2D/AnimationPlayer

var maxHealth = 100
var health = maxHealth

var angleConeOfVision := deg_to_rad(180.0)
var maxViewDistance := 200.0
var angleBetweenRays := deg_to_rad(5.0)

var direction = Vector2(1,0)
@export var starting_dir = Vector2(1,0)
var movement = starting_dir
var movementSpeed = 100
var acceleration = 25
var attackRange = 35
@export var atkDamage = 10
var attackDuration = 0.77
var attackTimer = 0.0
var fireRate = 1.58 #time between shots
var coolDownTimer = fireRate + attackDuration
var aimed = false
var aimTimer = 0.0
var timeToAim = 1.2
var currentFrame = 0
var frameProgress = 0.0
var facingRight = false
var state = 0 # 0 is idle, 1 is aiming, 2 is shooting

var target = null
var rayCount = 0

func onHurt(damage, knockBackDir):
	health -= damage
	setHealthBar()
	if (health <= 0):
		self.queue_free()
		
func _ready():
	var rng = RandomNumberGenerator.new()
	generateRaycasts()
	$HealthBar.max_value = maxHealth
	setHealthBar()
	movement = starting_dir
	animation.play("idle")
	animation.advance(rng.randi_range(0, 8)/10.0)

func setHealthBar():
	$HealthBar.value = health
	

func _physics_process(delta):
	var doesSeePlayer = target != null
	frameProgress = animation.current_animation_position
	if (doesSeePlayer):
		movement = Vector2(target.position.x - position.x, target.position.y - position.y)
		movement = movement.normalized()
		if attackTimer <= 0.0 && coolDownTimer <= 0.0:
			attack()
			attackTimer = attackDuration
			if !aimed:
				coolDownTimer = fireRate + attackDuration
			else:
				coolDownTimer = fireRate
		else:
			if attackTimer > 0.0:
				attackTimer -= delta
			if coolDownTimer > 0.0:
				if !aimed:
					aimTimer+=delta
					if aimTimer >= timeToAim - 0.05:
						aimed = true
					else:
						if direction.x > 0:
							animation.play("aim_right")
							if !facingRight && state == 1:
								facingRight = true
								animation.advance(frameProgress)
						else:
							animation.play("aim_left")
							if facingRight && state == 1:
								facingRight = false
								animation.advance(frameProgress)
						state = 1
				else:
					if direction.x > 0:
						animation.play("shoot_right")
						if !facingRight:
							facingRight = true
							animation.advance(frameProgress)
					else:
						animation.play("shoot_left")
						if facingRight:
							facingRight = false
							animation.advance(frameProgress)
					state = 2
				coolDownTimer -= delta
	else:
		coolDownTimer = fireRate + attackDuration
		aimTimer = 0.0
		aimed = false
		animation.play("idle")
		state = 0
	
	target = null
	for ray in get_children():
		if (ray is RayCast2D):
			ray.rotate(movement.angle()-direction.angle())
			if ray.is_colliding() && ray.get_collider() != null:
				if ray.get_collider().is_in_group("Player"):
					target = ray.get_collider()
	
	direction = movement
	
	
	

func generateRaycasts():
	rayCount = angleConeOfVision / angleBetweenRays
	for index in rayCount:
		var ray := RayCast2D.new()
		var angle = angleBetweenRays * (index - rayCount / 2)
		ray.target_position = Vector2(1,tan(angle)).normalized() * maxViewDistance
		add_child(ray)
		ray.enabled = true
	for index in rayCount:
		var ray := RayCast2D.new()
		var angle = angleBetweenRays * (index - rayCount / 2)
		ray.target_position = Vector2(-1,-tan(angle)).normalized() * maxViewDistance
		add_child(ray)
		ray.enabled = true


func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("Player"):
		body.onHurt(atkDamage, Vector2.ZERO)
		
func attack():
	var shot = bullet.duplicate()
	add_child(shot)
	shot.position.y = 5
	if direction.x > 0:
		shot.position.x = 20
	else:
		shot.position.x = -20
	shot.visible = true
	shot.direction = Vector2(target.global_position.x - shot.global_position.x, target.global_position.y - shot.global_position.y).normalized()
	shot.get_child(0).disabled = false
