extends Node2D

@onready var doorSide2 = $DoorSide2
@onready var doorSide1 = $DoorSide1
@onready var doorOpen = $DoorOpen
@onready var doorPass = $DoorPass
@export var doorCoords : Vector2i = Vector2i(-1, -1)

@export var isOpen = false
var justPassed = false

func doorSideTwoBody(body):
	if isOpen && !justPassed && body is Player:
		justPassed = true
		body.global_position.x = doorSide1.global_position.x
		body.global_position.y = doorSide1.global_position.y
		doorPass.play()

func doorSideTwoExit(body):
	if body is Player:
		justPassed = false

func doorSideOneBody(body):
	if isOpen && !justPassed && body is Player:
		justPassed = true
		body.global_position.x = doorSide2.global_position.x
		body.global_position.y = doorSide2.global_position.y
		doorPass.play()

func doorSideOneExit(body):
	if body is Player:
		justPassed = false

func open():
	isOpen = true
	doorOpen.play()
	for tileMap in get_parent().get_parent().get_children():
		if tileMap is TileMap:
			tileMap.set_cell(1, doorCoords, 0, Vector2i(8, 14))

func close():
	isOpen = false
	doorOpen.play()
	for tileMap in get_parent().get_parent().get_children():
		if tileMap is TileMap:
			tileMap.set_cell(1, doorCoords, 0, Vector2i(11, 14))

func checkOpen():
	return isOpen
