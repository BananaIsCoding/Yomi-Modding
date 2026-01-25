extends CharacterState

export (PackedScene) var SlashProjectile
# Temp for now (will be replaced by UI Data)
export var projPosX = 0
export var projPosY = 0

export (String) var diagonalUpAnimName; 
export (String) var diagonalDownAnimName;
export (String) var directlyUpAnimName;
export (String) var directlyDownAnimName; 

func _enter():
	if data.x == host.get_facing_int():
		if data.y == -1:
			anim_name = diagonalUpAnimName
		elif data.y == 1:
			anim_name = diagonalDownAnimName
	if data.x == 0:
		if data.y == -1:
			anim_name = directlyUpAnimName
	#		elif data.y == 1:
	#			host.change_state(directlyDownAnimName)

func _frame_7():
	var projectObject
	
	if data.x == host.get_facing_int():
		if data.y == 0:
			projectObject = host.spawn_object(SlashProjectile, 27, -20)
		elif data.y == -1:
			projectObject = host.spawn_object(SlashProjectile, 15, -35)
			projectObject.rotation_degrees = -45
		else:
			projectObject = host.spawn_object(SlashProjectile, 15, -5)
			projectObject.rotation_degrees = 45
	if data.x == 0:
		if data.y == -1:
			projectObject = host.spawn_object(SlashProjectile, 0, -45)
			projectObject.rotation_degrees = -90
		elif data.y == 1:
			projectObject = host.spawn_object(SlashProjectile, 0, -5)
			projectObject.rotation_degrees = 90
