extends ParticleEffect

func EnableParticles():
	for child in get_children():
		if child is Particles2D:
			child.one_shot = one_shot
			child.emitting = start_enabled
		elif child is CPUParticles2D:
			child.one_shot = one_shot
			child.emitting = start_enabled
		elif child is AnimatedSprite:
			child.playing = false
			child.frame = 0
		elif child is AudioStreamPlayer2D:
			sounds_played[child] = false
			

func DisableParticles():
	if hooks:
		hooks.stop_emitting()
	for child in get_children():
		if child is Particles2D:
			child.emitting = false
		if child is CPUParticles2D:
			child.emitting = false
