extends SkillState
	
func _exit():
	._exit()
	if !host.is_ghost:
		host.AddSpecialBoost(0.5, 80)
		host.emote("Special Dmg Buff")
