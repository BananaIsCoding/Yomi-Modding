extends Fighter

## Variables ##
export (Array, String) var stanceAnimKey = [ "", "(Armour)", "(Hidden)", "(HiddenArmour)" ]

var comboAttackCD = 0
var currentExcalCharge = 0
var skillCd = 0
var critChance = 0
var critStar = 0
var dmgBoost := -0.1
var specialBoost := 0
var armourOn = false
var damageReduction = 0.0
var commandSeals := 3
var playerExtra
var cutsceneInProgress := false

# Camera and emote related variables
class BoostData:
	var boostType
	var instance
	var tickRemaining : int
	var strength

enum BoostType {DmgBoost, SpecialBoost}

var cameraTween
var Emoting = false
var EmoteTimer = 0

const new_modulate_alpha = 0.0
const fade_speed = 0.30 # Lower number = slower

# Boost related variables
var BoostInfoUiInstance
var BoostQueue = []
var CritStartUi = null
var dmgBoostPng = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/NormalAttackUp.png")
var specialBoostPng = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/SpecialAttackUp.png")
var critStarPng = load("res://_FateMod/characters/kingOfKnights/sprites/UiSprites/CritStar.png")
var BoostToRemove = []

# Hidden blade related variables
export var _c_Hidden_Blade_Stuff = 0
export (int) var hiddenBladePercentChance = 40
export (int) var ticksUntilDecreaseHidden = 30
export (int) var hiddenBladeDecreaseRate = 1
var lastAttackLockIn = 0

var tipToggle = false

func update_property_list():
	# A full override because I do not want it to check ghost again
	# (Will check here then in the super function, if I did not overwrite)
	if not is_ghost:
		if busy_interrupt and commandSeals > 0:
			playerExtra.show()
			playerExtra.show_options()
		for state in state_machine.states_map:
			state_machine.states_map[state].update_property_list()
	
## Functions ##
func tick():
	if cutsceneInProgress:
		state_tick()
		return
	
	.tick()
	
	# Decrement cd timer
	if comboAttackCD > 0:
		 comboAttackCD -= 1
	if skillCd > 0:
		skillCd -= 1
	
	
	if (stance == "Hidden" or stance == "Hidden(Armour)") and hiddenBladePercentChance > 0:
		if game_tick % ticksUntilDecreaseHidden == 0:
			hiddenBladePercentChance -= hiddenBladeDecreaseRate
	
	if not is_ghost:
		# Updating current boosts
		if (!BoostQueue.empty()):
			for index in range(BoostQueue.size()):
				# Update tick for boost
				BoostQueue[index].tickRemaining -= 1
				if BoostQueue[index].tickRemaining <= 0:
					
					# Remove the boost buff when expired
					if BoostQueue[index].boostType == BoostType.DmgBoost:
						dmgBoost -= BoostQueue[index].strength
					elif BoostQueue[index].boostType == BoostType.SpecialBoost:
						specialBoost -= BoostQueue[index].strength
					
					# Remove from UI
					if id == 2:
						BoostInfoUiInstance.RemoveBoost(BoostQueue[index].instance)
					else:
						BoostQueue[index].instance.queue_free()
						#BoostQueue[index].instance.disable()
					
					# Save to remove later when all boost been checked
					BoostToRemove.append(index)
				else:
					# Update Boost Info/Tooltip
					if BoostQueue[index].boostType == BoostType.DmgBoost:
						var newToolTip = "+" + str(BoostQueue[index].strength * 100) + "% Damage Boost ( " + str(BoostQueue[index].tickRemaining) + " ticks )"
						BoostQueue[index].instance.hint_tooltip = newToolTip
					elif BoostQueue[index].boostType == BoostType.SpecialBoost:
						var newToolTip = "+" + str(BoostQueue[index].strength * 100) + "% Special Damage Boost ( " + str(BoostQueue[index].tickRemaining) + " ticks )"
						BoostQueue[index].instance.hint_tooltip = newToolTip
			
			# Remove the expired boosts
			for i in range(BoostToRemove.size()):
				BoostQueue.remove(BoostToRemove[i])
			BoostToRemove.clear()
	
	EmoteHandler()

## 100% my functions I think (why is there no region in godot) ##

func SaveTick():
	lastAttackLockIn = current_tick

func CalcCritChance():
	return critChance + (critStar * 3)

func AddDamageBoost(percentage, duration):
	# [NOTE] will add if statement for alter form
	dmgBoost += percentage
	
	var newItem = BoostData.new()
	newItem.boostType = BoostType.DmgBoost
	newItem.tickRemaining = duration
	newItem.strength = percentage
	var newToolTip = "+" + str(percentage * 100) + "% Damage Boost ( " + str(duration) + " ticks )"
	newItem.instance = BoostInfoUiInstance.AddBoost(dmgBoostPng, newToolTip)
	
	BoostQueue.append(newItem)
	
func AddSpecialBoost(percentage, duration):
	specialBoost += percentage
	
	var newItem = BoostData.new()
	newItem.boostType = BoostType.SpecialBoost
	newItem.tickRemaining = duration
	newItem.strength = percentage
	var newToolTip = "+" + str(specialBoost * 100) + "% Special Damage Boost ( " + str(duration) + " ticks )"
	newItem.instance = BoostInfoUiInstance.AddBoost(specialBoostPng, newToolTip)
	
	BoostQueue.append(newItem)

func ApplyInstinctSkill():
	critStar += 15;
	gain_super_meter_raw(MAX_SUPER_METER)
	var newToolTip = str(critStar) + " crit Stars"
	
	# Checks if there not already another crit icon
	if CritStartUi == null:
		CritStartUi = BoostInfoUiInstance.AddBoost(critStarPng, newToolTip)
	else:
		# Update it if there is
		CritStartUi.hint_tooltip = newToolTip

func ToggleArmorMode():
	armourOn = !armourOn
	if armourOn:
		damageReduction = 0.1
	else:
		damageReduction = 0.0
	BoostInfoUiInstance.ChangeMainBuff(armourOn)

func RevealThyBlade():
	dmgBoost += 0.1
	var instalIcon = BoostInfoUiInstance.installBuffSlot

func UseCommandSeal():
	commandSeals -= 1
	playerExtra.UpdateCommandSeals(commandSeals)

# camera controls functions from guide 
func tween_camera_zoom(initial_value, end_value, duration, transition_type, ease_type):
	if is_ghost or ReplayManager.resimulating:
		return 
	var game = Global.current_game
	
	#emit_signal("zoom_changed")
	if cameraTween:
		cameraTween.kill()
		set_camera_zoom(initial_value)
		
	cameraTween = game.create_tween()
	
	cameraTween.set_parallel(true)
	cameraTween.set_trans(transition_type)
	cameraTween.set_ease(ease_type)
	
	cameraTween.tween_property(game, "camera_zoom", initial_value, 0.0025)
	
	cameraTween.set_ease(ease_type)
	cameraTween.tween_property(game, "camera_zoom", end_value, duration)
	
	yield (cameraTween, "finished")
	if not is_instance_valid(self):
		return 
	cameraTween.kill()
	game.update_camera_limits()

func set_camera_zoom(value):
	if is_ghost or ReplayManager.resimulating:
		return 
	if cameraTween:
		cameraTween.kill()
	var game = Global.current_game
	game.camera_zoom = value
	#emit_signal("zoom_changed")
	game.update_camera_limits()

func ShowHintText(message):
	$EmoteLabel.clear()
	$EmoteLabel.append_bbcode("[center]" + message)
	$EmoteLabel.show()

func HideHintText():
	$EmoteLabel.clear()
	$EmoteLabel.hide()

# emote/text functions from guide 
func emote(message):
	ReplayManager.emote(message, id, current_tick)
	$EmoteLabel.clear()
	$EmoteLabel.append_bbcode("[center]" + message)
	$EmoteLabel.visible_characters = 0
	$EmoteLabel.percent_visible = 0
	$EmoteLabel.show()
	$EmoteLabel.modulate.a = 1.0
	Emoting = true
	EmoteTimer = 0
func EmoteHandler():
	if $EmoteLabel.bbcode_text != "":
		Emoting = true
	if Emoting:
		if $EmoteLabel.percent_visible < 1.0:
			if current_tick % 3 == 0:
				$EmoteLabel.visible_characters += randi_range(1, 2)
				#play_sound("Dialogue")
		else:
			EmoteTimer += 1
		if EmoteTimer >= 40:
			$EmoteLabel.modulate.a = lerp($EmoteLabel.modulate.a, 0.0, 0.12)
		if EmoteTimer > 90:
			$EmoteLabel.percent_visible = 0.0
			$EmoteLabel.visible_characters = 0
			$EmoteLabel.hide()
			$EmoteLabel.bbcode_text = ""
			Emoting = false
			EmoteTimer = 0

# UI hider from guide
func UITweener():
	if not is_ghost:
		get_node("/root/Main/%HudLayer/HudLayer").modulate.a = lerp(get_node("/root/Main/%HudLayer/HudLayer").modulate.a, new_modulate_alpha, fade_speed)
		get_node("/root/Main/%HudLayer/%GameUI").modulate.a = lerp(get_node("/root/Main/%HudLayer/%GameUI").modulate.a, new_modulate_alpha, fade_speed)
		get_node("/root/Main/%HudLayer/%GameUI/%BottomBar").modulate.a = lerp(get_node("/root/Main/%HudLayer/%BottomBar").modulate.a, new_modulate_alpha, fade_speed)
func UIResetter():
	if not is_ghost:
		get_node("/root/Main/%HudLayer/HudLayer").modulate.a = lerp(get_node("/root/Main/%HudLayer/HudLayer").modulate.a, 1.0, fade_speed)
		get_node("/root/Main/%HudLayer/%GameUI").modulate.a = lerp(get_node("/root/Main/%HudLayer/%GameUI").modulate.a, 1.0, fade_speed)
		get_node("/root/Main/%HudLayer/%GameUI/%BottomBar").modulate.a = lerp(get_node("/root/Main/%HudLayer/%BottomBar").modulate.a, 1.0, fade_speed)
func quick_ui_hider():
	if not is_ghost:
		get_node("/root/Main/%HudLayer/HudLayer").modulate.a = 0.0
		get_node("/root/Main/%HudLayer/%GameUI").modulate.a = 0.0
		get_node("/root/Main/%HudLayer/%GameUI/%BottomBar").modulate.a = 0.0
func quick_ui_revealer():
	if not is_ghost:
		get_node("/root/Main/%HudLayer/HudLayer").modulate.a = 1.0
		get_node("/root/Main/%HudLayer/%GameUI").modulate.a = 1.0
		get_node("/root/Main/%HudLayer/%GameUI/%BottomBar").modulate.a = 1.0

# Char Extra Function from guide

func process_extra(extra):
	.process_extra(extra)
	if extra.has("Tips"):
		tipToggle = extra.Tips
		if not tipToggle and is_ghost:
			Network.game.get_player(id).HideHintText()
 
# overriding to support damage reduction 
func take_damage(damage: int, minimum = 0, meter_gain_modifier = "1.0", combo_scaling_offset = 0, damage_taken_meter_gain_modifier = "1.0", self_hit = false, armor_block = false):
	# apply damage reduction before calc starts
	damage *= 1 - damageReduction
	
	var combo_ref = self if self_hit else opponent

	if combo_ref.combo_count == 0:
		trail_hp = get_visual_hp()

	if damage == 0:
		return

	gain_burst_meter(damage / BURST_ON_DAMAGE_AMOUNT)
	var damage_score = Utils.int_max(damage, minimum)
	damage = Utils.int_max(combo_stale_damage(damage, combo_scaling_offset), 1)
	damage = Utils.int_max(damage, minimum)
	damage = Utils.int_max(guts_stale_damage(damage), 1)

	if not self_hit:
		if opponent.parried_burst_combo:
			damage = fixed.round(fixed.mul(str(damage), burst_parry_combo_scaling))
		elif opponent.parry_combo:
			damage = fixed.round(fixed.mul(str(damage), parry_combo_scaling))
	damage = fixed.round(fixed.mul(str(damage), get_penalty_damage_modifier()))
	var meter_gain = fixed.round(fixed.mul(str(damage / DAMAGE_SUPER_GAIN_DIVISOR), meter_gain_modifier))

	if not self_hit:
		opponent.gain_super_meter(meter_gain)
		
	gain_super_meter(fixed.round(fixed.mul(str(damage / DAMAGE_TAKEN_SUPER_GAIN_DIVISOR), damage_taken_meter_gain_modifier)))
	damage = fixed.round(fixed.mul(fixed.mul(str(damage), damage_taken_modifier), global_damage_modifier))
	if not self_hit:
		opponent.combo_damage += damage
	
	hp -= damage
	add_penalty( - 25)
	if hp < 0:
		hp = 0
	if current_state().get("IS_NEW_PARRY") and current_state().push:
		if hp <= 0:
			hp = 1
