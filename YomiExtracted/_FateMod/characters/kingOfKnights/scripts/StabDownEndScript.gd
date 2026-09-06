extends ThrowState

func _frame_1():
	host.opponent.change_state("Knockdown")
	host.opponent.hitlag_ticks = 1
	host.opponent.take_damage(60)
	
func _frame_10():
	host.opponent.change_state("Knockdown")
	host.opponent.hitlag_ticks = 1
