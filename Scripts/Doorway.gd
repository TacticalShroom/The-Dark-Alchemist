extends Node2D

@onready var doorSide2 = $DoorSide2
@onready var doorSide1 = $DoorSide1
@onready var doorOpen = $DoorOpen
@onready var doorPass = $DoorPass


var isOpen = true
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

func close():
	isOpen = false
	doorOpen.play()
