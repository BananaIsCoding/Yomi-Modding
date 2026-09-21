extends CharacterState

## Variables ##



# Index 0 - Normal Stance
# Index 1 - Armour Stance
# Index 2 - Hidden Stance
# Index 3 - Hidden + Armour Stance
export (Array, String) var defaultAnimNameArray;
export (Array, String) var diagonalUpAnimNameArray; 
export (Array, String) var diagonalDownAnimNameArray;
export (Array, String) var directlyUpAnimNameArray;
export (Array, String) var directlyDownAnimNameArray; 

export var _c_ProjectileStuff = 0
export (PackedScene) var SlashProjectile
export var projectileSpeed = 5
export var projectileLifetime = 300

## Functions ##
func _ready():
	._ready()
	
	# Ensure the normal animations is set
	ValidateArraySize(defaultAnimNameArray)
	if (defaultAnimNameArray[0] == "" or defaultAnimNameArray[0] == null):
		defaultAnimNameArray[0] = sprite_animation
	
	# For each direction, checks if stance-variant animations is set
	CheckValidAnim(defaultAnimNameArray)
	CheckValidAnim(diagonalUpAnimNameArray)
	CheckValidAnim(diagonalDownAnimNameArray)
	CheckValidAnim(directlyUpAnimNameArray)
	CheckValidAnim(directlyDownAnimNameArray)

# Change animations base on direction given
func _enter():
	
	var stanceId := 0
	
	match host.stance:
		"Normal(Armour)":
			stanceId = 1
		"Hidden":
			stanceId = 2
		"Hidden(Armour)":
			stanceId = 3
	
	if data.x >= 90:
		anim_name = defaultAnimNameArray[stanceId]
	elif data.x >= 45:
		if data.y > 0:
			anim_name = diagonalDownAnimNameArray[stanceId]
		else:
			anim_name = diagonalUpAnimNameArray[stanceId]
	else:
		if data.y > 0:
			anim_name = directlyDownAnimNameArray[stanceId]
		else:
			anim_name = directlyUpAnimNameArray[stanceId]

# Spawning the projectile 
func _frame_7():
	var projectObject
	var projData = {"dir":xy_to_dir(data.x, data.y, str(projectileSpeed), "100"),"speed":projectileSpeed,"lifetime":projectileLifetime,"dmgBoost": host.dmgBoost + host.specialBoost}
	projectObject = host.spawn_object(SlashProjectile, data.x / 3 * host.get_facing_int(),  (data.y / 3) - 20, true, projData)

func CheckValidAnim(animNameArray:Array):
	
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
