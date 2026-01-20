extends ThrowState

func _frame_1():
	host.opponent.change_state("Knockdown")
	host.opponent.hitlag_ticks = 1
