extends Area2D

@onready var bottleSprite = $BottleSprite
@onready var bottleCollision = $BottleCollision
@onready var potionEffectArea = $PotionEffectArea
@onready var explosionParticles = $ExplosionParticles
@onready var banishParticles = $BanishParticles
@onready var brittleParticles = $BrittleParticles
@onready var freezeParticles = $FreezeParticles
@onready var potionQueueTimer = $PotionQueueTimer

const BOTTLE_VELOCITY = 4

signal bottle_landed

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

var thrown = false
var direction = Vector2.ZERO
var potionType
var hitBody

var potionTimer = 30

func _physics_process(delta):
	if thrown:
		bottleSprite.play("thrown")
		position.x += direction.x * BOTTLE_VELOCITY
		position.y += direction.y * BOTTLE_VELOCITY

		if hitBody != null || potionTimer <= 0:
			
			match potionType:
				PotionTypes.BRITTLE:
					brittleParticles.emitting = true
				PotionTypes.BANISH:
					banishParticles.emitting = true
				PotionTypes.EXPLOSION:
					explosionParticles.emitting = true
				PotionTypes.FREEZE:
					freezeParticles.emitting = true
			
			thrown = false
			potionQueueTimer.queue(self)
			bottleSprite.visible = false
			position.x -= direction.x * BOTTLE_VELOCITY
			position.y -= direction.y * BOTTLE_VELOCITY
			emit_signal("bottle_landed", potionType, potionEffectArea.get_overlapping_bodies(), global_position.x, global_position.y)
		potionTimer -= 1


func throw(type, dir : Vector2):
	thrown = true
	potionType = type
	direction = dir.normalized()


func _on_body_entered(body):
	if !body is Player:
		hitBody = body
