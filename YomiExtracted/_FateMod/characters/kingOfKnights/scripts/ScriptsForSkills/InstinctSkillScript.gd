extends SkillState

func _exit():
	._exit()
	host.ApplyInstinctSkill()
	host.emote("+15 Crit Stars")
