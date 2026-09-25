extends CommandSpellState

func _enter():
	._enter()
	host.start_invulnerability()
	host.start_projectile_invulnerability()
	interruptible_on_opponent_turn = false
	host.opponent.reset_combo()
	
func _exit():
	._exit()
	host.end_invulnerability()
	host.end_projectile_invulnerability()

func DoCommandSpell():
	force_speed = "5.0"
	host.apply_grav()
