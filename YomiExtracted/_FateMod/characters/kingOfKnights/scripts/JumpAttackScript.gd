extends KokNormalAttackState

var defaultForce = null

func _enter():
	._enter()
	# saving for later as we are changing the variable directly
	if defaultForce == null:
		defaultForce = Vector2(force_dir_x, force_dir_y)

func _frame_0():
	if data:
		# Getting user input and coverting it into direction
		# [NOTE] Prob don't need to convert
		var dir = xy_to_dir(data.x, data.y, "1.5")
		
		# Adding user's direction multiplier to the default jump arc 
		force_dir_x = defaultForce.x * float(dir.x)
		force_dir_y = defaultForce.y * float(dir.y)
		
		# Ensuring that the jump doesn't go opposite way or down
		if force_dir_y > 0:
			force_dir_y *= -1
		if force_dir_x < 0:
			force_dir_x *= -1
