extends CharacterState

## Variables ##

export (PackedScene) var SlashProjectile

# Index 0 - Normal Stance
# Index 1 - Armour Stance
# Index 2 - Hidden Stance
# Index 3 - Hidden + Armour Stance
export (Array, String) var defaultAnimNameArray;
export (Array, String) var diagonalUpAnimNameArray; 
export (Array, String) var diagonalDownAnimNameArray;
export (Array, String) var directlyUpAnimNameArray;
export (Array, String) var directlyDownAnimNameArray; 

## Functions ##
func _ready():
	._ready()
	
	# Ensure the normal animations is set
	ValidateArraySize(defaultAnimNameArray)
	if (defaultAnimNameArray[0] == "" or defaultAnimNameArray[0] == null):
		defaultAnimNameArray[0] = sprite_animation
	
	# For each direction, checks if stance-variant animations is set
	CheckValidAnim(defaultAnimNameArray, 0)
	CheckValidAnim(diagonalUpAnimNameArray, 1)
	CheckValidAnim(diagonalDownAnimNameArray, 2)
	CheckValidAnim(directlyUpAnimNameArray, 3)
	CheckValidAnim(directlyDownAnimNameArray, 4)

# Change animations base on direction given
func _enter():
	
	var stanceId := 0
	
	match host.stance:
		"Normal(Armour)":
			stanceId = 1
	
	if data.x == host.get_facing_int():
		if data.y == -1:
			anim_name = diagonalUpAnimNameArray[stanceId]
		elif data.y == 1:
			anim_name = diagonalDownAnimNameArray[stanceId]
		else:
			anim_name = defaultAnimNameArray[stanceId]
	elif data.x == 0:
		if data.y == -1:
			anim_name = directlyUpAnimNameArray[stanceId]
		if data.y == 1:
			anim_name = directlyDownAnimNameArray[stanceId]

# Spawning the projectile 
# and rotating it based on the directions (char facing and action data)
func _frame_7():
	var projectObject
	
	if data.x == host.get_facing_int():
		if data.y == 0:
			projectObject = host.spawn_object(SlashProjectile, 27, -20)
			return
		if data.y == -1:
			projectObject = host.spawn_object(SlashProjectile, 15, -35)
			projectObject.rotation_degrees = -45
			if (host.id == 2):
				projectObject.flip.rotation_degrees = 90
		else:
			projectObject = host.spawn_object(SlashProjectile, 15, -5)
			projectObject.rotation_degrees = 45
			if (host.id == 2):
				projectObject.flip.rotation_degrees = -90
	
	if data.x == 0:
		if data.y == -1:
			projectObject = host.spawn_object(SlashProjectile, 0, -45)
			projectObject.rotation_degrees = -90 
		elif data.y == 1:
			projectObject = host.spawn_object(SlashProjectile, 0, -5)
			projectObject.rotation_degrees = 90 
		if (host.id == 2):
			projectObject.flip.rotation_degrees = 180

func CheckValidAnim(animNameArray:Array, RowInArray):
	
	ValidateArraySize(animNameArray)
	if (animNameArray[0] == null):
		return
	# For each stance
	for i in range(1,host.stanceAnimKey.size()):
		# If emtpy attempt to guess the animation name / follow naming convention 
		if animNameArray[i] == "" or animNameArray[i] == null:
			animNameArray[i] = animNameArray[0] + host.stanceAnimKey[i]

# Ensures the array is not empty/wrong length
# So it doesn't get invalid index error
func ValidateArraySize(animNameArray:Array):
	if (animNameArray.size() < host.stanceAnimKey.size()):
		animNameArray.resize(host.stanceAnimKey.size())
