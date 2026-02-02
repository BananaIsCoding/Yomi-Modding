extends SkillState
	
func _exit():
	._exit()
	host.AddSpecialBoost(0.5, 80)
	host.emote("50% Special Damage Increase")
