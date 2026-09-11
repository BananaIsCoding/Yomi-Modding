extends GroundedParryState

export (Array, String) var highParryAnimNameArray = ["ParryHigh"]
export (Array, String) var lowParryAnimNameArray = ["ParryLow"]
export (Array, String) var highShieldAnimNameArray = ["ShieldHigh"]
export (Array, String) var lowShieldAnimNameArray = ["ShieldLow"]

var currentStance := 0

func _ready():
	
	CheckValidAnim(highParryAnimNameArray)
	CheckValidAnim(lowParryAnimNameArray)
	CheckValidAnim(highShieldAnimNameArray)
	CheckValidAnim(lowShieldAnimNameArray)
	
	._ready()

func _enter():
	
	match host.stance:
		"Normal":
			currentStance = 0
		"Normal(Armour)":
			currentStance = 1
	._enter()

func start():
	started_in_combo = host.combo_count > 0
	endless = false
	perfect = true
	parry_type = initial_parry_type
	parry_type = ParryHeight.High if data["Block Height"].y == 0 else ParryHeight.Low
	parry_active = true
	parry_tick = 0
	parried = false
	interruptible_on_opponent_turn = host.combo_count <= 0
	anim_length = 20 + extra_iasa
	iasa_at = - 1
	host.blocked_hitbox_plus_frames = 0

	var high_anim = highParryAnimNameArray[currentStance] if not use_guard_sprites else highShieldAnimNameArray[currentStance]
	var low_anim = lowParryAnimNameArray[currentStance] if not use_guard_sprites else lowShieldAnimNameArray[currentStance]
	if host.is_grounded():
		anim_name = high_anim if data["Block Height"].y == 0 else low_anim
	else:
		anim_name = low_anim

## Utility Functions ##
func CheckValidAnim(animNameArray:Array):
	
	if (animNameArray.size() < host.stanceAnimKey.size()):
		animNameArray.resize(host.stanceAnimKey.size())
		
	if (animNameArray[0] == null):
		return
	# For each stance
	for i in range(1,host.stanceAnimKey.size()):
		# If emtpy attempt to guess the animation name / follow naming convention 
		if animNameArray[i] == "" or animNameArray[i] == null:
			animNameArray[i] = animNameArray[0] + host.stanceAnimKey[i]
