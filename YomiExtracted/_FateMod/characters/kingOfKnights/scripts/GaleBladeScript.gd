extends CharacterState

export (PackedScene) var SlashProjectile
# Temp for now (will be replaced by UI Data)
export var projPosX = 0
export var projPosY = 0

export (String) var diagonalUpAnimName; 
export (String) var diagonalDownAnimName;
export (String) var directlyUpAnimName;
export (String) var directlyDownAnimName; 

func _frame_7():
	var projectObject
	
	if data.x == host.get_facing_int():
		if data.y == 0:
			projectObject = host.spawn_object(SlashProjectile, projPosX, projPosY)
		elif data.y == -1:
			print("Diagonal Up")
			host.change_state(diagonalUpAnimName)
		else:
			print("Diagonal Down")
			host.change_state(diagonalDownAnimName)
	if data.x == 0:
		if data.y == -1:
			host.change_state(directlyUpAnimName)
		elif data.y == 1:
			host.change_state(directlyDownAnimName)
