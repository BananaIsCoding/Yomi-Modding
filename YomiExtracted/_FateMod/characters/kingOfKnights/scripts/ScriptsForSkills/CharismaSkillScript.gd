extends SkillState

func _exit():
	._exit()
	if !host.is_ghost:
		host.AddDamageBoost(0.2, 160)
		host.emote("Dmg Buff")
