extends Fighter

# adding variable to storing combo cd timer
var comboAttackCD = 0

func tick():
	.tick()
	# Decrement cd timer
	if comboAttackCD > 0:
		 comboAttackCD -= 1
