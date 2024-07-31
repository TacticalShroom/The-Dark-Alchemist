extends Node2D

@onready var doorway = $Doors/Doorway
@onready var doorway_2 = $Doors/Doorway2
@onready var doorway_3 = $Doors/Doorway3
@onready var doorway_4 = $Doors/Doorway4
@onready var doorway_5 = $Doors/Doorway5
@onready var doorway_6 = $Doors/Doorway6
@onready var doorway_7 = $Doors/Doorway7
@onready var doorway_8 = $Doors/Doorway8
@onready var doorway_9 = $Doors/Doorway9
@onready var doorway_10 = $Doors/Doorway10
@onready var doorway_11 = $Doors/Doorway11

@onready var floorButton1 = $floorButton1
@onready var floorButton = $floorButton
@onready var torch1 = $Torch
@onready var torch2 = $Torch2
@onready var chest = $Chest

@onready var torch_3 = $Torch3
@onready var torch_4 = $Torch4
@onready var torch_5 = $Torch5
@onready var torch_6 = $Torch6
@onready var torch_7 = $Torch7
@onready var torch_8 = $Torch8
@onready var torch_9 = $Torch9
@onready var torch_10 = $Torch10
@onready var torch_11 = $Torch11
@onready var torch_12 = $Torch12
@onready var torch_13 = $Torch13
@onready var torch_14 = $Torch14
@onready var floor_button_2 = $floorButton2
@onready var floor_button_3 = $floorButton3
@onready var floor_button_4 = $floorButton4
@onready var floor_button_5 = $floorButton5
@onready var floor_button_6 = $floorButton6
@onready var floor_button_7 = $floorButton7
@onready var floor_button_8 = $floorButton8

@onready var chest_3 = $Chest3

@onready var floor_button_9 = $floorButton9
@onready var floor_button_10 = $floorButton10
@onready var torch_15 = $Torch15
@onready var torch_16 = $Torch16

@onready var floor_button_11 = $floorButton11
@onready var torch_17 = $Torch17

@onready var floor_button_19 = $floorButton19
@onready var floor_button_20 = $floorButton20
@onready var floor_button_21 = $floorButton21
@onready var floor_button_22 = $floorButton22
@onready var torch_21 = $Torch21
@onready var torch_22 = $Torch22
@onready var torch_23 = $Torch23
@onready var torch_24 = $Torch24

@onready var area_2d = $Area2D



func _process(delta):
	if floorButton1.isPressed() && !doorway.checkOpen():
		doorway.open()
	if floorButton.isPressed():
		torch1.light(true)
		torch2.light(true)
		chest.unlock()
	if chest.isOpenned():
		doorway_2.open()
	if torch_3.lit == torch_9.lit && torch_4.lit == torch_10.lit && torch_5.lit == torch_11.lit && torch_6.lit == torch_12.lit && torch_7.lit == torch_13.lit && torch_8.lit == torch_14.lit && torch_3.lit:
		doorway_5.open()
	if floor_button_2.isJustPressed():
		torch_9.light(!torch_9.lit)
	if floor_button_3.isJustPressed():
		torch_10.light(!torch_10.lit)
	if floor_button_4.isJustPressed():
		torch_11.light(!torch_11.lit)
	if floor_button_5.isJustPressed():
		torch_12.light(!torch_12.lit)
	if floor_button_6.isJustPressed():
		torch_13.light(!torch_13.lit)
	if floor_button_7.isJustPressed():
		torch_14.light(!torch_14.lit)
	if floor_button_8.isPressed():
		torch_3.light(true)
		torch_6.light(true)
		torch_7.light(true)
	else:
		torch_3.light(false)
		torch_6.light(false)
		torch_7.light(false)
	if chest_3.isOpenned():
		doorway_6.open()
	if floor_button_9.isPressed():
		torch_15.light(true)
	else:
		torch_15.light(false)
	if floor_button_10.isPressed():
		torch_16.light(true)
	else:
		torch_16.light(false)
	if torch_15.lit && torch_16.lit:
		doorway_7.open()
	else:
		doorway_7.close()
	if !floor_button_11.isPressed() && !torch_17.lit:
		doorway_8.open()
		doorway_9.open()
	if doorway_8.justPassed || doorway_9.justPassed:
		doorway_8.close()
		doorway_9.close()
		torch_17.light(true)
	
	if doorway_10.justPassed || doorway_11.justPassed:
		doorway_10.close()
		doorway_11.close()
		for enemy in get_child(3).getBanished():
			enemy.global_position.x = 1870
			enemy.global_position.y = -2350
	if floor_button_19.isJustPressed():
		torch_21.light(true)
	if floor_button_22.isJustPressed():
		if torch_21.lit:
			torch_22.light(true)
	if floor_button_20.isJustPressed():
		if torch_22.lit:
			torch_23.light(true)
		else:
			torch_21.light(false)
	if floor_button_21.isJustPressed():
		if torch_23.lit:
			torch_24.light(true)
		else:
			torch_21.light(false)
			torch_22.light(false)
	if torch_21.lit && torch_22.lit && torch_23.lit && torch_24.lit:
		get_child(0).set_cell(1, Vector2i(62, -83), 0, Vector2i(8, 13))
		get_child(0).set_cell(1, Vector2i(62, -84), 0, Vector2i(8, 12))
		area_2d.monitoring = true
