class_name Player
extends CharacterBody2D

@onready var rageTimer = $RageTimer
@onready var playerSprite = $PlayerSprite
@onready var hurtBox = $Area2D/CollisionShape2D

@onready var healthBar = $UI/HealthBar/MiddleLayer
@onready var shadowBar = $UI/BottleOShadow/MiddleLayer

#---------------------POTIONS---------------------
@onready var shadowPotion = $UI/Potions/Shadow
@onready var brittlePotion = $UI/Potions/Brittle
@onready var teleportPotion = $UI/Potions/Teleport
@onready var banishPotion = $UI/Potions/Banish
@onready var freezePotion = $UI/Potions/Freeze
@onready var blockPotion = $UI/Potions/Block
@onready var explosionPotion = $UI/Potions/Explosion
@onready var ragePotion = $UI/Potions/Rage

@onready var potionWheel = $UI/PotionWheel
@onready var bottleProjectile = $BottleProjectile

@onready var potions = [shadowPotion, brittlePotion, teleportPotion, banishPotion, freezePotion, blockPotion, explosionPotion, ragePotion]
#-------------------------------------------------

const MAX_SPEED = 150
const ACCELERATION = 50



var atkDamage = 25
var maxHealth = 100
var health = maxHealth

var direction = Vector2.ZERO
var hurtBoxDistance = 30 #attack range
var attackTimer = 0.0
var attackDuration = 0.25
var attackCoolDown = 0.25 #time between attacks

var coolDownTimer = 0.0
var speedMulti = 1
var shadowShards = 50
var maxShadowShards = 100

enum PotionTypes {
	SHADOW,
	BRITTLE,
	TELEPORT,
	BANISH,
	FREEZE,
	BLOCK,
	EXPLOSION,
	RAGE
}

func _ready():
	var i = 0
	for potion in potions:
		potion.getSprite().position.x = -32
	for potion in potions:
		potion.rotate((PI/4)*i)
		potion.getSprite().rotate(-(PI/4)*i)
		i += 1

func _physics_process(delta):
	if (Input.is_action_pressed("attack") && coolDownTimer <= 0.0 && attackTimer <= 0.0):
		hurtBox.disabled = false
		attackTimer = attackDuration
		coolDownTimer = attackCoolDown + attackDuration
		#do attack animation
	if (attackTimer > 0.0):
		attackTimer -= delta
	else:
		hurtBox.disabled = true

	if coolDownTimer > 0.0:
		coolDownTimer -= delta

	var movement = Vector2.ZERO
	
	if attackTimer <= 0.0:
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
	
	velocity.x = move_toward(velocity.x, movement.x*MAX_SPEED*speedMulti, ACCELERATION)
	velocity.y = move_toward(velocity.y, movement.y*MAX_SPEED*speedMulti, ACCELERATION)
	
	updateSprite()
	updateUI()
	potionListener()
	move_and_slide()

	if attackTimer <= 0.0:
		updateHurtBox()

func updateSprite():
	if velocity.x > 0:
		playerSprite.play("RunRight")
	elif velocity.x < 0:
		playerSprite.play("RunLeft")
	elif velocity.y < 0:
		playerSprite.play("RunRight")
	elif velocity.y > 0:
		playerSprite.play("RunLeft")
	else:
		if direction.x >= 0:
			playerSprite.play("IdleRight")
		else:
			playerSprite.play("IdleLeft")

var barYZero = 128
var barYFull = 48

var barMinSize = 48
var barMaxSize = 128

func updateUI():
	#HEALTH
	if health > maxHealth:
		healthBar.position.y = barYFull
		healthBar.size.y = barMaxSize
	else:
		var healthBarSize = int((float(health) / float(maxHealth)) * (barMaxSize - barMinSize) + barMinSize)
		var healthBarY = barYFull + (barMaxSize - healthBarSize)
		healthBar.position.y = healthBarY
		healthBar.size.y = healthBarSize
	
	#SHADOW
	
	
	var shadowBarSize = int((float(shadowShards) / float(maxShadowShards)) * (barMaxSize - barMinSize) + barMinSize)
	var shadowBarY = barYFull + (barMaxSize - shadowBarSize)
	shadowBar.position.y = shadowBarY
	shadowBar.size.y = shadowBarSize

func updateHurtBox():
	hurtBox.rotation = atan2(direction.y, direction.x)
	hurtBox.position.x = direction.x * hurtBoxDistance
	hurtBox.position.y = direction.y * hurtBoxDistance

func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("Hit"):
		direction = direction.normalized()
		body.onHurt(atkDamage, direction)
	

const potionWheelVel = 0.1
const potionWheelScale = 1
const potionScale = 1.5
var selectedPotionIndex = 2
var spinning = false
var spinSpeed = PI/16
var spinDir = -1
var spinAmountMax = PI/4
var spinAmountRemaining = spinAmountMax

func potionListener():
	if Input.is_action_just_pressed("throwPotion"):
		if shadowShards >= potions[selectedPotionIndex].getCost():
			shadowShards -= potions[selectedPotionIndex].getCost()
			match potions[selectedPotionIndex].getType():
				PotionTypes.SHADOW:
					splashPotion(PotionTypes.SHADOW)
				PotionTypes.BRITTLE:
					throwPotion(PotionTypes.BRITTLE)
				PotionTypes.TELEPORT:
					throwPotion(PotionTypes.TELEPORT)
				PotionTypes.BANISH:
					throwPotion(PotionTypes.BANISH)
				PotionTypes.FREEZE:
					throwPotion(PotionTypes.FREEZE)
				PotionTypes.BLOCK:
					throwPotion(PotionTypes.BLOCK)
				PotionTypes.EXPLOSION:
					throwPotion(PotionTypes.EXPLOSION)
				PotionTypes.RAGE:
					splashPotion(PotionTypes.RAGE)
	
	if Input.is_action_pressed("PotionMenu"):
		var i = 0
		for potion in potions:
			if i != selectedPotionIndex:
				potion.getSprite().scale.x = move_toward(potion.getSprite().scale.x, 1, 0.1)
				potion.getSprite().scale.y = move_toward(potion.getSprite().scale.y, 1, 0.1)
			else:
				potion.getSprite().scale.x = move_toward(potion.getSprite().scale.x, potionScale, 0.1)
				potion.getSprite().scale.y = move_toward(potion.getSprite().scale.y, potionScale, 0.1)
			i += 1
		
		potionWheel.scale.x = move_toward(potionWheel.scale.x, potionWheelScale, potionWheelVel)
		potionWheel.scale.y = move_toward(potionWheel.scale.y, potionWheelScale, potionWheelVel)
		#potionWheel.position.x = move_toward(potionWheel.position.x, 155, 0.5)
		#potionWheel.position.y = move_toward(potionWheel.position.y, 85, 0.5)
		for potion in potions:
			potion.getSprite().position.x = move_toward(potion.getSprite().position.x, (64 * sign(potion.getSprite().position.x))*potionWheelScale, 64*potionWheelVel)
	else:
		potionWheel.scale.x = move_toward(potionWheel.scale.x, 0.5, potionWheelVel)
		potionWheel.scale.y = move_toward(potionWheel.scale.y, 0.5, potionWheelVel)
		#potionWheel.position.x = move_toward(potionWheel.position.x, 160, 0.5)
		#potionWheel.position.y = move_toward(potionWheel.position.y, 90, 0.5)
		
		for potion in potions:
			potion.getSprite().scale.x = move_toward(potion.getSprite().scale.x, 0.75, 0.1)
			potion.getSprite().scale.y = move_toward(potion.getSprite().scale.y, 0.75, 0.1)
		
		potions[selectedPotionIndex].getSprite().scale.x = move_toward(potions[selectedPotionIndex].getSprite().scale.x, 0.9, 0.2)
		potions[selectedPotionIndex].getSprite().scale.y = move_toward(potions[selectedPotionIndex].getSprite().scale.y, 0.9, 0.2)
		
		for potion in potions:
			potion.getSprite().position.x = move_toward(potion.getSprite().position.x, (32 * sign(potion.getSprite().position.x)), 64*potionWheelVel)
	if !spinning && Input.is_action_pressed("PotionMenu"):
		if Input.is_action_just_pressed("scroll_up"):
			spinDir = 1
			spinning = true
			selectedPotionIndex -= 1
			if selectedPotionIndex <= -1:
				selectedPotionIndex = potions.size()-1
		if Input.is_action_just_pressed("scroll_down"):
			spinDir = -1
			spinning = true
			selectedPotionIndex += 1
			if selectedPotionIndex == potions.size():
				selectedPotionIndex = 0
	elif spinning:
		if spinAmountRemaining > 0:
			potionWheel.rotate(spinSpeed*spinDir)
			for potion in potions:
				potion.rotate(spinSpeed*spinDir)
				potion.getSprite().rotate(-spinSpeed*spinDir)
			spinAmountRemaining -= spinSpeed
		else:
			spinning = false
			spinAmountRemaining = spinAmountMax

func throwPotion(potionType: PotionTypes):
	var potionProjectile = bottleProjectile.duplicate()
	potionProjectile.visible = true
	add_child(potionProjectile)
	potionProjectile.connect("bottle_landed", onBottleHit)
	
	potionProjectile.throw(potionType, direction)

func onBottleHit(type, x, y):
	splashPotion(type, x, y)

func splashPotion(potionType : PotionTypes, x : int = 0, y : int = 0):
	match potionType:
		PotionTypes.SHADOW:
			pass
		PotionTypes.BRITTLE:
			pass
		PotionTypes.TELEPORT:
			global_position.x = x
			global_position.y = y
		PotionTypes.BANISH:
			pass
		PotionTypes.FREEZE:
			pass
		PotionTypes.BLOCK:
			pass
		PotionTypes.EXPLOSION:
			pass
		PotionTypes.RAGE:
			if rageTimer.is_stopped():
				rageTimer.start()
			
			speedMulti = 2
			health = 150


func rageTimerFinished():
	speedMulti = 1
	
func onHurt(damage):
	health -= damage
	if (health <= 0):
		self.queue_free() #you die
