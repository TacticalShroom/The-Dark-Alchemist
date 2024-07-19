extends Area2D

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

@onready var potion = $sprite
@export var shardCost = 0
@export var potionType = PotionTypes.SHADOW

func getSprite():
	return potion

func getCost():
	return shardCost

func getType():
	return potionType
