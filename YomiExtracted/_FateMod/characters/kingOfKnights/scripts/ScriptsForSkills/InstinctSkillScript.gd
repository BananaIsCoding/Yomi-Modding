extends SkillState

func _exit():
	._exit()
	host.ApplyInstinctSkill()
