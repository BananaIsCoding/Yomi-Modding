extends CommandSpellState

func DoCommandSpell():
	if !host.is_ghost:
		host.AddDamageBoost(0.2, 160 + anim_length)
