extends CharacterBody2D

@onready var potionWheel = $PotionWheel
@onready var rageTimer = $RageTimer

#---------------------POTIONS---------------------
@onready var shadowPotion = $Potions/Shadow
@onready var brittlePotion = $Potions/Brittle
@onready var teleportPotion = $Potions/Teleport
@onready var banishPotion = $Potions/Banish
@onready var freezePotion = $Potions/Freeze
@onready var blockPotion = $Potions/Block
@onready var explosionPotion = $Potions/Explosion
@onready var ragePotion = $Potions/Rage

@onready var potions = [shadowPotion, brittlePotion, teleportPotion, banishPotion, freezePotion, blockPotion, explosionPotion, ragePotion]
#-------------------------------------------------

const MAX_SPEED = 250
const ACCELERATION = 50
var speedMulti = 1
var health = 100
var shadowShards = 10

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
		potion.getSprite().position.x = -64
	for potion in potions:
		potion.rotate((PI/4)*i)
		potion.getSprite().rotate(-(PI/4)*i)
		i += 1

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
	velocity.x = move_toward(velocity.x, movement.x*MAX_SPEED*speedMulti, ACCELERATION)
	velocity.y = move_toward(velocity.y, movement.y*MAX_SPEED*speedMulti, ACCELERATION)
	
	move_and_slide()

const potionWheelVel = 0.05
const potionWheelScale = 1.5
const potionScale = 2.5
var selectedPotionIndex = 1
var spinning = false
var spinSpeed = PI/16
var spinDir = -1
var spinAmountMax = PI/4
var spinAmountRemaining = spinAmountMax

func potionListener():
	
	if Input.is_action_just_pressed("throwPotion"):
		if potions[selectedPotionIndex].getCost() <= shadowShards:
			splashPotion(potions[selectedPotionIndex].getType(), 0, 0)		# ZEROS ARE TEMP
	
	if Input.is_action_pressed("PotionMenu"):
		var i = 0
		for potion in potions:
			if i != selectedPotionIndex:
				potion.getSprite().scale.x = move_toward(potion.getSprite().scale.x, 1.5, 0.1)
				potion.getSprite().scale.y = move_toward(potion.getSprite().scale.y, 1.5, 0.1)
			else:
				potion.getSprite().scale.x = move_toward(potion.getSprite().scale.x, potionScale, 0.1)
				potion.getSprite().scale.y = move_toward(potion.getSprite().scale.y, potionScale, 0.1)
			i += 1
		
		potionWheel.scale.x = move_toward(potionWheel.scale.x, potionWheelScale, potionWheelVel)
		potionWheel.scale.y = move_toward(potionWheel.scale.y, potionWheelScale, potionWheelVel)
		potionWheel.position.x = move_toward(potionWheel.position.x, 315, 0.5)
		potionWheel.position.y = move_toward(potionWheel.position.y, 175, 0.5)
		for potion in potions:
			potion.getSprite().position.x = move_toward(potion.getSprite().position.x, (64 * sign(potion.getSprite().position.x))*potionWheelScale, 64*potionWheelVel)
	else:
		potionWheel.scale.x = move_toward(potionWheel.scale.x, 1, potionWheelVel)
		potionWheel.scale.y = move_toward(potionWheel.scale.y, 1, potionWheelVel)
		potionWheel.position.x = move_toward(potionWheel.position.x, 320, 0.5)
		potionWheel.position.y = move_toward(potionWheel.position.y, 180, 0.5)
		
		for potion in potions:
			potion.getSprite().scale.x = move_toward(potion.getSprite().scale.x, 1.5, 0.1)
			potion.getSprite().scale.y = move_toward(potion.getSprite().scale.y, 1.5, 0.1)
		
		for potion in potions:
			potion.getSprite().position.x = move_toward(potion.getSprite().position.x, (64 * sign(potion.getSprite().position.x)), 64*potionWheelVel)
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

func splashPotion(potionType : PotionTypes, x : int = 0, y : int = 0):
	match potionType:
		PotionTypes.SHADOW:
			pass
		PotionTypes.BRITTLE:
			pass
		PotionTypes.TELEPORT:
			pass
		PotionTypes.BANISH:
			pass
		PotionTypes.FREEZE:
			pass
		PotionTypes.BLOCK:
			pass
		PotionTypes.EXPLOSION:
			pass
		PotionTypes.RAGE:
			if rageTimer.is_stopped() && speedMulti == 1:
				rageTimer.start()
			
			speedMulti = 2
			health = 150


func rageTimerFinished():
	speedMulti = 1
