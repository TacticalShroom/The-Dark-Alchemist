class_name EnemyCommon
extends CharacterBody2D

var maxHealth = 100
var health = maxHealth

var angleConeOfVision := deg_to_rad(80.0)
var maxViewDistance := 400.0
var angleBetweenRays := deg_to_rad(5.0)

var direction = Vector2(1,0)
var movement = Vector2(1,-1)
var movementSpeed = 100
var acceleration = 25

var target = null
var rayCount = 0

func onHurt(damage):
	health -= damage
	setHealthBar()
	print(health)
	if (health <= 0):
		self.queue_free()
		
func _ready():
	generateRaycasts()
	$HealthBar.max_value = maxHealth
	setHealthBar()

func setHealthBar():
	$HealthBar.value = health
	

func _physics_process(delta):
	print(velocity)
	var doesSeePlayer := target != null
	
	if (doesSeePlayer):
		movement = Vector2(target.position.x - position.x, target.position.y - position.y)
		if abs(movement.x) > 50 || abs(movement.y) > 50:
			movement = movement.normalized()
			velocity.x = move_toward(velocity.x, movement.x * movementSpeed, acceleration)
			velocity.y = move_toward(velocity.y, movement.y * movementSpeed, acceleration)
			move_and_slide()

		
	
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
		print(rayCount)
