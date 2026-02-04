extends SkillState

func _exit():
	._exit()
	if !host.is_ghost:
		host.ApplyInstinctSkill()
		host.emote("+ Crit Stars")
