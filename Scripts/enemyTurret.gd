class_name EnemyTurret
extends CharacterBody2D

@onready var bullet = $Area2D

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
var attackRange = 35
@export var atkDamage = 10
var attackDuration = 0.25
var attackTimer = 0.0
var fireRate = 1.5 #time between shots
var coolDownTimer = fireRate

var target = null
var rayCount = 0

func onHurt(damage):
	health -= damage
	setHealthBar()
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
		movement = movement.normalized()
		if attackTimer <= 0.0 && coolDownTimer <= 0.0:
			attack()
			attackTimer = attackDuration
			coolDownTimer = fireRate + attackDuration
		else:
			if attackTimer > 0.0:
				attackTimer -= delta
			if coolDownTimer > 0.0:
				coolDownTimer -= delta
	
	target = null
	for ray in get_children():
		if (ray is RayCast2D):
			ray.rotate(movement.angle()-direction.angle())
			if ray.is_colliding() && ray.get_collider() is Player:
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


func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("Player"):
		body.onHurt(atkDamage)
		
func attack():
	var shot = bullet.duplicate()
	add_child(shot)
	shot.visible = true
	shot.direction = direction
