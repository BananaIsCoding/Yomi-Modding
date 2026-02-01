extends SkillState

func _exit():
	._exit()
	host.AddDamageBoost(0.2, 160)
