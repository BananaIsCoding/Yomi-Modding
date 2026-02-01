extends Fighter

# adding variable to storing combo cd timer
var comboAttackCD = 0
var currentExcalCharge = 0
var skillCd = 0
var critChance = 0
var critStar = 0
var dmgBoost = 0
var dmgBoostDuration = 0
var specialBoost = 0
var specialBoostDuration = 0
var armorOn = false
var damageReduction = 0.0

var tween


func tick():
	.tick()
	# Decrement cd timer
	if comboAttackCD > 0:
		 comboAttackCD -= 1
	if skillCd > 0:
		skillCd -= 1

# 100% my functions I think (why is there no region in godot)
func CalcCritChance():
	return critChance + (critStar * 3)
	
func AddDamageBoost(percentage, duration):
	# will add if statement for alter form
	dmgBoost = percentage
	dmgBoostDuration = duration
	
func AddSpecialBoost(percentage, duration):
	specialBoost = percentage
	specialBoostDuration = duration
	
func ApplyInstinctSkill():
	critStar += 15;
	gain_super_meter_raw(MAX_SUPER_METER)

func ToggleArmorMode():
	armorOn = !armorOn
	print("Script acknowledge the armor change")
	if armorOn:
		damageReduction = 0.2
	else:
		damageReduction = 0.0

# camera controls functions from guide 
func tween_camera_zoom(initial_value, end_value, duration, transition_type, ease_type):
	if is_ghost or ReplayManager.resimulating:
		return 
	var game = Global.current_game
	
	#emit_signal("zoom_changed")
	if tween:
		tween.kill()
		set_camera_zoom(initial_value)
		
	tween = game.create_tween()
	
	tween.set_parallel(true)
	tween.set_trans(transition_type)
	tween.set_ease(ease_type)
	
	tween.tween_property(game, "camera_zoom", initial_value, 0.0025)
	
	tween.set_ease(ease_type)
	tween.tween_property(game, "camera_zoom", end_value, duration)
	
	yield (tween, "finished")
	if not is_instance_valid(self):
		return 
	tween.kill()
	game.update_camera_limits()
	
func set_camera_zoom(value):
	if is_ghost or ReplayManager.resimulating:
		return 
	if tween:
		tween.kill()
	var game = Global.current_game
	game.camera_zoom = value
	emit_signal("zoom_changed")
	game.update_camera_limits()
	
# overriding to support damage reduction
func take_damage(damage: int, minimum = 0, meter_gain_modifier = "1.0", combo_scaling_offset = 0, damage_taken_meter_gain_modifier = "1.0"):
	
	if opponent.combo_count == 0:
		trail_hp = get_visual_hp()

	if damage == 0:
		return

	gain_burst_meter(damage / BURST_ON_DAMAGE_AMOUNT)
	var damage_score = Utils.int_max(damage, minimum)
	damage = Utils.int_max(combo_stale_damage(damage, combo_scaling_offset), 1)
	damage = Utils.int_max(damage, minimum)
	damage = Utils.int_max(guts_stale_damage(damage), 1)
	
	if opponent.parry_combo:
		damage = fixed.round(fixed.mul(str(damage), PARRY_COMBO_SCALING))
	damage = fixed.round(fixed.mul(str(damage), get_penalty_damage_modifier()))
	var meter_gain = fixed.round(fixed.mul(str(damage / DAMAGE_SUPER_GAIN_DIVISOR), meter_gain_modifier))

	opponent.gain_super_meter(meter_gain)

	gain_super_meter(fixed.round(fixed.mul(str(damage / DAMAGE_TAKEN_SUPER_GAIN_DIVISOR), damage_taken_meter_gain_modifier)))
	damage = fixed.round(fixed.mul(fixed.mul(str(damage), damage_taken_modifier), global_damage_modifier))
	opponent.combo_damage += damage
	
	# if armour state
	damage *= 1 - damageReduction
	hp -= damage
	add_penalty( - 25)
	if hp < 0:
		hp = 0
	if current_state().get("IS_NEW_PARRY") and current_state().push:
		if hp <= 0:
			hp = 1
