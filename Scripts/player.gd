class_name Player
extends CharacterBody2D

@onready var potionEffectTimer = $PotionEffectTimer
@onready var shadowTimer = $ShadowTimer

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

#PARTICLES
@onready var explosionParticles = $ExplosionParticles
@onready var banishParticles = $BanishParticles
@onready var teleportParticles = $TeleportParticles
@onready var brittleParticles = $BrittleParticles
@onready var rageParticles = $RageParticles
@onready var freezeParticles = $FreezeParticles
@onready var shadowParticles = $ShadowParticles

@onready var potionWheel = $UI/PotionWheel
@onready var bottleProjectile = $BottleProjectile
@onready var block = $Block

@onready var potions = [shadowPotion, brittlePotion, teleportPotion, banishPotion, freezePotion, blockPotion, explosionPotion, ragePotion]
#-------------------------------------------------

const MAX_SPEED = 150
const ACCELERATION = 50

var mouseDirection = Vector2.ZERO

var atkDamage = 25
var maxHealth = 100
var health = maxHealth

var direction = Vector2.ZERO
var hurtBoxDistance = 30 #attack range
var attackTimer = 0.0
var attackDuration = 0.25
var attackCoolDown = 0.25 #time between attacks
var knockBackDirection = Vector2.ZERO
var knockBackTimer = 0.0
var knockBackSpeed = 3000
var knockBackDuration = 0.2

var coolDownTimer = 0.0
var speedMulti = 1
var shadowShards = 100
var maxShadowShards = 100

var banishedEnemies = []

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
	
	mouseDirection = Vector2(get_global_mouse_position().x - position.x, get_global_mouse_position().y - position.y).normalized()
	
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
	
	if attackTimer <= 0.0 && knockBackTimer <= 0.0:
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
	
	if knockBackTimer <= 0.0:
		updateSprite()
	updateUI()
	potionListener()
	move_and_slide()
	if knockBackTimer > 0.0:
		takeKnockBack(delta)

	if attackTimer <= 0.0:
		updateHurtBox()

func updateSprite():
	if attackTimer > 0:
		if mouseDirection.x >= 0:
			playerSprite.play("AttackRight")
		else:
			playerSprite.play("AttackLeft")
		return
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
	hurtBox.rotation = atan2(mouseDirection.y, mouseDirection.x)
	hurtBox.position.x = mouseDirection.x * hurtBoxDistance
	hurtBox.position.y = mouseDirection.y * hurtBoxDistance

func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("Hit"):
		direction = direction.normalized()
		body.onHurt(atkDamage, mouseDirection)
	

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
	get_parent().add_child(potionProjectile)
	potionProjectile.global_position = self.global_position
	potionProjectile.connect("bottle_landed", onBottleHit)
	
	potionProjectile.throw(potionType, mouseDirection)

func onBottleHit(type, bodies, x, y):
	splashPotion(type, bodies, x, y)

var explosionDmg = 75

func splashPotion(potionType : PotionTypes, effectedBoddies : Array = [], x : int = 0, y : int = 0):
	match potionType:
		PotionTypes.SHADOW:
			self.remove_from_group("Player")
			shadowTimer.start()
			shadowParticles.emitting = true
		PotionTypes.BRITTLE:
			for body in effectedBoddies:
				if !body.is_in_group("Brittle"):
					body.add_to_group("Brittle")
		PotionTypes.TELEPORT:
			global_position.x = x
			global_position.y = y
			
			teleportParticles.emitting = true
		PotionTypes.BANISH:
			for body in effectedBoddies:
				if body.is_in_group("Hit"):
					banishedEnemies.append(body)
					body.global_position.x = 9999999
					body.global_position.y = 9999999 
		PotionTypes.FREEZE:
			for body in effectedBoddies:
				if body.is_in_group("Hit"):
					if potionEffectTimer.is_stopped():
						potionEffectTimer.start() 
					body.process_mode = PROCESS_MODE_DISABLED
		PotionTypes.BLOCK:
			var potionBlock = block.duplicate()
			get_parent().add_child(potionBlock)
			var pos = Vector2.ZERO
			pos.x = x
			pos.y = y
			potionBlock.global_position = pos
			potionBlock.visible = true
			potionBlock.setCollision(false)
		PotionTypes.EXPLOSION:
			for body in effectedBoddies:
				if body.is_in_group("Hit"):
					var dir = Vector2.ZERO
					dir.x = body.global_position.x - x
					dir.y = body.global_position.y - y
					dir = dir.normalized()
					body.onHurt(explosionDmg, dir)
		PotionTypes.RAGE:
			if potionEffectTimer.is_stopped():
				potionEffectTimer.start()
			
			speedMulti = 2
			health = 150
			rageParticles.emitting = true

func timerFinished():
	for body in get_tree().get_nodes_in_group("Hit"):
		body.process_mode = PROCESS_MODE_ALWAYS
	speedMulti = 1

func onHurt(damage, knockBackDir):
	health -= damage
	knockBackTimer = knockBackDuration
	knockBackDirection = knockBackDir
	if (health <= 0):
		self.queue_free() #you die

func takeKnockBack(delta):
	knockBackTimer -= delta
	velocity.x = move_toward(velocity.x, knockBackDirection.x * knockBackSpeed, ACCELERATION*1.15)
	velocity.y = move_toward(velocity.y, knockBackDirection.y * knockBackSpeed, ACCELERATION*1.15)
	move_and_slide()

func ShadowTimout():
	self.add_to_group("Player")
