extends Fighter

# adding variable to storing combo cd timer
var comboAttackCD = 0
var currentExcalCharge = 0
var skillCd = 0
var critChance = 0
var critStar = 0

func tick():
	.tick()
	# Decrement cd timer
	if comboAttackCD > 0:
		 comboAttackCD -= 1
	if skillCd > 0:
		skillCd -= 1

func CalcCritChance():
	return critChance + (critStar * 3)
