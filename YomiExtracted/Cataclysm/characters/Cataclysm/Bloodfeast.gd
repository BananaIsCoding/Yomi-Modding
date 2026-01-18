extends Fighter

var bloodfeast = 0

func tick():
	.tick()
	if bloodfeast > 100:
		bloodfeast = 100
	if bloodfeast < 0:
		bloodfeast = 0
