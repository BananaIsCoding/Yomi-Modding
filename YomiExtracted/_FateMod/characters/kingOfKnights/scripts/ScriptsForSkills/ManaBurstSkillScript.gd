extends SkillState

func _exit():
	._exit()
	host.AddSpecialBoost(0.5, 80)
