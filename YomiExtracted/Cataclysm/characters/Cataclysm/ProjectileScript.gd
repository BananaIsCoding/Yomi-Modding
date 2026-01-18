extends ParticleEffect

func tick():
	.tick()
	if tick == 20:
		$CPUParticles2D2.gravity.y = 20
