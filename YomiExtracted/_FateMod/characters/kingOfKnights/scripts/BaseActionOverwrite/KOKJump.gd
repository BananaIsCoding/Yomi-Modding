extends "res://characters/states/Jump.gd"

export (Array, String) var jumpAnimNameArray = ["Jump"]
export (Array, String) var jumpBackAnimNameArray = ["JumpBack"]
export (Array, String) var fallAnimNameArray = ["Fall"]
export (Array, String) var landAnimNameArray = ["Landing"]

var currentStance := 0

func _ready():
	
	CheckValidAnim(jumpAnimNameArray)
	CheckValidAnim(jumpBackAnimNameArray)
	CheckValidAnim(fallAnimNameArray)
	CheckValidAnim(landAnimNameArray)
	
	._ready()

func _enter():
	
	match host.stance:
		"Normal":
			currentStance = 0
		"Normal(Armour)":
			currentStance = 1
	
	# Overriding content of previous "_enter" Func
	anim_name = landAnimNameArray[currentStance]
	if (data is String and data == "homing") or data == null:
		var dir = host.get_opponent_dir_vec()
		if fixed.gt(dir.y, "-0.34"):
			dir.y = "-0.34"
			dir.x = fixed.mul(str(host.get_facing_int()), "0.94")
		dir = fixed.normalized_vec(dir.x, dir.y)
		data = {
			"x": fixed.round(fixed.mul(dir.x, "100")), 
			"y": fixed.round(fixed.mul(dir.y, "100"))
		}

	squat = is_squat()
	if not squat:
		host.start_throw_invulnerability()

## Overwriting Base Function ##
func _tick():
	if current_tick >= jump_tick:
		if "-" in force_x:
			if host.get_facing() == "Right" and data.x != 0:
				anim_name = jumpBackAnimNameArray[currentStance]
			else:
				anim_name = jumpAnimNameArray[currentStance]
		else:
			if host.get_facing() == "Left" and data.x != 0:
				anim_name = jumpBackAnimNameArray[currentStance]
			else:
				anim_name = jumpAnimNameArray[currentStance]
		if fall_anim:
			if fixed.gt(host.get_vel().y, fall_anim_speed):
				anim_name = fallAnimNameArray[currentStance]
		host.apply_grav()
		if not super_jump or fixed.gt(host.get_vel().y, "0") or current_tick > SUPER_JUMP_FORCES_END_TICK:
			host.apply_forces()
		else:
			host.apply_forces_no_limit()
	if current_tick > jump_tick:
		if host.is_grounded():
			return "Landing"

func _frame_0():
	
	if data is String and data == "homing":
		var dir = host.get_opponent_dir_vec()
		if fixed.gt(dir.y, "-0.34"):
			dir.y = "-0.34"
			dir.x = fixed.mul(str(host.get_facing_int()), "0.94")
		dir = fixed.normalized_vec(dir.x, dir.y)
		data = {
			"x": fixed.round(fixed.mul(dir.x, "100")), 
			"y": fixed.round(fixed.mul(dir.y, "100"))
		}

	if not super_jump:
		interruptible_on_opponent_turn = true
	next_state_on_hold = false
	next_state_on_hold_on_opponent_turn = false
	queue_backdash_check = false
	var vec = xy_to_dir(data["x"], data["y"], "1")
	var length = fixed.vec_len(vec.x, vec.y)
	var full_hop = fixed.gt(length, FULL_HOP_LENGTH)
	var back = fixed.sign(str(data["x"])) != host.get_facing_int() or data["x"] == 0
	squat = is_squat()
	if squat and not back:
		current_tick = 3

	if back and host.combo_count <= 0:
		host.add_penalty(back_full_hop_sadness if full_hop else back_short_hop_sadness)
		backdash_iasa = true
		beats_backdash = false
	else:
		backdash_iasa = false
		beats_backdash = not (host.opponent.current_state().beats_backdash)
		if (host.opponent.current_state().name == "Jump" or host.opponent.current_state().name == "DoubleJump" or host.opponent.current_state().name == "SuperJump"):
			queue_backdash_check = true
	if not squat:
		jump_tick = 1
		jump()
	else:
		jump_tick = 4 if not super_jump else 7
		anim_name = landAnimNameArray[currentStance]

	if not super_jump:
		if squat:
			interrupt_frames[0] = 14
			interrupt_frames[1] = 25
			if not back:
				interrupt_frames[0] = 14
				interrupt_frames[1] = 24
		elif full_hop:
			interrupt_frames[0] = 10
			interrupt_frames[1] = 21
		else:
			interrupt_frames[0] = SHORT_HOP_IASA if host.combo_count <= 0 else SHORT_HOP_COMBO_IASA
			interrupt_frames[1] = 18
	sfx_tick = jump_tick

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
