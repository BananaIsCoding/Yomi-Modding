extends ThrowState

func _enter():
	host.opponent.change_state("Knockdown")
	host.opponent.hitlag_ticks = 1
