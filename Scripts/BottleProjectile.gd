extends Area2D

@onready var bottleSprite = $BottleSprite
@onready var bottleCollision = $BottleCollision

const BOTTLE_VELOCITY = 4

signal bottle_landed

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
			position.x -= direction.x * BOTTLE_VELOCITY
			position.y -= direction.y * BOTTLE_VELOCITY
			emit_signal("bottle_landed", potionType, position.x, position.y)
			queue_free()
		potionTimer -= 1


func throw(type, dir : Vector2):
	thrown = true
	potionType = type
	direction = dir.normalized()


func _on_body_entered(body):
	if !body.is_in_group("Player"):
		hitBody = body
